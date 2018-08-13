#line 1 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
#line 13 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
const short Hdr = 0x3A;
const short End1 = 0x0D;
const short End2 = 0x0A;

unsigned short DataSize;
unsigned short Psize;
unsigned short Rsize;

unsigned short Add;
unsigned short Fcn;



unsigned char PDU[100];
unsigned char Ptcn[100];
unsigned char Rspt[100];

unsigned short it, ir, ip, i, j;
unsigned short BanTC, BanTI, BanTF;
unsigned short Dato;

const unsigned int PolModbus = 0xA001;
unsigned int CRC16, CRCPDU;
unsigned short *ptrCRC16, *ptrCRCPDU;

unsigned short Bb;



void interrupt(void){
 if(PIR1.F5==1){

 Dato = UART1_Read();




 if (Dato==Hdr){
 BanTI = 1;
 it = 0;

 }

 if (BanTI==1){

 if ((BanTF==1)&&(Dato==End2)){
 RSize = it+1;
 BanTI = 0;
 BanTC = 1;
 }

 if (Dato!=End1){
 Rspt[it] = Dato;
 it++;
 BanTF = 0;
 } else {
 Rspt[it] = Dato;
 it++;
 BanTF = 1;
 }

 }

 PIR1.F5 = 0;
 }
}



unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
{
 unsigned char ucCounter;
 unsigned int uiCRCResult;

 for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
 {
 uiCRCResult ^= *ptucBuffer ++;
 for(ucCounter =0; ucCounter <8; ucCounter ++)
 {
 if(uiCRCResult & 0x0001)
 uiCRCResult =(uiCRCResult>>1)^PolModbus;
 else
 uiCRCResult >>= 1;
 }
 }
 return uiCRCResult;
}


void Configuracion(){

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 TRISC5_bit = 0;
 TRISC4_bit = 0;
 TRISA0_bit = 1;
 TRISA1_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON.RBIF = 0;

 PIE1.RC1IE = 1;
 PIR1.F5 = 0;

 UART1_Init(19200);

 Delay_ms(10);

}

void main() {

 Configuracion();

 BanTI = 0;
 BanTC = 0;
 BanTF = 0;

 Bb = 0;


 RC5_bit = 0;
 RC4_bit = 0;

 ptrCRC16 = &CRC16;
 ptrCRCPDU = &CRCPDU;

 Add = 0x01;
 Fcn = 0x02;
 DataSize = 2;

 Psize = DataSize+7;






 Ptcn[0]=Hdr;
 Ptcn[1]=Add;
 Ptcn[2]=Fcn;
 Ptcn[3]=0x03;
 Ptcn[4]=0x04;
 Ptcn[7]=End1;
 Ptcn[8]=End2;



 while (1){


 if ((RA0_bit==0)&&(Bb==0)){
 Bb = 1;

 for (i=1;i<=(DataSize+2);i++){
 PDU[i-1] = Ptcn[i];
 }

 CRC16 = ModbusRTU_CRC16(PDU, DataSize+2);
 Ptcn[6] = *ptrCRC16;
 Ptcn[5] = *(ptrCRC16+1);

 RC5_bit = 1;
 for (i=0;i<Psize;i++){
 UART1_WRITE(Ptcn[i]);
 }

 while(UART_Tx_Idle()==0);
 RC5_bit = 0;

 } else if (RA0_bit==1){
 Bb = 0;
 }

 if (BanTC==1){

 if (Rspt[1]==Add){

 for (i=0;i<=(Rsize-5);i++){
 PDU[i] = Rspt[i+1];
 }

 CRC16 = ModbusRTU_CRC16(PDU, Rsize-5);
 *ptrCRCPDU = Rspt[Rsize-3];
 *(ptrCRCPDU+1) = Rspt[Rsize-4];

 if (CRC16==CRCPDU) {



 RC4_bit = ~RC4_bit;

 }

 }

 BanTC = 0;

 }

 Delay_ms(10);

 }
}
