/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz, email: miltonrodrigomunoz@gmail.com
Fecha de creacion: 14/03/2019
Configuracion: dsPIC33EP256MC202, XT=80MHz
---------------------------------------------------------------------------------------------------------------------------*/

////////////////////////////////////////////////////         Librerias         /////////////////////////////////////////////////////////////

#include <ADXL355_SPI.c>
#include <TIEMPO_GPS.c>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////

//Variables y contantes para la peticion y respuesta de datos
sbit RP1 at LATA4_bit;                                                          //Definicion del pin P1
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;                                                          //Definicion del pin P2
sbit RP2_Direction at TRISB4_bit;

const short HDR = 0x3A;                                                         //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                                        //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                                        //Constante de delimitador 2 de final de trama
const unsigned short NUM_MUESTRAS = 199;                                        //Constantes para almacenar el numero de muestras que se van a enviar en la interrupcion P2
//const unsigned int T2 = 222;

unsigned char tramaGPS[70];
unsigned char datosGPS[13];
unsigned char tiempo[6];                                                        //Vector para almacenar los datos de la cabecera
unsigned char pduSPI[15];                                                       //Vector de trama de datos del puerto UART2
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];                                                   //Vector para almacenar 27 muestras de 3 ejes del vector FIFO
unsigned char tramaCompleta[2506];                                              //Vector para almacenar 10 vectores datosFIFO, 250 cabeceras de muestras y el vector tiempo
unsigned short numFIFO, numSetsFIFO;                                            //Variablea para almacenar el numero de muestras y sets recuperados del buffer FIFO
unsigned short contTimer1;                                                      //Variable para contar el numero de veces que entra a la interrupcion por Timer 1

unsigned int i, x, y, i_gps;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;
unsigned int contFIFO;

unsigned short banTC, banTI, banTF;                                             //Banderas de trama completa, inicio de trama y final de trama
unsigned short banResp, banSPI, banLec, banEsc, banCiclo, banInicio, banSetReloj, banSetGPS;
unsigned short banMuestrear, banLeer, banConf;

long datox, datoy, datoz, auxiliar;
unsigned char *puntero_8, direccion;

