#line 1 "C:/Users/milto/Milton/RSA/Git/Registro Continuo/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
#line 1 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.c"
#line 96 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.c"
sbit CS_ADXL355 at LATA3_bit;
unsigned short axisAddresses[] = { 0x08 ,  0x09 ,  0x0A ,  0x0B ,  0x0C ,  0x0D ,  0x0E ,  0x0F ,  0x10 };

void ADXL355_init();
void ADXL355_write_byte(unsigned char address, unsigned char value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_data(unsigned char *vectorMuestra);
unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO);


void ADXL355_init(short tMuestreo){
 ADXL355_write_byte( 0x2F ,0x52);
 Delay_ms(10);
 ADXL355_write_byte( 0x2D ,  0x04 | 0x01 );
 ADXL355_write_byte( 0x2C ,  0x01 );
 switch (tMuestreo){
 case 1:
 ADXL355_write_byte( 0x28 ,  0x00 | 0x04 );
 break;
 case 2:
 ADXL355_write_byte( 0x28 ,  0x00 | 0x05 );
 break;
 case 4:
 ADXL355_write_byte( 0x28 ,  0x00 | 0x06 );
 break;
 case 8:
 ADXL355_write_byte( 0x28 ,  0x00 | 0x07  );
 break;
 }
}


void ADXL355_write_byte(unsigned char address, unsigned char value){
 address = (address<<1)&0xFE;
 CS_ADXL355=0;
 SPI2_Write(address);
 SPI2_Write(value);
 CS_ADXL355=1;
}


unsigned char ADXL355_read_byte(unsigned char address){
 unsigned char value = 0x00;
 address=(address<<1)|0x01;
 CS_ADXL355=0;
 SPI2_Write(address);
 value=SPI2_Read(0);
 CS_ADXL355=1;
 return value;
}


unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
 unsigned short j;
 unsigned short muestra;
 if((ADXL355_read_byte( 0x04 )&0x01)==1){
 CS_ADXL355=0;
 for (j=0;j<9;j++){
 muestra = ADXL355_read_byte(axisAddresses[j]);
 vectorMuestra[j] = muestra;
 }
 CS_ADXL355=1;
 } else {
 for (j=0;j<9;j++){
 vectorMuestra[j] = 0;
 }
 }
 return;
}


unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO){
 unsigned char add;
 add = ( 0x11 <<1)|0x01;
 CS_ADXL355 = 0;
 SPI2_Write(add);

 vectorFIFO[0] = SPI2_Read(0);
 vectorFIFO[1] = SPI2_Read(1);
 vectorFIFO[2] = SPI2_Read(2);

 vectorFIFO[3] = SPI2_Read(0);
 vectorFIFO[4] = SPI2_Read(1);
 vectorFIFO[5] = SPI2_Read(2);

 vectorFIFO[6] = SPI2_Read(0);
 vectorFIFO[7] = SPI2_Read(1);
 vectorFIFO[8] = SPI2_Read(2);
 CS_ADXL355 = 1;
 Delay_us(5);
 return;
}
#line 1 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_gps.c"




void GPS_init(short conf,short NMA);
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);





void GPS_init(short conf,short NMA){
 if (conf==1){
 UART1_Init(9600);
 Delay_ms(200);
 UART1_Write_Text("$PMTK605*31\r\n");
 UART1_Write_Text("$PMTK220,1000*1F\r\n");
 UART1_Write_Text("$PMTK251,115200*1F\r\n");
 Delay_ms(1000);
 UART1_Init(115200);
 }

 UART1_Write_Text("$PMTK313,1*2E\r\n");
 UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
 UART1_Write_Text("$PMTK319,1*24\r\n");
 UART1_Write_Text("$PMTK413*34\r\n");
 UART1_Write_Text("$PMTK513,1*28\r\n");

 switch (NMA){
 case 1:
 UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
 break;
 case 3:
 UART1_Write_Text("$PMTK314,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
 break;
 default:
 UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
 break;
 }

 Delay_ms(1000);
}




unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS){

 unsigned long tramaFecha[4];
 unsigned long fechaGPS;
 char datoStringF[3];
 char *ptrDatoStringF = &datoStringF;
 datoStringF[2] = '\0';
 tramaFecha[3] = '\0';


 datoStringF[0] = tramaDatosGPS[6];
 datoStringF[1] = tramaDatosGPS[7];
 tramaFecha[0] = atoi(ptrDatoStringF);


 datoStringF[0] = tramaDatosGPS[8];
 datoStringF[1] = tramaDatosGPS[9];
 tramaFecha[1] = atoi(ptrDatoStringF);


 datoStringF[0] = tramaDatosGPS[10];
 datoStringF[1] = tramaDatosGPS[11];
 tramaFecha[2] = atoi(ptrDatoStringF);

 fechaGPS = (tramaFecha[0]*10000)+(tramaFecha[1]*100)+(tramaFecha[2]);

 return fechaGPS;

}


unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS){

 unsigned long tramaTiempo[4];
 unsigned long horaGPS;
 char datoString[3];
 char *ptrDatoString = &datoString;
 datoString[2] = '\0';
 tramaTiempo[3] = '\0';


 datoString[0] = tramaDatosGPS[0];
 datoString[1] = tramaDatosGPS[1];
 tramaTiempo[0] = atoi(ptrDatoString);


 datoString[0] = tramaDatosGPS[2];
 datoString[1] = tramaDatosGPS[3];
 tramaTiempo[1] = atoi(ptrDatoString);


 datoString[0] = tramaDatosGPS[4];
 datoString[1] = tramaDatosGPS[5];
 tramaTiempo[2] = atoi(ptrDatoString);

 horaGPS = (tramaTiempo[0]*3600)+(tramaTiempo[1]*60)+(tramaTiempo[2]);
 return horaGPS;

}
#line 1 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rtc.c"
#line 37 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rtc.c"
sbit CS_DS3234 at LATA2_bit;




void DS3234_init();
void DS3234_write_byte(unsigned char address, unsigned char value);
void DS3234_read_byte(unsigned char address, unsigned char value);
void DS3234_setDate(unsigned long longHora, unsigned long longFecha);
unsigned long RecuperarFechaRTC();
unsigned long RecuperarHoraRTC();
unsigned long IncrementarFecha(unsigned long longFecha);
void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema);





void DS3234_init(){

 SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
 DS3234_write_byte( 0x8E ,0x20);
 DS3234_write_byte( 0x8F ,0x08);
 SPI2_Init();

}


void DS3234_write_byte(unsigned char address, unsigned char value){

 CS_DS3234 = 0;
 SPI2_Write(address);
 SPI2_Write(value);
 CS_DS3234 = 1;

}


unsigned char DS3234_read_byte(unsigned char address){

 unsigned char value = 0x00;
 CS_DS3234 = 0;
 SPI2_Write(address);
 value = SPI2_Read(0);
 CS_DS3234 = 1;
 return value;

}


void DS3234_setDate(unsigned long longHora, unsigned long longFecha){

 unsigned short valueSet;
 unsigned short hora;
 unsigned short minuto;
 unsigned short segundo;
 unsigned short dia;
 unsigned short mes;
 unsigned short anio;

 SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);

 hora = (short)(longHora / 3600);
 minuto = (short)((longHora%3600) / 60);
 segundo = (short)((longHora%3600) % 60);

 dia = (short)(longFecha / 10000);
 mes = (short)((longFecha%10000) / 100);
 anio = (short)((longFecha%10000) % 100);

 segundo = Dec2Bcd(segundo);
 minuto = Dec2Bcd(minuto);
 hora = Dec2Bcd(hora);
 dia = Dec2Bcd(dia);
 mes = Dec2Bcd(mes);
 anio = Dec2Bcd(anio);

 DS3234_write_byte( 0x80 , segundo);
 DS3234_write_byte( 0x81 , minuto);
 DS3234_write_byte( 0x82 , hora);
 DS3234_write_byte( 0x84 , dia);
 DS3234_write_byte( 0x85 , mes);
 DS3234_write_byte( 0x86 , anio);

 SPI2_Init();

 return;

}


