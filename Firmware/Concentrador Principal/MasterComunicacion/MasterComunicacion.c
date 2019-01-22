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
sbit RE_DE at RB1_bit;                                  //Definicion del pin RE_DE
sbit RE_DE_Direction at TRISB1_bit;

sbit IU1 at RC4_bit;                                    //Definicion del pin de indicador de interrupcion por UART1
sbit IU1_Direction at TRISC4_bit;

const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const short ACK = 0xAA;                                 //Constante de mensaje ACK
const short NACK = 0xAF;                                //Constante de mensaje NACK
const unsigned int POLMODBUS = 0xA001;                  //Polinomio para el calculo del CRC

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned char tramaRS485[50];                           //Vector de trama de datos del puerto UART1
short i1;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short banLP, banLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char tramaSPI[50];                             //Vector para almacenar la peticion proveniente de la Rpi
unsigned short sizeSPI;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master

unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     TRISB0_bit = 1;
     TRISC4_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     INTCON = 0xC0;

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     PIE1.RCIE = 1;

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
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros la trama PDU y su tamaño, y envia la trama de peticion completa a travez de RS485
void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por RS485 con los datos de la trama PDU
     tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
     tramaRS485[sizePDU+2]=*ptrCrcPdu;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaRS485[sizePDU+1]=*(ptrCrcPdu+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
     tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
     RE_DE = 1;                                         //Establece el Max485 en modo escritura
     for (i=0;i<(sizePDU+5);i++){
         if ((i>=1)&&(i<=sizePDU)){
            //Delay_ms(3);                              //Esto sirve para probar el Time-Out-Trama en el dispositivo que recibe la trama
            UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
         }
     }
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
     
     byteTrama=0;                                    //Limpia la variable del byte de la trama de peticion
     
     //Aqui esta el problema, o tal vez funciona correctamente debido a que no obtiene como respuesta el ACK
     //Inicializa el Time-Out-Dispositivo
     T1CON.TMR1ON = 1;                                  //Enciende el Timer1
     TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
     TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
     TMR1L = 0xDC;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para la comprobacion del CRC
//Esta funcion recibe como parametro una trama RS485 y la longitud de la trama PDU, y devuelve un 1 si el CRC calculado coincide con el valor del campo CRC
//de la trama o un 0 en caso contrario
unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
     unsigned char pdu[15];
     unsigned short j;
     unsigned int crcCalculado, crcTrama;               //Variables para almacenar el CRC calculado, y el CRC de la trama recibida
     unsigned short *ptrCRCTrama;                       //Puntero para almacenar los valores del CRC calculado y el de la trama PDU recibida
     crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
     crcTrama = 1;
     for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
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
     RE_DE = 1;                                         //Establece el Max485 en modo escritura
     UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama NACK
//Esta funcion indica que el mensaje recibido esta corrompido
void EnviarNACK(){
     RE_DE = 1;                                         //Establece el Max485 en modo escritura
     UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion UART1
//Esta interrupcion supervisa el estado del bus RS485, cuando detecta una peticion procediente del Master revisa si el prmer byte de la trama es
//la Cabecera, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues guarda el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama de peticion, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, comprueba el campo de Direccion, si es igual a 0xFF dara paso al
//proceso de calibracion, caso contrario renviara la trama por el puerto UART2 es decir a travez de los modulos inhalabricos hacia los esclavos.
     if (PIR1.RCIF==1){

        IU1 = 1;
        //Delay_ms(1);
        IU1 = 0;
        
        byteTrama = UART1_Read();                           //Lee el byte de la trama de peticion

        if (banTI==0){
            if ((byteTrama==HDR)){
               banTI = 1;                                   //Activa la bandera de inicio de trama
               i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
               tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
            }
        }

        if (banTI==1){                                      //Verifica que la bandera de inicio de trama este activa
           if (byteTrama!=END2){                            //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              tramaRS485[i1] = byteTrama;                   //Almacena el dato en la trama de respuesta
              i1++;                                         //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                    //Limpia la bandera de final de trama
           } else {
              tramaRS485[i1] = byteTrama;                   //Almacena el dato en la trama de respuesta
              banTF = 1;                                    //Si el dato recibido es el primer byte de final de trama activa la bandera
           }
           if (BanTF==1){                                   //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                    //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                    //Activa la bandera de trama completa
           }
        }
        
        if (banTC==1){  
           t1Size = tramaRS485[4]+4;                        //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
           tramaOk = VerificarCRC(tramaRS485,t1Size);       //Calcula y verifica el CRC de la trama de peticion
           if (tramaOk==1){
                  EnviarACK();
                  
                  Delay_ms(1000);                           //Simula un tiempo de procesamiento largo (un segundo);
                  EnviarMensajeRS485(tramaSPI, sizeSPI);          //Invoca a la funcion para enviar la peticion
           
           }else{
                 EnviarNACK();
           }
           banTC = 0;                                       //Limpia la bandera de trama completa
           i1 = 0;                                          //Limpia el subindice de trama
           banTI = 0;
        }

        PIR1.RCIF = 0;

     }

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void main() {

     ConfiguracionPrincipal();
     RE_DE = 1;                                         //Establece el Max485-1 en modo de lectura;
     i1=0;
     contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                  //Inicia el contador de NACK
     byteTrama = 0;                                     //Limpia la variable del byte de la trama de peticion
     
     banTI = 0;                                         //Limpia la bandera de inicio de trama
     banTC = 0;                                         //Limpia la bandera de trama completa
     banTF = 0;                                         //Limpia la bandera de final de trama
     banLR = 0;
     
     //Ejemplo de trama de peticion enviada por la RPi
     sizeSPI = 8;
     tramaSPI[0] = 0x09;                             //Id esclavo
     tramaSPI[1] = 0x01;                             //Codigo de funcion que se quiere ejecutar (00=Lectura, 01=Escritura)
     tramaSPI[2] = 0x02;                             //# de registro que se quiere leer/escribir
     tramaSPI[3] = sizeSPI-4;                        //# de datos del payload, como se trata de una solicitud de escritura no es necesario ningun dato adicioanl al registro que se quiere leer
     tramaSPI[4] = 0xD1;                             //Datos ejemplo
     tramaSPI[5] = 0xD2;
     tramaSPI[6] = 0xD3;
     tramaSPI[7] = 0xD4;

}