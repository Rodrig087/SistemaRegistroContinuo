
_interrupt:

;Master.c,42 :: 		void interrupt(void){
;Master.c,43 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Master.c,45 :: 		Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Master.c,50 :: 		if (Dato==Hdr){
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Master.c,51 :: 		BanTI = 1;
	MOVLW       1
	MOVWF       _BanTI+0 
;Master.c,52 :: 		it = 0;
	CLRF        _it+0 
;Master.c,54 :: 		}
L_interrupt1:
;Master.c,56 :: 		if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _BanTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;Master.c,58 :: 		if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
	MOVF        _BanTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _Dato+0, 0 
	XORLW       10
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt39:
;Master.c,59 :: 		RSize = it+1;                             //Establece la longitud total de la trama de respuesta
	MOVF        _it+0, 0 
	ADDLW       1
	MOVWF       _Rsize+0 
;Master.c,60 :: 		BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _BanTI+0 
;Master.c,61 :: 		BanTC = 1;                                //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _BanTC+0 
;Master.c,62 :: 		}
L_interrupt5:
;Master.c,64 :: 		if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _Dato+0, 0 
	XORLW       13
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
;Master.c,65 :: 		Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,66 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Master.c,67 :: 		BanTF = 0;                                //Limpia la bandera de final de trama
	CLRF        _BanTF+0 
;Master.c,68 :: 		} else {
	GOTO        L_interrupt7
L_interrupt6:
;Master.c,69 :: 		Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,70 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Master.c,71 :: 		BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _BanTF+0 
;Master.c,72 :: 		}
L_interrupt7:
;Master.c,74 :: 		}
L_interrupt2:
;Master.c,76 :: 		PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,77 :: 		}
L_interrupt0:
;Master.c,78 :: 		}
L_end_interrupt:
L__interrupt42:
	RETFIE      1
; end of _interrupt

_ModbusRTU_CRC16:

;Master.c,82 :: 		unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
;Master.c,87 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_ModbusRTU_CRC168:
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__ModbusRTU_CRC1644
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+0, 0 
L__ModbusRTU_CRC1644:
	BTFSC       STATUS+0, 2 
	GOTO        L_ModbusRTU_CRC169
;Master.c,89 :: 		uiCRCResult ^= *ptucBuffer ++;
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+0, FSR2
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_ModbusRTU_CRC16_ptucBuffer+0, 1 
	INCF        FARG_ModbusRTU_CRC16_ptucBuffer+1, 1 
;Master.c,90 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	CLRF        R2 
L_ModbusRTU_CRC1611:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ModbusRTU_CRC1612
;Master.c,92 :: 		if(uiCRCResult & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_ModbusRTU_CRC1614
;Master.c,93 :: 		uiCRCResult =(uiCRCResult>>1)^PolModbus;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_ModbusRTU_CRC1615
L_ModbusRTU_CRC1614:
;Master.c,95 :: 		uiCRCResult >>= 1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_ModbusRTU_CRC1615:
;Master.c,90 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	INCF        R2, 1 
;Master.c,96 :: 		}
	GOTO        L_ModbusRTU_CRC1611
L_ModbusRTU_CRC1612:
;Master.c,87 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       1
	SUBWF       FARG_ModbusRTU_CRC16_uiLen+0, 1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
;Master.c,97 :: 		}
	GOTO        L_ModbusRTU_CRC168
L_ModbusRTU_CRC169:
;Master.c,98 :: 		return uiCRCResult;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Master.c,99 :: 		}
L_end_ModbusRTU_CRC16:
	RETURN      0
; end of _ModbusRTU_CRC16

_Configuracion:

