##### Precipitacion anual de la cuenca hidrografica del Santa 

# ASSET Earth Engine
cuen_santa <- ee$FeatureCollection('users/juniorantoniocalvomontanez/carpeta/Cuenca_Hidrografica')$
  filter(ee$Filter$eq('NOMB_UH_N4', 'Santa'))


# cargar datos de precipitacion (mm/dia)= 365 imagenes por año 
precipCollection <- ee$ImageCollection("UCSB-CHG/CHIRPS/DAILY")$
  select('precipitation')$
  filterDate('2019-01-01', '2019-12-31')

# reducir la image collection a una sola imagen sumando los 365 patrones diarios
annualPre <- precipCollection$reduce(ee$Reducer$sum())
#sintaxis equivalente

annualPre2 <- precipCollection$sum()$clip(cuen_santa)

# visualizar la precipitacion anual
viz <- list(min= 60, 
            max= 3000,
            palette=c("000000,0000FF,FDFF92,FF2700,FF00E7"))

Map$addLayer(annualPre2, viz, 'Precipitacion')

rain_ext <- ee_extract(annualPre2, cuen_santa, via='getInfo')
View(rain_ext)
