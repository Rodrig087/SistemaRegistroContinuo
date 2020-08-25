# -*- coding: utf-8 -*-
"""
Created on Wed Apr 22 21:33:17 2020

@author: milto
"""

from matplotlib.widgets import Cursor
import matplotlib.pyplot as plt
import numpy as np
import time

tramaSize = 2506
banGuardar = 0
banExtraer = 0
contEje = 0
axisValue = 0
contMuestras = 0

axisData = [0 for i in range(4)]
xData = [0 for i in range(4)]
yData = [0 for i in range(4)]
zData = [0 for i in range(4)]

xTrama = []                                                                    #Vector para guardar los datos del eje X
yTrama = []                                                                    #Vector para guardar los datos del eje Y
zTrama = []                                                                    #Vector para guardar los datos del eje Z

#Constantes:
offLong = 0
offTran = 0
offVert = 0

#Ingreso de datos:
nombreEstacion = input("Ingrese el nombre de la estacion: ")
nombreArchivo = input("Ingrese el nombre del archivo: ")
#factorDiezmado = int(input("Ingrese el factor de diezmado: "))
#horaEvento = int(input("Ingrese la hora del evento (hhmmss): "))
#fechaEvento = (input("Ingrese la fecha del evento (mmdd): "))
#duracionEvento = int(input("Ingrese la duracion (horas): "))
factorDiezmado = 25
duracionEvento = (24 * 3600)

#nombreEstacion = "SismosPaper"
#nombreArchivo = "202003260001"
#nombreArchivo = "2020" + fechaEvento + "0001"
#horaEvento = 114845
#duracionEvento = 60

#Abre el archivo binario:
path = nombreEstacion + "/" + str(nombreArchivo) + ".dat"
f=open(path, "rb")
tramaDatos = np.fromfile(f, np.int8, 2506)
horaInicio = str('%0.2d' % tramaDatos[tramaSize-3]) + ":" + str('%0.2d' % tramaDatos[tramaSize-2]) + ":" + str('%0.2d' % tramaDatos[tramaSize-1])
horaInicioSeg = (3600*tramaDatos[tramaSize-3]) + (60*tramaDatos[tramaSize-2]) + (tramaDatos[tramaSize-1])
fechaEvento = str(tramaDatos[tramaSize-4]) + "/" + str(tramaDatos[tramaSize-5]) + "/" + str(tramaDatos[tramaSize-6])

#Obtiene y calcula el tiempo de inicio del muestreo
tiempoInicio = int((tramaDatos[tramaSize-3]*3600)+(tramaDatos[tramaSize-2]*60)+(tramaDatos[tramaSize-1]))
#print (tiempoInicio)
print("Calculando...")
       
#Vector de muestras en milisegundos
x_ms = np.linspace(0, duracionEvento*1000, int(250/factorDiezmado)*duracionEvento)
banExtraer = 1

class Cursor(object):
    def __init__(self, ax):
        self.ax = ax
        #self.lx = ax.axhline(color='red', linewidth=1)  # the horiz line
        #self.ly = ax.axvline(color='red', linewidth=1)  # the vert line

        # text location in axes coords
        self.txt = ax.text(0.7, 0.9, '', transform=ax.transAxes)

    def mouse_move(self, event):
        if not event.inaxes:
            return

        xtime = (horaInicioSeg)+(event.xdata/1000)      #tiempo en segundos
        #xtime = (10000*int(xtime/3600)) + (100*int((xtime%3600)/60)) + ((xtime%3600)%60)  #Formato hhmmss
        xtime = "T = " + str('%0.2d' % (int(xtime/3600))) + ":" + str('%0.2d' % (int((xtime%3600)/60))) + ":" + str('%0.2d' %((xtime%3600)%60))  #Formato hhmmss
        
        x, y = xtime, event.ydata
        # update the line positions
        #self.lx.set_ydata(y)
        #self.ly.set_xdata(x)

        #self.txt.set_text('x=%d, y=%1.2f' % (x, y))
        #self.txt.set_text('x=%0.6d' % (x))
        self.txt.set_text(xtime)
        self.ax.figure.canvas.draw()
 
 
