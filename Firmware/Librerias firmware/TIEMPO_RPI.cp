#line 1 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/TIEMPO_RPI.c"
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rpi.h"




unsigned long RecuperarFechaRPI(unsigned char *tramaTiempoRpi);
unsigned long RecuperarHoraRPI(unsigned char *tramaTiempoRpi);
#line 8 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/TIEMPO_RPI.c"
unsigned long RecuperarFechaRPI(unsigned char *tramaTiempoRpi){

 unsigned long fechaRPi;

 fechaRPi = ((unsigned long)tramaTiempoRpi[0]*10000)+((unsigned long)tramaTiempoRpi[1]*100)+((unsigned long)tramaTiempoRpi[2]);

 return fechaRPi;

}


unsigned long RecuperarHoraRPI(unsigned char *tramaTiempoRpi){

 unsigned long horaRPi;

 horaRPi = ((unsigned long)tramaTiempoRpi[3]*3600)+((unsigned long)tramaTiempoRpi[4]*60)+((unsigned long)tramaTiempoRpi[5]);

 return horaRPi;

}
