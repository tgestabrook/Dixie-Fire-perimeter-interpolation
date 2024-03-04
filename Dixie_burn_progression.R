library(terra)
library(tidyverse)
library(tidyterra)
#library(zipr)
library(stringr)

hoy <- function(date){
  (yday(date)-1)*24 + hour(date) + round(minute(date)/60, 0)
  #round(julian(date, origin = as_date('2021-01-01'))*24, 0)
}

hoy(ymd_hm('2021-01-01-05-01'))
hoy(ymd_hm('2021-01-01-05-51'))
hoy(ymd_hm('2021-01-01-05-01', tz = 'PDT'))

template_rast <- rast("E:\\TAMUK_Wildfire\\Data\\LEMMA\\2023_05_22_fried\\shapefile\\lp_rasterized.tif") # 30 meter pixel


############################################
### CI polygons

# Prior to loading shapefiles, I looped through the entire library of downloaded Courtney Intel kmz files, extracted the layers called 'Heat' and saved them as 
# shapefiles with the same filename as the kmz file. Unfortunately I accidentally deleted the exact lines of code I used.

#Load in shapefiles
sfs <- dir('E:\\Dixie\\Dixie_progression\\Daily_perimeters\\CourtneyIntel\\CI_KMZ\\SHP\\')
sfs <- sfs[grepl('.shp', sfs)]


CI_rast <- rast(ext(template_rast), resolution=res(template_rast), crs = crs(template_rast), vals = c(9999)) # initialize with 9999 so that min function works properly

for (sf in sfs){
  # calculate julian hour
  yyyy <- 2021
  mm <- substring(sf, 5, 6)
  dd <- substring(sf, 7, 8)
  hh <- substring(sf, 10, 11)
  mm2 <- substring(sf, 12, 13)
  
  if(mm2 == 'xi'){
    hh <- substring(sf, 16, 17)
    mm2 <- substring(sf, 18, 19)
  }
  
  print(sf)
  print(paste(yyyy, mm, dd, hh, mm2, sep = '-'))
  print(ymd_hm(paste(yyyy, mm, dd, hh, mm2, sep = '-'), tz = 'PDT'))
  date <- ymd_hm(paste(yyyy, mm, dd, hh, mm2, sep = '-'), tz = 'PDT')
  jh <- hoy(date)
  # dayfrac <- hour(date)/24 + minute(date)/(24*60)
  # ytd <- yday(date) + dayfrac
  
  # load sf
  if(!is.na(date)){
    heat <- vect(file.path('E:\\Dixie\\Dixie_progression\\Daily_perimeters\\CourtneyIntel\\CI_KMZ\\SHP\\', sf)) %>%
      project(crs(CI_rast)) %>%
      mutate(heatdate = jh)
    
    # bake into temp raster
    temp <- rasterize(heat, CI_rast, field = 'heatdate')
    # make new min raster
    CI_rast <- min(CI_rast, temp, na.rm = T)
  }
  
}
CI_rast[CI_rast == 9999] <- NA

plot(CI_rast)
writeRaster(CI_rast, 'E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\CI_raster.tif', overwrite = TRUE)

# patch raster with other method:
CI_rast <- rast('E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\CI_raster.tif')
fill_1 <- rast('E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\VIIRS_MODIS_idw_2km.tif') %>%
  project(CI_rast) %>% crop(CI_rast)

CI_rast[is.na(CI_rast)] <- fill_1
plot(CI_rast)

writeRaster(CI_rast, 'E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\CI_raster_filled.tif', overwrite = TRUE)
############################################
#### VIIRS-MODIS
vm_pts <- vect('E:/Dixie/Dixie_progression/VIIRS/VIIRS_and_MODIS_dixie_highest_confidence.shp') 

vm_time_info <- vm_pts %>% as.data.frame() %>% # terra (or tidyterra?) really doesn't like DateTime columns, so I had to cast to a dataframe
  mutate(acq_time2 = hm(paste0(as.character((acq_time - (acq_time %% 100))/100), ':', as.character(acq_time %% 100)))) %>%
  mutate(acq_date = as_date(acq_date)) %>%
  mutate(acq_datetime = acq_date + acq_time2) %>%
  mutate(day_frac = hour(acq_time2)/24 + minute(acq_time2)/(24*60)) %>%
  mutate(ytd = yday(acq_datetime) + day_frac) %>%
  mutate(epoch = as.numeric(acq_datetime)) %>%
  mutate(hoy = sapply(acq_datetime, hoy))  # convert to julian hour

vm_ytd <- vm_time_info %>%
  select(latitude, longitude, hoy) %>%
  vect(., geom = c('longitude', 'latitude'), crs = 'epsg:4326') %>%
  project(crs(template_rast))

template_rast <- template_rast %>%
  crop(ext(vm_ytd))

plot(template_rast)
plot(vm_ytd, add = T)

# IDW interpolation
vm_int <- interpIDW(template_rast, vm_ytd, field = 'hoy', radius=2000, power = 2, minPoints = 8)
plot(vm_int)
writeRaster(vm_int, 'E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\VIIRS_MODIS_idw_2km.tif', overwrite = T)

# Window interpolation
vm_int_win <- rasterizeWin(vm_ytd, template_rast, field = 'hoy', win = 'circle', pars = 375, fun = 'min')
plot(vm_int_win)
writeRaster(vm_int_win, 'E:\\Dixie\\Dixie_progression\\Rasters_to_compare\\VIIRS_MODIS_win_375m.tif', overwrite = T)


