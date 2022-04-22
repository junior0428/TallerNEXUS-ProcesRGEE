################### COLECCIONES Y VISUALIZACIONES #########################
"conocimientos a adquirir: 
-Acceder a colleciones vectoriales y raster
-Filtrar colecciones
-Mostrar en consola el metadatos de las colecciones
-Reducers
-Agregar capas al mapa
-Opciones de visualizacion basica
" 
#................DATOS VECTORIALES..............................
# Accedemos a las areas administrativas de nivel 2  de la FAO 
MUN <- ee$FeatureCollection("FAO/GAUL_SIMPLIFIED_500m/2015/level2")

#Filtraciones de la coleccion de acuerdo al pais
PER <- MUN$filter(ee$Filter$eq("ADM0_NAME", "Peru"))

#Imprimimos en la consola los items de la coleccion
ee_print(PER)

#Agregamos al mapa los items de la coleccion 
Map$addLayer(PER, list(color = "blue"), "Municipios de Peru")

#Centramos el mapa
Map$centerObject(PER, 5)

#Volvemos a filtrar la coleccion de acuerdo a los nombres de los administrativos
YUN <- PER$filter(ee$Filter$eq("ADM2_NAME", 'Yungay'))

#Imprimimos en consola
print(YUN)
ee_print(YUN)

#Agregamos las visualizaciones
Map$addLayer(PER, list(color = "blue"), "Municipios de Peru")+
  Map$addLayer(YUN, list(color = "red"))

#....................DATOS RASTER..................................

S2 <- ee$ImageCollection("COPERNICUS/S2_SR") %>%
  ee$ImageCollection$filterBounds(YUN) %>% #Filtrado de acuerdo a los vectores
  ee$ImageCollection$filterDate("2020-01-01", "2021-01-01") %>%  #Filtrado por fechas
  ee$ImageCollection$filterMetadata("CLOUDY_PIXEL_PERCENTAGE", "less_than", 10) #Filtrado por metadatos

#Obtener el ID de una coleccion de imagen
ee_get_date_ic(S2)

#Reducimos la coleccion a una sola imagen utilizando la mediana
S2 <- S2$median()

#Agregamos al mapa una composicion RGB(432),VNIR(843), SWIR(11,8,4)
Map$addLayer(S2, list(min = 0, max = 5000, bands = c("B11", "B8", "B4")), 'S2')


################### PROCESAMIENTO RASTER #########################

"
-Crear geometrias 
-Matematicas de mapas
-convoluciones
-Opciones de visualizacion intermedias
"

#Creamos una geometria
pyun <- ee$Geometry$Point(c(-77.61696, -9.12515))

#Accedemos a la coleccion de sentinel 1 GRD
S1 <- ee$ImageCollection("COPERNICUS/S1_GRD") %>%
  ee$ImageCollection$filterBounds(pyun) %>% #Filtrado de acuerdo a los vectores
  ee$ImageCollection$filterDate("2020-01-01", "2021-01-01") %>%  #Filtrado por fechas
  ee$ImageCollection$filter("orbitProperties_pass ==  'DESCENDING'") %>% 
  ee$ImageCollection$filter("instrumentMode == 'IW'")#Filtrado por metadatos

#Obtener el ID de una coleccion de imagen
ee_get_date_ic(S1)

#Reducimos  la coleccion a la primera imagen
S1 <- S1$first()

#Calculamos el ratio VV/WW, lo renombramos y lo agregamos como nueva banda 
S1 <- S1$addBands(S1$select("VV")$divide(S1$select("VH"))$rename("RATIO"))

#Definimos opciones de visualizacion por cada banda 
viz <- list(
  min = c(-30, -30, 0.3),
  max = c(-5, -5, 0.8),
  bands = c("VV", "VH", "RATIO")
)

#Agregamos la imagen al mapa
Map$centerObject(S1)
Map$addLayer(S1, viz, 'S1 ("VV", "VH", "RATIO")')

#Reducimos el ruido con un filtro de mediana
S1_median <- S1$focalMedian()

#Agregamos la imagen al mapa
Map$addLayer(S1, viz, 'S1 ("VV", "VH", "RATIO")')+
  Map$addLayer(S1_median, viz, 'S1 ("VV", "VH", "RATIO") Median')

#Reducimos el ruido con un filtro gausiano
S1_gauss <- S1$convolve(ee$Kernel$gaussian(1.5))
Map$addLayer(S1, viz, 'S1 ("VV", "VH", "RATIO")')+
  Map$addLayer(S1_median, viz, 'S1 ("VV", "VH", "RATIO") Median filter')+
  Map$addLayer(S1_gauss, viz, 'S1 ("VV", "VH", "RATIO") Gaussian filter')