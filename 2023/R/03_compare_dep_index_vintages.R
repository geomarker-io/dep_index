library(tidyverse)

year <- c("2015", "2018", "2023")
dep_urls <- glue::glue("{year}/data/ACS_deprivation_index_by_census_tracts.rds")

dep_index <- purrr::map(dep_urls, \(x) readRDS(x) |> ungroup())

ggplot() +
  geom_density(
    data = dep_index[[1]],
    aes(
      x = dep_index,
      fill = "2015"
    ),
    alpha = 0.7
  ) +
  geom_density(
    data = dep_index[[2]],
    aes(x = dep_index, , fill = "2018"),
    alpha = 0.7
  ) +
  geom_density(
    data = dep_index[[3]],
    aes(x = dep_index, fill = "2023"),
    alpha = 0.7
  )

ggsave("2023/figs/dep_index_vintage_density.jpg")
