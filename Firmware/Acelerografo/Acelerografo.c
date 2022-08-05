/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz, email: miltonrodrigomunoz@gmail.com
Fecha de creacion: 14/03/2019
Configuracion: dsPIC33EP256MC202, XT=80MHz
---------------------------------------------------------------------------------------------------------------------------*/

////////////////////////////////////////////////////         Librerias         /////////////////////////////////////////////////////////////

#include <ADXL355_SPI.c>
#include <TIEMPO_GPS.c>
#include <TIEMPO_RTC.c>
#include <TIEMPO_RPI.c>

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////

// Subindices:
unsigned int i, x, y, j;

// Definicion de pines:
sbit RP1 at LATA4_bit; // Definicion del pin P1
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit; // Definicion del pin P2
sbit RP2_Direction at TRISB4_bit;
sbit TEST at LATB12_bit; // Definicion del pin P2
sbit TEST_Direction at TRISB12_bit;

// Variables para la comunicacion SPI:
char bufferSPI;
char banLec, banEsc, banCiclo, banInicio;
char banMuestrear;
// char banLeer, banConf;  //Ojo: Parece que no son utilizadas para nada importantes
char banOperacion, tipoOperacion;
char banSPI0, banSPI1, banSPI2, banSPI3, banSPI4, banSPI5, banSPI6, banSPI7, banSPI8, banSPI9, banSPIA;

// Variables para manejo del GPS:
unsigned int i_gps;
char byteGPS, banGPSI, banGPSC;
char tramaGPS[70];
char datosGPS[13];
// char banTFGPS, stsGPS;
// char banSetGPS;

// Variables para manejo del tiempo:
char tiempo[6];    // Vector de datos de tiempo del sistema
char tiempoRPI[6]; // Vector para recuperar el tiempo enviado desde la RPi
char banSetReloj, banSyncReloj;
char fuenteReloj;
unsigned long horaSistema, fechaSistema;

// Variables para manejo del acelerometro:
char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
char datosFIFO[243];      // Vector para almacenar 27 muestras de 3 ejes del vector FIFO
char tramaCompleta[2506]; // Vector para almacenar 10 vectores datosFIFO, 250 cabeceras de muestras y el vector tiempo
// char tramaSalida[2506];  //Declarado pero nunca utilizado
char numFIFO, numSetsFIFO; // Variablea para almacenar el numero de muestras y sets recuperados del buffer FIFO
char contTimer1;           // Variable para contar el numero de veces que entra a la interrupcion por Timer 1
char contMuestras;
char contCiclos;
unsigned int contFIFO;
char tasaMuestreo; // Cambio minimo: se agrego unsigned
char numTMR1;      // Cambio minimo: se agrego unsigned

