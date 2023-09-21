import tkinter
from tkinter import filedialog
import os
import numpy as np
import csv
from obspy import UTCDateTime, read, Trace, Stream
import subprocess

# ///////////////////////////////// Archivos //////////////////////////////////

archivoConfiguracionMseed = 'configuracion_mseed.csv'

#abre una ventana para seleccionar el archivo
root = tkinter.Tk()
root.withdraw() # use to hide tkinter window
# Definir los tipos de archivo y sus extensiones correspondientes
tipos_archivo = (
    ("Archivos binarios", "*.dat"),
    ("Todos los archivos", "*.*")
)
# establecer atributos de la ventana de selección de archivos
root.attributes('-topmost', True)
root.attributes('-topmost', False)
currdir = os.getcwd()
archivo_binario = filedialog.askopenfilename(parent = root, initialdir = currdir, title = 'please select a file',filetypes=tipos_archivo)
#------------------------------------------------------------------------------
# /////////////////////////////////////////////////////////////////////////////

def parametros_():
#################################################################
#Método de Extracción de datos de conficuración de la estacion
#Desde el archivo configuracion.csv que debe estar presente en el mismo directorio del ejecutable.
        
        estaciones_=[]
        with open(archivoConfiguracionMseed,newline='') as f:
            datos=csv.reader(f,delimiter=';',quotechar=';')
            for r in datos:
                estaciones_.append(r)
        nombre_canal_total_=estaciones_[1][1]
        nombre_canal=estaciones_[1][2]
        tipo_canal_=estaciones_[1][3]
        n_canales_=estaciones_[1][4]
        hab_canal=estaciones_[1][5]
        componente_canal=estaciones_[1][6]
        grafico_=estaciones_[1][7]
        hab_plt=estaciones_[1][8]
        gan_plt=estaciones_[1][9]
        ganancia=estaciones_[1][10]
        diez_plt=estaciones_[1][11]
        bits_=estaciones_[1][12]
        calidad_=estaciones_[1][13]
        ubicacion_=estaciones_[1][14]
        tipo_canal=estaciones_[1][15]
        red_=estaciones_[1][16]
        muestreo_=estaciones_[1][17]
        longitud_=estaciones_[1][18]
        latitud_=estaciones_[1][19]
        altura_=estaciones_[1][20]
        ruido_=int(estaciones_[1][21])
        numero_est=int(estaciones_[1][0])
        filtro_=estaciones_[1][22]
        reserva_1=estaciones_[1][23]
        reserva_2=estaciones_[1][24]            
                
                
        return(nombre_canal_total_, #Canal 0  'NOMBRE'
               nombre_canal,        #Canal 1  'CODIGO'
               tipo_canal_,         #Canal 2  'SENSOR'
               n_canales_,          #Canal 3  'CANALES'
               hab_canal,           #Canal 4  'HAB_CANAL'
               componente_canal,    #Canal 5  'COMPONENTE'
               grafico_,            #Canal 6  'HAB_GRAFICO'
               hab_plt,             #Canal 7  'HAB_PLT'
               gan_plt,             #Canal 8  'GAN_PLT'
               ganancia,            #Canal 9  'GANANCIA'
               diez_plt,            #Canal 10 'DIEZ_PLT'
               bits_,               #Canal 11 'FACTOR_MUL'
               longitud_,           #Canal 12 'LONGITUD'
               latitud_,            #Canal 13 'LATITUD'
               altura_,             #Canal 14 'ALTITUD'
               ruido_,              #Canal 15 'RUIDO'
               calidad_,            #Canal 16 'CALIDAD'
               ubicacion_,          #Canal 17 'UBICACIÓN'
               tipo_canal,          #Canal 18 'CANAL'
               red_,                #Canal 19 'RED'
               muestreo_,           #Canal 20 'MUESTREO'
               numero_est,          #Canal 21 'N° ESTACION'
               filtro_,             #Canal 22 'FILTRO' 
               reserva_1,           #Canal 22 'Reserva 1'            
               reserva_2)           #Canal 22 'Reserva 2'