unsigned long RecuperarHoraRTC(){

 unsigned short valueRead;
 unsigned long hora;
 unsigned long minuto;
 unsigned long segundo;
 unsigned long horaRTC;

 SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);

 valueRead = DS3234_read_byte( 0x00 );
 valueRead = Bcd2Dec(valueRead);
 segundo = (long)valueRead;
 valueRead = DS3234_read_byte( 0x01 );
 valueRead = Bcd2Dec(valueRead);
 minuto = (long)valueRead;
 valueRead = DS3234_read_byte( 0x02 );
 valueRead = Bcd2Dec(valueRead);
 hora = (long)valueRead;

 horaRTC = (hora*3600)+(minuto*60)+(segundo);

 SPI2_Init();

 return horaRTC;

}


unsigned long RecuperarFechaRTC(){

 unsigned short valueRead;
 unsigned long dia;
 unsigned long mes;
 unsigned long anio;
 unsigned long fechaRTC;

 SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);

 valueRead = DS3234_read_byte( 0x04 );
 valueRead = Bcd2Dec(valueRead);
 dia = (long)valueRead;
 valueRead = 0x1F & DS3234_read_byte( 0x05 );
 valueRead = Bcd2Dec(valueRead);
 mes = (long)valueRead;
 valueRead = DS3234_read_byte( 0x06 );
 valueRead = Bcd2Dec(valueRead);
 anio = (long)valueRead;

 fechaRTC = (anio*10000)+(mes*100)+(dia);

 SPI2_Init();

 return fechaRTC;

}


unsigned long IncrementarFecha(unsigned long longFecha){

 unsigned long dia;
 unsigned long mes;
 unsigned long anio;
 unsigned long fechaInc;

 anio = longFecha / 10000;
 mes = (longFecha%10000) / 100;
 dia = (longFecha%10000) % 100;

 if (dia<28){
 dia++;
 } else {
 if (mes==2){

 if (((anio-16)%4)==0){
 if (dia==29){
 dia = 1;
 mes++;
 } else {
 dia++;
 }
 } else {
 dia = 1;
 mes++;
 }
 } else {
 if (dia<30){
 dia++;
 } else {
 if (mes==4||mes==6||mes==9||mes==11){
 if (dia==30){
 dia = 1;
 mes++;
 } else {
 dia++;
 }
 }
 if ((dia!=1)&&(mes==1||mes==3||mes==5||mes==7||mes==8||mes==10)){
 if (dia==31){
 dia = 1;
 mes++;
 } else {
 dia++;
 }
 }
 if ((dia!=1)&&(mes==12)){
 if (dia==31){
 dia = 1;
 mes = 1;
 anio++;
 } else {
 dia++;
 }
 }
 }
 }

 }

 fechaInc = (anio*10000)+(mes*100)+(dia);
 return fechaInc;

}


void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned short *tramaTiempoSistema){

 unsigned short hora;
 unsigned short minuto;
 unsigned short segundo;
 unsigned short dia;
 unsigned short mes;
 unsigned short anio;

 hora = (short)(longHora / 3600);
 minuto = (short)((longHora%3600) / 60);
 segundo = (short)((longHora%3600) % 60);

 anio = (short)(longFecha / 10000);
 mes = (short)((longFecha%10000) / 100);
 dia = (short)((longFecha%10000) % 100);

 tramaTiempoSistema[0] = anio;
 tramaTiempoSistema[1] = mes;
 tramaTiempoSistema[2] = dia;
 tramaTiempoSistema[3] = hora;
 tramaTiempoSistema[4] = minuto;
 tramaTiempoSistema[5] = segundo;

}
#line 1 "c:/users/milto/milton/rsa/git/registro continuo/sistemaregistrocontinuo/firmware/librerias firmware/tiempo_rpi.c"



unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi);
unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi);




unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi){

 unsigned long fechaRPi;

 fechaRPi = ((long)tramaTiempoRpi[0]*10000)+((long)tramaTiempoRpi[1]*100)+((long)tramaTiempoRpi[2]);

 return fechaRPi;

}


unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi){

 unsigned long horaRPi;

 horaRPi = ((long)tramaTiempoRpi[3]*3600)+((long)tramaTiempoRpi[4]*60)+((long)tramaTiempoRpi[5]);

 return horaRPi;

}
#line 19 "C:/Users/milto/Milton/RSA/Git/Registro Continuo/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
sbit RP1 at LATA4_bit;
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;
sbit RP2_Direction at TRISB4_bit;
sbit LedTest at LATB12_bit;
sbit TEST_Direction at TRISB12_bit;

