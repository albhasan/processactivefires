#!/usr/bin/env Rscript
##############################################################################
# PROCESS A FIRE FILE AND EXPORT ITS CONTENTS TO  A TXT FILE
#-----------------------------------------------------------------------------
# Example stand-alone:
# Rscript --vanilla processor.R --file /home/alber/Documents/inpe/people/guilherme/netcdf_to_txt/750/VNP14.A2015248.0048.002.2023145142000.nc --resolution 750 --out /home/alber/Downloads/ncdf2txt
#
# Example using GNU parallel:
# find /home/alber/Documents/inpe/people/guilherme/netcdf_to_txt/750 -type f -iname "*.nc" | parallel -j16 Rscript --vanilla ./processor.R --resolution 750 --out /home/alber/Downloads/ncdf2txt --file {}
##############################################################################



suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(processactivefires))



#---- Parse parameters ----

option_list <- list(
  optparse::make_option(
    opt_str = "--file",
    type = "character",
    metavar = "character",
    default = NULL,
    help = "Path to a CSV file containing paths to files."
  ),
  optparse::make_option(
    opt_str = "--resolution",
    type = "integer",
    metavar = "integer",
    default = NULL,
    help = "Spatial resolution of the given file. Either 375 or 750."
  ),
  optparse::make_option(
    opt_str = "--out",
    type = "character",
    metavar = "character",
    default = NULL,
    help = "Path to a directory for storing results."
  )
)

opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)

if (!("file" %in% names(opt))) {
  stop("Missing file option!")
}
file_in <- opt[["file"]]
if (!file.exists(file_in)) {
  stop("Input file not found!")
}

if (!("out" %in% names(opt))) {
  stop("Invalid output directory option!")
}
out_dir <- opt[["out"]]
if (!dir.exists(out_dir)) {
  stop("Output directory not found!")
}

if (!("resolution" %in% names(opt))) {
  stop("Unknown resolution!")
}
res <- opt[["resolution"]]
if (!(res %in% c(375, 750))) {
  stop("Invalid resolution! Valid values are either 375 or 750.")
}
var_names <- processactivefires:::VAR.NAMES.375
if (res == 750) {
  var_names <- processactivefires:::VAR.NAMES.750
}



#---- Process file ----

stopifnot("Only one file was expected!" = length(file_in) == 1)

data_df <-
  file_in |>
  processactivefires::get_file_metadata() |>
  dplyr::mutate(
    y = lubridate::year(adate),
    yday = lubridate::yday(adate)
  )

out_dir <- file.path(out_dir, data_df[["y"]], data_df[["yday"]])

if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

file_out <- file.path(
  out_dir,
  paste0(tools::file_path_sans_ext(basename(file_in)), ".txt")
)

if (file.exists(file_out)) {
  stop("Output file already exists!")
}

processactivefires::process_data(
  x = file_in,
  adate = data_df[["adate"]],
  file_out = file_out,
  var_names = var_names,
  fire_codes = processactivefires:::FIRE.CODES
)
