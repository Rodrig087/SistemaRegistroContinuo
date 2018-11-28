/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 20/11/2018
Configuracion: PIC16F876A XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
sbit AUX at RB3_bit;                                    //Definicion del pin de indicador auxiliar para hacer pruebas
sbit AUX_Direction at TRISB3_bit;
sbit ECINT at RC2_bit;                                  //Definicion del pin de indicador auxiliar para hacer pruebas
sbit ECINT_Direction at TRISC2_bit;

unsigned char tramaSPI[15];                             //Vector para almacenar la peticion proveniente de la Rpi
unsigned char petSPI[15];
unsigned char resSPI[15];
unsigned short sizeSPI;                                 //Variable para la longitud de trama de comunicacion con la Rpi
unsigned short direccionRpi;                            //Variable para almacenar la direccion del esclavo requerido por el Master
unsigned short funcionRpi;                              //Variable para alamacenar el tipo de funcion requerida por el Master
unsigned short i, x;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banMed;


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

     //Configuracion del puerto UART
     UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
     //PIE1.RCIE = 1;

     //Configuracion del puerto SPI en modo Esclavo
     SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
     PIE1.SSPIE = 1;                                  //Habilita la interrupcion por SPI

     //Configuracion de la interrupcion externa
     INTCON.INTE = 1;                                   //Habilita la interrupcion externa
     INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
     OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de bajada

     Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios

}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(){

//Interrupcion Externa
     if (INTCON.INTF==1){
        INTCON.INTF = 0;                                  //Limpia la badera de interrupcion externa
        SSPBUF = 0xBB;
     }
 
//Interrupcion SPI
     if (PIR1.SSPIF){
     
        PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
        AUX = 1;
        AUX = 0;
        
        buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
        
        if (buffer==0xA0){                                //Verifica si el primer byte es la cabecera de datos
           banMed = 1;
           SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
           Delay_us(50);
        }
        if ((banMed==1)&&(buffer!=0xA0)&&(buffer!=0xA1)){
           registro = buffer;
           switch (registro){
                  case 1:
                       numBytesSPI = 0x02;
                       SSPBUF = numBytesSPI;
                       break;
                  case 2:
                       numBytesSPI = 0x04;
                       SSPBUF = numBytesSPI;
                       break;
                  default:
                       SSPBUF = 0;
           }
        }
        if (buffer==0xA1){
           banPet = 1;
           banMed = 0;
           UART1_Write(registro);
           SSPBUF = 0xB0;
        }
        
        if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
           if (i<numBytesSPI){
              SSPBUF = resSPI[i];
              i++;
           }
          /*if (x==(numBytesSPI+0)){
              //SSPBUF = 0xA0;
              i=0;
              banResp=0;
           }*/
        }
        
        
     }

}


void main() {

     ConfiguracionPrincipal();
     ECINT = 0;
     AUX = 0;
     i = 0;
     x = 0;
     banPet = 0;
     banResp = 0;
     banSPI = 0;
     banMed = 0;
     respSPI = 0xC0;
     SSPBUF = 0xA0;                                   //Carga un valor inicial en el buffer
     


     while(1){
     
          if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
             Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
             resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
             resSPI[1] = 0x58;
             resSPI[2] = 0x8F;
             resSPI[3] = 0x5C;
             i=0;
             
             ECINT = 1;                               //Genera un pulso en alto para producir una interrupcion externa en el Master
             Delay_ms(1);
             ECINT = 0;
             banPet = 0;                              //Limpia la bandera de peticion SPI
             banResp = 1;                             //Activa la bandera de respuesta SPI
             
          }

       /*if ((i<4)&&(banPet==0)){
           while (SSPSTAT.BF!=1);
           buffer=SSPBUF;
           tramaSPI[i]=buffer;
           i++;
           SSPCON.SSPOV=0;
        } else if ((i==4)&&(banPet==0)) {
           i=0;
           SSPCON.SSPOV=0;
           banPet = 1;
        }*/
        
        /*if ((banPet==1)) {

           for (x=0;x<3; x++){
               UART1_Write(tramaSPI[x]);
           }

           Delay_ms(1000);


           respSPI++;
           SSPBUF = respSPI;
           ECINT = 1;
           Delay_ms(10);
           ECINT = 0;
           while (SSPSTAT.BF!=1);

           banSPI = 0;
           banPet = 0;
        }*/
        

        /*Delay_ms(1);
        SSPBUF = 0xC2;
        Delay_ms(1);
        SSPBUF = 0xC3;*/
        
        

     }

}