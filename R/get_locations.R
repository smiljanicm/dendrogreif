#' Get all locations from the site in the vector for further use
#'
#' @param ... arguments passed through to the list_locations, including active connection.
#'
#' @details
#' The function returns the vectr of the list location_ids. Can be used to select entire dataset from the site(s).
#'
#' @return A vector with monitoring location_ids
#' @export
#'
#' @examples
#' dg_con <- con_init()
#' sites <- list_sites(dg_con)
#' res <- get_data(dg_con, get_locations(con=dg_con, site_ids = 6), 1)
#'
get_locations <- function(...) {
  list_locations(...) %>%
    select(location_id) %>%
    unlist() %>%
    return()
}
