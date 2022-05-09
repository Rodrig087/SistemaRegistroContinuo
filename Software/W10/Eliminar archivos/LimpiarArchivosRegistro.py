
import os


# ///////////////////////////////// Principal /////////////////////////////////

if __name__ == '__main__':
    
    #******************************************************************************
    #Obtiene el nombre de todos los archivos:
    #Lista los archivos del directorio a subir
    rutaCarpeta = "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/SistemaRegistroContinuo/Resultados/RegistroContinuo/"
    listaMeses=[] 
    #print(rutaCarpeta)
    listaArchivos = os.listdir(rutaCarpeta)
    listaArchivosOrdenada = sorted(listaArchivos) 
    listaArchivosOrdenada = listaArchivosOrdenada[0:(len(listaArchivosOrdenada)-3)]
    #print(listaArchivosOrdenada)    
    #******************************************************************************
    
    #******************************************************************************
    #Obtiene los prefijos de los archivos de los 2 ultimos meses:
    for nombreArchivo in listaArchivosOrdenada: 
        #print(nombreArchivo[7:11])
        listaMeses.append(nombreArchivo[0:11])
    
    #Crea un set con el nombre de los meses
    #print(set(listaMeses))
    setMeses = sorted(set(listaMeses))
    #print(setMeses)
    mes1 = setMeses[len(setMeses)-2]
    mes2 = setMeses[len(setMeses)-1]
    print(mes1)
    print(mes2)
    #******************************************************************************
    
    #******************************************************************************
    #Lista todos los archivos excepto los correspondientes a los 2 ultimos meses:
    for nombreArchivo in listaArchivosOrdenada: 
        if (nombreArchivo[0:11]!=mes1) and (nombreArchivo[0:11]!=mes2):
            #print(nombreArchivo)
            pathArchivo = rutaCarpeta + nombreArchivo
            print(pathArchivo)
            
    #******************************************************************************
        
          