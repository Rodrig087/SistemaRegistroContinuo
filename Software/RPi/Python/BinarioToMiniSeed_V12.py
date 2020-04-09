import numpy as np
import time

tramaSize = 2506
banGuardar = 0
contEje = 0
axisValue = 0

axisData = [0 for i in range(4)]
xData = [0 for i in range(4)]
yData = [0 for i in range(4)]
zData = [0 for i in range(4)]

xTrama = []                                                          #Vector para guardar los datos del eje X
yTrama = []                                                          #Vector para guardar los datos del eje Y
zTrama = []                                                          #Vector para guardar los datos del eje Z

f=open("/home/pi/TMP/tramafile.tmp", "rb")
tramaDatos = np.fromfile(f, np.int8, 2506)
f.close()

for i in range (0,2501):									         #Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
	if (i%10==0):						 	 				         #Indica el inicio de un nuevo set de muestras
		banGuardar = 1									 	         #Cambia el estado de la bandera para permitir guardar la muestra 
		j = 0
		contEje = 0
	else:
		if (banGuardar==1):
			if (j<2):
				axisData[j] = tramaDatos[i] 				         #axisData guarda la informacion de los 3 bytes correspondientes a un eje
			else:
				axisData[2] = tramaDatos[i] 				         #Termina de llenar el vector axisData
				axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF)

				#Aplica el complemento a 2:
				if (axisValue >= 0x80000) :
					axisValue = axisValue & 0x7FFFF		             #Se descarta el bit 20 que indica el signo (1=negativo)
					axisValue = -1*(((~axisValue)+1)& 0x7FFFF)
	
				#aceleracion = axisValue * (9.8/pow(2,18))           #Calcula la aceleracion en g (float) 
 
				if (contEje==0):
					xTrama.append(axisValue)	

				if (contEje==1):
					yTrama.append(axisValue)	

				if (contEje==2):
					zTrama.append(axisValue)						
					banGuardar = 0							         #Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar
	
				j = -1
				contEje = contEje+1
			j = j+1	


#************************************************************************************************************************************************************
#**Comprobacion**
xAceleracion = xTrama[249]	
yAceleracion = yTrama[249]
zAceleracion = zTrama[249]	

#Imprime la hora y fecha recuperada de la trama de datos
print("Datos de la trama:")
print("|%02d:%02d:%02d %02d/%02d/%02d|" % (tramaDatos[tramaSize-3], tramaDatos[tramaSize-2],  tramaDatos[tramaSize-1], tramaDatos[tramaSize-6], tramaDatos[tramaSize-5], tramaDatos[tramaSize-4]))		
#Imprime los datos de aceleracion:
print("|X: %d Y: %d Z: %d|" % (xAceleracion, yAceleracion, zAceleracion))
print("|X: %2.8f Y: %2.8f Z: %2.8f|" % ((xAceleracion*(9.8/pow(2,18))), (yAceleracion*(9.8/pow(2,18))), (zAceleracion*(9.8/pow(2,18)))))
#************************************************************************************************************************************************************


#**Observaciones:
#*Los vectores xTrama, yTrama y zTrama almacenan los datos de aceleracion de cada eje en formato entero con signo.
#*Los vecotores solo almacenan los 250 datos de aceleracion. No se icluyo el numero de cada muestra.
#*Para convertir cada dato a g, se utiliza esta funcion: aceleracion = xTrama[i] * (9.8/pow(2,18))
#*Si se necesita el dato de hora y fecha de cada trama, se puede obtener a partir de los ultimos 6 bytes del vector tramaDatos en el siguiente orden:
# dia = tramaDatos[tramaSize-6]
# mes = tramaDatos[tramaSize-5]
# anio = tramaDatos[tramaSize-4]
# hora = tramaDatos[tramaSize-3]
# minuto = tramaDatos[tramaSize-2]
# segundo = tramaDatos[tramaSize-1]