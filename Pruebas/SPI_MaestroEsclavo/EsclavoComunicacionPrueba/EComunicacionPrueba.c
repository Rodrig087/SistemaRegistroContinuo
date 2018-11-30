/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 20/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

/////////////////////////////////// Formato de la trama de datos ///////////////////////////////////
//|  Cabecera  |                      PDU                       |        CRC        |      Fin     |
//|   1 byte   |   1 byte  |              n bytes               |      2 bytes      |    2 bytes   |
//|    3Ah     | Dirección | #Datos  | Función | Data1 | DataN  | CRC_MSB | CRC_LSB |  0Dh  |  0Ah |
//|      0     |     1     |    2    |    3    |   4   |    n   |   n+4   |   n+5   |  n+4  |  n+5 |

// Codigo ACK: AAh
// Codigo NACK: AFh
// Direccion H/S: FDh, FEh, FFh



//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables y contantes para la peticion y respuesta de datos
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit CS at RC2_bit;                                     //Definicion del pin CS
sbit CS_Direction at TRISC2_bit;

const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const short ACK = 0xAA;                                 //Constante de mensaje ACK
const short NACK = 0xAF;                                //Constante de mensaje NACK
const unsigned int POLMODBUS = 0xA001;                  //Polinomio para el calculo del CRC

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned char tramaUART[30];                           //Vector de trama de datos del puerto UART1
short i1;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF, banPet;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char petSPI[15];                               //Vector para la petcion SPI para el esclavo
unsigned char resSPI[15];                               //Vector para la respuesta SPI proveniente del esclavo
unsigned short sizeSPI;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master

unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK

unsigned short x, buffer, numBytesSPI;
unsigned short respSPI;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     TRISB0_bit = 1;
     TRISB3_bit = 0;
     TRISC2_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     PIE1.RCIE = 1;

     //Configuracion del puerto SPI
     SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);

     //Configuracion de la interrupcion externa
     INTCON.INTE = 1;                                   //Habilita la interrupcion externa
     INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
     OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida

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
//Esta funcion recibe como parametros el id de esclavo, la trama de respuesta, y su tamaño
void EnviarMensajeUART(unsigned char idEsclavo, unsigned char *tramaPDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por RS485 con los datos de la trama PDU
     tramaUART[0] = HDR;                               //Añade la cabecera a la trama a enviar
     tramaUART[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaUART[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaUART[sizePDU+3] = END1;                      //Añade el primer delimitador de final de trama
     tramaUART[sizePDU+4] = END2;                      //Añade el segundo delimitador de final de trama
     for (i=0;i<(sizePDU+5);i++){
         if ((i>=1)&&(i<=sizePDU)){
            UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(tramaUART[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
         }
     }
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para la comprobacion del CRC
//Esta funcion recibe como parametro una trama RS485 y la longitud de la trama PDU, y devuelve un 1 si el CRC calculado coincide con el valor del campo CRC
//de la trama o un 0 en caso contrario
unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
     unsigned char pdu[15]; //**Aqui se daña cuando pongo un numero de elementos mayor a 30
     unsigned short j;
     unsigned int crcCalculado, crcTrama;               //Variables para almacenar el CRC calculado, y el CRC de la trama recibida
     unsigned short *ptrCRCTrama;                       //Puntero para almacenar los valores del CRC calculado y el de la trama PDU recibida

     unsigned short *crcPrint;

     crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
     crcTrama = 1;

     for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
         pdu[j] = trama[j+1];
     }

     crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU

     ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
     *ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
     *(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU

     if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
        return 1;
     } else {
        return 0;
     }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama ACK
//Esta funcion indica que el mensaje fue recibido satisfactoriamente
void EnviarACK(){
     UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama NACK
//Esta funcion indica que el mensaje recibido esta corrompido
void EnviarNACK(){
     UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una peticion SPI
//Esta funcion permite enviar una solicitud al EsclavoSensor para realizar una lectura de los sensores

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa
//Aqui recibe y procesa la trama SPI devuelta por el ESensor
     if (INTCON.INTF==1){
        INTCON.INTF = 0;                                //Limpia la badera de interrupcion externa
        Delay_ms(10);                                   //**Sin esto no funciona y no se porque**
        CS = 0;                                         //Coloca en bajo el pin CS para abrir la transmision
        for (x=0;x<=numBytesSPI;x++){
            SSPBUF = 0xBB;                              //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
            if ((x>0)){
               while (SSPSTAT.BF!=1);
               UART1_Write(SSPBUF);
            }
            Delay_us(200);
        }
        CS = 1;                                         //Coloca en alto el pin CS para cerrar la transmision
     }

//Interrupcion UART1
     if (PIR1.RCIF==1){

        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion

        if ((byteTrama==HDR)&&(banTI==0)){
           banTI = 1;                                   //Activa la bandera de inicio de trama
           i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
           tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
        }

        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              tramaUART[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
              i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                //Limpia la bandera de final de trama
           } else {
              tramaUART[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
              banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
           }
           if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                //Activa la bandera de trama completa
              t1Size = tramaUART[2];                   //Guarda el byte de longitud del campo PDU
           }
        }

        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
           tramaOk = VerificarCRC(tramaUART,t1Size);   //Calcula y verifica el CRC de la trama de peticion
           if (tramaOk==1){
               EnviarACK();                             //Si la trama llego sin errores responde con un ACK al esclavo
               
               petSPI[0] = 0xA0;                        //Cabecera de trama de solicitud de medicion
               petSPI[1] = 0x02;                        //Codigo del registro que se quiere leer
               petSPI[2] = 0xA1;                        //Delimitador de final de trama
               
               CS = 0;
               for (x=0;x<3;x++){
                   SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
                   if (x==2){
                      while (SSPSTAT.BF!=1);
                      numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
                   }
                   Delay_ms(1);
               }
               CS = 1;
               
           } else if (tramaOk==0) {
               EnviarNACK();                            //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
           }
           banTC = 0;                                   //Limpia la bandera de trama completa
           i1 = 0;                                      //Limpia el subindice de trama
           banTI = 0;
        }

        PIR1.RCIF = 0;

     }

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



void main() {

     ConfiguracionPrincipal();
     AUX = 0;
     i1=0;
     contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                  //Inicia el contador de NACK
     banTI=0;
     banTC=0;
     banTF=0;
     banPet=0;

}