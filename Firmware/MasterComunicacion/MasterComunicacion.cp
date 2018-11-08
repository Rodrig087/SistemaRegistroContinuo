#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/MasterComunicacion/MasterComunicacion.c"
#line 22 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/MasterComunicacion/MasterComunicacion.c"
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

unsigned short BanLP, BanLR;
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
 TRISB1_bit = 0;
 TRISB2_bit = 1;
 TRISB3_bit = 0;
 TRISB5_bit = 0;
 TRISB6_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);


 T1CON = 0x30;
 TMR1IF_bit = 0;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
 TMR1IE_bit = 1;
 INTCON = 0xC0;


 T2CON = 0x78;
 PR2 = 249;
 TMR2IE_bit = 1;


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

 tramaRS485[0]=HDR;
 tramaRS485[sizePDU+2] = *ptrCrcPdu;
 tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);
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
#line 149 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/MasterComunicacion/MasterComunicacion.c"
}






unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
 unsigned char* pdu;
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



 if (INTCON.INTF==1){
 INTCON.INTF=0;

 tramaSPI[0]=0x03;
 tramaSPI[1]=0x04;
 tramaSPI[2]=0x05;
 tramaSPI[3]=0x06;

 direccionRpi = tramaSPI[0];
 sizeSPI = tramaSPI[1];
 funcionRpi = tramaSPI[2];


 EnviarMensajeRS485(tramaSPI, sizeSPI);
#line 239 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/MasterComunicacion/MasterComunicacion.c"
 }







 if (PIR1.F5==1){

 IU1 = 1;
 byteTrama = UART1_Read();

 if ((byteTrama==ACK)&&(banTI==0)){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 }

 if ((byteTrama==NACK)&&(banTI==0)){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 if (contadorNACK<3){
 EnviarMensajeRS485(tramaSPI, sizeSPI);
 contadorNACK++;
 } else {

 contadorNACK = 0;
 }

 }

 if ((byteTrama==HDR)&&(banTI==0)){
 tramaRS485[0]=byteTrama;
 banTI = 1;
 i1 = 1;
 tramaOk = 0;

 T2CON.TMR2ON = 1;
 PR2 = 249;
 }

 if (banTI==1){
 T2CON.TMR2ON = 0;
 if (i1==1){
 tramaRS485[i1] = byteTrama;
 i1 = 2;
 T2CON.TMR2ON = 1;
 } else if (i1=2){
 tramaRS485[i1] = byteTrama;
 t1Size = byteTrama;
 i1 = 3;
 T2CON.TMR2ON = 1;
 } else if ((i1>2)&&(i1<t1Size)){
 tramaRS485[i1] = byteTrama;
 i1=i1+1;
 T2CON.TMR2ON = 1;
 if (i1==t1Size-1){
 banTI = 0;
 banTC = 1;
 T2CON.TMR2ON = 0;
 }
 }
 }

 if (banTC==1){

 tramaOk = VerificarCRC(tramaRS485,t1Size);

 if (tramaOk==1){
 EnviarACK();

 } else {
 EnviarNACK();
 }
 banTC = 0;
 i1 = 0;

 }

 PIR1.F5 = 0;
 IU1 = 0;


 }





 if (PIR1.TMR1IF==1){
 TMR1IF_bit = 0;
 T1CON.TMR1ON = 0;
 if (contadorTOD<3){
 EnviarMensajeRS485(tramaSPI, sizeSPI);
 contadorTOD++;
 } else {

 contadorTOD = 0;
 }
 }






 if (PIR1.TMR2IF==1){
 TMR2IF_bit = 0;
 T2CON.TMR2ON = 0;
 banTI = 0;
 i1 = 0;
 banTC = 0;
 EnviarNACK();
 }

}



void main() {

 ConfiguracionPrincipal();
 RE_DE = 1;
 i1=0;
 contadorTOD = 0;
 contadorNACK = 0;

}
