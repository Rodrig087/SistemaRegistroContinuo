
_ConfiguracionPrincipal:

;EsclavoComunicacionMultiple.c,71 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacionMultiple.c,73 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;EsclavoComunicacionMultiple.c,74 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;EsclavoComunicacionMultiple.c,76 :: 		TRISB3_bit = 0;                                   //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;EsclavoComunicacionMultiple.c,77 :: 		TRISB5_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;EsclavoComunicacionMultiple.c,78 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;EsclavoComunicacionMultiple.c,79 :: 		TRISB4_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;EsclavoComunicacionMultiple.c,80 :: 		TRISC4_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;EsclavoComunicacionMultiple.c,82 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;EsclavoComunicacionMultiple.c,83 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;EsclavoComunicacionMultiple.c,86 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;EsclavoComunicacionMultiple.c,87 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;EsclavoComunicacionMultiple.c,88 :: 		PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
	BSF         PIE3+0, 5 
;EsclavoComunicacionMultiple.c,89 :: 		PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR3+0, 5 
;EsclavoComunicacionMultiple.c,90 :: 		UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;EsclavoComunicacionMultiple.c,91 :: 		UART2_Init(19200);                                //Inicializa el UART2 a 9600 bps
	BSF         BAUDCON2+0, 3, 0
	CLRF        SPBRGH2+0 
	MOVLW       103
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;EsclavoComunicacionMultiple.c,94 :: 		T2CON = 0x78;                                     //Timer2 Output Postscaler Select bits
	MOVLW       120
	MOVWF       T2CON+0 
;EsclavoComunicacionMultiple.c,95 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;EsclavoComunicacionMultiple.c,96 :: 		PIR1.TMR2IF = 0;                                  //Limpia la bandera de interrupcion del TMR2
	BCF         PIR1+0, 1 
;EsclavoComunicacionMultiple.c,97 :: 		PIE1.TMR2IE = 1;                                  //Habilita la interrupción de desbordamiento TMR2
	BSF         PIE1+0, 1 
;EsclavoComunicacionMultiple.c,99 :: 		Delay_ms(100);                                    //Espera hasta que se estabilicen los cambios
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_ConfiguracionPrincipal0:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionPrincipal0
	NOP
;EsclavoComunicacionMultiple.c,101 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacionMultiple.c,107 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacionMultiple.c,110 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_CalcularCRC1:
	MOVF        FARG_CalcularCRC_tramaSize+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_CalcularCRC2
;EsclavoComunicacionMultiple.c,111 :: 		CRC16^=*trama ++;
	MOVFF       FARG_CalcularCRC_trama+0, FSR2
	MOVFF       FARG_CalcularCRC_trama+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_CalcularCRC_trama+0, 1 
	INCF        FARG_CalcularCRC_trama+1, 1 
;EsclavoComunicacionMultiple.c,112 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	CLRF        R2 
L_CalcularCRC4:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_CalcularCRC5
;EsclavoComunicacionMultiple.c,113 :: 		if(CRC16 & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_CalcularCRC7
;EsclavoComunicacionMultiple.c,114 :: 		CRC16 = (CRC16>>1)^POLMODBUS;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacionMultiple.c,116 :: 		CRC16>>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_CalcularCRC8:
;EsclavoComunicacionMultiple.c,112 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	INCF        R2, 1 
;EsclavoComunicacionMultiple.c,117 :: 		}
	GOTO        L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacionMultiple.c,110 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	DECF        FARG_CalcularCRC_tramaSize+0, 1 
;EsclavoComunicacionMultiple.c,118 :: 		}
	GOTO        L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacionMultiple.c,119 :: 		return CRC16;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;EsclavoComunicacionMultiple.c,120 :: 		}
L_end_CalcularCRC:
	RETURN      0
; end of _CalcularCRC

_VerificarCRC:

;EsclavoComunicacionMultiple.c,127 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacionMultiple.c,132 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        VerificarCRC_crcCalculado_L0+0 
	CLRF        VerificarCRC_crcCalculado_L0+1 
;EsclavoComunicacionMultiple.c,133 :: 		crcTrama = 1;
	MOVLW       1
	MOVWF       VerificarCRC_crcTrama_L0+0 
	MOVLW       0
	MOVWF       VerificarCRC_crcTrama_L0+1 
