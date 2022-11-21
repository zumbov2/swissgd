#' Search available datasets for pattern matches
#'
#' \code{search_geodata} searches for matches to argument \code{pattern} within
#'     the names of all available datasets on the geo-information platform of
#'     the Swiss Confederation (\url{https://data.geo.admin.ch/}).
#'
#' @importFrom dplyr pull filter bind_rows distinct
#' @importFrom stringr str_replace_all str_detect
#' @importFrom magrittr "%>%"
#' @importFrom purrr map_lgl
#'
#' @param pattern character string containing a regular expression to be matched in
#'     the dataset names on the geo-information platform.
#' @param fuzzy_support if \code{TRUE}, approximate matches are included.
#' @param include_links if \code{TRUE}, the links to available resources are included
#'     in the results.
#' @param available_geodata result of a previous call with \code{get_available_geodata}.
#'     Optional argument.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @return A tibble with matching datasets and their retrieval function. The links
#'     to available resources are included if \code{include_links = TRUE}.
#'
#' @examples
#' # Show all available datasets for the search term 'Agglomerations'
#' search_geodata(pattern = "Agglomeration")
#'
#' # Show all available datasets of the Federal Office for the Environment (BAFU)
#' search_geodata(pattern = "BAFU")
#'
#' @export
#'
search_geodata <- function(pattern, fuzzy_support = FALSE, include_links = FALSE, available_geodata) {

  # Download available datasets
  if (missing(available_geodata)) available_geodata <- get_available_geodata(include_links = include_links)

  # Return all available datasets if no query is specified
  if (missing(pattern)) return(available_geodata)

  # Adjust Umlauts
  pattern <- pattern %>%
    tolower() %>%
    stringr::str_replace_all("\u00e4", "ae") %>%
    stringr::str_replace_all("\u00f6", "oe") %>%
    stringr::str_replace_all("\u00fc", "ue")

  # String matching
  res <- dplyr::filter(available_geodata, stringr::str_detect(name, pattern))

  # Fuzzy string matching
  if (fuzzy_support) {

    res2 <- dplyr::filter(available_geodata, purrr::map_lgl(name, function(x) agrepl(pattern, x)))
    res <- dplyr::bind_rows(res, res2) %>% dplyr::distinct()

  }

  # Return result
  return(res)

}
