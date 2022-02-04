# -*- coding: utf-8 -*-
"""
Created on Wed Apr 22 21:33:17 2020

@author: milto
"""

from matplotlib.widgets import Cursor
import matplotlib.pyplot as plt
import numpy as np
import time
import os
import errno

#****************************************************************
# Datos de configuracion:
carpetaBin = "EventosBin"  #Carpeta de entrada que almacena los archivos binarios a convertir
carpetaTxt = "EventosTxt"  #Carpeta de salida que almacena los archivos de texto convertidos
modoGrafico = 0  #Estilo de graficos: 0 = modo analisis, 1 = modo paper
tipoEstacion = 0  #Tipo de estacion que se analizara: 0 = Acelerografos Presas, 1 = Nodos Centro Sur
#****************************************************************
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

xTrama = []  #Vector para guardar los datos del eje X
yTrama = []  #Vector para guardar los datos del eje Y
zTrama = []  #Vector para guardar los datos del eje Z

numPisoChar = []
numNodoChar = []

#Ingreso de datos:
nombreArchivo = input("Ingrese el nombre del archivo: ")
#modoGrafico = int(input("Escoja el tipo de grafico (0=Normal, 1=Paper): "))
factorDiezmado = 1
segundosDia = (24 * 3600)

#Verifica el tipo de estacion:
if (tipoEstacion == 1):
    #Extrae el numero del piso y del nodo a partir del nombre del archivo:
    numPiso = int(nombreArchivo[2])
    numNodo = int(nombreArchivo[5])
    print('Piso:%0.2d Nodo:%0.2d' % (numPiso, numNodo))

#Abre el archivo binario:
path = carpetaBin + "/" + str(nombreArchivo) + ".dat"
f = open(path, "rb")
tramaDatos = np.fromfile(f, np.int8, 2506)

horaInicioSeg = (3600 * tramaDatos[tramaSize - 3]) + (60 * tramaDatos[tramaSize - 2]) + (tramaDatos[tramaSize - 1])
horaInicio = str('%0.2d' % (int(horaInicioSeg / 3600))) + ":" + str('%0.2d' % (int((horaInicioSeg % 3600) / 60))) + ":" + str('%0.2d' % ((horaInicioSeg % 3600) % 60))
fechaEvento = str('%0.2d' % tramaDatos[tramaSize - 6]) + "-" + str('%0.2d' % tramaDatos[tramaSize - 5]) + "-" + str('%0.2d' % tramaDatos[tramaSize - 4])

fechaInfo = str('%0.2d' % tramaDatos[tramaSize - 6]) + str(
    '%0.2d' % tramaDatos[tramaSize - 5]) + str(
        '%0.2d' % tramaDatos[tramaSize - 4])
horaInfo = str('%0.2d' % (int(horaInicioSeg / 3600))) + str('%0.2d' % (int(
    (horaInicioSeg % 3600) / 60))) + str('%0.2d' %
                                         ((horaInicioSeg % 3600) % 60))

print(fechaEvento+" "+horaInicio)
                                         
#Obtiene y calcula el tiempo de inicio del muestreo
tiempoInicio = int((tramaDatos[tramaSize - 3] * 3600) +
                   (tramaDatos[tramaSize - 2] * 60) +
                   (tramaDatos[tramaSize - 1]))
#print (tiempoInicio)
print("Calculando...")

#Vector de muestras en milisegundos
#x_ms = np.linspace(0, segundosDia*1000, int(250/factorDiezmado)*segundosDia)
banExtraer = 1


class Cursor(object):
    def __init__(self, ax):
        self.ax = ax
        self.lx = ax.axhline(color='blue', linewidth=1)  # the horiz line
        self.ly = ax.axvline(color='red', linewidth=1)  # the vert line
        self.txt = ax.text(0.0, 0.9, '', transform=ax.transAxes)

    def mouse_move(self, event):
        if not event.inaxes:
            return

        xtime = (event.xdata)
        x, y = xtime, event.ydata
        # update the line positions
        self.lx.set_ydata(y)
        self.ly.set_xdata(x)
        self.txt.set_text((' T = %5.2f' % x) + (' Y = %1.2f' % y))
        self.ax.figure.canvas.draw()


