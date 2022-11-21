#' Display all data retrievable via the STAC API
#'
#' \code{get_stac_collections} displays a description of all data provided
#'     via the Spatial Temporal Asset Catalog (STAC) REST Interface on the
#'     geo-information platform of the Swiss Confederation
#'     (\url{https://data.geo.admin.ch/api/stac/v0.9/}).
#'
#' @importFrom httr GET content
#' @importFrom tibble tibble
#' @importFrom purrr map_chr map
#' @importFrom tidyr unnest_wider
#' @importFrom magrittr "%>%"
#'
#' @param api link to query endpoint listing all available datasets.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @return A tibble with a set of metadata (name, id, description, spatial and temporal extent)
#'     about all available geospatial datasets.
#'
#' @examples
#' # Show all available datasets of the STAC API
#' get_stac_collections()
#'
#' @export
#'
get_stac_collections <- function(api = "https://data.geo.admin.ch/api/stac/v0.9/collections") {

  # Fetch
  res <- httr::GET(api)
  cnt <- httr::content(res)

  # Extract
  dt <- tibble::tibble(
    title = purrr::map_chr(cnt[["collections"]], "title"),
    id = purrr::map_chr(cnt[["collections"]], "id"),
    description = purrr::map_chr(cnt[["collections"]], "description"),
    udated = purrr::map_chr(cnt[["collections"]], "updated"),
    extent_spatial = purrr::map(purrr::map(purrr::map(cnt[["collections"]], "extent"), "spatial"), unlist),
    extent_temporal = purrr::map(purrr::map(purrr::map(cnt[["collections"]], "extent"), "temporal"), unlist),
    license = purrr::map_chr(cnt[["collections"]], "license")
    ) %>%
    tidyr::unnest_wider(extent_spatial) %>%
    tidyr::unnest_wider(extent_temporal)

  return(dt)

}
