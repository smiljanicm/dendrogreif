#' Get data from dendrogreif database based from location_id and variable_id
#'
#' @param con initialized connection
#' @param location_ids location_ids from list_locations()
#' @param variable_ids variable_ids from list_variables()
#' @param minutes range of the minutes to retrieve. Only relevant for the raw data series.
#' @param source source table of the data
#' @param start iso8601 timestamp of the data beginning
#' @param end iso8601 timestamp of the data end
#' @param toclean "clean", "raw" or "both" data
#'
#' @details
#' This is the main function of the package, which requests the data from the database system. Please take a look at the examples below for common usage. Minutes parameter is only relevant for the raw SapFlow series. Otherwise default value is fine.
#'
#' @return A data.frame with monitoring locations, labels, descriptions and available variables. Location_id and variable_id combinations can be used to get_data() from the database.
#' @export
#'
#' @examples
#' ## initialize database connection from credentials file.
#' conn <- con_init("creds")
#'
#' #list all sites in the database
#' list_sites(conn)
#'
#' demmin_locations <- list_locations(conn, 6)
#' demmin_locations %>% head(20) %>% knitr::kable()
#' #get single tree dendrometer
#' data_ind <- get_data(conn, location_ids = 67, variable_ids = 1)
#' print(head(data_ind))
#'
#' #get all dendrometer series from the single site
#' data_all_dend <- get_data(conn, location_ids = get_locations(conn, site_ids=6), variable_ids = 1)
#' print(head(data_all_dend))
#'
#' #get all series from the single site
#' data_all <- get_data(conn, location_ids = get_locations(conn, site_ids=6), variable_ids = 1:200)
#' print(head(data_all))
#'
get_data <- function(con = NULL, location_ids = NULL, variable_ids = NULL, minutes = 0:59, source = "obs_30", start = "2013-01-01", end = Sys.Date(), toclean = 'raw') {
    if(is.null(variable_ids)) {
      variable_id <- list_variables(con, location_ids) %>%
 #     variable_id <- all_variables %>% filter(as.numeric(variable_id)<103) %>%
        select(variable_id) %>% unlist()
    }

  clean_sensor <- function(data, clean_df = cdff, locID = 2, varID = 1, clsetID = 1) {
    #cleaning_set_id;location_id;variable_id;c
    clean_df <- clean_df %>%
      filter(cleaning_set_id == clsetID) %>%
      filter(location_id == locID) %>%
      filter(variable_id == varID) %>%
      select(correction, arguments)
    out <- data
    # print(clean_df)
    # print(out %>% head())
    out %>% head() %>% print()
    if(nrow(clean_df) > 0) {
      for(i in 1:nrow(clean_df)){
        corr <- clean_df[[i, "correction"]]
        args <- clean_df[[i, "arguments"]]

        args_list <- fromJSON(args)
        args_list <- c(list(data=out), args_list)
        out <- do.call(corr, args_list)
      }
    }
    return(out)
  }

    # print(paste0("variable: ",variable_ids))
    locs <- location_ids #%>%
      # map_dbl(function(x){
      #   string_vec <- unlist(strsplit(x,'_'))
      #   as.numeric(string_vec[[length(string_vec)]])}) #Line needs cleaning for now location_id must be last in the string
    # print("locations:")
    # print(locs)
#    locs <- na.omit(locs)
    #  vars <- variable_id %>% map_dbl(function(x) { as.numeric(x) })

    #  print(vars)
    #  print(class(vars))
    if(length(locs)==0) { return() }
    sql_query <- paste0("SELECT DISTINCT
                           o.timestamp as timestamp,
                           o.value,
                           p.label,
                           s.latin_name AS species,
                           l.description AS location_description,
                           l.height_above_ground as height,
                           v.description as variable,
                           v.variable_id,
                           l.location_id
                         FROM ", source, " as o
                         LEFT JOIN locations as l USING(location_id)
                         LEFT JOIN plates as p USING(plate_id)
                         LEFT JOIN variables as v USING(variable_id)
                         LEFT JOIN species as s USING(species_id)
                         WHERE location_id IN (", paste0(locs, collapse=','), ")
                           AND variable_id IN ( ", paste0(variable_ids, collapse=','), ")
                           AND EXTRACT(MINUTE FROM o.timestamp) IN (", paste0(minutes, collapse=','),") --change zero with minute resolutions
                           AND o.timestamp BETWEEN '", start, "'::timestamp AND '", end, "'::timestamp
                         ORDER BY o.timestamp")
    res <- DBI::dbGetQuery(con, sql_query)
    # print("res after sql: ")
    # print(res %>% head())
    vars <- res %>% distinct(variable_id) %>% unlist()
    # print("vars:")
    # print(vars)
#    res <- res %>% mutate(location_id = case_when(is.na(label) ~ paste0(variable_id, '_', description, '_', variable, '_', height, '_', location_id),
#                                                  TRUE ~ paste0(variable_id, '_', label, '_', variable, '_', height, '_', location_id))) %>%
#      select(timestamp, value, location_id)
    if(toclean != 'raw') {
      # print(toclean)
      # print(res %>% head())
      cdff <- tbl(con, 'cleaning_instructions') %>% collect()
      if(!is.null(res)) {
        # print(locs)
        # print(vars)
        comb <- locs %>% map(function(loc = locs, var = vars) { data.frame(loc, vars) }) %>%
          bind_rows() %>%
          t() %>%
          as.data.frame()
        # print("comb")
        # print(comb)
        #      res_clean <- res %>% distinct(location_id) %>% unlist() %>%
        res_clean <- comb %>% map(function(com) {
          # print("com:")
          # print(com)
          x <- com[[1]]
          v <- com[[2]]
          # print("x:")
          # print(x)
          # print("v:")
          # print(v)

          # t <- res %>% rename("TIMESTAMP" = timestamp) %>%
          #   rename("Sensor" = value) %>%
          #   #          filter(grepl(paste0('_',x), location_id)) %>%
          #   mutate(locs = location_id) %>%
          #   separate(locs, c("variable_id", "label", "variable", "height", "loc_id"), sep="_")
          # print(res %>% head())
          t <- res %>%
            rename("TIMESTAMP" = timestamp) %>%
            rename("Sensor" = value) %>%
            filter(location_id == x) %>%
            filter(variable_id == v) #%>%
#            select(TIMESTAMP, Sensor, location_id)
          # print(t %>% head())
          t <- t %>%
            clean_sensor(locID = x, varID = v, clean_df = cdff)
          # print(t %>% head())
          t
        }) %>% bind_rows() %>% rename("timestamp" = TIMESTAMP, "value" = Sensor) %>% arrange(timestamp)
        if(toclean == "clean") {
          res <- res_clean
        } else if(toclean == "both") {
          res <- res_clean %>% mutate(clean = '1.cleaned') %>%
            bind_rows(res %>% mutate(clean = '0.raw'))
        }
      }
    }

 #   res <- res %>%
#      rename(label = location_id,
#             time = timestamp)

    return(res)
}
