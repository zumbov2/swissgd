#' View metadata
#'
#' \code{show_metadata} opens the entry of a dataset in the Swiss Geometadata
#'     Catalogue (\url{https://www.geocat.admin.ch}).
#'
#' @importFrom utils menu browseURL
#' @importFrom stringr str_replace_all
#'
#' @param dataset character string containing the name of an available dataset.
#'     Use \code{get_available_geodata()} to find the corresponding names.
#' @param available_geodata result of a previous call with \code{get_available_geodata}.
#'     Optional argument.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @examples
#' # Show metadata of the catalog of sports facilities of national importance
#' show_metadata("ch.baspo.nationales-sportanlagenkonzept")
#'
#' @export
#'
show_metadata <- function(dataset, available_geodata) {

  # Download available datasets
  if (missing(available_geodata)) available_geodata <- get_available_geodata(include_links = T)

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

  # End if none is to be displayed
  if (choice == nrow(res) + 1) return(invisible(res))

  # Visit geocat
  utils::browseURL(stringr::str_replace_all(res[["metadata"]][[choice]], "\\/ger\\/", "/eng/"))

  }
