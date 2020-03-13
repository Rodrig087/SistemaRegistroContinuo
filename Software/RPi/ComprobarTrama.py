import numpy as np

tramaSize = 2506

#Declaracion de vectores:
xData = [0 for i in range(3)]
yData = [0 for i in range(3)]
zData = [0 for i in range(3)]

#Abre el archivo temporal que alberga la trama en formato binario:
f=open("/home/pi/TMP/tramafile.tmp", "rb")
tramaDatos = np.fromfile(f, np.int8, -1)
f.close()

for x in range(0, 3):
	xData[x] = tramaDatos[x+1]
	yData[x] = tramaDatos[x+4]	
	zData[x] = tramaDatos[x+7]

#Calculo aceleracion eje x:
xValue = ((xData[0]<<12)&0xFF000)+((xData[1]<<4)&0xFF0)+((xData[2]>>4)&0xF);
#Apply two complement
if (xValue >= 0x80000) :
	xValue = xValue & 0x7FFFF					#Se descarta el bit 20 que indica el signo (1=negativo)
	xValue = -1*(((~xValue)+1)& 0x7FFFF)
xAceleracion = xValue * (9.8/pow(2,18))

#Calculo aceleracion eje y:
yValue = ((yData[0]<<12)&0xFF000)+((yData[1]<<4)&0xFF0)+((yData[2]>>4)&0xF);
#Apply two complement
if (yValue >= 0x80000) :
	yValue = yValue & 0x7FFFF					#Se descarta el bit 20 que indica el signo (1=negativo)
	yValue = -1*(((~yValue)+1)& 0x7FFFF)
yAceleracion = yValue * (9.8/pow(2,18))

#Calculo aceleracion eje z:
zValue = ((zData[0]<<12)&0xFF000)+((zData[1]<<4)&0xFF0)+((zData[2]>>4)&0xF);
#Apply two complement
if (zValue >= 0x80000) :
	zValue = zValue & 0x7FFFF					#Se descarta el bit 20 que indica el signo (1=negativo)
	zValue = -1*(((~zValue)+1)& 0x7FFFF)
zAceleracion = zValue * (9.8/pow(2,18))

#Imprime la hora y fecha recuperada de la trama de datos
print("Datos de la trama:")
print("|%02d:%02d:%02d %02d/%02d/%02d|" % (tramaDatos[tramaSize-3], tramaDatos[tramaSize-2],  tramaDatos[tramaSize-1], tramaDatos[tramaSize-6], tramaDatos[tramaSize-5], tramaDatos[tramaSize-4]))
#Imprime los datos de 
print("|X: %2.8f Y: %2.8f Z: %2.8f|" % (xAceleracion, yAceleracion, zAceleracion))
