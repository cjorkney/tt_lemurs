library(readr)
library(rvest)
library(janitor)
library(dplyr)
library(ggplot2)

lemur_data_url <- 'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-08-24/lemur_data.csv'

lemurs <- read_csv(lemur_data_url)

lemur_info_page <- "https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24/readme.md"

lemur_taxons <- read_html(lemur_info_page) %>%
  html_nodes("table") %>% 
  .[[1]] %>% 
  html_table() %>%
  clean_names()
  

lemurs <- left_join(lemurs, lemur_taxons, by = "taxon")
  
