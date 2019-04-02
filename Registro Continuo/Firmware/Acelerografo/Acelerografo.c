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
sbit RP1 at LATA4_bit;                                    //Definicion del pin P1
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;                                    //Definicion del pin P2
sbit RP2_Direction at TRISB4_bit;

const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const unsigned short NUM_MUESTRAS = 199;                //Constantes para almacenar el numero de muestras que se van a enviar en la interrupcion P2
//const unsigned int T2 = 222;

unsigned char tiempo[5];                                //Vector para almacenar los datos de la cabecera
unsigned char datos[10];                                //Vector para almacenar los datos de payload
unsigned char pduSPI[15];                               //Vector de trama de datos del puerto UART2
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};

unsigned short i, x;
unsigned short  buffer;
unsigned short contMuestras;
unsigned short contCiclos;

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama
unsigned short  banResp, banSPI, banLec, banEsc;


long datox, datoy, datoz, auxiliar;
unsigned char *puntero_8, direccion;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){
     
     //configuracion del oscilador                      //FPLLO = FIN*(M/(N1+N2)) = 80.017MHz
     CLKDIVbits.FRCDIV = 0;                             //FIN=FRC/1
     CLKDIVbits.PLLPOST = 0;                            //N2=2
     CLKDIVbits.PLLPRE = 5;                             //N1=7
     PLLFBDbits.PLLDIV = 150;                           //M=152
     //Configuracion de puertos
     ANSELA = 0;                                        //Configura PORTA como digital     *
     ANSELB = 0;                                        //Configura PORTB como digital     *
     TRISA3_bit = 0;                                    //Configura el pin A3 como salida  *
     TRISA4_bit = 0;                                    //Configura el pin A4 como salida  *
     TRISB4_bit = 0;                                    //Configura el pin B4 como salida  *
     TRISB10_bit = 1;                                   //Configura el pin B10 como entrada *
     TRISB11_bit = 1;                                   //Configura el pin B11 como entrada *
     TRISB12_bit = 1;                                   //Configura el pin B12 como entrada *
     TRISB13_bit = 1;                                   //Configura el pin B13 como entrada *

     INTCON2.GIE = 1;                                   //Habilita las interrupciones globales *
     
     //Configuracion del puerto UART
     //RPINR18 = 0x0022;                                  //Configura el pin RB2/RPI34 como Rx1 *
     //RPOR0.RP35R = 0x0100;                              //Configura el Tx1 en el pin RB3/RP35 *

     //Configuracion del puerto SPI1 en modo Esclavo
     SPI1STAT.SPIEN = 1;                                //Habilita el SPI1 *
     SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
     SPI1IE_bit = 1;                                    //Habilita la interrupcion por SPI1  *
     SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI *
     
     //Configuracion del puerto SPI2 en modo Master
     RPINR22bits.SDI2R = 0x21;                          //Configura el pin RB1/RPI33 como SDI2 *
     RPOR2bits.RP38R = 0x08;                            //Configura el SDO2 en el pin RB6/RP38 *
     RPOR1bits.RP37R = 0x09;                            //Configura el SCK2 en el pin RB5/RP37 *
     SPI2STAT.SPIEN = 1;                                //Habilita el SPI2 *
     SPI2_Init();                                       //Inicializa el modulo SPI2

     //Configuracion de la interrupcion externa
     RPINR0 = 0x2E00;                                   //Asigna INT1 al RB14/RPI46
     INT1IE_bit = 1;                                    //Habilita la interrupcion externa INT1
     INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
     IPC0 = 0x0001;                                     //Prioridad en la interrupocion externa 1

     //Configuracion del TMR1 con un tiempo de 5ms
     T1CON = 0x0010;
     T1CON.TON = 0;                                     //Apaga el Timer1
     T1IE_bit = 1;                                      //Habilita la interrupción de desbordamiento TMR1
     T1IF_bit = 0;                                      //Limpia la bandera de interrupcion del TMR2
     IPC0 = 0x1000;                                     //Prioridad de la interrupcion por desbordamiento del TMR1
     PR1 = 25000;
     
     ADXL355_init();
     
     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////

//Interrupcion INT1
void int_1() org IVT_ADDR_INT1INTERRUPT {
     INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
     contMuestras = 0;                                  //Limpia el contador de muestras
     datos[0] = contCiclos;                             //Carga el primer valor de la trama de datos con el valor de la muestra actual
     
     //readMultipleData(axisAddresses, 9, datosLeidos);
    ADXL355_muestra(datosLeidos);
     datos[1] = (datosLeidos[0]);
     datos[2] = (datosLeidos[1]);
     datos[3] = (datosLeidos[2]>>4);
     datos[4] = (datosLeidos[3]);
     datos[5] = (datosLeidos[4]);
     datos[6] = (datosLeidos[5]>>4);
     datos[7] = (datosLeidos[6]);
     datos[8] = (datosLeidos[7]);
     datos[9] = (datosLeidos[8]>>4);

     /*datos[0] = contCiclos;                             //Carga el primer valor de la trama de datos con el valor de la muestra actual
     datos[1] = datox & 0xFF;
     datos[2] = (datox>>8) & 0xFF;
     datos[3] = (datox>>16) & 0xFF;
     datos[4] = datoy & 0xFF;
     datos[5] = (datoy>>8) & 0xFF;
     datos[6] = (datoy>>16) & 0xFF;
     datos[7] = datoz & 0xFF;
     datos[8] = (datoz>>8) & 0xFF;
     datos[9] = (datoz>>16) & 0xFF;*/

     for (x=0;x<10;x++){
         pduSPI[x]=datos[x];                            //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
     }
     banTI = 1;                                         //Activa la bandera de inicio de trama
     RP1 = 1;                                           //Genera el pulso P1 para producir la interrupcion en la RPi
     Delay_us(20);
     RP1 = 0;
     T1CON.TON = 1;                                     //Enciende el Timer1
     contCiclos++;
}

//Interrupcion por desbordamiento del Timer1
void Timer1Int() org IVT_ADDR_T1INTERRUPT{
     T1IF_bit = 0; 
     contMuestras++;                                    //Incrementa el contador de muestras
     datos[0] = contMuestras;                           //Carga el primer valor de la trama de datos con el valor de la muestra actual
     
     //readMultipleData(axisAddresses, 9, datosLeidos);
     
     ADXL355_muestra(datosLeidos);
     datos[1] = (datosLeidos[0]);
     datos[2] = (datosLeidos[1]);
     datos[3] = (datosLeidos[2]);
     datos[4] = (datosLeidos[3]);
     datos[5] = (datosLeidos[4]);
     datos[6] = (datosLeidos[5]);
     datos[7] = (datosLeidos[6]);
     datos[8] = (datosLeidos[7]);
     datos[9] = (datosLeidos[8]);

     /*datos[0] = contMuestras;                           //Carga el primer valor de la trama de datos con el valor del contador de muestras
     datos[1] = datox & 0xFF;
     datos[2] = (datox>>8) & 0xFF;
     datos[3] = (datox>>16) & 0xFF;
     datos[4] = datoy & 0xFF;
     datos[5] = (datoy>>8) & 0xFF;
     datos[6] = (datoy>>16) & 0xFF;
     datos[7] = datoz & 0xFF;
     datos[8] = (datoz>>8) & 0xFF;
     datos[9] = (datoz>>16) & 0xFF;*/
     
     for (x=0;x<10;x++){
         pduSPI[x]=datos[x];                            //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
     }
     if (contMuestras==NUM_MUESTRAS){
        T1CON.TON = 0;                                  //Apaga el Timer2
        for (x=10;x<15;x++){
            pduSPI[x]=tiempo[x-10];                     //Carga el vector de salida de datos SPI con los datos de la cabecera
        }
     }
     banTI = 1;                                         //Activa la bandera de inicio de trama
     RP2 = 1;                                           //Genera el pulso P2 para producir la interrupcion en la RPi
     Delay_us(20);
     RP2 = 0;                                           //Limpia la bandera de interrupcion por desbordamiento del Timer1
}

//Interrupcion SPI1
void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
     SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI
     buffer = SPI1BUF;                                  //Guarda el contenido del bufeer (lectura)
     //Rutina para procesar la trama de solicitud de lectura desde la RPi
     if ((banTI==1)){                                   //Verifica si la bandera de inicio de trama esta activa
        banLec = 1;                                     //Activa la bandera de lectura
        banTI = 0;
        i = 0;
        SPI1BUF = pduSPI[i];
     }
     if ((banLec==1)&&(buffer!=0xB1)){
        SPI1BUF = pduSPI[i];
        i++;
     }
     if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
        banLec = 0;                                     //Limpia la bandera de lectura
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
     
     datos[1] = 0;
     datos[2] = 0;
     datos[3] = 0;
     datos[4] = 0;
     datos[5] = 0;
     datos[6] = 0;
     datos[7] = 0;
     datos[8] = 0;
     datos[9] = 0;
     
     //datox = 0x1BACA5;                                  //00011011 10101100 10100101       165  172  027
     //datoy = 0x2BECA5;                                  //00101011 11101100 10100101       165  236  043
     //datoz = 0x3B0CA5;                                  //00111011 00001100 10100101       165  012  059
     
     datox = 0;
     datoy = 0x6F6F6F6F;
     datoz = 0x6F6F6F6F;

     banTI = 0;
     banLec = 0;
     i = 0;
     x = 0;

     contMuestras = 0;
     contCiclos = 0;
     RP1 = 0;
     RP2 = 0;
     
     puntero_8 = &auxiliar;

     SPI1BUF = 0x00;

     while(1){

              Delay_ms(500);

     }

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////