def obtenerTraza(nombreCanal,num_canal, data, anio, mes, dia, horas, minutos, segundos, microsegundos, segundos_faltantes=None):
    
    print('obteniedo traza:', num_canal)
    
    # Define todas las caracteristicas de la traza
    parametros=parametros_()
    nombreRed=parametros[19]
    nombreEstacion=parametros[1]
    tipoEstacion=parametros[2]
    localizacion=parametros[17]
    nCanal=parametros[18]
    fsample=int(parametros[20])
    calidad=parametros[16]
    if fsample>80:
        nombreCanal='E'
    else:
        nombreCanal='S'
    if tipoEstacion=='SISMICO':
        nombreCanal=nombreCanal+'L'
    else:
        nombreCanal=nombreCanal+'N'
    num_canal=num_canal-3*(int((num_canal-1)/3))
    nombreCanal=nombreCanal+nCanal[num_canal-1:num_canal]
    stats = {'network': nombreRed, 'station': nombreEstacion, 'location': localizacion,
             'channel': nombreCanal, 'npts': len(data), 'sampling_rate': fsample,
             'mseed': {'dataquality': calidad}}
    # Establece el tiempo
    stats['starttime'] = UTCDateTime(anio, mes, dia, horas, minutos, segundos, microsegundos)    
    
    # Crea la traza con los datos las caracteristicas
    #traza = Trace(data = data, header = stats)
    
    # Crea la traza con los datos y las características
    if segundos_faltantes is not None:
        
        segundo_inicio = (horas*3600)+(minutos*60)+segundos
        muestras_por_segundo = int(fsample)
        lista_ceros = np.zeros(muestras_por_segundo, dtype=np.int32)
        npts_completo = len(data) + int(len(segundos_faltantes) * muestras_por_segundo)
        
        data_completo = np.zeros(npts_completo, dtype=np.int32)  
        data_completo = data.copy()
        
        stats['npts'] = npts_completo
        print('NTPS completo: ', npts_completo)
            
        for segundo_faltante in segundos_faltantes:
            
            tiempo_muestra_faltante = int(segundo_faltante-segundo_inicio)
            #print(tiempo_muestra_faltante)
            indice_muestra_faltante = tiempo_muestra_faltante * muestras_por_segundo
            #print(indice_muestra_faltante)
            #print(data_completo[(indice_muestra_faltante-10):(indice_muestra_faltante+260)])
            data_completo = np.insert(data_completo, indice_muestra_faltante, lista_ceros)
            #print(data_completo[(indice_muestra_faltante-10):(indice_muestra_faltante+260)])
        
        '''
        print('Inicio')
        print(data_completo[(indice_muestra_faltante-1010):(indice_muestra_faltante-750)])
        print('Fin')
        print(data_completo[(indice_muestra_faltante):(indice_muestra_faltante+260)])
        '''
        print('Len data_completo: ', len(data_completo))
        
        traza = Trace(data=data_completo, header=stats)    
        
    else:
        traza = Trace(data=data, header=stats)
    
    return traza
    #return data_completo


def lectura_archivo(archivo):
    datos = [[], [], []]
    contador = 0
    segundo_anterior = None
    segundos_faltantes = []

    with open(archivo, "rb") as f:
        while True:
            tramaDatos = np.fromfile(f, np.int8, 2506)
            if len(tramaDatos) != 2506:
                break
            
            hora = tramaDatos[2503]
            minuto = tramaDatos[2504]
            segundo = tramaDatos[2505]
            n_segundo = hora * 3600 + minuto * 60 + segundo
            
            if segundo_anterior is not None:
                if n_segundo != segundo_anterior + 1:
                    segundos_faltantes.extend(range(segundo_anterior + 1, n_segundo))
                elif n_segundo > segundo_anterior + 1:
                    # Si hay un salto mayor, se llenan los segundos faltantes intermedios
                    segundos_faltantes.extend(range(segundo_anterior + 1, n_segundo))
            
            segundo_anterior = n_segundo
            
            for j in range(0, 3):
                for i in range(0, 250):
                    dato_1 = tramaDatos[i * 10 + j * 3 + 1]
                    dato_2 = tramaDatos[i * 10 + j * 3 + 2]
                    dato_3 = tramaDatos[i * 10 + j * 3 + 3]
                    xValue = ((dato_1 << 12) & 0xFF000) + ((dato_2 << 4) & 0xFF0) + ((dato_3 >> 4) & 0xF)
                    if (xValue >= 0x80000):
                        xValue = xValue & 0x7FFFF
                        xValue = -1 * (((~xValue) + 1) & 0x7FFFF)
                    datos[j].append(int(xValue))

            contador += 1
            if contador == 864:
                contador = 0

    datos_np = np.asarray(datos)

    if segundos_faltantes:
        print("Segundos faltantes:", segundos_faltantes)

    return datos_np, segundos_faltantes if segundos_faltantes else None


