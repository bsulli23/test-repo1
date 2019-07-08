# packages to install
if(!require("readr"))install.packages("readr")
if(!require("dplyr"))install.packages("dplyr")
if(!require("ggplot2"))install.packages("ggplot2")
if(!require("mapdata"))install.packages("mapdata")
if(!require("leaflet"))install.packages("leaflet")
library("leaflet")
library("zipcode")
library("dplyr")
library("ggplot2")
library("mapdata")



# Load file // get NC data
# https://www.zillow.com/research/data/ (Rental values: ZRI Time Series: Multifamily ($))
multifam_rental_nc <- as_tibble(
                        fread("http://files.zillowstatic.com/research/public/Zip/Zip_MedianRentalPrice_AllHomes.csv", 
                              skip = 0)) %>% filter(State == "NC")

#multifam_rental_nc <- as_tibble(readr::read_csv(paste0(filepath,"/Zip_Zri_MultiFamilyResidenceRental.csv"), col_names = TRUE)) %>% filter(State == "NC")
    # the warning here is ok (parsing)


# Chose data from 01/2015 (arbitrary) 
mytext=paste( "<br/>", "Zillow national ranking: ", multifam_rental_nc$SizeRank, "<br/>", "Median rental value $: ", multifam_rental_nc$`2018-12`, sep="") %>%
  lapply(htmltools::HTML)


# Grab long/lat with zip (to join to "main" dataset)
data(zipcode)
zips <- zipcode %>% filter(state == "NC")
zips$zip <- as.integer(zips$zip)
multifam_rental_nc_3 <- inner_join(zips, multifam_rental_nc, by = c("zip" = "RegionName"))


# Display map
leaflet(multifam_rental_nc_3) %>% 
  addTiles()  %>% 
  setView( lat=35, lng=-79 , zoom=5) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addCircleMarkers(~longitude, ~latitude, 
                   label = mytext,
                   labelOptions = labelOptions( style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px", direction = "auto")) 