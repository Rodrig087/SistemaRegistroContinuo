#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoSensorRS485/EsclavoSensor.c"
#line 28 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Esclavo/EsclavoSensorRS485/EsclavoSensor.c"
sbit AUX at RB3_bit;
sbit AUX_Direction at TRISB3_bit;
sbit RE_DE at RC1_bit;
sbit RE_DE_Direction at TRISC1_bit;
sbit ECINT at RC2_bit;
sbit ECINT_Direction at TRISC2_bit;

unsigned short idEsclavo;
const short HDR = 0xAA;
const short END = 0xFF;
const short funcEsclavo = 0x01;
const short regLectura = 0x04;
const short regEscritura = 0x03;


unsigned short byteTrama;
unsigned short banTI, banTC, banTF;
unsigned short i1;
unsigned char pduSolicitud[10];
unsigned short pduIdEsclavo;
unsigned short pduFuncion;
unsigned short pduRegistro;
unsigned short pduNumDatos;
unsigned char pduDatos[4];

unsigned int tiempoEspera;
unsigned char datosEscritura[10];
unsigned char resRS485[15];
unsigned short regEsc;
unsigned short numDatosEsc;
unsigned short i, x, j;
unsigned short respSPI, buffer, registro, numBytesSPI;
unsigned short banPet, banResp, banSPI, banLec, banId, banEsc;
unsigned short contDelay;










void ConfiguracionPrincipal(){

 ADCON1 = 0x07;

 TRISA0_bit = 1;
 TRISA1_bit = 1;
 TRISB0_bit = 1;
 TRISB3_bit = 0;
 TRISC1_bit = 0;
 TRISC2_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 UART1_Init(19200);
 PIE1.RCIE = 1;


 INTCON.INTE = 1;
 INTCON.INTF = 0;
 OPTION_REG.INTEDG = 1;

 Delay_ms(100);

}





void IdentificarEsclavo(){
 resRS485[0] = HDR;
 resRS485[1] = idEsclavo;
 resRS485[2] = funcEsclavo;
 resRS485[3] = regLectura;
 resRS485[4] = regEscritura;
 resRS485[5] = END;
 RE_DE = 1;
 for (x=0;x<6;x++){
 UART1_Write(resRS485[x]);
 while(UART1_Tx_Idle()==0);
 }
 RE_DE = 0;
}




void interrupt(){


 if (PIR1.RCIF==1){

 byteTrama = UART1_Read();

 if (banTI==0){
 if (bytetrama==0xB0){
 banTI = 1;
 i1 = 0;
 }
 }

 if (banTI==1){
 if (byteTrama!=0xB1){
 pduSolicitud[i1] = byteTrama;
 i1++;
 banTF = 0;
 } else {
 pduSolicitud[i1] = byteTrama;
 banTF = 1;
 T2CON.TMR2ON = 1;
 PR2 = 249;
 }
 if (banTF==1){
 banTI = 0;
 banTC = 1;
 PIR1.TMR2IF = 0;
 T2CON.TMR2ON = 0;
 }
 }


 if (banTC==1){
 pduIdEsclavo = pduSolicitud[1];
 if (pduIdEsclavo==idEsclavo){
 pduFuncion = pduSolicitud[2];
 pduRegistro = pduSolicitud[3];
 pduNumDatos = pduSolicitud[4];

 UART1_Write(0xAA);


 }

 banTI = 0;
 banTC = 0;
 i1 = 0;
 }

 PIR1.RCIF=0;

 }

}


void main() {

 ConfiguracionPrincipal();

 idEsclavo = 0x09;

 ECINT = 1;

 i1 = 0;
 x = 0;





}
