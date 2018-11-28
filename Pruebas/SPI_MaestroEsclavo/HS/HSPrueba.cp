#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/Pruebas/SPI_MaestroEsclavo/V2/HS/HSPrueba.c"
#line 19 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/Pruebas/SPI_MaestroEsclavo/V2/HS/HSPrueba.c"
sbit TOUT at RC3_bit;
sbit TOUT_Direction at TRISC3_bit;
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;

const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const unsigned int POLMODBUS = 0xA001;

unsigned short byteTrama;
unsigned short t1Size;
unsigned char trama[30];
short i1;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;

unsigned char PDU[15];
unsigned short sizePDU;
unsigned short direccionRpi;
unsigned short funcionRpi;

unsigned short contadorTOD;
unsigned short contadorNACK;







void ConfiguracionPrincipal(){

 TRISB3_bit = 0;
 TRISC3_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);


 INTCON.INTE = 1;
 INTCON.INTF = 0;
 OPTION_REG.INTEDG = 0;

 Delay_ms(100);

}





unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
 unsigned char ucCounter;
 unsigned int CRC16;
 for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
 CRC16 ^=*trama ++;
 for(ucCounter =0; ucCounter <8; ucCounter ++){
 if(CRC16 & 0x0001)
 CRC16 = (CRC16 >>1)^POLMODBUS;
 else
 CRC16>>=1;
 }
 }
 return CRC16;
}





void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
 unsigned char i;
 unsigned int CRCPDU;
 unsigned short *ptrCRCPDU;
 CRCPDU = CalcularCRC(tramaPDU, sizePDU);
 ptrCRCPDU = &CRCPDU;
 trama[0]=HDR;
 trama[sizePDU+2]=*ptrCrcPdu;
 trama[sizePDU+1]=*(ptrCrcPdu+1);
 trama[sizePDU+3]=END1;
 trama[sizePDU+4]=END2;
 for (i=0;i<(sizePDU+5);i++){
 if ((i>=1)&&(i<=sizePDU)){
 UART1_Write(tramaPDU[i-1]);
 } else {
 UART1_Write(trama[i]);
 }
 }
 while(UART1_Tx_Idle()==0);
 TOUT = 1;
 Delay_ms(200);
 TOUT = 0;
}




void interrupt(){



 if (INTCON.INTF==1){
 AUX = 1;
 INTCON.INTF=0;
 PDU[0]=0x03;
 PDU[1]=0x05;
 PDU[2]=0x05;
 PDU[3]=0x06;
 PDU[4]=0x07;
 sizePDU = PDU[1];
 EnviarMensajeRS485(PDU, sizePDU);
 AUX = 0;
 }
}


void main() {

 AUX = 0;
 ConfiguracionPrincipal();
 TOUT = 1;
 Delay_ms(200);
 TOUT = 0;

}
