# Dixie-Fire-perimeter-interpolation
A script for testing out several methods of interpolating VIIRS and MODIS fire detection data to generate interpolated fire perimeters. The maps were developed for the following paper, currently under review: 

> Estabrook, Thomas, Jeremy S. Fried, Weimin Xi, Haibin Su, Jianwei Zhang. In review. "Predicting burn severity from forest stand structure and weather offers potential to map fire hazard mitigation." submitted to Ecosphere

## Maps: 
(30 meter cell size, cell values record the Julian interval, in hours, between 2021-01-01 00:00 GMT and fire detection)
- VIIRS_tin.tif - Smoothed TIN interpolation of VIIRS points done in QGIS. This was my earliest attempt and, while it has some obvious visual artefacts, it ended up performing best in the model.
- VIIRS_MODIS_idw_2km.tif - IDW interpolation of a layer made by combining VIIRS and MODIS detections. The 2 km window size came from Scaduto et al. 2020. This layer would need to be masked to the actual final Dixie perimeter.
- VIIRS_MODIS_win_375m.tif - each pixel is assigned the timestamp of the earliest fire detection within a 375-meter window.
- CI_raster.tif - this map uses the Courtney Intel IR hotspot kmz files found here. Each pixel with a value denotes its earliest appearance in a CI hotspot kmz. The FTP archive has substantially more data that could be leveraged in a similar way, but the CI hotspots seemed to have the most consistent timestamps and so required less data cleaning. 
- CI_raster_filled.tif - as above, but uses the IDW map to fill in NA values.


These were developed from the following remotely sensed datasets:
- [Combined detections from VIIRS and MODIS](https://www.earthdata.nasa.gov/learn/find-data/near-real-time/firms/active-fire-data) clipped to Dixie area, with low confidence pixels removed (from VIIRS, those marked as 'l', and from MODIS conf < 75). I also manually eliminated some obvious outliers. This is the layer I used for the IDW and window interpolations.
- Extracted 'heat' polygons (aerially detected infrared hotspots) from [the Courtney Intel folder in the NIFC FTP server](https://ftp.wildfire.gov/public/incident_specific_data/calif_n/!CALFIRE/2021_Incidents/CA-BTU-009205_Dixie/IR/CourtneyIntel/).

If you would like a copy of either layer, please reach out at my email: [tgestab@umich.edu](tgestab@umich.edu) or [thomas.estabrook@usda.gov](thomas.estabrook@usda.gov)

## Works cited:
NRT VIIRS 375 m Active Fire product VNP14IMGT distributed from NASA FIRMS. Available on-line https://earthdata.nasa.gov/firms. doi:10.5067/FIRMS/VIIRS/VNP14IMGT_NRT.002

Scaduto, Erica, Bin Chen, and Yufang Jin. "Satellite-based fire progression mapping: A comprehensive assessment for large fires in northern California." IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing 13 (2020): 5102-5114.
