#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
#line 1 "c:/users/ivan/desktop/milton muñoz/proyectos/git/instrumentacion presa/instrumentacionpch/registro continuo/firmware/acelerografo/adxl355_spi.c"
#line 94 "c:/users/ivan/desktop/milton muñoz/proyectos/git/instrumentacion presa/instrumentacionpch/registro continuo/firmware/acelerografo/adxl355_spi.c"
sbit CS_ADXL355 at LATA3_bit;
unsigned short axisAddresses[] = { 0x08 ,  0x09 ,  0x0A ,  0x0B ,  0x0C ,  0x0D ,  0x0E ,  0x0F ,  0x10 };

void ADXL355_init();
void ADXL355_write_byte(unsigned char address, unsigned char value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_data(unsigned char *vectorMuestra);
unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO);


void ADXL355_init(){
 ADXL355_write_byte( 0x2F ,0x52);
 Delay_ms(10);
 ADXL355_write_byte( 0x2D ,  0x04 | 0x01 );
 ADXL355_write_byte( 0x28 ,  0x00 | 0x04 );
 ADXL355_write_byte( 0x2C ,  0x01 );
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
#line 17 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
sbit RP1 at LATA4_bit;
sbit RP1_Direction at TRISA4_bit;
sbit RP2 at LATB4_bit;
sbit RP2_Direction at TRISB4_bit;

const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const unsigned short NUM_MUESTRAS = 199;


unsigned char tramaGPS[70];
unsigned char datosGPS[13];
unsigned char tiempo[6];
unsigned char pduSPI[15];
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
unsigned char datosFIFO[243];
unsigned char tramaCompleta[2506];
unsigned short numFIFO, numSetsFIFO;
unsigned short contTimer1;

unsigned int i, x, y, i_gps;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;
unsigned int contFIFO;

unsigned short banTC, banTI, banTF;
unsigned short banResp, banSPI, banLec, banEsc, banCiclo, banInicio, banSetReloj, banSetGPS;
unsigned short banMuestrear, banLeer, banConf;

long datox, datoy, datoz, auxiliar;
unsigned char *puntero_8, direccion;

unsigned char byteGPS, banTIGPS, banTFGPS, banTCGPS;
unsigned short tiempoDeAjuste[2] = {10, 0};
unsigned long tiempoSistema, fechaSistema, segundoDeAjuste;






void ConfiguracionPrincipal();
void Muestrear();
void ConfigurarGPS();
unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS);
unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS);
void AjustarTiempoSistema(unsigned long hGPS, unsigned long fGPS, unsigned char *tramaTiempoSistema);





void main() {

 ConfiguracionPrincipal();
 ConfigurarGPS();

 tiempo[0] = 12;
 tiempo[1] = 12;
 tiempo[2] = 12;
 tiempo[3] = 12;
 tiempo[4] = 12;
 tiempo[5] = 19;

 banTI = 0;
 banLec = 0;
 banCiclo = 0;
 banSetReloj = 0;
 banSetGPS = 0;
 banTIGPS = 0;
 banTFGPS = 0;
 banTCGPS = 0;

 banMuestrear = 0;
 banLeer = 0;
 banConf = 0;

 i = 0;
 x = 0;
 y = 0;
 i_gps = 0;
 tiempoSistema = 0;
 fechaSistema = 190101;
 segundoDeAjuste = (3600*tiempoDeAjuste[0]) + (60*tiempoDeAjuste[1]);

 contMuestras = 0;
 contCiclos = 0;
 contFIFO = 0;
 numFIFO = 0;
 numSetsFIFO = 0;
 contTimer1 = 0;

 byteGPS = 0;

 RP1 = 0;
 RP2 = 0;

 puntero_8 = &auxiliar;

 SPI1BUF = 0x00;

 banInicio = 0;
 U1RXIE_bit = 1;
 INT1IE_bit = 1;

 while(1){

 Delay_ms(500);

 }

}








