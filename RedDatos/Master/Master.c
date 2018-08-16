/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 02/08/2016
Ultima modificacion: 02/08/2018
Estado: Modificando
Configuarcion: PIC18F25k22 8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
const short Hdr = 0x3A;                                 //Constante de delimitador de inicio de trama
const short End1 = 0x0D;                                //Constantes de delimitador de final de trama:
const short End2 = 0x0A;                                //El delimitador de final de trama es del tipo CR+LF

unsigned short dataSize;                                //Variable de longitud del campo de datos de la trama de peticion
unsigned short psize;                                   //Variable de longitud de trama de Peticion
unsigned short rsize;                                   //Variable de longitud de trama de Respuesta

unsigned short Add;                                     //Variable de codigo de direccion de esclavo
unsigned short Fcn;                                     //Variable de funcion

//Segun el protolo Modbus RTU, la carga util de la trama PDU puede ser de hasta 252 bytes. Aqui se ha fijado un limite de hasta 98 bytes.
//Si se requiere mas espacio para datos se puede extender mas, siempre y cuando no sobrepase la capacidad de memoria del microcontrolador
unsigned char PDU[100];                                 //Trama PDU.
unsigned char Ptcn[100];                                //Trama de peticion
unsigned char Rspt[100];                                //Trama de respuesta

unsigned short it, ir, ip, i, j;                       //Subindices para las tramas de peticion y respuesta
unsigned short BanTC, BanTI, BanTF;                     //Banderas de trama completa, inicio de trama y final de trama
unsigned short Dato;

const unsigned int PolModbus = 0xA001;                  //Polinomio para el calculo del CRC
unsigned int CRC16, CRCPDU;                             //Variables para almacenar el CRC calculado, y el CRC de la trama PDU recibida
unsigned short *ptrCRC16, *ptrCRCPDU;                   //Puntero para almacenar los valores del CRC calculado y el de la trama PDU recibida

unsigned short Bb;                                      //Bandera de boton, sirve solo para hacer pruebas

////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){
//Interrupcion por Uart
     if(PIR1.RC1IF==1){

        Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato
        
        //Verifica que el dato recibido sea el identificador de inicio de trama, de ser asi inicializa el subindice y el Time Out y activa una bandera
        //de inicio de trama para permitir almacenar los datos en la trama de respuesta. Si se vuelve a recibir el identificador de inicio de trama y no a
        //terminado de llenar la primera trama de respuesta, inicializa de nuevo el subindice y el Time Out para sobreescribir la trama.
        if (Dato==Hdr){
           BanTI = 1;                                   //Activa la bandera de inicio de trama
           it = 0;                                      //Limpia el subindice de trama
           T1CON.TMR1ON = 1;                            //Enciende el Timer1
           TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
           TMR1H = 0x3C;                                //Se vuelve a cargar el valor del preload correspondiente a los 50ms, porque
           TMR1L = 0xB0;                                //al parecer este valor se pierde cada vez que entra a la interrupcion
        }
        
        if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa
           
           if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
              rSize = it+1;                             //Establece la longitud total de la trama de respuesta
              BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              BanTC = 1;                                //Activa la bandera de trama completa
              T1CON.TMR1ON = 0;                         //Apaga el Timer1
              TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
           }
           
           if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
              it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              BanTF = 0;                                //Limpia la bandera de final de trama
           } else {
              Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
              it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
           }
           
        }

        PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
     }
     
//Interrupcion por desbordamiento del TMR1
     //Si se produce una interrupcion por desbordamiento del TMR1 quiere decir que se cumplio el tiempo establecido por el TimeOut,
     //por lo que se debe descartar la trama actual. Esto se logra limpiando la bandera de inicio de trama y encerando el subindice de trama,
     //de esta manera si llega otro dato por el Uart y este es diferente del encabezamiento de inicio de trama ya no se almacenara en la trama de respuesta.
     if (TMR1IF_bit==1){
        TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
        T1CON.TMR1ON = 0;                               //Apaga el Timer1
        
        RC4_bit = ~RC4_bit;                             //Conmuta el valor de la salida RC4 para indicar que entro a la interrupcion
        
        BanTI = 0;                                      //Limpia la bandera de inicio de trama
        it = 0;                                         //Limpia el subindice de trama

     }
}

////////////////////////////////////////////////////////////// Funciones //////////////////////////////////////////////////////////////

//Funcion para calcular el CRC16 de una trama de datos
unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen){

   unsigned char ucCounter;
   unsigned int uiCRCResult;

   for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
   {
      uiCRCResult ^= *ptucBuffer ++;
      for(ucCounter =0; ucCounter <8; ucCounter ++)
      {
         if(uiCRCResult & 0x0001)
            uiCRCResult =(uiCRCResult>>1)^PolModbus;
         else
            uiCRCResult >>= 1;
      }
   }
   return uiCRCResult;
   
}

//Funcion para rellenar y enviar la trama de peticion
//////////////////////////////////////// Formato de trama ////////////////////////////////////////
//| Encabezado |                      PDU                     |        CRC        |      Fin     |
//|   1 byte   |        2 bytes      |        n bytes         |      2 bytes      |    2 bytes   |
//|     :      | Dirección | Función | Data1 | Data2 | DataN  | CRC_MSB | CRC_LSB |  CR   |  LF  |
//|     0      |     1     |    2    |   3   |   4   |    n   |   n+3   |   n+4   |  n+5  |  n+6 |

