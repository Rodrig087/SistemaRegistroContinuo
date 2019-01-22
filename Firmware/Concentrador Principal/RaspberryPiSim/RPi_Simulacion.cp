#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Concentrador Principal/RaspberryPiSim/RPi_Simulacion.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Concentrador Principal/RaspberryPiSim/RPi_Simulacion.c"
sbit CS at RC2_bit;
sbit CS_Direction at TRISC2_bit;

unsigned short byteTrama;
unsigned short t1Size;
unsigned char tramaRS485[50];
short i,j,x;

unsigned short banTC, banTI, banTF;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;

unsigned char tramaSPI[15];
unsigned char tramaRespuesta[15];
unsigned short sizeSPI;
unsigned short direccionRpi;
unsigned short funcionRpi;
unsigned short registroRPi;
unsigned short tipoDato;
unsigned short numDatos;









void ConfiguracionPrincipal(){

 ANSELB = 0;
 ANSELC = 0;

 TRISB0_bit = 1;
 TRISB1_bit = 1;
 TRISC2_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);


 SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);


 INTCON.INT0IE = 1;
 INTCON.INT0IF = 0;
 INTCON3.INT1IE = 1;
 INTCON3.INT1IF = 0;



 Delay_ms(100);

}





void EnviarMensajeSPI(unsigned char *trama, unsigned short sizePDU){
 CS = 0;
 for (x=0;x<sizePDU;x++){
 SSPBUF = trama[x];
 Delay_ms(1);
 }
 CS = 1;
}





unsigned short RecuperarRespuestaSPI(){
#line 110 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Concentrador Principal/RaspberryPiSim/RPi_Simulacion.c"
 unsigned short numBytes;
 tramaSPI[0] = 0xC0;
 tramaSPI[1] = 0xCC;
 tramaSPI[2] = 0xC1;
 CS = 0;
 for (x=0;x<3;x++){
 SSPBUF = tramaSPI[x];
 if (x==2){
 while (SSP1STAT.BF!=1);
 numBytes = SSPBUF;
 }
 Delay_ms(1);
 }
 CS = 1;

 Delay_ms(100);

 if ((numbytes!=0xC0)||(numbytes!=0xCC)||(numbytes!=0xC1)||(numbytes!=0x00)){
 CS = 0;
 SSPBUF = 0xD0;
 Delay_ms(1);
 for (x=0;x<(numBytes);x++){
 SSPBUF = 0xDD;
 while (SSP1STAT.BF!=1);
 tramaRespuesta[x] = SSPBUF;
 Delay_ms(1);
 }
 SSPBUF = 0xD1;
 Delay_ms(1);
 CS = 1;
 }

 for (x=0;x<(numBytes);x++){
 UART1_Write(tramaRespuesta[x]);
 }

}



void interrupt(){



 if (INTCON3.INT1IF==1){
 INTCON3.INT1IF = 0;



 funcionRpi = 0x00;
 direccionRpi = 0x09;
 registroRPi = 0x02;

 tramaSPI[0] = 0xB0;
 tramaSPI[1] = direccionRpi;
 tramaSPI[2] = funcionRpi;
 tramaSPI[3] = registroRPi;

 if (funcionRpi==0x00){

 tramaSPI[4] = 0x00;
 tramaSPI[5] = 0xB1;
 EnviarMensajeSPI(tramaSPI,6);

 }else{

 tipoDato = 0x02;
 switch (tipoDato){
 case 0:
 numDatos = 1;
 tramaSPI[4] = numDatos;
 tramaSPI[5] = 0x5C;
 tramaSPI[numDatos+5] = 0xB1;
 break;
 case 1:
 numDatos = 2;
 tramaSPI[4] = numDatos;
 tramaSPI[5] = 0x5C;
 tramaSPI[6] = 0x8F;
 tramaSPI[numDatos+5] = 0xB1;
 break;
 case 2:
 numDatos = 4;
 tramaSPI[4] = numDatos;
 tramaSPI[5] = 0xE1;
 tramaSPI[6] = 0xE2;
 tramaSPI[7] = 0xE3;
 tramaSPI[8] = 0xE4;
 tramaSPI[numDatos+5] = 0xB1;
 break;
 }

 EnviarMensajeSPI(tramaSPI,(numDatos+6));

 }

 }




 if (INTCON.INT0IF==1){
 INTCON.INT0IF = 0;
 RecuperarRespuestaSPI();
 }

 }


void main() {

 ConfiguracionPrincipal();
 CS = 1;
 byteTrama = 0;
 banTI = 0;
 banTC = 0;
 banTF = 0;

}