// Variables sin usar:
// char banTC, banTI, banTF;                                             //Banderas de trama completa, inicio de trama y final de trama
// short confGPS[2];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////  Declaracion de funciones  /////////////////////////////////////////////////////////
void ConfiguracionPrincipal();
void Muestrear();
void InterrupcionP1(char operacion);
void CambiarEstadoBandera(char bandera, char estado);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////      Main      ////////////////////////////////////////////////////////////////
void main()
{

   ConfiguracionPrincipal();
   // GPS_init();                                                                //Inicializa el GPS
   DS3234_init();                     // inicializa el RTC
   tasaMuestreo = 1;                  // 1=250Hz, 2=125Hz, 4=62.5Hz, 8=31.25Hz
   ADXL355_init(tasaMuestreo);        // Inicializa el modulo ADXL con la tasa de muestreo requerida:
   numTMR1 = (tasaMuestreo * 10) - 1; // Calcula el numero de veces que tienen que desbordarse el TMR1 para cada tasa de muestreo

   // Inicializacion de variables:

   // Subindices:
   i = 0;
   j = 0;
   x = 0;
   y = 0;

   // Comunicacion SPI:
   bufferSPI = 0; //**
   banLec = 0;
   banEsc = 0;
   banCiclo = 0;
   banInicio = 0;
   banOperacion = 0;
   tipoOperacion = 0;
   banMuestrear = 0; // Inicia el programa con esta bandera en bajo para permitir que la RPi envie la peticion de inicio de muestreo
   SPI1BUF = 0x00;
   // banLeer = 0;
   // banConf = 0;
   banSPI0 = 0;
   banSPI1 = 0;
   banSPI2 = 0;
   banSPI3 = 0;
   banSPI4 = 0;
   banSPI5 = 0;
   banSPI6 = 0;
   banSPI7 = 0;
   banSPI8 = 0;
   banSPI9 = 0;
   banSPIA = 0;

   // GPS:
   i_gps = 0;
   byteGPS = 0;
   banGPSI = 0;
   banGPSC = 0;
   // banTFGPS = 0;   //Sin usar
   // banSetGPS = 0;
   // stsGPS = 0;   //Sin usar

   // Tiempo:
   banSetReloj = 0;
   banSyncReloj = 0;
   fuenteReloj = 0;
   horaSistema = 0;
   fechaSistema = 0;

   // Acelerometro:
   contMuestras = 0;
   contCiclos = 0;
   contFIFO = 0;
   numFIFO = 0;
   numSetsFIFO = 0;
   contTimer1 = 0;

   // Puertos:
   RP1 = 0;
   RP2 = 0;
   TEST = 1;

   // Variables sin usar:
   // banTI = 0;

   while (1)
   {
      Delay_ms(100);
   }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////// Funciones ////////////////////////////////////////////////////////////////

//****************************************************************************************************************************************
// Funcion para realizar la configuracion principal
void ConfiguracionPrincipal()
{

   // configuracion del oscilador                                              //FPLLO = FIN*(M/(N1+N2)) = 80.017MHz
   CLKDIVbits.FRCDIV = 0;   // FIN=FRC/1
   CLKDIVbits.PLLPOST = 0;  // N2=2
   CLKDIVbits.PLLPRE = 5;   // N1=7
   PLLFBDbits.PLLDIV = 150; // M=152

   // Configuracion de puertos
   ANSELA = 0;      // Configura PORTA como digital     *
   ANSELB = 0;      // Configura PORTB como digital     *
   TRISA2_bit = 0;  // Configura el pin A2 como salida  *
   TRISA3_bit = 0;  // Configura el pin A3 como salida  *
   TRISA4_bit = 0;  // Configura el pin A4 como salida  *
   TRISB4_bit = 0;  // Configura el pin B4 como salida  *
   TRISB12_bit = 0; // Configura el pin B12 como salida *

   TRISB10_bit = 1; // Configura el pin B10 como entrada *
   TRISB11_bit = 1; // Configura el pin B11 como entrada *
   TRISB13_bit = 1; // Configura el pin B13 como entrada *
   TRISB14_bit = 1;
   TRISB15_bit = 1; // Configura el pin B15 como entrada *

   INTCON2.GIE = 1; // Habilita las interrupciones globales *

   // Configuracion del puerto UART1
   RPINR18bits.U1RXR = 0x22; // Configura el pin RB2/RPI34 como Rx1 *
   RPOR0bits.RP35R = 0x01;   // Configura el Tx1 en el pin RB3/RP35 *
   U1RXIE_bit = 1;           // Habilita la interrupcion por UART1 RX *
   // U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion por UART1 RX *
   IPC2bits.U1RXIP = 0x04; // Prioridad de la interrupcion UART1 RX
   U1STAbits.URXISEL = 0x00;
   UART1_Init(9600); // Inicializa el UART1 con una velocidad de 9600 baudios

   // Configuracion del puerto SPI1 en modo Esclavo
   SPI1STAT.SPIEN = 1;                                                                                                                                                 // Habilita el SPI1 *
   SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE); //*
   SPI1IE_bit = 1;                                                                                                                                                     // Habilita la interrupcion por SPI1  *
   SPI1IF_bit = 0;                                                                                                                                                     // Limpia la bandera de interrupcion por SPI *
   IPC2bits.SPI1IP = 0x03;                                                                                                                                             // Prioridad de la interrupcion SPI1

   // Configuracion del puerto SPI2 en modo Master
   RPINR22bits.SDI2R = 0x21; // Configura el pin RB1/RPI33 como SDI2 *
   RPOR2bits.RP38R = 0x08;   // Configura el SDO2 en el pin RB6/RP38 *
   RPOR1bits.RP37R = 0x09;   // Configura el SCK2 en el pin RB5/RP37 *
   SPI2STAT.SPIEN = 1;       // Habilita el SPI2 *
   SPI2_Init();              // Inicializa el modulo SPI2
   CS_DS3234 = 1;            // Pone en alto el CS del RTC
   CS_ADXL355 = 1;           // Pone en alto el CS del acelerometro

   // Configuracion del acelerometro
   ADXL355_write_byte(POWER_CTL, DRDY_OFF | STANDBY); // Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO

   // Configuracion de la interrupcion externa INT1
   // RPINR0 = 0x2E00;                                                         //Asigna INT1 al RB14/RPI46 (PPS)
   RPINR0 = 0x2F00;        // Asigna INT1 al RB15/RPI47 (SQW)
   INT1IE_bit = 1;         // Habilita la interrupcion externa INT1
   INT1IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
   IPC5bits.INT1IP = 0x01; // Prioridad en la interrupocion externa 1

   // Configuracion del TMR1 con un tiempo de 100ms
   T1CON = 0x0020;
   T1CON.TON = 0;        // Apaga el Timer1
   T1IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR1
   T1IF_bit = 0;         // Limpia la bandera de interrupcion del TMR1
   PR1 = 62500;          // Car ga el preload para un tiempo de 100ms
   IPC0bits.T1IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR1

   Delay_ms(200); // Espera hasta que se estabilicen los cambios
}
//****************************************************************************************************************************************

