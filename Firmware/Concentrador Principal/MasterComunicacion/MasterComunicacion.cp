#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Concentrador Principal/MasterComunicacion/MasterComunicacion.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Concentrador Principal/MasterComunicacion/MasterComunicacion.c"
sbit RE_DE at RB1_bit;
sbit RE_DE_Direction at TRISB1_bit;

sbit IU1 at RC4_bit;
sbit IU1_Direction at TRISC4_bit;

const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const short ACK = 0xAA;
const short NACK = 0xAF;
const unsigned int POLMODBUS = 0xA001;

unsigned short byteTrama;
unsigned short t1Size;
unsigned char tramaRS485[50];
short i1;

unsigned short banTC, banTI, banTF;

unsigned short banLP, banLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;

unsigned char tramaSPI[50];
unsigned short sizeSPI;
unsigned short direccionRpi;
unsigned short funcionRpi;

unsigned short contadorTOD;
unsigned short contadorNACK;








void ConfiguracionPrincipal(){

 TRISB0_bit = 1;
 TRISC4_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 INTCON = 0xC0;


 UART1_Init(19200);
 PIE1.RCIE = 1;

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

 tramaRS485[0]=HDR;
 tramaRS485[sizePDU+2]=*ptrCrcPdu;
 tramaRS485[sizePDU+1]=*(ptrCrcPdu+1);
 tramaRS485[sizePDU+3]=END1;
 tramaRS485[sizePDU+4]=END2;
 RE_DE = 1;
 for (i=0;i<(sizePDU+5);i++){
 if ((i>=1)&&(i<=sizePDU)){

 UART1_Write(tramaPDU[i-1]);
 } else {
 UART1_Write(tramaRS485[i]);
 }
 }
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;

 byteTrama=0;



 T1CON.TMR1ON = 1;
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
}






unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
 unsigned char pdu[15];
 unsigned short j;
 unsigned int crcCalculado, crcTrama;
 unsigned short *ptrCRCTrama;
 crcCalculado = 0;
 crcTrama = 1;
 for (j=0;j<=(tramaPDUSize);j++){
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
 RE_DE = 1;
 UART1_Write(ACK);
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;
}





void EnviarNACK(){
 RE_DE = 1;
 UART1_Write(NACK);
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;
}




void interrupt(){







 if (PIR1.RCIF==1){

 IU1 = 1;

 IU1 = 0;

 byteTrama = UART1_Read();

 if (banTI==0){
 if ((byteTrama==HDR)){
 banTI = 1;
 i1 = 0;
 tramaOk = 9;
 }
 }

 if (banTI==1){
 if (byteTrama!=END2){
 tramaRS485[i1] = byteTrama;
 i1++;
 banTF = 0;
 } else {
 tramaRS485[i1] = byteTrama;
 banTF = 1;
 }
 if (BanTF==1){
 banTI = 0;
 banTC = 1;
 }
 }

 if (banTC==1){
 t1Size = tramaRS485[4]+4;
 tramaOk = VerificarCRC(tramaRS485,t1Size);
 if (tramaOk==1){
 EnviarACK();

 Delay_ms(1000);
 EnviarMensajeRS485(tramaSPI, sizeSPI);

 }else{
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
 RE_DE = 1;
 i1=0;
 contadorTOD = 0;
 contadorNACK = 0;
 byteTrama = 0;

 banTI = 0;
 banTC = 0;
 banTF = 0;
 banLR = 0;


 sizeSPI = 8;
 tramaSPI[0] = 0x09;
 tramaSPI[1] = 0x01;
 tramaSPI[2] = 0x02;
 tramaSPI[3] = sizeSPI-4;
 tramaSPI[4] = 0xD1;
 tramaSPI[5] = 0xD2;
 tramaSPI[6] = 0xD3;
 tramaSPI[7] = 0xD4;

}
