% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_stac_assets.R
\name{get_stac_assets}
\alias{get_stac_assets}
\title{Call STAC API}
\usage{
get_stac_assets(
  collection_id,
  lon = 660158,
  lat = 183641,
  api = "https://data.geo.admin.ch/api/stac/v0.9/collections"
)
}
\arguments{
\item{collection_id}{character string for selecting a dataset. Use
\code{get_stac_collections} to obtain all available datasets.}

\item{lon}{longitude of a given point. WGS84, LV03 and LV95 coordinates are possible.
Default value refers to the geographical center of Switzerland.}

\item{lat}{latitude of a given point. WGS84, LV03 and LV95 coordinates are possible.
Default value refers to the geographical center of Switzerland.}

\item{api}{link to the latest query endpoint of the STAC API.}
}
\value{
A tibble with a set of metadata for including download links for
    the requested asset (dataset and point).
}
\description{
\code{get_stac_assets} calls the STAC API on the geo-information platform
    of the Swiss Confederation (\url{https://data.geo.admin.ch/api/stac/v0.9/})
    and returns download links to geo-specific assets.
}
\details{
The acquisition and use of data or services is free of charge,
    subject to the provisions on fair use (see \url{https://www.geo.admin.ch/terms-of-use}).
}
\examples{
# Get link to the aerial photograph of the old town of Aarau (LV03 coordinates)
get_stac_assets(
    collection_id = "ch.swisstopo.swissimage-dop10",
    lon = 645685,
    lat = 249287
    )

}
