/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 07/01/2018
Configuracion: PIC18F25k22 XT=8MHz
Observaciones:

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
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit IU1 at RB4_bit;                                    //Definicion del pin de indicador de interrupcion por UART1
sbit IU1_Direction at TRISB4_bit;
sbit RInt at RC1_bit;                                      //Definicion del pin RInt
sbit RInt_Direction at TRISC1_bit;
sbit RE_DE at RC2_bit;                                  //Definicion del pin RE_DE
sbit RE_DE_Direction at TRISC2_bit;

const short DIR = 0xFD;                                 //Direccion de este dispositivo
const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const short ACK = 0xAA;                                 //Constante de mensaje ACK
const short NACK = 0xAF;                                //Constante de mensaje NACK
const unsigned int POLMODBUS = 0xA001;                  //Polinomio para el calculo del CRC

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size, t2Size, pduSize;                 //Variables de longitud de tramas de peticion, respuesta y PDU
unsigned char tramaRS485[25];                           //Vector de trama de datos del puerto UART1
unsigned char tramaPDU[15];                             //Vector para almacenar los valores de la trama PDU creada localmente
unsigned char pduSPI[10];                               //Vector de trama de datos del puerto UART2
short i1, i2;                                           //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;
unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK
unsigned short puertoTOT;                               //Especifica el puerto por cual enviar el NACK en caso de producirse un Time-Out-Trama

unsigned short regEsc;                                  //Variable para almacenar el registro que se quiere escribir
unsigned short numDatosEsc;                             //Variable para almacenar el numero de datos que se desea escribir en un registro de escritura
unsigned short
unsigned short i, x, j;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banLec, banId, banEsc;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISB1_bit = 1;                                   //Configura el pin B1 como entrada
     TRISB3_bit = 0;                                   //Configura el pin B3 como salida
     TRISB4_bit = 0;                                   //Configura el pin B4 como salida
     TRISC1_bit = 0;                                   //Configura el pin C1 como salida
     TRISC2_bit = 0;                                   //Configura el pin C2 como salida

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas

     //Configuracion del USART
     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
     
     //Configuracion del puerto SPI en modo Esclavo
     SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
     PIE1.SSP1IE = 1;                                  //Habilita la interrupcion por SPI

     //Configuracion del TMR1 con un tiempo de 250ms
     T1CON = 0x30;                                     //Timer1 Input Clock Prescale Select bits
     TMR1H = 0x0B;
     TMR1L = 0xDC;
     PIR1.TMR1IF = 0;                                  //Limpia la bandera de interrupcion del TMR1
     PIE1.TMR1IE = 1;                                  //Habilita la interrupción de desbordamiento TMR1

     //Configuracion del TMR2 con un tiempo de 2ms
     T2CON = 0x78;                                     //Timer2 Output Postscaler Select bits
     PR2 = 249;
     PIR1.TMR2IF = 0;                                  //Limpia la bandera de interrupcion del TMR2
     PIE1.TMR2IE = 1;                                  //Habilita la interrupción de desbordamiento TMR2

     Delay_ms(100);                                    //Espera hasta que se estabilicen los cambios

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el calculo y comprobacion del CRC
//Esta funcion recibe como parametro una trama y su longitud y devuelve el valor calculado del CRC
unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
     unsigned char ucCounter;
     unsigned int CRC16;                                //Variables para almacenar el CRC calculado, y el CRC de la trama PDU recibida
     for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
          CRC16^=*trama ++;
          for(ucCounter=0; ucCounter<8; ucCounter++){
               if(CRC16 & 0x0001)
               CRC16 = (CRC16>>1)^POLMODBUS;
          else
               CRC16>>=1;
          }
     }
     return CRC16;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para la comprobacion del CRC
