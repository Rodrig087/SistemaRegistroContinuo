#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/ADXL355_SPI.c"
#line 102 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Registro Continuo/Firmware/Acelerografo/ADXL355_SPI.c"
sbit CS_ADXL355 at LATA0_bit;

void ADXL355_init();
void ADXL355_write_byte(unsigned char address, unsigned char value);
void ADXL355_write_word(unsigned char address, unsigned int value);
unsigned char ADXL355_read_byte(unsigned char address);
unsigned int ADXL355_read_word(unsigned char address);
void get_values(signed int *x_val, signed int *y_val, signed int *z_val);
void get_offsets(signed int *x_val, signed int *y_val, signed int *z_val);
void set_offsets(signed int *x_val, signed int *y_val, signed int *z_val);
unsigned int ADXL355_muestra(void);

void ADXL355_init()
{
 SPI2_Init();
 delay_ms(100);
 ADXL355_write_byte( 0x2D ,  0x04 | 0x02 | 0x00 );
 ADXL355_write_byte( 0x2C ,  0x80 | 0x01 );
 ADXL355_write_byte( 0x2C ,  0x00 | 0x05 );

}


void ADXL355_write_byte(unsigned char address, unsigned char value)
{

 address = (address<<1)&0xFE;
 CS_ADXL355=0;
 SPI2_Write(address);
 SPI2_Write(value);
 CS_ADXL355=1;
}


void ADXL355_write_word(unsigned char address, unsigned int value)
{
 unsigned int temp = 0x0000;

 temp = value & 0xFF00;
 temp >>= 8;

 address=(address<<1)&0xFE;
 CS_ADXL355=0;
 SPI2_Write(address);
 SPI2_Write(value);
 SPI2_Write(temp);
 CS_ADXL355=1;

}


unsigned char ADXL355_read_byte(unsigned char address)
{
 unsigned char value = 0x00;
 address=(address<<1)|0x01;
 CS_ADXL355=0;
 SPI2_Write(address);
 value=SPI2_Read(0);
 CS_ADXL355=1;

 return value;
}


unsigned int ADXL355_read_word(unsigned char address)
{
 unsigned char hb = 0x00;
 unsigned char lb = 0x00;
 unsigned int temp = 0x0000;
 address=(address<<1)|0x01;
 CS_ADXL355=0;
 SPI2_Write(address);
 hb = SPI_Read(1);
 lb = SPI_Read(0);
 CS_ADXL355=1;
 temp = hb;
 temp <<= 0x08;
 temp |= lb;
 return temp;
}

unsigned int ADXL355_read_data(unsigned char address)
{
 long *dato,auxiliar;
 unsigned char *puntero_8,bandera;
 puntero_8=&dato;
 address=(address<<1)|0x01;
 CS_ADXL355=0;
 SPI2_Write(address);
 *(puntero_8+0) = SPI_Read(2);
 *(puntero_8+1) = SPI_Read(1);
 *(puntero_8+2) = SPI_Read(0);
 CS_ADXL355=1;

 bandera=*(puntero_8+0)&0x80;
 auxiliar=*dato;
 auxiliar=auxiliar>>12;
 if(bandera!=0){
 auxiliar=auxiliar|0xFFF00000;
 }
 return auxiliar;
}


void get_values(signed int *x_val, signed int *y_val, signed int *z_val)
{

 *x_val = ADXL355_read_data( 0x08 );
 *y_val = ADXL355_read_data( 0x0B );
 *z_val = ADXL355_read_data( 0x0E );
}


unsigned int ADXL355_muestra( unsigned char *puntero_8)
{

 CS_ADXL355=0;
 SPI2_Write(0x11);

 *(puntero_8+0) = SPI_Read(8);
 *(puntero_8+1) = SPI_Read(7);
 *(puntero_8+2) = SPI_Read(6);
 *(puntero_8+3) = SPI_Read(5);
 *(puntero_8+4) = SPI_Read(4);
 *(puntero_8+5) = SPI_Read(3);
 *(puntero_8+6) = SPI_Read(2);
 *(puntero_8+7) = SPI_Read(1);
 *(puntero_8+8) = SPI_Read(0);
 CS_ADXL355=1;
 return;
}
