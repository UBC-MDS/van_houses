library(dplyr)
library(readr)

addresses <-
  read_csv2(
    "https://opendata.vancouver.ca/explore/dataset/property-addresses/download/?format=csv&timezone=America/Los_Angeles&lang=en&use_labels_for_header=true&csv_separator=%3B"
  )


save(addresses, file = "data-raw/addresses.rda", compress='bzip2')
