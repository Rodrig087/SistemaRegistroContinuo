#line 1 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Esclavo/Esclavo.c"
#line 12 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Esclavo/Esclavo.c"
const short Hdr = 0x3A;
const short End1 = 0x0D;
const short End2 = 0x0A;

unsigned short dataSize;
unsigned short Psize;


unsigned short Add;
unsigned short Fcn;



unsigned char PDU[100];
unsigned char Ptcn[100];
unsigned char Rspt[9];

unsigned short it, ir, ip, i, j;
unsigned short BanTC, BanTI, BanTF;
unsigned short Dato;

const unsigned int PolModbus = 0xA001;
unsigned int CRC16, CRCPDU;
unsigned short *ptrCRC16, *ptrCRCPDU;

unsigned short Bb;


unsigned int ITemp, IHmd, Sum;
unsigned char *chTemp, *chHmd;
unsigned char Check, T_byte1, T_byte2, RH_byte1, RH_byte2;
unsigned int DatoPtcn;
unsigned short *chDP;




void interrupt(void){

 if(PIR1.RC1IF==1){

 Dato = UART1_Read();




 if (Dato==Hdr){
 BanTI = 1;
 it = 0;

 T1CON.TMR1ON = 1;
 TMR1IF_bit = 0;
 TMR1H = 0x3C;
 TMR1L = 0xB0;
 }

 if (BanTI==1){

 if ((BanTF==1)&&(Dato==End2)){
 PSize = it+1;
 BanTI = 0;
 BanTC = 1;

 T1CON.TMR1ON = 0;
 TMR1IF_bit = 0;
 }

 if (Dato!=End1){
 Ptcn[it] = Dato;
 it++;
 BanTF = 0;
 } else {
 Ptcn[it] = Dato;
 it++;
 BanTF = 1;
 }

 }

 PIR1.F5 = 0;
 }





 if (TMR1IF_bit==1){

 TMR1IF_bit = 0;
 T1CON.TMR1ON = 0;
 BanTI = 0;
 it = 0;
 BanTC = 0;

 }

}




unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen){

 unsigned char ucCounter;
 unsigned int uiCRCResult;
 for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
 {
 uiCRCResult ^=*ptucBuffer ++;
 for(ucCounter =0; ucCounter <8; ucCounter ++)
 {
 if(uiCRCResult & 0x0001)
 uiCRCResult =( uiCRCResult >>1)^PolModbus;
 else
 uiCRCResult >>=1;
 }
 }
 return uiCRCResult;

}








void enviarTrama(unsigned short dataSize){

 unsigned short rSize = dataSize + 7;


 PDU[0] = Add;
 PDU[1] = Ptcn[2];

 PDU[2] = 0xEE;
 PDU[3] = 0xEE;


 Rspt[0] = Hdr;
 for (i=0;i<=(dataSize+1);i++){
 Rspt[i+1] = PDU[i];
 }
 CRC16 = ModbusRTU_CRC16(PDU, dataSize+2);
 Rspt[dataSize+3] = *(ptrCRC16+1);
 Rspt[dataSize+4] = *ptrCRC16;
 Rspt[dataSize+5] = End1;
 Rspt[dataSize+6] = End2;


 RC5_bit = 1;
 for (i=0;i<rSize;i++){
 UART1_Write(Rspt[i]);
 }
 while(UART1_Tx_Idle()==0);
 RC5_bit = 0;

}



void Configuracion(){

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 TRISA = 1;
 TRISC0_bit = 1;
 TRISC1_bit = 1;
 TRISC4_bit = 0;
 TRISC5_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 PIE1.RC1IE = 1;
 PIR1.RC1IF = 0;
 UART1_Init(19200);


 T1CON = 0x11;
 TMR1IE_bit = 1;
 TMR1IF_bit = 0;
 TMR1H = 0x3C;
 TMR1L = 0xB0;


 RCON.IPEN = 1;
 IPR1.RC1IP = 0;
 IPR1.TMR1IP = 1;

 Delay_ms(10);

}


void main() {

 Configuracion();

 BanTI = 0;
 BanTC = 0;
 BanTF = 0;

 RC5_bit = 0;
 RC4_bit = 0;

 CRC16 = 0;
 CRCPDU = 1;

 ptrCRC16 = &CRC16;
 ptrCRCPDU = &CRCPDU;

 Add = (PORTA&0x3F)+((PORTC&0x03)<<6);

 while (1){

 if (BanTC==1){

 if (Ptcn[1]==Add){

 for (i=0;i<=(Psize-5);i++){
 PDU[i] = Ptcn[i+1];
 }

 CRC16 = ModbusRTU_CRC16(PDU, Psize-5);
 *ptrCRCPDU = Ptcn[Psize-3];
 *(ptrCRCPDU+1) = Ptcn[Psize-4];

 if (CRC16==CRCPDU) {



 enviarTrama(2);

 }
 BanTC = 0;
 }

 BanTC = 0;

 }

 Delay_ms(10);


 }

}