//Esta funcion recibe como parametro una trama RS485 y la longitud de la trama PDU, y devuelve un 1 si el CRC calculado coincide con el valor del campo CRC
//de la trama o un 0 en caso contrario
unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
     unsigned char pdu[15];
     unsigned short j;
     unsigned int crcCalculado, crcTrama;               //Variables para almacenar el CRC calculado, y el CRC de la trama recibida
     unsigned short *ptrCRCTrama;                       //Puntero para almacenar los valores del CRC calculado y el de la trama PDU recibida
     crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
     crcTrama = 1;
     for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
         pdu[j] = trama[j+1];
        //UART1_Write(pdu[j]);
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama ACK
//Esta funcion indica que el mensaje fue recibido satisfactoriamente
void EnviarACK(unsigned char puerto){
     unsigned short i;
     if (puerto==1){
        RE_DE = 1;                                      //Establece el Max485 en modo escritura
        UART1_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
        while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
        RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
     } else {
        UART2_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
        while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama NACK
//Esta funcion indica que el mensaje recibido esta corrompido
void EnviarNACK(unsigned char puerto){
     unsigned short i;
     if (puerto==1){
        RE_DE = 1;                                      //Establece el Max485 en modo escritura
        UART1_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
        while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
        RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
     } else {
        UART2_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
        while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros la trama PDU y su numero de elementos
void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(PDU, sizePDU);                //Calcula el CRC de la trama PDU
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por RS485 con los datos de la trama PDU
     tramaRS485[0] = HDR;                               //Añade la cabecera a la trama a enviar
     tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaRS485[sizePDU+3] = END1;                      //Añade el primer delimitador de final de trama
     tramaRS485[sizePDU+4] = END2;                      //Añade el segundo delimitador de final de trama
     RE_DE = 1;                                         //Establece el Max485 en modo escritura
     for (i=0;i<(sizePDU+5);i++){
         if ((i>=1)&&(i<=sizePDU)){
            UART1_Write(PDU[i-1]);                      //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
         }
     }
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
     //Inicializa el Time-Out-Dispositivo
     T1CON.TMR1ON = 1;                                  //Enciende el Timer1
     TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
     TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
     TMR1L = 0xDC;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de datos a la RPi por medio del puerto SPI
//Esta funcion recibe como parametros la trama de datos que se recibio por RS485 y su numero de elementos
void EnviarMensajeSPI(unsigned char *trama, unsigned char pduSize2){
     unsigned short j;
     for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
         pduSPI[j] = trama[j+1];
         UART1_Write(pduSPI[j]);
     }
     RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
     Delay_ms(1);
     RInt = 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){

//Interrupcion SPI
     if (PIR1.SSP1IF){

        PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI

        buffer = SSPBUF;                                //Guarda el contenido del bufeer (lectura)

        //Rutina para procesar recibir la trama de Peticion de la RPi y reenviarla al H/S
        if ((buffer==0xB0)&&(banEsc==0)){               //Verifica si el primer byte es la cabecera de datos
           banLec = 1;                                  //Activa la bandera de lectura
           i = 0;
        }
        if ((banLec==1)&&(buffer!=0xB0)){
           tramaPDU[i] = buffer;
           i++;
        }
        if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
           banLec = 0;                                  //Limpia la bandera de medicion
           banResp = 0;                                 //Activa la bandera de respuesta
           pduSize = i-1;
           EnviarMensajeRS485(tramaPDU,pduSize);
        }
        
        //Rutina para enviar a la Rpi el numero de bytes de la trama PDU
        if ((buffer==0xC0)&&(banResp==0)){              //
           banResp = 1;
        }
        if ((buffer==0xCC)&&(banResp==1)){              //
           banResp = 0;
           banSPI = 1;
           i = 0;
           SSPBUF = t1Size;
           Delay_ms(1);
        }
        
        //Rutina para enviar a la Rpi el contenido de la trama PDU a travez del puerto SPI
        if ((buffer==0xD0)&&(banSPI==1)){
           banSPI = 2;
        }
        if ((buffer!=0xD1)&&(banSPI==2)){              //
           SSPBUF = pduSPI[i];
           Delay_ms(1);
           i++;
        }
        if ((buffer==0xD1)&&(banSPI==2)){
           banSPI = 0;
           i = 0;
        }

     }

//Interrupcion UART1
//Esta interrupcion supervisa el estado del bus RS485, cuando detecta un mensaje procedente de un H/S revisa si el primer byte de la trama es
//la Cabecera, si es asi lo guarda en la trama, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues extrae el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama recibida, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, renviara la trama por el puerto UART1 es decir a travez del bus RS485
     if(PIR1.RC1IF==1){

        IU1 = 1;                                              //Enciende el indicador de interrupcion por UART1
        byteTrama = UART1_Read();                             //Lee el byte de la trama de peticion

        if (banTI==0){
            if ((byteTrama==ACK)){                            //Verifica si recibio un ACK
               //Detiene el Time-Out-Dispositivo
               T1CON.TMR1ON = 0;                              //Apaga el Timer1
               TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
               banTI=0;                                       //Limpia la bandera de inicio de trama
               byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
            }
            if ((byteTrama==NACK)){                           //Verifica si recibio un NACK
               //Detiene el Time-Out-Dispositivo
               T1CON.TMR1ON = 0;                              //Apaga el Timer1
               TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
               if (contadorNACK<3){
                  //EnviarMensajeRS485(tramaSPI, sizeSPI);    //Si recibe un NACK como respuesta, le renvia la trama
                  contadorNACK++;                             //Incrementa en una unidad el valor del contador de NACK
               } else {
                  contadorNACK = 0;                           //Limpia el contador de Time-Out-Trama
               }
               banTI=0;                                       //Limpia la bandera de inicio de trama
               byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
            }
            if ((byteTrama==HDR)){
               banTI = 1;                                     //Activa la bandera de inicio de trama
               i1 = 0;                                        //Define en 1 el subindice de la trama de peticion
               tramaOk = 9;                                   //Limpia la variable que indica si la trama ha llegado correctamente
               //Inicializa el Time-Out-Trama, t=2ms
               T2CON.TMR2ON = 1;                              //Enciende el Timer2
               PR2 = 249;                                     //Se carga el valor del preload correspondiente al tiempo de 2ms
            }
        }
        
        //Si en el paso anterior recibio una cabecera aqui termina de llenar la trama de datos
        //Cada vez que entra en esta etapa apaga el Time-Out-Trama y lo vuelve a encender al salir, excepto cuando termina de completar la trama
        if (banTI==1){                                        //Verifica que la bandera de inicio de trama este activa
           PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR2
           T2CON.TMR2ON = 0;                                  //Apaga el Timer2
           if (byteTrama!=END2){                              //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
              i1++;                                           //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                      //Limpia la bandera de final de trama
              T2CON.TMR2ON = 1;                               //Enciende el Timer2
              PR2 = 249;
           } else {
              tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
              banTF = 1;                                      //Si el dato recibido es el primer byte de final de trama activa la bandera
              T2CON.TMR2ON = 1;                               //Enciende el Timer2
              PR2 = 249;
           }
           if (BanTF==1){                                     //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                      //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                      //Activa la bandera de trama completa
              t1Size = tramaRS485[4]+4;                       //calcula la longitud de la trama PDU sumando 4 al valor del campo #Datos
              PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
              T2CON.TMR2ON = 0;                               //Apaga el Timer2
           }
        }
        
        //Aqui procesa el contenido de la trama de peticion
        if (banTC==1){                                        //Verifica que se haya completado de llenar la trama de peticion
           tramaOk = 0;
           tramaOk = VerificarCRC(tramaRS485,t1Size);         //Calcula y verifica el CRC de la trama de peticion
           if (tramaOk==1){
               EnviarACK(1);                                  //Si la trama llego sin errores responde con un ACK al H/S
               EnviarMensajeSPI(tramaRS485,t1Size);         //Invoca esta funcion para enviar los datos a la RPi por SPI
           } else {
               EnviarNACK(1);                                 //Si hubo algun error en la trama se envia un NACK al H/S
           }
           banTI = 0;                                         //Limpia la bandera de inicio de trama
           banTC = 0;                                         //Limpia la bandera de trama completa
           i1 = 0;                                            //Incializa el subindice de la trama de peticion
        }

        IU1 = 0;
        
     }


//Interrupcion por TIMER1 (Time-Out-Dispositivo)
//Si se produce una interrupcion por desbordamiento del TMR1 quiere decir que se cumplio el tiempo establecido por el Time-Out-Dispositivo
     if (TMR1IF_bit==1){
        TMR1IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR1
        T1CON.TMR1ON = 0;                                     //Apaga el Timer1
        if (contadorTOD<3){
           //EnviarMensajeRS485(tramaPDU, sizeTramaPDU);      //Reenvia la trama por el bus RS485
           contadorTOD++;                                     //Incrementa el contador de Time-Out-Dispositivo en una unidad
        } else {
           //EnviarMensajeSPI()                               //Responde al Master notificandole del error
           contadorTOD = 0;                                   //Limpia el contador de Time-Out-Dispositivo
        }
     }

//Interrupcion por TIMER2 (Time-Out-Trama)
//Si se produce una interrupcion por desbordamiento del TMR2 quiere decir que se cumplio el tiempo establecido por el Time-Out-Trama,
//por lo que se debe descartar la trama actual. Esto se logra limpiando la bandera de inicio de trama y encerando el subindice de trama,
//de esta manera si llega otro dato por el Uart y este es diferente del encabezamiento de inicio de trama ya no se almacenara en la trama de respuesta.
//Tambien se envia un NACK para pedir el renvio de la trama
     if (TMR2IF_bit==1){
        TMR2IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR2
        T2CON.TMR2ON = 0;                                     //Apaga el Timer2
        banTI = 0;                                            //Limpia la bandera de inicio de trama
        i1 = 0;                                               //Limpia el subindice de la trama de peticion
        banTC = 0;                                            //Limpia la bandera de trama completa(Por si acaso)
        if (puertoTOT==1){
            EnviarNACK(1);                                    //Envia un NACK por el puerto UART1 para solicitar el reenvio de la trama
        } else if (puertoTOT==2) {
            EnviarNACK(2);                                    //Envia un NACK por el puerto UART2 para solicitar el reenvio de la trama
        }
        puertoTOT = 0;                                        //Encera la variable para evitar confusiones
     }

}



void main() {

     ConfiguracionPrincipal();
     RE_DE = 0;                                               //Establece el Max485-1 en modo de lectura;
     RInt = 0;
     i1=0;
     i2=0;
     contadorTOD = 0;                                         //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                        //Inicia el contador de NACK
     banTI=0;                                                 //Limpia la bandera de inicio de trama
     banTC=0;                                                 //Limpia la bandera de trama completa
     banTF=0;                                                 //Limpia la bandera de final de trama
     
     AUX = 0;
     t1Size = 0;
     
}