//*****************************************************************************************************************************************
// Funcion para realizar la interrupcion en la RPi
void InterrupcionP1(char operacion)
{
   // banOperacion = 0;           // Encera la bandera para permitir una nueva peticion de operacion
   CambiarEstadoBandera(0, 0); // Limpia la bandera banSPI0 para permitir una nueva peticion de operacion
   tipoOperacion = operacion;  // Carga en la variable el tipo de operacion requerido
   // Genera el pulso P1 para producir la interrupcion externa en la RPi
   RP1 = 1;
   Delay_us(50);
   RP1 = 0;
}
//*****************************************************************************************************************************************

//*****************************************************************************************************************************************
// Funcion para cambiar el estado de las banderas:
void CambiarEstadoBandera(char bandera, char estado)
{
   if (estado == 1)
   {
      // Cambia el estado de todas las baderas para evitar posibles interferencias
      banSPI0 = 3;
      banSPI1 = 3;
      banSPI2 = 3;
      banSPI4 = 3;
      banSPI5 = 3;
      banSPI6 = 3;
      banSPI7 = 3;
      banSPI8 = 3;
      banSPIA = 3;
      // Activa la bandera requerida:
      switch (bandera)
      {
      case 0:
         banSPI0 = 1;
         break;
      case 1:
         banSPI1 = 1;
         break;
      case 2:
         banSPI2 = 1;
         break;
      case 4:
         banSPI4 = 1;
         break;
      case 5:
         banSPI5 = 1;
         break;
      case 6:
         banSPI6 = 1;
         break;
      case 7:
         banSPI7 = 1;
         break;
      case 8:
         banSPI8 = 1;
         break;
      case 0x0A:
         banSPIA = 1;
         break;
      }
   }

   // Limpia todas las banderas de comunicacion SPI:
   if (estado == 0)
   {
      banSPI0 = 0;
      banSPI1 = 0;
      banSPI2 = 0;
      banSPI4 = 0;
      banSPI5 = 0;
      banSPI6 = 0;
      banSPI7 = 0;
      banSPI8 = 0;
      banSPIA = 0;
   }
}
//*****************************************************************************************************************************************

