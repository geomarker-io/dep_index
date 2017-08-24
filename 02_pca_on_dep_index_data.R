library(tidyverse)

d <- readRDS('data_for_dep_index.rds') %>% as_tibble()


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
    knitr::kable(digits=2)

# plot variance explained by component
summary(d_pca)$importance %>%
    as_tibble() %>%
    mutate(measure = row.names(summary(d_pca)$importance)) %>%
    gather(component, value, -measure) %>%
    filter(! measure == 'Standard deviation') %>%
    # filter(measure == 'Proportion of Variance') %>%
    ggplot(aes(component, value, alpha=measure)) +
    geom_bar(stat='identity', position=position_dodge(0)) +
    labs(title = 'Variance of ACS Measures Expained by Deprivation Indices',
         subtitle = 'PC1 explains over 70% of the variation in the 5 ACS measures') +
    theme(legend.title=element_blank()) +
    xlab('index') + ylab('variance')

# inverse sign all weights so higher PC1 means more deprivation
dep_weights <- d_pca$rotation %>%
    as_tibble() %>%
    mutate(measure = row.names(d_pca$rotation)) %>%
    gather(component, weight, -measure) %>%
    mutate(weight = -1 * weight)

# plot loading weights
dep_weights %>%
    ggplot(aes(measure, weight)) +
    geom_bar(stat='identity') +
    coord_flip() +
    facet_wrap(~ component) +
    labs(title='Weights of ACS Measure on Deprivation Indices') +
    xlab(' ')

# visualize transformed indices for the census tracts
d_pca$x %>%
    as_tibble() %>%
    ggpairs(lower = list(continuous = wrap('points', alpha=0.3)))


# take the first pc and norm to [0,1]
# reverse magnitude so higher value means higher deprivation
dep_index <- d_pca$x %>%
    as_tibble() %>%
    select(dep_index = PC1) %>%
    mutate(dep_index = -1 * dep_index) %>%
    mutate(dep_index = (dep_index - min(dep_index)) / diff(range(dep_index))) %>%
    mutate(census_tract_fips = d %>% na.omit() %>% pull(census_tract_fips))

# visualize univariate distribution of dep_index
dep_index %>%
    ggplot(aes(dep_index)) +
    geom_density(fill='lightgrey') +
    labs(title='Distribution of Deprivation Index for All US Census Tracts') +
    xlab('deprivation index')


# merge in and save
d <- left_join(d, dep_index, by='census_tract_fips')
saveRDS(d, 'ACS_deprivation_index_by_census_tracts.csv')

