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

unsigned short PDUSize;                                 //Variable de longitud de trama PDU
unsigned short Psize;                                   //Variable de longitud de trama de Peticion
unsigned short Rsize;                                   //Variable de longitud de trama de Respuesta

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
              Rspt[it] = 0;                             //Borrar el ultimo elemento de la trama de respuesta, por que corresponde al primer byte del delimitador de final de trama
              RSize = it;                               //Establece la longitud de la trama de respuesta sin considerar el ultimo elemento
              BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
              BanTC = 1;                                //Activa la bandera de trama completa
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

        PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
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

     ANSELA = 0;                                       //Configura el PORTA como digital
     ANSELB = 0;                                       //Configura el PORTB como digital
     ANSELC = 0;                                       //Configura el PORTC como digital

     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISA0_bit = 1;
     TRISA1_bit = 0;

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
     INTCON.RBIF = 0;

     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion

     UART1_Init(19200);                                //Inicializa el UART a 9600 bps
     
     Delay_ms(10);                                     //Espera para que el modulo UART se estabilice

}

void main() {

     Configuracion();
     
     BanTI = 0;                                                     //Inicializa las banderas de trama
     BanTC = 0;
     BanTF = 0;
     
     Bb = 0;                                                        //Inicializa la bandera del boton, es solo para el ejemplo del dispositivo maestro

     
     RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;

     ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
     ptrCRCPDU = &CRCPDU;                                           //Asociacion del puntero CRCPDU
     
     Add = 0x01;                                                    //Direccion del esclavo a quien se realiza la peticion (Ejemplo)
     Fcn = 0x02;                                                    //Funcion solicitada al esclavo (Ejemplo)
     Psize = 9;                                                     //Longitu de la trama de peticion (Ejemplo)
     
     //Trama de peticion
     // | Hdr |              PDU          |        CRC        |     End     |
     // |  :  | Add | Fcn | Data1 | Data2 | CRC_MSB | CRC_LSB |  CR  |  LF  |
     
     Ptcn[0]=Hdr;
     Ptcn[1]=Add;
     Ptcn[2]=Fcn;
     Ptcn[3]=0x03;
     Ptcn[4]=0x04;
     Ptcn[7]=End1;
     Ptcn[8]=End2;
     
     //Ptc[] = 3A010203042BA10D0A
     
     while (1){
     
            //Rutina de ejemplo del dispositivo maestro. Cada vez que se pulsa un boton se envia una peticion a un esclavo especifico.
            if ((RA0_bit==0)&&(Bb==0)){
               Bb = 1;
               for (i=1;i<=4;i++){                                  //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC
                   PDU[i-1] = Ptcn[i];
               }
               
               CRC16 = ModbusRTU_CRC16(PDU, 4);                     //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
               Ptcn[6] = *ptrCRC16;                                 //Asigna el LSB del CRC al espacio 6 de la trama de peticion
               Ptcn[5] = *(ptrCRC16+1);                             //Asigna el MSB del CRC al espacio 5 de la trama de peticion
               
               RC5_bit = 1;                                         //Establece el Max485 en modo de escritura
               for (i=0;i<Psize;i++){
                   UART1_WRITE(Ptcn[i]);                           //Manda por Uart la trama de peticion
               }

               while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
               RC5_bit = 0;                                         //Establece el Max485 en modo de lectura;
               
            } else if (RA0_bit==1){
               Bb = 0;                                              //Esta rutina sirve para evitar rebotes en el boton
            }
     
            //Ojo condicion inexistente para hacer pruebas
            if (BanTC==5){                                          //Verifica que la bandera de trama completa este activa
            
               if (Rspt[0]==Add){                                   //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado

                  for (i=0;i<=(Rsize-3);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC
                      PDU[i] = Rspt[i];
                  }

                  CRC16 = ModbusRTU_CRC16(PDU, PDUSize);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
                  *ptrCRCPDU = Rspt[Rsize-1];                       //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
                  *(ptrCRCPDU+1) = Rspt[Rsize-2];                   //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
                  
                  if (CRC16==CRCPDU) {                              //Verifica si el CRC calculado es igual al CRC obtenido de la trama de peticion

                  }

                  BanTC = 0;                                        //Limpia la bandera de trama completa
               
               }
            }

            Delay_ms(10);

     }
}