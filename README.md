[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/swissgd)](https://cran.r-project.org/package=swissgd)
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-orange.svg)
[![Build Status](https://travis-ci.org/zumbov2/swissgd.svg?branch=master)](https://travis-ci.org/zumbov2/swissgd)

# swissgd
This R package is an interface to parts of the [Geo-Information Platform of the Swiss Confederation](https://www.geo.admin.ch/en/geo-services/geo-services/download-services.html) and **work-in-progress**. It provides functions to search and download geodata from [data.geo.admin.ch](https://data.geo.admin.ch/) and wraps around the [Spatial Temporal Asset Catalog (STAC) API](https://data.geo.admin.ch/api/stac/v0.9/).
 
The acquisition and use of data or services is free of charge, subject to the provisions on fair use. For more information, please see the [Terms of Use](https://www.geo.admin.ch/en/geo-services/geo-services/terms-of-use.html).

## Installation
Install from GitHub for a regularly updated version (latest: 0.1.0):

```r
install.packages("devtools")
devtools::install_github("zumbov2/swissgd")

```

# Functions

## `get_available_geodata`
Retrieves the names of all available datasets (currently 545) and returns the function (`download_geodata()` or `get_stac_assets()`) to obtain them.

``` r
swissgd::get_available_geodata()

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

## `search_geodata`
Searches for matches to argument `pattern` within the names of available datasets on the geo-information platform.

``` r
swissgd::search_geodata(pattern = "ÖV")

#> # A tibble: 6 x 2
#>   name                                     retrieval_function         
#>   <chr>                                    <chr>                      
#> 1 ch.are.erreichbarkeit-oev                swissgd::download_geodata()
#> 2 ch.are.gueteklassen_oev                  swissgd::download_geodata()
#> 3 ch.are.reisezeit-agglomerationen-oev     swissgd::download_geodata()
#> 4 ch.are.reisezeit-oev                     swissgd::download_geodata()
#> 5 ch.bav.haltestellen-oev                  swissgd::download_geodata()
#> 6 ch.bav.kataster-belasteter-standorte-oev swissgd::download_geodata()
```

``` r
swissgd::search_geodata("Alti")

#> # A tibble: 1 x 2
#>   name                     retrieval_function        
#>   <chr>                    <chr>                     
#> 1 ch.swisstopo.swissalti3d swissgd::get_stac_assets()
```

## `show_metadata` and `show_preview`
These functions can be used to visit the entry of a dataset in the [Swiss Geometadata Catalogue](https://www.geocat.admin.ch) and preview the data on [mapping platform of the Swiss Confederation](https://map.geo.admin.ch).
``` r
swissgd::show_metadata("ch.are.erreichbarkeit-oev")
swissgd::show_preview("ch.are.erreichbarkeit-oev")
```

## `download_geodata`
Downloads datasets available directly from the geo-information platform. Other data can be obtained via the STAC API. See the functions below.

``` r
swissgd::download_geodata("ch.swisstopo.swissboundaries3d-gemeinde-flaeche.fill")
```

## `get_stac_collections`
Displays a description of all data provided via the [Spatial Temporal Asset Catalog (STAC) REST Interface](https://data.geo.admin.ch/api/stac/v0.9/collections) on the geo-information platform (currently 10).

``` r
swissgd::get_stac_collections()

#> # A tibble: 10 x 11
#>    title id    description udated bbox1 bbox2 bbox3 bbox4 interval1 interval2
#>    <chr> <chr> <chr>       <chr>  <dbl> <dbl> <dbl> <dbl> <chr>     <chr>    
#>  1 swis~ ch.s~ swissALTI3~ 2021-~  5.95  45.7 10.5   47.8 2019-01-~ 2020-01-~
#>  2 swis~ ch.s~ swissTLM3D~ 2021-~  5.35  45.6 11.5   48.3 2020-03-~ 2020-03-~
#>  3 swis~ ch.s~ swissBUILD~ 2021-~  5.94  45.8 10.5   47.8 2018-07-~ 2020-10-~
#>  4 SWIS~ ch.s~ The orthop~ 2021-~  5.95  45.8 10.5   47.8 2017-01-~ 2020-01-~
#>  5 Nati~ ch.s~ The 1:10,0~ 2021-~  5.88  45.8 10.6   47.8 2020-01-~ 2020-01-~
#>  6 Nati~ ch.s~ The Nation~ 2021-~  5.87  45.7 10.9   47.9 2007-01-~ 2018-01-~
#>  7 Nati~ ch.s~ The Nation~ 2021-~  5.87  45.8 10.7   47.9 1984-01-~ 2018-01-~
#>  8 Nati~ ch.s~ The Nation~ 2021-~  5.85  45.7 11.4   47.9 2012-01-~ 2019-01-~
#>  9 Nati~ ch.s~ The Nation~ 2021-~  5.60  45.5 10.7   48.0 2019-01-~ 2019-01-~
#> 10 swis~ ch.s~ swissSURFA~ 2021-~  5.95  45.8  9.68  47.8 2015-01-~ 2020-01-~
#> # ... with 1 more variable: license <chr>
```

## `get_stac_assets`
Calls the STAC API on the geo-information platform and returns the download links to geo-specific assets. Here the aerial photo with a ground resolution of 10 cm of a part of my hometown Aarau is queried. WGS84, LV03 and LV95 coordinates are possible.

``` r
swissgd::get_stac_assets(
    collection_id = "ch.swisstopo.swissimage-dop10", 
    lon = 645685, 
    lat = 249287
    )

#> # A tibble: 2 x 7
#>   type      href      created  updated  `eo:gsd` `proj:epsg` `checksum:multihas~
#>   <chr>     <chr>     <chr>    <chr>       <dbl>       <int> <chr>              
#> 1 image/ti~ https://~ 2021-02~ 2021-02~      2          2056 122053DCAE0197F524~
#> 2 image/ti~ https://~ 2021-02~ 2021-02~      0.1        2056 12208825F4C065E9FA~
```

## `download_stac_assets`
Downloads assets from the STAC API that were previously queried with a `get_stac_assets()` call.

``` r
res <- swissgd::get_stac_assets(
  collection_id = "ch.swisstopo.swissimage-dop10",
  lon = 645685,
  lat = 249287
  )

swissgd::download_stac_assets(res)
```

# Examples

## Spatial distribution of place name suffixes
**Datasets:** ch.swisstopo.swissnames3d, ch.swisstopo.swissboundaries3d-land-flaeche.fill  
**Packages:** `sf`, `raster`, `btb`, `ggplot2` and friends

<img src="https://raw.githubusercontent.com/zumbov2/swissgd/main/examples/ex1_ikon.png" width="300">  
<img src="https://raw.githubusercontent.com/zumbov2/swissgd/main/examples/ex1_ikon.png" width="300">  



