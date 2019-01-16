/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 17/10/2018
Configuracion: PIC18F25k22 XT=8MHz
Observaciones:
Lo ultimo que hice el miercoles 31 de octubre fue revisar la secuencia de instrucciones de la bandera banTC=1 de la interrupcion UART1
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
unsigned short t2Size, sizeTramaPDU, numDatosEsc;
unsigned char tramaSerial[50];                          //Vector de trama de datos del puerto UART1
unsigned char tramaPDU[15];                             //Vector para almacenar los valores de la trama PDU creada localmente
unsigned char tramaPetEsc[10];
unsigned char u2Trama[50];                              //Vector de trama de datos del puerto UART2
short i1;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta
unsigned short banAtEsc, banIdEsc;                      //Bandera para almacenamiento de los atributos de los esclavos conectados, e identificacion de esclavos

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;
unsigned short puertoTOT;                               //Especifica el puerto por cual enviar el NACK en caso de producirse un Time-Out-Trama

unsigned short x;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISB3_bit = 0;                                   //Configura el pin B3 como salida
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una peticion al EsclavoSensor por SPI
//Esta funcion envia una solicitud al dispositivo EsclavoSensor, recibe como parametro la trama de datos y la longitud de la trama PDU
void EnviarSolicitudEsclavo(unsigned char* trama, unsigned char tramaPDUSize){
     unsigned short j;
     RE_DE = 1;                                    //Establece el Max485 en modo escritura
     UART1_Write(0xB0);
     for (j=0;j<tramaPDUSize;j++){
        UART1_Write(trama[j+1]);
     }
     UART1_Write(0xB1);
     while(UART1_Tx_Idle()==0);
     RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){

//Interrupcion UART2
//Esta interrupcion supervisa el estado del puerto UART2 donde esta conectado el modulo APC220, cuando detecta una peticion procedente del H/S revisa si el prmer byte de la trama es
//la Cabecera para guardar el resto de la trama. Despues verifica el CRC de la trama recibida y si es correcto envia un ACK al H/S, extrae los datos de la peticion y los envia al dispositivo
//esclavo correspondiente. Caso contrario, si la validacion del CRC es incorrecto, envia un NACK al H/S para pedir el renvio de la trama.

     if(PIR3.RC2IF ==1){

        IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
        byteTrama = UART2_Read();                       //Lee el byte de la trama de peticion;

        //Verifica si el primer byte en llegar es una Cabecera de trama o una cabecera de atualizacion de informacion de esclavos conectados
        if (banTI==0){                                  //Verifica que la bandera de inicio de trama este apagada
           if (byteTrama==HDR){                         //Verifica si recibio una cabecera
              banTI = 1;                                //Activa la bandera de inicio de trama
              i1 = 0;                                   //Define en 1 el subindice de la trama de peticion
              tramaOk = 9;                              //Limpia la variable que indica si la trama ha llegado correctamente
              puertoTOT = 1;                            //Indica al Time-Out-Trama que de ser necesario envie el NACK por el puerto UART1
              //Inicializa el Time-Out-Trama, t=2ms
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
           }
        }

        //Si en el paso anterior recibio una cabecera aqui termina de llenar la trama de datos
        //Cada vez que entra en esta etapa apaga el Time-Out-Trama y lo vuelve a encender al salir, excepto cuando termina de completar la trama
        if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
           T2CON.TMR2ON = 0;                            //Apaga el Timer2
           if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              tramaSerial[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
              i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              banTF = 0;                                //Limpia la bandera de final de trama
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;
           } else {
              tramaSerial[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
              banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
              T2CON.TMR2ON = 1;                         //Enciende el Timer2
              PR2 = 249;
           }
           if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
              banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              banTC = 1;                                //Activa la bandera de trama completa
              PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
              T2CON.TMR2ON = 0;                         //Apaga el Timer2
           }
        }

        //Aqui procesa el contenido de la trama de peticion
        if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
           numDatosEsc = tramaSerial[4];
           sizeTramaPDU = numDatosEsc+4;                      //Calcula la longitud de la trama PDU sumando 4 al valor del campo #Datos
           tramaOk = VerificarCRC(tramaSerial,sizeTramaPDU);  //Calcula y verifica el CRC de la trama de peticion
           if (tramaOk==1){
               //Delay_ms(300);                         //Sirve para probar el Time-Out-Dispositivo en el dispositivo que recibe el ACK
               EnviarACK(2);                            //Si la trama llego sin errores responde con un ACK al H/S
               EnviarSolicitudEsclavo(tramaSerial,sizeTramaPDU);                //Envia la trama de peticion a los esclavos
           } else if (tramaOk==0) {
               EnviarNACK(2);                            //Si hubo algun error en la trama se envia un NACK al Master para que le reenvie la peticion
           }
           banTI = 0;                                    //Limpia la bandera de inicio de trama
           banTC = 0;                                    //Limpia la bandera de trama completa
           i1 = 0;                                       //Incializa el subindice de la trama de peticion
        }

        PIR3.RC2IF = 0;                                  //Limpia la bandera de interrupcion de UART1
        IU1 = 0;                                         //Apaga el indicador de interrupcion por UART1

     }


//Interrupcion UART1
//Esta interrupcion supervisa el estado del puerto UART1 conectado al bus RS485,
     if (PIR1.RC1IF==1){

        IU2 = 1;                                        //Enciende el indicador de interrupcion por UART2
        byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion




        PIR1.RC1IF = 0;                                    //Limpia la bandera de interrupcion de UART2
        IU2 = 0;                                        //Apaga el indicador de interrupcion por UART2

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
     banTI=0;                                          //Limpia la bandera de inicio de trama
     banTC=0;                                          //Limpia la bandera de trama completa
     banTF=0;                                          //Limpia la bandera de final de trama
     AUX = 0;

}