
from __future__ import print_function
from googleapiclient import errors
from googleapiclient.http import MediaFileUpload
from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools

from datetime import datetime
import time


# ///////////////////////////////// Archivos //////////////////////////////////

pathArchivosConfiguracion = '/home/rsa/Configuracion/'
pathNombresArchvivosRC = '/home/rsa/TMP/'
pathLogFiles = '/home/rsa/LogFiles/'

archivoDatosConfiguracion = pathArchivosConfiguracion + 'DatosConfiguracion.txt'
archivoNombresArchivosRC = pathNombresArchvivosRC + 'NombreArchivoRegistroContinuo.tmp'

credentialsFile = pathArchivosConfiguracion + 'credentials.json'
tokenFile = pathArchivosConfiguracion + 'token.json'
#nombreArchivo = 'C00N02_210611-065731-GPS_090.dat'
#archivoSubir = direccionCarpeta + nombreArchivo
# ID de la carpeta para almacenar los archivos en Drive
# Esta ID se obtiene ingresando al Drive mediante el navegador y en la URL
# https://drive.google.com/drive/u/1/folders/12S_kjBDl1wZALM1B0El892Oa-Il7kEXa
#pathDriveID = '1LLSy9PkgP7CEUKfPYPjwWgp48V9i6NA3'

# /////////////////////////////////////////////////////////////////////////////



# ////////////////////////////////// Metodos //////////////////////////////////

# **********************************************************************
# ******************* Metodo get_authenticated *************************
# **********************************************************************
# Metodo que permite realizar la autenticacion a Google Drive, para esto
# es necesario tener el archivo credentials.json en la misma carpeta de
# este script. La primera vez se abrira el navegador para realizar la
# autenticacion y se creara el archivo token.json que permite realizar
# directamente la autenticacion desde la segunda vez que se ejecute, sin
# necesidad del navegador
def get_authenticated(SCOPES, credential_file = credentialsFile,
                  token_file = tokenFile, service_name = 'drive',
                  api_version = 'v3'):
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    store = file.Storage(token_file)
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets(credential_file, SCOPES)
        creds = tools.run_flow(flow, store)
    service = build(service_name, api_version, http = creds.authorize(Http()))

    return service
# **********************************************************************
# ****************** Fin Metodo get_authenticated **********************
# **********************************************************************


# **********************************************************************
# ************************* Metodo insert_file *************************
# **********************************************************************
# Metodo que permite subir un archivo a la cuenta de Drive, no importa
# el tamaño del archivo. Si se desea subir a una carpeta en específico
# se debe colocar el parent_id
def insert_file(service, name, description, parent_id, mime_type, filename):
    """Insert new file.

    Args:
        service: Drive API service instance.
        name: Name of the file to insert, including the extension.
        description: Description of the file to insert.
        parent_id: Parent folder's ID.
        mime_type: MIME type of the file to insert.
        filename: Filename of the file to insert.
    Returns:
        Inserted file metadata if successful, None otherwise.
    """
    #media_body = MediaFileUpload(filename, mimetype = mime_type, resumable = False, chunksize=256 * 1024)
    #media_body = MediaFileUpload(filename, mimetype = mime_type, resumable = False)
    media_body = MediaFileUpload(filename, mimetype = mime_type, chunksize=-1, resumable = True)
    body = {
        'name': name,
        'description': description,
        'mimeType': mime_type
    }
        
    # Si se recibe la ID de la carpeta superior, la coloca
    if parent_id:
        body['parents'] = [parent_id]

    # Realiza la carga del archivo en la carpeta respectiva de Drive
    try:
        #print("punto de control")
        file = service.files().create(
            body = body,
            media_body = media_body,
            fields='id').execute()
        
        #Prueba
        # response = None
        # while response is None:
        #     status, response = file.next_chunk()
        #     if status:
        #         #logger.info('Uploaded {}%'.format(int(100*status.progress()))
        #         print ("Uploaded %d%%." % int(status.progress() * 100))
        #Fin prueba
        
        # Uncomment the following line to print the File ID
        # print 'File ID: %s' % file['id']
        
        return file
        #print "Upload Complete!"
    
    except errors.HttpError as error:
        print('An error occurred: %s' % error)
        return None
# **********************************************************************
# *********************** Fin Metodo insert_file ***********************
# **********************************************************************


