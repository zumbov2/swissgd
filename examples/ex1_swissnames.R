# Load Packages --------------------------------------------------------------
install.packages("devtools")
devtools::install_github("zumbov2/swissgd")

library(swissgd)
library(sf)
library(raster)
library(dplyr)
library(stringr)
library(purrr)
library(fasterize)
library(btb)
library(tidyr)
library(ggplot2)
library(hrbrthemes)

# Load Data ------------------------------------------------------------------

# Search dataset with place names
swissgd::search_geodata("Names")

# Download
download_geodata("ch.swisstopo.swissnames3d$")

# Unpack the zip folder inside the downloaded folder
unzip("ch.swisstopo.swissnames3d/swissNAMES3D_LV03.zip")

# Load the shapefile dataset and filter for places
ply <- sf::st_read("swissNAMES3D_LV03/shp_LV03_LN02/swissNAMES3D_PLY.shp")

places <- ply %>%
  filter(OBJEKTART == "Ort") %>%
  filter(STATUS == "offiziell")

# Place name endings ---------------------------------------------------------

# Get 2 to 7 letter place name endings
endings <- places %>%
  mutate(chars = nchar(NAME)) %>%
  mutate(
    ending2 = stringr::str_sub(NAME, chars-1, chars),
    ending3 = stringr::str_sub(NAME, chars-2, chars),
    ending4 = stringr::str_sub(NAME, chars-3, chars),
    ending5 = stringr::str_sub(NAME, chars-4, chars),
    ending6 = stringr::str_sub(NAME, chars-5, chars),
    ending7 = stringr::str_sub(NAME, chars-6, chars)
    ) %>%
  select(starts_with("ending")) %>%
  pivot_longer(starts_with("ending")) %>%
  group_by(name, value) %>%
  count() %>%
  ungroup() %>%
  arrange(desc(n))

# Select the most common ones manually
endings_selection <- c(
  "hof", "berg", "matt", "egg", "bach", "wil", "weid", "haus", "au", "moos",
  "holz", "acker", "acher", "boden", "tal", "bühl", "rüti", "hus", "hüsli", "büel",
  "feld", "wald", "schwand", "rain", "ried", "stein", "ikon", "halde", "loch", "graben",
  "halden", "mühle", "burg", "alp", "mont", "hubel"
  )

# Detect endings in place names...
endings_detection <- purrr::map_dfc(
  paste0(endings_selection, "$"),
  function(x) str_detect(tolower(places$NAME), x)
  )

# ...bind to dataset and reduce geoms to points
names(endings_detection) <- endings_selection
places <- bind_cols(places, endings_detection) %>%
  st_point_on_surface()

# Get national border as bounding --------------------------------------------

# Search
swissgd::search_geodata("boundaries")

# Download
swissgd::download_geodata("ch.swisstopo.swissboundaries3d-land-flaeche.fill")

# Readme says we find the data here
folder <- "swissboundaries3d.zip"
download.file(
  "https://data.geo.admin.ch/ch.swisstopo.swissboundaries3d-gemeinde-flaeche.fill/shp/2056/ch.swisstopo.swissboundaries3d-gemeinde-flaeche.fill.zip",
  folder
  )
unzip(folder, exdir = "swissboundaries3d")
file.remove(folder)

# Load data
ch <- sf::st_read("swissboundaries3d/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp")
ch <- ch %>% filter(NAME == "Schweiz")

# Transforming points pattern to continuous coverage -------------------------------------

# Strongly inspired by
# https://www.r-bloggers.com/2019/05/kernel-spatial-smoothing-transforming-points-pattern-to-continuous-coverage/
get_spatial_smooting <- function(ending, x, bounding, res, bw, crs = 2056) {

  cat(ending, "\n")

  # Bounding
  bx <- sf::st_bbox(bounding)

  # Make grid
  bounding_coords <- bounding %>%
    sf::st_make_grid(
      cellsize = res,
      offset = c(
        plyr::round_any(bx[1] - bw, res, floor),
        plyr::round_any(bx[2] - bw, res, floor)),
      what = "centers"
      ) %>%
    sf::st_sf() %>%
    sf::st_join(bounding, join = st_intersects, left = F) %>%
    sf::st_coordinates() %>%
    tibble::as_tibble() %>%
    dplyr::select(x = X, y = Y)

  # Compute Kernel
  kernel <- x %>%
    cbind(., st_coordinates(.)) %>%
    sf::st_set_geometry(NULL) %>%
    dplyr::select(x = X, y = Y, ending) %>%
    btb::kernelSmoothing(
      dfObservations = .,
      sEPSG = crs,
      iCellSize = res,
      iBandwidth = bw,
      vQuantiles = NULL,
      dfCentroids = bounding_coords
      )

  names(kernel)[3] <- "density"
  kernel$ending <- paste0("-", ending)

  return(kernel)

}

