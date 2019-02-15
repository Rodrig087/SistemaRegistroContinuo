/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 5/11/2018
Configuracion: 18F25K22 XT=8MHz
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
sbit CS at RC2_bit;                                     //Definicion del pin CS
sbit CS_Direction at TRISC2_bit;

unsigned short byteTrama;                               //Variable de bytes de trama de datos
unsigned short t1Size;                                  //Variables de longitud de trama para la comunicacion por el UART1
unsigned char tramaRS485[50];                           //Vector de trama de datos del puerto UART1
short i,j,x;                                               //Subindices para el manejo de las tramas de datos

unsigned short banTC, banTI, banTF;                     //Banderas de trama completa, inicio de trama y final de trama

unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta

unsigned short tramaOk;                                 //Variable para indicar si la trama de datos llego correctamente;

unsigned char tramaSPI[15];                             //Vector para almacenar la peticion proveniente de la Rpi
unsigned char tramaRespuesta[15];
unsigned short sizeSPI;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master
unsigned short registroRPi;                             //Variable para almcenar el
unsigned short tipoDato;                                //Variable para indicar el tipo de dato que se va a enviar: 0x00 Short, 0x01 Entero, 0x02 Float
unsigned short numDatos;                                //Variable para alamcenar el numero de datos que se van a enviar

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     ANSELB = 0;                                        //Configura PORTB como digital
     ANSELC = 0;                                        //Configura PORTC como digital
     
     TRISB0_bit = 1;
     TRISB1_bit = 1;
     TRISC2_bit = 0;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps

     //Configuracion del puerto SPI
     //SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
     SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV4,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);

     //Configuracion de la interrupcion externa (simula la una peticion)
     INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
     INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
     //INTCON3.INT1IE = 1;                                //Habilita la interrupcion externa INT1
     //INTCON3.INT1IF = 0;                                //Limpia la bandera de interrupcion externa INT1
     //INTCON2.INTEDG0 = 0;                             //Interrupcion INT0 en flanco de bajada
     //INTCON2.INTEDG1 = 0;                             //Interrupcion INT1 en flanco de bajada

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para el envio de una trama de datos
//Esta funcion recibe como parametros la trama PDU y su tamaño, y envia la trama de peticion completa a travez de SPI
void EnviarMensajeSPI(unsigned char *trama, unsigned short sizePDU){
     CS = 0;
     for (x=0;x<sizePDU;x++){
         SSPBUF = trama[x];                             //Llena el buffer de salida con cada valor de la tramaSPI
         Delay_ms(1);
     }
     CS = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para recuperar los datos que le envia el CPcomunicacion
//Esta funcion primero envia una trama de 3 dummy bytes para recuperar el numero de bytes
unsigned short RecuperarRespuestaSPI(){
      /*CS = 0;
      SSPBUF = 0xC0;
      Delay_ms(1);
      SSPBUF = 0xCC;
      Delay_ms(1);
      SSPBUF = 0xC1;
      Delay_ms(1);
      CS = 1;*/
     
     unsigned short numBytes;
     tramaSPI[0] = 0xC0;
     tramaSPI[1] = 0xCC;
     tramaSPI[2] = 0xC1;
     CS = 0;
     for (x=0;x<3;x++){
         SSPBUF = tramaSPI[x];                          //Llena el buffer de salida con cada valor de la tramaSPI
         if (x==2){
            while (SSP1STAT.BF!=1);
            numBytes = SSPBUF;                          //Recupera el numero de bytes de la trama de respuesta
         }
         Delay_ms(1);
     }
     CS = 1;
     
     Delay_ms(100);
     
     if ((numbytes!=0xC0)||(numbytes!=0xCC)||(numbytes!=0xC1)||(numbytes!=0x00)){
        CS = 0;
        SSPBUF = 0xD0;
        Delay_us(10);
        for (x=0;x<(numBytes);x++){
            SSPBUF = 0xDD;
            while (SSP1STAT.BF!=1);
            tramaRespuesta[x] = SSPBUF;
            Delay_us(10);
        }
        SSPBUF = 0xD1;
        Delay_us(10);
        CS = 1;
     }
     
     for (x=0;x<(numBytes);x++){
         UART1_Write(tramaRespuesta[x]);
     }
     
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para probar el puerto SPI
void ProbarSPI(){
     tramaSPI[0] = 0x00;
     tramaSPI[1] = 0x01;
     tramaSPI[2] = 0x02;
     tramaSPI[3] = 0x03;
     tramaSPI[4] = 0x04;
     tramaSPI[5] = 0x05;
     tramaSPI[6] = 0x06;
     tramaSPI[7] = 0x07;
     tramaSPI[8] = 0x08;
     tramaSPI[9] = 0x09;
     CS = 0;
     SSPBUF = 0xB0;
     Delay_us(10);
     for (x=0;x<10;x++){
         SSPBUF = tramaSPI[x];                          //Llena el buffer de salida con cada valor de la tramaSPI
         Delay_us(10);
     }
     SSPBUF = 0xB1;
     Delay_us(10);
     CS = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa 1
//Esta interrupcion simula lo que envia la RPi al dispositivo CPComunicacion
     if (INTCON3.INT1IF==1){
        INTCON3.INT1IF = 0;                             //Limpia la badera de interrupcion externa
        
        //Aqui va la parte donde realiza la toma de datos que llegan por SPI desde la Rpi
        //Ejemplo de trama de peticion enviada por la RPi:
        funcionRpi = 0x00;                              //Funcion que se requiere realizar. 0x00:Lectura  0x01:Escritura
        direccionRpi = 0x09;                            //Direccion del esclavo destinatario de la peticion
        registroRPi = 0x02;                             //Registro que se desea leer o escribir

        tramaSPI[0] = 0xB0;                             //Cabecera
        tramaSPI[1] = direccionRpi;                     //Direccion
        tramaSPI[2] = funcionRpi;                       //Funcion
        tramaSPI[3] = registroRPi;                      //Registro

        if (funcionRpi==0x00){
           
           tramaSPI[4] = 0x00;                          //#Datos
           tramaSPI[5] = 0xB1;                          //Fin
           EnviarMensajeSPI(tramaSPI,6);
           
        }else{
           
           tipoDato = 0x02;                             //0x00: Short, 0x01: Entero, 0x02: Float
           switch (tipoDato){
                  case 0:
                       numDatos = 1;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0x5C;              //Datos
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
                  case 1:
                       numDatos = 2;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0x5C;              //Datos
                       tramaSPI[6] = 0x8F;
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
                  case 2:
                       numDatos = 4;
                       tramaSPI[4] = numDatos;          //#Datos
                       tramaSPI[5] = 0xE1;              //Datos
                       tramaSPI[6] = 0xE2;
                       tramaSPI[7] = 0xE3;
                       tramaSPI[8] = 0xE4;
                       tramaSPI[numDatos+5] = 0xB1;
                       break;
           }
           
           EnviarMensajeSPI(tramaSPI,(numDatos+6));
        
        }

     }
 
 //Interrupcion Externa 0
//Esta interrupcion se activa cuando el CPComunicacion le envia un pulso para indicarle que tiene lista la trama de respuesta,
//entonces la RPi primero genera 3 dummy bytes  para recuperar el numero de bytes que va a recuperar, para despues generar el numero de dummy bytes necesarios para recuperar la trama de respuesta
     if (INTCON.INT0IF==1){
        INTCON.INT0IF = 0;                                //Limpia la badera de interrupcion externa
        //RecuperarRespuestaSPI();
        //ProbarSPI();
     }
     
 }


void main() {

     ConfiguracionPrincipal();
     CS = 1;
     byteTrama = 0;                                       //Limpia la variable del byte de la trama de peticion
     banTI = 0;                                           //Limpia la bandera de inicio de trama
     banTC = 0;                                           //Limpia la bandera de trama completa
     banTF = 0;                                           //Limpia la bandera de final de trama

    while(1){
    
             ProbarSPI();
             Delay_ms(1000);
    
    }

}