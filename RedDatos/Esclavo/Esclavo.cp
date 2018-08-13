#line 1 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Esclavo/Esclavo.c"
#line 12 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Esclavo/Esclavo.c"
const short Hdr = 0x3A;
const short End1 = 0x0D;
const short End2 = 0x0A;

unsigned short PDUSize;
unsigned short Psize;
unsigned short Rsize;

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
 if(PIR1.F5==1){

 Dato = UART1_Read();




 if (Dato==Hdr){
 BanTI = 1;
 it = 0;

 }

 if (BanTI==1){

 if ((BanTF==1)&&(Dato==End2)){
 Ptcn[it] = 0;
 PSize = it;
 BanTI = 0;
 BanTC = 1;
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
}



void Responder(unsigned int Reg){

 if (Reg==0x01){
 for (ir=4;ir>=3;ir--){
 Rspt[ir]=(*chTemp++);
 }
 }

 if (Reg==0x02){
 for (ir=4;ir>=3;ir--){
 Rspt[ir]=(*chHmd++);
 }
 }

 Rspt[2]=Ptcn[2];

 RC5_bit = 1;

 for (ir=0;ir<Rsize;ir++){
 UART1_Write(Rspt[ir]);
 }
 while(UART1_Tx_Idle()==0);

 RC5_bit = 0;

 for (ir=3;ir<5;ir++){
 Rspt[ir]=0;;
 }

}


unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
{
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



void Configuracion(){

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 TRISA = 1;
 TRISC4_bit = 0;
 TRISC5_bit = 0;
 TRISC0_bit = 1;
 TRISC1_bit = 1;


 INTCON.GIE = 1;
 INTCON.PEIE = 1;

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

 RC5_bit = 0;
 RC4_bit = 0;

 CRC16 = 0;
 CRCPDU = 1;

 ptrCRC16 = &CRC16;
 ptrCRCPDU = &CRCPDU;

 Add = 0x01;
 Fcn = 0x02;
 Rsize = 9;






 Rspt[0] = Hdr;
 Rspt[1] = Add;
 Rspt[7] = End1;
 Rspt[8] = End2;

 while (1){

 if (BanTC==1){

 if (Ptcn[1]==Add){

 for (i=0;i<=(Psize-5);i++){
 PDU[i] = Ptcn[i+1];
 }

 CRC16 = ModbusRTU_CRC16(PDU, 4);
 *ptrCRCPDU = Ptcn[Psize-2];
 *(ptrCRCPDU+1) = Ptcn[Psize-3];

 if (CRC16==CRCPDU) {




 RC4_bit = ~RC4_bit;
 Rspt[2] = Ptcn[2];
 Rspt[3] = 0xAA;
 Rspt[4] = 0xFF;

 for (i=0;i<=3;i++){
 PDU[i] = Rspt[i+1];
 }

 CRC16 = ModbusRTU_CRC16(PDU, 4);
 Rspt[6] = *ptrCRC16;
 Rspt[5] = *(ptrCRC16+1);

 for (i=0;i<=8;i++){
 UART1_Write(Rspt[i]);
 }
 while(UART1_Tx_Idle()==0);

 }
 BanTC = 0;
 }

 BanTC = 0;

 }

 Delay_ms(10);


 }

}
