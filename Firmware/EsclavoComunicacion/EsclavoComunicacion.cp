#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/EsclavoComunicacion/EsclavoComunicacion.c"
#line 21 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/EsclavoComunicacion/EsclavoComunicacion.c"
sbit IU1 at RB2_bit;
sbit IU1_Direction at TRISB2_bit;
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

unsigned short idEsclavo;
unsigned short funcEsclavo;

unsigned short byteTrama;
unsigned short t1Size;
unsigned short t1IdEsclavo;
unsigned short t1Funcion;
unsigned char tramaSerial[50];
short i1;

unsigned short banTC, banTI, banTF;

unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;

unsigned short tramaOk;

unsigned char petSPI[4];
unsigned char resSPI[15];
unsigned short direccionEsc;
unsigned short numBytesSPI;
unsigned short numDatos;
unsigned short banMed;

unsigned short contadorTOD;
unsigned short contadorNACK;

unsigned short x;









void ConfiguracionPrincipal(){

 TRISB0_bit = 1;
 TRISB2_bit = 0;
 TRISB3_bit = 0;
 TRISC2_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);
 PIE1.RCIE = 1;


 SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);


 T1CON = 0x30;
 PIR1.TMR1IF = 0;
 TMR1H = 0x0B;
 TMR1L = 0xDC;
 PIE1.TMR1IE = 1;
 INTCON = 0xC0;


 T2CON = 0x78;
 PR2 = 249;
 PIR1.TMR2IF = 0;
 PIE1.TMR2IE = 1;


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





void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
 unsigned char i;
 unsigned int CRCPDU;
 unsigned short *ptrCRCPDU;
 CRCPDU = CalcularCRC(tramaPDU, sizePDU);
 ptrCRCPDU = &CRCPDU;

 tramaSerial[0]=HDR;
 tramaSerial[sizePDU+2] = *ptrCrcPdu;
 tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);
 tramaSerial[sizePDU+3] = END1;
 tramaSerial[sizePDU+4] = END2;
 for (i=0;i<(sizePDU+5);i++){
 if ((i>=1)&&(i<=sizePDU)){
 UART1_Write(tramaPDU[i-1]);
 } else {
 UART1_Write(tramaSerial[i]);
 }
 }
 while(UART1_Tx_Idle()==0);
#line 162 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/EsclavoComunicacion/EsclavoComunicacion.c"
}





void EnviarMensajeError(unsigned short codigoError){
 unsigned char i;
 unsigned int CRCerrorPDU;
 unsigned short *ptrCRCerrorPDU;
 unsigned char errorPDU[4];
 errorPDU[0] = idEsclavo;
 errorPDU[1] = 0x01;
 errorPDU[2] = 0xEE;
 errorPDU[3] = codigoError;
 CRCerrorPDU = CalcularCRC(errorPDU,4);
 ptrCRCerrorPDU = &CRCerrorPDU;

 tramaSerial[0] = HDR;
 tramaSerial[6] = *ptrCRCerrorPDU;
 tramaSerial[5] = *(ptrCRCerrorPDU+1);
 tramaSerial[7] = END1;
 tramaSerial[8] = END2;
 for (i=0;i<(9);i++){
 if ((i>=1)&&(i<=4)){
 UART1_Write(errorPDU[i-1]);
 } else {
 UART1_Write(tramaSerial[i]);
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





void EnviarSolicitudMedicion(unsigned short registroEsclavo){
 petSPI[0] = 0xB0;
 petSPI[1] = registroEsclavo;
 petSPI[2] = 0xB1;
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
 banMed = 1;
}





void IdentificarEsclavo(){
 petSPI[0] = 0xA0;
 petSPI[1] = 0xA1;
 petSPI[2] = 0xA2;
 petSPI[3] = 0xA3;
 CS = 0;
 for (x=0;x<4;x++){
 SSPBUF = petSPI[x];
 if (x==2){
 while (SSPSTAT.BF!=1);
 idEsclavo = SSPBUF;
 }
 if (x==3){
 while (SSPSTAT.BF!=1);
 funcEsclavo = SSPBUF;
 }
 Delay_ms(1);
 }
 CS = 1;
}





void interrupt(){



 if (INTCON.INTF==1){
 INTCON.INTF=0;
 if (banMed==1){

 CS = 0;
 for (x=0;x<(numBytesSPI+1);x++){
 SSPBUF = 0xCC;
 if ((x>0)){
 while (SSPSTAT.BF!=1);
 resSPI[x+2] = SSPBUF;
 }
 Delay_us(200);
 }
 CS = 1;

 resSPI[0] = idEsclavo;
 resSPI[1] = numBytesSPI + 3;
 resSPI[2] = t1Funcion;

 }
 banMed=0;

 EnviarMensajeUART(resSPI,(numBytesSPI+3));

 }







 if (PIR1.RCIF==1){

 IU1 = 1;
 byteTrama = UART1_Read();
 AUX = 1;

 if (banTI==0){
 if ((byteTrama==ACK)){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 banTI=0;
 byteTrama=0;
 }

 if ((byteTrama==NACK)){

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 if (contadorNACK<3){

 contadorNACK++;
 } else {
 contadorNACK = 0;
 }
 banTI=0;
 byteTrama=0;
 }

 if ((byteTrama==HDR)){
 banTI = 1;
 i1 = 0;
 tramaOk = 9;

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
 t1IdEsclavo = tramaSerial[1];
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 }
 }

 if (banTC==1){
 if (t1IdEsclavo==IdEsclavo){
 t1Size = tramaSerial[2]+3;
 t1Funcion = tramaSerial[3];
 tramaOk = VerificarCRC(tramaSerial,t1Size);
 if (tramaOk==1){
 EnviarACK();


 if (t1Funcion<=funcEsclavo){
 EnviarSolicitudMedicion(tramaSerial[4]);
 } else {
 EnviarMensajeError(0xE0);
 }

 } else if (tramaOk==0) {
 EnviarNACK();
 }
 }
 banTC = 0;
 i1 = 0;
 banTI = 0;
 }

 PIR1.RCIF = 0;
 IU1 = 0;
 AUX = 0;

 }





 if (PIR1.TMR1IF==1){
 TMR1IF_bit = 0;
 T1CON.TMR1ON = 0;
 if (contadorTOD<3){

 contadorTOD++;
 } else {

 contadorTOD = 0;
 }
 }






 if (PIR1.TMR2IF==1){
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 i1 = 0;
 banTI = 0;
 banTC = 0;
 banTF = 0;
 EnviarNACK();
 }

}



void main() {

 ConfiguracionPrincipal();
 IdentificarEsclavo();
 CS = 1;
 AUX = 0;
 IU1 = 0;
 i1=0;
 contadorTOD = 0;
 contadorNACK = 0;
 banTI = 0;
 banTC = 0;
 banTF = 0;
 banMed = 0;
}
