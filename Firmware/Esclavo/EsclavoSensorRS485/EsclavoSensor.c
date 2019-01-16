/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 29/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

///////////////////////////////////// Formato de la trama de datos ////////////////////////////////////
//|  Cabecera  |                        PDU                        |        CRC        |      Fin     |
//|   1 byte   |   1 byte  |              n bytes                  |      2 bytes      |    2 bytes   |
//|    3Ah     | Dirección | Función | Registro | #Datos  | DataN  | CRC_MSB | CRC_LSB |  0Dh  |  0Ah |
//|      0     |     1     |    2    |    3     |   4     |   n    |   n+4   |   n+5   |  n+4  |  n+5 |

// Registros de Lectura //
//|   00   |   Caudal   |
//|   01   |   Nivel    |
//|   02   |    TOF     |
//|   03   |    Temp    |

//          Registros de Escritura          //
//|   00   |   Altura instalacion           |
//|   01   |   Factor calibracion altura    |
//|   02   |   Factor calibracion TOF       |


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit RE_DE at RC1_bit;                                     //Definicion del pin REDE
sbit RE_DE_Direction at TRISC1_bit;
sbit ECINT at RC2_bit;                                  //Definicion del pin de indicador auxiliar para hacer pruebas
sbit ECINT_Direction at TRISC2_bit;

unsigned short idEsclavo;                               //Constante de identificador de esclavo
const short HDR = 0xAA;                                 //Constante de cabecera
const short END = 0xFF;                                 //Constante de fin de trama
const short funcEsclavo = 0x01;                         //Constante de numero de funciones del esclavo (0x00 = Solo lectura , 0x01 = Lectura y escritura)
const short regLectura = 0x04;                          //Numero de registros de lectura del esclavo
const short regEscritura = 0x03;                        //Numero de registros de escritura del esclavo

//Variables para el procesamiento de la trama recibida por RS485
unsigned short byteTrama;
unsigned short banTI, banTC, banTF;
unsigned short i1;
unsigned char pduSolicitud[10];
unsigned short pduIdEsclavo;
unsigned short pduFuncion;
unsigned short pduRegistro;
unsigned short pduNumDatos;
unsigned char pduDatos[4];
unsigned char resRS485[8];

unsigned int tiempoEspera;
unsigned char datosEscritura[10];                       //Vector para almacenar los valores que se requiere escribir en los registros de escritura
unsigned short regEsc;                                  //Variable para almacenar el registro que se quiere escribir
unsigned short numDatosEsc;                             //Variable para almacenar el numero de datos que se desea escribir en un registro de escritura
unsigned short i, x, j;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banLec, banId, banEsc;
unsigned short contDelay;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ADCON1 = 0x07;
     
     TRISA0_bit = 1;
     TRISA1_bit = 1;
     TRISB0_bit = 1;
     TRISB3_bit = 0;
     TRISC1_bit = 0;
     TRISC2_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
     
     //Configuracion del UART
     UART1_Init(19200);
     PIE1.RCIE = 1;
     
      //Configuracion de la interrupcion externa
     INTCON.INTE = 1;                                   //Habilita la interrupcion externa
     INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
     OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de un mensaje de respuest de error
//Esta funcion recibe como parametros el codigo de error
void EnviarMensajeError(unsigned short codigoError){
     resRS485[0] = 0xEE;
     resRS485[1] = codigoError;
     resRS485[2] = funcEsclavo;
     resRS485[3] = regLectura;
     resRS485[4] = regEscritura;
     resRS485[5] = END;
     RE_DE = 1;                                         //Establece el Max485 en modo escritura
     for (x=0;x<6;x++){
         UART1_Write(resRS485[x]);
         while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
     RE_DE = 0;                                         //Establece el Max485 en modo lectura
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion UART
     if (PIR1.RCIF==1){

        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
        
        if (banTI==0){
           if (bytetrama==0xB0){
              banTI = 1;                                //Activa la bandera de inicio de trama
              i1 = 0;
           }
        }
        
        if (banTI==1){
           if (byteTrama!=0xB1){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              pduSolicitud[i1] = byteTrama;             //Almacena el dato en la trama de respuesta
              i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                //Limpia la bandera de final de trama
           } else {
              pduSolicitud[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
              banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;
           }
           if (banTF==1){                               //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                //Activa la bandera de trama completa
              PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
              T2CON.TMR2ON = 0;                         //Apaga el Timer2
           }
        }
        
        //Aqui procesa el contenido de la trama de peticion
        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
           pduIdEsclavo = pduSolicitud[1];
           if (pduIdEsclavo==idEsclavo){
              pduFuncion = pduSolicitud[2];
              pduRegistro = pduSolicitud[3];
              pduNumDatos = pduSolicitud[4];
              if (pduFuncion<funcEsclavo){              //Verifica si existe la funcion solicitada

              } else {
              
              }
              
              UART1_Write(0xAA);

           
           }
           
           banTI = 0;                                   //Limpia la bandera de inicio de trama
           banTC = 0;                                   //Limpia la bandera de trama completa
           i1 = 0;                                      //Limpia el subindice de trama
        }
        
        PIR1.RCIF=0;
        
     }

}


void main() {

     ConfiguracionPrincipal();
     //idEsclavo = (PORTA&0x03)+((0x00&0xFC)<<2);
     idEsclavo = 0x09;

     ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)

     i1 = 0;
     x = 0;

     



}