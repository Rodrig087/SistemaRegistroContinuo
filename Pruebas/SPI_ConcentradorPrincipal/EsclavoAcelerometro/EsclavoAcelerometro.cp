#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/EsclavoAcelerometro/EsclavoAcelerometro.c"
#line 18 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/EsclavoAcelerometro/EsclavoAcelerometro.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;
sbit P1 at RB4_bit;
sbit P1_Direction at TRISB4_bit;
sbit P2 at RB5_bit;
sbit P2_Direction at TRISB5_bit;

const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const unsigned short NUM_MUESTRAS = 199;
const unsigned int T2 = 222;


unsigned char tiempo[5];
unsigned char datos[10];
unsigned char pduSPI[15];

unsigned short i, x;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;

unsigned short banTC, banTI, banTF;

unsigned short banResp, banSPI, banLec, banEsc;









void ConfiguracionPrincipal(){

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 TRISB0_bit = 1;
 TRISB3_bit = 0;
 TRISB4_bit = 0;
 TRISB5_bit = 0;

 RCON.IPEN = 0;
 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
 PIE1.SSP1IE = 1;
 PIR1.SSP1IF = 0;


 INTCON.INT0IE = 1;
 INTCON.INT0IF = 0;


 T2CON = 0x36;

 PR2 = T2;
 PIR1.TMR2IF = 0;
 PIE1.TMR2IE = 1;

 Delay_ms(100);

}



void pulsoAux(){

 AUX = 1;
 Delay_us(1);
 AUX = 0;

}



void interrupt(void){


 if (PIR1.SSP1IF==1){

 PIR1.SSP1IF = 0;
 buffer = SSP1BUF;


 if ((banTI==1)){
 banLec = 1;
 banTI = 0;
 i = 0;
 SSP1BUF = pduSPI[i];
 }
 if ((banLec==1)&&(buffer!=0xB1)){
 SSP1BUF = pduSPI[i];
 i++;
 }
 if ((banLec==1)&&(buffer==0xB1)){
 banLec = 0;
 banTI = 0;
 SSP1BUF = 0xFF;
 }

 }



 if (INTCON.INT0IF==1){
 INTCON.INT0IF = 0;
 contMuestras = 0;
 datos[0] = contCiclos;
 for (x=0;x<10;x++){
 pduSPI[x]=datos[x];
 }
 banTI = 1;
 P1 = 1;
 Delay_us(20);
 P1 = 0;
 T2CON.TMR2ON = 1;
 PR2 = T2;
 contCiclos++;
 }



 if (TMR2IF_bit==1){
 TMR2IF_bit = 0;
 contMuestras++;
 datos[0] = contMuestras;
 for (x=0;x<10;x++){
 pduSPI[x]=datos[x];
 }
 if (contMuestras==NUM_MUESTRAS){
 T2CON.TMR2ON = 0;
 for (x=1;x<10;x++){
 pduSPI[x]=66;
 }
 for (x=10;x<15;x++){
 pduSPI[x]=tiempo[x-10];
 }
 }
 banTI = 1;
 P2 = 1;
 Delay_us(20);
 P2 = 0;
 }

}


void main() {

 ConfiguracionPrincipal();

 tiempo[0] = 19;
 tiempo[1] = 49;
 tiempo[2] = 9;
 tiempo[3] = 30;
 tiempo[4] = 0;

 datos[1] = 11;
 datos[2] = 12;
 datos[3] = 13;
 datos[4] = 21;
 datos[5] = 22;
 datos[6] = 23;
 datos[7] = 31;
 datos[8] = 32;
 datos[9] = 33;

 banTI = 0;
 banLec = 0;
 i = 0;
 x = 0;
 AUX = 0;

 contMuestras = 0;
 contCiclos = 0;
 P1 = 0;
 P2 = 0;

 SSP1BUF = 0xFF;

 while(1){

 Delay_ms(500);

 }


}