# Spatial Kernel Smooting for all endings
endings_kernels <- purrr::map_dfr(
  endings_selection,
  get_spatial_smooting,
  x = places,
  bounding = ch,
  res = 1000,
  bw = 20000
  )

# Visualize ----------------------------------------------------------------

# -hof
p1 <- endings_kernels %>%
  filter(ending == "-hof") %>%
  mutate(density = density / max(density)) %>%
  ggplot() +
  geom_sf(fill = "grey90", color = NA) +
  geom_sf(aes(fill = density, alpha = density), color = NA) +
  scale_fill_viridis_c(option = "magma", direction = -1, na.value = "white") +
  scale_alpha_continuous(range = c(0, 1)) +
  labs(
    title = "Distribution of the place name suffix -hof",
    subtitle = "Spatial kernel density estimation",
    caption = "Datasets: ch.swisstopo.swissnames3d, ch.swisstopo.swissboundaries3d
Method: btb::kernelSmoothing with a grid resolution of 1km and a bandwidth of 20km"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    axis.text = element_text(color = "white"),
    axis.ticks = element_line(color = "white"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

ggsave("ex1_1.png", p1, dpi = 500)

# -ikon
p2 <- endings_kernels %>%
  # filter(ending %in% c("-hof", "-matt", "-wil", "-ikon", "-berg", "-mont")) %>%
  # mutate(ending = factor(ending, levels = c("-hof", "-matt", "-wil", "-ikon", "-berg", "-mont"))) %>%
  filter(ending == "-ikon") %>%
  # mutate(ending = factor(ending, levels = c("-hof", "-matt", "-wil", "-ikon", "-berg", "-mont"))) %>%
  group_by(ending) %>%
  mutate(density = density / max(density)) %>%
  ungroup() %>%
  ggplot() +
  geom_sf(fill = "grey90", color = NA) +
  geom_sf(aes(fill = density, alpha = density), color = NA) +
  # facet_wrap(.~ending) +
  scale_fill_viridis_c(option = "magma", direction = -1, na.value = "white") +
  scale_alpha_continuous(range = c(0, 1)) +
  labs(
    title = "Distribution of the place name suffix -ikon",
    subtitle = "Spatial kernel density estimation",
    caption = "Datasets: ch.swisstopo.swissnames3d, ch.swisstopo.swissboundaries3d
Method: btb::kernelSmoothing with a grid resolution of 1km and a bandwidth of 20km"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    axis.text = element_text(color = "white"),
    axis.ticks = element_line(color = "white"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

ggsave("ex1_2.png", p2, dpi = 500)

# Suffix for mountain in german and french
p3 <- endings_kernels %>%
  filter(ending %in% c("-berg", "-mont")) %>%
  rename("Suffix" = "ending") %>%
  group_by(Suffix) %>%
  mutate(density = density / max(density)) %>%
  ungroup() %>%
  ggplot() +
  geom_sf(fill = "grey90", color = NA) +
  geom_sf(aes(fill = Suffix, alpha = density), color = NA) +
  scale_alpha_continuous(range = c(0, 1), guide = FALSE) +
  scale_fill_manual(values = c("#377eb8", "#4daf4a")) +
  labs(
    title = "Distribution of the place name suffixes -berg and -mont",
    subtitle = "Spatial kernel density estimation",
    caption = "Datasets: ch.swisstopo.swissnames3d, ch.swisstopo.swissboundaries3d
Method: btb::kernelSmoothing with a grid resolution of 1km and a bandwidth of 20km"
  ) +
  theme_ipsum_rc() +
  theme(
    legend.position = "right",
    legend.justification = c(0, 1),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    axis.text = element_text(color = "white"),
    axis.ticks = element_line(color = "white"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

ggsave("ex1_3.png", p3, dpi = 500)