void ConfiguracionPrincipal(){


 CLKDIVbits.FRCDIV = 0;
 CLKDIVbits.PLLPOST = 0;
 CLKDIVbits.PLLPRE = 5;
 PLLFBDbits.PLLDIV = 150;


 ANSELA = 0;
 ANSELB = 0;
 TRISA3_bit = 0;
 TRISA4_bit = 0;
 TRISB4_bit = 0;
 TRISB10_bit = 1;
 TRISB11_bit = 1;
 TRISB12_bit = 1;
 TRISB13_bit = 1;

 INTCON2.GIE = 1;


 RPINR18bits.U1RXR = 0x22;
 RPOR0bits.RP35R = 0x01;
 UART1_Init(9600);
 U1RXIE_bit = 1;
 U1RXIF_bit = 0;
 IPC2bits.U1RXIP = 0x04;


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


 RPINR0 = 0x2E00;
 INT1IE_bit = 0;
 INT1IF_bit = 0;
 IPC5bits.INT1IP = 0x01;


 T1CON = 0x0020;
 T1CON.TON = 0;
 T1IE_bit = 1;
 T1IF_bit = 0;
 PR1 = 62500;
 IPC0bits.T1IP = 0x02;


 T2CON = 0x0020;
 T2CON.TON = 0;
 T2IE_bit = 1;
 T2IF_bit = 0;
 PR2 = 46875;
 IPC1bits.T2IP = 0x05;

 ADXL355_init();

 Delay_ms(200);

}




void Muestrear(){

 if (banCiclo==0){

 ADXL355_write_byte( 0x2D ,  0x04 | 0x01 );

 } else {

 banCiclo = 0;

 tramaCompleta[0] = contCiclos;
 numFIFO = ADXL355_read_byte( 0x05 );
 numSetsFIFO = (numFIFO)/3;


 for (x=0;x<numSetsFIFO;x++){
 ADXL355_read_FIFO(datosLeidos);
 for (y=0;y<9;y++){
 datosFIFO[y+(x*9)] = datosLeidos[y];
 }
 }


 for (x=0;x<(numSetsFIFO*9);x++){
 if ((x==0)||(x%9==0)){
 tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
 tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
 contMuestras++;
 } else {
 tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
 }
 }


 AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
 for (x=0;x<6;x++){
 tramaCompleta[2500+x] = tiempo[x];
 }

 banTI = 1;
 RP1 = 1;
 Delay_us(20);
 RP1 = 0;

 }

 contCiclos++;
 contMuestras = 0;
 contFIFO = 0;

 if (ADXL355_read_byte( 0x2D )&0x01==1){
 ADXL355_write_byte( 0x2D ,  0x04 | 0x00 );
 }

 T1CON.TON = 1;

}





void ConfigurarGPS(){
 UART1_Write_Text("$PMTK605*31\r\n");
 UART1_Write_Text("$PMTK220,1000*1F\r\n");
 UART1_Write_Text("$PMTK251,115200*1F\r\n");
 Delay_ms(1000);
 UART1_Init(115200);
 UART1_Write_Text("$PMTK313,1*2E\r\n");
 UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
 UART1_Write_Text("$PMTK319,1*24\r\n");
 UART1_Write_Text("$PMTK413*34\r\n");
 UART1_Write_Text("$PMTK513,1*28\r\n");
 Delay_ms(1000);
}




unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS){

 unsigned int tramaFecha[4];
 unsigned long fechaGPS;
 char datoStringF[3];
 char *ptrDatoStringF = &datoStringF;
 datoStringF[2] = '\0';
 tramaFecha[3] = '\0';
#line 304 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 datoStringF[0] = '1';
 datoStringF[1] = '7';

 tramaFecha[0] = 17;
#line 312 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 datoStringF[0] = '0';
 datoStringF[1] = '6';

 tramaFecha[1] = 6;
#line 320 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 datoStringF[0] = '1';
 datoStringF[1] = '9';

 tramaFecha[2] = 0;


 fechaGPS = (tramaFecha[0]*3600)+(tramaFecha[1]*60)+(tramaFecha[2]);

 return fechaGPS;

}
#line 376 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema){

 unsigned char hora;
 unsigned char minuto;
 unsigned char segundo;
 unsigned char dia;
 unsigned char mes;
 unsigned char anio;

 hora = longHora / 3600;
 minuto = (longHora%3600) / 60;
 segundo = (longHora%3600) % 60;

 dia = longFecha / 10000;
 mes = (longFecha%10000) / 100;
 anio = (longFecha%10000) % 100;

 tramaTiempoSistema[0] = hora;
 tramaTiempoSistema[1] = minuto;
 tramaTiempoSistema[2] = segundo;
 tramaTiempoSistema[3] = dia;
 tramaTiempoSistema[4] = mes;
 tramaTiempoSistema[5] = anio;

 banSetReloj = 1;

}








