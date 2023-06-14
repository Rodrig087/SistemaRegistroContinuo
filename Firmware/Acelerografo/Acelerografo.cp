#line 1 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.h"
#line 100 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.h"
sbit CS_ADXL355 at LATA3_bit;


void ADXL355_init(short tMuestreo);
void ADXL355_write_byte(unsigned char address, unsigned char value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_data(unsigned char *vectorMuestra);
unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO);
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_gps.h"






void GPS_init();
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rpi.h"




unsigned long RecuperarFechaRPI(unsigned char *tramaTiempoRpi);
unsigned long RecuperarHoraRPI(unsigned char *tramaTiempoRpi);
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rtc.h"




sbit CS_DS3234 at LATA2_bit;


void DS3234_init();
void DS3234_write_byte(unsigned char address, unsigned char value);
void DS3234_read_byte(unsigned char address, unsigned char value);
void DS3234_setDate(unsigned long longHora, unsigned long longFecha);
unsigned long RecuperarFechaRTC();
unsigned long RecuperarHoraRTC();
unsigned long IncrementarFecha(unsigned long longFecha);
void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema);
#line 19 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
sbit RP1 at LATA4_bit;
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;
sbit RP2_Direction at TRISB4_bit;
sbit LedTest at LATB12_bit;
sbit TEST_Direction at TRISB12_bit;

unsigned char tramaGPS[70];
unsigned char datosGPS[13];
unsigned char tiempo[6];
unsigned char tiempoRPI[6];
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];
unsigned char tramaCompleta[2506] = {0};
unsigned char numFIFO, numSetsFIFO;
unsigned char contTimer1;

unsigned int i, x, y, i_gps, j;
unsigned char buffer;
unsigned char contMuestras;
unsigned char contCiclos;
unsigned int contFIFO;
unsigned char tasaMuestreo;
unsigned char numTMR1;

unsigned char banTC, banTI, banTF;
unsigned char banLec, banEsc, banCiclo, banInicio, banSetReloj, banSetGPS, banSyncReloj;
unsigned char banMuestrear, banLeer, banConf;
unsigned char banOperacion, tipoOperacion;

unsigned char byteGPS, banGPSI, banTFGPS, banGPSC, stsGPS;
unsigned char fuenteReloj;
unsigned char confGPS[2];
unsigned long horaSistema, fechaSistema;
unsigned char referenciaTiempo;
unsigned char banInicializar;
unsigned char contTimeout1;
unsigned char banInitGPS;
unsigned char contTimer3;









void ConfiguracionPrincipal();
void Muestrear();
void InterrupcionP1(unsigned char operacion);



void main()
{

 tasaMuestreo = 1;
 numTMR1 = (tasaMuestreo * 10) - 1;

 banOperacion = 0;
 tipoOperacion = 0;

 banTI = 0;
 banLec = 0;
 banEsc = 0;
 banCiclo = 0;
 banSetReloj = 0;

 banSetGPS = 0;
 banGPSI = 0;
 banTFGPS = 0;
 banGPSC = 0;
 stsGPS = 0;
 fuenteReloj = 0;
 banSyncReloj = 0;

 banMuestrear = 0;
 banInicio = 0;
 banLeer = 0;
 banConf = 0;

 i = 0;
 x = 0;
 y = 0;
 i_gps = 0;
 horaSistema = 0;
 referenciaTiempo = 0;
 contTimeout1 = 0;

 contMuestras = 0;
 contCiclos = 0;
 contFIFO = 0;
 numFIFO = 0;
 numSetsFIFO = 0;
 contTimer1 = 0;
 contTimer3 = 0;

 byteGPS = 0;
 banInitGPS = 0;


 banInicializar = 0;

 RP1 = 0;
 RP2 = 0;
 LedTest = 0;

 SPI1BUF = 0x00;

 ConfiguracionPrincipal();

 while (1)
 {
#line 163 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
 Delay_ms(1);
 }

}