void enviarTrama(unsigned short dataSize, unsigned short fcn){

     unsigned short pSize = dataSize + 7;                //Longitud de la trama de respuesta

      //Prepara la trama PDU
     PDU[0] = Add;                                       //Rellena el campo de direccion con la direccion del dispositivo esclavo
     PDU[1] = fcn;                                       //Rellena el campo de funcion con la funcion que se requerira al esclavo
     //Rellena el campo de datos de la trama PDU con el payload. OJO aqui hay que buscar la forma de pasar como parametro un vector
     PDU[2] = 0xAA;                                     //Rellena el campo de datos con los valores 0xAAFF
     PDU[3] = 0xAA;

     //Prepara la trama de peticion
     Ptcn[0] = Hdr;                                     //Se rellena el primer byte de la trama de peticion con el delimitador de inicio de trama
     for (i=0;i<=(dataSize+1);i++){                     //Rellena la trama de Respuesta con el PDU
         Ptcn[i+1] = PDU[i];
     }
     CRC16 = ModbusRTU_CRC16(PDU, dataSize+2);          //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
     Ptcn[dataSize+3] = *(ptrCRC16+1);                  //Rellena el campo CRC_MSB de la trama de respuesta
     Ptcn[dataSize+4] = *ptrCRC16;                      //Rellena el campo CRC_LSB de la trama de respuesta
     Ptcn[dataSize+5] = End1;                           //Se rellena el penultimo byte de la trama de repuesta con el primer byte del delimitador de final de trama
     Ptcn[dataSize+6] = End2;                           //Se rellena el ultimo byte de la trama de repuesta con el segundo byte del delimitador de final de trama

     //Envia la trama de peticion por el UART1
     RC5_bit = 1;                                       //Establece el Max485 en modo de escritura
     for (i=0;i<pSize;i++){
         UART1_Write(Ptcn[i]);                          //Envia la trama de peticion
     }
     while(UART1_Tx_Idle()==0);
     RC5_bit = 0;                                       //Establece el Max485 en modo de lectura

}

////////////////////////////////////////////////////////////// Configuracion //////////////////////////////////////////////////////////////

void Configuracion(){

     ANSELA = 0;                                       //Configura el PORTA como digital
     ANSELB = 0;                                       //Configura el PORTB como digital
     ANSELC = 0;                                       //Configura el PORTC como digital

     TRISA = 1;                                        //Configura el puerto A como entrada
     TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
     TRISC1_bit = 1;                                   //Configura el pin C1 como entrada
     TRISC2_bit = 1;                                   //Configura el pin C2 como entrada
     TRISC3_bit = 0;                                   //Configura el pin C3 como salida
     TRISC4_bit = 0;                                   //Configura el pin C4 como salida
     TRISC5_bit = 0;                                   //Configura el pin C5 como salida

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas

     //Configuracion del UART
     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.RC1IF = 0;                                   //Limpia la bandera de interrupcion
     UART1_Init(19200);                                //Inicializa el UART a 9600 bps
     
     //Configuracion del TMR1
     T1CON = 0x21;                                     //Establece el prescalador en 1:2, enciende el TMR1
     TMR1IE_bit = 1;                                   //Habilita la interrupcion por desbordamiento del TMR1
     TMR1IF_bit = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR1
     TMR1H = 0x3C;                                     //Preload = 15536, Time = 100ms
     TMR1L = 0xB0;
     
     //Nivel de prioridad de las interrupciones
     RCON.IPEN = 1;                                    //Habilita el nivel de prioridad en las interrupciones
     IPR1.RC1IP = 0;                                   //EUSART1 Receive Interrupt Priority bit = Low priority
     IPR1.TMR1IP = 1;                                  //TMR1 Overflow Interrupt Priority bit = High priority
     
     Delay_ms(10);                                     //Espera para que el modulo UART se estabilice
     

}

void main() {

     Configuracion();
     
     BanTI = 0;                                                     //Inicializa las banderas de trama
     BanTC = 0;
     BanTF = 0;
     
     Bb = 0;                                                        //Inicializa la bandera del boton, es solo para el ejemplo del dispositivo maestro

     RC5_bit = 0;
     RC3_bit = 0;                                                   //Establece el Max485 en modo de lectura;
     RC4_bit = 0;                                                   //Inicializa un indicador. No tiene relevancia para la ejecucion del programa

     ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
     ptrCRCPDU = &CRCPDU;                                           //Asociacion del puntero CRCPDU
     
     while (1){
     
            //Rutina de ejemplo del dispositivo maestro. Cada vez que se pulsa un boton se envia una peticion a un esclavo especifico.
            if ((RC2_bit==0)&&(Bb==0)){
               Bb = 1;
               Add = (PORTA&0x3F)+((PORTC&0x03)<<6);                //Carga el valor del dipswitch como direccion del esclavo a quien se realiza la peticion
               enviarTrama(2,3);                                    //Envia la trama de peticion con 2 bytes de pyload y solicitando la funcion 3
               
            } else if (RC2_bit==1){
               Bb = 0;                                              //Esta rutina sirve para evitar rebotes en el boton
            }
     
            if (BanTC==1){                                          //Verifica que la bandera de trama completa este activa
            
               if (Rspt[1]==Add){                                   //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado
               
                  for (i=0;i<=(Rsize-5);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
                      PDU[i] = Rspt[i+1];
                  }

                  CRC16 = ModbusRTU_CRC16(PDU, Rsize-5);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
                  *ptrCRCPDU = Rspt[Rsize-3];                       //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
                  *(ptrCRCPDU+1) = Rspt[Rsize-4];                   //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU

                  if (CRC16==CRCPDU) {                              //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
               
                     //Aqui se ejecuta la accion que tomara el cliente una vez que reciba los datos solicitados
                     //En este caso unicamente cambiara el estado del bit C3
                     RC3_bit = 1;
                     Delay_ms(100);
                     RC3_bit = 0;
                  }
                  
               }
               
               BanTC = 0;
               
            }

            Delay_ms(10);

     }
}