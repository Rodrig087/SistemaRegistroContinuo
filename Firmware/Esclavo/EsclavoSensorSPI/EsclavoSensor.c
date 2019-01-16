/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 29/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

///////////////////////////////////// Formato de la trama de datos ////////////////////////////////////
//|  Cabecera  |                        PDU                        |        CRC        |      Fin     |
//|   1 byte   |   1 byte  |              n bytes                  |      2 bytes      |    2 bytes   |
//|    3Ah     | Dirección | Función | Registro | #Datos  | DataN  | CRC_MSB | CRC_LSB |  0Dh  |  0Ah |
//|      0     |     1     |    2    |    3     |   4     |   n    |   n+4   |   n+5   |  n+4  |  n+5 |

// Registros de Lectura //
//|   00   |   Caudal   |
//|   01   |   Nivel    |
//|   02   |    TOF     |
//|   03   |    Temp    |

//          Registros de Escritura          //
//|   00   |   Altura instalacion           |
//|   01   |   Factor calibracion altura    |
//|   02   |   Factor calibracion TOF       |


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit ECINT at RC2_bit;                                  //Definicion del pin de indicador auxiliar para hacer pruebas
sbit ECINT_Direction at TRISC2_bit;

const short idEsclavo = 0x09;                           //Constante de identificador de esclavo
const short funcEsclavo = 0x01;                         //Constante de numero de funciones del esclavo (0x00 = Solo lectura , 0x01 = Lectura y escritura)
const short regLectura = 0x04;                          //Numero de registros de lectura del esclavo
const short regEscritura = 0x03;                        //Numero de registros de escritura del esclavo