//****************************************************************************************************************************************
// Funcion para relizar el muesteo
void Muestrear()
{
   if (banCiclo == 0)
   {

      ADXL355_write_byte(POWER_CTL, DRDY_OFF | MEASURING); // Coloca el ADXL en modo medicion
      T1CON.TON = 1;                                       // Enciende el Timer1
   }
   else if (banCiclo == 1)
   {

      banCiclo = 2; // Limpia la bandera de ciclo completo

      tramaCompleta[0] = contCiclos; // LLena el primer elemento de la tramaCompleta con el contador de ciclos
      numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
      numSetsFIFO = (numFIFO) / 3; // Lee el numero de sets disponibles en el FIFO

      // Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
      for (x = 0; x < numSetsFIFO; x++)
      {
         ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
         for (y = 0; y < 9; y++)
         {
            datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
         }
      }

      // Este bucle rellena la trama completa intercalando el numero de muestra correspondientes
      for (x = 0; x < (numSetsFIFO * 9); x++)
      {
         if ((x == 0) || (x % 9 == 0))
         {
            tramaCompleta[contFIFO + contMuestras + x] = contMuestras; // Funciona bien
            tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
            contMuestras++;
         }
         else
         {
            tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
         }
      }

      // LLena la trama tiempo con el valor del tiempo actual del sistema y luega rellena la tramaCompleta con los valores de esta trama
      AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
      for (x = 0; x < 6; x++)
      {
         tramaCompleta[2500 + x] = tiempo[x];
      }

      contMuestras = 0; // Limpia el contador de muestras
      contFIFO = 0;     // Limpia el contador de FIFOs
      T1CON.TON = 1;    // Enciende el Timer1

      banLec = 1; // Activa la bandera de lectura para enviar la trama
      InterrupcionP1(0XB1);

      TEST = 0;
   }

   contCiclos++; // Incrementa el contador de ciclos
}
//****************************************************************************************************************************************

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////// Interrupciones /////////////////////////////////////////////////////////////

