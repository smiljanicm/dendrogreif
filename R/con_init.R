#' Initialize DataBase connections
#'
#' @param creds a filepath to the credentials file
#' @param db_name name of the dendrogreif database
#' @param db_host a character string address of the dendrogreif database server
#' @param db_user user name registered on the dendrogreif database server
#' @param db_pass password of the db_user
#'
#' @details
#' If you have credentials file from the system admin you can use it to initialize the database connection. Otherwise parameters to access DendroGreif system must be named manually.
#'
#' @return An active db connection which needs to be used for other activities here.
#' @export
#'
#' @examples
#' dg_con <- con_init()
#'
con_init <- function(creds = "creds",
                     db_name = NULL,
                     db_host = NULL,
                     db_user = NULL,
                     db_pass = NULL) {
  if(is.null(creds)) {
    db_name <- ifelse(is.null(db_name),rstudioapi::askForPassword("Please enter your database name"))
    print(db_name)
  } else {
    cr <- readRenviron("creds")
    db_name <- Sys.getenv("db_name")
    db_host <- Sys.getenv("db_host")
    db_user <- Sys.getenv("db_user")
    db_pass <- Sys.getenv("db_pass")
  }
  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname=db_name,
                        host=db_host,
                        user = db_user,
                        password=db_pass)

  return(con)
}