unsigned char datosEscritura[10];                       //Vector para almacenar los valores que se requiere escribir en los registros de escritura
unsigned char resSPI[15];
unsigned short regEsc;                                  //Variable para almacenar el registro que se quiere escribir
unsigned short numDatosEsc;                             //Variable para almacenar el numero de datos que se desea escribir en un registro de escritura
unsigned short
unsigned short i, x, j;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banLec, banId, banEsc;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Funcion para realizar la Configuracion de parametros
void ConfiguracionPrincipal(){

     TRISC2_bit = 0;
     TRISB3_bit = 0;
     TRISA5_bit = 1;

     INTCON.GIE = 1;                                    //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas

     //Configuracion del puerto SPI en modo Esclavo
     SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
     PIE1.SSPIE = 1;                                    //Habilita la interrupcion por SPI
     
     UART1_Init(19200);

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion SPI
     if (PIR1.SSPIF){

        PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
        AUX = 1;
        AUX = 0;

        buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
        
        //Rutina para procesar la solicitud de envio de informacion de este esclavo
        if ((buffer==0xA0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de solicitud de informacion y si la bandera de escritura esta desactivada
           banId = 1;                                     //Activa la bandera de escritura de Id
           SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
           Delay_us(50);
        }
        if ((banId==1)&&(buffer!=0xA5)){     //Envia los bytes de informacion de este esclavo: [IdEsclavo, regEsclavo, funcEsclavo]
           if (buffer==0xA1){
              SSPBUF = idEsclavo;
           }
           if (buffer==0xA2){
              SSPBUF = funcEsclavo;
           }
           if (buffer==0xA3){
              SSPBUF = regLectura;
           }
           if (buffer==0xA4){
              SSPBUF = regEscritura;
           }
        }
        if ((banId==1)&&(buffer==0xA5)){                  //Si detecta el delimitador de final de trama:
           banId = 0;                                     //Limpia la bandera de escritura de Id
           SSPBUF = 0xB0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
        }

        //Rutina para procesar la Solicitud de Lectura de un registro especifico
        if ((buffer==0xB0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de datos
           banLec = 1;                                    //Activa la bandera de lectura
           SSPBUF = 0xB0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
           Delay_us(50);
        }
        if ((banLec==1)&&(buffer!=0xB0)){
           registro = buffer;
           //Aqui devuelve el numero de bytes necesarios para cada registro de lectura, por ejemplo, este esclavo tiene 4 registros para leer:
           
           //El byte de error es una mera precaucion, ya que la intencion es que al iniciar el esclavoSensor envie toda su informacion al esclavoComunicacion (id, registros, funciones) para que 
           //sea este quien realice las validaciones y asi evite que este dispositivo realice tareas inecesarias
           switch (registro){
                  case 0:
                       numBytesSPI = 0x02;                //Si solicita leer el registro #1 establece que el numero de bytes que va a responder sera 3 (ejemplo), uno de direccion y dos de datos
                       SSPBUF = numBytesSPI;              //Escribe la variable numBytesSPI en el buffer para enviarle al Maestro el numero de bytes que le va a responder
                       break;
                  case 1:
                       numBytesSPI = 0x02;
                       SSPBUF = numBytesSPI;
                       break;
                  case 2:
                       numBytesSPI = 0x04;
                       SSPBUF = numBytesSPI;
                       break;
                  case 3:
                       numBytesSPI = 0x04;
                       SSPBUF = numBytesSPI;
                       break;
                  default:
                       SSPBUF = 0x01;                     //Si solicita leer un registro inexixtente devuelve una longitud de un solo byte para mandar el mensaje de error
           }
        }
        if ((banLec==1)&&(buffer==0xB1)){                 //Si detecta el delimitador de final de trama:
           banPet = 1;                                    //Activa la bandera de peticion
           banLec = 0;                                    //Limpia la bandera de medicion
           banResp = 0;                                   //Limpia la bandera de peticion. **Esto parece no ser necesario pero quiero asegurarme de que no entre al siguiente if sin antes pasar por el bucle
           SSPBUF = 0xC0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
        }

        //Rutina para enviar la respuesta de la Solicitud de Lectura
        if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
           if (i<numBytesSPI){
              SSPBUF = resSPI[i];
              i++;
           }
        }
        
        //Rutina para procesar la Solicitud de Escritura de un registro especifico
        if ((buffer==0xD0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de datos y si la bandera de escritura esta desactivada
           banEsc = 1;                                    //Activa la bandera de escritura de Id
           j=0;
        }
        if ((banEsc==1)&&(buffer!=0xD0)){
           datosEscritura[j] = buffer;                    //Guarda en el vector el registro que se quiere escribir y los datos correspondientes
           if (j>1){
              regEsc = datosEscritura[1];                 //Guarda en la variable el valor del registro que se quiere escribir
              numDatosEsc = datosEscritura[1];            //Si el subindice es mayor a 1 guarda en la variable numDatosEsc el valor del numero de datos que se desea escribir en el registro
              if ((j-1)==numDatosEsc){
                 banEsc = 0;
                 numDatosEsc = 0;
                 for (x=0;x<6;x++){
                      UART1_Write(datosEscritura[x]);
                 }
              }
           }
           j++;
        }

     }

}


void main() {

     ConfiguracionPrincipal();
     ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)
     AUX = 0;
     i = 0;
     x = 0;
     banPet = 0;
     banResp = 0;
     banSPI = 0;
     banLec = 0;
     banId = 0;
     banEsc = 0;
     
     //respSPI = 0xC0;
     SSPBUF = 0xA0;                                   //Carga un valor inicial en el buffer
     numDatosEsc = 0;
     regEsc = 0;

     while(1){

          if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
             
             Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
             resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
             resSPI[1] = 0x58;
             resSPI[2] = 0x8F;
             resSPI[3] = 0x5C;
             i=0;

             ECINT = 0;                               //Genera un pulso en bajo para producir una interrupcion externa en el Master
             Delay_ms(1);
             ECINT = 1;
             banPet = 0;                              //Limpia la bandera de peticion SPI
             banResp = 1;                             //Activa la bandera de respuesta SPI

          }

     }

}