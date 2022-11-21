#' Download assets from STAC API
#'
#' \code{download_stac_assets} downloads assets from the STAC API on the
#'     geo-information platform of the Swiss Confederation
#'     (\url{https://data.geo.admin.ch/api/stac/v0.9/}).
#'
#' @importFrom stringr str_detect str_split
#' @importFrom purrr map map_int map2_chr walk2
#'
#' @param response response object of a \code{get_stac_assets} call to the
#'     STAC API.
#' @param path the directory to download files to.
#' @param type selects the type of file to download. If not specified, all assets are downloaded.
#'     Use \code{type = "image"} to download GeoTIFF only.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @examples
#' \dontrun{
#' # Download the aerial photograph of the old town of Aarau (LV03 coordinates)
#' call_res <- get_stac_assets(
#'     collection_id = "ch.swisstopo.swissimage-dop10",
#'     lon = 645685
#'     lat = 249287
#'     )
#'
#' download_stac_assets(call_res, type = "image")
#'
#' }
#'
#' @export
#'
download_stac_assets <- function(response, path, type) {

  if (missing(path)) path <- "."
  if (!missing(type)) response <- response[stringr::str_detect(response[["type"]], type),]
  if (nrow(response) == 0) {

    message("No asset of type ", type, " found.\n")
    return(invisible())

  }

  nms <- purrr::map(response[["href"]], function(x) unlist(stringr::str_split(x, "/")))
  nms_l <- purrr::map_int(nms, function(x) length(x))
  nms <- purrr::map2_chr(nms, nms_l, function(x, y) x[y])

  purrr::walk2(
    response[["href"]],
    paste0(path, "/", nms),
    download.file,
    mode = "wb"
  )

}
