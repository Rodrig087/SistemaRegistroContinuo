#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoComunicacionMultilple/EsclavoComunicacionMultiple.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoComunicacionMultilple/EsclavoComunicacionMultiple.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;

sbit RE_DE at RC5_bit;
sbit RE_DE_Direction at TRISC5_bit;

sbit IU1 at RC4_bit;
sbit IU1_Direction at TRISC4_bit;
sbit IU2 at RB3_bit;
sbit IU2_Direction at TRISB3_bit;

sbit ENABLE at RB5_bit;
sbit ENABLE_Direction at TRISB5_bit;
sbit SET at RB4_bit;
sbit SET_Direction at TRISB4_bit;

const short DIR = 0xFD;
const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const short ACK = 0xAA;
const short NACK = 0xAF;
const unsigned int POLMODBUS = 0xA001;

unsigned short byteTrama;
unsigned short t2Size, sizeTramaPDU, numDatosEsc;
unsigned char tramaSerial[50];
unsigned char tramaPDU[15];
unsigned char tramaPetEsc[10];
unsigned char u2Trama[50];
short i1;

unsigned short banTC, banTI, banTF;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;
unsigned short banAtEsc, banIdEsc;

unsigned short tramaOk;
unsigned short puertoTOT;

unsigned short x;








void ConfiguracionPrincipal(){

 ANSELB = 0;
 ANSELC = 0;

 TRISB3_bit = 0;
 TRISB5_bit = 0;
 TRISC5_bit = 0;
 TRISB4_bit = 0;
 TRISC4_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 PIE1.RC1IE = 1;
 PIR1.F5 = 0;
 PIE3.RC2IE = 1;
 PIR3.F5 = 0;
 UART1_Init(19200);
 UART2_Init(19200);


 T2CON = 0x78;
 PR2 = 249;
 PIR1.TMR2IF = 0;
 PIE1.TMR2IE = 1;

 Delay_ms(100);

}





unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
 unsigned char ucCounter;
 unsigned int CRC16;
 for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
 CRC16^=*trama ++;
 for(ucCounter=0; ucCounter<8; ucCounter++){
 if(CRC16 & 0x0001)
 CRC16 = (CRC16>>1)^POLMODBUS;
 else
 CRC16>>=1;
 }
 }
 return CRC16;
}






unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
 unsigned char pdu[15];
 unsigned short j;
 unsigned int crcCalculado, crcTrama;
 unsigned short *ptrCRCTrama;
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





void EnviarACK(unsigned char puerto){
 if (puerto==1){
 RE_DE = 1;
 UART1_Write(ACK);
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;
 } else {
 UART2_Write(ACK);
 while(UART2_Tx_Idle()==0);
 }
}





void EnviarNACK(unsigned char puerto){
 if (puerto==1){
 RE_DE = 1;
 UART1_Write(NACK);
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;
 } else {
 UART2_Write(NACK);
 while(UART2_Tx_Idle()==0);
 }
}





void EnviarSolicitudEsclavo(unsigned char* trama, unsigned char tramaPDUSize){
 unsigned short j;
 RE_DE = 1;
 UART1_Write(0xB0);
 for (j=0;j<tramaPDUSize;j++){
 UART1_Write(trama[j+1]);
 }
 UART1_Write(0xB1);
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;

}




void interrupt(void){






 if(PIR3.RC2IF ==1){

 IU1 = 1;
 byteTrama = UART2_Read();


 if (banTI==0){
 if (byteTrama==HDR){
 banTI = 1;
 i1 = 0;
 tramaOk = 9;
 puertoTOT = 1;

 T2CON.TMR2ON = 1;
 PR2 = 249;
 }
 }



 if (banTI==1){
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 if (byteTrama!=END2){
 tramaSerial[i1] = byteTrama;
 i1++;
 banTF = 0;
 T2CON.TMR2ON = 1;
 PR2 = 249;
 } else {
 tramaSerial[i1] = byteTrama;
 banTF = 1;
 T2CON.TMR2ON = 1;
 PR2 = 249;
 }
 if (BanTF==1){
 banTI = 0;
 banTC = 1;
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 }
 }


 if (banTC==1){
 numDatosEsc = tramaSerial[4];
 sizeTramaPDU = numDatosEsc+4;
 tramaOk = VerificarCRC(tramaSerial,sizeTramaPDU);
 if (tramaOk==1){

 EnviarACK(2);
 EnviarSolicitudEsclavo(tramaSerial,sizeTramaPDU);
 } else if (tramaOk==0) {
 EnviarNACK(2);
 }
 banTI = 0;
 banTC = 0;
 i1 = 0;
 }

 PIR3.RC2IF = 0;
 IU1 = 0;

 }




 if (PIR1.RC1IF==1){

 IU2 = 1;
 byteTrama = UART1_Read();




 PIR1.RC1IF = 0;
 IU2 = 0;

 }







 if (TMR2IF_bit==1){
 TMR2IF_bit = 0;
 T2CON.TMR2ON = 0;
 banTI = 0;
 i1 = 0;
 banTC = 0;
 if (puertoTOT==1){
 EnviarNACK(1);
 } else if (puertoTOT==2) {
 EnviarNACK(2);
 }
 puertoTOT = 0;
 }

}



void main() {

 ConfiguracionPrincipal();

 RE_DE = 0;
 ENABLE = 1;
 SET = 1;
 i1=0;
 banTI=0;
 banTC=0;
 banTF=0;
 AUX = 0;

}
