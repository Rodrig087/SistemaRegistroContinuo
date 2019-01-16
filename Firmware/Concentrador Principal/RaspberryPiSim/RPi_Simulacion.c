/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 5/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

///////////////////////////////////// Formato de la trama de datos ////////////////////////////////////
//|  Cabecera  |                        PDU                        |        CRC        |      Fin     |
//|   1 byte   |   1 byte  |              n bytes                  |      2 bytes      |    2 bytes   |
//|    3Ah     | Dirección | Función | Registro | #Datos  | DataN  | CRC_MSB | CRC_LSB |  0Dh  |  0Ah |
//|      0     |     1     |    2    |    3     |   4     |   n    |   n+4   |   n+5   |  n+4  |  n+5 |

// Codigo ACK: AAh
// Codigo NACK: AFh
// Direccion H/S: FDh, FEh, FFh

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables y contantes para la peticion y respuesta de datos
sbit CS at RC2_bit;                                     //Definicion del pin CS
sbit CS_Direction at TRISC2_bit;

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned char tramaRS485[50];                           //Vector de trama de datos del puerto UART1
short i,j,x;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char tramaSPI[50];                             //Vector para almacenar la peticion proveniente de la Rpi
unsigned short sizeSPI;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master
unsigned short registroRPi;                             //Variable para almcenar el
unsigned short tipoDato;                                //Variable para indicar el tipo de dato que se va a enviar: 0x00 Short, 0x01 Entero, 0x02 Float
unsigned short numDatos;                                //Variable para alamcenar el numero de datos que se van a enviar

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital
     
     TRISB0_bit = 1;
     TRISB1_bit = 1;
     TRISC2_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps

     //Configuracion del puerto SPI
     SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);

     //Configuracion de la interrupcion externa (simula la una peticion)
     INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
     INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
     INTCON3.INT1IE = 1;                                //Habilita la interrupcion externa INT1
     INTCON3.INT1IF = 0;                                //Limpia la bandera de interrupcion externa INT1
     //INTCON2.INTEDG0 = 0;                               //Interrupcion INT0 en flanco de bajada
     //INTCON2.INTEDG1 = 0;                               //Interrupcion INT1 en flanco de bajada

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros la trama PDU y su tamaño, y envia la trama de peticion completa a travez de SPI
void EnviarMensajeSPI(unsigned char *trama, unsigned short sizePDU){
     CS = 0;
     for (x=0;x<sizePDU;x++){
         SSPBUF = trama[x];                             //Llena el buffer de salida con cada valor de la tramaSPI
         Delay_ms(1);
     }
     CS = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa
//Esta interrupcion simula lo que envia la RPi al dispositivo CPComunicacion
     if (INTCON3.INT1IF==1){
        INTCON3.INT1IF = 0;                             //Limpia la badera de interrupcion externa
        
        //Aqui va la parte donde realiza la toma de datos que llegan por SPI desde la Rpi
        //Ejemplo de trama de peticion enviada por la RPi:
        funcionRpi = 0x01;                              //Funcion que se requiere realizar. 0x00:Lectura  0x01:Escritura
        direccionRpi = 0x09;                            //Direccion del esclavo destinatario de la peticion
        registroRPi = 0x02;                             //Registro que se desea leer o escribir

        tramaSPI[0] = 0xB0;                             //Cabecera
        tramaSPI[1] = direccionRpi;                     //Direccion
        tramaSPI[2] = funcionRpi;                       //Funcion
        tramaSPI[3] = registroRPi;                      //Registro

        if (funcionRpi==0x00){
           
           tramaSPI[4] = 0x00;                          //#Datos
           tramaSPI[5] = 0xB1;                          //Fin
           EnviarMensajeSPI(tramaSPI,6);
           
        }else{
           
           tipoDato = 0x02;                             //0x00: Short, 0x01: Entero, 0x02: Float
           switch (tipoDato){
                  case 0:
                       numDatos = 1;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0x5C;              //Datos
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
                  case 1:
                       numDatos = 2;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0x5C;              //Datos
                       tramaSPI[6] = 0x8F;
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
                  case 2:
                       numDatos = 4;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0x5C;              //Datos
                       tramaSPI[6] = 0x8F;
                       tramaSPI[7] = 0x58;
                       tramaSPI[8] = 0x83;
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
           }
           
           EnviarMensajeSPI(tramaSPI,(numDatos+6));
        
        }

     }
 }


void main() {

     ConfiguracionPrincipal();
     CS = 1;
     byteTrama = 0;                                       //Limpia la variable del byte de la trama de peticion
     banTI = 0;                                           //Limpia la bandera de inicio de trama
     banTC = 0;                                           //Limpia la bandera de trama completa
     banTF = 0;                                           //Limpia la bandera de final de trama

}