;EsclavoComunicacionMultiple.c,134 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        VerificarCRC_j_L0+0 
L_VerificarCRC9:
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	SUBWF       VerificarCRC_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_VerificarCRC10
;EsclavoComunicacionMultiple.c,135 :: 		pdu[j] = trama[j+1];
	MOVLW       VerificarCRC_pdu_L0+0
	MOVWF       FSR1 
	MOVLW       hi_addr(VerificarCRC_pdu_L0+0)
	MOVWF       FSR1H 
	MOVF        VerificarCRC_j_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        VerificarCRC_j_L0+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_VerificarCRC_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_VerificarCRC_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoComunicacionMultiple.c,134 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        VerificarCRC_j_L0+0, 1 
;EsclavoComunicacionMultiple.c,137 :: 		}
	GOTO        L_VerificarCRC9
L_VerificarCRC10:
;EsclavoComunicacionMultiple.c,138 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW       VerificarCRC_pdu_L0+0
	MOVWF       FARG_CalcularCRC_trama+0 
	MOVLW       hi_addr(VerificarCRC_pdu_L0+0)
	MOVWF       FARG_CalcularCRC_trama+1 
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	MOVWF       FARG_CalcularCRC_tramaSize+0 
	CALL        _CalcularCRC+0, 0
	MOVF        R0, 0 
	MOVWF       VerificarCRC_crcCalculado_L0+0 
	MOVF        R1, 0 
	MOVWF       VerificarCRC_crcCalculado_L0+1 
;EsclavoComunicacionMultiple.c,139 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW       VerificarCRC_crcTrama_L0+0
	MOVWF       VerificarCRC_ptrCRCTrama_L0+0 
	MOVLW       hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF       VerificarCRC_ptrCRCTrama_L0+1 
;EsclavoComunicacionMultiple.c,140 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW       2
	ADDWF       FARG_VerificarCRC_tramaPDUSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_VerificarCRC_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_VerificarCRC_trama+1, 0 
	MOVWF       FSR0H 
	MOVFF       VerificarCRC_ptrCRCTrama_L0+0, FSR1
	MOVFF       VerificarCRC_ptrCRCTrama_L0+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoComunicacionMultiple.c,141 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW       1
	ADDWF       VerificarCRC_ptrCRCTrama_L0+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      VerificarCRC_ptrCRCTrama_L0+1, 0 
	MOVWF       FSR1H 
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_VerificarCRC_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_VerificarCRC_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoComunicacionMultiple.c,142 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        VerificarCRC_crcCalculado_L0+1, 0 
	XORWF       VerificarCRC_crcTrama_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__VerificarCRC50
	MOVF        VerificarCRC_crcTrama_L0+0, 0 
	XORWF       VerificarCRC_crcCalculado_L0+0, 0 
L__VerificarCRC50:
	BTFSS       STATUS+0, 2 
	GOTO        L_VerificarCRC12
;EsclavoComunicacionMultiple.c,143 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_VerificarCRC
;EsclavoComunicacionMultiple.c,144 :: 		} else {
L_VerificarCRC12:
;EsclavoComunicacionMultiple.c,145 :: 		return 0;
	CLRF        R0 
;EsclavoComunicacionMultiple.c,147 :: 		}
L_end_VerificarCRC:
	RETURN      0
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacionMultiple.c,153 :: 		void EnviarACK(unsigned char puerto){
;EsclavoComunicacionMultiple.c,154 :: 		if (puerto==1){
	MOVF        FARG_EnviarACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK14
;EsclavoComunicacionMultiple.c,155 :: 		RE_DE = 1;                                     //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,156 :: 		UART1_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;EsclavoComunicacionMultiple.c,157 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK15:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK16
	GOTO        L_EnviarACK15
L_EnviarACK16:
;EsclavoComunicacionMultiple.c,158 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,159 :: 		} else {
	GOTO        L_EnviarACK17
L_EnviarACK14:
;EsclavoComunicacionMultiple.c,160 :: 		UART2_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       170
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;EsclavoComunicacionMultiple.c,161 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK18:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK19
	GOTO        L_EnviarACK18
L_EnviarACK19:
;EsclavoComunicacionMultiple.c,162 :: 		}
L_EnviarACK17:
;EsclavoComunicacionMultiple.c,163 :: 		}
L_end_EnviarACK:
	RETURN      0
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacionMultiple.c,169 :: 		void EnviarNACK(unsigned char puerto){
;EsclavoComunicacionMultiple.c,170 :: 		if (puerto==1){
	MOVF        FARG_EnviarNACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK20
;EsclavoComunicacionMultiple.c,171 :: 		RE_DE = 1;                                     //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,172 :: 		UART1_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       175
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;EsclavoComunicacionMultiple.c,173 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK21:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK22
	GOTO        L_EnviarNACK21
L_EnviarNACK22:
;EsclavoComunicacionMultiple.c,174 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,175 :: 		} else {
	GOTO        L_EnviarNACK23
L_EnviarNACK20:
;EsclavoComunicacionMultiple.c,176 :: 		UART2_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       175
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;EsclavoComunicacionMultiple.c,177 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK24:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK25
	GOTO        L_EnviarNACK24
L_EnviarNACK25:
;EsclavoComunicacionMultiple.c,178 :: 		}
L_EnviarNACK23:
;EsclavoComunicacionMultiple.c,179 :: 		}
L_end_EnviarNACK:
	RETURN      0
