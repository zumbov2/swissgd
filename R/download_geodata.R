#' Download datasets
#'
#' \code{download_geodata} downloads datasets from the geo-information platform of
#'     the Swiss Confederation (\url{https://data.geo.admin.ch/}).
#'
#' @importFrom utils browseURL download.file
#' @importFrom stringr str_replace_all
#' @importFrom purrr walk2
#'
#' @param dataset character string containing the name of an available dataset.
#'     Use \code{get_available_geodata} to find the corresponding names.
#' @param path the directory to download files to.
#' @param unzip if \code{TRUE}, the downloaded folder is unzipped and the zip folder is
#'    deleted.
#' @param available_geodata result of a previous call with \code{get_available_geodata}.
#'    Optional argument.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @examples
#' \dontrun{
#' # Show all available records for the search term Agglomerations
#' download_geodata("ch.are.reisezeit-oev")
#' }
#'
#' @export
#'
download_geodata <- function(dataset, path, unzip = TRUE, available_geodata) {

  # Download available datasets
  if (missing(available_geodata)) available_geodata <- get_available_geodata(include_links = T)
  if (missing(path)) path = "."

  # Search matching datasets
  res <- search_geodata(dataset, include_links = T, available_geodata = available_geodata)

  # Search, check and clarify
  res <- search_geodata(dataset, include_links = T, available_geodata = available_geodata)
  if (nrow(res) == 0) {
    message("No matching dataset found.\n")
    return(invisible())
  }
  if (nrow(res) > 1) {

    choice <- utils::menu(
      choices = c(res[["name"]], "No."),
      title = "The entered dataset name is ambiguous. Would you like to view the metadata of any of the following datasets?"
    )

  } else {

    choice <- 1

  }

  # Prep Data
  if (choice == nrow(res) + 2) return(invisible(res))
  if (choice == nrow(res) + 1) res <- res[is.na(res[["STAC_API"]]),]
  if (choice <= nrow(res)) res <- res[choice,]

  # 'Non-trivial' cases
  if (nrow(res) == 1 && !is.na(res[["STAC_API"]])) {

    message("Please download the data with via the STAC API (see get_stac_assets()) or via your browser.\nThe corresponding web page opens automatically in a few seconds.")
    Sys.sleep(3)
    utils::browseURL(stringr::str_replace_all(res[["download"]], "\\/de\\/", "/en/"))
    return(invisible(res))

  }

  # Download
  dl <- res[["download"]]
  p0 <- paste0(path, "/", res[["name"]])
  p1 <- paste0(p0, ".zip")

  purrr::walk2(dl, p1, utils::download.file)
  if (unzip) purrr::walk2(p1, p0, function(x, y) unzip(x, exdir = y))
  if (unzip) file.remove(p1)

  return(invisible(res))

}
