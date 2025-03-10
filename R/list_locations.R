#' List all locations for the sites
#'
#' @param con an active connection to the DB initialized via con_init().
#' @param site_ids site_ids from list_sites()
#'
#' @return A tibble with monitoring locations, labels, descriptions and available variables. Location_id and variable_id combinations can be used to get_data() from the database.
#' @export
#'
#' @examples
#' dg_con <- con_init()
#' sites <- list_sites(dg_con)
#' locations <- list_locations(dg_con, c(2,4))

list_locations <- function(con = NULL, site_ids) {
  if(is.null(con)) {
    con <- con_init()
  }

  sql_query <-
    paste0(
    'SELECT
       sites.name as site,
       sites.site_id,
       locations.location_id,
       locations.description,
       plates.label,
       height_above_ground AS height
     FROM sites
     RIGHT JOIN locations
       USING(site_id)
     LEFT JOIN plates
       USING(plate_id)
     WHERE site_id IN (', paste0(site_ids, collapse = ','), ')')
  res <- DBI::dbGetQuery(con, sql_query)
  return(res)
}
