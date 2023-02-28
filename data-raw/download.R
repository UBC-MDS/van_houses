# This script is adapted from the GitHub Repo:
# https://github.com/UBC-MDS/taxyvr
# by Hayley Boyce and Jordan Bourak in the UBC MDS Program

library(readr)
source("data-raw/munge_tax.R")

download <- function(data_file) {
  print("Warning! This can take a while to download and tidy (~300Mb)")

  # Download the data from Vancouver Open Data Portal (this takes a long time)
  url <- "https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/property-tax-report/exports/csv?lang=en&timezone=America%2FLos_Angeles&use_labels=true&delimiter=%3B"
  house_data <- read_delim(url, delim = ";", show_col_types = FALSE)
  dir.create("data-raw")
  write_csv(house_data, "data-raw/van_house_data.csv")

  house_data <- munge_tax("data-raw/van_house_data.csv")

  save(house_data, file = "data-raw/house_data.rda", compress = "bzip2")

  # Attach the following line in the app.R to load the house_data variable
  # load(file='data-raw/house_data.rda')
  print("Finished downloading!")
}