void ConfiguracionPrincipal()
{


 CLKDIVbits.FRCDIV = 0;
 CLKDIVbits.PLLPOST = 0;
 CLKDIVbits.PLLPRE = 5;
 PLLFBDbits.PLLDIV = 150;


 ANSELA = 0;
 ANSELB = 0;
 TRISA2_bit = 0;
 TRISA3_bit = 0;
 TRISA4_bit = 0;
 TRISB4_bit = 0;
 TRISB12_bit = 0;

 TRISB10_bit = 1;
 TRISB11_bit = 1;
 TRISB13_bit = 1;
 TRISB14_bit = 1;
 TRISB15_bit = 1;

 INTCON2.GIE = 1;


 SPI1STAT.SPIEN = 1;
 SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);
 SPI1IE_bit = 1;
 SPI1IF_bit = 0;
 IPC2bits.SPI1IP = 0x03;


 RPINR22bits.SDI2R = 0x21;
 RPOR2bits.RP38R = 0x08;
 RPOR1bits.RP37R = 0x09;
 SPI2STATbits.SPIROV = 0;
 SPI2STAT.SPIEN = 1;
 SPI2_Init();
 CS_DS3234 = 1;
 CS_ADXL355 = 1;


 RPINR18bits.U1RXR = 0x22;
 RPOR0bits.RP35R = 0x01;
 U1RXIE_bit = 1;
 U1RXIF_bit = 0;
 IPC2bits.U1RXIP = 0x04;
 U1STAbits.URXISEL = 0x00;
 UART1_Init(9600);


 RPINR0 = 0x2F00;
 INT1IE_bit = 1;
 INT1IF_bit = 0;
 IPC5bits.INT1IP = 0x02;


 RPINR1 = 0x002E;
 INT2IE_bit = 1;
 INT2IF_bit = 0;
 IPC7bits.INT2IP = 0x01;


 T1CON = 0x0020;
 T1CON.TON = 0;
 T1IE_bit = 1;
 T1IF_bit = 0;
 PR1 = 62500;
 IPC0bits.T1IP = 0x02;


 T2CON = 0x30;
 T2CON.TON = 0;
 T2IE_bit = 1;
 T2IF_bit = 0;
 PR2 = 46875;
 IPC1bits.T2IP = 0x02;


 T3CON = 0x20;
 T3CON.TON = 0;
 T3IE_bit = 1;
 T3IF_bit = 0;
 PR3 = 62500;
 IPC2bits.T3IP = 0x02;

 Delay_ms(200);


 DS3234_init();

 Delay_ms(500);


 ADXL355_init(tasaMuestreo);


 GPS_init();
 U1MODE.UARTEN = 0;


 LedTest = ~LedTest;
 Delay_ms(300);
 LedTest = ~LedTest;
 Delay_ms(300);
 LedTest = ~LedTest;

}




void InterrupcionP1(unsigned char operacion)
{
 banOperacion = 0;
 tipoOperacion = operacion;

 RP1 = 1;
 Delay_us(20);
 RP1 = 0;
}




