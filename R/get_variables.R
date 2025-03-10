#' Get all variables observed at the given locations for the further use
#'
#' @param ... arguments passed through to the list_variables, including active connection.
#'
#' @details
#' The function returns the vectorized variables_ids from the list_variables functions. Can be used to select entire dataset from the site(s).
#'
#' @return A vector with variable_ids
#' @export
#'
#' @examples
#' dg_con <- con_init()
#' sites <- list_sites(dg_con)
#' loc_ids <- get_locations(con=dg_con, site_ids = 6)
#' var_ids <- get_variables(con=dg_con, location_ids = loc_ids)
#' res <- get_data(dg_con, loc_ids, var_ids)
#'
get_variables <- function(...) {
  list_variables(...) %>%
    select(variable_id) %>%
    unlist() %>%
    return()
}
