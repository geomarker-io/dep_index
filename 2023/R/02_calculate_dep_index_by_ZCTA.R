library(tidyverse)

dep_index <- readRDS(gzcon(url(
  'https://github.com/geomarker-io/dep_index/raw/master/2023/data/ACS_deprivation_index_by_census_tracts.rds'
)))

ZCTA_tract_crosswalk <-
  read.table(
    "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_tract20_natl.txt",
    header = TRUE,
    sep = '|',
    colClasses = c(
      'GEOID_ZCTA5_20' = 'character',
      'GEOID_TRACT_20' = 'character'
    )
  ) |>
  select(
    zcta_2020 = GEOID_ZCTA5_20,
    census_tract_id_2020 = GEOID_TRACT_20
  )

dep_index_ZCTA <- left_join(
  dep_index,
  ZCTA_tract_crosswalk,
  by = "census_tract_id_2020"
)

# set ZCTA values as mean of all containing tract values
dep_index_ZCTA <-
  dep_index_ZCTA |>
  group_by(zcta_2020) |>
  summarize_if(is.numeric, mean, na.rm = TRUE) |>
  filter(zcta_2020 != "")

write_csv(
  dep_index_ZCTA,
  file = '2023/data/ACS_deprivation_index_by_zipcode.csv'
)
saveRDS(dep_index_ZCTA, "2023/data/ACS_deprivation_index_by_zipcode.rds")
