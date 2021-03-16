#' Preview data
#'
#' \code{show_preview} opens the dataset on mapping platform of
#'     the Swiss Confederation (\url{https://map.geo.admin.ch}).
#'
#' @importFrom utils menu browseURL
#'
#' @param dataset character string containing the name of an available dataset.
#'     Use \code{get_available_geodata} to find the corresponding names.
#' @param available_geodata result of a previous call with \code{get_available_geodata}.
#'     Optional argument.
#'
#' @details The acquisition and use of data or services is free of charge,
#'     subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
#'
#' @examples
#' # Shows the preview of the travel time to 6 major centres by public transport
#' show_preview("ch.are.reisezeit-oev")
#'
#' @export
#'
show_preview <- function(dataset, available_geodata) {

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
      title = "The entered dataset name is ambiguous. Would you like to preview one of the following datasets?"
    )

  } else {

    choice <- 1

  }

  # End if none is to be displayed
  if (choice == nrow(res) + 1) return(invisible(res))

  # Visit geocat
  if (is.na(res[["preview"]][[choice]])) {
    message("No preview is available for the selected dataset.\n")
    return(invisible())
  }

  utils::browseURL(res[["preview"]][[choice]])

}
