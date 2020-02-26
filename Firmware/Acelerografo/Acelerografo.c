/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz, email: miltonrodrigomunoz@gmail.com
Fecha de creacion: 14/03/2019
Configuracion: dsPIC33EP256MC202, XT=80MHz
---------------------------------------------------------------------------------------------------------------------------*/

////////////////////////////////////////////////////         Librerias         /////////////////////////////////////////////////////////////

#include <ADXL355_SPI.c>
#include <TIEMPO_GPS.c>
#include <TIEMPO_RTC.c>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////

//Variables y contantes para la peticion y respuesta de datos
sbit RP1 at LATA4_bit;                                                          //Definicion del pin P1
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;                                                          //Definicion del pin P2
sbit RP2_Direction at TRISB4_bit;
sbit TEST at LATB12_bit;                                                        //Definicion del pin P2
sbit TEST_Direction at TRISB12_bit;

unsigned char tramaGPS[70];
unsigned char datosGPS[13];
unsigned short tiempo[6];                                                       //Vector de datos de tiempo del sistema
unsigned short tiempoRPI[6];                                                    //Vector para recuperar el tiempo enviado desde la RPi
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];                                                   //Vector para almacenar 27 muestras de 3 ejes del vector FIFO
unsigned char tramaCompleta[2506];                                              //Vector para almacenar 10 vectores datosFIFO, 250 cabeceras de muestras y el vector tiempo
unsigned char tramaSalida[2506];
unsigned short numFIFO, numSetsFIFO;                                            //Variablea para almacenar el numero de muestras y sets recuperados del buffer FIFO
unsigned short contTimer1;                                                      //Variable para contar el numero de veces que entra a la interrupcion por Timer 1

unsigned int i, x, y, i_gps, j;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;
unsigned int contFIFO;
short tasaMuestreo;
short numTMR1;

unsigned short banTC, banTI, banTF;                                             //Banderas de trama completa, inicio de trama y final de trama
unsigned short banLec, banEsc, banCiclo, banInicio, banSetReloj, banSetGPS;
unsigned short banMuestrear, banLeer, banConf;

