#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/CPComunicacion/CPComunicacion.c"
#line 31 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/CPComunicacion/CPComunicacion.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;
sbit IU1 at RB4_bit;
sbit IU1_Direction at TRISB4_bit;
sbit RInt at RC1_bit;
sbit RInt_Direction at TRISC1_bit;
sbit RE_DE at RC2_bit;
sbit RE_DE_Direction at TRISC2_bit;

const short DIR = 0xFD;
const short HDR = 0x3A;
const short END1 = 0x0D;
const short END2 = 0x0A;
const short ACK = 0xAA;
const short NACK = 0xAF;
const unsigned int POLMODBUS = 0xA001;

unsigned short byteTrama;
unsigned short t1Size,pduSize;
unsigned char tramaRS485[25];
unsigned char tramaPDU[15];
unsigned char pduSPI[10];
unsigned short i1;

unsigned short banTC, banTI, banTF;

unsigned short tramaOk;
unsigned short contadorTOD;
unsigned short contadorNACK;

unsigned short i, x;
unsigned short buffer;
unsigned short banResp, banSPI, banLec, banEsc;
unsigned short banBoton;









void ConfiguracionPrincipal(){

 ANSELB = 0;
 ANSELC = 0;

 TRISB1_bit = 1;
 TRISB3_bit = 0;
 TRISB4_bit = 0;
 TRISC1_bit = 0;
 TRISC2_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 PIE1.RC1IE = 1;
 UART1_Init(19200);


 SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
 PIE1.SSP1IE = 1;





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





void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
 unsigned char i;
 unsigned int CRCPDU;
 unsigned short *ptrCRCPDU;
 CRCPDU = CalcularCRC(PDU, sizePDU);
 ptrCRCPDU = &CRCPDU;

 tramaRS485[0] = HDR;
 tramaRS485[sizePDU+2] = *ptrCrcPdu;
 tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);
 tramaRS485[sizePDU+3] = END1;
 tramaRS485[sizePDU+4] = END2;
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






void EnviarMensajeSPI(unsigned char *trama, unsigned char pduSize2){
 unsigned short j;
 for (j=0;j<pduSize2;j++){
 pduSPI[j] = trama[j+1];
 UART1_Write(pduSPI[j]);
 }
 RInt = 1;
 Delay_ms(1);
 RInt = 0;
}





void EnviarErrorSPI(unsigned char *trama, unsigned short codigoError){
 pduSPI[0] = trama[0];
 pduSPI[1] = 0xEE;
 pduSPI[2] = trama[2];
 pduSPI[3] = 0x01;
 pduSPI[4] = codigoError;
 t1Size = 5;
 RInt = 1;
 Delay_ms(1);
 RInt = 0;
}




void ProbarSPI(){



}




void interrupt(void){


 if (PIR1.SSP1IF){

 PIR1.SSP1IF = 0;
 buffer = SSPBUF;
 AUX = 1;
 Delay_us(2);
 AUX = 0;
#line 291 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Pruebas/SPI_ConcentradorPrincipal/CPComunicacion/CPComunicacion.c"
 }



 if (INTCON.INT0IF==1){
 INTCON.INT0IF = 0;

 if (banBoton==0){
 UART1_Write(0x2A);
 RInt = 1;
 Delay_ms(1);
 RInt = 0;
 banBoton = 1;
 }
 }

}



void main() {

 ConfiguracionPrincipal();
 RE_DE = 0;
 RInt = 0;
 i1=0;
 contadorTOD = 0;
 contadorNACK = 0;
 banTI=0;
 banTC=0;
 banTF=0;
 banEsc = 0;
 banBoton = 0;

 AUX = 0;
 t1Size = 0;

 while(1){










 }

}
