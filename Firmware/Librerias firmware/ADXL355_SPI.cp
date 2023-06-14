#line 1 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/ADXL355_SPI.c"
#line 1 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.h"
#line 100 "c:/users/rsa-milton/documents/git/sistemaregistrocontinuo/firmware/librerias firmware/adxl355_spi.h"
sbit CS_ADXL355 at LATA3_bit;


void ADXL355_init(short tMuestreo);
void ADXL355_write_byte(unsigned char address, unsigned char value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_data(unsigned char *vectorMuestra);
unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO);
#line 5 "C:/Users/RSA-Milton/Documents/Git/SistemaRegistroContinuo/Firmware/Librerias firmware/ADXL355_SPI.c"
unsigned short axisAddresses[] = { 0x08 ,  0x09 ,  0x0A ,  0x0B ,  0x0C ,  0x0D ,  0x0E ,  0x0F ,  0x10 };


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