// Interrupcion SPI1
void spi_1() org IVT_ADDR_SPI1INTERRUPT
{

   SPI1IF_bit = 0;      // Limpia la bandera de interrupcion por SPI
   bufferSPI = SPI1BUF; // Guarda el contenido del bufeer (lectura)

   //************************************************************************************************************************************
   // Rutina para enviar la peticion de operacion a la RPi  (C:0xA0   F:0xF0)
   if ((banSPI0 == 0) && (bufferSPI == 0xA0))
   {
      // banOperacion = 1;                                                     //Activa la bandera para enviar el tipo de operacion requerido a la RPi
      CambiarEstadoBandera(0, 1);
      SPI1BUF = tipoOperacion; // Carga en el buffer el tipo de operacion requerido
   }
   if ((banSPI0 == 1) && (bufferSPI != 0xA0) && (bufferSPI == 0xF0))
   {
      CambiarEstadoBandera(0, 0); // Limpia la bandera
      tipoOperacion = 0;          // Limpia la variable de tipo de operacion
   }
   //************************************************************************************************************************************

   //************************************************************************************************************************************
   // Rutinas de control del muestreo:

   // Rutina para inicio del muestreo (C:0xA1   F:0xF1):
   if ((banMuestrear == 0) && (bufferSPI == 0xA1))
   {
      banMuestrear = 1; // Cambia el estado de la bandera para que no inicie el muestreo mas de una vez de manera consecutiva
      CambiarEstadoBandera(1, 1);
      banCiclo = 0;
      contMuestras = 0;
      contCiclos = 0;
      contFIFO = 0;
      numFIFO = 0;
      numSetsFIFO = 0;
      contTimer1 = 0;
      banInicio = 1; // Bandera que permite el inicio del muestreo dentro de la interrupcion INT1
      /*
      if (INT1IE_bit==0){
         INT1IE_bit = 1;
      }
      */
   }
   if ((banSPI1 == 1) && (bufferSPI == 0xF1))
   {
      CambiarEstadoBandera(1, 0);
   }

   /*
   // (C:0xA3   F:0xF3)
   // Rutina de lectura de los datos del acelerometro:
   if ((banLec == 1) && (bufferSPI == 0xA3))
   {              // Verifica si la bandera de inicio de trama esta activa
      banLec = 2; // Activa la bandera de lectura
      i = 0;
      SPI1BUF = tramaCompleta[i];
   }
   if ((banLec == 2) && (bufferSPI != 0xF3))
   {
      SPI1BUF = tramaCompleta[i];
      i++;
   }
   if ((banLec == 2) && (bufferSPI == 0xF3))
   {              // Si detecta el delimitador de final de trama:
      banLec = 0; // Limpia la bandera de lectura                        ****AQUI Me QUEDE
      SPI1BUF = 0xFF;
   }
   */
   //************************************************************************************************************************************

   //************************************************************************************************************************************
   // Rutinas de manejo de tiempo:

   // (C:0xA4   F:0xF4)
   // Rutina para obtener la hora de la RPi:
   if ((banSPI4 == 0) && (bufferSPI == 0xA4))
   {
      CambiarEstadoBandera(4, 1);
      j = 0;
   }
   if ((banSPI4 == 1) && (bufferSPI != 0xA4) && (bufferSPI != 0xF4))
   {
      tiempoRPI[j] = bufferSPI;
      j++;
   }
   if ((banSPI4 == 1) && (bufferSPI == 0xF4))
   {
      CambiarEstadoBandera(4, 0);
      horaSistema = RecuperarHoraRPI(tiempoRPI);               // Recupera la hora de la RPi
      fechaSistema = RecuperarFechaRPI(tiempoRPI);             // Recupera la fecha de la RPi
      DS3234_setDate(horaSistema, fechaSistema);               // Configura la hora en el RTC
      horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
      fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
      AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
      fuenteReloj = 2;                                         // Fuente de reloj = RPi
      banSetReloj = 1;                                         // Activa esta bandera para usar la hora/fecha recuperada
      InterrupcionP1(0XB2);                                    // Envia la hora local a la RPi
   }

   // (C:0xA5   F:0xF5)
   // Rutina para enviar la hora local a la RPi:
   if ((banSPI5 == 0) && (bufferSPI == 0xA5))
   {
      CambiarEstadoBandera(5, 1);
      j = 0;
      SPI1BUF = fuenteReloj; // Envia el indicador de fuente de reloj (0:RTC, 1:GPS)
   }
   if ((banSPI5 == 1) && (bufferSPI != 0xA5) && (bufferSPI != 0xF5))
   {
      SPI1BUF = tiempo[j]; // Envia la trama de tiempo
      j++;
   }
   if ((banSPI5 == 1) && (bufferSPI == 0xF5))
   {
      CambiarEstadoBandera(5, 0);
      // SPI1BUF = 0xFF; //**No se que hace esto
   }

   /*
   // Rutina para obtener la hora del GPS(C:0xA6   F:0xF6):
   if ((banSetReloj == 0) && (bufferSPI == 0xA6))
   {
      banGPSI = 1;       // Inicia la bandera de inicio de trama  del GPS
      banGPSC = 0;       // Limpia la bandera de trama completa
      U1MODE.UARTEN = 1; // Inicializa el UART1
   }
   */

   // (C:0xA7   F:0xF7)
   // Rutina para obtener la hora del RTC:
   if ((banSPI7 == 0) && (bufferSPI == 0xA7))
   {
      CambiarEstadoBandera(7, 1);
   }
   if ((banSPI7 == 1) && (bufferSPI == 0xF7))
   {
      CambiarEstadoBandera(7, 0);
      horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
      fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
      AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
      fuenteReloj = 0;                                         // Indica que la fuente de reloj es el RTC
      banSetReloj = 1;                                         // Activa esta bandera para usar la hora/fecha recuperada
      InterrupcionP1(0XB2);                                    // Envia la hora local a la RPi
   }

   //************************************************************************************************************************************
}
//************************************************************************************************************************************