unsigned char tramaGPS[70];
unsigned char datosGPS[13];
unsigned short tiempo[6];
unsigned short tiempoRPI[6];
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];
unsigned char tramaCompleta[2506];
unsigned char tramaSalida[2506];
unsigned short numFIFO, numSetsFIFO;
unsigned short contTimer1;

unsigned int i, x, y, i_gps, j;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;
unsigned int contFIFO;
short tasaMuestreo;
short numTMR1;

unsigned short banTC, banTI, banTF;
unsigned short banLec, banEsc, banCiclo, banInicio, banSetReloj, banSetGPS;
unsigned short banMuestrear, banLeer, banConf;
unsigned short banOperacion, tipoOperacion;

unsigned char byteGPS, banTIGPS, banTFGPS, banTCGPS, stsGPS;
unsigned short fuenteReloj;
short confGPS[2];
unsigned long horaSistema, fechaSistema;
unsigned short referenciaTiempo;




void ConfiguracionPrincipal();
void Muestrear();
void InterrupcionP1(unsigned short operacion);



void main()
{

 ConfiguracionPrincipal();

 DS3234_init();
 tasaMuestreo = 1;
 ADXL355_init(tasaMuestreo);
 numTMR1 = (tasaMuestreo * 10) - 1;

 banOperacion = 0;
 tipoOperacion = 0;

 banTI = 0;
 banLec = 0;
 banEsc = 0;
 banCiclo = 0;
 banSetReloj = 0;

 banSetGPS = 0;
 banTIGPS = 0;
 banTFGPS = 0;
 banTCGPS = 0;
 stsGPS = 0;
 fuenteReloj = 0;

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

 contMuestras = 0;
 contCiclos = 0;
 contFIFO = 0;
 numFIFO = 0;
 numSetsFIFO = 0;
 contTimer1 = 0;

 byteGPS = 0;

 RP1 = 0;
 RP2 = 0;
 LedTest = 1;

 SPI1BUF = 0x00;

 while (1)
 {
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


 RPINR18bits.U1RXR = 0x22;
 RPOR0bits.RP35R = 0x01;
 U1RXIE_bit = 0;
 U1RXIF_bit = 0;
 IPC2bits.U1RXIP = 0x04;
 U1STAbits.URXISEL = 0x00;
 UART1_Init(115200);


 SPI1STAT.SPIEN = 1;
 SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);
 SPI1IE_bit = 1;
 SPI1IF_bit = 0;
 IPC2bits.SPI1IP = 0x03;


 RPINR22bits.SDI2R = 0x21;
 RPOR2bits.RP38R = 0x08;
 RPOR1bits.RP37R = 0x09;
 SPI2STAT.SPIEN = 1;
 SPI2_Init();
 CS_DS3234 = 1;
 CS_ADXL355 = 1;


 ADXL355_write_byte( 0x2D ,  0x04  |  0x01 );



 RPINR0 = 0x2F00;
 INT1IE_bit = 0;
 INT1IF_bit = 0;
 IPC5bits.INT1IP = 0x01;


 T1CON = 0x0020;
 T1CON.TON = 0;
 T1IE_bit = 1;
 T1IF_bit = 0;
 PR1 = 62500;
 IPC0bits.T1IP = 0x02;

 Delay_ms(200);
}




void InterrupcionP1(unsigned short operacion)
{


 if (INT1IE_bit == 0)
 {
 INT1IE_bit = 1;
 }
#line 217 "C:/Users/milto/Milton/RSA/Git/Registro Continuo/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
 banOperacion = 0;
 tipoOperacion = operacion;

 RP1 = 1;
 Delay_us(20);
 RP1 = 0;
}




