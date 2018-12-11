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
sbit IU1 at RB2_bit;                                    //Definicion del pin de indicador de interrupcion por UART1
sbit IU1_Direction at TRISB2_bit;
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

unsigned short idEsclavo;                               //Variable para almacenar el ID del modulo EsclavoSensor
unsigned short funcEsclavo;                             //Variable para almacenar las funciones disponibles del modulo EsclavoSensor
unsigned short regLecturaEsclavo;                       //Variable para almacenar los registros de lectura disponibles del modulo EsclavoSensor
unsigned short regEscrituraEsclavo;                     //Variable para almacenar los registros de escritura disponibles del modulo EsclavoSensor

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned short t1IdEsclavo;                             //Variable para almacenar el Id de esclavo de la trama de peticion
unsigned short t1Funcion;                               //Variable para almacenar la funcion requerida en la trama de peticion
unsigned short t1Registro;                              //Variable para almacenar el registro requerido en la trama de peticion
unsigned char tramaSerial[15];                          //Vector de trama de datos del puerto UART1
unsigned char datosEscritura[4];                        //Vector para almacenar los datos necesarios para las solicitudes de escritura
unsigned short numDatosEsc;                             //Variable para almacenar el numero de datos de escritura
short i1;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char petSPI[4];                                //Vector para realizar la solicitud SPI al EsclavoSensor
unsigned char resSPI[10];                               //Vector para almacenar la respuesta devuelta por el EsclavoSensor
unsigned short direccionEsc;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short numBytesSPI;                             //Variable para guardar el numero de bytes que se necesita para almacenar la respuesta del EsclavoSensor
unsigned short numDatos;                                //Variable para guardar el numero de datos del Payload de la trama PDU
unsigned short banMed;

unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK

unsigned short x;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     TRISB0_bit = 1;
     TRISB2_bit = 0;
     TRISB3_bit = 0;
     TRISC2_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     PIE1.RCIE = 1;
     
     //Configuracion del puerto SPI
     SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);

     //Configuracion del TMR1 con un tiempo de 250ms
     T1CON = 0x30;
     PIR1.TMR1IF = 0;
     TMR1H = 0x0B;
     TMR1L = 0xDC;
     PIE1.TMR1IE = 1;
     INTCON = 0xC0;

     //Configuracion del TMR2 con un tiempo de 2ms
     T2CON = 0x78;
     PR2 = 249;
     PIR1.TMR2IF = 0;
     PIE1.TMR2IE = 1;

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
//Funcion para el envio de un mensaje de respuesta
//Esta funcion recibe como parametros la trama PDU y su tamaño, y envia la trama de peticion completa a travez de RS485
void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por RS485 con los datos de la trama PDU
     tramaSerial[0]=HDR;                                //Añade la cabecera a la trama a enviar
     tramaSerial[sizePDU+2] = *ptrCrcPdu;               //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);           //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaSerial[sizePDU+3] = END1;                     //Añade el primer delimitador de final de trama
     tramaSerial[sizePDU+4] = END2;                     //Añade el segundo delimitador de final de trama
     for (i=0;i<(sizePDU+5);i++){
         if ((i>=1)&&(i<=sizePDU)){
            UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
         }
     }
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar

     //Aqui esta el problema, o tal vez funciona correctamente debido a que no obtiene como respuesta el ACK
     //Inicializa el Time-Out-Dispositivo
     /*T1CON.TMR1ON = 1;                                  //Enciende el Timer1
     TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
     TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
     TMR1L = 0xDC;*/
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de un mensaje de respuest de error
//Esta funcion recibe como parametros el codigo de error
void EnviarMensajeError(unsigned short numRegistro,unsigned short codigoError){
     unsigned char i;
     unsigned int CRCerrorPDU;
     unsigned short *ptrCRCerrorPDU;
     unsigned char errorPDU[4];
     errorPDU[0] = idEsclavo;
     errorPDU[1] = 0xEE;                                //Cambia el valor del campo Funcion por el codigo 0xEE para indicar que se ha producido un error
     errorPDU[2] = numRegistro;                         //Numero de registro que se solocito leer/escribir
     errorPDU[3] = 0x01;                                //Numero de datos del pyload de la trama PDU
     errorPDU[4] = codigoError;                         //Codigo de error producido
     CRCerrorPDU = CalcularCRC(errorPDU,5);             //Calcula el CRC de la trama errorPDU
     ptrCRCerrorPDU = &CRCerrorPDU;                     //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por serial con los datos de la trama PDU
     tramaSerial[0] = HDR;                              //Añade la cabecera a la trama a enviar
     tramaSerial[6] = *(ptrCRCerrorPDU+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaSerial[7] = *ptrCRCerrorPDU;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaSerial[8] = END1;                             //Añade el primer delimitador de final de trama
     tramaSerial[9] = END2;                             //Añade el segundo delimitador de final de trama
     for (i=0;i<(10);i++){
         if ((i>=1)&&(i<=5)){
            UART1_Write(errorPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
         } else {
            UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
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
//Funcion para identificar el Esclavo conecatdo por SPI
//Esta funcion envia una solicitud al EsclavoSensor y este le devuelve su codigo identificador, el numero de funciones disponibles, el numero de registros de lectura y el numero de registros de escritura Esta funcion sera ejecutada una sola vez al encender este modulo.
void IdentificarEsclavo(){
     petSPI[0] = 0xA0;
     petSPI[1] = 0xA1;
     petSPI[2] = 0xA2;
     petSPI[3] = 0xA3;
     petSPI[4] = 0xA4;
     petSPI[5] = 0xA5;
     CS = 0;
     for (x=0;x<6;x++){
         SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
         if (x==2){
            while (SSPSTAT.BF!=1);
            idEsclavo = SSPBUF;               //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
         }
         if (x==3){
            while (SSPSTAT.BF!=1);
            funcEsclavo = SSPBUF;              //Recupera el numero de funciones disponibles en el modulo EsclavoSensor
         }
         if (x==4){
            while (SSPSTAT.BF!=1);
            regLecturaEsclavo = SSPBUF;        //Recupera el numero de registros de lectura disponibles en el modulo EsclavoSensor
         }
         if (x==5){
            while (SSPSTAT.BF!=1);
            regEscrituraEsclavo = SSPBUF;      //Recupera el numero de registros de escritura disponibles en el modulo EsclavoSensor
         }

         Delay_ms(1);
     }
     CS = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una peticion al EsclavoSensor por SPI
//Esta funcion envia una solicitud de medicion al dispositivo EsclavoSensor, recibe como parametro el codigo del registro que se quiere leer en el EsclavoSensor
void EnviarSolicitudLectura(unsigned short registroLectura){
     petSPI[0] = 0xB0;                        //Cabecera de trama de solicitud de medicion
     petSPI[1] = registroLectura;             //Codigo del registro que se quiere leer
     petSPI[2] = 0xB1;                        //Delimitador de final de trama
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
     banMed = 1;                              //Activa la bandera de medicion para evitar que existan falsos positivos en la interrupcion externa
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una peticion al EsclavoSensor por SPI
//Esta funcion envia una solicitud de medicion al dispositivo EsclavoSensor, recibe como parametro el codigo del registro que se quiere leer en el EsclavoSensor
void EnviarSolicitudEscritura(unsigned short registroEscritura, unsigned short numDatos, unsigned char* datos){
     CS = 0;
     SSPBUF = 0XD0;                           //Llena el buffer de salida con el valor de la cabecera de solicitud de escritura
     Delay_ms(1);
     SSPBUF = registroEscritura;              //Llena el buffer de salida con el valor del registro que se quiere leer
     Delay_ms(1);
     SSPBUF = numDatos;                       //Llena el buffer de salida con el valor del numero de datos
     Delay_ms(1);
     for (x=0;x<numDatos;x++){
         SSPBUF = datos[x];                   //Llena el buffer de salida con cada valor de la tramaSPI
         Delay_ms(1);
     }
     CS = 1;
     //Aqui tal vez seria bueno agregar una rutina que verifique si tuvo respuesta
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa
//Al detectar la interrupcion externa generada por el dispositivo EsclavoSensor recibe los datos de este a travez del SPI y los reenvia en forma de trama completa a travez del puerto uart
     if (INTCON.INTF==1){
        INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
        if (banMed==1){
           
           CS = 0;                                      //Coloca en bajo el pin CS para abrir la transmision
           for (x=0;x<(numBytesSPI+1);x++){
               SSPBUF = 0xCC;                           //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
               if ((x>0)){
                  while (SSPSTAT.BF!=1);
                  resSPI[x+3] = SSPBUF;                 //Guarda la respuesta del EsclavoSensor en el vector resSPI a partir de la cuarta posicion
               }
               Delay_us(200);
           }
           CS = 1;                                      //Coloca en alto el pin CS para cerrar la transmision
           
           resSPI[0] = idEsclavo;                       //Guarda en la primera posicion del vector PDU de respuesta el id del Esclavo
           resSPI[1] = t1Funcion;                       //Guarda en la segunda posicion del vector PDU el codigo de funcion requerido
           resSPI[2] = t1Registro;                      //Guarda en la tercera posicion del vector PDU el # de registro requerido
           resSPI[3] = numBytesSPI;                     //Guarda en la cuarta posicion del vector PDU de respuesta el numero de bytes del payload
        
        }
        banMed=0;
        
        EnviarMensajeUART(resSPI,(numBytesSPI+4));
        
     }

//Interrupcion UART1
//Esta interrupcion supervisa el estado del bus RS485, cuando detecta una peticion procediente del Master revisa si el prmer byte de la trama es
//la Cabecera, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues guarda el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama de peticion, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, comprueba el campo de Direccion, si es igual a 0xFF dara paso al
//proceso de calibracion, caso contrario renviara la trama por el puerto UART2 es decir a travez de los modulos inhalabricos hacia los esclavos.
     if (PIR1.RCIF==1){

        IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
        AUX = 1;

        if (banTI==0){
            if ((byteTrama==ACK)){                          //Verifica si recibio un ACK
               //Detiene el Time-Out-Dispositivo
               T1CON.TMR1ON = 0;                            //Apaga el Timer1
               TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
               banTI=0;                                     //Limpia la bandera de inicio de trama
               byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
            }

            if ((byteTrama==NACK)){                         //Verifica si recibio un NACK
               //Detiene el Time-Out-Dispositivo
               T1CON.TMR1ON = 0;                            //Apaga el Timer1
               TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
               if (contadorNACK<3){
                  //EnviarMensajeRS485(tramaSPI, sizeSPI);    //Si recibe un NACK como respuesta, le renvia la trama
                  contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
               } else {
                  contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
               }
               banTI=0;                                     //Limpia la bandera de inicio de trama
               byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
            }

            if ((byteTrama==HDR)){
               banTI = 1;                                   //Activa la bandera de inicio de trama
               i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
               tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
               //Inicializa el Time-Out-Trama, t=2ms
               T2CON.TMR2ON = 1;                            //Enciende el Timer2
               PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
            }
        }

        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
           T2CON.TMR2ON = 0;                            //Apaga el Timer2
           if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
              i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                //Limpia la bandera de final de trama
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;
           } else {
              tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
              banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;
           }
           if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                //Activa la bandera de trama completa
              t1IdEsclavo = tramaSerial[1];             //Guarda el byte de Id de esclavo del campo PDU
              PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
              T2CON.TMR2ON = 0;                         //Apaga el Timer2
           }
        }

        if (banTC==1){                                             //Verifica que se haya completado de llenar la trama de peticion
           if (t1IdEsclavo==IdEsclavo){                            //Verifica si coincide el Id de esclavo para seguir con el procesamiento de la peticion
               numDatosEsc = tramaSerial[4];
               t1Size = numDatosEsc+4;                             //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
               t1Funcion = tramaSerial[2];                         //Guarda el byte de funcion reequerida del campo PDU
               t1Registro = tramaSerial[3];                        //Guarda el byte de # de registro que se quiere leer/escribir
               tramaOk = VerificarCRC(tramaSerial,t1Size);         //Calcula y verifica el CRC de la trama de peticion
               if (tramaOk==1){
                   EnviarACK();                                    //Si la trama llego sin errores responde con un ACK al esclavo
                   //Aqui comprueba si existe la funcion solicitada, como todas las funciones estan ordenadas en forma secuencial basta con verificar 
                   //si el numero de la funcion solicitada es mayor al numero de funciones disponibles en el EsclavoSensor envia un mensaje de error
                   if (t1Funcion<=funcEsclavo){
                      if (t1Funcion==0){                           //Verifica si se solicito una funcion de lectura
                         if (t1Registro<regLecturaEsclavo){        //Verifica si existe el registro de lectura solicitado
                            EnviarSolicitudLectura(t1Registro);    //Envia una solicitud de lectura del registro especificado al modulo EsclavoSensor
                         } else {
                            EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
                         }
                      } else {                                     //Caso contrario se trata de una funcion de escritura
                         if (t1Registro<regEscrituraEsclavo){      //Verifica si existe el registro de lectura solicitado
                             for (x=0;x<(tramaSerial[4]);x++){
                                 datosEscritura[x]=tramaSerial[x+5];      //Carga el vector payload con los valores de la trama serial
                             }
                            //Envia una solicitud de lectura del registro especificado al modulo EsclavoSensor:
                            EnviarSolicitudEscritura(t1Registro,numDatosEsc,datosEscritura);
                         } else {
                            EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
                         }
                      }
                   } else {
                      EnviarMensajeError(t1Registro,0xE0);         //Envia un mensaje de error con el codigo de "Funcion no disponible"
                   }
               } else if (tramaOk==0) {
                   EnviarNACK();                                   //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
               }
           }
           banTC = 0;                               //Limpia la bandera de trama completa
           i1 = 0;                                  //Limpia el subindice de trama
           banTI = 0;
        }

        PIR1.RCIF = 0;
        IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
        AUX = 0;

     }


//Interrupcion por TIMER1 (Time-Out-Dispositivo)
//Si se produce una interrupcion por desbordamiento del TMR1 quiere decir que se cumplio el tiempo establecido por el Time-Out-Dispositivo,
//
     if (PIR1.TMR1IF==1){
        TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
        T1CON.TMR1ON = 0;                               //Apaga el Timer1
        if (contadorTOD<3){
           //EnviarMensajeRS485(tramaSPI, sizeSPI);       //Reenvia la trama por el bus RS485
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
        PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
        T2CON.TMR2ON = 0;                               //Apaga el Timer2
        i1 = 0;                                         //Limpia el subindice de la trama de peticion
        banTI = 0;                                      //Limpia la bandera de inicio de trama
        banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
        banTF = 0;
        EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
     }

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void main() {

     ConfiguracionPrincipal();                          //Inicia las configuraciones necesarias
     IdentificarEsclavo();                              //Con esta funcion determina cual es el codigo identificador del dispositivo EsclavoSensor conectado por SPI
     CS = 1;                                            //Desabilita el CS
     AUX = 0;
     IU1 = 0;
     i1=0;
     contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                  //Inicia el contador de NACK
     banTI = 0;
     banTC = 0;
     banTF = 0;
     banMed = 0;
     numDatosEsc = 0;
}