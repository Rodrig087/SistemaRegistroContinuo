#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Splitter/Splitter.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Splitter/Splitter.c"
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
unsigned short t1Size, t2Size, sizeTramaPDU;
unsigned char tramaRS485[50];
unsigned char tramaPDU[15];
unsigned char u2Trama[50];
short i1, i2;

unsigned short banTC, banTI, banTF;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;
unsigned short contadorTOD;
unsigned short contadorNACK;
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


 T1CON = 0x30;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
 PIR1.TMR1IF = 0;
 PIE1.TMR1IE = 1;


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
 unsigned short i;
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
 unsigned short i;
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





void RenviarTrama(unsigned char puerto, unsigned char *trama, unsigned char sizePDU){
 unsigned char i;
 if (puerto==1){
 RE_DE = 1;
 for (i=0;i<(sizePDU+5);i++){
 UART1_Write(trama[i]);
 }
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;
 } else {
 for (i=0;i<(sizePDU+5);i++){
 UART2_Write(trama[i]);
 }
 while(UART2_Tx_Idle()==0);
 }



}





void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
 unsigned char i;
 unsigned int CRCPDU;
 unsigned short *ptrCRCPDU;
 CRCPDU = CalcularCRC(PDU, sizePDU);
 ptrCRCPDU = &CRCPDU;

 tramaRS485[0]=HDR;
 tramaRS485[sizePDU+2] = *ptrCrcPdu;
 tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);
 tramaRS485[sizePDU+3]=END1;
 tramaRS485[sizePDU+4]=END2;
 RE_DE = 1;
 for (i=0;i<(sizePDU+5);i++){
 if ((i>=1)&&(i<=sizePDU)){
 UART1_Write(PDU[i-1]);
 } else {
 UART1_Write(tramaRS485[i]);
 }
 }
 while(UART1_Tx_Idle()==0);
 RE_DE = 0;

 T1CON.TMR1ON = 1;
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
}






void ConfiguracionAPC220(unsigned char *trama, unsigned char tramaSize){
 unsigned char* datos;
 unsigned short k=0;
 unsigned short datosSize = tramaSize-8;
 while (k<=datosSize){
 datos[k] = trama[k+3]+0x30;
 k++;
 if (k==6||k==8||k==10||k==12||k==14){
 datos[k] = 0x20;
 k++;
 }
 }
 SET = 0;
 UART2_Init(9600);
 Delay_ms(5);
 UART2_Write(0x57);
 UART2_Write(0x52);
 UART2_Write(0x20);
 for (k=0;k<(datosSize);k++){
 UART2_Write(datos[k]);
 }
 UART2_Write(0x0D);
 UART2_Write(0x0A);
 while(UART1_Tx_Idle()==0);
 Delay_ms(200);


 Delay_ms(5);
 SET = 1;
 UART2_Init(19200);
 Delay_ms(100);
 RenviarTrama(1,trama,tramaSize);
}





void interrupt(void){







 if(PIR1.RC1IF==1){

 IU1 = 1;
 byteTrama = UART1_Read();


 if (banTI==0){
 if (byteTrama==HDR){
 banTI = 1;
 i1 = 0;
 tramaOk = 9;
 puertoTOT = 1;

 T2CON.TMR2ON = 1;
 PR2 = 249;
 }
 if (byteTrama==ACK){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 banTI=0;
 }
 if (byteTrama==NACK){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 if (contadorNACK<3){
 EnviarMensajeRS485(tramaRS485,sizeTramaPDU);
 contadorNACK++;
 } else {
 contadorNACK = 0;
 }
 banTI=0;
 }
 }



 if (banTI==1){
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 if (byteTrama!=END2){
 tramaRS485[i1] = byteTrama;
 i1++;
 banTF = 0;
 T2CON.TMR2ON = 1;
 PR2 = 249;
 } else {
 tramaRS485[i1] = byteTrama;
 banTF = 1;
 T2CON.TMR2ON = 1;
 PR2 = 249;
 }
 if (BanTF==1){
 banTI = 0;
 banTC = 1;
 t1Size = tramaRS485[2];
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 }
 }


 if (banTC==1){
 tramaOk = VerificarCRC(tramaRS485,t1Size);
 if (tramaOk==1){

 EnviarACK(1);
 if (tramaRS485[1]==DIR){
 if (tramaRS485[3]==0x01){

 } else if (tramaRS485[3]==0x02){

 } else if (tramaRS485[3]==0x03){
 ConfiguracionAPC220(tramaRS485,t1Size);
 } else {

 tramaPDU[1]=DIR;
 tramaPDU[2]=0x04;
 tramaPDU[3]=0xEE;
 tramaPDU[4]=0xE0;
 sizeTramaPDU = tramaPDU[2];
 EnviarMensajeRS485(tramaRS485,sizeTramaPDU);
 }
 } else {
 RenviarTrama(2,tramaRS485,t1Size);
 }
 } else if (tramaOk==0) {
 EnviarNACK(1);
 }
 banTI = 0;
 banTC = 0;
 i1 = 0;
 }


 IU1 = 0;

 }
#line 491 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Splitter/Splitter.c"
 if (TMR1IF_bit==1){
 TMR1IF_bit = 0;
 T1CON.TMR1ON = 0;
 if (contadorTOD<3){
 EnviarMensajeRS485(tramaPDU, sizeTramaPDU);
 contadorTOD++;
 } else {

 contadorTOD = 0;
 }
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
 i2=0;
 contadorTOD = 0;
 contadorNACK = 0;
 banTI=0;
 banTC=0;
 banTF=0;
 AUX = 0;

}
