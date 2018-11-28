  /*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 20/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:
Envia una trama de datos valida por UART cada vez que presiona el pulsante conectado al pin de interrupcion externa

---------------------------------------------------------------------------------------------------------------------------*/

/////////////////////////////////// Formato de la trama de datos ///////////////////////////////////
//|  Cabecera  |                      PDU                       |        CRC        |      Fin     |
//|   1 byte   |   1 byte  |              n bytes               |      2 bytes      |    2 bytes   |
//|    3Ah     | Dirección | #Datos  | Función | Data1 | DataN  | CRC_MSB | CRC_LSB |  0Dh  |  0Ah |
//|      0     |     1     |    2    |    3    |   4   |    n   |   n+4   |   n+5   |  n+4  |  n+5 |


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables y contantes para la peticion y respuesta de datos
sbit TOUT at RC3_bit;                                   //Definicion del pin RE_DE
sbit TOUT_Direction at TRISC3_bit;
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador de interrupcion por UART1
sbit AUX_Direction at TRISB3_bit;

const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const unsigned int POLMODBUS = 0xA001;                  //Polinomio para el calculo del CRC

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned char trama[30];                                //Vector de trama de datos del puerto UART1
short i1;                                               //Subindices para el manejo de las tramas de datos

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char PDU[15];                                  //Vector para almacenar la peticion proveniente de la Rpi
unsigned short sizePDU;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master

unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     TRISB3_bit = 0;
     TRISC3_bit = 0;
     
     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     
     //Configuracion de la interrupcion externa
     INTCON.INTE = 1;                                   //Habilita la interrupcion externa
     INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
     OPTION_REG.INTEDG = 0;                             //Activa la interrupcion en el flanco de bajada

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el calculo y comprobacion del CRC
//Esta funcion recibe como parametro una trama y su longitud y devuelve el valor calculado del CRC
unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
     unsigned char ucCounter;
     unsigned int CRC16;                                //Variables para almacenar el CRC calculado, y el CRC de la trama PDU recibida
     for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
          CRC16 ^=*trama ++;
          for(ucCounter =0; ucCounter <8; ucCounter ++){
               if(CRC16 & 0x0001)
               CRC16 = (CRC16 >>1)^POLMODBUS;
          else
               CRC16>>=1;
          }
     }
     return CRC16;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros la trama PDU y su tamaño, y envia la trama de peticion completa a travez de RS485
void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     trama[0]=HDR;                                      //Añade la cabecera a la trama a enviar
     trama[sizePDU+2]=*ptrCrcPdu;                       //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     trama[sizePDU+1]=*(ptrCrcPdu+1);                   //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     trama[sizePDU+3]=END1;                             //Añade el primer delimitador de final de trama
     trama[sizePDU+4]=END2;                             //Añade el segundo delimitador de final de trama
     for (i=0;i<(sizePDU+5);i++){
         if ((i>=1)&&(i<=sizePDU)){
            UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(trama[i]);                      //Envia el contenido del resto de la trama de peticion a travez del UART1
         }
     }
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     TOUT = 1;
     Delay_ms(200);
     TOUT = 0;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa
//Esta interrupcion simula lo que debe hacer el dipositivo MasterComunicacion al recibir una peticion del RPi por SPI
     if (INTCON.INTF==1){
        AUX = 1;
        INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
        PDU[0]=0x03;                                    //Ejemplo de trama PDU
        PDU[1]=0x05;
        PDU[2]=0x05;
        PDU[3]=0x06;
        PDU[4]=0x07;
        sizePDU = PDU[1];                               //Guarda el dato de la longitud de la trama PDU
        EnviarMensajeRS485(PDU, sizePDU);               //Invoca a la funcion para enviar la peticion
        AUX = 0;
     }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main() {

     AUX = 0;
     ConfiguracionPrincipal();
     TOUT = 1;
     Delay_ms(200);
     TOUT = 0;

}