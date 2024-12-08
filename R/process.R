#' Process a file
#'
#' @description
#' Given a file with fire data, export its contents to a text file.
#'
#' @param x a character(1). Path to a NetCDF.
#' @param adate a date(1). Date of the given file.
#' @param file_out a character(1). Path to the resulting file.
#' @param var_names a character. Name of the variables to export in the given
#' file.
#' @param fire_codes an integer. Codes in the data that represent fire. For
#' example 7, 8, and 9 represent fire in VNP14 data.
#'
#' @return a character(1). The save path given for the output file.
#'
#' @export
#'
process_data <- function(x, adate, file_out, var_names, fire_codes = 7:9) {
  # Open the given file
  nc <- ncdf4::nc_open(x, return_on_error = TRUE)
  if (nc[["error"]]) {
    # ncdf4::nc_close(nc)
    rm(nc)
    gc()
    stop(sprintf("Unable to open %s", x))
  }
  # Read data
  data_ls <- lapply(var_names, function(x) {
    ncdf4::ncvar_get(nc, x)
  })
  names(data_ls) <- var_names
  # Check the out directory exists otherwise create it.
  if (!dir.exists(file_out)) {
    dir.create(dirname(file_out), showWarnings = FALSE, recursive = TRUE)
  }
  # Check longitude and latitude
  n_rows <- unique(sapply(data_ls[1:2], length))
  stopifnot("Length of lon & lat must match!" = length(n_rows) == 1)
  # Build a data frame
  data_df <- as.data.frame(data_ls[var_names[1:2]])
  # Check if the given file actually contains fires
  if (n_rows == 0) {
    return(sprintf("WARNING: No data found in %s", x))
  }
  # Get the fires
  for (v in var_names[3:length(var_names)]) {
    # Check for useful data in objects with more than one dimension
    if (length(dim(data_ls[[v]])) != 1) {
      if (sum(data_ls[[v]] %in% fire_codes) == n_rows) {
        data_ls[[v]] <- data_ls[[v]][data_ls[[v]] %in% 7:9]
      }
    }
    if (length(data_ls[[v]]) != n_rows) next
    data_df[v] <- data_ls[[v]]
  }
  # Format data with two digits for month, day, hour, and minute
  data_df["year"] <- as.integer(format(adate, "%Y"))
  data_df["month"] <- format(adate, "%m")
  data_df["day"] <- format(adate, "%d")
  data_df["hh"] <- format(adate, "%H")
  data_df["mm"] <- format(adate, "%M")
  # Reorder columns
  data_df <- data_df[, c("year", "month", "day", "hh", "mm", var_names)]
  # Export to TXT without column names or row names, using space as separator
  utils::write.table(
    x = data_df,
    file = file_out,
    row.names = FALSE,
    col.names = TRUE,
    sep = ",",
    quote = FALSE
  )
  ncdf4::nc_close(nc)
  rm(data_df, data_ls, nc, n_rows)
  gc()
  invisible(file_out)
}
