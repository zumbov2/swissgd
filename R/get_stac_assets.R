#' Call STAC API
#'
#' \code{get_stac_assets} calls the STAC API on the geo-information platform
#'     of the Swiss Confederation (\url{https://data.geo.admin.ch/api/stac/v0.9/})
#'     and returns download links to geo-specific assets.
#'
#' @importFrom sf st_as_sf st_transform st_bbox
#' @importFrom tibble tibble
#' @importFrom httr modify_url GET content
#' @importFrom dplyr bind_rows
#'
#' @param collection_id character string for selecting a dataset. Use
#'     \code{get_stac_collections} to obtain all available datasets.
#' @param lon longitude of a given point. WGS84, LV03 and LV95 coordinates are possible.
#' @param lat latitude of a given point. WGS84, LV03 and LV95 coordinates are possible.
#' @param api link to the latest query endpoint of the STAC API.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @return A tibble with a set of metadata for including download links for
#'     the requested asset (dataset and point).
#'
#' @examples
#' # Get link to the aerial photograph of the old town of Aarau (LV03 coordinates)
#' get_stac_assets(
#'     collection_id = "ch.swisstopo.swissimage-dop10",
#'     lon = 645685,
#'     lat = 249287
#'     )
#'
#' @export
#'
get_stac_assets <- function(collection_id, lon, lat, api = "https://data.geo.admin.ch/api/stac/v0.9/collections") {

  # CRS
  .crs <- dplyr::case_when(
    lat <= 90 ~ 4326,
    lat < 1000000 ~ 21781,
    TRUE ~ 2056
    )

  # Point
  point <- sf::st_as_sf(
    tibble::tibble(
      lon = lon,
      lat = lat
      ),
    coords = c('lon', 'lat'),
    crs = .crs
    )

  # Transformation
  if (!.crs == 4326) point <- sf::st_transform(point, crs = 4326)

  # Build URL
  url <- paste0(api, "/", collection_id, "/items")
  url <- httr::modify_url(
    url, query = list(
      bbox = paste0(sf::st_bbox(point), collapse = ",")
    )
  )

  # Call
  res <- httr::GET(url)
  cnt <- httr::content(res)

  # Extract Asset Links and return
  assets <- dplyr::bind_rows(cnt[["features"]][[1]][["assets"]])
  return(assets)

}
