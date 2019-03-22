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

     //Configuracion del puerto SPI
     SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV4,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Funcion para probar el puerto SPI
void ProbarSPI(){

     CS = 0;
     SSPBUF = 0xB0;
     Delay_us(100);
     for (x=0;x<6;x++){
         SSPBUF = 0xBB;
         Delay_us(100);
     }
     SSPBUF = 0xB1;
     Delay_us(100);
     CS = 1;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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