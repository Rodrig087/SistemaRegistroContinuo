#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoSensorSPI/EsclavoSensor.c"
#line 28 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoSensorSPI/EsclavoSensor.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;
sbit ECINT at RC2_bit;
sbit ECINT_Direction at TRISC2_bit;

const short idEsclavo = 0x09;
const short funcEsclavo = 0x01;
const short regLectura = 0x03;
const short regEscritura = 0x03;

unsigned char datosEscritura[10];
unsigned char resSPI[15];
unsigned short regEsc;
unsigned short numDatosEsc;
unsigned short
unsigned short i, x, j;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banLec, banId, banEsc;










void ConfiguracionPrincipal(){

 TRISC2_bit = 0;
 TRISB3_bit = 0;
 TRISA5_bit = 1;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
 PIE1.SSPIE = 1;

 UART1_Init(19200);

 Delay_ms(100);

}








void interrupt(){


 if (PIR1.SSPIF){

 PIR1.SSPIF = 0;
 AUX = 1;
 AUX = 0;

 buffer = SSPBUF;


 if ((buffer==0xA0)&&(banEsc==0)){
 banId = 1;
 SSPBUF = 0xA0;
 Delay_us(50);
 }
 if ((banId==1)&&(buffer!=0xA5)){
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
 if ((banId==1)&&(buffer==0xA5)){
 banId = 0;
 SSPBUF = 0xB0;
 }


 if ((buffer==0xB0)&&(banEsc==0)){
 banLec = 1;
 SSPBUF = 0xB0;
 Delay_us(50);
 }
 if ((banLec==1)&&(buffer!=0xB0)){
 registro = buffer;




 switch (registro){
 case 0:
 numBytesSPI = 0x02;
 SSPBUF = numBytesSPI;
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
 SSPBUF = 0x01;
 }
 }
 if ((banLec==1)&&(buffer==0xB1)){
 banPet = 1;
 banLec = 0;
 banResp = 0;
 SSPBUF = 0xC0;
 }


 if (banResp==1){
 if (i<numBytesSPI){
 SSPBUF = resSPI[i];
 i++;
 }
 }


 if ((buffer==0xD0)&&(banEsc==0)){
 banEsc = 1;
 j=0;
 }
 if ((banEsc==1)&&(buffer!=0xD0)){
 datosEscritura[j] = buffer;
 if (j>1){
 regEsc = datosEscritura[1];
 numDatosEsc = datosEscritura[1];
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
 ECINT = 1;
 AUX = 0;
 i = 0;
 x = 0;
 banPet = 0;
 banResp = 0;
 banSPI = 0;
 banLec = 0;
 banId = 0;
 banEsc = 0;


 SSPBUF = 0xA0;
 numDatosEsc = 0;
 regEsc = 0;

 while(1){

 if (banPet==1){

 Delay_ms(1000);
 resSPI[0] = 0x83;
 resSPI[1] = 0x58;
 resSPI[2] = 0x8F;
 resSPI[3] = 0x5C;
 i=0;

 ECINT = 0;
 Delay_ms(1);
 ECINT = 1;
 banPet = 0;
 banResp = 1;

 }

 }

}
