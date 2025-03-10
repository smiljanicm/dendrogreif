#' List all variables for the given locations
#'
#' @param location_ids location_ids from list_locations()
#'
#' @details
#' The function looks for the available variable_ids (for example Dendrometers, Temperature etc...) for the locations and returns the database table entry for them.
#'
#' @return A tibble with monitoring locations, labels, descriptions and available variables. Location_id and variable_id combinations can be used to get_data() from the database.
#' @export
#'
#' @examples
#' dg_con <- con_init()
#' sites <- list_sites(dg_con)
#' locations <- list_locations(dg_con, c(2,4))
#' variables <- list_variables(dg_con, c(2,5,6))

list_variables <- function(con = NULL, location_ids) {
  if(is.null(con)) {
    con <- con_init()
  }

  sql_query <-
    paste0(
      'SELECT *
       FROM variables
       WHERE variable_id IN
       (SELECT DISTINCT variable_id FROM obs_120 WHERE location_id IN (', paste0(location_ids, collapse = ','), '))')
  res <- DBI::dbGetQuery(con, sql_query)
  return(res)

}
