#line 1 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/TIEMPO_RTC.c"
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
#line 38 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/TIEMPO_RTC.c"
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

 unsigned char valueSet;
 unsigned char hora;
 unsigned char minuto;
 unsigned char segundo;
 unsigned char dia;
 unsigned char mes;
 unsigned char anio;

 SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);

 hora = (char)(longHora / 3600);
 minuto = (char)((longHora%3600) / 60);
 segundo = (char)((longHora%3600) % 60);

 anio = (char)(longFecha / 10000);
 mes = (char)((longFecha%10000) / 100);
 dia = (char)((longFecha%10000) % 100);

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

 unsigned char valueRead;
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

 unsigned char valueRead;
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


void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema){

 unsigned char hora;
 unsigned char minuto;
 unsigned char segundo;
 unsigned char dia;
 unsigned char mes;
 unsigned char anio;

 hora = (char)(longHora / 3600);
 minuto = (char)((longHora%3600) / 60);
 segundo = (char)((longHora%3600) % 60);

 anio = (char)(longFecha / 10000);
 mes = (char)((longFecha%10000) / 100);
 dia = (char)((longFecha%10000) % 100);

 tramaTiempoSistema[0] = anio;
 tramaTiempoSistema[1] = mes;
 tramaTiempoSistema[2] = dia;
 tramaTiempoSistema[3] = hora;
 tramaTiempoSistema[4] = minuto;
 tramaTiempoSistema[5] = segundo;

}