void Muestrear()
{

 if (banCiclo == 0)
 {

 ADXL355_write_byte( 0x2D ,  0x04  |  0x00 );
 T1CON.TON = 1;
 }
 else if (banCiclo == 1)
 {

 banCiclo = 2;

 tramaCompleta[0] = contCiclos;
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

 contCiclos++;
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
 banCiclo = 0;
 contMuestras = 0;
 contCiclos = 0;
 contFIFO = 0;
 numFIFO = 0;
 numSetsFIFO = 0;
 contTimer1 = 0;
 banInicio = 1;
 if (INT1IE_bit == 0)
 {
 INT1IE_bit = 1;
 }
 }


 if ((banMuestrear == 1) && (buffer == 0xA2))
 {
 banInicio = 0;
 banMuestrear = 0;

 banTI = 0;
 banLec = 0;
 banEsc = 0;
 banSetReloj = 0;
 banSetGPS = 0;
 banTIGPS = 0;
 banTFGPS = 0;
 banTCGPS = 0;
 banLeer = 0;
 banConf = 0;
 i = 0;
 x = 0;
 y = 0;
 i_gps = 0;
 contTimer1 = 0;
 byteGPS = 0;

 ADXL355_write_byte( 0x2D ,  0x04  |  0x01 );

 if (INT1IE_bit == 1)
 {
 INT1IE_bit = 0;
 }

 if (T1CON.TON == 1)
 {
 T1CON.TON = 0;
 }
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




 if ((banSetReloj == 0) && (buffer == 0xA4))
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
 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 banEsc = 0;
 banSetReloj = 1;
 InterrupcionP1(0XB2);
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
 banSetReloj = 0;
 SPI1BUF = 0xFF;
 }

 if ((banSetReloj == 0) && (buffer == 0xA6))
 {
 banSetReloj = 2;
 }
 if ((banSetReloj == 2) && (buffer != 0xA6) && (buffer != 0xF6))
 {
 referenciaTiempo = buffer;
 }
 if ((banSetReloj == 2) && (buffer == 0xF6))
 {
 banSetReloj = 1;
 if (referenciaTiempo == 1)
 {







 }
 else
 {

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 2;
 InterrupcionP1(0xB2);
 }
 }
#line 490 "C:/Users/milto/Milton/RSA/Git/Registro Continuo/SistemaRegistroContinuo/Firmware/Acelerografo/Acelerografo.c"
}




void int_1() org IVT_ADDR_INT1INTERRUPT
{

 INT1IF_bit = 0;

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
 banCiclo = 1;
 contTimer1 = 0;
 }
}



void urx_1() org IVT_ADDR_U1RXINTERRUPT
{

 U1RXIF_bit = 0;

 byteGPS = U1RXREG;
 OERR_bit = 0;

 if (banTIGPS == 0)
 {

 if (byteGPS == 0x24)
 {
 banTIGPS = 1;
 i_gps = 0;
 }
 else
 {
 i_gps++;
 }

 if (i_gps > 90)
 {

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 0;
 banSetReloj = 1;
 InterrupcionP1(0XB2);
 U1RXIE_bit = 0;
 }
 }

 if (banTIGPS == 1)
 {

 if (byteGPS != 0x2A)
 {
 tramaGPS[i_gps] = byteGPS;
 if ((i_gps == 1) && (tramaGPS[1] != 0x47))
 {
 i_gps = 0;
 banTIGPS = 0;
 banTCGPS = 0;
 }
 i_gps++;
 }
 else
 {
 tramaGPS[i_gps] = byteGPS;
 banTIGPS = 2;
 banTCGPS = 1;
 }
 }

 if (banTCGPS == 1)
 {
 if (tramaGPS[18] == 0x41)
 {
 for (x = 0; x < 6; x++)
 {
 datosGPS[x] = tramaGPS[7 + x];
 }
 for (x = 50; x < 60; x++)
 {
 if (tramaGPS[x] == 0x2C)
 {
 for (y = 0; y < 6; y++)
 {
 datosGPS[6 + y] = tramaGPS[x + y + 1];
 }
 break;
 }
 }
 horaSistema = RecuperarHoraGPS(datosGPS);
 fechaSistema = RecuperarFechaGPS(datosGPS);
 DS3234_setDate(horaSistema, fechaSistema);
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 1;
 }
 else
 {

 horaSistema = RecuperarHoraRTC();
 fechaSistema = RecuperarFechaRTC();
 AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
 fuenteReloj = 0;
 }
 banSetReloj = 1;
 InterrupcionP1(0XB2);
 U1RXIE_bit = 0;
 }
}