//************************************************************************************************************************************
// Interrupcion INT1
void int_1() org IVT_ADDR_INT1INTERRUPT
{

   INT1IF_bit = 0; // Limpia la bandera de interrupcion externa INT1

   // Incrementa el reloj del sistema:
   if (banSetReloj == 1)
   {
      TEST = ~TEST;
      horaSistema++; // Incrementa el reloj del sistema
   }

   // Reinicia el reloj al llegar a las 24:00:00 horas: (24*3600)+(0*60)+(0) = 86400
   if (horaSistema == 86400)
   {
      horaSistema = 0;
   }

   // Inicia el muestreo
   if (banInicio == 1)
   {
      // TEST = ~TEST;
      // Muestrear();
   }
}
//************************************************************************************************************************************

//************************************************************************************************************************************
// Interrupcion por desbordamiento del Timer1
void Timer1Int() org IVT_ADDR_T1INTERRUPT
{

   T1IF_bit = 0; // Limpia la bandera de interrupcion por desbordamiento del Timer1

   numFIFO = ADXL355_read_byte(FIFO_ENTRIES); // 75                            //Lee el numero de muestras disponibles en el FIFO
   numSetsFIFO = (numFIFO) / 3;               // 25                            //Lee el numero de sets disponibles en el FIFO

   // Este bucle recupera tantos sets de mediciones del buffer FIFO como indique la variable anterior
   for (x = 0; x < numSetsFIFO; x++)
   {
      ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
      for (y = 0; y < 9; y++)
      {
         datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
      }
   }

   // Este bucle rellena la trama completa intercalando el numero de muestra correspondientes
   for (x = 0; x < (numSetsFIFO * 9); x++)
   { // 0-224
      if ((x == 0) || (x % 9 == 0))
      {
         tramaCompleta[contFIFO + contMuestras + x] = contMuestras;
         tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
         contMuestras++;
      }
      else
      {
         tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
      }
   }

   contFIFO = (contMuestras * 9); // Incrementa el contador de FIFOs

   contTimer1++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer1

   if (contTimer1 == numTMR1)
   {                  // Verifica si se cumplio el numero de interrupciones por TMR1 para la tasa de muestreo seleccionada
      T1CON.TON = 0;  // Apaga el Timer1
      banCiclo = 1;   // Activa la bandera que indica que se completo un ciclo de medicion
      contTimer1 = 0; // Limpia el contador de interrupciones por Timer1
   }
}
//************************************************************************************************************************************