unsigned char byteGPS, banTIGPS, banTFGPS, banTCGPS;
unsigned long horaSistema, fechaSistema;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////  Declaracion de funciones  /////////////////////////////////////////////////////////
void ConfiguracionPrincipal();
void Muestrear();
void ConfigurarGPS();
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi);
unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi);
void AjustarTiempoSistema(unsigned long hGPS, unsigned long fGPS, unsigned char *tramaTiempoSistema);
void InterrupcionP2();
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////      Main      ////////////////////////////////////////////////////////////////
void main() {

     ConfiguracionPrincipal();
     ConfigurarGPS();
     Delay_ms(1000);
     //DS3234_init();
     
     tasaMuestreo = 1;                                                          //1=250Hz, 2=125Hz, 4=62.5Hz, 8=31.25Hz
     ADXL355_init(tasaMuestreo);                                                //Inicializa el modulo ADXL con la tasa de muestreo requerida:
     numTMR1 = (tasaMuestreo*10)-1;                                             //Calcula el numero de veces que tienen que desbordarse el TMR1 para cada tasa de muestreo
     
     banTI = 0;
     banLec = 0;
     banEsc = 0;
     banCiclo = 0;
     banSetReloj = 0;
     banSetGPS = 0;
     banTIGPS = 0;
     banTFGPS = 0;
     banTCGPS = 0;

     banMuestrear = 0;                                                          //Inicia el programa con esta bandera en bajo para permitir que la RPi envie la peticion de inicio de muestreo
     banInicio = 0;                                                             //Bandera de inicio de muestreo
     banLeer = 0;
     banConf = 0;

     i = 0;
     x = 0;
     y = 0;
     i_gps = 0;
     horaSistema = 0;

     contMuestras = 0;
     contCiclos = 0;
     contFIFO = 0;
     numFIFO = 0;
     numSetsFIFO = 0;
     contTimer1 = 0;

     byteGPS = 0;

     RP1 = 0;
     RP2 = 0;
     TEST = 1;

     SPI1BUF = 0x00;

     while(1){

     }

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la configuracion principal
void ConfiguracionPrincipal(){
     
     //configuracion del oscilador                                              //FPLLO = FIN*(M/(N1+N2)) = 80.017MHz
     CLKDIVbits.FRCDIV = 0;                                                     //FIN=FRC/1
     CLKDIVbits.PLLPOST = 0;                                                    //N2=2
     CLKDIVbits.PLLPRE = 5;                                                     //N1=7
     PLLFBDbits.PLLDIV = 150;                                                   //M=152
     
     //Configuracion de puertos
     ANSELA = 0;                                                                //Configura PORTA como digital     *
     ANSELB = 0;                                                                //Configura PORTB como digital     *
     TRISA2_bit = 0;                                                            //Configura el pin A2 como salida  *
     TRISA3_bit = 0;                                                            //Configura el pin A3 como salida  *
     TRISA4_bit = 0;                                                            //Configura el pin A4 como salida  *
     TRISB4_bit = 0;                                                            //Configura el pin B4 como salida  *
     TRISB12_bit = 0;                                                           //Configura el pin B12 como salida *
     
     TRISB10_bit = 1;                                                           //Configura el pin B10 como entrada *
     TRISB11_bit = 1;                                                           //Configura el pin B11 como entrada *
     TRISB13_bit = 1;                                                           //Configura el pin B13 como entrada *
     TRISB14_bit = 1;
     TRISB15_bit = 1;                                                           //Configura el pin B15 como entrada *
     
     INTCON2.GIE = 1;                                                           //Habilita las interrupciones globales *
     
     //Configuracion del puerto UART1
     RPINR18bits.U1RXR = 0x22;                                                  //Configura el pin RB2/RPI34 como Rx1 *
     RPOR0bits.RP35R = 0x01;                                                    //Configura el Tx1 en el pin RB3/RP35 *
     UART1_Init(9600);                                                          //Inicializa el UART1 con una velocidad de 9600 baudios
     U1RXIE_bit = 0;                                                            //Desabilita la interrupcion por UART1 RX *
     U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion por UART1 RX *
     IPC2bits.U1RXIP = 0x04;                                                    //Prioridad de la interrupcion UART1 RX
     U1STAbits.URXISEL = 0x00;

     //Configuracion del puerto SPI1 en modo Esclavo
     SPI1STAT.SPIEN = 1;                                                        //Habilita el SPI1 *
     SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
     SPI1IE_bit = 1;                                                            //Habilita la interrupcion por SPI1  *
     SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI *
     IPC2bits.SPI1IP = 0x03;                                                    //Prioridad de la interrupcion SPI1
     
     //Configuracion del puerto SPI2 en modo Master
     RPINR22bits.SDI2R = 0x21;                                                  //Configura el pin RB1/RPI33 como SDI2 *
     RPOR2bits.RP38R = 0x08;                                                    //Configura el SDO2 en el pin RB6/RP38 *
     RPOR1bits.RP37R = 0x09;                                                    //Configura el SCK2 en el pin RB5/RP37 *
     SPI2STAT.SPIEN = 1;                                                        //Habilita el SPI2 *
     SPI2_Init();                                                               //Inicializa el modulo SPI2
     CS_DS3234 = 1;                                                             //Pone en alto el CS del RTC
     CS_ADXL355 = 1;                                                            //Pone en alto el CS del acelerometro
     
     //Configuracion del acelerometro
     ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                           //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO

     //Configuracion de la interrupcion externa INT1
     //RPINR0 = 0x2E00;                                                           //Asigna INT1 al RB14/RPI46 (PPS)
     RPINR0 = 0x2F00;                                                           //Asigna INT1 al RB15/RPI47 (SQW)
     INT1IE_bit = 0;                                                            //Habilita la interrupcion externa INT1
     INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
     IPC5bits.INT1IP = 0x01;                                                    //Prioridad en la interrupocion externa 1

     //Configuracion del TMR1 con un tiempo de 100ms
     T1CON = 0x0020;
     T1CON.TON = 0;                                                             //Apaga el Timer1
     T1IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR1
     T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR1
     PR1 = 62500;                                                               //Car ga el preload para un tiempo de 100ms
     IPC0bits.T1IP = 0x02;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1

     Delay_ms(200);                                                             //Espera hasta que se estabilicen los cambios

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para relizar el muesteo
void Muestrear(){

     if (banCiclo==0){

         ADXL355_write_byte(POWER_CTL, DRDY_OFF|MEASURING);                     //Coloca el ADXL en modo medicion
         T1CON.TON = 1;                                                         //Enciende el Timer1

     } else if (banCiclo==1) {

         banCiclo = 2;                                                          //Limpia la bandera de ciclo completo

         tramaCompleta[0] = contCiclos;                                         //LLena el primer elemento de la tramaCompleta con el contador de ciclos
         numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
         numSetsFIFO = (numFIFO)/3;                                             //Lee el numero de sets disponibles en el FIFO

         //Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
         for (x=0;x<numSetsFIFO;x++){
             ADXL355_read_FIFO(datosLeidos);                                    //Lee una sola posicion del FIFO
             for (y=0;y<9;y++){
                 datosFIFO[y+(x*9)] = datosLeidos[y];                           //LLena la trama datosFIFO
             }
         }

         //Este bucle rellena la trama completa intercalando el numero de muestra correspondientes
         for (x=0;x<(numSetsFIFO*9);x++){
             if ((x==0)||(x%9==0)){
                tramaCompleta[contFIFO+contMuestras+x] = contMuestras;          //Funciona bien
                tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
                contMuestras++;
             } else {
                tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
             }
         }

         //LLena la trama tiempo con el valor del tiempo actual del sistema y luega rellena la tramaCompleta con los valores de esta trama
         AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
         for (x=0;x<6;x++){
             tramaCompleta[2500+x] = tiempo[x];
         }

         contMuestras = 0;                                                      //Limpia el contador de muestras
         contFIFO = 0;                                                          //Limpia el contador de FIFOs
         T1CON.TON = 1;                                                         //Enciende el Timer1
         
         banLec = 1;                                                            //Activa la bandera de lectura para enviar la trama
         RP1 = 1;                                                               //Genera el pulso P1 para producir la interrupcion en la RPi
         Delay_us(20);
         RP1 = 0;

     }

     contCiclos++;                                                              //Incrementa el contador de ciclos

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para realizar la interrupcion en la RPi
 void InterrupcionP2(){
     //Habilita la interrupcion INT1 para incrementar la hora del sistema con cada pulso PPS
     if (INT1IE_bit==0){
        INT1IE_bit = 1;
     }
     //Genera el pulso P2 para producir la interrupcion externa en la RPi
     RP2 = 1;
     Delay_us(20);
     RP2 = 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones /////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion SPI1
void spi_1() org  IVT_ADDR_SPI1INTERRUPT {

     SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI
     buffer = SPI1BUF;                                                          //Guarda el contenido del bufeer (lectura)

     //Rutina para inicio del muestreo
     if (banMuestrear==0){
        if (buffer==0xA0){
           banMuestrear = 1;                                                    //Cambia el estado de la bandera para que no inicie el muestreo mas de una vez de manera consecutiva
           //ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                     //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
           banCiclo = 0;
           contMuestras = 0;
           contCiclos = 0;
           contFIFO = 0;
           numFIFO = 0;
           numSetsFIFO = 0;
           contTimer1 = 0;
           banInicio = 1;                                                       //Bandera que permite el inicio del muestreo dentro de la interrupcion INT1
           if (INT1IE_bit==0){
              INT1IE_bit = 1;
           }
        }
     }
     
     //Rutina para detener el muestreo
     if (banMuestrear==1){
        if (buffer==0xAF){
           banInicio = 0;                                                       //Bandera que permite el inicio del muestreo dentro de la interrupcion INT1
           banMuestrear = 0;                                                    //Cambia el estado de la bandera para permitir que inicie el muestreo de nuevo en el futuro
           ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                     //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
           //Desabilita la interrupcion INT1 si esta habilitada:
           if (INT1IE_bit==1){
              INT1IE_bit = 0;
           }
           //Desabilita la interrupcion TMR1 si esta habilitada:
           if (T1CON.TON==1){
              T1CON.TON = 0;
           }
        }
     }

     //**************************************************************************************************************************************************
     //Rutina para obtener la hora del GPS
     if ((banSetReloj==0)){
        if (buffer==0xC0){
           banTIGPS = 0;                                                        //Limpia la bandera de inicio de trama  del GPS
           banTCGPS = 0;                                                        //Limpia la bandera de trama completa
           i_gps = 0;                                                           //Limpia el subindice de la trama GPS
           //Habilita interrupcion por UART1Rx si esta desabilitada:
           if (U1RXIE_bit==0){
              U1RXIE_bit = 1;
           }
        }
     }
     
     //Rutina para obtener la hora del RTC
     if ((banSetReloj==0)&&(buffer==0xA8)){
        horaSistema = RecuperarHoraRTC();                                       //Recupera la hora del RTC
        fechaSistema = RecuperarFechaRTC();                                     //Recupera la fecha del RTC
        AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);                //Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
        banEsc = 0;
        banSetReloj = 1;
        InterrupcionP2();
     }
     
     //Rutina para obtener la hora de la RPi
     if ((banSetReloj==0)&&(buffer==0xC3)){                                     //**Segun esto solo puedo igualar el reloj una sola vez al encender o reiniciar el dsPIC
         banEsc = 1;
         j = 0;
     }
     if ((banEsc==1)&&(buffer!=0xC3)&&(buffer!=0xC4)){
        tiempoRPI[j] = buffer;
        j++;
     }
     if ((banEsc==1)&&(buffer==0xC4)){
        //horaSistema = RecuperarHoraRPI(tiempoRPI);                              //Recupera la hora de la RPi
        //fechaSistema = RecuperarFechaRPI(tiempoRPI);                            //Recupera la fecha de la RPi
        DS3234_init();                                                          //inicializa el RTC
        //DS3234_setDate(horaSistema, fechaSistema);                              //Configura la hora en el RTC con la hora recuperada de la RPi
        horaSistema = RecuperarHoraRTC();                                       //Recupera la hora del RTC
        fechaSistema = RecuperarFechaRTC();                                     //Recupera la fecha del RTC
        AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);                //Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
        banEsc = 0;
        banSetReloj = 1;
        InterrupcionP2();
     }
     
     //Rutina para enviar la hora local a la RPi
     if (banSetReloj==1){
        banSetReloj = 2;
        j = 0;
        SPI1BUF = tiempo[j];
     }
     if ((banSetReloj==2)&&(buffer!=0xC1)){
        SPI1BUF = tiempo[j];
        j++;
     }
     if ((banSetReloj==2)&&(buffer==0xC1)){                                     //Si detecta el delimitador de final de trama:
        banSetReloj = 0;                                                        //Limpia la bandera de lectura
        SPI1BUF = 0xFF;
     }
     //**************************************************************************************************************************************************
     
     //Rutina de lectura de los datos del acelerometro
     if ((banLec==1)&&(buffer==0xB0)){                                          //Verifica si la bandera de inicio de trama esta activa
        banLec = 2;                                                             //Activa la bandera de lectura
        i = 0;
        SPI1BUF = tramaCompleta[i];
     }
     if ((banLec==2)&&(buffer!=0xB1)){
        SPI1BUF = tramaCompleta[i];
        i++;
     }
     if ((banLec==2)&&(buffer==0xB1)){                                          //Si detecta el delimitador de final de trama:
        banLec = 0;                                                             //Limpia la bandera de lectura
        SPI1BUF = 0xFF;
     }
     
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion INT1
void int_1() org IVT_ADDR_INT1INTERRUPT {
     
     INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
     
     TEST = ~TEST;
     horaSistema++;                                                             //Incrementa el reloj del sistema

     if (horaSistema==86400){                                                   //(24*3600)+(0*60)+(0) = 86400
        horaSistema = 0;                                                        //Reinicia el reloj al llegar a las 24:00:00 horas
     }
     
     if (banInicio==1){
        Muestrear();
     }
     
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion por desbordamiento del Timer1
void Timer1Int() org IVT_ADDR_T1INTERRUPT{
     
     T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion por desbordamiento del Timer1
     
     numFIFO = ADXL355_read_byte(FIFO_ENTRIES); //75                            //Lee el numero de muestras disponibles en el FIFO
     numSetsFIFO = (numFIFO)/3;                 //25                            //Lee el numero de sets disponibles en el FIFO

     //Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
     for (x=0;x<numSetsFIFO;x++){
         ADXL355_read_FIFO(datosLeidos);                                        //Lee una sola posicion del FIFO
         for (y=0;y<9;y++){
             datosFIFO[y+(x*9)] = datosLeidos[y];                               //LLena la trama datosFIFO
         }
     }
     
     //Este bucle rellena la trama completa intercalando el numero de muestra correspondientes
     for (x=0;x<(numSetsFIFO*9);x++){      //0-224
         if ((x==0)||(x%9==0)){
            tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
            tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
            contMuestras++;
         } else {
            tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
         }
     }

     contFIFO = (contMuestras*9);                                               //Incrementa el contador de FIFOs

     contTimer1++;                                                              //Incrementa una unidad cada vez que entra a la interrupcion por Timer1
     
     if (contTimer1==numTMR1){                                                  //Verifica si se cumplio el numero de interrupciones por TMR1 para la tasa de muestreo seleccionada
        T1CON.TON = 0;                                                          //Apaga el Timer1
        banCiclo = 1;                                                           //Activa la bandera que indica que se completo un ciclo de medicion
        contTimer1 = 0;                                                         //Limpia el contador de interrupciones por Timer1
     }

}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
