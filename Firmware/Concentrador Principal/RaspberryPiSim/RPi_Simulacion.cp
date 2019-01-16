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

unsigned char tramaSPI[50];
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



void interrupt(){



 if (INTCON3.INT1IF==1){
 INTCON3.INT1IF = 0;



 funcionRpi = 0x01;
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
 tramaSPI[5] = 0x5C;
 tramaSPI[6] = 0x8F;
 tramaSPI[7] = 0x58;
 tramaSPI[8] = 0x83;
 tramaSPI[numDatos+5] = 0xB1;
 break;
 }

 EnviarMensajeSPI(tramaSPI,(numDatos+6));

 }

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
