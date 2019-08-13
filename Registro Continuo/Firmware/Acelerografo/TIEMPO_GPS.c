//Funciones para el manejo del GPS

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para configurar el GPS
void ConfigurarGPS(){
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
     Delay_ms(1000);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para tomar la fecha del GPS
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS){

     unsigned int tramaFecha[4];
     unsigned long fechaGPS;
     char datoStringF[3];
     char *ptrDatoStringF = &datoStringF;
     datoStringF[2] = '\0';
     tramaFecha[3] = '\0';

      //Dia
     /*datoStringF[0] = tramaDatosGPS[6];
     datoStringF[1] = tramaDatosGPS[7];*/
     datoStringF[0] = '1';
     datoStringF[1] = '7';
     /*tramaFecha[0] =  atoi(ptrDatoStringF);*/
     tramaFecha[0] =  17;

     //Mes
     /*datoStringF[0] = tramaDatosGPS[8];
     datoStringF[1] = tramaDatosGPS[9];*/
     datoStringF[0] = '0';
     datoStringF[1] = '6';
    /*tramaFecha[1] = atoi(ptrDatoStringF);*/
     tramaFecha[1] = 6;

     //Año
     /*datoStringF[0] = tramaDatosGPS[10];
     datoStringF[1] = tramaDatosGPS[11];*/
     datoStringF[0] = '1';
     datoStringF[1] = '9';
     //tramaFecha[2] = atoi(ptrDatoStringF);
     tramaFecha[2] = 0;

     //fechaGPS = (tramaFecha[0]*10000)+(tramaFecha[1]*100)+(tramaFecha[2]);    //10000*dd + 100*mm + aa
     fechaGPS = (tramaFecha[0]*3600)+(tramaFecha[1]*60)+(tramaFecha[2]);

     return fechaGPS;

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para tomar la hora del GPS
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS){

     unsigned int tramaTiempo[4];
     unsigned long horaGPS;
     char datoString[3];
     char *ptrDatoString = &datoString;
     datoString[2] = '\0';
     tramaTiempo[3] = '\0';

     //Horas
     datoString[0] = tramaDatosGPS[0];
     datoString[1] = tramaDatosGPS[1];
     datoString[0] = '1';
     datoString[1] = '0';
     //tramaTiempo[0] = atoi(ptrDatoString);
     tramaTiempo[0] = atoi("10");

     //Minutos
    datoString[0] = tramaDatosGPS[2];
     datoString[1] = tramaDatosGPS[3];
     datoString[0] = '4';
     datoString[1] = '5';
     //tramaTiempo[1] = atoi(ptrDatoString);
     tramaTiempo[1] = atoi("45");

     //Segundos
     datoString[0] = tramaDatosGPS[4];
     datoString[1] = tramaDatosGPS[5];
     datoString[0] = '1';
     datoString[1] = '1';
     //tramaTiempo[2] = atoi(ptrDatoString);
     tramaTiempo[2] = atoi("11");

     horaGPS = (tramaTiempo[0]*3600)+(tramaTiempo[1]*60)+(tramaTiempo[2]);      //Calcula el segundo actual = hh*3600 + mm*60 + ss
     return horaGPS;

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para ajustar la hora y la fecha del sistema
void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema){

     unsigned char hora;
     unsigned char minuto;
     unsigned char segundo;
     unsigned char dia;
     unsigned char mes;
     unsigned char anio;

     hora = longHora / 3600;
     minuto = (longHora%3600) / 60;
     segundo = (longHora%3600) % 60;

     dia = longFecha / 10000;
     mes = (longFecha%10000) / 100;
     anio = (longFecha%10000) % 100;

     tramaTiempoSistema[0] = hora;
     tramaTiempoSistema[1] = minuto;
     tramaTiempoSistema[2] = segundo;
     tramaTiempoSistema[3] = dia;
     tramaTiempoSistema[4] = mes;
     tramaTiempoSistema[5] = anio;

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////