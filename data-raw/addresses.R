# This script is adapted from the GitHub Repo:
# https://github.com/UBC-MDS/taxyvr
# by Hayley Boyce and Jordan Bourak in the UBC MDS Program

library(dplyr)
library(readr)

addresses <-
  read_csv2(
    "https://opendata.vancouver.ca/explore/dataset/property-addresses/download/?format=csv&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"
  )

save(addresses, file = "data-raw/addresses.rda", compress='bzip2')