//*****************************************************************************************************************************************
// Interrupcion UART1
void urx_1() org IVT_ADDR_U1RXINTERRUPT
{

   // Recupera el byte recibido en cada interrupcion:
   U1RXIF_bit = 0;    // Limpia la bandera de interrupcion por UART
   byteGPS = U1RXREG; // Lee el byte de la trama enviada por el GPS
   U1STA.OERR = 0;    // Limpia este bit para limpiar el FIFO UART1

   // Recupera el pyload de la trama GPS:                                      //Aqui deberia entrar despues de recuperar la cabecera de trama
   if (banGPSI == 3)
   {
      if (byteGPS != 0x2A)
      {
         tramaGPS[i_gps] = byteGPS; // LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
         i_gps++;
      }
      else
      {
         banGPSI = 0; // Limpia la bandera de inicio de trama
         banGPSC = 1; // Activa la bandera de trama completa
      }
   }

   // Recupera la cabecera de la trama GPS:                                    //Aqui deberia entrar primero cada vez que se recibe una trama nueva
   if ((banGPSI == 1))
   {
      if (byteGPS == 0x24)
      { // Verifica si el primer byte recibido sea la cabecera de trama "$"
         banGPSI = 2;
         i_gps = 0;
      }
   }
   if ((banGPSI == 2) && (i_gps < 6))
   {
      tramaGPS[i_gps] = byteGPS; // Recupera los datos de cabecera de la trama GPS: ["$", "G", "P", "R", "M", "C"]
      i_gps++;
   }
   if ((banGPSI == 2) && (i_gps == 6))
   {
      // Detiene el Timeout 1:
      T2CON.TON = 0;
      TMR2 = 0;
      // Comprueba la cabecera GPRMC:
      if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
      {
         banGPSI = 3;
         i_gps = 0;
      }
      else
      {
         banGPSI = 0;
         banGPSC = 0;
         i_gps = 0;
         // Recupera la hora del RTC:
         horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
         fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
         AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
         fuenteReloj = 4;                                         // Fuente reloj: RTC/E4
         banSetReloj = 1;
         InterrupcionP1(0xB2); // Envia la hora local a la RPi y a los nodos                                                   //Envia la hora local a la RPi
         banGPSI = 0;
         banGPSC = 0;
         i_gps = 0;
         U1MODE.UARTEN = 0; // Desactiva el UART1
      }
   }

   // Realiza el procesamiento de la informacion del  pyload:                  //Aqui se realiza cualquier accion con el pyload recuperado
   if (banGPSC == 1)
   {
      // Extrae los datos de la trama GPS:
      for (x = 0; x < 6; x++)
      {
         datosGPS[x] = tramaGPS[x + 1]; // Guarda los datos de hhmmss
      }
      // Busca el simbolo "," a partir de la posicion 44
      for (x = 44; x < 54; x++)
      {
         if (tramaGPS[x] == 0x2C)
         {
            for (y = 0; y < 6; y++)
            {
               datosGPS[6 + y] = tramaGPS[x + y + 1]; // Guarda los datos de DDMMAA en la trama datosGPS
            }
         }
      }
      horaSistema = RecuperarHoraGPS(datosGPS);                // Recupera la hora del GPS
      fechaSistema = RecuperarFechaGPS(datosGPS);              // Recupera la fecha del GPS
      AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del gps

      /*
      //Prueba
       //Recupera la hora del RTC:
       horaSistema = RecuperarHoraRTC();                                       //Recupera la hora del RTC
       fechaSistema = RecuperarFechaRTC();                                     //Recupera la fecha del RTC
       AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);                //Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
       fuenteReloj = 4;                                                        //Fuente reloj: RTC/E5
       banSetReloj = 1;
       InterrupcionP1(0XB2);
      //Fin prueba
      */

      // Verifica que el caracter 12 sea igual a "A" lo cual comprueba que los datos son validos:
      if (tramaGPS[12] == 0x41)
      {
         fuenteReloj = 1; // Fuente reloj: GPS
         banSyncReloj = 1;
         banSetReloj = 1;
         // Prueba
         InterrupcionP1(0xB2);
         // Fin prueba
      }
      else
      {
         fuenteReloj = 3; // Fuente reloj: GPS/E3
         banSyncReloj = 1;
         banSetReloj = 1;
         InterrupcionP1(0xB2); // Envia la hora local a la RPi
      }

      banGPSI = 0;
      banGPSC = 0;
      i_gps = 0;
      U1MODE.UARTEN = 0; // Desactiva el UART1
   }
}
//*****************************************************************************************************************************************

// Fuentes de reloj V1:
// 0 -> RTC
// 1 -> GPS

// Fuentes de reloj V2:
// 0 -> GPS
// 1 -> RTC
// 2 -> RPi
// 3 -> Error 3: Problemas al recuperar la trama GPRMC del GPS
// 4 -> Error 4: La hora del GPS es invalida
// 5 -> Error 5: El GPS tarda en responder