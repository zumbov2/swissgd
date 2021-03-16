#' Display all available datasets
#'
#' \code{get_available_geodata} displays all datasets available on the geo-information platform
#'     of the Swiss Confederation (\url{https://data.geo.admin.ch/}).
#'
#' @importFrom httr GET content
#' @importFrom rvest html_nodes html_text
#' @importFrom xml2 xml_attrs
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#' @importFrom dplyr mutate select group_by slice ungroup n lag
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_replace_all str_split str_detect
#' @importFrom magrittr "%>%"
#'
#' @param include_links if \code{TRUE}, links to available resources are included in the results.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @return A tibble with the names of the datasets and their retrieval function. The links
#'     to available resources are included if \code{include_links = TRUE}.
#'
#' @examples
#' # Display all available datasets
#' get_available_geodata()
#'
#' @export
#'
get_available_geodata <- function(include_links = FALSE) {

  # Content
  pg <- httr::GET("https://data.geo.admin.ch/")
  pgc <- httr::content(pg, encoding = "UTF-8")

  # Attributs
  .nodes <- rvest::html_nodes(pgc, "#data > a")
  .attrs <- purrr::map_chr(.nodes, xml2::xml_attrs)
  .names <- rvest::html_text(.nodes)

  # Results
  res1 <- tibble::tibble(
    name = .names,
    attr = .attrs
    ) %>%
    dplyr::mutate(
      name = stringr::str_replace_all(name, "\\s", "_"),
      id = 1:dplyr::n(),
      id = ifelse(!name == "download", dplyr::lag(id, 1), id),
      id = ifelse(!name == "download", dplyr::lag(id, 1), id),
      id = ifelse(!name == "download", dplyr::lag(id, 1), id),
      id = ifelse(!name == "download", dplyr::lag(id, 1), id)
      ) %>%
    tidyr::pivot_wider(names_from = name, values_from = attr) %>%
    dplyr::mutate(id = 1:dplyr::n())

  res2 <- res1 %>%
    dplyr::mutate(
      name = stringr::str_split(metadata, "="),
      download = ifelse(
        !stringr::str_detect(download, "https://"),
        paste("https://data.geo.admin.ch", download, "data.zip", sep = "/"),
        download
        )
      ) %>%
    dplyr::mutate(retrieval_function = ifelse(is.na(STAC_API), "swissgd::download_geodata()", "swissgd::get_stac_assets()")) %>%
    dplyr::select(id, name, retrieval_function, names(res1)[!names(res1) %in% c("name", "id")]) %>%
    tidyr::unnest(name) %>%
    dplyr::group_by(id) %>%
    dplyr::slice(2) %>%
    dplyr::ungroup() %>%
    dplyr::select(-id)

  # Links
  if (!include_links) res2 <- dplyr::select(res2, name, retrieval_function)

  # Return
  return(res2)

}
