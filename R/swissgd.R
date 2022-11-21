#' \code{swissgd} package
#'
#' Interface to the Geo-Information Platform of the Swiss Confederation
#'
#' See the README on
#' \href{https://github.com/zumbov2/swissgd#readme}{GitHub}
#'
#' @docType package
#' @name swissgd
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1") {

  utils::globalVariables(
    c(
      "name", "type", "metadata", "download", "STAC_API",
      "retrieval_function", "extent_spatial", "extent_temporal"
      )
  )

}