if (banExtraer==1):
    
    while (contMuestras<duracionEvento):
        
        try:
        
            tramaDatos = np.fromfile(f, np.int8, 2506)
            
            for i in range (0,2501):									               #Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
                if (i%(10*factorDiezmado)==0):						 	 			   #Indica el inicio de un nuevo set de muestras
                    banGuardar = 1									 	               #Cambia el estado de la bandera para permitir guardar la muestra 
                    j = 0
                    contEje = 0
                else:
                    if (banGuardar==1):
                        if (j<2):
                            axisData[j] = tramaDatos[i] 				               #axisData guarda la informacion de los 3 bytes correspondientes a un eje
                        else:
                            axisData[2] = tramaDatos[i] 				               #Termina de llenar el vector axisData
                            axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF)
            
                            #Aplica el complemento a 2:
                            if (axisValue >= 0x80000) :
                                axisValue = axisValue & 0x7FFFF		                   #Se descarta el bit 20 que indica el signo (1=negativo)
                                axisValue = -1*(((~axisValue)+1)& 0x7FFFF)
                
                            aceleracion = axisValue * (980/pow(2,18))                  #Calcula la aceleracion en gales (float) 
             
                            if (contEje==0):
                                xTrama.append(aceleracion-offTran)	
            
                            if (contEje==1):
                                yTrama.append(aceleracion-offLong)	
            
                            if (contEje==2):
                                zTrama.append(aceleracion-offVert)						
                                banGuardar = 0							               #Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar
                
                            j = -1
                            contEje = contEje+1
                        j = j+1	
            contMuestras = contMuestras+1
            
        except: 
            
            print("Advertencia: Archivo incompleto")
            x_ms = np.linspace(0, contMuestras*1000, int(250/factorDiezmado)*contMuestras)
            contMuestras = duracionEvento
            
            

    #plt.title('Aceleracion')

    fig = plt.figure()
    ax1 = fig.add_subplot(311)
    #ax1=plt.subplot(311)
    plt.plot(x_ms, yTrama)
    plt.setp(ax1.get_xticklabels(), visible=False)
    plt.title('Eje Longitudinal')
    plt.ylabel('Aceleracion [cm/seg2]')

    ax2=plt.subplot(312, sharex=ax1)
    plt.plot(x_ms, xTrama)
    plt.setp(ax2.get_xticklabels(), visible=False)
    plt.title('Eje Transversal')
    plt.ylabel('Aceleracion [cm/seg2]')

    ax3=plt.subplot(313, sharex=ax1)
    plt.plot(x_ms, zTrama)
    plt.title('Eje Vertical')
    infoTiempo = "Tiempo [ms]\n" "\n" + "Fecha: " + fechaEvento + "   Tiempo de inicio: " + horaInicio 
    plt.xlabel(infoTiempo)
    plt.ylabel('Aceleracion [cm/seg2]')
    
    # cursor1 = Cursor(ax1, useblit=True, color='red', linewidth=1)
    # cursor2 = Cursor(ax2, useblit=True, color='red', linewidth=1)
    # cursor3 = Cursor(ax3, useblit=True, color='red', linewidth=1)
    
    cursor1 = Cursor(ax1)
    cursor2 = Cursor(ax2)
    cursor3 = Cursor(ax3)

    fig.canvas.mpl_connect('motion_notify_event', cursor1.mouse_move)
    plt.show()


#Cierra el archivo binario:
f.close()
#************************************************************************************************************************************************************
#**Comprobacion**
#xAceleracion = xTrama[249]	
#yAceleracion = yTrama[249]
#zAceleracion = zTrama[249]	
#
##Imprime la hora y fecha recuperada de la trama de datos
#print("Datos de la trama:")
#print("|%02d:%02d:%02d %02d/%02d/%02d|" % (tramaDatos[tramaSize-3], tramaDatos[tramaSize-2],  tramaDatos[tramaSize-1], tramaDatos[tramaSize-6], tramaDatos[tramaSize-5], tramaDatos[tramaSize-4]))		
##Imprime los datos de aceleracion:
#print("|X: %d Y: %d Z: %d|" % (xAceleracion, yAceleracion, zAceleracion))
#print("|X: %2.8f Y: %2.8f Z: %2.8f|" % ((xAceleracion*(9.8/pow(2,18))), (yAceleracion*(9.8/pow(2,18))), (zAceleracion*(9.8/pow(2,18)))))
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

#Ejecutable W10: pyinstaller --onefile LocalizarEventos_V2.py
#Ejecutable con icono: pyinstaller --onefile --icon=./icono.ico LocalizarEventos_V2.py
