#!/usr/bin/env Rscript
##############################################################################
# CHANGE THE DIRECTORY STRUCTURE FROM YYYY-MM-DD TO YYYY-YDOY
##############################################################################

library(dplyr)
library(lubridate)
library(purrr)
library(stringr)

in_dir <- "/home/alber/Documents/data/VNP14_txt_test"
out_dir <- "/home/alber/Downloads/VNP14_txt2"

stopifnot(dir.exists(in_dir))

data_df <-
  in_dir |>
  list.files(full.names = TRUE, recursive = TRUE) |>
  tibble::as_tibble() |>
  dplyr::rename(file_path = "value") |>
  dplyr::mutate(
    file_name = basename(file_path),
    d = lubridate::as_date(basename(dirname(file_path))),
    y = lubridate::year(d),
    doy = lubridate::yday(d)
  ) |>
  dplyr::mutate(
    new_path = file.path(
      out_dir,
      y,
      stringr::str_pad(string = doy, width = 3, pad = "0"),
      file_name
    )
  ) |>
  dplyr::mutate(
    new_dir = purrr::map2_chr(
      .x = file_path,
      .y = new_path,
      .f = function(current_path, new_path) {
        if (!dir.exists(dirname(new_path)))
          dir.create(dirname(new_path), recursive = TRUE)
        file.rename(from = current_path, to = new_path)
        return(new_path)
      }
    )
  )