if (banExtraer == 1):

    while (contMuestras < segundosDia):

        try:

            #tramaDatos = np.fromfile(f, np.int8, 2506)

            for i in range(0, 2501):  #Recorro las 2501 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
                if (i % (10 * factorDiezmado) == 0):  #Indica el inicio de un nuevo set de muestras
                    banGuardar = 1  #Cambia el estado de la bandera para permitir guardar la muestra
                    j = 0
                    contEje = 0
                else:
                    if (banGuardar == 1):
                        if (j < 2):
                            axisData[j] = tramaDatos[i]  #axisData guarda la informacion de los 3 bytes correspondientes a un eje
                        else:
                            axisData[2] = tramaDatos[i]  #Termina de llenar el vector axisData
                            axisValue = ((axisData[0] << 12) & 0xFF000) + ((axisData[1] << 4) & 0xFF0) + ((axisData[2] >> 4) & 0xF)

                            #Aplica el complemento a 2:
                            if (axisValue >= 0x80000):
                                axisValue = axisValue & 0x7FFFF  #Se descarta el bit 20 que indica el signo (1=negativo)
                                axisValue = -1 * (((~axisValue) + 1) & 0x7FFFF)

                            aceleracion = axisValue * (980 / pow(2, 18))  #Calcula la aceleracion en gales (float)

                            if (contEje == 0):
                                #xTrama.append(aceleracion-offTran)
                                acelY = aceleracion

                            if (contEje == 1):
                                #yTrama.append(aceleracion-offLong)
                                acelX = aceleracion

                            if (contEje == 2):
                                #zTrama.append(aceleracion-offVert)
                                acelZ = aceleracion

                                if (tipoEstacion == 0):
                                    xTrama.append(acelX)
                                    yTrama.append(acelY)
                                    zTrama.append(acelZ)
                                else:
                                    #Guarda los valores de aceleracion en el archivo con el orden y signo determinado por el nodo especifico:
                                    if (numPiso == 0):
                                        if (numNodo == 1 or numNodo == 2):
                                            #YnZnXn:
                                            #fprintf(fileX, "%2.5f\t%2.5f\t%2.5f\n", acelY, acelZ, acelX)
                                            xTrama.append(acelY)
                                            yTrama.append(acelZ)
                                            zTrama.append(acelX)
                                        if (numNodo == 3):
                                            #ZnYn-Xn:
                                            #fprintf(fileX, "%2.5f\t%2.5f\t%2.5f\n", acelZ, acelY, acelX*-1)
                                            xTrama.append(acelZ)
                                            yTrama.append(acelY)
                                            zTrama.append((-1 * acelX))
                                        if (numNodo == 4):
                                            #-ZnYnXn:
                                            #fprintf(fileX, "%2.5f\t%2.5f\t%2.5f\n", acelZ*-1, acelY, acelX)
                                            xTrama.append((-1 * acelZ))
                                            yTrama.append(acelY)
                                            zTrama.append(acelX)
                                    else:
                                        #Yn-ZnXn:
                                        #fprintf(fileX, "%2.5f\t%2.5f\t%2.5f\n", acelY, acelZ*-1, acelX)
                                        xTrama.append(acelY)
                                        yTrama.append((-1 * acelZ))
                                        zTrama.append(acelX)

                                banGuardar = 0  #Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar

                            j = -1
                            contEje = contEje + 1
                        j = j + 1

            tramaDatos = np.fromfile(f, np.int8, 2506)
            contMuestras = contMuestras + 1

        except:

            print("Advertencia: Archivo incompleto")
            duracionEvento = contMuestras
            x_ms = np.linspace(0, contMuestras * 1000,
                               int(250 / factorDiezmado) * contMuestras)
            contMuestras = segundosDia

    #Cierra el archivo binario:
    f.close()

    #Convierte los vectores X, Y y Z a formato np:
    npX = np.array(xTrama)
    npY = np.array(yTrama)
    npZ = np.array(zTrama)

    #Calcula la media:
    meanX = np.mean(npX)
    meanY = np.mean(npY)
    meanZ = np.mean(npZ)

    #Calcula la mediana:
    medX = np.median(npX)
    medY = np.median(npY)
    medZ = np.median(npZ)

    #Calcula el RMS de los datos de cada eje:
    rmsX = np.sqrt(np.mean(npX**2))
    rmsY = np.sqrt(np.mean(npY**2))
    rmsZ = np.sqrt(np.mean(npZ**2))

    #Calcula los maximos y minimos:
    minX = np.min(npX)
    maxX = np.max(npX)
    minY = np.min(npY)
    maxY = np.max(npY)
    minZ = np.min(npZ)
    maxZ = np.max(npZ)

    #Calcula la amplitud Pico-Pico
    ppX = round(abs(maxX - minX))
    ppY = round(abs(maxY - minY))
    ppZ = round(abs(maxZ - minZ))
    listaPP = [ppX, ppY, ppZ]
    maxPP = max(listaPP)

    print('X:' + ' Media = ' + str(meanX) + ' Mediana = ' + str(medX) +
          ' RSM = ' + str(rmsX) + ' Min = ' + str(minX) + ' Max = ' +
          str(maxX) + ' APP = ' + str(ppX))
    print('Y:' + ' Media = ' + str(meanY) + ' Mediana = ' + str(medY) +
          ' RSM = ' + str(rmsY) + ' Min = ' + str(minY) + ' Max = ' +
          str(maxY) + ' APP = ' + str(ppY))
    print('Z:' + ' Media = ' + str(meanZ) + ' Mediana = ' + str(medZ) +
          ' RSM = ' + str(rmsZ) + ' Min = ' + str(minZ) + ' Max = ' +
          str(maxZ) + ' APP = ' + str(ppZ))
    #print('Max APP = ' + str(maxPP))

    #Realiza el offset de la señales:
    for i in range(0, len(xTrama)):
        xTrama[i] = xTrama[i] - meanX
        yTrama[i] = yTrama[i] - meanY
        zTrama[i] = zTrama[i] - meanZ

    #Calcula el RMS de los datos corregidos:
    npX2 = np.array(xTrama)
    npY2 = np.array(yTrama)
    npZ2 = np.array(zTrama)
    rmsX2 = np.sqrt(np.mean(npX2**2))
    rmsY2 = np.sqrt(np.mean(npY2**2))
    rmsZ2 = np.sqrt(np.mean(npZ2**2))
    print('Long:' + ' RSM = ' + str(rmsX2))
    print('Tran:' + ' RSM = ' + str(rmsY2))
    print('Vert:' + ' RSM = ' + str(rmsZ2))

    #Grafica las señales
    if (modoGrafico == 0):
        limY = (maxPP)
        fig = plt.figure()
        ax1 = fig.add_subplot(311)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, xTrama)
        plt.setp(ax1.get_xticklabels(), visible=False)
        plt.title('Eje Longitudinal')
        plt.ylabel('Aceleracion [cm/seg2]')

        ax2 = plt.subplot(312, sharex=ax1)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, yTrama)
        plt.setp(ax2.get_xticklabels(), visible=False)
        plt.title('Eje Transversal')
        plt.ylabel('Aceleracion [cm/seg2]')

        ax3 = plt.subplot(313, sharex=ax1)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, zTrama)
        plt.title('Eje Vertical')
        infoTiempo = "Tiempo [ms]\n" "\n" + "Fecha: " + fechaEvento + "   Hora de inicio: " + horaInicio
        plt.xlabel(infoTiempo)
        plt.ylabel('Aceleracion [cm/seg2]')

        cursor1 = Cursor(ax1)
        cursor2 = Cursor(ax2)
        cursor3 = Cursor(ax3)

        fig.canvas.mpl_connect('motion_notify_event', cursor1.mouse_move)
        fig.canvas.mpl_connect('motion_notify_event', cursor2.mouse_move)
        fig.canvas.mpl_connect('motion_notify_event', cursor3.mouse_move)

    if (modoGrafico == 1):
        limY = 4
        fig = plt.figure()
        ax1 = fig.add_subplot(331)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, xTrama)
        plt.title('Eje Longitudinal')
        plt.ylabel('Aceleracion [cm/seg2]')

        ax2 = plt.subplot(332, sharex=ax1)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, yTrama)
        plt.setp(ax2.get_yticklabels(), visible=False)
        plt.title('Eje Transversal')
        infoTiempo = "Tiempo [seg]\n" "\n" + "Fecha: " + fechaEvento + "   Hora de inicio: " + horaInicio + "(UTC)"
        plt.xlabel(infoTiempo)

        ax3 = plt.subplot(333, sharex=ax1)
        plt.ylim(-limY, limY)
        plt.plot(x_ms, zTrama)
        plt.setp(ax3.get_yticklabels(), visible=False)
        plt.title('Eje Vertical')

    plt.show()

    #Extraccion del evento en un archivo de texto:
    extraerEventoTxt = input("Desea extraer el evento? s/n: ")
    if (extraerEventoTxt == 's'):
        print('Extrayendo..')
        #Crea una nueva carpeta con la fecha del evento:
        pathTxt = carpetaTxt + "/" + str(fechaEvento)
        try:
            os.mkdir(pathTxt)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise
        #Guarda la imagen del grafico:
        nombreImagen = pathTxt + "/" + str(nombreArchivo) + ".png"
        #plt.savefig(nombreImagen, dpi=100)
        #Crea el archivo de texto y el archi de informacion con el nombre del archivo binario:
        nameFileTxt = pathTxt + "/" + str(nombreArchivo) + ".txt"
        nameFileInfo = pathTxt + "/" + str(nombreArchivo) + ".INFO"
        fileTxt = open(nameFileTxt, "w")
        fileInfo = open(nameFileInfo, "w")
        #Genera el archivo de informacion
        cabeceraInfo = 'Fecha(aammdd),Tiempo(hhmmss),Tiempo(segundos),Duracion(segundos),Periodo(ms)\n'
        datosInfo = fechaInfo + ',' + horaInfo + ',' + str(
            tiempoInicio) + ',' + str(duracionEvento) + ',4'
        fileInfo.write(cabeceraInfo)
        fileInfo.write(datosInfo)
        #Guarda los vectores de datos en el archivo de texto:
        for i in range(0, len(xTrama)):
            #datosTxt = str(xTrama[i]) + " " + str(yTrama[i]) + " " + str(zTrama[i]) + os.linesep
            #str('%0.2d' % (int(horaInicioSeg/3600)))
            datosTxt = '%.5f\t%.5f\t%.5f\n' % (xTrama[i], yTrama[i], zTrama[i])
            fileTxt.write(datosTxt)
        #Cierra los archivos:
        fileInfo.close()
        fileTxt.close()

    else:
        print('Adios')
        exit()

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
