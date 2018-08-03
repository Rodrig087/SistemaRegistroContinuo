#line 1 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
#line 13 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
const short Hdr = 0x3A;
const short End = 0x0D;
const short Id = 0x02;
const short Fcn = 0x01;

const short PDUSize = 4;
const short Psize = 6;
const short Rsize = 6;

unsigned char PDU[PDUSize];
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];

short ir, irr, ip, j;
unsigned short BanP, BanT;
unsigned short Dato;

const unsigned int PolModbus = 0xA001;
unsigned int CRC16;
unsigned short *ptrCRC16;

void interrupt(void){
 if(PIR1.F5==1){

 Dato = UART1_Read();

 if ((Dato==Hdr)&&(ir==0)){
 BanT = 1;
 Rspt[ir] = Dato;
 }
 if ((Dato!=Hdr)&&(ir==0)){
 ir=-1;
 }
 if ((BanT==1)&&(ir!=0)){
 Rspt[ir] = Dato;
 }

 ir++;
 if (ir==Rsize){
 BanP = 1;
 ir=0;
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

 TRISC5_bit = 0;
 TRISA0_bit = 1;
 TRISA1_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON.RBIF = 0;

 PIE1.RC1IE = 1;
 PIR1.F5 = 0;

 UART1_Init(9600);
 Delay_ms(100);

}

void main() {

 Configuracion();
 RC5_bit = 0;




 PDU[0]=0x01;
 PDU[1]=0x02;
 PDU[2]=0x03;
 PDU[3]=0x04;


 Ptcn[0]=0x01;
 Ptcn[1]=0x02;
 Ptcn[2]=0x03;
 Ptcn[3]=0x04;
 Ptcn[4]=0x05;
 Ptcn[5]=0x09;


 while (1){

 CRC16 = ModbusRTU_CRC16(PDU, 4);


 if (CRC16==0x2BA1){
 UART1_WRITE(0xAA);
 } else {
 UART1_WRITE(CRC16);
 }


 while(UART_Tx_Idle()==0);

 Delay_ms(20);

 }
}
