library(tidyverse)

ZCTA_data<- read.table("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt", header = TRUE,sep = ',',
                       colClasses = c('ZCTA5' = 'character' , 'GEOID' = 'character'))

#select the variables 
ZCTA_data<- ZCTA_data %>%
  dplyr::select(ZCTA5, STATE,GEOID) %>%
  filter (STATE %in% c(1:56)) # remove the islands

# Download deprivation index
dep_index <- 'https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds' %>% 
  url() %>% 
  gzcon() %>% 
  readRDS() %>% 
  as_tibble()

dep_index <- dep_index %>% 
  dplyr::select(dep_index,census_tract_fips)

dep_index$GEOID <- as.character(dep_index$census_tract_fips)

# combine two data 
d <- dplyr::left_join(ZCTA_data,dep_index, by= 'GEOID')

# remove missing deprivation index
d <- filter(d, !is.na(dep_index))

# Deprivation index by Zip code
d<- d %>%
  group_by(ZCTA5) %>%
  summarize(dep_index = mean(dep_index))


  




###############
#Newyork 
d<- data_combined %>%
  filter(STATE == 36) %>%
  dplyr :: select (ZCTA5,dep_index)
  #filter(dep_index != 'NA' )

# keep only those that could be geocoded
d <- filter(d, !is.na(dep_index))

write.csv(d, file= 'ZCTA_dep_together_newyork.csv')

##donor data
#NY<- read.csv('C:\\Users\\BHUD9C\\Desktop\\DATA_SHARAD\\New York\\Donors.csv')
NY<- read.csv('C:\\Users\\Nobel\\Desktop\\New_York.csv')
NY$STATE <- as.character(NY$STATE)
NY<- NY %>% 
  filter (STATE == 'NY') %>%
  dplyr::select(ZIP,SEX,DONOR)

NY <- NY %>%
  group_by(ZIP) %>%
  summarise(number_of_donor = sum(DONOR == 'Y'),
            total = n()) %>%
  mutate(organ_donor_rate = number_of_donor / total)

write.csv(NY, file= 'NewYork_donor.csv')

############### read new york donor data and combine with zcta and 
NY$ZIP <- as.character(NY$ZIP)
NY <- dplyr::left_join(NY,d, by= c("ZIP" = "ZCTA5"))