def verificacion_archivo(archivo):
    f = open(archivo, "rb")
    tramaDatos = np.fromfile(f, np.int8, 2506)
    hora = tramaDatos[2503]
    minuto = tramaDatos[2504]
    segundo = tramaDatos[2505]
    n_segundo=hora*3600+minuto*60+segundo
    anio=tramaDatos[2500]
    anio_s= str(anio)
    mes=tramaDatos[2501]
    mes_s=str(mes)
    if(mes<10):
        mes_s='0'+mes_s
    dia=tramaDatos[2502]
    dia_s=str(dia)
    if(dia<10):
        dia_s='0'+dia_s
    hora_s=str(hora)
    if(hora<10):
        hora_s='0'+hora_s
    minuto_s=str(minuto)
    if(minuto<10):
        minuto_s='0'+minuto_s
    segundo_s=str(segundo)
    if(segundo<10):
        segundo_s='0'+segundo_s
    fecha_=(anio,mes,dia,hora,minuto,segundo,n_segundo),(anio_s,mes_s,dia_s,hora_s,minuto_s,segundo_s)
    f.close
    return(fecha_)


def nombre_mseed(nombre_,fecha_):
    anio_s=fecha_[1][0]
    mes_s=fecha_[1][1]
    dia_s=fecha_[1][2]
    hora_s=fecha_[1][3]
    minuto_s=fecha_[1][4]
    segundo_s=fecha_[1][5]
    fecha_string=anio_s+mes_s+dia_s        
    hora_string=hora_s+minuto_s+segundo_s
    fileName = 'C:/Users/RSA-Milton/Desktop/Convertidor binario-texto/mseed/'+nombre_+fecha_string+"_"+hora_string+".mseed" 
    return fileName
    
    
def conversion_mseed_digital(fileName,fecha_, data_np, segundos_faltantes):
    # Nombre del archivo en funcion del tiempo de inicio
    anio=fecha_[0][0]
    mes=fecha_[0][1]
    dia=fecha_[0][2]
    horas=fecha_[0][3]
    minutos=fecha_[0][4]
    segundos=fecha_[0][5]
    parametros=parametros_()
    nombre_=parametros[2]

    #fileName=self.directorio_registros+fileName
    
    print("Convirtiendo archivo...")
    
    #trazaCH1 = obtenerTraza(nombre_,1, data_np[0],(2000 + anio), mes, dia, horas, minutos, segundos, 0, segundos_faltantes)
    #trazaCH3 = obtenerTraza(nombre_,3, data_np[2],(2000 + anio), mes, dia, horas, minutos, segundos, 0, segundos_faltantes)    
    
    
    # Una vez que se tiene los datos, llama al metodo para obtener la traza
    # Todos los parametros que recibe se detallan en el metodo (mas abajo)
    trazaCH1 = obtenerTraza(nombre_,1, data_np[0],(2000 + anio), mes, dia, horas, minutos, segundos, 0, segundos_faltantes)
    trazaCH2 = obtenerTraza(nombre_,2, data_np[1],(2000 + anio), mes, dia, horas, minutos, segundos, 0, segundos_faltantes)        
    trazaCH3 = obtenerTraza(nombre_,3, data_np[2],(2000 + anio), mes, dia, horas, minutos, segundos, 0, segundos_faltantes)
    # Crea un objeto Stream con la traza
    #stData = Stream(traces=[trazaCH1])
    # Si se desea varias trazas, esto seria para cuando se tiene 3 canales
    stData = Stream(traces=[trazaCH1, trazaCH2, trazaCH3])
    
    stData.write(fileName, format = 'MSEED', encoding = 'STEIM1', reclen = 512)
    

parametros=parametros_()
nombre=parametros[1]
fecha_=verificacion_archivo(archivo_binario)
nombre_= parametros[1]+'_20'
n_mseed=nombre_mseed(nombre_,fecha_)
datos_np, segundos_faltantes  = lectura_archivo(archivo_binario)
conversion_mseed_digital(n_mseed,fecha_, datos_np, segundos_faltantes)


print(n_mseed)

if segundos_faltantes is None:
    print("No hay segundos faltantes.")
else:
    print("Segundos faltantes:", segundos_faltantes)