unsigned char byteGPS, banTIGPS, banTFGPS, banTCGPS;
unsigned short tiempoDeAjuste[2] = {10, 0};                                     //Hora a la que se desea igualar el reloj RTC{hh, mm}
unsigned long tiempoSistema, fechaSistema, segundoDeAjuste;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////  Declaracion de funciones  /////////////////////////////////////////////////////////
void ConfiguracionPrincipal();
void Muestrear();
void ConfigurarGPS();
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
void AjustarTiempoSistema(unsigned long hGPS, unsigned long fGPS, unsigned char *tramaTiempoSistema);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////      Main      ////////////////////////////////////////////////////////////////
void main() {

     ConfiguracionPrincipal();
     ConfigurarGPS();

     tiempo[0] = 12;                                                            //Hora
     tiempo[1] = 12;                                                            //Minuto
     tiempo[2] = 12;                                                            //Segundo
     tiempo[3] = 12;                                                            //Dia
     tiempo[4] = 12;                                                            //Mes
     tiempo[5] = 19;                                                            //Año

     banTI = 0;
     banLec = 0;
     banCiclo = 0;
     banSetReloj = 0;
     banSetGPS = 0;
     banTIGPS = 0;
     banTFGPS = 0;
     banTCGPS = 0;

     banMuestrear = 0;
     banLeer = 0;
     banConf = 0;

     i = 0;
     x = 0;
     y = 0;
     i_gps = 0;
     tiempoSistema = 0;
     fechaSistema = 190101;
     segundoDeAjuste = (3600*tiempoDeAjuste[0]) + (60*tiempoDeAjuste[1]);       //Calcula el segundo en el que se efectuara el ajuste de hora = hh*3600 + mm*60

     contMuestras = 0;
     contCiclos = 0;
     contFIFO = 0;
     numFIFO = 0;
     numSetsFIFO = 0;
     contTimer1 = 0;

     byteGPS = 0;

     RP1 = 0;
     RP2 = 0;

     puntero_8 = &auxiliar;

     SPI1BUF = 0x00;

     banInicio = 1;
     U1RXIE_bit = 1;                                                            //Habilita la interrupcion por UARTRx
     INT1IE_bit = 1;

     while(1){

              Delay_ms(500);

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
     TRISA3_bit = 0;                                                            //Configura el pin A3 como salida  *
     TRISA4_bit = 0;                                                            //Configura el pin A4 como salida  *
     TRISB4_bit = 0;                                                            //Configura el pin B4 como salida  *
     TRISB10_bit = 1;                                                           //Configura el pin B10 como entrada *
     TRISB11_bit = 1;                                                           //Configura el pin B11 como entrada *
     TRISB12_bit = 1;                                                           //Configura el pin B12 como entrada *
     TRISB13_bit = 1;                                                           //Configura el pin B13 como entrada *

     INTCON2.GIE = 1;                                                           //Habilita las interrupciones globales *
     
     //Configuracion del puerto UART1
     RPINR18bits.U1RXR = 0x22;                                                  //Configura el pin RB2/RPI34 como Rx1 *
     RPOR0bits.RP35R = 0x01;                                                    //Configura el Tx1 en el pin RB3/RP35 *
     UART1_Init(9600);                                                          //Inicializa el UART1 con una velocidad de 9600 baudios
     U1RXIE_bit = 1;                                                            //Habilita la interrupcion por UART1 RX *
     U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion por UART1 RX *
     IPC2bits.U1RXIP = 0x04;                                                    //Prioridad de la interrupcion UART1 RX

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

     //Configuracion de la interrupcion externa INT1
     RPINR0 = 0x2E00;                                                           //Asigna INT1 al RB14/RPI46
     INT1IE_bit = 1;                                                            //Habilita la interrupcion externa INT1
     INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
     IPC5bits.INT1IP = 0x01;                                                    //Prioridad en la interrupocion externa 1

     //Configuracion del TMR1 con un tiempo de 100ms
     T1CON = 0x0020;
     T1CON.TON = 0;                                                             //Apaga el Timer1
     T1IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR1
     T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR1
     PR1 = 62500;                                                               //Car ga el preload para un tiempo de 100ms
     IPC0bits.T1IP = 0x02;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
     
     //Configuracion del TMR2 con un tiempo de 75ms
     T2CON = 0x0020;
     T2CON.TON = 0;                                                             //Apaga el Timer2
     T2IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR2
     T2IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR2
     PR2 = 46875;                                                               //Carga el preload para un tiempo de 75ms
     IPC1bits.T2IP = 0x05;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
     
     ADXL355_init();
     
     Delay_ms(200);                                                             //Espera hasta que se estabilicen los cambios

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para relizar el muesteo
void Muestrear(){

     if (banCiclo==0){

         ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                       //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO

     } else {

         banCiclo = 0;                                                          //Limpia la bandera de ciclo completo

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
                tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
                tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
                contMuestras++;
             } else {
                tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
             }
         }

         //LLena la trama tiempo con el valor del tiempo actual del sistema y luega rellena la tramaCompleta con los valores de esta trama
         AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
         for (x=0;x<6;x++){
             tramaCompleta[2500+x] = tiempo[x];
         }

         banTI = 1;                                                             //Activa la bandera de inicio de trama para permitir el envio de la trama por SPI
         RP1 = 1;                                                               //Genera el pulso P1 para producir la interrupcion en la RPi
         Delay_us(20);
         RP1 = 0;

     }

     contCiclos++;                                                              //Incrementa el contador de ciclos
     contMuestras = 0;                                                          //Limpia el contador de muestras
     contFIFO = 0;                                                              //Limpia el contador de FIFOs

     if (ADXL355_read_byte(POWER_CTL)&0x01==1){
        ADXL355_write_byte(POWER_CTL, DRDY_OFF|MEASURING);                      //Coloca el ADXL en modo medicion
     }

     T1CON.TON = 1;                                                             //Enciende el Timer1

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones /////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion SPI1
void spi_1() org  IVT_ADDR_SPI1INTERRUPT {

     SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI
     buffer = SPI1BUF;                                                          //Guarda el contenido del bufeer (lectura)

    /*//////////////// Rutina para iniciar el muestreo ////////////////
     if ((buffer==0xA0)&&(banMuestrear==0)){
        banInicio = 2;

     }

     //////////////// Rutina para Lectura ////////////////
     if ((buffer==0xB0)&&(banLeer==0)){
        banLeer = 1;
        i = 0;
     }
     if ((banLeer==1)&&(buffer!=0xB0)&&(buffer!=0xBF)){
        SPI1BUF = tiempo[i];
        i++;
     }
     if ((banLeer==1)&&(buffer==0xBF)){
        banLeer = 0;
     }

     //////////////// Rutina de Configuracion ////////////////
     if ((buffer==0xC0)&&(banConf==0)){

     }*/

     //Rutina para procesar la trama de solicitud de lectura desde la RPi
     if ((banTI==1)){                                                           //Verifica si la bandera de inicio de trama esta activa
        banLec = 1;                                                             //Activa la bandera de lectura
        banTI = 0;
        i = 0;
        SPI1BUF = tramaCompleta[i];
     }
     if ((banLec==1)&&(buffer!=0xB1)){
        SPI1BUF = tramaCompleta[i];
        i++;
     }
     if ((banLec==1)&&(buffer==0xB1)){                                          //Si detecta el delimitador de final de trama:
        banLec = 0;                                                             //Limpia la bandera de lectura
        banTI = 0;
        SPI1BUF = 0xFF;
     }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion INT1
void int_1() org IVT_ADDR_INT1INTERRUPT {
     
     INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
     
     /*AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
     RP1 = 1;                                                           //Genera el pulso P1 para producir la interrupcion en la RPi
     Delay_us(20);
     RP1 = 0;

     if (tiempoSistema==segundoDeAjuste){
        U1RXIE_bit = 1;                                                         //Enciende la interrupcion por UARTRx para igualar el tiempo del sistema con el GPS
     } else {
        tiempoSistema++;                                                        //Si el reloj esta igualado incrementa la cuenta del segundo
     }*/
        
     //Con esto se asegura que el proceso comience cuando se haya completado la configuracion inicial
     //Esta bandera tambien me puede servir para iniciar el sistema mediante comandos enviados desde la RPi por SPI
     

     
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
     //En cada interrupcion debe haber 25 sets de mediciones +-1
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
     
     if (contTimer1==9){                                                        //Verifica si se recibio los 5 FIFOS
        T1CON.TON = 0;                                                          //Apaga el Timer1
        banCiclo = 1;                                                           //Activa la bandera que indica que se completo un ciclo de medicion
        contTimer1 = 0;                                                         //Limpia el contador de interrupciones por Timer1
     }
     


}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion por desbordamiento del Timer2
void Timer2Int() org IVT_ADDR_T2INTERRUPT{

     T2IF_bit = 0;
     
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Interrupcion UART1
void urx_1() org  IVT_ADDR_U1RXINTERRUPT {

     U1RXIF_bit = 0;
     byteGPS = UART1_Read();                                                    //Lee el byte de la trama enviada por el GPS

     if (banTIGPS==0){
        if ((byteGPS==0x24)&&(i_gps==0)){                                       //Verifica si el primer byte recibido es el simbolo "$" que indica el inicio de una trama GPS
           banTIGPS = 1;                                                        //Activa la bandera de inicio de trama
           i_gps = 0;                                                           //Limpia el subindice de la trama GPS
        }
     }

     if (banTIGPS==1){
        if (byteGPS!=0x2A){                                                     //0x2A = "*"
           tramaGPS[i_gps] = byteGPS;                                           //LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
           banTFGPS = 0;                                                        //Limpia la bandera de final de trama
           if (i_gps<70){
              i_gps++;                                                          //Incrementa el valor del subindice mientras sea menor a 70
           }
           if ((i_gps>1)&&(tramaGPS[1]!=0x47)){                                 //Verifica si el segundo elemento guardado es diferente de G
              i_gps = 0;                                                        //Limpia el subindice para almacenar la trama desde el principio
              banTIGPS = 0;                                                     //Limpia la bandera de inicio de trama
              banTCGPS = 0;                                                     //Limpia la bandera de trama completa
           }
        } else {
           tramaGPS[i_gps] = byteGPS;
           banTFGPS = 1;                                                        //Activa la bandera de final de trama GPS
        }
        if (banTFGPS==1){
           banTIGPS = 0;                                                        //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
           banTCGPS = 1;                                                        //Activa la bandera de trama completa
        }
     }

     if (banTCGPS==1){
        if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){      //"GPRMC" y "A"
           for (x=0;x<6;x++){
               datosGPS[x] = tramaGPS[7+x];                                     //Guarda los datos de hhmmss
           }
           for (x=50;x<60;x++){
               if (tramaGPS[x]==0x2C){                                          //Busca el simbolo "," a partir de la posicion 50
                   for (y=0;y<6;y++){
                       datosGPS[6+y] = tramaGPS[x+y+1];                         //Guarda los datos de DDMMAA en la trama datosGPS
                   }
               }
           }
           banSetGPS = 1;                                                       //Activa esta bandera si se logro recuperar la hora del GPS;
           
           datosGPS[0] = '1';
           datosGPS[1] = '7';
           datosGPS[2] = '2';
           datosGPS[3] = '4';
           datosGPS[4] = '0';
           datosGPS[5] = '0';
           
           datosGPS[6] = '2';
           datosGPS[7] = '6';
           datosGPS[8] = '0';
           datosGPS[9] = '6';
           datosGPS[10] = '1';
           datosGPS[11] = '9';
           datosGPS[12] = '\0';
           
           tiempoSistema = RecuperarFechaGPS(datosGPS);
           fechaSistema = RecuperarFechaGPS(datosGPS);
           
           /*tiempoSistema = 63960;
           fechaSistema = 250619;*/
           
           U1RXIE_bit = 0;                                                      //Apaga la interrupcion por UARTRx
          /*if (INT1IE_bit==0){
              INT1IE_bit = 1;                                                   //Habilita la interrupcion externa INT1 solo despues de que ha recuperado la hora del GPS
           }*/
        }
        i_gps = 0;                                                              //Limpia el subindice para almacenar la trama desde el principio
        banTIGPS = 0;                                                           //Limpia la bandera de inicio de trama
        banTCGPS = 0;                                                           //Limpia la bandera de trama completa
     }

}