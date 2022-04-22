
#Instalacion de paquetes 
library(rgee)

#Inicializando la API de Google Earth Engine 
ee_Initialize(user = 'Junior')

#Usuarios autoidentificados con GEE
ee_users()
ee_user_info() #Saber donde estan guardados las credenciales

# Eliminar credenciales de usuarios de GEE
ee_clean_credentials(user = 'usename')

#Funcion de ayuda para los argumentos 
ee_help(ee$Kernel$gaussian)

#Imprimir en la consola   
ee_print()

#Lo que se envia al servidor
print(ee$Image(0), type = 'json')




