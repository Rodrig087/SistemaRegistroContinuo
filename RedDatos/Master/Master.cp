#line 1 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
#line 13 "E:/Milton/Github/RSA/InstrumentacionPresa/RedDatos/Master/Master.c"
const short Hdr = 0x3A;
const short End1 = 0x0D;
const short End2 = 0x0A;
const short Add = 0x01;
const short Fcn = 0x02;

const short PDUSize = 4;
const short Psize = 9;
const short Rsize = 9;

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

 UART1_Init(57600);
 Delay_ms(100);

}

void main() {

 Configuracion();
 RC5_bit = 0;

 ptrCRC16 = &CRC16;


 PDU[0]=Add;
 PDU[1]=Fcn;
 PDU[2]=0x03;
 PDU[3]=0x04;





 Ptcn[0]=Hdr;
 Ptcn[Psize-2]=End1;
 Ptcn[Psize-1]=End2;


 while (1){

 CRC16 = ModbusRTU_CRC16(PDU, PDUSize);
 Ptcn[6] = *ptrCRC16;
 Ptcn[5] = *(ptrCRC16+1);

 for (ip=1;ip<=4;ip++){
 Ptcn[ip] = PDU[ip-1];
 }

 for (ip=0;ip<Psize;ip++){
 UART1_WRITE(Ptcn[ip]);
 }
 while(UART_Tx_Idle()==0);

 Delay_ms(20);

 }
}
