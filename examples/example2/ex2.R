# Packages
library(swissgd)
library(sf)
library(ggplot2)
library(hrbrthemes)

# Search data on reachability
reach <- search_geodata("erreichbarkeit")
show_preview("ch.are.erreichbarkeit-oev")

# Download data on reachability by public transport
get_stac_assets("ch.are.erreichbarkeit-oev") %>% download_stac_assets()

# Check available layers
st_layers("erreichbarkeit-oev_2056.gpkg")

# Load high-res data
reisezeit <- st_read("erreichbarkeit-oev_2056.gpkg", layer = "Reisezeit_Erreichbarkeit")

# Plot
p1 <-
  reisezeit %>%
  ggplot(aes(fill = OeV_Erreichb_EWAP ^ (1/5))) +
  geom_sf(size = 0) +
  coord_sf(
    xlim = st_bbox(reisezeit)[c(1, 3)],
    ylim = st_bbox(reisezeit)[c(2, 4)],
    expand = FALSE
    ) +
  labs(
    title = "Erreichbarkeit mit dem öffentlichen Verkehr",
    subtitle = "Bundesamt für Raumentwicklung ARE",
    caption = "ch.are.erreichbarkeit-oev | swissgd"
    ) +
  scale_fill_viridis_c(option = "plasma") +
  theme_ipsum_rc() +
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank()
    )

ggsave(p1, filename = "ex2_map.png", dpi = 500, width = 9.6, height = 7.2)
