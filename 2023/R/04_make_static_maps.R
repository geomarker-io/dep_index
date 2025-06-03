library(tidyverse)

d <- readRDS("2023/data/ACS_deprivation_index_by_census_tracts.rds") |>
  mutate(
    dep_index_dec = cut(
      dep_index,
      breaks = seq(0, 1, 0.1),
      labels = c(
        "0.0 - 0.1",
        "0.1 - 0.2",
        "0.2 - 0.3",
        "0.3 - 0.4",
        "0.4 - 0.5",
        "0.5 - 0.6",
        "0.6 - 0.7",
        "0.7 - 0.8",
        "0.8 - 0.9",
        "0.9 - 1.0"
      )
    )
  )

tracts <- tigris::tracts(year = 2020, cb = TRUE) |>
  filter(
    !STATEFP %in%
      c(
        "02",
        "03",
        "15",
        "60",
        "64",
        "14",
        "66",
        "69",
        "43",
        "72",
        "74",
        "52",
        "78"
      )
  ) |>
  select(census_tract_id_2020 = GEOID) |>
  sf::st_transform(crs = 5072)

d_sf <- left_join(tracts, d, by = "census_tract_id_2020")

ggplot() +
  geom_sf(
    data = d_sf |> filter(!is.na(dep_index_dec)),
    aes(fill = dep_index_dec),
    lwd = 0
  ) +
  scale_fill_viridis_d(begin = 0, end = 1, na.value = "white") +
  ggthemes::theme_map() +
  ggspatial::annotation_scale(location = "bl", width_hint = 0.3) +
  labs(fill = "Deprivation Index") +
  theme(
    legend.position = "right"
  )

ggsave("2023/figs/dep_index_nationwide_map.jpg", width = 10, height = 7)
