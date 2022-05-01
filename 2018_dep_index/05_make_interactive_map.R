library(leaflet)
library(leafgl)
library(leaflet.extras)
library(sf)
options(viewer = NULL)

dep_index <-
  s3::s3_get("s3://geomarker/tract_dep_index_2018.rds") |>
  readRDS()

tracts <- tigris::tracts(year = 2019, cb = TRUE, progress_bar = FALSE)

d <-
  dplyr::left_join(tracts, dep_index, by = c("GEOID" = "census_tract_fips")) |>
  dplyr::select(dep_index) |>
  st_cast("POLYGON")

d$dep_index <- round(d$dep_index, digits = 2)
d <- na.omit(d)

national_map <- leaflet() |>
  addProviderTiles(provider = providers$CartoDB.Positron) |>
  addGlPolygons(
    data = d,
    fillColor = "dep_index",
    fillOpacity = 0.8, popup = c("dep_index"),
    src = TRUE
  ) |>
  setView(-93.65, 38.0285, zoom = 5) |>
  addScaleBar(
    position = "bottomright", options =
      scaleBarOptions(metric = TRUE)
  ) |>
  addFullscreenControl(position = "bottomleft") |>
  addResetMapButton() |>
  addControlGPS(
    options =
      gpsOptions(
        position = "topleft",
        activate = TRUE,
        autoCenter = TRUE,
        setView = TRUE
      )
  )

mapview::mapshot(national_map, "interactive_map_2018_dep_index.html")
