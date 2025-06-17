library(tidyverse)
library(dpkg)
ggplot2::theme_set(theme_bw())

d <- dpkg::stow(
    "https://github.com/geomarker-io/hh_acs_measures/releases/download/hh_acs_measures-v1.3.0/hh_acs_measures-v1.3.0.parquet"
) |>
    dpkg::read_dpkg() |>
    filter(
        census_tract_vintage == "2020",
        year == "2023"
    ) |>
    select(
        census_tract_id_2020 = census_tract_id,
        fraction_poverty,
        fraction_snap,
        fraction_insured,
        median_income,
        fraction_hs,
        fraction_vacant
    )

#### visualize data for dep index --------------------------------------
library(GGally)

d |>
    ungroup() |>
    select(-census_tract_id_2020) |>
    ggpairs(lower = list(continuous = wrap('points', alpha = 0.1)))
ggsave('2023/figs/acs_data_pairs_plot.jpg', width = 12, height = 12)

# Hamilton county only
# d |>
#     filter(substr(census_tract_id_2020, 1, 5) == '39061') |>
#     ungroup() |>
#     select(-census_tract_id_2020) |>
#     ggpairs(lower = list(continuous = wrap('points', alpha=0.3)))
# save_pdf('2023/figs/acs_data_pairs_plot_Hamilton_only.pdf', width=11, height=11, jpg=TRUE)

#### principal components analysis ----------------------------------------

# will be missing for 2075 of 84,122 census tracts
d_pca <-
    d |>
    na.omit() |>
    ungroup() |>
    select(-census_tract_id_2020) |>
    prcomp(center = TRUE, scale = TRUE)

# table variance explained by component
summary(d_pca)$importance |>
    as_tibble() |>
    mutate(measure = row.names(summary(d_pca)$importance)) |>
    slice(-1) |>
    select(measure, everything()) |>
    knitr::kable(digits = 2) |>
    cat(
        file = '2023/figs/variance_of_acs_explained_by_dep_index.md',
        sep = '\n'
    )

# plot variance explained by component
summary(d_pca)$importance |>
    as_tibble() |>
    mutate(measure = row.names(summary(d_pca)$importance)) |>
    gather(component, value, -measure) |>
    filter(!measure == 'Standard deviation') |>
    # filter(measure == 'Proportion of Variance') |>
    ggplot(aes(component, value, alpha = measure)) +
    geom_bar(stat = 'identity', position = position_dodge(0)) +
    labs(title = 'Variance of ACS Measures Expained by Deprivation Indices') +
    theme(legend.title = element_blank()) +
    xlab('index') +
    ylab('variance')

ggsave(
    '2023/figs/variance_of_acs_explained_by_dep_index.jpg',
    width = 10,
    height = 4
)

# inverse sign all weights so higher PC1 means more deprivation
dep_weights <-
    d_pca$rotation |>
    as_tibble() |>
    mutate(measure = row.names(d_pca$rotation)) |>
    gather(component, weight, -measure) |>
    mutate(weight = -1 * weight)

# plot loading weights
dep_weights |>
    ggplot(aes(measure, weight)) +
    geom_bar(stat = 'identity') +
    coord_flip() +
    facet_wrap(~component) +
    labs(title = 'Weights of ACS Measure on Deprivation Indices') +
    xlab(' ')

ggsave(
    '2023/figs/acs_measure_weights_on_dep_index.jpg',
    width = 10,
    height = 6
)

# visualize transformed indices for the census tracts
d_pca$x |>
    as_tibble() |>
    ggpairs(lower = list(continuous = wrap('points', alpha = 0.3)))
ggsave('2023/figs/PCs_pairs_plot.jpg', width = 12, height = 12)

# take the first pc and norm to [0,1]
# reverse magnitude so higher value means higher deprivation
dep_index <-
    d_pca$x |>
    as_tibble() |>
    select(dep_index = PC1) |>
    mutate(dep_index = -1 * dep_index) |>
    mutate(dep_index = (dep_index - min(dep_index)) / diff(range(dep_index))) |>
    mutate(census_tract_id_2020 = d |> na.omit() |> pull(census_tract_id_2020))

# visualize univariate distribution of dep_index
dep_index |>
    ggplot(aes(dep_index)) +
    geom_density(fill = 'lightgrey') +
    labs(title = 'Distribution of Deprivation Index for All US Census Tracts') +
    xlab('deprivation index')
ggsave('2023/figs/dep_index_density.jpg', width = 10, height = 5)

# merge in and save
d <- left_join(d, dep_index, by = 'census_tract_id_2020')
saveRDS(d, '2023/data/ACS_deprivation_index_by_census_tracts.rds')
write_csv(d, '2023/data/ACS_deprivation_index_by_census_tracts.csv')

# pairs plot including indices
d |>
    ungroup() |>
    select(-census_tract_id_2020) |>
    gather(measure, value, -dep_index) |>
    ggplot(aes(dep_index, value)) +
    geom_point(alpha = 0.5) +
    facet_wrap(~measure, scales = 'free') +
    labs(title = 'Relationship of Deprivation Index with ACS Measures') +
    xlab('deprivation index') +
    ylab('')

ggsave(
    '2023/figs/dep_index_and_acs_measures_xyplots.jpg',
    width = 12,
    height = 7,
)
