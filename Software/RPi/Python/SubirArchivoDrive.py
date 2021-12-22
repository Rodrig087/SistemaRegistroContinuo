
from __future__ import print_function
from googleapiclient import errors
from googleapiclient.http import MediaFileUpload
from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools


# ///////////////////////////////// Archivos //////////////////////////////////

pathArchivosConfiguracion = '/home/rsa/Configuracion/'
pathNombresArchvivosRC = '/home/rsa/TMP/'

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
    media_body = MediaFileUpload(filename, mimetype = mime_type, resumable = True)
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
        file = service.files().create(
            body = body,
            media_body = media_body).execute()

        # Uncomment the following line to print the File ID
        # print 'File ID: %s' % file['id']

        return file
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
        return service
    except:
        isConecctedDrive = False
        print("********** Error Inicio Drive ********")
        return 0
# **********************************************************************
# Fin del metodo para conectarse a Drive
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
     
    ficheroConfiguracion = open(archivoDatosConfiguracion)
    ficheroNombresArchivos = open(archivoNombresArchivosRC)
    
    lineasFicheroConfiguracion = ficheroConfiguracion.readlines()
    lineasFicheroNombresArchivos = ficheroNombresArchivos.readlines()
    
    nombreArchvioRegistroContinuo = lineasFicheroNombresArchivos[1].rstrip('\n')
    pathArchivoRegistroContinuo = lineasFicheroConfiguracion[2].rstrip('\n') + nombreArchvioRegistroContinuo
    pathDriveID = lineasFicheroConfiguracion[6].rstrip('\n')
    
    #print('Subiendo el archivo: %s' %nombreArchvioRegistroContinuo)
    print('Subiendo el archivo: %s' %pathArchivoRegistroContinuo)
    #print(pathArchivoRegistroContinuo)
    
    #Llama al metodo para intentar conectarse a Google Drive
    service = Try_Autenticar_Drive(SCOPES)
    
    if isConecctedDrive == True:
        # El metodo tiene este formato: insert_file(service, name, description, parent_id, mime_type, filename)
        #file_uploaded = insert_file(service, nombreArchivo, nombreArchivo, pathDriveID, 'text/x-script.txt', archivoSubir)
        file_uploaded = insert_file(service, nombreArchvioRegistroContinuo, nombreArchvioRegistroContinuo, pathDriveID, 'text/x-script.txt', pathArchivoRegistroContinuo)
# /////////////////////////////////////////////////////////////////////////////
