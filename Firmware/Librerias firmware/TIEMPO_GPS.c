//Libreria para el manejo del tiempo del GPS

/////////////////////////////////////////// Definicion de funciones ///////////////////////////////////////////

void GPS_init();
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);


///////////////////////////////////////////        Funciones        ///////////////////////////////////////////

//Funcion para configurar el GPS
void GPS_init(){
     /*
     UART1_Write_Text("$PMTK605*31\r\n");
     UART1_Write_Text("$PMTK220,1000*1F\r\n");
     UART1_Write_Text("$PMTK251,115200*1F\r\n");
     Delay_ms(1000);                                                            //Tiempo necesario para que se de efecto el cambio de configuracion
     UART1_Init(115200);
     UART1_Write_Text("$PMTK313,1*2E\r\n");
     UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
     UART1_Write_Text("$PMTK319,1*24\r\n");
     UART1_Write_Text("$PMTK413*34\r\n");
     UART1_Write_Text("$PMTK513,1*28\r\n");
     */

     // Con el codigo 220 establece la tasa de actualizacion del tiempo, en ms
     // En este caso cada segundo la interrupcion del UART y la actualizacion del
     // tiempo. El valor de 1F es el check sum, enlace para calcularlo
     // http://www.hhhh.org/wiml/proj/nmeaxor.html
     UART1_Write_Text("$PMTK220,1000*1F\r\n");
     Delay_ms(1000);
     // Configuracion del GPS, se habilita solamnte la trama RMC (Recommended
     // Minimun Specific GNSS Sentence), solo esta en 1, el resto en 0. Contiene
     // datos de hora, fecha, posicionamiento, entre otros.
     UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
     Delay_ms(1000);

     U1MODE.UARTEN = 0;                                                         //Desactiva el UART1
}
//* Estructura comandos PMTK: |Preamble ($)|Talker ID (PMTK)|Pkt Type,Data Field|*|Checksum (just an XOR of all the bytes between the $ and the *)|CR LF|
//**SBAS es un sistema de correccion de las senales que los Sistemas Globales de Navegacion por Satelite (GNSS) transmiten al receptor GPS del usuario.

//Funcion para tomar la fecha del GPS
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS){

     unsigned long tramaFecha[4];
     unsigned long fechaGPS;
     char datoStringF[3];
     char *ptrDatoStringF = &datoStringF;
     datoStringF[2] = '\0';
     tramaFecha[3] = '\0';

     //Anio
     datoStringF[0] = tramaDatosGPS[10];
     datoStringF[1] = tramaDatosGPS[11];
     tramaFecha[0] = atoi(ptrDatoStringF); 

     //Mes
     datoStringF[0] = tramaDatosGPS[8];
     datoStringF[1] = tramaDatosGPS[9];
     tramaFecha[1] = atoi(ptrDatoStringF);
	 
	 //Dia
     datoStringF[0] = tramaDatosGPS[6];
     datoStringF[1] = tramaDatosGPS[7];
     tramaFecha[2] =  atoi(ptrDatoStringF);

     fechaGPS = (tramaFecha[0]*10000)+(tramaFecha[1]*100)+(tramaFecha[2]);      //10000*aa + 100*mm + dd
     
     return fechaGPS;

}

//Funcion para tomar la hora del GPS
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS){

     unsigned long tramaTiempo[4];
     unsigned long horaGPS;
     char datoString[3];
     char *ptrDatoString = &datoString;
     datoString[2] = '\0';
     tramaTiempo[3] = '\0';

     //Horas
     datoString[0] = tramaDatosGPS[0];
     datoString[1] = tramaDatosGPS[1];
     tramaTiempo[0] = atoi(ptrDatoString);

     //Minutos
     datoString[0] = tramaDatosGPS[2];
     datoString[1] = tramaDatosGPS[3];
     tramaTiempo[1] = atoi(ptrDatoString);

     //Segundos
     datoString[0] = tramaDatosGPS[4];
     datoString[1] = tramaDatosGPS[5];
     tramaTiempo[2] = atoi(ptrDatoString);

     horaGPS = (tramaTiempo[0]*3600)+(tramaTiempo[1]*60)+(tramaTiempo[2]);      //Calcula el segundo actual = hh*3600 + mm*60 + ss
     return horaGPS;

}