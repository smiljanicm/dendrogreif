#' List all sites in the database
#'
#' @param con connection to the PostGreSQL DendroGreif database server
#'
#' @details
#' If the con is NULL the function will try to initialize the connection to the dendrogreif database.
#'
#' @return A data.frame with complete 'sites' data table from the database
#' @export
#'
#' @examples
#' dg_con <- con_init()
#' list_sites(dg_con)
#'
list_sites <- function(con = NULL, ...) {
  if(is.null(con)) {
    con <- con_init(...)
  }
  sites_df <- tbl(con, "sites") %>% collect()
  return(sites_df)
}
