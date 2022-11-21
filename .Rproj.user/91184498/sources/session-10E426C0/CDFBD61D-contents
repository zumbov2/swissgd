#' Display all available datasets
#'
#' \code{get_available_geodata} displays all datasets available on the geo-information platform
#'     of the Swiss Confederation (\url{https://data.geo.admin.ch/}).
#'
#' @importFrom httr GET content
#' @importFrom rvest html_nodes html_text html_attr
#' @importFrom tibble tibble
#' @importFrom dplyr mutate arrange rename select
#' @importFrom purrr map_chr
#' @importFrom stringr str_replace_all str_split str_detect
#' @importFrom tidyr fill complete pivot_wider
#' @importFrom magrittr "%>%"
#' @importFrom utils tail
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
  
  # Nodes
  .nodes <- rvest::html_nodes(pgc, "#data > a")
  
  # Step 1: Build data frame from content
  temp1 <- 
    tibble::tibble(
      type = rvest::html_text(.nodes),
      url = rvest::html_attr(.nodes, "href")
      ) %>% 
    dplyr::mutate(
      name = purrr::map_chr(url, function(x) stringr::str_split(x, "=") %>% unlist() %>% utils::tail(1)),
      name = ifelse(!type == "metadata", NA, name)
      ) %>%
    tidyr::fill(name, .direction = "up") %>% 
    tidyr::complete(name, type) %>% 
    dplyr::arrange(type) %>% 
    tidyr::pivot_wider(names_from = type, values_from = url) %>%
    
    # Manual correction swissTLMRegio (2022-11-21)
    dplyr::mutate(name = ifelse(name == "2a190233-498a-46c4-91ca-509a97d797a2", "swissTLMRegio", name)) %>% 
    dplyr::arrange(name) %>% 
    dplyr::rename("STAC_API" = "API")
  
  # Step 2: Add retrieval function
  temp2 <- 
    temp1 %>%
    dplyr::mutate(
      download = ifelse(
        !stringr::str_detect(download, "https://"),
        paste("https://data.geo.admin.ch", download, "data.zip", sep = "/"),
        download
        ),
      retrieval_function = ifelse(
        is.na(STAC_API),
        "swissgd::download_geodata()",
        "swissgd::get_stac_assets()"),
      .before = 2
      ) 

  # Links
  if (!include_links) temp2 <- dplyr::select(temp2, name, retrieval_function)

  # Return
  return(temp2)

}
