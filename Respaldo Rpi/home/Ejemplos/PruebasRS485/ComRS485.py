import serial
import binascii
import RPi.GPIO as GPIO
import time


#Funcion para realizar una peticion y obtener el dato de la trama de respuesta
#Parametros de entrada: pin EE del RS485, Id del esclavo, funcion, dato
#def Configurar(18, Id, Fcn, DatoP):


def Leer():

    # Configuracion del GPIO y el serial:
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(18, GPIO.OUT, initial=0)     #Establece el GPIO 18 como salida  (senal REDE)
    GPIO.setup(23, GPIO.OUT, initial=0)     #Establece el GPIO 23 como salida (senal luminosa)
    ser = serial.Serial("/dev/ttyAMA0", baudrate=9600, timeout=3.5)

    # Prepara los datos de la trama de peticion:
    GPIO.output(23,1)        # Encendido senal luminosa

    #Envia la trama de peticion:
    GPIO.output(18,1)        # Establece el max485 en modo de escritura
    #for x in  range(10):
    #   ser.write("*99A")        # Envia el comando para leer todos los dispositivos (broadcast)
    #   ser.write(chr(13))       # Envia el caracter de retorno de carro (hex 0D)
    #   time.sleep(2)
    comando = "*00P="
    print(comando)
    ser.write(comando)
    ser.write(chr(13))
    time.sleep(0.005)
#    ser.write("99WE")
#    ser.write(chr(13))
#    time.sleep(0.005)
    GPIO.output(18,0)        # Establece el max485 en modo de lectura
#    GPIO.output(23,0)        # Apagado senal luminosa
    time.sleep(0.1)

    #Recibe la trama de respuesta:
    Rspt = ser.read(9)      # Recibe 28 bytes de respuesta
    print(Rspt)

    GPIO.output(23,0)

    ser.flushInput()
    ser.flushOutput()
    GPIO.cleanup()
    ser.close()


