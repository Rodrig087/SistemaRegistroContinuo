
_interrupt:

;Esclavo.c,50 :: 		void interrupt(void){
;Esclavo.c,51 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Esclavo.c,53 :: 		Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Esclavo.c,58 :: 		if (Dato==Hdr){
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Esclavo.c,59 :: 		BanTI = 1;
	MOVLW       1
	MOVWF       _BanTI+0 
;Esclavo.c,60 :: 		it = 0;
	CLRF        _it+0 
;Esclavo.c,62 :: 		}
L_interrupt1:
;Esclavo.c,64 :: 		if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _BanTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;Esclavo.c,66 :: 		if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
	MOVF        _BanTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _Dato+0, 0 
	XORLW       10
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt50:
;Esclavo.c,67 :: 		PSize = it+1;                             //Establece la longitud total de la trama de peticion
	MOVF        _it+0, 0 
	ADDLW       1
	MOVWF       _Psize+0 
;Esclavo.c,68 :: 		BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _BanTI+0 
;Esclavo.c,69 :: 		BanTC = 1;                                //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _BanTC+0 
;Esclavo.c,70 :: 		}
L_interrupt5:
;Esclavo.c,72 :: 		if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _Dato+0, 0 
	XORLW       13
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
;Esclavo.c,73 :: 		Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,74 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Esclavo.c,75 :: 		BanTF = 0;                                //Limpia la bandera de final de trama
	CLRF        _BanTF+0 
;Esclavo.c,76 :: 		} else {
	GOTO        L_interrupt7
L_interrupt6:
;Esclavo.c,77 :: 		Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,78 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Esclavo.c,79 :: 		BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _BanTF+0 
;Esclavo.c,80 :: 		}
L_interrupt7:
;Esclavo.c,82 :: 		}
L_interrupt2:
;Esclavo.c,84 :: 		PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Esclavo.c,85 :: 		}
L_interrupt0:
;Esclavo.c,86 :: 		}
L_end_interrupt:
L__interrupt52:
	RETFIE      1
; end of _interrupt

_Responder:

