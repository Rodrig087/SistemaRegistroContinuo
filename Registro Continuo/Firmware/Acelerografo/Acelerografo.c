/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz, email: miltonrodrigomunoz@gmail.com
Fecha de creacion: 14/03/2019
Configuracion: dsPIC33EP256MC202, XT=80MHz
---------------------------------------------------------------------------------------------------------------------------*/

////////////////////////////////////////////////////         Librerias         /////////////////////////////////////////////////////////////

#include <ADXL355_SPI.c>

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

unsigned char tiempo[5];                                                        //Vector para almacenar los datos de la cabecera
unsigned char pduSPI[15];                                                       //Vector de trama de datos del puerto UART2
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosLeidos2[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];                                                   //Vector para almacenar 27 muestras de 3 ejes del vector FIFO
unsigned char tramaCompleta[2505];                                              //Vector para almacenar 10 vectores datosFIFO, 250 cabeceras de muestras y el vector tiempo
unsigned short numFIFO, numSetsFIFO;                                            //Variablea para almacenar el numero de muestras y sets recuperados del buffer FIFO
unsigned short contTimer1;                                                      //Variable para contar el numero de veces que entra a la interrupcion por Timer 1

unsigned int i, x, y;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;
unsigned int contFIFO;

unsigned short banTC, banTI, banTF;                                             //Banderas de trama completa, inicio de trama y final de trama
unsigned short  banResp, banSPI, banLec, banEsc, banCiclo, banInicio;


long datox, datoy, datoz, auxiliar;
unsigned char *puntero_8, direccion;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
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
     
     //Configuracion del puerto UART
     //RPINR18 = 0x0022;                                                        //Configura el pin RB2/RPI34 como Rx1 *
     //RPOR0.RP35R = 0x0100;                                                    //Configura el Tx1 en el pin RB3/RP35 *

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
     T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR2
     PR1 = 62500;                                                               //Carga el preload para un tiempo de 100ms
     IPC0bits.T1IP = 0x02;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
     
     ADXL355_init();
     
     Delay_ms(100);                                                             //Espera hasta que se estabilicen los cambios

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////

//Interrupcion INT1
void int_1() org IVT_ADDR_INT1INTERRUPT {
     
     INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
     
     //Con esto se asegura que el proceso comience cuando se haya completado la configuracion inicial
     //Esta bandera tambien me puede servir para iniciar el sistema mediante comandos enviados desde la RPi por SPI
     if (banInicio==1){
     
         if (banCiclo==0){

             ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                   //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO

         } else {

             banCiclo = 0;                                                      //Limpia la bandera de ciclo completo

             tramaCompleta[0] = contCiclos;                                     //LLena el primer elemento de la tramaCompleta con el contador de ciclos
             //ADXL355_read_byte(Status);
             numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
            //numFIFO = 75;
             numSetsFIFO = (numFIFO)/3;                                         //Lee el numero de sets disponibles en el FIFO
             
             //Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
             for (x=0;x<numSetsFIFO;x++){
                 ADXL355_read_FIFO(datosLeidos);                               //Lee una sola posicion del FIFO
                 for (y=0;y<9;y++){
                     datosFIFO[y+(x*9)] = datosLeidos[y];                       //LLena la trama datosFIFO
                 }
             }
             
             //ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                   //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
             
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
             
             //Este bucle llena los 5 ultimos elementos de la tramaCompleta con los elementos de la trama tiempo
             for (x=0;x<5;x++){
                 tramaCompleta[2500+x] = tiempo[x];
             }
             
             banTI = 1;                                                         //Activa la bandera de inicio de trama para permitir el envio de la trama por SPI
             RP1 = 1;                                                           //Genera el pulso P1 para producir la interrupcion en la RPi
             Delay_us(20);
             RP1 = 0;

         }
         
         contCiclos++;                                                          //Incrementa el contador de ciclos
         contMuestras = 0;                                                      //Limpia el contador de muestras
         contFIFO = 0;                                                          //Limpia el contador de FIFOs
         
         if (ADXL355_read_byte(POWER_CTL)&0x01==1){
            ADXL355_write_byte(POWER_CTL, DRDY_OFF|MEASURING);                  //Coloca el ADXL en modo medicion
         }
         
         T1CON.TON = 1;                                                         //Enciende el Timer1

     
     }
     
}

//Interrupcion por desbordamiento del Timer1
void Timer1Int() org IVT_ADDR_T1INTERRUPT{
     
     T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion por desbordamiento del Timer1
     
     //ADXL355_read_byte(Status);
     numFIFO = ADXL355_read_byte(FIFO_ENTRIES); //75                            //Lee el numero de muestras disponibles en el FIFO
     //numFIFO = 75;
     numSetsFIFO = (numFIFO)/3;                 //25                            //Lee el numero de sets disponibles en el FIFO

     //Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
     //En cada interrupcion debe haber 25 sets de mediciones +-1
     for (x=0;x<numSetsFIFO;x++){
         ADXL355_read_FIFO(datosLeidos);                                       //Lee una sola posicion del FIFO
         for (y=0;y<9;y++){
             datosFIFO[y+(x*9)] = datosLeidos[y];                               //LLena la trama datosFIFO
         }
     }
     
     //Este bucle rellena la trama completa intercalando el numero de muestra correspondientes
     for (x=0;x<(numSetsFIFO*9);x++){      //0-224
         if ((x==0)||(x%9==0)){
            tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
            //tramaCompleta[contFIFO+contMuestras+x] = 255;
            tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
            contMuestras++;
         } else {
            tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
         }
     }
     
     contFIFO = (contMuestras*9);                                    //Incrementa el contador de FIFOs

     contTimer1++;                                                              //Incrementa una unidad cada vez que entra a la interrupcion por Timer1
     
     if (contTimer1==9){                                                        //Verifica si se recibio los 5 FIFOS
        T1CON.TON = 0;                                                          //Apaga el Timer1
        banCiclo = 1;                                                           //Activa la bandera que indica que se completo un ciclo de medicion
        contTimer1 = 0;                                                         //Limpia el contador de interrupciones por Timer1
     }
     


}

//Interrupcion SPI1
void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
     SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI
     buffer = SPI1BUF;                                                          //Guarda el contenido del bufeer (lectura)
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


//////////////////////////////////////////////////////////////      Main      //////////////////////////////////////////////////////////////

void main() {

     ConfiguracionPrincipal();

     tiempo[0] = 19;                                    //Año
     tiempo[1] = 49;                                    //Dia
     tiempo[2] = 9;                                     //Hora
     tiempo[3] = 30;                                    //Minuto
     tiempo[4] = 0;                                     //Segundo
     
     datosLeidos[0] = 111;
     datosLeidos[1] = 111;
     datosLeidos[2] = 111;
     datosLeidos[3] = 111;
     datosLeidos[4] = 111;
     datosLeidos[5] = 111;
     datosLeidos[6] = 111;
     datosLeidos[7] = 111;
     datosLeidos[8] = 111;

     banTI = 0;
     banLec = 0;
     banCiclo = 0;

     i = 0;
     x = 0;
     y = 0;

     contMuestras = 0;
     contCiclos = 0;
     contFIFO = 0;
     numFIFO = 0;
     numSetsFIFO = 0;
     contTimer1 = 0;
     
     RP1 = 0;
     RP2 = 0;

     puntero_8 = &auxiliar;

     SPI1BUF = 0x00;

     banInicio = 1;

     while(1){

              Delay_ms(500);

     }

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////