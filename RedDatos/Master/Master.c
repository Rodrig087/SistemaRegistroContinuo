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
const short Add = 0x01;                                  //Identificador de tipo de sensor
const short Fcn = 0x02;                                 //Identificador de numero de esclavo

const short PDUSize = 4;                                //Constante de longitud de trama PDU
const short Psize = 9;                                  //Constante de longitud de trama de Peticion
const short Rsize = 9;                                  //Constante de longitud de trama de Respuesta

unsigned char PDU[PDUSize];                             //Trama PDU
unsigned char Ptcn[Psize];                              //Trama de peticion
unsigned char Rspt[Rsize];                              //Trama de respuesta

short ir, irr, ip, j;                                   //Subindices para las tramas de peticion y respuesta
unsigned short BanP, BanT;
unsigned short Dato;

const unsigned int PolModbus = 0xA001;                  //Polinomio para el calculo del CRC
unsigned int CRC16;                                     //Variable para almacenar el valor del CRC calculado
unsigned short *ptrCRC16;                               //Puntero para almacenar el valor del CRC

void interrupt(void){
     if(PIR1.F5==1){

        Dato = UART1_Read();

        if ((Dato==Hdr)&&(ir==0)){                   //Verifica que el primer dato en llegar sea el identificador de inicio de trama
           BanT = 1;                                 //Activa una bandera de trama
           Rspt[ir] = Dato;                          //Almacena el Dato en la trama de respuesta
        }
        if ((Dato!=Hdr)&&(ir==0)){                   //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
           ir=-1;                                    //Si es asi, reduce el subindice en una unidad
        }
        if ((BanT==1)&&(ir!=0)){
           Rspt[ir] = Dato;                          //Almacena el resto de datos en la trama de respuesta si la bandera de trama esta activada
        }

        ir++;                                        //Aumenta el subindice una unidad
        if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
           BanP = 1;                                 //Habilita la bandera de lectura de datos
           ir=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
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

     UART1_Init(57600);                                 //Inicializa el UART a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

}

void main() {

     Configuracion();
     RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;

     ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16

     //PDU = 0x01020304  CRC=0x2BA1
     PDU[0]=Add;
     PDU[1]=Fcn;
     PDU[2]=0x03;
     PDU[3]=0x04;
     
     //Trama de peticion
     // | Hdr |              PDU          |     CRC     |     End     |
     // |  :  | Add | Fcn | Data1 | Data2 | CRC1 | CRC2 |  CR  |  LF  |
     
     Ptcn[0]=Hdr;
     Ptcn[Psize-2]=End1;
     Ptcn[Psize-1]=End2;

     
     while (1){

            CRC16 = ModbusRTU_CRC16(PDU, PDUSize);               //Calcula el CRC de la trama de peticion y la almacena en la variable CRC16
            Ptcn[6] = *ptrCRC16;                                 //Asigna el MSB de CRC al espacio 6 de la trama de peticion
            Ptcn[5] = *(ptrCRC16+1);                             //Asigna el LSB del CRC al espacio 5 de la trama de peticion
            
            for (ip=1;ip<=4;ip++){                               //Rellena la trama de peticion con los datos de la trama PDU
                Ptcn[ip] = PDU[ip-1];
            }

            for (ip=0;ip<Psize;ip++){
                UART1_WRITE(Ptcn[ip]);                           //Manda por Uart la trama de peticion
            }
            while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar

            Delay_ms(20);

     }
}