;Esclavo.c,90 :: 		void Responder(unsigned int Reg){
;Esclavo.c,92 :: 		if (Reg==0x01){
	MOVLW       0
	XORWF       FARG_Responder_Reg+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Responder54
	MOVLW       1
	XORWF       FARG_Responder_Reg+0, 0 
L__Responder54:
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder8
;Esclavo.c,93 :: 		for (ir=4;ir>=3;ir--){
	MOVLW       4
	MOVWF       _ir+0 
L_Responder9:
	MOVLW       3
	SUBWF       _ir+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Responder10
;Esclavo.c,94 :: 		Rspt[ir]=(*chTemp++);                        //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _chTemp+0, FSR0
	MOVFF       _chTemp+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _chTemp+0, 1 
	INCF        _chTemp+1, 1 
;Esclavo.c,93 :: 		for (ir=4;ir>=3;ir--){
	DECF        _ir+0, 1 
;Esclavo.c,95 :: 		}
	GOTO        L_Responder9
L_Responder10:
;Esclavo.c,96 :: 		}
L_Responder8:
;Esclavo.c,98 :: 		if (Reg==0x02){
	MOVLW       0
	XORWF       FARG_Responder_Reg+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Responder55
	MOVLW       2
	XORWF       FARG_Responder_Reg+0, 0 
L__Responder55:
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder12
;Esclavo.c,99 :: 		for (ir=4;ir>=3;ir--){
	MOVLW       4
	MOVWF       _ir+0 
L_Responder13:
	MOVLW       3
	SUBWF       _ir+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Responder14
;Esclavo.c,100 :: 		Rspt[ir]=(*chHmd++);                         //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Humedad calculada
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _chHmd+0, FSR0
	MOVFF       _chHmd+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _chHmd+0, 1 
	INCF        _chHmd+1, 1 
;Esclavo.c,99 :: 		for (ir=4;ir>=3;ir--){
	DECF        _ir+0, 1 
;Esclavo.c,101 :: 		}
	GOTO        L_Responder13
L_Responder14:
;Esclavo.c,102 :: 		}
L_Responder12:
;Esclavo.c,104 :: 		Rspt[2]=Ptcn[2];                                    //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOVF        _Ptcn+2, 0 
	MOVWF       _Rspt+2 
;Esclavo.c,106 :: 		RC5_bit = 1;                                        //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,108 :: 		for (ir=0;ir<Rsize;ir++){
	CLRF        _ir+0 
L_Responder16:
	MOVF        _Rsize+0, 0 
	SUBWF       _ir+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_Responder17
;Esclavo.c,109 :: 		UART1_Write(Rspt[ir]);                          //Envia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _ir+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Esclavo.c,108 :: 		for (ir=0;ir<Rsize;ir++){
	INCF        _ir+0, 1 
;Esclavo.c,110 :: 		}
	GOTO        L_Responder16
L_Responder17:
;Esclavo.c,111 :: 		while(UART1_Tx_Idle()==0);                          //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_Responder19:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder20
	GOTO        L_Responder19
L_Responder20:
;Esclavo.c,113 :: 		RC5_bit = 0;                                        //Establece el Max485 en modo de lectura
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,115 :: 		for (ir=3;ir<5;ir++){
	MOVLW       3
	MOVWF       _ir+0 
L_Responder21:
	MOVLW       5
	SUBWF       _ir+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_Responder22
;Esclavo.c,116 :: 		Rspt[ir]=0;;                                    //Limpia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;Esclavo.c,115 :: 		for (ir=3;ir<5;ir++){
	INCF        _ir+0, 1 
;Esclavo.c,117 :: 		}
	GOTO        L_Responder21
L_Responder22:
;Esclavo.c,119 :: 		}
L_end_Responder:
	RETURN      0
; end of _Responder

_ModbusRTU_CRC16:

;Esclavo.c,122 :: 		unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
;Esclavo.c,126 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_ModbusRTU_CRC1624:
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__ModbusRTU_CRC1657
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+0, 0 
L__ModbusRTU_CRC1657:
	BTFSC       STATUS+0, 2 
	GOTO        L_ModbusRTU_CRC1625
;Esclavo.c,128 :: 		uiCRCResult ^=*ptucBuffer ++;
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+0, FSR2
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_ModbusRTU_CRC16_ptucBuffer+0, 1 
	INCF        FARG_ModbusRTU_CRC16_ptucBuffer+1, 1 
;Esclavo.c,129 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	CLRF        R2 
L_ModbusRTU_CRC1627:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ModbusRTU_CRC1628
;Esclavo.c,131 :: 		if(uiCRCResult & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_ModbusRTU_CRC1630
;Esclavo.c,132 :: 		uiCRCResult =( uiCRCResult >>1)^PolModbus;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_ModbusRTU_CRC1631
L_ModbusRTU_CRC1630:
;Esclavo.c,134 :: 		uiCRCResult >>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_ModbusRTU_CRC1631:
;Esclavo.c,129 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	INCF        R2, 1 
;Esclavo.c,135 :: 		}
	GOTO        L_ModbusRTU_CRC1627
L_ModbusRTU_CRC1628:
;Esclavo.c,126 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       1
	SUBWF       FARG_ModbusRTU_CRC16_uiLen+0, 1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
;Esclavo.c,136 :: 		}
	GOTO        L_ModbusRTU_CRC1624
L_ModbusRTU_CRC1625:
;Esclavo.c,137 :: 		return uiCRCResult;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Esclavo.c,138 :: 		}
L_end_ModbusRTU_CRC16:
	RETURN      0
; end of _ModbusRTU_CRC16

_Configuracion:

;Esclavo.c,142 :: 		void Configuracion(){
;Esclavo.c,144 :: 		ANSELA = 0;                                       //Configura PORTA como digital
	CLRF        ANSELA+0 
;Esclavo.c,145 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Esclavo.c,146 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Esclavo.c,148 :: 		TRISA = 1;                                        //Configura el puerto A como entrada
	MOVLW       1
	MOVWF       TRISA+0 
;Esclavo.c,149 :: 		TRISC4_bit = 0;                                   //Configura el pin C4 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Esclavo.c,150 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Esclavo.c,151 :: 		TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
	BSF         TRISC0_bit+0, BitPos(TRISC0_bit+0) 
;Esclavo.c,152 :: 		TRISC1_bit = 1;                                   //Configura el pin C1 como entrada
	BSF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;Esclavo.c,155 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Esclavo.c,156 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Esclavo.c,158 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Esclavo.c,159 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Esclavo.c,161 :: 		UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Esclavo.c,162 :: 		Delay_ms(10);                                     //Espera para que el modulo UART se estabilice
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_Configuracion32:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion32
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion32
	NOP
;Esclavo.c,164 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Esclavo.c,167 :: 		void main() {
;Esclavo.c,169 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Esclavo.c,171 :: 		BanTI = 0;                                               //Inicializa las banderas de trama
	CLRF        _BanTI+0 
;Esclavo.c,172 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Esclavo.c,173 :: 		BanTF = 0;
	CLRF        _BanTF+0 
;Esclavo.c,175 :: 		RC5_bit = 0;                                             //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,176 :: 		RC4_bit = 0;
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Esclavo.c,178 :: 		CRC16 = 0;                                               //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        _CRC16+0 
	CLRF        _CRC16+1 
;Esclavo.c,179 :: 		CRCPDU = 1;
	MOVLW       1
	MOVWF       _CRCPDU+0 
	MOVLW       0
	MOVWF       _CRCPDU+1 
;Esclavo.c,181 :: 		ptrCRC16 = &CRC16;                                       //Asociacion del puntero CRC16
	MOVLW       _CRC16+0
	MOVWF       _ptrCRC16+0 
	MOVLW       hi_addr(_CRC16+0)
	MOVWF       _ptrCRC16+1 
;Esclavo.c,182 :: 		ptrCRCPDU = &CRCPDU;                                     //Asociacion del puntero CRCPDU
	MOVLW       _CRCPDU+0
	MOVWF       _ptrCRCPDU+0 
	MOVLW       hi_addr(_CRCPDU+0)
	MOVWF       _ptrCRCPDU+1 
;Esclavo.c,184 :: 		Add = 0x01;                                              //Direccion del esclavo a quien se realiza la peticion (Ejemplo)
	MOVLW       1
	MOVWF       _Add+0 
;Esclavo.c,185 :: 		Fcn = 0x02;                                              //Funcion solicitada al esclavo (Ejemplo)
	MOVLW       2
	MOVWF       _Fcn+0 
;Esclavo.c,186 :: 		DataSize = 2;
	MOVLW       2
	MOVWF       _DataSize+0 
;Esclavo.c,187 :: 		Rsize = Datasize + 7;
	MOVLW       9
	MOVWF       _Rsize+0 
;Esclavo.c,194 :: 		Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOVLW       58
	MOVWF       _Rspt+0 
;Esclavo.c,195 :: 		Rspt[1] = Add;                                           //Se rellena el segundo byte de la trama de repuesta con la Add del sensor
	MOVLW       1
	MOVWF       _Rspt+1 
;Esclavo.c,196 :: 		Rspt[7] = End1;                                          //Se rellena el penultimo byte de la trama de repuesta con el primer byte del delimitador de final de trama
	MOVLW       13
	MOVWF       _Rspt+7 
;Esclavo.c,197 :: 		Rspt[8] = End2;                                          //Se rellena el penultimo byte de la trama de repuesta con el segundo byte del delimitador de final de trama
	MOVLW       10
	MOVWF       _Rspt+8 
;Esclavo.c,199 :: 		while (1){
L_main33:
;Esclavo.c,201 :: 		if (BanTC==1){                                     //Verifica si se realizo una peticion comprobando el estado de la bandera de trama completa
	MOVF        _BanTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main35
;Esclavo.c,203 :: 		if (Ptcn[1]==Add){                              //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado
	MOVF        _Ptcn+1, 0 
	XORWF       _Add+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_main36
;Esclavo.c,205 :: 		for (i=0;i<=(Psize-5);i++){                 //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        _i+0 
L_main37:
	MOVLW       5
	SUBWF       _Psize+0, 0 
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
	GOTO        L__main60
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main60:
	BTFSS       STATUS+0, 0 
	GOTO        L_main38
;Esclavo.c,206 :: 		PDU[i] = Ptcn[i+1];
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
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,205 :: 		for (i=0;i<=(Psize-5);i++){                 //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        _i+0, 1 
;Esclavo.c,207 :: 		}
	GOTO        L_main37
L_main38:
;Esclavo.c,209 :: 		CRC16 = ModbusRTU_CRC16(PDU, Psize-5);      //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       5
	SUBWF       _Psize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Esclavo.c,210 :: 		*ptrCRCPDU = Ptcn[Psize-3];                 //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW       3
	SUBWF       _Psize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVFF       _ptrCRCPDU+0, FSR1
	MOVFF       _ptrCRCPDU+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,211 :: 		*(ptrCRCPDU+1) = Ptcn[Psize-4];             //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW       1
	ADDWF       _ptrCRCPDU+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrCRCPDU+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	SUBWF       _Psize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,213 :: 		if (CRC16==CRCPDU) {                        //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        _CRC16+1, 0 
	XORWF       _CRCPDU+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main61
	MOVF        _CRCPDU+0, 0 
	XORWF       _CRC16+0, 0 
L__main61:
	BTFSS       STATUS+0, 2 
	GOTO        L_main40
;Esclavo.c,218 :: 		Rspt[2] = Ptcn[2];                       //Rellena el campo de funcion con la funcion requerida en la trama de peticion
	MOVF        _Ptcn+2, 0 
	MOVWF       _Rspt+2 
;Esclavo.c,219 :: 		Rspt[3] = 0xAA;                          //Rellena el campo de datos con los valores 0xAAFF
	MOVLW       170
	MOVWF       _Rspt+3 
;Esclavo.c,220 :: 		Rspt[4] = 0xFF;
	MOVLW       255
	MOVWF       _Rspt+4 
;Esclavo.c,222 :: 		for (i=1;i<=(DataSize+2);i++){           //Rellena la trama de PDU con los datos de interes de la trama de respuesta
	MOVLW       1
	MOVWF       _i+0 
L_main41:
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
	GOTO        L__main62
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main62:
	BTFSS       STATUS+0, 0 
	GOTO        L_main42
;Esclavo.c,223 :: 		PDU[i-1] = Rspt[i];
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
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,222 :: 		for (i=1;i<=(DataSize+2);i++){           //Rellena la trama de PDU con los datos de interes de la trama de respuesta
	INCF        _i+0, 1 
;Esclavo.c,224 :: 		}
	GOTO        L_main41
L_main42:
;Esclavo.c,226 :: 		CRC16 = ModbusRTU_CRC16(PDU, 4);         //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       4
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	MOVLW       0
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Esclavo.c,227 :: 		Rspt[6] = *ptrCRC16;                     //CRC_LSB
	MOVFF       _ptrCRC16+0, FSR0
	MOVFF       _ptrCRC16+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _Rspt+6 
;Esclavo.c,228 :: 		Rspt[5] = *(ptrCRC16+1);                 //CRC_MSB
	MOVLW       1
	ADDWF       _ptrCRC16+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _ptrCRC16+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _Rspt+5 
;Esclavo.c,230 :: 		for (i=0;i<=8;i++){
	CLRF        _i+0 
L_main44:
	MOVF        _i+0, 0 
	SUBLW       8
	BTFSS       STATUS+0, 0 
	GOTO        L_main45
;Esclavo.c,231 :: 		UART1_Write(Rspt[i]);                //Envia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Esclavo.c,230 :: 		for (i=0;i<=8;i++){
	INCF        _i+0, 1 
;Esclavo.c,232 :: 		}
	GOTO        L_main44
L_main45:
;Esclavo.c,233 :: 		while(UART1_Tx_Idle()==0);
L_main47:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main48
	GOTO        L_main47
L_main48:
;Esclavo.c,235 :: 		}
L_main40:
;Esclavo.c,236 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Esclavo.c,237 :: 		}
L_main36:
;Esclavo.c,239 :: 		BanTC = 0;                                      //Limpia la bandera de trama completa
	CLRF        _BanTC+0 
;Esclavo.c,241 :: 		}
L_main35:
;Esclavo.c,243 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main49:
	DECFSZ      R13, 1, 1
	BRA         L_main49
	DECFSZ      R12, 1, 1
	BRA         L_main49
	NOP
;Esclavo.c,246 :: 		}
	GOTO        L_main33
;Esclavo.c,248 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
