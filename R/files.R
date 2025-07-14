#' Get metadata from file paths
#'
#' @description
#' Given a vector of file paths, return a data frame with the metadata in their
#' file names.
#'
#' @param x a character. Path to files.
#'
#' @return a data frame.
#'
#' @export
#'
get_file_metadata <- function(x) {
  adate <- file_path <- fname <- NULL
  res <-
    x |>
    dplyr::as_tibble() |>
    dplyr::rename(file_path = "value") |>
    dplyr::mutate(
      fname = tools::file_path_sans_ext(basename(file_path))
    ) |>
    tidyr::separate(
      col = fname,
      into = c("sensor", "adate", "atime", "X1", "X2"),
      sep = "[.]"
    ) |>
    tidyr::unite(
      col = "adate",
      tidyselect::all_of(c("adate", "atime")),
      sep = ""
    ) |>
    dplyr::mutate(
      adate = stringr::str_sub(adate, start = 2L),
      adate = lubridate::parse_date_time(adate, "%Y%j%H%M"),
    )
  return(res)
}
