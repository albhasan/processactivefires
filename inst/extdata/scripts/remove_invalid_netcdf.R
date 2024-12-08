#!/usr/bin/env Rscript
###############################################################################
# REMOVE THE GIVEN NETCDF FILE IF IT CANNOT BE OPEN
###############################################################################
library(ncdf4)

test_ncdf <- function(x) {
  nc <- ncdf4::nc_open(x, return_on_error = TRUE)
  if (nc[["error"]]) {
    rm(nc)
    gc()
    # file.remove(x)
    return()
  }
  ncdf4::nc_close(nc)
}

args <- commandArgs(trailingOnly = TRUE)
print(args)
print(length(args))
if (length(args) != 1) {
  stop("One parameter expected!")
}
x <- args[1]
test_ncdf(x)
