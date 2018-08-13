/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 07/07/2017
Ultima modificacion: 07/08/2018
Configuracion: PIC18F25k22 XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
const short Hdr = 0x3A;                                 //Constante de delimitador de inicio de trama
const short End1 = 0x0D;                                //Constantes de delimitador de final de trama:
const short End2 = 0x0A;                                //El delimitador de final de trama es del tipo CR+LF

unsigned short PDUSize;                                 //Variable de longitud de trama PDU
unsigned short Psize;                                   //Variable de longitud de trama de Peticion
unsigned short Rsize;                                   //Variable de longitud de trama de Respuesta

unsigned short Add;                                     //Variable de codigo de direccion de esclavo
unsigned short Fcn;                                     //Variable de funcion

//Segun el protolo Modbus RTU, la carga util de la trama PDU puede ser de hasta 252 bytes. Aqui se ha fijado un limite de hasta 98 bytes.
//Si se requiere mas espacio para datos se puede extender mas, siempre y cuando no sobrepase la capacidad de memoria del microcontrolador
unsigned char PDU[100];                                 //Trama PDU.
unsigned char Ptcn[100];                                //Trama de peticion
unsigned char Rspt[9];                                //Trama de respuesta

unsigned short it, ir, ip, i, j;                       //Subindices para las tramas de peticion y respuesta
unsigned short BanTC, BanTI, BanTF;                     //Banderas de trama completa, inicio de trama y final de trama
unsigned short Dato;

const unsigned int PolModbus = 0xA001;                  //Polinomio para el calculo del CRC
unsigned int CRC16, CRCPDU;                             //Variables para almacenar el CRC calculado, y el CRC de la trama PDU recibida
unsigned short *ptrCRC16, *ptrCRCPDU;                   //Puntero para almacenar los valores del CRC calculado y el de la trama PDU recibida

unsigned short Bb;                                      //Bandera de boton, sirve solo para hacer pruebas

//Variables para el calculo de la temperatura y la humedad
unsigned int ITemp, IHmd, Sum;                          //Variables tipo entero para los datos de temperatura y humedad
unsigned char *chTemp, *chHmd;                          //Variables tipo puntero para la Temperatura, Caudal y factor de calibracion
unsigned char  Check, T_byte1, T_byte2, RH_byte1, RH_byte2;
unsigned int DatoPtcn;                                  //Variable para el Dato de la peticion
unsigned short *chDP;                                   //Variable tipo puntero para el dato de peticion


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////

//Interrupcion por Uart
void interrupt(void){
     if(PIR1.F5==1){

        Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato

        //Verifica que el dato recibido sea el identificador de inicio de trama, de ser asi inicializa el subindice y el Time Out y activa una bandera
        //de inicio de trama para permitir almacenar los datos en la trama de respuesta. Si se vuelve a recibir el identificador de inicio de trama y no a
        //terminado de llenar la primera trama de respuesta, inicializa de nuevo el subindice y el Time Out para sobreescribir la trama.
        if (Dato==Hdr){
           BanTI = 1;
           it = 0;
           //Inicializa el TimeOut
        }

        if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa

           if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
              Ptcn[it] = 0;                             //Borrar el ultimo elemento de la trama de respuesta, por que corresponde al primer byte del delimitador de final de trama
              PSize = it;                               //Establece la longitud de la trama de respuesta sin considerar el ultimo elemento
              BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              BanTC = 1;                                //Activa la bandera de trama completa
           }

           if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
              Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
              it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              BanTF = 0;                                //Limpia la bandera de final de trama
           } else {
              Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
              it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
              BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
           }

        }

        PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
     }
}

// Funciones //

void Responder(unsigned int Reg){

     if (Reg==0x01){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chTemp++);                        //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
        }
     }
     
     if (Reg==0x02){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chHmd++);                         //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Humedad calculada
        }
     }
     
     Rspt[2]=Ptcn[2];                                    //Rellena el byte 2 con el tipo de funcion de la trama de peticion

     RC5_bit = 1;                                        //Establece el Max485 en modo de escritura

     for (ir=0;ir<Rsize;ir++){
         UART1_Write(Rspt[ir]);                          //Envia la trama de respuesta
     }
     while(UART1_Tx_Idle()==0);                          //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     
     RC5_bit = 0;                                        //Establece el Max485 en modo de lectura

     for (ir=3;ir<5;ir++){
         Rspt[ir]=0;;                                    //Limpia la trama de respuesta
     }

}

