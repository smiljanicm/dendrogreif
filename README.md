
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dendrogreif

<!-- badges: start -->
<!-- badges: end -->

The goal of dendrogreif is to provide an R interface for downloading
data from DendroGreif network, containing 1000+ environmental (100+
Temperature and Relative Humidity) and 500+ tree physiological sensor
streams (350+ dendrometers). Currently the database is meant for the
internal use, but could be opened up to the public if there is enough
interest.

## Installation

You can install the development version of dendrogreif like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

You will need credentials file for the database access. Please contact
<marko.smiljanic@uni-greifswald.de> for the access rights.

## Example

Common workflow entails looking up the site id from the sites database,
getting either all or some locations from it and at the end getting the
relevant data series.

``` r
library(dendrogreif)

## initialize database connection from credentials file.
conn <- con_init("creds")

#list all sites in the database
list_sites(conn)
#> # A tibble: 27 × 6
#>    site_id name                     description       gps   parent_id short_name
#>      <int> <chr>                    <chr>             <pq_>     <int> <chr>     
#>  1       3 Eldena_managed           Protected since … (54.…        NA EMA       
#>  2       4 Eldena_Tilia             Landesforst expe… (54.…        NA ETI       
#>  3       5 Eldena_Alnus_Ulmus       Aldercarr         (54.…        NA EAU       
#>  4       6 Demmin                   FemoPhys crane s… (53.…        NA DEM       
#>  5       7 Ladebow                  Mixed pine oak b… (54.…        NA LAD       
#>  6       8 Friedrichsmoor_Oak_Beech HydroForMix site  (53.…        NA FOB       
#>  7       9 Friedrichsmoor_Oak       HydroForMix site  (53.…        NA FOA       
#>  8      10 Friedrichsmoor_Beech     HydroForMix site  (53.…        NA FBE       
#>  9      11 Bremerhagen_Oak_Carpinus HydroForMix site  (54.…        NA BOC       
#> 10      12 Bremerhagen_Oak          HydroForMix site  (54.…        NA BOA       
#> # ℹ 17 more rows

#list all locations for a single site
demmin_locations <- list_locations(conn, 6)
demmin_locations %>% head(20) %>% knitr::kable()
```

| site   | site_id | location_id | description       | label | height |
|:-------|--------:|------------:|:------------------|:------|-------:|
| Demmin |       6 |          47 | Dendrometer       | 20    |    1.5 |
| Demmin |       6 |          48 | Crown dendrometer | 20    |   22.0 |
| Demmin |       6 |          84 | Dendrometer       | 76    |    1.5 |
| Demmin |       6 |          49 | Crown dendrometer | 20    |   15.0 |
| Demmin |       6 |          50 | Dendrometer       | 4     |    1.5 |
| Demmin |       6 |          51 | Crown dendrometer | 4     |   22.0 |
| Demmin |       6 |          52 | Crown dendrometer | 4     |   15.0 |
| Demmin |       6 |          53 | Dendrometer       | 294   |    1.5 |
| Demmin |       6 |          54 | Crown dendrometer | 294   |   22.0 |
| Demmin |       6 |          55 | Crown dendrometer | 294   |   15.0 |
| Demmin |       6 |          56 | Dendrometer       | 332   |    1.5 |
| Demmin |       6 |          57 | Dendrometer       | 276   |    1.5 |
| Demmin |       6 |          58 | Dendrometer       | 261   |    1.5 |
| Demmin |       6 |          59 | Crown dendrometer | 261   |   22.0 |
| Demmin |       6 |          60 | Crown dendrometer | 261   |   15.0 |
| Demmin |       6 |          61 | Dendrometer       | 266   |    1.5 |
| Demmin |       6 |          62 | Dendrometer       | 257   |    1.5 |
| Demmin |       6 |          63 | Dendrometer       | 220   |    1.5 |
| Demmin |       6 |          66 | Dendrometer       | 191   |    1.5 |
| Demmin |       6 |          67 | Dendrometer       | 188   |    1.5 |

``` r
#get single tree dendrometer
data_ind <- get_data(conn, location_ids = 67, variable_ids = 1)
print(head(data_ind))
#>             timestamp    value label         species location_description
#> 1 2023-04-19 10:00:00 48.30000   188 Fagus sylvatica          Dendrometer
#> 2 2023-04-19 11:00:00 48.64000   188 Fagus sylvatica          Dendrometer
#> 3 2023-04-19 12:00:00 49.89000   188 Fagus sylvatica          Dendrometer
#> 4 2023-04-19 13:00:00 50.73000   188 Fagus sylvatica          Dendrometer
#> 5 2023-04-19 13:30:00 49.18748   188 Fagus sylvatica          Dendrometer
#> 6 2023-04-19 14:00:00 48.99783   188 Fagus sylvatica          Dendrometer
#>   height    variable variable_id location_id
#> 1    1.5 Dendrometer           1          67
#> 2    1.5 Dendrometer           1          67
#> 3    1.5 Dendrometer           1          67
#> 4    1.5 Dendrometer           1          67
#> 5    1.5 Dendrometer           1          67
#> 6    1.5 Dendrometer           1          67

#get all dendrometer series from the single site
data_all_dend <- get_data(conn, location_ids = get_locations(conn, site_ids=6), variable_ids = 1)
print(head(data_all_dend))
#>             timestamp value label         species location_description height
#> 1 2023-04-19 10:00:00 38.10   261   Quercus robur    Crown dendrometer   15.0
#> 2 2023-04-19 10:00:00 40.23   286     Picea abies          Dendrometer    1.5
#> 3 2023-04-19 10:00:00 42.08   261   Quercus robur    Crown dendrometer   22.0
#> 4 2023-04-19 10:00:00 43.25   251 Fagus sylvatica          Dendrometer    1.5
#> 5 2023-04-19 10:00:00 43.96   220   Quercus robur    Crown dendrometer   15.0
#> 6 2023-04-19 10:00:00 46.85   182 Fagus sylvatica          Dendrometer    1.5
#>      variable variable_id location_id
#> 1 Dendrometer           1          60
#> 2 Dendrometer           1          71
#> 3 Dendrometer           1          59
#> 4 Dendrometer           1          72
#> 5 Dendrometer           1          65
#> 6 Dendrometer           1          68

#get all series from the single site
loc_ids <- get_locations(con = conn, site_ids=6)
var_ids <- get_variables(con = conn , location_ids = loc_ids)
data_all <- get_data(conn, location_ids = loc_ids, variable_ids = var_ids)
print(head(data_all))
#>             timestamp      value label species location_description height
#> 1 2023-04-03 15:00:00  -93.01131  <NA>    <NA>          Temp/RH D01      2
#> 2 2023-04-03 15:00:00  -55.83445  <NA>    <NA>          Temp/RH D01      2
#> 3 2023-04-03 15:30:00 -107.29730  <NA>    <NA>          Temp/RH D01      2
#> 4 2023-04-03 15:30:00  -51.43214  <NA>    <NA>          Temp/RH D01      2
#> 5 2023-04-03 16:00:00 -104.46680  <NA>    <NA>          Temp/RH D01      2
#> 6 2023-04-03 16:00:00  -48.35669  <NA>    <NA>          Temp/RH D01      2
#>            variable variable_id location_id
#> 1       Temperature           2         254
#> 2 Relative Humidity           3         254
#> 3       Temperature           2         254
#> 4 Relative Humidity           3         254
#> 5       Temperature           2         254
#> 6 Relative Humidity           3         254
```
