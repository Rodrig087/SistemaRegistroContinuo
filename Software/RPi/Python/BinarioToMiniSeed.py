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

try:

	while(1):
		
		f=open("/home/pi/TMP/tramafile.tmp", "rb")
		tramaDatos = np.fromfile(f, np.int8, 2506)
		f.close()
		
		
		for i in range (0,2501):									 #Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
			if (i%10==0):						 	 				 #Indica el inicio de un nuevo set de muestras
				banGuardar = 1									 	 #Cambia el estado de la bandera para permitir guardar la muestra 
				j = 0
				contEje = 0
			} else {
				if (banGuardar==1){
					if (j<2){
						axisData[j] = tramaDatos[i] 				 #axisData guarda la informacion de los 3 bytes correspondientes a un eje
					} else {
						axisData[2] = tramaDatos[i] 				 #Termina de llenar el vector axisData
						axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF)
						
						#Aplica el complemento a 2:
						if (axisValue >= 0x80000) :
							axisValue = axisValue & 0x7FFFF		      #Se descarta el bit 20 que indica el signo (1=negativo)
							axisValue = -1*(((~axisValue)+1)& 0x7FFFF)
						
						aceleracion = axisValue * (9.8/pow(2,18))
						if (contEje==0){
							fprintf(fileX, "%2.8f\n", aceleracion)	
						}
						if (contEje==1){
							fprintf(fileY, "%2.8f\n", aceleracion)	
						}
						if (contEje==2){
							fprintf(fileZ, "%2.8f\n", aceleracion)						
							banGuardar = 0							 #Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar
						}	
						
						j = -1;
						contEje++;
					}
					j++;	
				}
			}
						
	    }



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
		#Imprime los datos de aceleracion:
		print("|X: %2.8f Y: %2.8f Z: %2.8f|" % (xAceleracion, yAceleracion, zAceleracion))
		
		time.sleep(1)

except KeyboardInterrupt:

	print ("\nCtrl-C presionado.  Saliendo del programa...")
