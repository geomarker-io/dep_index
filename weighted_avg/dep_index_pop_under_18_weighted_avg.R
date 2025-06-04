suppressPackageStartupMessages(library(tidyverse))

year <- c("2015", "2018", "2023")
dep_urls <- glue::glue("{year}/data/ACS_deprivation_index_by_census_tracts.rds")
dep_index <- purrr::map(dep_urls, \(x) readRDS(x) |> ungroup())
names(dep_index) <- year
dep_index <- purrr::map(dep_index, \(x) rename(x, census_tract_id = 1))
dep_index <- purrr::map(dep_index, \(x) select(x, census_tract_id, dep_index))
dep_index <- bind_rows(dep_index, .id = "year")

n_children <- dpkg::stow(
  "https://github.com/geomarker-io/hh_acs_measures/releases/download/hh_acs_measures-v1.3.0/hh_acs_measures-v1.3.0.parquet"
) |>
  dpkg::read_dpkg() |>
  filter(
    census_tract_vintage == "2010" &
      year %in% c("2015", "2018") |
      census_tract_vintage == "2020" & year %in% c("2023")
  ) |>
  select(census_tract_id, year, n_children_lt18) |>
  mutate(year = as.character(year))

dep_index <-
  dep_index |>
  left_join(n_children, by = c("census_tract_id", "year")) |>
  na.omit() |>
  group_by(year) |>
  nest()

dep_index |>
  mutate(
    mean = purrr::map_dbl(
      data,
      \(d) weighted.mean(x = d$dep_index, w = d$n_children_lt18)
    ),
    variance = purrr::map_dbl(
      data,
      \(d) weighted.mean(x = (d$dep_index - mean)^2, w = d$n_children_lt18)
    ),
    sd = sqrt(variance),
    se = purrr::map_dbl(
      data,
      \(d) diagis::weighted_se(x = d$dep_index, w = d$n_children_lt18)
    ),
    wt_quantile = purrr::map(
      data,
      \(d)
        ggstats::weighted.quantile(
          x = d$dep_index,
          w = d$n_children_lt18,
          probs = c(0.25, 0.5, 0.75)
        )
    ),
    p25 = purrr::map_dbl(wt_quantile, \(q) q[1]),
    median = purrr::map_dbl(wt_quantile, \(q) q[2]),
    p75 = purrr::map_dbl(wt_quantile, \(q) q[3])
  ) |>
  select(year, mean, se, sd, p25, median, p75) |>
  mutate(across(where(is.numeric), \(x) round(x, 2))) |>
  knitr::kable() |>
  cat(file = "weighted_avg/table.md", append = FALSE)
