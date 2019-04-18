#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
#line 1 "c:/users/ivan/desktop/milton muñoz/proyectos/git/instrumentacion presa/instrumentacionpch/registro continuo/firmware/acelerografo/adxl355_spi.c"
#line 94 "c:/users/ivan/desktop/milton muñoz/proyectos/git/instrumentacion presa/instrumentacionpch/registro continuo/firmware/acelerografo/adxl355_spi.c"
sbit CS_ADXL355 at LATA3_bit;
unsigned short axisAddresses[] = { 0x08 ,  0x09 ,  0x0A ,  0x0B ,  0x0C ,  0x0D ,  0x0E ,  0x0F ,  0x10 };

void ADXL355_init();
void ADXL355_write_byte(unsigned char address, unsigned char value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_data(unsigned char *vectorMuestra);
unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO, unsigned short numFIFO);


void ADXL355_init(){
 ADXL355_write_byte( 0x2F , 0x52);
 ADXL355_write_byte(0x2D, 0x01);
 ADXL355_write_byte( 0x04 , 0xFF);

 ADXL355_write_byte( 0x2D ,  0x04 | 0x02 | 0x00 );
 ADXL355_write_byte( 0x2C ,  0x00  | 0x01 );
 ADXL355_write_byte( 0x28 ,  0x00 | 0x04 );

 ADXL355_write_byte( 0x29 , 0x02);
}


void ADXL355_write_byte(unsigned char address, unsigned char value){
 address = (address<<1)&0xFE;
 CS_ADXL355 = 0;
 SPI2_Write(address);
 SPI2_Write(value);
 CS_ADXL355=1;
}


unsigned char ADXL355_read_byte(unsigned char address){
 unsigned char value = 0x00;
 address=(address<<1)|0x01;
 CS_ADXL355 = 0;
 SPI2_Write(address);
 value=SPI2_Read(0);
 CS_ADXL355 = 1;
 return value;
}


unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
 unsigned short j;
 unsigned short muestra;
 if((ADXL355_read_byte( 0x04 )&0x01)==1){
 CS_ADXL355=0;
 for (j=0;j<9;j++){
 muestra = ADXL355_read_byte(axisAddresses[j]);
 if (j==2||j==5||j==8){
 vectorMuestra[j] = (muestra>>4)&0x0F;
 } else {
 vectorMuestra[j] = muestra;
 }
 }
 CS_ADXL355=1;
 } else {
 for (j=0;j<8;j++){
 vectorMuestra[j] = 0;
 }
 vectorMuestra[8] = (ADXL355_read_byte( 0x04 )&0x7F);
 }
 return;
}


unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO, unsigned short numFIFO){
 unsigned char add;
 unsigned short j;
 unsigned short muestra;
 add = ( 0x11 <<1)|0x01;
 CS_ADXL355 = 0;
 SPI2_Write(add);
 for (j=0; j<numFIFO; j++){
 vectorFIFO[0+(j*9)] = SPI_Read(8);
 vectorFIFO[1+(j*9)] = SPI_Read(7);

 vectorFIFO[2+(j*9)] = SPI_Read(6)&0x0F;
 vectorFIFO[3+(j*9)] = SPI_Read(5);
 vectorFIFO[4+(j*9)] = SPI_Read(4);
 vectorFIFO[5+(j*9)] = SPI_Read(3);
 vectorFIFO[6+(j*9)] = SPI_Read(2);
 vectorFIFO[7+(j*9)] = SPI_Read(1);
 vectorFIFO[8+(j*9)] = SPI_Read(0);
 }
 CS_ADXL355 = 1;
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
const unsigned short NUM_MUESTRAS = 249;


unsigned char tiempo[5];
unsigned char pduSPI[15];
unsigned char datosLeidos[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};

unsigned char lecturaRegistro;

unsigned short i, x;
unsigned short buffer;
unsigned short contMuestras;
unsigned short contCiclos;

unsigned short banTC, banTI, banTF;
unsigned short banResp, banSPI, banLec, banEsc;


long datox, datoy, datoz, auxiliar;
unsigned char *puntero_8, direccion;








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
 TRISB10_bit = 0;
 TRISB11_bit = 1;
 TRISB12_bit = 1;
 TRISB13_bit = 1;

 INTCON2.GIE = 1;






 SPI1STAT.SPIEN = 1;
 SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);
 SPI1IE_bit = 1;
 SPI1IF_bit = 0;
 IPC2bits.SPI1IP = 0x04;


 RPINR22bits.SDI2R = 0x21;
 RPOR2bits.RP38R = 0x08;
 RPOR1bits.RP37R = 0x09;
 SPI2STAT.SPIEN = 1;
 SPI2_Init();


 RPINR0 = 0x2E00;
 INT1IE_bit = 1;
 INT1IF_bit = 0;
 IPC5bits.INT1IP = 0x01;