void Muestrear()
{

 if (banCiclo == 1)
 {
 ADXL355_write_byte( 0x2D ,  0x04  |  0x00 );
 T1CON.TON = 1;
 }
 else if (banCiclo == 2)
 {

 banCiclo = 3;

 tramaCompleta[0] = fuenteReloj;
 numFIFO = ADXL355_read_byte( 0x05 );
 numSetsFIFO = (numFIFO) / 3;


 for (x = 0; x < numSetsFIFO; x++)
 {
 ADXL355_read_FIFO(datosLeidos);
 for (y = 0; y < 9; y++)
 {
 datosFIFO[y + (x * 9)] = datosLeidos[y];

 }
 }


 for (x = 0; x < (numSetsFIFO * 9); x++)
 {
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


 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 for (x = 0; x < 6; x++)
 {
 tramaCompleta[2500 + x] = tiempo[x];
 }

 contMuestras = 0;
 contFIFO = 0;
 T1CON.TON = 1;

 banLec = 1;
 InterrupcionP1(0XB1);

 LedTest = 0;
 }

}







void spi_1() org IVT_ADDR_SPI1INTERRUPT
{

 SPI1IF_bit = 0;
 buffer = SPI1BUF;



 if ((banOperacion == 0) && (buffer == 0xA0))
 {
 banOperacion = 1;
 SPI1BUF = tipoOperacion;
 }
 if ((banOperacion == 1) && (buffer == 0xF0))
 {
 banOperacion = 0;
 tipoOperacion = 0;
 }




 if ((banMuestrear == 0) && (buffer == 0xA1))
 {
 banMuestrear = 1;
 banCiclo = 1;
 }
 if ((banMuestrear == 1) && (buffer != 0xA1) && (buffer != 0xF1))
 {
 banInicio = 1;
#line 407 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
 }
 if ((banMuestrear == 1) && (buffer == 0xF1))
 {
 banMuestrear = 0;
 }


 if ((banInitGPS == 0) && (buffer == 0xA2))
 {

 banInitGPS = 1;
 SPI1BUF = 0x47;
 }
 if ((banInitGPS == 1) && (buffer == 0xF2))
 {


 LedTest = 0;
 Delay_ms(150);
 LedTest = ~LedTest;
 Delay_ms(150);
 LedTest = ~LedTest;
 Delay_ms(150);
 LedTest = ~LedTest;
 Delay_ms(150);
 LedTest = ~LedTest;
 Delay_ms(150);
 LedTest = ~LedTest;
 }


 if ((banLec == 1) && (buffer == 0xA3))
 {
 banLec = 2;
 i = 0;
 SPI1BUF = tramaCompleta[i];
 }
 if ((banLec == 2) && (buffer != 0xF3))
 {
 SPI1BUF = tramaCompleta[i];
 i++;
 }
 if ((banLec == 2) && (buffer == 0xF3))
 {
 banLec = 0;
 SPI1BUF = 0xFF;
 }




 if ((banEsc == 0) && (buffer == 0xA4))
 {
 banEsc = 1;
 j = 0;
 }
 if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
 {
 tiempoRPI[j] = buffer;
 j++;
 }
 if ((banEsc == 1) && (buffer == 0xF4))
 {
 horaSistema = RecuperarHoraRPI(tiempoRPI);
 fechaSistema = RecuperarFechaRPI(tiempoRPI);
 DS3234_setDate(horaSistema, fechaSistema);
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 0;
 InterrupcionP1(0XB2);
 banEsc = 0;
 banSetReloj = 1;
 }


 if ((banSetReloj == 1) && (buffer == 0xA5))
 {
 banSetReloj = 2;
 j = 0;
 SPI1BUF = fuenteReloj;
 }
 if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
 {
 SPI1BUF = tiempo[j];
 j++;
 }
 if ((banSetReloj == 2) && (buffer == 0xF5))
 {
 banSetReloj = 1;
 SPI1BUF = 0xFF;
 }


 if ((banEsc == 0) && (buffer == 0xA6))
 {
 banEsc = 1;
 }
 if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
 {
 referenciaTiempo = buffer;
 }
 if ((banEsc == 1) && (buffer == 0xF6))
 {
 if (referenciaTiempo == 1)
 {

 banGPSI = 1;
 banGPSC = 0;
 U1MODE.UARTEN = 1;

 T2CON.TON = 1;
 TMR2 = 0;
 }
 else
 {

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 2;
 InterrupcionP1(0xB2);
 }
 banEsc = 0;
 banSetReloj = 1;
 }

}




void int_1() org IVT_ADDR_INT1INTERRUPT
{

 INT1IF_bit = 0;

 if (banSetReloj == 1)
 {
 LedTest = ~LedTest;
 horaSistema++;


 if (horaSistema == 86400)
 {
 horaSistema = 0;
 }

 if (banInicio == 1)
 {

 Muestrear();
 }
 }
}



void int_2() org IVT_ADDR_INT2INTERRUPT
{

 INT2IF_bit = 0;

 if (banSyncReloj == 1)
 {


 LedTest = ~LedTest;
 horaSistema = horaSistema + 2;



 T3CON.TON = 1;
 TMR3 = 0;
#line 591 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
 }
}



void Timer1Int() org IVT_ADDR_T1INTERRUPT
{

 T1IF_bit = 0;

 numFIFO = ADXL355_read_byte( 0x05 );
 numSetsFIFO = (numFIFO) / 3;


 for (x = 0; x < numSetsFIFO; x++)
 {
 ADXL355_read_FIFO(datosLeidos);
 for (y = 0; y < 9; y++)
 {
 datosFIFO[y + (x * 9)] = datosLeidos[y];
 }
 }


 for (x = 0; x < (numSetsFIFO * 9); x++)
 {
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

 contFIFO = (contMuestras * 9);

 contTimer1++;

 if (contTimer1 == numTMR1)
 {
 T1CON.TON = 0;
 banCiclo = 2;
 contTimer1 = 0;
 }
}



void Timer2Int() org IVT_ADDR_T2INTERRUPT
{

 T2IF_bit = 0;
 contTimeout1++;


 if (contTimeout1 == 4)
 {
 T2CON.TON = 0;
 TMR2 = 0;
 contTimeout1 = 0;

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 5;
 banSetReloj = 1;
 InterrupcionP1(0xB2);
 }
}



void Timer3Int() org IVT_ADDR_T3INTERRUPT
{
 T3IF_bit = 0;

 contTimer3++;


 if (contTimer3 == 5)
 {
 DS3234_setDate(horaSistema, fechaSistema);

 banSyncReloj = 0;
 banSetReloj = 1;


 InterrupcionP1(0xB2);
 contTimer3 = 0;
 T3CON.TON = 0;
 }
}



void urx_1() org IVT_ADDR_U1RXINTERRUPT
{

 byteGPS = U1RXREG;
 U1STA.OERR = 0;


 if (banGPSI == 3)
 {
 if (byteGPS != 0x2A)
 {
 tramaGPS[i_gps] = byteGPS;
 i_gps++;
 }
 else
 {
 banGPSI = 0;
 banGPSC = 1;
 }
 }


 if ((banGPSI == 1))
 {
 if (byteGPS == 0x24)
 {
 banGPSI = 2;
 i_gps = 0;
 }
 }
 if ((banGPSI == 2) && (i_gps < 6))
 {
 tramaGPS[i_gps] = byteGPS;
 i_gps++;
 }
 if ((banGPSI == 2) && (i_gps == 6))
 {

 T2CON.TON = 0;
 TMR2 = 0;

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

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 4;
 banSetReloj = 1;
 InterrupcionP1(0xB2);
 banGPSI = 0;
 banGPSC = 0;
 i_gps = 0;
 U1MODE.UARTEN = 0;
 }
 }


 if (banGPSC == 1)
 {

 for (x = 0; x < 6; x++)
 {
 datosGPS[x] = tramaGPS[x + 1];
 }

 for (x = 44; x < 54; x++)
 {
 if (tramaGPS[x] == 0x2C)
 {
 for (y = 0; y < 6; y++)
 {
 datosGPS[6 + y] = tramaGPS[x + y + 1];
 }
 }
 }
 horaSistema = RecuperarHoraGPS(datosGPS);
 fechaSistema = RecuperarFechaGPS(datosGPS);
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);


 if (tramaGPS[12] == 0x41)
 {
 fuenteReloj = 1;
 banSyncReloj = 1;
 banSetReloj = 0;
 }
 else
 {
 fuenteReloj = 3;
 banSyncReloj = 0;
 banSetReloj = 1;
 InterrupcionP1(0xB2);
 }
 banGPSI = 0;
 banGPSC = 0;
 i_gps = 0;
 U1MODE.UARTEN = 0;
 }


 U1RXIF_bit = 0;
}
