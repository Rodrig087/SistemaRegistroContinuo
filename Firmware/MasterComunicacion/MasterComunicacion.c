/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 5/11/2018
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

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
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
     TRISB1_bit = 0;
     TRISB2_bit = 1;
     TRISB3_bit = 0;
     TRISB5_bit = 0;
     TRISB6_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps

     //Configuracion del TMR1 con un tiempo de 250ms
     T1CON = 0x30;
     TMR1IF_bit = 0;
     TMR1H = 0x0B;
     TMR1L = 0xDC;
     TMR1IE_bit = 1;
     INTCON = 0xC0;

     //Configuracion del TMR2 con un tiempo de 2ms
     T2CON = 0x78;
     PR2 = 249;
     TMR2IE_bit        = 1;

     //Configuracion de la interrupcion externa (simula la interrupcion por SPI)
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

//Interrupcion Externa
//Esta interrupcion simula lo que debe hacer el dipositivo MasterComunicacion al recibir una peticion del RPi por SPI
     if (INTCON.INTF==1){
        INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
        //Aqui va la parte donde realiza la toma de datos que llegan por SPI desde la Rpi
        tramaSPI[0]=0x03;                               //Ejemplo de trama de peticion enviada por la RPi
        tramaSPI[1]=0x05;                               //CRC=0xF3C2
        tramaSPI[2]=0x05;
        tramaSPI[3]=0x06;
        tramaSPI[4]=0x07;

        direccionRpi = tramaSPI[0];                     //Guarda el dato de la direccion del dispositvo con que se desea comunicar
        sizeSPI = tramaSPI[1];                          //Guarda el dato de la longitud de la trama PDU
        funcionRpi = tramaSPI[2];                       //Guarda el dato de la funcion requerida

        if (direccionRpi==0xFD || direccionRpi==0xFE || direccionRpi==0xFF){
           if (funcionRpi==0x01){                       //Verifica el campo de Funcion para ver si se trata de una sincronizacion de segundos
              //SincronizacionSegundos();               //Invoca a la funcion de sincronizacion de segundos
           } else if (funcionRpi==0x02){                //Verifica el campo de Funcion para ver si se trata de una solicitud de sincronizacion de fecha y hora
              //SincronizacionFechaHora();              //Invoca a la funcion de sincronizacion de fecha y hora
           } else {
              EnviarMensajeRS485(tramaSPI, sizeSPI);    //Invoca a la funcion para enviar la peticion
           }
        } else {
           EnviarMensajeRS485(tramaSPI, sizeSPI);       //Invoca a la funcion para enviar la peticion
        }

     }

//Interrupcion UART1
//Esta interrupcion supervisa el estado del bus RS485, cuando detecta una peticion procediente del Master revisa si el prmer byte de la trama es
//la Cabecera, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues guarda el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama de peticion, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, comprueba el campo de Direccion, si es igual a 0xFF dara paso al
//proceso de calibracion, caso contrario renviara la trama por el puerto UART2 es decir a travez de los modulos inhalabricos hacia los esclavos.
     if (PIR1.F5==1){

        IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion

        if ((byteTrama==ACK)&&(banTI==0)){              //Verifica si recibio un ACK
           //Detiene el Time-Out-Dispositivo
           TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
           T1CON.TMR1ON = 0;                            //Apaga el Timer1
           banTI=0;                                     //Limpia la bandera de inicio de trama
           byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
        }

        if ((byteTrama==NACK)&&(banTI==0)){             //Verifica si recibio un NACK
           //Detiene el Time-Out-Dispositivo
           TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
           T1CON.TMR1ON = 0;                            //Apaga el Timer1
           if (contadorNACK<3){
              EnviarMensajeRS485(tramaSPI, sizeSPI);    //Si recibe un NACK como respuesta, le renvia la trama
              contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
           } else {
              //EnviarMensajeSPI()                      //Responde a la RPI notificandole del error
              contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
              EnviarACK();
           }
           banTI=0;                                     //Limpia la bandera de inicio de trama
           byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
        }

        if ((byteTrama==HDR)&&(banTI==0)){
           tramaRS485[0]=byteTrama;                     //Guarda el primer byte de la trama en la primera posicion de la trama de peticion
           banTI = 1;                                   //Activa la bandera de inicio de trama
           i1 = 1;                                      //Define en 1 el subindice de la trama de peticion
           tramaOk = 0;                                 //Limpia la variable que indica si la trama ha llegado correctamente
           //Inicializa el Time-Out-Trama, t=2ms
           //T2CON.TMR2ON = 1;                            //Enciende el Timer2
           //PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
        }

        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa

        }

        
        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion

           tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion

           if (tramaOk==1){
               EnviarACK();                             //Si la trama llego sin errores responde con un ACK al esclavo
               //EnviarMensajeSPI()                     //Envia la respuesta a la RPi
           } else {
               EnviarNACK();                            //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
           }
           banTC = 0;                                   //Limpia la bandera de trama completa
           i1 = 0;                                      //Limpia el subindice de trama

        }

        PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion de UART2
        IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2


     }


//Interrupcion por TIMER1 (Time-Out-Dispositivo)
//Si se produce una interrupcion por desbordamiento del TMR1 quiere decir que se cumplio el tiempo establecido por el Time-Out-Dispositivo,
//
     if (PIR1.TMR1IF==1){
        TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
        T1CON.TMR1ON = 0;                               //Apaga el Timer1
        //**R: byteTrama=0;                                    //Limpia la variable del byte de la trama de peticion
        if (contadorTOD<3){
           EnviarMensajeRS485(tramaSPI, sizeSPI);       //Reenvia la trama por el bus RS485
           contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
        } else {
           //EnviarMensajeSPI()                         //Responde a la RPI notificandole del error
           contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
        }
     }

//Interrupcion por TIMER2 (Time-Out-Trama)
//Si se produce una interrupcion por desbordamiento del TMR2 quiere decir que se cumplio el tiempo establecido por el Time-Out-Trama,
//por lo que se debe descartar la trama actual. Esto se logra limpiando la bandera de inicio de trama y encerando el subindice de trama,
//de esta manera si llega otro dato por el Uart y este es diferente del encabezamiento de inicio de trama ya no se almacenara en la trama de respuesta.
//Tambien se envia un NACK para pedir el renvio de la trama
     if (PIR1.TMR2IF==1){
        TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
        T2CON.TMR2ON = 0;                               //Apaga el Timer2
        banTI = 0;                                      //Limpia la bandera de inicio de trama
        i1 = 0;                                         //Limpia el subindice de la trama de peticion
        banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
        EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
     }

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void main() {

     ConfiguracionPrincipal();
     RE_DE = 1;                                         //Establece el Max485-1 en modo de lectura;
     i1=0;
     contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                  //Inicia el contador de NACK
     byteTrama=0;                                       //Limpia la variable del byte de la trama de peticion
     banTI=0;                                           //Limpia la bandera de inicio de trama
     banTC=0;                                           //Limpia la bandera de trama completa
     banTF=0;                                           //Limpia la bandera de final de trama
     
}