#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_MaestroEsclavo/EsclavoComunicacionPrueba/EComunicacionPrueba.c"
#line 23 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_MaestroEsclavo/EsclavoComunicacionPrueba/EComunicacionPrueba.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;
sbit CS at RC2_bit;
sbit CS_Direction at TRISC2_bit;

const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const short ACK = 0xAA;
const short NACK = 0xAF;
const unsigned int POLMODBUS = 0xA001;

unsigned short byteTrama;
unsigned short t1Size;
unsigned char tramaUART[30];
short i1;

unsigned short banTC, banTI, banTF, banPet;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;

unsigned char petSPI[15];
unsigned char resSPI[15];
unsigned short sizeSPI;
unsigned short direccionRpi;
unsigned short funcionRpi;

unsigned short contadorTOD;
unsigned short contadorNACK;

unsigned short x, buffer, numBytesSPI;
unsigned short respSPI;









void ConfiguracionPrincipal(){

 TRISB0_bit = 1;
 TRISB3_bit = 0;
 TRISC2_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);
 PIE1.RCIE = 1;


 SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);


 INTCON.INTE = 1;
 INTCON.INTF = 0;
 OPTION_REG.INTEDG = 1;

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





void EnviarMensajeUART(unsigned char idEsclavo, unsigned char *tramaPDU, unsigned char sizePDU){
 unsigned char i;
 unsigned int CRCPDU;
 unsigned short *ptrCRCPDU;
 CRCPDU = CalcularCRC(tramaPDU, sizePDU);
 ptrCRCPDU = &CRCPDU;

 tramaUART[0] = HDR;
 tramaUART[sizePDU+2] = *ptrCrcPdu;
 tramaUART[sizePDU+1] = *(ptrCrcPdu+1);
 tramaUART[sizePDU+3] = END1;
 tramaUART[sizePDU+4] = END2;
 for (i=0;i<(sizePDU+5);i++){
 if ((i>=1)&&(i<=sizePDU)){
 UART1_Write(tramaPDU[i-1]);
 } else {
 UART1_Write(tramaUART[i]);
 }
 }
 while(UART1_Tx_Idle()==0);
}






unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
 unsigned char pdu[15];
 unsigned short j;
 unsigned int crcCalculado, crcTrama;
 unsigned short *ptrCRCTrama;

 unsigned short *crcPrint;

 crcCalculado = 0;
 crcTrama = 1;

 for (j=0;j<tramaPDUSize;j++){
 pdu[j] = trama[j+1];
 }

 crcCalculado = CalcularCRC(pdu, tramaPDUSize);

 ptrCRCTrama = &CRCTrama;
 *ptrCRCTrama = trama[tramaPDUSize+2];
 *(ptrCRCTrama+1) = trama[tramaPDUSize+1];

 if (crcCalculado==CRCTrama) {
 return 1;
 } else {
 return 0;
 }
}





void EnviarACK(){
 UART1_Write(ACK);
 while(UART1_Tx_Idle()==0);
}





void EnviarNACK(){
 UART1_Write(NACK);
 while(UART1_Tx_Idle()==0);
}










void interrupt(){



 if (INTCON.INTF==1){
 INTCON.INTF = 0;
 Delay_ms(10);
 CS = 0;
 for (x=0;x<=numBytesSPI;x++){
 SSPBUF = 0xBB;
 if ((x>0)){
 while (SSPSTAT.BF!=1);
 UART1_Write(SSPBUF);
 }
 Delay_us(200);
 }
 CS = 1;
 }


 if (PIR1.RCIF==1){

 byteTrama = UART1_Read();

 if ((byteTrama==HDR)&&(banTI==0)){
 banTI = 1;
 i1 = 0;
 tramaOk = 9;
 }

 if (banTI==1){
 if (byteTrama!=END2){
 tramaUART[i1] = byteTrama;
 i1++;
 banTF = 0;
 } else {
 tramaUART[i1] = byteTrama;
 banTF = 1;
 }
 if (BanTF==1){
 banTI = 0;
 banTC = 1;
 t1Size = tramaUART[2];
 }
 }

 if (banTC==1){
 tramaOk = VerificarCRC(tramaUART,t1Size);
 if (tramaOk==1){
 EnviarACK();

 petSPI[0] = 0xA0;
 petSPI[1] = 0x02;
 petSPI[2] = 0xA1;

 CS = 0;
 for (x=0;x<3;x++){
 SSPBUF = petSPI[x];
 if (x==2){
 while (SSPSTAT.BF!=1);
 numBytesSPI = SSPBUF;
 }
 Delay_ms(1);
 }
 CS = 1;

 } else if (tramaOk==0) {
 EnviarNACK();
 }
 banTC = 0;
 i1 = 0;
 banTI = 0;
 }

 PIR1.RCIF = 0;

 }

}




void main() {

 ConfiguracionPrincipal();
 AUX = 0;
 i1=0;
 contadorTOD = 0;
 contadorNACK = 0;
 banTI=0;
 banTC=0;
 banTF=0;
 banPet=0;

}