# **********************************************************************
# Metodo para intentar conectarse a Google Drive y activar la bandera de conexion
# **********************************************************************
def Try_Autenticar_Drive(SCOPES):
    global isConecctedDrive
    # Llama al metodo para realizar la autenticacion, la primera vez se
    # abrira el navegador, pero desde la segunda ya no
    try:
        service = get_authenticated(SCOPES)
        isConecctedDrive = True
        print("Inicio Drive Ok")
        guardarDataInLogFile ("Inicio Drive Ok")
        return service
    except:
        isConecctedDrive = False
        print("********** Error Inicio Drive ********")
        guardarDataInLogFile ("Error Inicio Drive")
        return 0
# **********************************************************************
# Fin del metodo para conectarse a Drive
# **********************************************************************


# **********************************************************************
# ****************** Metodo guardarDataInLogFile ***********************
# **********************************************************************
def guardarDataInLogFile (info):
    global objLogFile

    timeActual = datetime.now()
    timeFormato = timeActual.strftime('%Y-%m-%d %H:%M:%S')

    # Abre o crea el nuevo archivo de texto y en formato para escribir
    archivo = open(objLogFile, "a")
    archivo.write((timeFormato + "\t" + info + "\n"))
    archivo.close()
# **********************************************************************
# *************** Fin Metodo guardarDataInLogFile **********************
# **********************************************************************

# /////////////////////////////////////////////////////////////////////////////



# ///////////////////////////////// Principal /////////////////////////////////

if __name__ == '__main__':
    
    #service  = 0
    # If modifying these scopes, delete the file token.json.
    SCOPES = 'https://www.googleapis.com/auth/drive'
	 # Llama al metodo para realizar la autenticacion, la primera vez se
	 # abrira el navegador, pero desde la segunda ya no
	 #service = get_authenticated(SCOPES)
     
    # Fecha actual
    fechaActual = datetime.now()
    fechaFormato = fechaActual.strftime('%Y-%m-%d') 
             
    ficheroConfiguracion = open(archivoDatosConfiguracion)
    ficheroNombresArchivos = open(archivoNombresArchivosRC)
    
    lineasFicheroConfiguracion = ficheroConfiguracion.readlines()
    lineasFicheroNombresArchivos = ficheroNombresArchivos.readlines()
    
    nombreArchvioRegistroContinuo = lineasFicheroNombresArchivos[1].rstrip('\n')
    print(nombreArchvioRegistroContinuo)
    pathArchivoRegistroContinuo = lineasFicheroConfiguracion[2].rstrip('\n') + nombreArchvioRegistroContinuo
    pathDriveID = lineasFicheroConfiguracion[6].rstrip('\n')
    
    # Crea el archivo para almacenar los logs del proyectos, que eventos ocurren
    objLogFile = pathLogFiles + 'Log' + lineasFicheroConfiguracion[0].rstrip('\n') + fechaFormato + '.txt'
    # Llama al metodo para crear un nuevo archivo log
    #guardarDataInLogFile ("Inicio")
    
    
    #Llama al metodo para intentar conectarse a Google Drive
    service = Try_Autenticar_Drive(SCOPES)
    
    if isConecctedDrive == True:
        # Llama al metodo para subir el archivo a Google Drive
        try:
            # El metodo tiene este formato: insert_file(service, name, description, parent_id, mime_type, filename)
            #file_uploaded = insert_file(service, nombreArchivo, nombreArchivo, pathDriveID, 'text/x-script.txt', archivoSubir)
            print('Subiendo el archivo: %s' %pathArchivoRegistroContinuo)
            guardarDataInLogFile ("Subiendo el archivo: " + nombreArchvioRegistroContinuo)
            #file_uploaded = insert_file(service, nombreArchvioRegistroContinuo, nombreArchvioRegistroContinuo, pathDriveID, 'text/x-script.txt', pathArchivoRegistroContinuo)
            file_uploaded = insert_file(service, nombreArchvioRegistroContinuo, nombreArchvioRegistroContinuo, pathDriveID, 'text/plain', pathArchivoRegistroContinuo)
            guardarDataInLogFile ("Archivo subido correctamente a Google Drive " + str(file_uploaded))
            print('Archivo' + nombreArchvioRegistroContinuo + ' subido correctamente a Google Drive ' )
        except:
            # Llama al metodo para guardar el evento ocurrido en el archivo
            guardarDataInLogFile ("Error subiendo el archivo a Google Drive")
            print ('Error subiendo el archivo a Google Drive')
# /////////////////////////////////////////////////////////////////////////////
