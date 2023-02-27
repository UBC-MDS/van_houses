library(readr)
source("data-raw/munge_tax.R")

# Uncomment the following to download the data from Vancouver Open Data Portal
# url <- "https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/property-tax-report/exports/csv?lang=en&timezone=America%2FLos_Angeles&use_labels=true&delimiter=%3B"
# house_data <- read_delim(url, delim = ";", show_col_types = FALSE)
# dir.create("data-raw")
# write_csv(house_data, "data-raw/van_house_data.csv")
tax_2023 <- munge_tax()

# write_csv(tax_2023, "data-raw/tax_2023.csv")
save(tax_2023, file = "data-raw/tax_2023.rda", compress = "bzip2")

