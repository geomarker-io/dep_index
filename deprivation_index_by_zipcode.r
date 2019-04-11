library(tidyverse)

ZCTA_data<- read.table("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt", header = TRUE,sep = ',',
                       colClasses = c('ZCTA5' = 'character' , 'GEOID' = 'character'))

#select the variables 
ZCTA_data<- ZCTA_data %>%
  dplyr::select(ZCTA5, STATE,GEOID) %>%
  filter (STATE %in% c(1:56)) # remove the islands

# Download deprivation index
dep_index <- 'https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds' %>% 
  url() %>% 
  gzcon() %>% 
  readRDS() %>% 
  as_tibble()

dep_index <- dep_index %>% 
  dplyr::select(dep_index,census_tract_fips)

dep_index$GEOID <- as.character(dep_index$census_tract_fips)

# combine two data 
d <- dplyr::left_join(ZCTA_data,dep_index, by= 'GEOID')

# remove missing deprivation index
d <- filter(d, !is.na(dep_index))

# Deprivation index by Zip code
d<- d %>%
  group_by(ZCTA5) %>%
  summarize(dep_index = mean(dep_index))


  



