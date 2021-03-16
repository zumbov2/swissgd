[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/swissgd)](https://cran.r-project.org/package=swissgd)
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-orange.svg)
[![Build Status](https://travis-ci.org/zumbov2/swissgd.svg?branch=master)](https://travis-ci.org/zumbov2/swissgd)

# swissgd
This R package is an interface to parts of the [Geo-Information Platform of the Swiss Confederation](https://www.geo.admin.ch/en/geo-services/geo-services/download-services.html) and **work-in-progress**. It provides functions to search and download data from [data.geo.admin.ch](https://data.geo.admin.ch/) and wraps around the [Spatial Temporal Asset Catalog (STAC) API](https://data.geo.admin.ch/api/stac/v0.9/).
 
The acquisition and use of data or services is free of charge, subject to the provisions on fair use. For more information, please see the [Terms of Use](https://www.geo.admin.ch/en/geo-services/geo-services/terms-of-use.html).

## Installation
Install from GitHub for a regularly updated version (latest: 0.1.0):

```r
install.packages("devtools")
devtools::install_github("zumbov2/swissgd")

```

# Functions

## `get_available_geodata`
Retrieves the names of all available datasets (currently 545).

``` r
swissgd::get_available_geodata()
#> 
#> # A tibble: 545 x 2
#>    name                                     retrieval_function         
#>    <chr>                                    <chr>                      
#>  1 ch.are.agglomerationsverkehr             swissgd::download_geodata()
#>  2 ch.are.alpenkonvention                   swissgd::download_geodata()
#>  3 ch.are.belastung-personenverkehr-bahn    swissgd::download_geodata()
#>  4 ch.are.belastung-personenverkehr-strasse swissgd::download_geodata()
#>  5 ch.are.erreichbarkeit-miv                swissgd::download_geodata()
#>  6 ch.are.erreichbarkeit-oev                swissgd::download_geodata()
#>  7 ch.are.gemeindetypen                     swissgd::download_geodata()
#>  8 ch.are.gueteklassen_oev                  swissgd::download_geodata()
#>  9 ch.are.landschaftstypen                  swissgd::download_geodata()
#> 10 ch.are.reisezeit-agglomerationen-miv     swissgd::download_geodata()
#> # ... with 535 more rows
```
