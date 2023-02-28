# This script is adapted from the GitHub Repo:
# https://github.com/UBC-MDS/taxyvr
# by Hayley Boyce and Jordan Bourak in the UBC MDS Program

library(tidyverse)
library(readr)
library(ggmap)

munge_tax<- function(data_file){
   
  print("Loading data--------------------------", quote = FALSE)
  raw <- read_csv(data_file, show_col_types = FALSE)
  
  print("Cleaning up---------------------------", quote = FALSE)
  tax <- raw %>%
    mutate(
      FOLIO = as.numeric(FOLIO),
      LAND_COORDINATE = as.numeric(LAND_COORDINATE)
    ) %>%
    rename_all(tolower)
  
  # read in addresses
  print("Read vancouver addresses--------------", quote = FALSE)
  addresses <- get(load(file = "data-raw/addresses.rda"))
  
  # convert PCOORD to correct type
  coords <- addresses %>%
    mutate(PCOORD = as.numeric(PCOORD))
  
  # join with tax dataframe
  print("Joining dataframes--------------------", quote = FALSE)
  combo <- inner_join(tax, coords, by = c("land_coordinate" = "PCOORD"))
  
  # remove duplicates of folio that are created when joined with coord df
  print("Removing duplicates-------------------", quote = FALSE)
  ll_df <- combo %>%
    group_by(tax_assessment_year, folio) %>%
    slice(1) %>%
    ungroup()
  
  # obtain the latitude and longitude of the column
  print("Creating lat/long columns-------------", quote = FALSE)
  ll_df <- ll_df %>%
    mutate(Geom = str_replace_all(Geom, ".*\\[| |\\].*", "")) %>%
    separate(Geom, c("longitude", "latitude"), sep = ",") %>%
    mutate(longitude = as.numeric(longitude)) %>%
    mutate(latitude = as.numeric(latitude))
  
  # make a column for the full address to use geocoding on
  print("Creating full address column----------", quote = FALSE)
  ll_df$full_address <- paste(
    ll_df$to_civic_number,
    " ",
    ll_df$street_name,
    ", Vancouver, BC, ",
    ll_df$property_postal_code,
    sep = ""
  )
  
  # find the values that are missing coordinates
  print("Finding missing coordinates-----------", quote=FALSE)
  tax <- ll_df |>
    filter(!is.na(longitude))
  
}
