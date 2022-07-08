from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import numpy as np
import struct




filepath = "/home/rsa/TMP/TramaTemporal.tmp"

#Variables globales
valCH1 = 0
valCH2 = 0
valCH3 = 0

xData = [0 for i in range(4)]
yData = [0 for i in range(4)]
zData = [0 for i in range(4)]

#********************************************************************************
#Metodo para leer el archivo de texto y extraer los valores de los 3 ejes:
#********************************************************************************
def LeerArchivo():
    
    #variables globales
    global valCH1
    global valCH2
    global valCH3
    
    #print("imprimiendo...")
    
    # Abre el archivo para lectura de binarios "rb"
    objFile = open(filepath, "rb")
    #Lee el total de bytes del archivo
    tramaDatos = np.fromfile(objFile, np.int8, 2506)

    # Extrae los datos de aceleracion de los 3 ejes:
    for i in range(0, 3):
        xData[i] = tramaDatos[i + 1]
        yData[i] = tramaDatos[i + 4]
        zData[i] = tramaDatos[i + 7]
    
    #Calculo aceleracion eje x:
    xValue = ((xData[0]<<12)&0xFF000)+((xData[1]<<4)&0xFF0)+((xData[2]>>4)&0xF)
	 #Apply two complement
    if (xValue >= 0x80000):
        xValue = xValue & 0x7FFFF		 
        xValue = -1*(((~xValue)+1)& 0x7FFFF)
    
    valCH1 = xValue * (9.8/pow(2,18))
    
    #Calculo aceleracion eje y:
    yValue = ((yData[0]<<12)&0xFF000)+((yData[1]<<4)&0xFF0)+((yData[2]>>4)&0xF)
	 #Apply two complement
    if (yValue >= 0x80000):
        yValue = yValue & 0x7FFFF		 
        yValue = -1*(((~yValue)+1)& 0x7FFFF)
    
    valCH2 = yValue * (9.8/pow(2,18))
    
    #Calculo aceleracion eje z:
    zValue = ((zData[0]<<12)&0xFF000)+((zData[1]<<4)&0xFF0)+((zData[2]>>4)&0xF)
	 #Apply two complement
    if (zValue >= 0x80000):
        zValue = zValue & 0x7FFFF		 
        zValue = -1*(((~zValue)+1)& 0x7FFFF)
    
    valCH3 = zValue * (9.8/pow(2,18))
    
    print("%f   %f   %f" % (valCH1, valCH2, valCH3))

    # Al final cierra el archivo de lectura
    objFile.close()
#********************************************************************************

#********************************************************************************
#Clase para monitorizar cambios en los archivos:
#********************************************************************************
class MyEventHandler(FileSystemEventHandler):
    def on_modified(self, event):
        #print(event.src_path, "modificado.")
        LeerArchivo()
#********************************************************************************


#********************************************************************************
#Main
#********************************************************************************
observer = Observer()
observer.schedule(MyEventHandler(), filepath, recursive=False)
observer.start()

try:
    while observer.is_alive():
        observer.join(1)
        print("hola")
except KeyboardInterrupt:
    observer.stop()
observer.join()

#********************************************************************************