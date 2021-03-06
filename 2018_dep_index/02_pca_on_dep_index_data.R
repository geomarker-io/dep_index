library(tidyverse)

d <- readRDS('./2018_dep_index/data_for_dep_index.rds') %>% as_tibble()

#### visualize data for dep index --------------------------------------
dir.create('./2018_dep_index/figs')

library(GGally)

d %>% ungroup() %>% select(-census_tract_fips) %>%
    ggpairs(lower = list(continuous = wrap('points', alpha=0.1)))
ggsave('./2018_dep_index/figs/acs_data_pairs_plot.jpg', width=12, height=12)
# CB::save_pdf('./2018_dep_index/figs/acs_data_pairs_plot.pdf', width=12, height=12, jpg=TRUE)


# # Hamilton county only
# d_hamilton <- d %>%
#     filter(substr(census_tract_fips, 1, 5) == '39061')
# d_hamilton %>%
#     ungroup() %>%
#     select(-census_tract_fips) %>%
#     ggpairs(lower = list(continuous = wrap('points', alpha=0.3)))
# save_pdf('figs/acs_data_pairs_plot_Hamilton_only.pdf', width=11, height=11, jpg=TRUE)

#### principal components analysis ----------------------------------------

# will be missing for 999 of 73,056 census tracts
d_pca <- d %>%
    na.omit() %>%
    ungroup() %>%
    select(-census_tract_fips) %>%
    prcomp(center=TRUE, scale=TRUE)

# table variance explained by component
summary(d_pca)$importance %>%
    as_tibble() %>%
    mutate(measure = row.names(summary(d_pca)$importance)) %>%
    slice(-1) %>%
    select(measure, everything()) %>%
    knitr::kable(digits=2) %>%
    cat(file='./2018_dep_index/figs/variance_of_acs_explained_by_dep_index.md', sep='\n')

# plot variance explained by component
summary(d_pca)$importance %>%
    as_tibble() %>%
    mutate(measure = row.names(summary(d_pca)$importance)) %>%
    gather(component, value, -measure) %>%
    filter(! measure == 'Standard deviation') %>%
    # filter(measure == 'Proportion of Variance') %>%
    ggplot(aes(component, value, alpha=measure)) +
    geom_bar(stat='identity', position=position_dodge(0)) +
    labs(title = 'Variance of ACS Measures Expained by Deprivation Indices') +
    theme(legend.title=element_blank()) +
    xlab('index') + ylab('variance')
ggsave('./2018_dep_index/figs/variance_of_acs_explained_by_dep_index.jpg', width=10, height=4)
# CB::save_pdf('./2018_dep_index/figs/variance_of_acs_explained_by_dep_index.pdf', width=10, height=4, jpg=TRUE)

# DO NOT inverse sign all weights so higher PC1 means more deprivation
dep_weights <- d_pca$rotation %>%
    as_tibble() %>%
    mutate(measure = row.names(d_pca$rotation)) %>%
    gather(component, weight, -measure)

# plot loading weights
dep_weights %>%
    ggplot(aes(measure, weight)) +
    geom_bar(stat='identity') +
    coord_flip() +
    facet_wrap(~ component) +
    labs(title='Weights of ACS Measure on Deprivation Indices') +
    xlab(' ')
ggsave('./2018_dep_index/figs/acs_measure_weights_on_dep_index.jpg', width=10, height=6)
# CB::save_pdf('./2018_dep_index/figs/acs_measure_weights_on_dep_index.pdf', width=10, height=6, jpg=TRUE)

# visualize transformed indices for the census tracts
d_pca$x %>%
    as_tibble() %>%
    ggpairs(lower = list(continuous = wrap('points', alpha=0.3)))
ggsave('./2018_dep_index/figs/PCs_pairs_plot.jpg', width=12, height=12)
# CB::save_pdf('./2018_dep_index/figs/PCs_pairs_plot.pdf', width=12, height=12, jpg=TRUE)

# take the first pc and norm to [0,1]
# DO NOT reverse magnitude so higher value means higher deprivation
dep_index <- d_pca$x %>%
    as_tibble() %>%
    select(dep_index = PC1) %>%
    mutate(dep_index = (dep_index - min(dep_index)) / diff(range(dep_index))) %>%
    mutate(census_tract_fips = d %>% na.omit() %>% pull(census_tract_fips))

# visualize univariate distribution of dep_index
dep_index %>%
    ggplot(aes(dep_index)) +
    geom_density(fill='lightgrey') +
    labs(title='Distribution of Deprivation Index for All US Census Tracts') +
    xlab('deprivation index')
ggsave('./2018_dep_index/figs/dep_index_density.jpg', width=10, height = 5)
# CB::save_pdf('./2018_dep_index/figs/dep_index_density.pdf', width=10, height = 5, jpg=TRUE)

# merge in and save
d <- left_join(d, dep_index, by='census_tract_fips')
saveRDS(d, './2018_dep_index/ACS_deprivation_index_by_census_tracts.rds')
rio::export(d, './2018_dep_index/ACS_deprivation_index_by_census_tracts.csv')

## save as shapefile
# states_needed <- tigris::fips_codes %>%
#     select(state_code, state_name) %>%
#     filter(! state_name %in% c('American Samoa', 'Guam', 'Northern Mariana Islands',
#                                'Puerto Rico', 'U.S. Minor Outlying Islands',
#                                'U.S. Virgin Islands')) %>%
#     unique() %>%
#     pull(state_code)
# 
# us_tracts <- map(states_needed, ~tigris::tracts(state = .x, year = 2018))
# 
# tracts_data <- left_join(us_tracts, d, by=c('GEOID' = 'census_tract_fips'))
# 
# st_write(tracts_data, '../dep_index_2018.shp')

# pairs plot including indices
d %>%
    ungroup() %>%
    select(-census_tract_fips) %>%
    gather(measure, value, -dep_index) %>%
    ggplot(aes(dep_index, value)) +
    geom_point(alpha=0.5) +
    facet_wrap(~ measure, scales='free') +
    labs(title = 'Relationship of Deprivation Index with ACS Measures') +
    xlab('deprivation index') + ylab('')
ggsave('./2018_dep_index/figs/dep_index_and_acs_measures_xyplots.jpg', width=12, height=7)
# CB::save_pdf('./2018_dep_index/figs/dep_index_and_acs_measures_xyplots.pdf', width=12, height=7, jpg=TRUE)

