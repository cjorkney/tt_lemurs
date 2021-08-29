library(readr)
library(rvest)
library(lubridate)
library(janitor)
library(dplyr)
library(ggplot2)


# Constants and links -----------------------------------------------------

lemur_data_url <- 'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-08-24/lemur_data.csv'

lemur_info_page <- "https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24/readme.md"

death_thresh_quantile <- 0.9 # Call it dead if its age is above the 90% quantile

today_date <- as_date("2021-08-29")
days_in_year <- 365.25


lemurs <- read_csv(lemur_data_url)

lemur_taxons <- read_html(lemur_info_page) %>%
  html_nodes("table") %>% 
  .[[1]] %>% 
  html_table() %>%
  clean_names()

lemurs <- left_join(lemurs, lemur_taxons, by = "taxon")

# New field to make it easier to filter out dead, if needed
lemurs$dead <- !is.na(lemurs$dod)

summary(lemurs$age_at_death_y)
quantile(lemurs$age_at_death_y, probs = 0.9, na.rm = TRUE)

age_death_thresh_quartile <- quantile(lemurs$age_at_death_y, probs = 0.9, na.rm = TRUE)

lemurs <- lemurs %>%
  mutate(
    years_since_birth = case_when(
      !dead ~ as.numeric(today_date - dob) / days_in_year,
      TRUE ~ NaN
    ),
    dead = if_else(!dead & (years_since_birth > age_death_thresh_quartile),
                   TRUE,
                   dead)
  )