//Funcion para calcular el CRC16 de una trama de datos
unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
{
   unsigned char ucCounter;
   unsigned int uiCRCResult;
   for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
   {
      uiCRCResult ^=*ptucBuffer ++;
      for(ucCounter =0; ucCounter <8; ucCounter ++)
      {
         if(uiCRCResult & 0x0001)
            uiCRCResult =( uiCRCResult >>1)^PolModbus;
         else
            uiCRCResult >>=1;
      }
   }
   return uiCRCResult;
}


// Configuracion //
void Configuracion(){

     ANSELA = 0;                                       //Configura PORTA como digital
     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISA = 1;                                        //Configura el puerto A como entrada
     TRISC4_bit = 0;                                   //Configura el pin C4 como salida
     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
     TRISC1_bit = 1;                                   //Configura el pin C1 como entrada


     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas

     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion

     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     Delay_ms(10);                                    //Espera para que el modulo UART se estabilice

}


void main() {
    
     Configuracion();

     BanTI = 0;                                                     //Inicializa las banderas de trama
     BanTC = 0;
     BanTF = 0;

     RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;
     RC4_bit = 0;
     
     CRC16 = 0;                                                     //Inicializa los valores del CRC obtenido y calculado con valores diferentes
     CRCPDU = 1;

     ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
     ptrCRCPDU = &CRCPDU;                                           //Asociacion del puntero CRCPDU

     Add = 0x01;                                                    //Direccion del esclavo a quien se realiza la peticion (Ejemplo)
     Fcn = 0x02;                                                    //Funcion solicitada al esclavo (Ejemplo)
     Rsize = 9;

     //Trama de respuesta
     // | Hdr |              PDU          |        CRC        |     End     |
     // |  :  | Add | Fcn | Data1 | Data2 | CRC_MSB | CRC_LSB |  CR  |  LF  |
     // |  0  |  1  |  2  |   3   |   4   |    5    |    6    |   7  |   8  |
     
     Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
     Rspt[1] = Add;                                           //Se rellena el segundo byte de la trama de repuesta con la Add del sensor
     Rspt[7] = End1;                                          //Se rellena el penultimo byte de la trama de repuesta con el primer byte del delimitador de final de trama
     Rspt[8] = End2;                                          //Se rellena el penultimo byte de la trama de repuesta con el segundo byte del delimitador de final de trama
     
     while (1){
     
           if (BanTC==1){                                     //Verifica si se realizo una peticion comprobando el estado de la bandera de trama completa

              if (Ptcn[1]==Add){                              //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado

                  for (i=0;i<=(Psize-5);i++){                 //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
                      PDU[i] = Ptcn[i+1];
                  }

                  CRC16 = ModbusRTU_CRC16(PDU, 4);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
                  *ptrCRCPDU = Ptcn[Psize-2];                 //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
                  *(ptrCRCPDU+1) = Ptcn[Psize-3];             //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU

                  if (CRC16==CRCPDU) {                        //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion

                     //Aqui se ejecuta lo que respondera el esclavo una vez que ha validado el CRC de la trama de peticion
                     //Por ejemplo, aqui se envia la trama de respuesta con valores impuestos
                     
                     RC4_bit = ~RC4_bit;                      //Indicador
                     Rspt[2] = Ptcn[2];                       //Rellena el campo de funcion con la funcion requerida en la trama de peticion
                     Rspt[3] = 0xAA;                          //Rellena el campo de datos con los valores 0xAAFF
                     Rspt[4] = 0xFF;
                     
                     for (i=0;i<=3;i++){                      //Rellena la trama de PDU con los datos de interes de la trama de respuesta
                         PDU[i] = Rspt[i+1];
                     }
                     
                     CRC16 = ModbusRTU_CRC16(PDU, 4);         //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
                     Rspt[6] = *ptrCRC16;                     //CRC_LSB
                     Rspt[5] = *(ptrCRC16+1);                 //CRC_MSB
                     
                     for (i=0;i<=8;i++){
                         UART1_Write(Rspt[i]);                //Envia la trama de respuesta
                     }
                     while(UART1_Tx_Idle()==0);

                  }
                  BanTC = 0;
              }
              
              BanTC = 0;                                      //Limpia la bandera de trama completa
              
           }
                
            Delay_ms(10);
                 
                 
     }

}