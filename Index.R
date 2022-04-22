#Paquetes a utilizar
library(sp)
library(cptcity)
library(rgee)
library(sf)
library(dplyr)
library(raster)


#Cargamos nuestro archivo vectorial
ar <- st_read('https://github.com/junior0428/TallerNEXUS-ProcesRGEE/blob/main/ZonaHuascaran.gpkg?raw=true')

plot(ar)

#Llevando a Earth Engine el archivo vectorial
ar_ee <- ar %>% st_geometry() %>% 
  sf_as_ee()

Map$centerObject(ar_ee, zoom = 11)
Map$addLayer(ar_ee)

#Coleccion de datos Sentinel 2
sen <- ee$ImageCollection('COPERNICUS/S2')$
  filterDate('2020-04-01', '2021-04-01')$
  filterBounds(ar_ee)$
  filterMetadata('CLOUDY_PIXEL_PERCENTAGE', 'less_than', 5)

ee_get_date_ic(sen)

#Imagen sentienl 2 de 2020
im_2sen20 <- ee$Image('COPERNICUS/S2/20200617T152651_20200617T152645_T18LTQ')$
  clip(ar_ee)

# Parametros de visualizacion
visParams <- list(min=450,
                max=3500,
                bands=c('B11', 'B8A', 'B2'),
                gamma=0.8)


Map$addLayer(im_2sen20, visParams)


#Calculo del indice de nieve NDSI

NDSI <- im_2sen20$normalizedDifference(c('B3', 'B11'))

#Definiendo la rampa de color
col<-colorRampPalette(c('blue', 'white'))

#Visualizacion del calculo del NDSI
Map$centerObject(NDSI)
Map$addLayer(eeObject =NDSI,  visParams = list(
  min = 0.2 ,
  max = 0.8 ,
  palette = col(2)
))

# Earth Engine a local
lo_ndsi <- ee_as_raster(image = NDSI, 
                        region = NDSI$geometry(), 
                        via = 'drive',
                        scale = 30)
ee_image_to_asset()
#Visualizacion en el local
plot(lo_ndsi, col= cptcity::cpt(pal = "mpl_viridis", n = 2))

#Exportacion a la carpeta
setwd('E:/Taller-NEXUS')
writeRaster(lo_ndsi, 'Huascaran.tif')
