#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/RPi_Acelerometro/RPi_Simulacion.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/RPi_Acelerometro/RPi_Simulacion.c"
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


 SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV4,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);

 Delay_ms(100);

}




void ProbarSPI(){

 CS = 0;
 SSPBUF = 0xB0;
 Delay_us(100);
 for (x=0;x<6;x++){
 SSPBUF = 0xBB;
 Delay_us(100);
 }
 SSPBUF = 0xB1;
 Delay_us(100);
 CS = 1;
}



void main() {

 ConfiguracionPrincipal();
 CS = 1;
 byteTrama = 0;
 banTI = 0;
 banTC = 0;
 banTF = 0;

 while(1){

 ProbarSPI();
 Delay_ms(1000);

 }

}
