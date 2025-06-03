library(tidyverse)
library(sf)
library(tidycensus)
census_api_key(Sys.getenv('CENSUS_API_KEY'))
library(tigris)
options(tigris_use_cache=TRUE)
options(tigris_class='sf')

#### get all ACS tract-level variables -----------------------------------

states_needed <- tigris::fips_codes %>%
    select(state_code, state_name) %>%
    filter(! state_name %in% c('American Samoa', 'Guam', 'Northern Mariana Islands',
                               'Puerto Rico', 'U.S. Minor Outlying Islands',
                               'U.S. Virgin Islands')) %>%
    unique() %>%
    pull(state_code)

## fraction_poverty
# income in past 12 months below poverty level
    # B17001_001: total
    # B17001_002: n
acs_poverty <- get_acs(geography = 'tract',
                       variables = 'B17001_002',
                       summary_var = 'B17001_001',
                       endyear = 2015,
                       state = states_needed) %>%
    mutate(fraction_poverty = estimate / summary_est) %>%
    select(GEOID, fraction_poverty)

## median_income
# median household income in the past 12 months in 2015 inflation-adjusted dollars
    # B19013_001: est
acs_income <- get_acs(geography = 'tract',
                      variables = 'B19013_001',
                      endyear = 2015,
                      state = states_needed) %>%
    mutate(median_income = estimate) %>%
    select(GEOID, median_income)

## fraction_high_school_edu
# population 25 and older with edu attainment of at least high school graduate (includes GED equivalency)
    # B15003_001: total
    # B15003_{017 - 025}: n
acs_edu <- get_acs(geography = 'tract',
                       variables = paste0('B15003_0',17:25),
                       summary_var = 'B15003_001',
                       endyear = 2015,
                       state = states_needed) %>%
    group_by(GEOID) %>%
    summarize(high_school_edu = sum(estimate),
              total = unique(summary_est)) %>%
    mutate(fraction_high_school_edu = high_school_edu / total) %>%
    select(GEOID, fraction_high_school_edu)

## fraction_no_health_ins
# no type of insurance coverage
    # B27010_001: total
    # B27010_{017,033,050,066}: n
acs_ins <- get_acs(geography = 'tract',
                       variables = paste0('B27010_0',c(17, 33, 50, 66)),
                       summary_var = 'B27010_001',
                       endyear = 2015,
                       state = states_needed) %>%
    group_by(GEOID) %>%
    summarize(no_health_ins = sum(estimate),
              total = unique(summary_est)) %>%
    mutate(fraction_no_health_ins = no_health_ins / total) %>%
    select(GEOID, fraction_no_health_ins)

## fraction_assisted_income
# public assistance income or food Stamps/SNAP in the past 12 months for households
    # B19058_001: total
    # B19058_002: n
acs_assisted_income <- get_acs(geography = 'tract',
                               variables = 'B19058_002',
                               summary_var = 'B19058_001',
                               endyear = 2015,
                               state = states_needed) %>%
    group_by(GEOID) %>%
    mutate(fraction_assisted_income = estimate / summary_est) %>%
    select(GEOID, fraction_assisted_income)

## fraction_vacant_housing
# vacancy status:
    # B25002_001: total
    # B25002_003: n
acs_vacancy_status <- get_acs(geography = 'tract',
                              variables = 'B25002_003',
                              summary_var = 'B25002_001',
                              endyear = 2015,
                              state = states_needed) %>%
    group_by(GEOID) %>%
    mutate(fraction_vacant_housing = estimate / summary_est) %>%
    select(GEOID, fraction_vacant_housing)

## merge all acs variables in to data

d <- reduce(.x = list(acs_assisted_income, acs_edu, acs_income,
                      acs_ins, acs_poverty, acs_vacancy_status),
            .f = function(.x, .y) left_join(.x, .y, by='GEOID')) %>%
    rename(census_tract_fips = GEOID)

saveRDS(d, 'data_for_dep_index.rds')