;Master.c,102 :: 		void Configuracion(){
;Master.c,104 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Master.c,105 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Master.c,106 :: 		ANSELC = 0;                                       //Configura el PORTC como digital
	CLRF        ANSELC+0 
;Master.c,108 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Master.c,109 :: 		TRISC4_bit = 0;                                   //Configura el pin C4 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Master.c,110 :: 		TRISA0_bit = 1;
	BSF         TRISA0_bit+0, BitPos(TRISA0_bit+0) 
;Master.c,111 :: 		TRISA1_bit = 0;
	BCF         TRISA1_bit+0, BitPos(TRISA1_bit+0) 
;Master.c,113 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Master.c,114 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Master.c,115 :: 		INTCON.RBIF = 0;
	BCF         INTCON+0, 0 
;Master.c,117 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Master.c,118 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,120 :: 		UART1_Init(19200);                                //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Master.c,122 :: 		Delay_ms(10);                                     //Espera para que el modulo UART se estabilice
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_Configuracion16:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion16
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion16
	NOP
;Master.c,124 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Master.c,126 :: 		void main() {
;Master.c,128 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Master.c,130 :: 		BanTI = 0;                                                     //Inicializa las banderas de trama
	CLRF        _BanTI+0 
;Master.c,131 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Master.c,132 :: 		BanTF = 0;
	CLRF        _BanTF+0 
;Master.c,134 :: 		Bb = 0;                                                        //Inicializa la bandera del boton, es solo para el ejemplo del dispositivo maestro
	CLRF        _Bb+0 
;Master.c,137 :: 		RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,138 :: 		RC4_bit = 0;                                                   //Inicializa un indicador. No tiene relevancia para la ejecucion del programa
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Master.c,140 :: 		ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
	MOVLW       _CRC16+0
	MOVWF       _ptrCRC16+0 
	MOVLW       hi_addr(_CRC16+0)
	MOVWF       _ptrCRC16+1 
;Master.c,141 :: 		ptrCRCPDU = &CRCPDU;                                           //Asociacion del puntero CRCPDU
	MOVLW       _CRCPDU+0
	MOVWF       _ptrCRCPDU+0 
	MOVLW       hi_addr(_CRCPDU+0)
	MOVWF       _ptrCRCPDU+1 
;Master.c,143 :: 		Add = 0x01;                                                    //Direccion del esclavo a quien se realiza la peticion (Ejemplo)
	MOVLW       1
	MOVWF       _Add+0 
;Master.c,144 :: 		Fcn = 0x02;                                                    //Funcion solicitada al esclavo (Ejemplo)
	MOVLW       2
	MOVWF       _Fcn+0 
;Master.c,145 :: 		DataSize = 2;                                                  //Longitud del campo de datos de la trama de peticion
	MOVLW       2
	MOVWF       _DataSize+0 
;Master.c,147 :: 		Psize = DataSize+7;                                            //Longitu de la trama de peticion
	MOVLW       9
	MOVWF       _Psize+0 
;Master.c,154 :: 		Ptcn[0]=Hdr;
	MOVLW       58
	MOVWF       _Ptcn+0 
;Master.c,155 :: 		Ptcn[1]=Add;
	MOVLW       1
	MOVWF       _Ptcn+1 
;Master.c,156 :: 		Ptcn[2]=Fcn;
	MOVLW       2
	MOVWF       _Ptcn+2 
;Master.c,157 :: 		Ptcn[3]=0x03;
	MOVLW       3
	MOVWF       _Ptcn+3 
;Master.c,158 :: 		Ptcn[4]=0x04;
	MOVLW       4
	MOVWF       _Ptcn+4 
;Master.c,159 :: 		Ptcn[7]=End1;
	MOVLW       13
	MOVWF       _Ptcn+7 
;Master.c,160 :: 		Ptcn[8]=End2;
	MOVLW       10
	MOVWF       _Ptcn+8 
;Master.c,164 :: 		while (1){
L_main17:
;Master.c,167 :: 		if ((RA0_bit==0)&&(Bb==0)){
	BTFSC       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main21
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main21
L__main40:
;Master.c,168 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;Master.c,170 :: 		for (i=1;i<=(DataSize+2);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC
	MOVLW       1
	MOVWF       _i+0 
L_main22:
	MOVLW       2
	ADDWF       _DataSize+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	ADDWFC      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main47:
	BTFSS       STATUS+0, 0 
	GOTO        L_main23
;Master.c,171 :: 		PDU[i-1] = Ptcn[i];
	DECF        _i+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _PDU+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_PDU+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,170 :: 		for (i=1;i<=(DataSize+2);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC
	INCF        _i+0, 1 
;Master.c,172 :: 		}
	GOTO        L_main22
L_main23:
;Master.c,174 :: 		CRC16 = ModbusRTU_CRC16(PDU, DataSize+2);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       2
	ADDWF       _DataSize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	ADDWFC      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Master.c,175 :: 		Ptcn[6] = *ptrCRC16;                                 //Asigna el LSB del CRC al espacio 6 de la trama de peticion
	MOVFF       _ptrCRC16+0, FSR0
	MOVFF       _ptrCRC16+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _Ptcn+6 
;Master.c,176 :: 		Ptcn[5] = *(ptrCRC16+1);                             //Asigna el MSB del CRC al espacio 5 de la trama de peticion
	MOVLW       1
	ADDWF       _ptrCRC16+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _ptrCRC16+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _Ptcn+5 
;Master.c,178 :: 		RC5_bit = 1;                                         //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,179 :: 		for (i=0;i<Psize;i++){
	CLRF        _i+0 
L_main25:
	MOVF        _Psize+0, 0 
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main26
;Master.c,180 :: 		UART1_WRITE(Ptcn[i]);                            //Manda por Uart la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Master.c,179 :: 		for (i=0;i<Psize;i++){
	INCF        _i+0, 1 
;Master.c,181 :: 		}
	GOTO        L_main25
L_main26:
;Master.c,183 :: 		while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_main28:
	CALL        _UART_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main29
	GOTO        L_main28
L_main29:
;Master.c,184 :: 		RC5_bit = 0;                                         //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,186 :: 		} else if (RA0_bit==1){
	GOTO        L_main30
L_main21:
	BTFSS       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main31
;Master.c,187 :: 		Bb = 0;                                              //Esta rutina sirve para evitar rebotes en el boton
	CLRF        _Bb+0 
;Master.c,188 :: 		}
L_main31:
L_main30:
;Master.c,190 :: 		if (BanTC==1){                                          //Verifica que la bandera de trama completa este activa
	MOVF        _BanTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main32
;Master.c,192 :: 		if (Rspt[1]==Add){                                   //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado
	MOVF        _Rspt+1, 0 
	XORWF       _Add+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_main33
;Master.c,194 :: 		for (i=0;i<=(Rsize-5);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        _i+0 
L_main34:
	MOVLW       5
	SUBWF       _Rsize+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	SUBWFB      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main48
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main48:
	BTFSS       STATUS+0, 0 
	GOTO        L_main35
;Master.c,195 :: 		PDU[i] = Rspt[i+1];
	MOVLW       _PDU+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FSR1H 
	MOVF        _i+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _i+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,194 :: 		for (i=0;i<=(Rsize-5);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        _i+0, 1 
;Master.c,196 :: 		}
	GOTO        L_main34
L_main35:
;Master.c,198 :: 		CRC16 = ModbusRTU_CRC16(PDU, Rsize-5);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       5
	SUBWF       _Rsize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Master.c,199 :: 		*ptrCRCPDU = Rspt[Rsize-3];                       //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW       3
	SUBWF       _Rsize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVFF       _ptrCRCPDU+0, FSR1
	MOVFF       _ptrCRCPDU+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,200 :: 		*(ptrCRCPDU+1) = Rspt[Rsize-4];                   //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW       1
	ADDWF       _ptrCRCPDU+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrCRCPDU+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	SUBWF       _Rsize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,202 :: 		if (CRC16==CRCPDU) {                              //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        _CRC16+1, 0 
	XORWF       _CRCPDU+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main49
	MOVF        _CRCPDU+0, 0 
	XORWF       _CRC16+0, 0 
L__main49:
	BTFSS       STATUS+0, 2 
	GOTO        L_main37
;Master.c,206 :: 		RC4_bit = ~RC4_bit;                             //Indicador
	BTG         RC4_bit+0, BitPos(RC4_bit+0) 
;Master.c,208 :: 		}
L_main37:
;Master.c,210 :: 		}
L_main33:
;Master.c,212 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Master.c,214 :: 		}
L_main32:
;Master.c,216 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main38:
	DECFSZ      R13, 1, 1
	BRA         L_main38
	DECFSZ      R12, 1, 1
	BRA         L_main38
	NOP
;Master.c,218 :: 		}
	GOTO        L_main17
;Master.c,219 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
