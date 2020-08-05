# A Nationwide Community Deprivation Index

Please see the main README for methodological details.  This document only contains output relevant to the update from the 2015 version of the index to the 2018 version.

## Import 2018 index directly into `R`

Use the following code to download the deprivation index dataframe directly into R:

```
dep_index <- 'https://github.com/geomarker-io/dep_index/raw/master/2018_dep_index/ACS_deprivation_index_by_census_tracts.rds' %>% 
    url() %>% 
    gzcon() %>% 
    readRDS() %>% 
    as_tibble()
```

## 2018 ZIP Code Deprivation Index

The deprivation index is also available by zip codes, denoted using the [ZIP Code Tabulation Area (ZCTA)](https://en.wikipedia.org/wiki/ZIP_Code_Tabulation_Area) boundaries. The value for each ZCTA is calculated as the mean of all of its intersecting census tracts. Download the 2018 file located at `2018_dep_index/ACS_deprivation_index_by_zipcode.csv` or use the above code to read it into R by replacing the RDS file name with `ACS_deprivation_index_by_zipcode.rds`.

## Updated PCA results for 2018 ACS data

#### Pairs plot of ACS estimates

![](2018_dep_index/figs/acs_data_pairs_plot.jpg)

#### PCA

![](2018_dep_index/figs/variance_of_acs_explained_by_dep_index.jpg)

![](2018_dep_index/figs/acs_measure_weights_on_dep_index.jpg)

#### Distribution of index

![](2018_dep_index/figs/dep_index_density.jpg)

#### Relationship between index and ACS measure

![](2018_dep_index/figs/dep_index_and_acs_measures_xyplots.jpg)
