/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 17/10/2018
Configuracion: PIC18F25k22 XT=8MHz
Observaciones:
Lo ultimo que hice el miercoles 31 de octubre fue revisar la secuencia de instrucciones de la bandera banTC=1 de la interrupcion UART1
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
sbit RE_DE at RC5_bit;                                  //Definicion del pin RE_DE
sbit RE_DE_Direction at TRISC5_bit;

sbit IU1 at RC4_bit;                                    //Definicion del pin de indicador de interrupcion por UART1
sbit IU1_Direction at TRISC4_bit;
sbit IU2 at RB3_bit;                                    //Definicion del pin de indicador de interrupcion por UART2
sbit IU2_Direction at TRISB3_bit;

sbit ENABLE at RB5_bit;                                 //Definicion del pin ENABLE del modulo APC220
sbit ENABLE_Direction at TRISB5_bit;
sbit SET at RB4_bit;                                    //Definicion del pin SET del modulo APC220
sbit SET_Direction at TRISB4_bit;

const short DIR = 0xFD;                                 //Direccion de este dispositivo
const short HDR = 0x3A;                                 //Constante de delimitador de inicio de trama
const short END1 = 0x0D;                                //Constante de delimitador 1 de final de trama
const short END2 = 0x0A;                                //Constante de delimitador 2 de final de trama
const short ACK = 0xAA;                                 //Constante de mensaje ACK
const short NACK = 0xAF;                                //Constante de mensaje NACK
const unsigned int POLMODBUS = 0xA001;                  //Polinomio para el calculo del CRC

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size, t2Size, sizeTramaPDU;            //Variables de longitud de tramas de peticion, respuesta y PDU
unsigned char tramaRS485[50];                           //Vector de trama de datos del puerto UART1
unsigned char tramaPDU[50];                             //Vector para almacenar los valores de la trama PDU creada localmente
unsigned char u2Trama[50];                              //Vector de trama de datos del puerto UART2
short i1, i2;                                           //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;
unsigned short contadorTOD;                             //Contador de Time-Out-Dispositivo
unsigned short contadorNACK;                            //Contador de NACK
unsigned short puertoTOT;                               //Especifica el puerto por cual enviar el NACK en caso de producirse un Time-Out-Trama
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISB5_bit = 0;                                   //Configura el pin B5 como salida
     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISB4_bit = 0;                                   //Configura el pin B5 como salida
     TRISC4_bit = 0;                                   //Configura el pin C5 como salida

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas

     //Configuracion del USART
     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
     PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
     PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
     UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
     UART2_Init(19200);                                //Inicializa el UART2 a 9600 bps

     //Configuracion del TMR1 con un tiempo de 250ms
     T1CON = 0x30;
     TMR1IF_bit = 0;
     TMR1H = 0x0B;
     TMR1L = 0xDC;
     TMR1IE_bit = 1;

     //Configuracion del TMR2 con un tiempo de 2ms
     T2CON = 0x78;
     TMR2IF_bit = 0;
     PR2 = 249;
     TMR2IE_bit        = 1;

     Delay_ms(100);                                    //Espera hasta que se estabilicen los cambios
     
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para la comprobacion del CRC
//Esta funcion recibe como parametro una trama RS485 y la longitud de la trama PDU, y devuelve un 1 si el CRC calculado coincide con el valor del campo CRC
//de la trama o un 0 en caso contrario
unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
     unsigned char* pdu;
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama ACK
//Esta funcion indica que el mensaje fue recibido satisfactoriamente
void EnviarACK(unsigned char puerto){
     unsigned short i;
     if (puerto==1){
        RE_DE = 1;                                     //Establece el Max485 en modo escritura
        UART1_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
        while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
        RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
     } else {
        UART2_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
        while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama NACK
//Esta funcion indica que el mensaje recibido esta corrompido
void EnviarNACK(unsigned char puerto){
     unsigned short i;
     if (puerto==1){
        RE_DE = 1;                                     //Establece el Max485 en modo escritura
        UART1_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
        while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
        RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
     } else {
        UART2_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
        while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros el puerto UART, la trama de datos y el numero de elementos
void RenviarTrama(unsigned char puerto, unsigned char *trama, unsigned char numDatos){
     unsigned char i;
     if (puerto==1){
        RE_DE = 1;                                     //Establece el Max485 en modo escritura
        for (i=0;i<(numDatos);i++){
            UART1_Write(trama[i]);                     //Reenvia la trama de peticion a travez del UART1
        }
        while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
        RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
     } else {
        for (i=0;i<(numDatos);i++){
            UART2_Write(trama[i]);                     //Reenvia la trama de peticion a travez del UART2
        }
        while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     }
     
     //Aqui deberia poner lo que pasa cuando no recibe la respuesta ACK en x tiempo
     //Tal vez deberia usar otro Timer
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros el puerto UART, la direccion del esclavo que genero el error, el tipo de error,
void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
     unsigned char i;
     unsigned int CRCPDU;
     unsigned short *ptrCRCPDU;
     CRCPDU = CalcularCRC(PDU, sizePDU);           //Calcula el CRC de la trama PDU
     ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
     //Rellena la trama que se enviara por RS485 con los datos de la trama PDU
     tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
     tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
     tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
     tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
     tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
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
//Funcion para la configuracion del modulo APC220
//Esta funcion recibe como parametros una trama de datos en cuyo campo PDU estaran las especificaciones requeridas:
//Freceuncia, RFdatarate, OutputPower, UARTdatarate, Sin checkout
void ConfiguracionAPC220(unsigned char *trama, unsigned char tramaSize){
     unsigned char* datos;
     unsigned short k=0;
     unsigned short datosSize = tramaSize-8;
     while (k<=datosSize){
         datos[k] = trama[k+3]+0x30;                    //Rellena la trama de datos en formato ASCII
         k++;
         if (k==6||k==8||k==10||k==12||k==14){
            datos[k] = 0x20;                            //Coloca un codigo de espacio para dividir los datos
            k++;
         }
     }
     SET = 0;                                           //Establece el modulo APC en modo configuracion
     UART2_Init(9600);                                  //Establece la velocidad del puerto UART2 en 9600 para realizar la configuracion
     Delay_ms(5);                                       //Espera hasta que se estabilicen el modulo APC
     UART2_Write(0x57);                                 //Envia el comando WR para iniciar la configuracion
     UART2_Write(0x52);
     UART2_Write(0x20);
     for (k=0;k<(datosSize);k++){
         UART2_Write(datos[k]);                         //Envia la trama de configuracion al modulo APC
     }
     UART2_Write(0x0D);                                 //Envia el delimitador de final de trama
     UART2_Write(0x0A);
     while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     Delay_ms(200);                                     //Espera hasta que el modulo procese la configuracion
     //Aqui el modulo APC devuelve un mensaje de confirmacion, pero este sera atendido por la interrupcion UART2 y descartada por que no tiene el byte
     //de cabecera.
     Delay_ms(5);
     SET = 1;                                           //Establece el modulo APC en modo de funcionamiento normal
     UART2_Init(19200);                                 //Vuelve a fijar la velocidad del puerto UART2 en 19200
     Delay_ms(100);                                     //Espera hasta que el puerto UART se estabilice
     RenviarTrama(1,trama,tramaSize);                   //Reenvia la trama de peticion al Master paraindicar que la solicitud se ha procesado correctamente
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){

//Interrupcion UART1
//Esta interrupcion supervisa el estado del bus RS485, cuando detecta una peticion procediente del Master revisa si el prmer byte de la trama es
//la Cabecera, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues guarda el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama de peticion, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, comprueba el campo de Direccion, si es igual a 0xFF dara paso al 
//proceso de calibracion, caso contrario renviara la trama por el puerto UART2 es decir a travez de los modulos inhalabricos hacia los esclavos.
     if(PIR1.F5==1){
     
        IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
        
        //Verifica si el primer byte en llegar es una cabecera, un ACK o un NACK
        if (banTI==0){                                  //Verifica que la bandera de inicio de trama este apagada
            if (byteTrama==HDR){                        //Verifica si recibio una cabecera
              tramaRS485[0]=byteTrama;                  //Guarda el primer byte de la trama en la primera posicion de la trama de peticion
              banTI = 1;                                //Activa la bandera de inicio de trama
              i1 = 1;                                   //Define en 1 el subindice de la trama de peticion
              tramaOk = 0;                              //Limpia la variable que indica si la trama ha llegado correctamente
              puertoTOT = 1;                            //Indica al Time-Out-Trama que de ser necesario envie el NACK por el puerto UART1
              //Inicializa el Time-Out-Trama, t=2ms
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
           }
           if (byteTrama==ACK){                         //Verifica si recibio un ACK
              //Detiene el Time-Out-Dispositivo
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
           }
           if (byteTrama==NACK){                        //Verifica si recibio un NACK
              //Detiene el Time-Out-Dispositivo
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
              if (contadorNACK<3){
                 EnviarMensajeRS485(tramaRS485,sizeTramaPDU);
                 contadorNACK++;                        //Incrrmenta en una unidad el valor del contador de NACK
              } else {
                 contadorNACK = 0;                      //Solo puede resetear el contador de NACK por que no puede comunicarse con el dispositivo jerarquico superior (Master) para notificarle el error
              }
           }
        }
        
        //Si en el paso anterior recibio una cabecera aqui termina de llenar la trama de datos
        //Cada vez que entra en esta etapa apaga el Time-Out-Trama y lo vuelve a encender al salir, excepto cuando termina de completar la trama
        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           T2CON.TMR2ON = 0;                            //Detiene el Time-Out-Trama
           if (i1==1){
              tramaRS485[i1] = byteTrama;               //Guarda el byte de Direccion en la segunda posicion del vector de peticion
              i1 = 2;                                   //Incrementa el subindice de la trama de peticion en una unidad
              T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
              PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
           } else if (i1=2){
              tramaRS485[i1] = byteTrama;               //Guarda el byte de #Datos en la tercera posicion del vector de peticion
              t1Size = byteTrama;                       //Guarda en la variable t1Size el valor del campo #Datos, este campo tiene informacion de la longitud de la trama PDU
              i1 = 3;                                   //Incrementa el subindice de la trama de peticion en una unidad
              T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
              PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
           } else if ((i1>2)&&(i1<t1Size)){
              tramaRS485[i1] = byteTrama;               //Guarda el resto de bytes en el vector de peticion hasta que se complete el numero de bytes especificado en el campo #Datos
              i1=i1+1;                                  //Incrementa el subindice de la trama de peticion en una unidad
              T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
              if (i1==t1Size-1){
                 banTI = 0;                             //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
                 banTC = 1;                             //Activa la bandera de trama completa
                 T2CON.TMR2ON = 0;                      //Apaga el Time-Out-Trama
              }
           }
        }
        
        //Aqui procesa el contenido de la trama de peticion
        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
           tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion
           
           //Si la trama llego sin errores responde con un ACK al master y luego reenvia la trama a los esclavos
           //Si hubo algun error no hace nada, el master renviara la peticion al no recibir respuesta en un tiempo determinado
           if (tramaOk==1){
               EnviarACK(1);                            //Invoca a la funcion EnviarACK() para notificar al remitente que la trama llego sin errores
               if (tramaRS485[1]==DIR){                 //Verifica si la direccion es FFh para comprobar si se trata de una solicitud de sincronizacion.
                  if (tramaRS485[3]==0x01){             //Verifica el campo de Funcion para ver si se trata de una sincronizacion de segundos
                     //SincronizacionSegundos();        //Invoca a la funcion de sincronizacion de segundos
                  } else if (tramaRS485[3]==0x02){      //Verifica el campo de Funcion para ver si se trata de una solicitud de sincronizacion de fecha y hora
                     //SincronizacionFechaHora();       //Invoca a la funcion de sincronizacion de fecha y hora
                  } else if (tramaRS485[3]==0x03){      //Verifica el campo de Funcion para ver si se trata de una solicitud de configuracion del APC220
                     ConfiguracionAPC220(tramaRS485,t1Size);  //Invoca a la funcion para realizar la configuracion del modulo APC con los parametros especificados en la trama
                  } else {
                     //Arma una trama de respuesta para indicar al Master que se produjo un error
                     tramaPDU[1]=0xFF;
                     tramaPDU[2]=0x04;                   //Establece en 10 el numero de elementos de la trama de respuesta de error
                     tramaPDU[3]=0xEE;                   //Cambia el campo de funcion por el codigo 0xEE para
                     tramaPDU[4]=0xE1;                   //Codigo de error para funcion no disponible
                     sizeTramaPDU = tramaPDU[2];         //Guarda en la variable sizeTramaPDU el valor del campo #Datos de la trama PDU
                     EnviarMensajeRS485(tramaRS485,sizeTramaPDU);   //Invoca a la funcion de Error pasandole como parametros el puerto, la Direccion y el tipo de error
                  }
               } else {                                  //Si la direccion es diferente de FFh renvia la trama de peticion por el puerto UART2
                  RenviarTrama(2,tramaRS485,t1Size);        //Invoca la funcion para renviar la trama por el puerto UART2
               }
           }
           
           banTC = 0;                                    //Limpia la bandera de trama completa
           i1 = 0;                                       //Incializa el subindice de la trama de peticion
           
        }
        
        PIR1.F5 = 0;                                     //Limpia la bandera de interrupcion de UART1
        IU1 = 0;                                         //Apaga el indicador de interrupcion por UART1
        
     }
     
     
//Interrupcion UART2
//Esta interrupcion supervisa el estado del puerto UART2 conectado al modulo APC220, cuando detecta un mensaje procediente de un esclavo revisa si el primer byte de la trama es
//la Cabecera, si es asi lo guarda en la trama, despues guarda el siguiente byte de Direccion, despues lee el siguiente byte de #Datos y utiliza esta informacion para saber cuantos
//bytes debe guardar a continuacion. Despues extrae el campo PDU, calcula su CRC y lo compara con el campo CRC de la trama recibida, si coincide el CRC
//envia un ACK al remitente para indicar que la peticion llego correctamente. Despues, renviara la trama por el puerto UART1 es decir a travez del bus RS485
/*if (PIR3.F5==1){

        IU2 = 1;                                        //Enciende el indicador de interrupcion por UART2
        byteTrama = UART2_Read();                       //Lee el byte de la trama de peticion

        if (banTI==0){

           if (byteTrama==HDR){
              u2Trama[0]=byteTrama;                     //Guarda el primer byte de la trama en la primera posicion de la trama
              banTI = 1;                                //Activa la bandera de inicio de trama
              i2 = 1;                                   //Define en 1 el subindice de la trama
              tramaOk = 0;                              //Limpia la variable que indica si la trama ha llegado correctamente
              puertoTOT = 2;                            //Indica al Time-Out-Trama que de ser necesario envie el NACK por el puerto UART2
              //Inicializa el Time-Out-Trama, t=2ms
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
           }

           if (byteTrama==ACK){                         //Verifica si recibio un ACK
              //Detiene el Time-Out-Dispositivo
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
           }

           if (byteTrama==NACK){                        //Verifica si recibio un NACK
              //Detiene el Time-Out-Dispositivo
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
              if (contadorNACK<3){
                 EnviarMensajeRS485(tramaRS485,sizeTramaPDU);
                 contadorNACK++;                        //Incrrmenta en una unidad el valor del contador de NACK
              } else {
                 //Arma una trama de respuesta para indicar al Master que se produjo un Error de canal (codigo:E4h)
                 tramaPDU[1]=u2Trama[1];                        //Guarda la direccion del Esclavo
                 tramaPDU[2]=0x04;                              //Establece en 4 el numero de elementos de la trama PDU
                 tramaPDU[3]=0xEE;                              //Cambia el campo de funcion por el codigo 0xEE para indicar que se produjo un error
                 tramaPDU[4]=0xE4;                              //Codigo de error para Error de canañ
                 sizeTramaPDU = tramaPDU[2];                    //Guarda en la variable sizeTramaPDU el valor del campo #Datos de la trama PDU
                 EnviarMensajeRS485(tramaRS485,sizeTramaPDU);   //Invoca a la funcion de Error pasandole como parametros el puerto, la Direccion y el tipo de error
                 contadorNACK = 0;                              //Limpia el contador de Time-Out-Trama
                 contadorNACK = 0;                              //Limpia el contador de Time-Out-Trama
              }
           }

        }

        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           if (i2==1){
              u2Trama[i1] = byteTrama;                  //Guarda el byte de Direccion en la segunda posicion del vector
              i2 = 2;                                   //Incrementa el subindice de la trama en una unidad
           } else if (i2=2){
              u2Trama[i2] = byteTrama;                  //Guarda el byte de #Datos en la tercera posicion del vector de peticion
              t2Size = byteTrama;                       //Guarda en la variable t1Size el valor del campo #Datos
              i1 = 3;                                   //Incrementa el subindice de la trama de peticion en una unidad
           } else if ((i1>2)&&(i1<t1Size)){
              tramaRS485[i1] = byteTrama;                  //Guarda el resto de bytes en el vector de peticion hasta que se complete el numero de bytes especificado en el campo #Datos
              i1=i1+1;                                  //Incrementa el subindice de la trama de peticion en una unidad
              banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                //Activa la bandera de trama completa
              //Detiene el TimeOut
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
           }
        }

        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion

           tramaOk = VerificarCRC(u2Trama,t2Size);      //Calcula y verifica el CRC de la trama de peticion

           //Si la trama llego sin errores responde con un ACK al esclavo y luego reenvia la trama al master
           //Si hubo algun error no hace nada, el esclavo renviara la peticion al no recibir respuesta en un tiempo determinado
           if (tramaOk==1){
               EnviarACK(2);                            //Invoca a la funcion EnviarACK() para notificar al remitente que la trama llego sin errores
           }

           banTC = 0;                                   //Limpia la bandera de trama completa
           i2 = 0;                                      //Limpia el subindice de trama

        }

        PIR3.F5 = 0;                                    //Limpia la bandera de interrupcion de UART2
        IU2 = 0;                                        //Apaga el indicador de interrupcion por UART2

     }*/
     
//Interrupcion por TIMER1 (Time-Out-Dispositivo)
//Si se produce una interrupcion por desbordamiento del TMR1 quiere decir que se cumplio el tiempo establecido por el Time-Out-Dispositivo
     if (TMR1IF_bit==1){
        TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
        T1CON.TMR1ON = 0;                               //Apaga el Timer1
        if (contadorTOD<3){
           EnviarMensajeRS485(tramaPDU, sizeTramaPDU);  //Reenvia la trama por el bus RS485
           contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
        } else {
           //EnviarMensajeSPI()                         //Responde al Master notificandole del error
           contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
        }
     }
     
//Interrupcion por TIMER2 (Time-Out-Trama)
//Si se produce una interrupcion por desbordamiento del TMR2 quiere decir que se cumplio el tiempo establecido por el Time-Out-Trama,
//por lo que se debe descartar la trama actual. Esto se logra limpiando la bandera de inicio de trama y encerando el subindice de trama,
//de esta manera si llega otro dato por el Uart y este es diferente del encabezamiento de inicio de trama ya no se almacenara en la trama de respuesta.
//Tambien se envia un NACK para pedir el renvio de la trama
     if (TMR2IF_bit==1){
        TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
        T2CON.TMR2ON = 0;                               //Apaga el Timer2
        banTI = 0;                                      //Limpia la bandera de inicio de trama
        i1 = 0;                                         //Limpia el subindice de la trama de peticion
        banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
        if (puertoTOT==1){
            EnviarNACK(1);                              //Envia un NACK por el puerto UART1 para solicitar el reenvio de la trama
        } else if (puertoTOT==2) {
            EnviarNACK(2);                              //Envia un NACK por el puerto UART2 para solicitar el reenvio de la trama
        }
        puertoTOT = 0;                                  //Encera la variable para evitar confusiones
     }

}



void main() {

     ConfiguracionPrincipal();
     RE_DE = 0;                                        //Establece el Max485-1 en modo de lectura;
     ENABLE = 1;                                       //Enciende el modulo APC220
     SET = 1;
     i1=0;
     i2=0;
     contadorTOD = 0;                                  //Inicia el contador de Time-Out-Dispositivo
     contadorNACK = 0;                                 //Inicia el contador de NACK
     
}