; end of _EnviarNACK

_EnviarSolicitudEsclavo:

;EsclavoComunicacionMultiple.c,185 :: 		void EnviarSolicitudEsclavo(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacionMultiple.c,187 :: 		RE_DE = 1;                                    //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,188 :: 		UART1_Write(0xB0);
	MOVLW       176
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;EsclavoComunicacionMultiple.c,189 :: 		for (j=0;j<tramaPDUSize;j++){
	CLRF        EnviarSolicitudEsclavo_j_L0+0 
L_EnviarSolicitudEsclavo26:
	MOVF        FARG_EnviarSolicitudEsclavo_tramaPDUSize+0, 0 
	SUBWF       EnviarSolicitudEsclavo_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarSolicitudEsclavo27
;EsclavoComunicacionMultiple.c,190 :: 		UART1_Write(trama[j+1]);
	MOVF        EnviarSolicitudEsclavo_j_L0+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_EnviarSolicitudEsclavo_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_EnviarSolicitudEsclavo_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;EsclavoComunicacionMultiple.c,189 :: 		for (j=0;j<tramaPDUSize;j++){
	INCF        EnviarSolicitudEsclavo_j_L0+0, 1 
;EsclavoComunicacionMultiple.c,191 :: 		}
	GOTO        L_EnviarSolicitudEsclavo26
L_EnviarSolicitudEsclavo27:
;EsclavoComunicacionMultiple.c,192 :: 		UART1_Write(0xB1);
	MOVLW       177
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;EsclavoComunicacionMultiple.c,193 :: 		while(UART1_Tx_Idle()==0);
L_EnviarSolicitudEsclavo29:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarSolicitudEsclavo30
	GOTO        L_EnviarSolicitudEsclavo29
L_EnviarSolicitudEsclavo30:
;EsclavoComunicacionMultiple.c,194 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,196 :: 		}
L_end_EnviarSolicitudEsclavo:
	RETURN      0
; end of _EnviarSolicitudEsclavo

_interrupt:

;EsclavoComunicacionMultiple.c,201 :: 		void interrupt(void){
;EsclavoComunicacionMultiple.c,208 :: 		if(PIR3.RC2IF ==1){
	BTFSS       PIR3+0, 5 
	GOTO        L_interrupt31
;EsclavoComunicacionMultiple.c,210 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF         RC4_bit+0, BitPos(RC4_bit+0) 
;EsclavoComunicacionMultiple.c,211 :: 		byteTrama = UART2_Read();                       //Lee el byte de la trama de peticion;
	CALL        _UART2_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _byteTrama+0 
;EsclavoComunicacionMultiple.c,214 :: 		if (banTI==0){                                  //Verifica que la bandera de inicio de trama este apagada
	MOVF        _banTI+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt32
;EsclavoComunicacionMultiple.c,215 :: 		if (byteTrama==HDR){                         //Verifica si recibio una cabecera
	MOVF        _byteTrama+0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt33
;EsclavoComunicacionMultiple.c,216 :: 		banTI = 1;                                //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;EsclavoComunicacionMultiple.c,217 :: 		i1 = 0;                                   //Define en 1 el subindice de la trama de peticion
	CLRF        _i1+0 
;EsclavoComunicacionMultiple.c,218 :: 		tramaOk = 9;                              //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW       9
	MOVWF       _tramaOk+0 
;EsclavoComunicacionMultiple.c,219 :: 		puertoTOT = 1;                            //Indica al Time-Out-Trama que de ser necesario envie el NACK por el puerto UART1
	MOVLW       1
	MOVWF       _puertoTOT+0 
;EsclavoComunicacionMultiple.c,221 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,222 :: 		PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;EsclavoComunicacionMultiple.c,223 :: 		}
L_interrupt33:
;EsclavoComunicacionMultiple.c,224 :: 		}
L_interrupt32:
;EsclavoComunicacionMultiple.c,228 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt34
;EsclavoComunicacionMultiple.c,229 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;EsclavoComunicacionMultiple.c,230 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,231 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _byteTrama+0, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt35
;EsclavoComunicacionMultiple.c,232 :: 		tramaSerial[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVLW       _tramaSerial+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaSerial+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _i1+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoComunicacionMultiple.c,233 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _i1+0, 1 
;EsclavoComunicacionMultiple.c,234 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;EsclavoComunicacionMultiple.c,235 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,236 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;EsclavoComunicacionMultiple.c,237 :: 		} else {
	GOTO        L_interrupt36
L_interrupt35:
;EsclavoComunicacionMultiple.c,238 :: 		tramaSerial[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVLW       _tramaSerial+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaSerial+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _i1+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoComunicacionMultiple.c,239 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _banTF+0 
;EsclavoComunicacionMultiple.c,240 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,241 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;EsclavoComunicacionMultiple.c,242 :: 		}
L_interrupt36:
;EsclavoComunicacionMultiple.c,243 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF        _banTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt37
;EsclavoComunicacionMultiple.c,244 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _banTI+0 
;EsclavoComunicacionMultiple.c,245 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _banTC+0 
;EsclavoComunicacionMultiple.c,246 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;EsclavoComunicacionMultiple.c,247 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,248 :: 		}
L_interrupt37:
;EsclavoComunicacionMultiple.c,249 :: 		}
L_interrupt34:
;EsclavoComunicacionMultiple.c,252 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF        _banTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt38
;EsclavoComunicacionMultiple.c,253 :: 		numDatosEsc = tramaSerial[4];
	MOVF        _tramaSerial+4, 0 
	MOVWF       _numDatosEsc+0 
;EsclavoComunicacionMultiple.c,254 :: 		sizeTramaPDU = numDatosEsc+4;                      //Calcula la longitud de la trama PDU sumando 4 al valor del campo #Datos
	MOVLW       4
	ADDWF       _tramaSerial+4, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sizeTramaPDU+0 
;EsclavoComunicacionMultiple.c,255 :: 		tramaOk = VerificarCRC(tramaSerial,sizeTramaPDU);  //Calcula y verifica el CRC de la trama de peticion
	MOVLW       _tramaSerial+0
	MOVWF       FARG_VerificarCRC_trama+0 
	MOVLW       hi_addr(_tramaSerial+0)
	MOVWF       FARG_VerificarCRC_trama+1 
	MOVF        R0, 0 
	MOVWF       FARG_VerificarCRC_tramaPDUSize+0 
	CALL        _VerificarCRC+0, 0
	MOVF        R0, 0 
	MOVWF       _tramaOk+0 
;EsclavoComunicacionMultiple.c,256 :: 		if (tramaOk==1){
	MOVF        R0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt39
;EsclavoComunicacionMultiple.c,258 :: 		EnviarACK(2);                            //Si la trama llego sin errores responde con un ACK al H/S
	MOVLW       2
	MOVWF       FARG_EnviarACK_puerto+0 
	CALL        _EnviarACK+0, 0
;EsclavoComunicacionMultiple.c,259 :: 		EnviarSolicitudEsclavo(tramaSerial,sizeTramaPDU);                //Envia la trama de peticion a los esclavos
	MOVLW       _tramaSerial+0
	MOVWF       FARG_EnviarSolicitudEsclavo_trama+0 
	MOVLW       hi_addr(_tramaSerial+0)
	MOVWF       FARG_EnviarSolicitudEsclavo_trama+1 
	MOVF        _sizeTramaPDU+0, 0 
	MOVWF       FARG_EnviarSolicitudEsclavo_tramaPDUSize+0 
	CALL        _EnviarSolicitudEsclavo+0, 0
;EsclavoComunicacionMultiple.c,260 :: 		} else if (tramaOk==0) {
	GOTO        L_interrupt40
L_interrupt39:
	MOVF        _tramaOk+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt41
;EsclavoComunicacionMultiple.c,261 :: 		EnviarNACK(2);                            //Si hubo algun error en la trama se envia un NACK al Master para que le reenvie la peticion
	MOVLW       2
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;EsclavoComunicacionMultiple.c,262 :: 		}
L_interrupt41:
L_interrupt40:
;EsclavoComunicacionMultiple.c,263 :: 		banTI = 0;                                    //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;EsclavoComunicacionMultiple.c,264 :: 		banTC = 0;                                    //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;EsclavoComunicacionMultiple.c,265 :: 		i1 = 0;                                       //Incializa el subindice de la trama de peticion
	CLRF        _i1+0 
;EsclavoComunicacionMultiple.c,266 :: 		}
L_interrupt38:
;EsclavoComunicacionMultiple.c,268 :: 		PIR3.RC2IF = 0;                                  //Limpia la bandera de interrupcion de UART1
	BCF         PIR3+0, 5 
;EsclavoComunicacionMultiple.c,269 :: 		IU1 = 0;                                         //Apaga el indicador de interrupcion por UART1
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;EsclavoComunicacionMultiple.c,271 :: 		}
L_interrupt31:
;EsclavoComunicacionMultiple.c,276 :: 		if (PIR1.RC1IF==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt42
;EsclavoComunicacionMultiple.c,278 :: 		IU2 = 1;                                        //Enciende el indicador de interrupcion por UART2
	BSF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoComunicacionMultiple.c,279 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _byteTrama+0 
;EsclavoComunicacionMultiple.c,284 :: 		PIR1.RC1IF = 0;                                    //Limpia la bandera de interrupcion de UART2
	BCF         PIR1+0, 5 
;EsclavoComunicacionMultiple.c,285 :: 		IU2 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoComunicacionMultiple.c,287 :: 		}
L_interrupt42:
;EsclavoComunicacionMultiple.c,295 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt43
;EsclavoComunicacionMultiple.c,296 :: 		TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;EsclavoComunicacionMultiple.c,297 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF         T2CON+0, 2 
;EsclavoComunicacionMultiple.c,298 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;EsclavoComunicacionMultiple.c,299 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF        _i1+0 
;EsclavoComunicacionMultiple.c,300 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF        _banTC+0 
;EsclavoComunicacionMultiple.c,301 :: 		if (puertoTOT==1){
	MOVF        _puertoTOT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt44
;EsclavoComunicacionMultiple.c,302 :: 		EnviarNACK(1);                              //Envia un NACK por el puerto UART1 para solicitar el reenvio de la trama
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;EsclavoComunicacionMultiple.c,303 :: 		} else if (puertoTOT==2) {
	GOTO        L_interrupt45
L_interrupt44:
	MOVF        _puertoTOT+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt46
;EsclavoComunicacionMultiple.c,304 :: 		EnviarNACK(2);                              //Envia un NACK por el puerto UART2 para solicitar el reenvio de la trama
	MOVLW       2
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;EsclavoComunicacionMultiple.c,305 :: 		}
L_interrupt46:
L_interrupt45:
;EsclavoComunicacionMultiple.c,306 :: 		puertoTOT = 0;                                  //Encera la variable para evitar confusiones
	CLRF        _puertoTOT+0 
;EsclavoComunicacionMultiple.c,307 :: 		}
L_interrupt43:
;EsclavoComunicacionMultiple.c,309 :: 		}
L_end_interrupt:
L__interrupt55:
	RETFIE      1
; end of _interrupt

_main:

;EsclavoComunicacionMultiple.c,313 :: 		void main() {
;EsclavoComunicacionMultiple.c,315 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;EsclavoComunicacionMultiple.c,317 :: 		RE_DE = 0;                                        //Establece el Max485-1 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;EsclavoComunicacionMultiple.c,318 :: 		ENABLE = 1;                                       //Enciende el modulo APC220
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoComunicacionMultiple.c,319 :: 		SET = 1;
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoComunicacionMultiple.c,320 :: 		i1=0;
	CLRF        _i1+0 
;EsclavoComunicacionMultiple.c,321 :: 		banTI=0;                                          //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;EsclavoComunicacionMultiple.c,322 :: 		banTC=0;                                          //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;EsclavoComunicacionMultiple.c,323 :: 		banTF=0;                                          //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;EsclavoComunicacionMultiple.c,324 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoComunicacionMultiple.c,326 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
