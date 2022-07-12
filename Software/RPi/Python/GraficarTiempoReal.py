from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import numpy as np
import struct
import matplotlib.pyplot as plt
import matplotlib.animation as animation


filepath = "/home/rsa/TMP/TramaTemporal.tmp"
filepathM = "/home/rsa/Resultados/RegistroContinuo/UCUE01_220712-230954.dat"

#********************************************************************************
#Variables y parametros
#********************************************************************************
#Lectura del archivo binario:
tramaSize = 2506
valCH1 = 0
valCH2 = 0
valCH3 = 0
xData = [0 for i in range(4)]
yData = [0 for i in range(4)]
zData = [0 for i in range(4)]

#Parametros del grafico:
x_len = 120         # Number of points to display
y1_range = [-2, 2]  # Range of possible Y values to display
y2_range = [-2, 2] 
y3_range = [8, 12] 
# Crea la figura y los subplots
plt.style.use('dark_background')
fig = plt.figure()
ax1 = fig.add_subplot(3, 1, 1)
ax2 = fig.add_subplot(3, 1, 2)
ax3 = fig.add_subplot(3, 1, 3)
#Establece los limistes del eje X
xs = list(range(0, 120))
ys1 = [0] * x_len
ys2 = [0] * x_len
ys3 = [0] * x_len
#Establece los limites del eje Y
ax1.set_ylim(y1_range)
ax2.set_ylim(y2_range)
ax3.set_ylim(y3_range)
#Establece los colores de fondo de los subplots
ax1.set_facecolor('#181c1fff')
ax2.set_facecolor('#181c1fff')
ax3.set_facecolor('#181c1fff')
#Establece el estilo del grid
ax1.grid(linestyle='-',linewidth=0.2)
ax2.grid(linestyle='-',linewidth=0.2)
ax3.grid(linestyle='-',linewidth=0.2)
#Establece las marcas del eje X
plt.setp(ax1.get_xticklabels(), visible=False)     #Borra las marcar del plot x1
plt.setp(ax2.get_xticklabels(), visible=False)     #Borra las marcar del plot x2
ax3.set_xticks([0,20,40,60,80,100,120])     #Selecciona las marcas de los puntos extremos y mitad del eje X
ax3.set_xticklabels([-60,'','',-30,'','',0])     #Remplaza las marcas seleccionadas por los valores 0, 30 y 60
ax1.tick_params(labelsize=9,labelcolor='gray')
ax2.tick_params(labelsize=9,labelcolor='gray')
ax3.tick_params(labelsize=9,labelcolor='gray')
#Establece las etiquetas de los ejes X y Y
ax1.set_ylabel('CH1')
ax2.set_ylabel('CH2')
ax3.set_ylabel('CH3')
ax3.set_xlabel('Tiempo [seg]')
# Create a blank line. We will update the line in animate
line1, = ax1.plot(xs, ys1, color='#5bd15eff')
line2, = ax2.plot(xs, ys2, color='#5bd15eff')
line3, = ax3.plot(xs, ys3, color='#5bd15eff')

#********************************************************************************


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
    tramaDatos = np.fromfile(objFile, np.int8, tramaSize)
    
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

    #Imprime la hora y fecha recuperada de la trama de datos
    #print("Datos de la trama:")
    print("|%02d:%02d:%02d %02d/%02d/%02d|" % (tramaDatos[tramaSize-3], tramaDatos[tramaSize-2],  tramaDatos[tramaSize-1], tramaDatos[tramaSize-6], tramaDatos[tramaSize-5], tramaDatos[tramaSize-4]))		
	#Imprime los datos de aceleracion:
    print("|X: %2.8f Y: %2.8f Z: %2.8f|" % (valCH1, valCH2, valCH3))
    
    #print("%f   %f   %f" % (valCH1, valCH2, valCH3))

    # Al final cierra el archivo de lectura
    objFile.close()

#********************************************************************************

#********************************************************************************
#Metodo que se llama periodicamente desde FuncAnimation
#********************************************************************************
def animate(i):
    
    global xs
    global ys1
    global ys2
    global ys3

    # Actualiza la medicion de los canales CH1, CH2 y CH3
    medCH1 = valCH1
    medCH2 = valCH2
    medCH3 = valCH3

    # Add x and y to lists
    ys1.append(medCH1)
    ys2.append(medCH2)
    ys3.append(medCH3)

    # Limit y list to set number of items
    ys1 = ys1[-x_len:]
    ys2 = ys2[-x_len:]
    ys3 = ys3[-x_len:]

    line1.set_data(xs,ys1)
    line2.set_data(xs,ys2)
    line3.set_data(xs,ys3)

    return line1,line2,line3

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
observer.schedule(MyEventHandler(), filepathM, recursive=False)
observer.start()

# Set up plot to call animate() function periodically
#ani = animation.FuncAnimation(fig, animate, fargs=(ys1, ys2, ys3, ), interval=500, blit=True)
ani = animation.FuncAnimation(fig, animate, interval=500, blit=True)
plt.show()

try:
    while observer.is_alive():
        observer.join(1)
        print("hola")
except KeyboardInterrupt:
    observer.stop()
observer.join()

#********************************************************************************