#line 105 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
 T1CON = 0x0010;
 T1CON.TON = 0;
 T1IE_bit = 1;
 T1IF_bit = 0;

 PR1 = 20000;
 IPC0bits.T1IP = 0x02;

 ADXL355_init();

 Delay_ms(100);

}







void int_1() org IVT_ADDR_INT1INTERRUPT {
 INT1IF_bit = 0;
 contMuestras = 0;

 pduSPI[0] = contCiclos;

 ADXL355_read_FIFO(datosLeidos, 1);
 for (x=1;x<10;x++){
 pduSPI[x]=datosLeidos[x-1];
 }

 banTI = 1;
 RP1 = 1;
 Delay_us(20);
 RP1 = 0;
 T1CON.TON = 1;
 contCiclos++;
}


void Timer1Int() org IVT_ADDR_T1INTERRUPT{
 T1IF_bit = 0;
 contMuestras++;

 pduSPI[0] = contMuestras;

 ADXL355_read_FIFO(datosLeidos, 1);
 for (x=1;x<10;x++){
 pduSPI[x]=datosLeidos[x-1];
 }
 if (contMuestras==NUM_MUESTRAS){
 T1CON.TON = 0;
 for (x=10;x<15;x++){
 pduSPI[x]=tiempo[x-10];
 }
 }

 banTI = 1;

 RP2 = 1;
 Delay_us(20);
 RP2 = 0;
}


void spi_1() org IVT_ADDR_SPI1INTERRUPT {
 SPI1IF_bit = 0;
 buffer = SPI1BUF;

 if ((banTI==1)){
 banLec = 1;
 banTI = 0;
 i = 0;
 SPI1BUF = pduSPI[i];
 }
 if ((banLec==1)&&(buffer!=0xB1)){
 SPI1BUF = pduSPI[i];
 i++;
 }
 if ((banLec==1)&&(buffer==0xB1)){
 banLec = 0;
 banTI = 0;
 SPI1BUF = 0xFF;
 }
}
#line 202 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/Acelerografo.c"
void main() {

 ConfiguracionPrincipal();

 tiempo[0] = 19;
 tiempo[1] = 49;
 tiempo[2] = 9;
 tiempo[3] = 30;
 tiempo[4] = 0;





 datosLeidos[0] = 0x01;
 datosLeidos[1] = 0x02;
 datosLeidos[2] = 0x03;
 datosLeidos[3] = 0x01;
 datosLeidos[4] = 0x02;
 datosLeidos[5] = 0x03;
 datosLeidos[6] = 0x01;
 datosLeidos[7] = 0x02;
 datosLeidos[8] = 0x03;

 banTI = 0;
 banLec = 0;
 i = 0;
 x = 0;

 contMuestras = 0;
 contCiclos = 0;
 RP1 = 0;
 RP2 = 0;

 puntero_8 = &auxiliar;

 SPI1BUF = 0x00;

 while(1){

 Delay_ms(500);

 }

}