void spi_1() org IVT_ADDR_SPI1INTERRUPT {

 SPI1IF_bit = 0;
 buffer = SPI1BUF;


 if ((buffer==0xA0)&&(banMuestrear==0)){
 banInicio = 2;

 }


 if ((buffer==0xB0)&&(banLeer==0)){
 banLeer = 1;
 i = 0;
 }
 if ((banLeer==1)&&(buffer!=0xB0)&&(buffer!=0xBF)){
 SPI1BUF = tiempo[i];
 i++;
 }
 if ((banLeer==1)&&(buffer==0xBF)){
 banLeer = 0;
 }


 if ((buffer==0xC0)&&(banConf==0)){

 }
#line 456 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
}




void int_1() org IVT_ADDR_INT1INTERRUPT {

 INT1IF_bit = 0;

 AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
 RP1 = 1;
 Delay_us(20);
 RP1 = 0;

 if (tiempoSistema==segundoDeAjuste){
 U1RXIE_bit = 1;
 } else {
 tiempoSistema++;
 }



 if (banInicio==1){

 void Muestrear();

 }

}



void Timer1Int() org IVT_ADDR_T1INTERRUPT{

 T1IF_bit = 0;

 numFIFO = ADXL355_read_byte( 0x05 );

 numSetsFIFO = (numFIFO)/3;



 for (x=0;x<numSetsFIFO;x++){
 ADXL355_read_FIFO(datosLeidos);
 for (y=0;y<9;y++){
 datosFIFO[y+(x*9)] = datosLeidos[y];
 }
 }


 for (x=0;x<(numSetsFIFO*9);x++){
 if ((x==0)||(x%9==0)){
 tramaCompleta[contFIFO+contMuestras+x] = contMuestras;

 tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
 contMuestras++;
 } else {
 tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
 }
 }

 contFIFO = (contMuestras*9);

 contTimer1++;

 if (contTimer1==9){
 T1CON.TON = 0;
 banCiclo = 1;
 contTimer1 = 0;
 }



}



void Timer2Int() org IVT_ADDR_T2INTERRUPT{

 T2IF_bit = 0;

}




void urx_1() org IVT_ADDR_U1RXINTERRUPT {

 U1RXIF_bit = 0;
 byteGPS = UART1_Read();

 if (banTIGPS==0){
 if ((byteGPS==0x24)&&(i_gps==0)){
 banTIGPS = 1;
 i_gps = 0;
 }
 }

 if (banTIGPS==1){
 if (byteGPS!=0x2A){
 tramaGPS[i_gps] = byteGPS;
 banTFGPS = 0;
 if (i_gps<70){
 i_gps++;
 }
 if ((i_gps>1)&&(tramaGPS[1]!=0x47)){
 i_gps = 0;
 banTIGPS = 0;
 banTCGPS = 0;
 }
 } else {
 tramaGPS[i_gps] = byteGPS;
 banTFGPS = 1;
 }
 if (banTFGPS==1){
 banTIGPS = 0;
 banTCGPS = 1;
 }
 }

 if (banTCGPS==1){
 if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){
 for (x=0;x<6;x++){
 datosGPS[x] = tramaGPS[7+x];
 }
 for (x=50;x<60;x++){
 if (tramaGPS[x]==0x2C){
 for (y=0;y<6;y++){
 datosGPS[6+y] = tramaGPS[x+y+1];
 }
 }
 }
 banSetGPS = 1;

 datosGPS[0] = '1';
 datosGPS[1] = '7';
 datosGPS[2] = '2';
 datosGPS[3] = '4';
 datosGPS[4] = '0';
 datosGPS[5] = '0';

 datosGPS[6] = '2';
 datosGPS[7] = '6';
 datosGPS[8] = '0';
 datosGPS[9] = '6';
 datosGPS[10] = '1';
 datosGPS[11] = '9';
 datosGPS[12] = '\0';

 tiempoSistema = RecuperarFechaGPS(datosGPS);
 fechaSistema = RecuperarFechaGPS(datosGPS);
#line 611 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 U1RXIE_bit = 0;
#line 615 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 }
 i_gps = 0;
 banTIGPS = 0;
 banTCGPS = 0;
 }

}
