# Dixie-Fire-perimeter-interpolation
A script for testing out several methods of interpolating VIIRS and MODIS fire detection data to generate interpolated fire perimeters. The maps were developed for the following paper, currently under review: 

> Estabrook, Thomas, Jeremy S. Fried, Weimin Xi, Haibin Su, Jianwei Zhang. In review. "Predicting burn severity from forest stand structure and weather offers potential to map fire hazard mitigation." submitted to Ecosphere

Maps - 30 meter cell size, and the unit for all of these is the Julian interval, in hours, between 2021-01-01 00:00 GMT and fire detection. They are listed here in order of how well they performed in the model Jeremy and I have been working on (that is, using them to match FIA plots with hourly max wind gust speed from RAWS stations, using the wind estimates in a logit model to predict burn severity, and comparing overall fit & p-value for the wind speed variable)
- VIIRS_tin.tif - Smoothed TIN interpolation of VIIRS points done in QGIS. This was my earliest attempt and, while it has some obvious visual artefacts, it ended up performing best in the model. I think this may be due to quirks in the burn detection <-> wind speed <-> remotely-sensed RdNBR relationships rather than an indication that this method is best. 
- VIIRS_MODIS_idw_2km.tif - IDW interpolation of a layer made by combining VIIRS and MODIS detections. The 2 km window size came from Scaduto et al. 2020. This layer would need to be masked to the actual final Dixie perimeter.
- VIIRS_MODIS_win_375m.tif - each pixel is assigned the timestamp of the earliest fire detection within a 375-meter window.
- CI_raster.tif - this map uses the Courtney Intel IR hotspot kmz files found here. Each pixel with a value denotes its earliest appearance in a CI hotspot kmz. The FTP archive has substantially more data that could be leveraged in a similar way, but the CI hotspots seemed to have the most consistent timestamps and so required less data cleaning. 
- CI_raster_filled.tif - as above, but uses the IDW map to fill in NA values.


These were developed from the following remotely sensed datasets:
- [Combined detections from VIIRS and MODIS](https://www.earthdata.nasa.gov/learn/find-data/near-real-time/firms/active-fire-data) clipped to Dixie area, with low confidence pixels removed (from VIIRS, those marked as 'l', and from MODIS conf < 75). I also manually eliminated some obvious outliers. This is the layer I used for the IDW and window interpolations.
- Extracted 'heat' polygons (aerially detected infrared hotspots) from [the Courtney Intel folder in the NIFC FTP server](https://ftp.wildfire.gov/public/incident_specific_data/calif_n/!CALFIRE/2021_Incidents/CA-BTU-009205_Dixie/IR/CourtneyIntel/).

If you would like a copy of either layer, please reach out at my email: [tgestab@umich.edu](tgestab@umich.edu) or [thomas.estabrook@usda.gov](thomas.estabrook@usda.gov)
