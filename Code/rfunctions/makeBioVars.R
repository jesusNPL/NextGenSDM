#library(raster)

#elev <- raster("Data/raster/Topography/US_elevation.tif")

#lst <- list.files("Data/raster/MOD11C3v6.0-CHIRPSv2.0_MONTHLY_03m/", pattern = "tif$")

#Prec <- lst[1:12]
#Tmax <- lst[13:24]
#Tmin <- lst[25:36]

#Prec <- stack(paste0("Data/raster/MOD11C3v6.0-CHIRPSv2.0_MONTHLY_03m/", Prec))

#Tmax <- stack(paste0("Data/raster/MOD11C3v6.0-CHIRPSv2.0_MONTHLY_03m/", Tmax))

#Tmin <- stack(paste0("Data/raster/MOD11C3v6.0-CHIRPSv2.0_MONTHLY_03m/", Tmin))

makeEOBios <- function(maxTemp, minTemp, Precip, elevation) { 
  
  if ( ! ("raster" %in% installed.packages())) { 
    install.packages("raster", dependencies = TRUE) 
  }
  
  if ( ! ("dismo" %in% installed.packages())) { 
    install.packages("dismo", dependencies = TRUE) 
  } 
  
  # EO bioclimatic variables
  if ( dir.exists("Data/raster/EOBioclim") == FALSE) { 
    dir.create("Data/raster/EOBioclim") 
  } 
  # EO maximum temperature
  if ( dir.exists("Data/raster/EOBioclim/EOmaxTemp") == FALSE) { 
    dir.create("Data/raster/EOBioclim/EOmaxTemp") 
  } 
  # EO minimum temperature
  if ( dir.exists("Data/raster/EOBioclim/EOminTemp") == FALSE) { 
    dir.create("Data/raster/EOBioclim/EOminTemp") 
  }
  # EO precipitation
  if ( dir.exists("Data/raster/EOBioclim/EOPrecip") == FALSE) { 
    dir.create("Data/raster/EOBioclim/EOPrecip") 
  }
  
  
  ## Crop to elevation extent
  maxTemp <- crop(maxTemp, extent(elevation)) 
  minTemp <- crop(minTemp, extent(elevation))
  Precip <- crop(Precip, extent(elevation)) 
  
  ## Names
  maxTempNames <- names(maxTemp)
  maxTempNames <- gsub("_03m", "_1km", maxTempNames)
  
  minTempNames <- names(minTemp)
  minTempNames <- gsub("_03m", "_1km", minTempNames)
  
  PrecipNames <- names(Precip)
  PrecipNames <- gsub("_03m", "_1km", PrecipNames)
  
  ## Spatial extent
  elev_res <- res(elevation) # (x, y) resolution of the panchromatic raster in CRS units (?)
  bios_res <- res(maxTemp) # (x, y) resolution of the lowers raster in CRS units (?)
  
  ## Rescale EO data to elevation
  maxTemp <- raster::disaggregate(maxTemp, 
                                  fact = round(bios_res[1]/elev_res[1]), 
                                  method = "bilinear")  
  
  ## Save raster files
  writeRaster(maxTemp, filename = "Data/raster/EOBioclim/EOmaxTemp/EO", 
              format = "GTiff", overwrite = TRUE, bylayer = TRUE, suffix = maxTempNames)
  
  print("maximum temperature Done!")
  
  minTemp <- raster::disaggregate(minTemp, 
                                  fact = round(bios_res[1]/elev_res[1]), 
                                  method = "bilinear") 
  
  ## Save raster files
  writeRaster(maxTemp, filename = "Data/raster/EOBioclim/EOminTemp/EO", 
              format = "GTiff", overwrite = TRUE, bylayer = TRUE, suffix = minTempNames)
  
  print("minimum temperature Done!")
  
  Precip <- raster::disaggregate(Precip, 
                                 fact = round(bios_res[1]/elev_res[1]), 
                                 method = "bilinear") 
  
  ## Save raster files
  writeRaster(maxTemp, filename = "Data/raster/EOBioclim/EOPrecip/EO", 
              format = "GTiff", overwrite = TRUE, bylayer = TRUE, suffix = PrecipNames) 
  
  print("precipitation Done!")
  
  ##### Build EO-bioclimatic variables using the downscaled monthly data #####
  
  EO_bios <- dismo::biovars(prec = Precip, 
                            tmin = minTemp, 
                            tmax = maxTemp) 
  ## Save EO-Biovars
  writeRaster(EO_bios, "Data/raster/EOBioclim/EO", 
              format = "GTiff", bylayer = TRUE, overwrite = TRUE, suffix = names(EO_bios)) 
  
  print("Earth-observation bioclimatic variables ... Done!!!")

}

#makeEOBios(maxTemp = Tmax, minTemp = Tmin, Precip = Prec, elevation = elev)
