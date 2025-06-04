# 2018 Deprivation Index

Please see the main [README](../README.md) for methodological details. 

## Getting the data

### Download the 2018 deprivation index CSV file

The data is contained in a CSV file called [ACS_deprivation_index_by_census_tracts.csv](https://github.com/geomarker-io/dep_index/raw/master/2018_dep_index/ACS_deprivation_index_by_census_tracts.csv) which is a table of census tracts listed by their FIPS ID and corresponding deprivation index.  Also included for each tract are the six individual ACS measures used to create the deprivation index.

### Import the 2018 deprivation index directly into `R`

Use the following code to download the deprivation index data.frame directly into R:

```
dep_index <- 'https://github.com/geomarker-io/dep_index/raw/master/2018_dep_index/ACS_deprivation_index_by_census_tracts.rds' %>% 
    url() %>% 
    gzcon() %>% 
    readRDS() %>% 
    as_tibble()
```

## 2018 ZIP code deprivation index

The deprivation index is also available by zip codes, denoted using the [ZIP Code Tabulation Area (ZCTA)](https://en.wikipedia.org/wiki/ZIP_Code_Tabulation_Area) boundaries. The value for each ZCTA is calculated as the mean of all of its intersecting census tracts. Download the 2018 file located at `2018/data/ACS_deprivation_index_by_zipcode.csv` or use the above code to read it into R by replacing the RDS file name with `ACS_deprivation_index_by_zipcode.rds`.

## Details on Creating the Index

The following census tract level variables were derived from the 2018 5-year American Community Survey:

- `fraction_poverty`: fraction of population with income in past 12 months below poverty level
- `median_income`: median household income in the past 12 months in 2015 inflation-adjusted dollars
- `fraction_high_school_edu`: fraction of population 25 and older with educational attainment of at least high school graduation (includes GED equivalency)
- `fraction_no_health_ins`: fraction of poulation with no health insurance coverage
- `fraction_assisted_income`: fraction of households receiving public assistance income or food stamps or SNAP in the past 12 months
- `fraction_vacant_housing`: fraction of houses that are vacant

## PCA results for 2018 ACS data

### Pairs plot of ACS estimates

![](2018/figs/acs_data_pairs_plot.jpg)

### PCA

![](2018/figs/variance_of_acs_explained_by_dep_index.jpg)

![](2018/figs/acs_measure_weights_on_dep_index.jpg)

### Distribution of index

![](2018/figs/dep_index_density.jpg)

### Relationship between index and ACS measure

![](2018/figs/dep_index_and_acs_measures_xyplots.jpg)
