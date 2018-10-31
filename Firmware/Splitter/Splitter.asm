
_ConfiguracionPrincipal:

;Splitter.c,65 :: 		void ConfiguracionPrincipal(){
;Splitter.c,67 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Splitter.c,68 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Splitter.c,70 :: 		TRISB5_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;Splitter.c,71 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Splitter.c,72 :: 		TRISB4_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;Splitter.c,73 :: 		TRISC4_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Splitter.c,75 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Splitter.c,76 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Splitter.c,79 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Splitter.c,80 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,81 :: 		PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
	BSF         PIE3+0, 5 
;Splitter.c,82 :: 		PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR3+0, 5 
;Splitter.c,83 :: 		UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Splitter.c,84 :: 		UART2_Init(19200);                                //Inicializa el UART2 a 9600 bps
	BSF         BAUDCON2+0, 3, 0
	CLRF        SPBRGH2+0 
	MOVLW       103
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;Splitter.c,87 :: 		T1CON = 0x30;
	MOVLW       48
	MOVWF       T1CON+0 
;Splitter.c,88 :: 		TMR1IF_bit = 0;
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Splitter.c,89 :: 		TMR1H = 0x0B;
	MOVLW       11
	MOVWF       TMR1H+0 
;Splitter.c,90 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;Splitter.c,91 :: 		TMR1IE_bit = 1;
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;Splitter.c,94 :: 		T2CON = 0x78;
	MOVLW       120
	MOVWF       T2CON+0 
;Splitter.c,95 :: 		TMR2IF_bit = 0;
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;Splitter.c,96 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;Splitter.c,97 :: 		TMR2IE_bit	= 1;
	BSF         TMR2IE_bit+0, BitPos(TMR2IE_bit+0) 
;Splitter.c,99 :: 		Delay_ms(100);                                    //Espera hasta que se estabilicen los cambios
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
;Splitter.c,101 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_CalcularCRC:

;Splitter.c,107 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;Splitter.c,110 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_CalcularCRC1:
	MOVF        FARG_CalcularCRC_tramaSize+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_CalcularCRC2
;Splitter.c,111 :: 		CRC16 ^=*trama ++;
	MOVFF       FARG_CalcularCRC_trama+0, FSR2
	MOVFF       FARG_CalcularCRC_trama+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_CalcularCRC_trama+0, 1 
	INCF        FARG_CalcularCRC_trama+1, 1 
;Splitter.c,112 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF        R2 
L_CalcularCRC4:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_CalcularCRC5
;Splitter.c,113 :: 		if(CRC16 & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_CalcularCRC7
;Splitter.c,114 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_CalcularCRC8
L_CalcularCRC7:
;Splitter.c,116 :: 		CRC16>>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_CalcularCRC8:
;Splitter.c,112 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF        R2, 1 
;Splitter.c,117 :: 		}
	GOTO        L_CalcularCRC4
L_CalcularCRC5:
;Splitter.c,110 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF        FARG_CalcularCRC_tramaSize+0, 1 
;Splitter.c,118 :: 		}
	GOTO        L_CalcularCRC1
L_CalcularCRC2:
;Splitter.c,119 :: 		return CRC16;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Splitter.c,120 :: 		}
L_end_CalcularCRC:
	RETURN      0
; end of _CalcularCRC

_VerificarCRC:

;Splitter.c,127 :: 		unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;Splitter.c,132 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        VerificarCRC_crcCalculado_L0+0 
	CLRF        VerificarCRC_crcCalculado_L0+1 
;Splitter.c,133 :: 		crcTrama = 1;
	MOVLW       1
	MOVWF       VerificarCRC_crcTrama_L0+0 
	MOVLW       0
	MOVWF       VerificarCRC_crcTrama_L0+1 
;Splitter.c,134 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        VerificarCRC_j_L0+0 
L_VerificarCRC9:
	MOVF        VerificarCRC_j_L0+0, 0 
	SUBWF       FARG_VerificarCRC_tramaPDUSize+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_VerificarCRC10
;Splitter.c,135 :: 		pdu[j] = trama[j+1];
	MOVF        VerificarCRC_j_L0+0, 0 
	ADDWF       VerificarCRC_pdu_L0+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      VerificarCRC_pdu_L0+1, 0 
	MOVWF       FSR1H 
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
;Splitter.c,134 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        VerificarCRC_j_L0+0, 1 
;Splitter.c,136 :: 		}
	GOTO        L_VerificarCRC9
L_VerificarCRC10:
;Splitter.c,137 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVF        VerificarCRC_pdu_L0+0, 0 
	MOVWF       FARG_CalcularCRC_trama+0 
	MOVF        VerificarCRC_pdu_L0+1, 0 
	MOVWF       FARG_CalcularCRC_trama+1 
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	MOVWF       FARG_CalcularCRC_tramaSize+0 
	CALL        _CalcularCRC+0, 0
	MOVF        R0, 0 
	MOVWF       VerificarCRC_crcCalculado_L0+0 
	MOVF        R1, 0 
	MOVWF       VerificarCRC_crcCalculado_L0+1 
;Splitter.c,138 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW       VerificarCRC_crcTrama_L0+0
	MOVWF       VerificarCRC_ptrCRCTrama_L0+0 
	MOVLW       hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF       VerificarCRC_ptrCRCTrama_L0+1 
;Splitter.c,139 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;Splitter.c,140 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;Splitter.c,141 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        VerificarCRC_crcCalculado_L0+1, 0 
	XORWF       VerificarCRC_crcTrama_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__VerificarCRC100
	MOVF        VerificarCRC_crcTrama_L0+0, 0 
	XORWF       VerificarCRC_crcCalculado_L0+0, 0 
L__VerificarCRC100:
	BTFSS       STATUS+0, 2 
	GOTO        L_VerificarCRC12
;Splitter.c,142 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	GOTO        L_end_VerificarCRC
;Splitter.c,143 :: 		} else {
L_VerificarCRC12:
;Splitter.c,144 :: 		return 0;
	CLRF        R0 
	CLRF        R1 
;Splitter.c,146 :: 		}
L_end_VerificarCRC:
	RETURN      0
; end of _VerificarCRC

_EnviarACK:

;Splitter.c,152 :: 		void EnviarACK(unsigned char puerto){
;Splitter.c,154 :: 		if (puerto==1){
	MOVF        FARG_EnviarACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK14
;Splitter.c,155 :: 		RE_DE = 1;                                     //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,156 :: 		UART1_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,157 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK15:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK16
	GOTO        L_EnviarACK15
L_EnviarACK16:
;Splitter.c,158 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,159 :: 		} else {
	GOTO        L_EnviarACK17
L_EnviarACK14:
;Splitter.c,160 :: 		UART2_Write(ACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       170
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,161 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK18:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK19
	GOTO        L_EnviarACK18
L_EnviarACK19:
;Splitter.c,162 :: 		}
L_EnviarACK17:
;Splitter.c,163 :: 		}
L_end_EnviarACK:
	RETURN      0
; end of _EnviarACK

_EnviarNACK:

;Splitter.c,169 :: 		void EnviarNACK(unsigned char puerto){
;Splitter.c,171 :: 		if (puerto==1){
	MOVF        FARG_EnviarNACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK20
;Splitter.c,172 :: 		RE_DE = 1;                                     //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,173 :: 		UART1_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       175
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,174 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK21:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK22
	GOTO        L_EnviarNACK21
L_EnviarNACK22:
;Splitter.c,175 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,176 :: 		} else {
	GOTO        L_EnviarNACK23
L_EnviarNACK20:
;Splitter.c,177 :: 		UART2_Write(NACK);                             //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       175
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,178 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK24:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK25
	GOTO        L_EnviarNACK24
L_EnviarNACK25:
;Splitter.c,179 :: 		}
L_EnviarNACK23:
;Splitter.c,180 :: 		}
L_end_EnviarNACK:
	RETURN      0
; end of _EnviarNACK

_RenviarTrama:

;Splitter.c,186 :: 		void RenviarTrama(unsigned char puerto, unsigned char *trama, unsigned char numDatos){
;Splitter.c,188 :: 		if (puerto==1){
	MOVF        FARG_RenviarTrama_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_RenviarTrama26
;Splitter.c,189 :: 		RE_DE = 1;                                     //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,190 :: 		for (i=0;i<(numDatos);i++){
	CLRF        RenviarTrama_i_L0+0 
L_RenviarTrama27:
	MOVF        FARG_RenviarTrama_numDatos+0, 0 
	SUBWF       RenviarTrama_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_RenviarTrama28
;Splitter.c,191 :: 		UART1_Write(trama[i]);                     //Reenvia la trama de peticion a travez del UART1
	MOVF        RenviarTrama_i_L0+0, 0 
	ADDWF       FARG_RenviarTrama_trama+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_RenviarTrama_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,190 :: 		for (i=0;i<(numDatos);i++){
	INCF        RenviarTrama_i_L0+0, 1 
;Splitter.c,192 :: 		}
	GOTO        L_RenviarTrama27
L_RenviarTrama28:
;Splitter.c,193 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_RenviarTrama30:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_RenviarTrama31
	GOTO        L_RenviarTrama30
L_RenviarTrama31:
;Splitter.c,194 :: 		RE_DE = 0;                                     //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,195 :: 		} else {
	GOTO        L_RenviarTrama32
L_RenviarTrama26:
;Splitter.c,196 :: 		for (i=0;i<(numDatos);i++){
	CLRF        RenviarTrama_i_L0+0 
L_RenviarTrama33:
	MOVF        FARG_RenviarTrama_numDatos+0, 0 
	SUBWF       RenviarTrama_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_RenviarTrama34
;Splitter.c,197 :: 		UART2_Write(trama[i]);                     //Reenvia la trama de peticion a travez del UART2
	MOVF        RenviarTrama_i_L0+0, 0 
	ADDWF       FARG_RenviarTrama_trama+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_RenviarTrama_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,196 :: 		for (i=0;i<(numDatos);i++){
	INCF        RenviarTrama_i_L0+0, 1 
;Splitter.c,198 :: 		}
	GOTO        L_RenviarTrama33
L_RenviarTrama34:
;Splitter.c,199 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_RenviarTrama36:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_RenviarTrama37
	GOTO        L_RenviarTrama36
L_RenviarTrama37:
;Splitter.c,200 :: 		}
L_RenviarTrama32:
;Splitter.c,204 :: 		}
L_end_RenviarTrama:
	RETURN      0
; end of _RenviarTrama

_EnviarMensajeRS485:

;Splitter.c,210 :: 		void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
;Splitter.c,214 :: 		CRCPDU = CalcularCRC(PDU, sizePDU);           //Calcula el CRC de la trama PDU
	MOVF        FARG_EnviarMensajeRS485_PDU+0, 0 
	MOVWF       FARG_CalcularCRC_trama+0 
	MOVF        FARG_EnviarMensajeRS485_PDU+1, 0 
	MOVWF       FARG_CalcularCRC_trama+1 
	MOVF        FARG_EnviarMensajeRS485_sizePDU+0, 0 
	MOVWF       FARG_CalcularCRC_tramaSize+0 
	CALL        _CalcularCRC+0, 0
	MOVF        R0, 0 
	MOVWF       EnviarMensajeRS485_CRCPDU_L0+0 
	MOVF        R1, 0 
	MOVWF       EnviarMensajeRS485_CRCPDU_L0+1 
;Splitter.c,215 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW       EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+0 
	MOVLW       hi_addr(EnviarMensajeRS485_CRCPDU_L0+0)
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+1 
;Splitter.c,217 :: 		tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
	MOVLW       58
	MOVWF       _tramaRS485+0 
;Splitter.c,218 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVLW       2
	ADDWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _tramaRS485+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVFF       EnviarMensajeRS485_ptrCRCPDU_L0+0, FSR0
	MOVFF       EnviarMensajeRS485_ptrCRCPDU_L0+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,219 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	MOVF        FARG_EnviarMensajeRS485_sizePDU+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _tramaRS485+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       1
	ADDWF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      EnviarMensajeRS485_ptrCRCPDU_L0+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,220 :: 		tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
	MOVLW       3
	ADDWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _tramaRS485+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       13
	MOVWF       POSTINC1+0 
;Splitter.c,221 :: 		tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
	MOVLW       4
	ADDWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _tramaRS485+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       10
	MOVWF       POSTINC1+0 
;Splitter.c,222 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,223 :: 		for (i=0;i<(sizePDU+5);i++){
	CLRF        EnviarMensajeRS485_i_L0+0 
L_EnviarMensajeRS48538:
	MOVLW       5
	ADDWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	ADDWFC      R2, 1 
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__EnviarMensajeRS485105
	MOVF        R1, 0 
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
L__EnviarMensajeRS485105:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48539
;Splitter.c,224 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW       1
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48543
	MOVF        EnviarMensajeRS485_i_L0+0, 0 
	SUBWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48543
L__EnviarMensajeRS48594:
;Splitter.c,225 :: 		UART1_Write(PDU[i-1]);                      //Envia el contenido de la trama PDU a travez del UART1
	DECF        EnviarMensajeRS485_i_L0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_EnviarMensajeRS485_PDU+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_EnviarMensajeRS485_PDU+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,226 :: 		} else {
	GOTO        L_EnviarMensajeRS48544
L_EnviarMensajeRS48543:
;Splitter.c,227 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVLW       _tramaRS485+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FSR0H 
	MOVF        EnviarMensajeRS485_i_L0+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,228 :: 		}
L_EnviarMensajeRS48544:
;Splitter.c,223 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF        EnviarMensajeRS485_i_L0+0, 1 
;Splitter.c,229 :: 		}
	GOTO        L_EnviarMensajeRS48538
L_EnviarMensajeRS48539:
;Splitter.c,230 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48545:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarMensajeRS48546
	GOTO        L_EnviarMensajeRS48545
L_EnviarMensajeRS48546:
;Splitter.c,231 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,233 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF         T1CON+0, 0 
;Splitter.c,234 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Splitter.c,235 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW       11
	MOVWF       TMR1H+0 
;Splitter.c,236 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;Splitter.c,237 :: 		}
L_end_EnviarMensajeRS485:
	RETURN      0
; end of _EnviarMensajeRS485

_ConfiguracionAPC220:

;Splitter.c,244 :: 		void ConfiguracionAPC220(unsigned char *trama, unsigned char tramaSize){
;Splitter.c,246 :: 		unsigned short k=0;
	CLRF        ConfiguracionAPC220_k_L0+0 
;Splitter.c,247 :: 		unsigned short datosSize = tramaSize-8;
	MOVLW       8
	SUBWF       FARG_ConfiguracionAPC220_tramaSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVF        R0, 0 
	MOVWF       ConfiguracionAPC220_datosSize_L0+0 
;Splitter.c,248 :: 		while (k<=datosSize){
L_ConfiguracionAPC22047:
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	SUBWF       ConfiguracionAPC220_datosSize_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_ConfiguracionAPC22048
;Splitter.c,249 :: 		datos[k] = trama[k+3]+0x30;                    //Rellena la trama de datos en formato ASCII
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	ADDWF       ConfiguracionAPC220_datos_L0+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      ConfiguracionAPC220_datos_L0+1, 0 
	MOVWF       FSR1H 
	MOVLW       3
	ADDWF       ConfiguracionAPC220_k_L0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_ConfiguracionAPC220_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_ConfiguracionAPC220_trama+1, 0 
	MOVWF       FSR0H 
	MOVLW       48
	ADDWF       POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,250 :: 		k++;
	INCF        ConfiguracionAPC220_k_L0+0, 1 
;Splitter.c,251 :: 		if (k==6||k==8||k==10||k==12||k==14){
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L__ConfiguracionAPC22095
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L__ConfiguracionAPC22095
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L__ConfiguracionAPC22095
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	XORLW       12
	BTFSC       STATUS+0, 2 
	GOTO        L__ConfiguracionAPC22095
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	XORLW       14
	BTFSC       STATUS+0, 2 
	GOTO        L__ConfiguracionAPC22095
	GOTO        L_ConfiguracionAPC22051
L__ConfiguracionAPC22095:
;Splitter.c,252 :: 		datos[k] = 0x20;                            //Coloca un codigo de espacio para dividir los datos
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	ADDWF       ConfiguracionAPC220_datos_L0+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      ConfiguracionAPC220_datos_L0+1, 0 
	MOVWF       FSR1H 
	MOVLW       32
	MOVWF       POSTINC1+0 
;Splitter.c,253 :: 		k++;
	INCF        ConfiguracionAPC220_k_L0+0, 1 
;Splitter.c,254 :: 		}
L_ConfiguracionAPC22051:
;Splitter.c,255 :: 		}
	GOTO        L_ConfiguracionAPC22047
L_ConfiguracionAPC22048:
;Splitter.c,256 :: 		SET = 0;                                           //Establece el modulo APC en modo configuracion
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;Splitter.c,257 :: 		UART2_Init(9600);                                  //Establece la velocidad del puerto UART2 en 9600 para realizar la configuracion
	BSF         BAUDCON2+0, 3, 0
	CLRF        SPBRGH2+0 
	MOVLW       207
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;Splitter.c,258 :: 		Delay_ms(5);                                       //Espera hasta que se estabilicen el modulo APC
	MOVLW       13
	MOVWF       R12, 0
	MOVLW       251
	MOVWF       R13, 0
L_ConfiguracionAPC22052:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionAPC22052
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionAPC22052
	NOP
	NOP
;Splitter.c,259 :: 		UART2_Write(0x57);                                 //Envia el comando WR para iniciar la configuracion
	MOVLW       87
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,260 :: 		UART2_Write(0x52);
	MOVLW       82
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,261 :: 		UART2_Write(0x20);
	MOVLW       32
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,262 :: 		for (k=0;k<(datosSize);k++){
	CLRF        ConfiguracionAPC220_k_L0+0 
L_ConfiguracionAPC22053:
	MOVF        ConfiguracionAPC220_datosSize_L0+0, 0 
	SUBWF       ConfiguracionAPC220_k_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ConfiguracionAPC22054
;Splitter.c,263 :: 		UART2_Write(datos[k]);                         //Envia la trama de configuracion al modulo APC
	MOVF        ConfiguracionAPC220_k_L0+0, 0 
	ADDWF       ConfiguracionAPC220_datos_L0+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      ConfiguracionAPC220_datos_L0+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,262 :: 		for (k=0;k<(datosSize);k++){
	INCF        ConfiguracionAPC220_k_L0+0, 1 
;Splitter.c,264 :: 		}
	GOTO        L_ConfiguracionAPC22053
L_ConfiguracionAPC22054:
;Splitter.c,265 :: 		UART2_Write(0x0D);                                 //Envia el delimitador de final de trama
	MOVLW       13
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,266 :: 		UART2_Write(0x0A);
	MOVLW       10
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,267 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_ConfiguracionAPC22056:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_ConfiguracionAPC22057
	GOTO        L_ConfiguracionAPC22056
L_ConfiguracionAPC22057:
;Splitter.c,268 :: 		Delay_ms(200);                                     //Espera hasta que el modulo procese la configuracion
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       8
	MOVWF       R12, 0
	MOVLW       119
	MOVWF       R13, 0
L_ConfiguracionAPC22058:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionAPC22058
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionAPC22058
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionAPC22058
;Splitter.c,271 :: 		Delay_ms(5);
	MOVLW       13
	MOVWF       R12, 0
	MOVLW       251
	MOVWF       R13, 0
L_ConfiguracionAPC22059:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionAPC22059
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionAPC22059
	NOP
	NOP
;Splitter.c,272 :: 		SET = 1;                                           //Establece el modulo APC en modo de funcionamiento normal
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;Splitter.c,273 :: 		UART2_Init(19200);                                 //Vuelve a fijar la velocidad del puerto UART2 en 19200
	BSF         BAUDCON2+0, 3, 0
	CLRF        SPBRGH2+0 
	MOVLW       103
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;Splitter.c,274 :: 		Delay_ms(100);                                     //Espera hasta que el puerto UART se estabilice
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_ConfiguracionAPC22060:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionAPC22060
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionAPC22060
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionAPC22060
	NOP
;Splitter.c,275 :: 		RenviarTrama(1,trama,tramaSize);                   //Reenvia la trama de peticion al Master paraindicar que la solicitud se ha procesado correctamente
	MOVLW       1
	MOVWF       FARG_RenviarTrama_puerto+0 
	MOVF        FARG_ConfiguracionAPC220_trama+0, 0 
	MOVWF       FARG_RenviarTrama_trama+0 
	MOVF        FARG_ConfiguracionAPC220_trama+1, 0 
	MOVWF       FARG_RenviarTrama_trama+1 
	MOVF        FARG_ConfiguracionAPC220_tramaSize+0, 0 
	MOVWF       FARG_RenviarTrama_numDatos+0 
	CALL        _RenviarTrama+0, 0
;Splitter.c,276 :: 		}
L_end_ConfiguracionAPC220:
	RETURN      0
; end of _ConfiguracionAPC220

_interrupt:

;Splitter.c,282 :: 		void interrupt(void){
;Splitter.c,290 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt61
;Splitter.c,292 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF         RC4_bit+0, BitPos(RC4_bit+0) 
;Splitter.c,293 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _byteTrama+0 
;Splitter.c,296 :: 		if (banTI==0){                                  //Verifica que la bandera de inicio de trama este apagada
	MOVF        _banTI+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt62
;Splitter.c,297 :: 		if (byteTrama==HDR){                        //Verifica si recibio una cabecera
	MOVF        _byteTrama+0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt63
;Splitter.c,298 :: 		tramaRS485[0]=byteTrama;                  //Guarda el primer byte de la trama en la primera posicion de la trama de peticion
	MOVF        _byteTrama+0, 0 
	MOVWF       _tramaRS485+0 
;Splitter.c,299 :: 		banTI = 1;                                //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;Splitter.c,300 :: 		i1 = 1;                                   //Define en 1 el subindice de la trama de peticion
	MOVLW       1
	MOVWF       _i1+0 
;Splitter.c,301 :: 		tramaOk = 0;                              //Limpia la variable que indica si la trama ha llegado correctamente
	CLRF        _tramaOk+0 
;Splitter.c,302 :: 		puertoTOT = 1;                            //Indica al Time-Out-Trama que de ser necesario envie el NACK por el puerto UART1
	MOVLW       1
	MOVWF       _puertoTOT+0 
;Splitter.c,304 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF         T2CON+0, 2 
;Splitter.c,305 :: 		PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;Splitter.c,306 :: 		}
L_interrupt63:
;Splitter.c,307 :: 		if (byteTrama==ACK){                         //Verifica si recibio un ACK
	MOVF        _byteTrama+0, 0 
	XORLW       170
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt64
;Splitter.c,309 :: 		T1CON.TMR1ON = 0;                         //Apaga el Timer1
	BCF         T1CON+0, 0 
;Splitter.c,310 :: 		TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Splitter.c,311 :: 		}
L_interrupt64:
;Splitter.c,312 :: 		if (byteTrama==NACK){                        //Verifica si recibio un NACK
	MOVF        _byteTrama+0, 0 
	XORLW       175
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt65
;Splitter.c,314 :: 		T1CON.TMR1ON = 0;                         //Apaga el Timer1
	BCF         T1CON+0, 0 
;Splitter.c,315 :: 		TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Splitter.c,316 :: 		if (contadorNACK<3){
	MOVLW       3
	SUBWF       _contadorNACK+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt66
;Splitter.c,317 :: 		EnviarMensajeRS485(tramaRS485,sizeTramaPDU);
	MOVLW       _tramaRS485+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        _sizeTramaPDU+0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;Splitter.c,318 :: 		contadorNACK++;                        //Incrrmenta en una unidad el valor del contador de NACK
	INCF        _contadorNACK+0, 1 
;Splitter.c,319 :: 		} else {
	GOTO        L_interrupt67
L_interrupt66:
;Splitter.c,320 :: 		contadorNACK = 0;                      //Solo puede resetear el contador de NACK por que no puede comunicarse con el dispositivo jerarquico superior (Master) para notificarle el error
	CLRF        _contadorNACK+0 
;Splitter.c,321 :: 		}
L_interrupt67:
;Splitter.c,322 :: 		}
L_interrupt65:
;Splitter.c,323 :: 		}
L_interrupt62:
;Splitter.c,327 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt68
;Splitter.c,328 :: 		T2CON.TMR2ON = 0;                            //Detiene el Time-Out-Trama
	BCF         T2CON+0, 2 
;Splitter.c,329 :: 		if (i1==1){
	MOVF        _i1+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt69
;Splitter.c,330 :: 		tramaRS485[i1] = byteTrama;               //Guarda el byte de Direccion en la segunda posicion del vector de peticion
	MOVLW       _tramaRS485+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _i1+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,331 :: 		i1 = 2;                                   //Incrementa el subindice de la trama de peticion en una unidad
	MOVLW       2
	MOVWF       _i1+0 
;Splitter.c,332 :: 		T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
	BSF         T2CON+0, 2 
;Splitter.c,333 :: 		PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;Splitter.c,334 :: 		} else if (i1=2){
	GOTO        L_interrupt70
L_interrupt69:
	MOVLW       2
	MOVWF       _i1+0 
;Splitter.c,335 :: 		tramaRS485[i1] = byteTrama;               //Guarda el byte de #Datos en la tercera posicion del vector de peticion
	MOVLW       _tramaRS485+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _i1+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,336 :: 		t1Size = byteTrama;                       //Guarda en la variable t1Size el valor del campo #Datos, este campo tiene informacion de la longitud de la trama PDU
	MOVF        _byteTrama+0, 0 
	MOVWF       _t1Size+0 
;Splitter.c,337 :: 		i1 = 3;                                   //Incrementa el subindice de la trama de peticion en una unidad
	MOVLW       3
	MOVWF       _i1+0 
;Splitter.c,338 :: 		T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
	BSF         T2CON+0, 2 
;Splitter.c,339 :: 		PR2 = 249;                                //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;Splitter.c,349 :: 		}
L_interrupt72:
L_interrupt70:
;Splitter.c,350 :: 		}
L_interrupt68:
;Splitter.c,353 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF        _banTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt77
;Splitter.c,354 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion
	MOVLW       _tramaRS485+0
	MOVWF       FARG_VerificarCRC_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_VerificarCRC_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_VerificarCRC_tramaPDUSize+0 
	CALL        _VerificarCRC+0, 0
	MOVF        R0, 0 
	MOVWF       _tramaOk+0 
;Splitter.c,358 :: 		if (tramaOk==1){
	MOVF        R0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt78
;Splitter.c,359 :: 		EnviarACK(1);                            //Invoca a la funcion EnviarACK() para notificar al remitente que la trama llego sin errores
	MOVLW       1
	MOVWF       FARG_EnviarACK_puerto+0 
	CALL        _EnviarACK+0, 0
;Splitter.c,360 :: 		if (tramaRS485[1]==DIR){                 //Verifica si la direccion es FFh para comprobar si se trata de una solicitud de sincronizacion.
	MOVF        _tramaRS485+1, 0 
	XORLW       253
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt79
;Splitter.c,361 :: 		if (tramaRS485[3]==0x01){             //Verifica el campo de Funcion para ver si se trata de una sincronizacion de segundos
	MOVF        _tramaRS485+3, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt80
;Splitter.c,363 :: 		} else if (tramaRS485[3]==0x02){      //Verifica el campo de Funcion para ver si se trata de una solicitud de sincronizacion de fecha y hora
	GOTO        L_interrupt81
L_interrupt80:
	MOVF        _tramaRS485+3, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt82
;Splitter.c,365 :: 		} else if (tramaRS485[3]==0x03){      //Verifica el campo de Funcion para ver si se trata de una solicitud de configuracion del APC220
	GOTO        L_interrupt83
L_interrupt82:
	MOVF        _tramaRS485+3, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt84
;Splitter.c,366 :: 		ConfiguracionAPC220(tramaRS485,t1Size);//Invoca a la funcion para realizar la configuracion del modulo APC con los parametros especificados en la trama
	MOVLW       _tramaRS485+0
	MOVWF       FARG_ConfiguracionAPC220_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_ConfiguracionAPC220_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_ConfiguracionAPC220_tramaSize+0 
	CALL        _ConfiguracionAPC220+0, 0
;Splitter.c,367 :: 		} else {
	GOTO        L_interrupt85
L_interrupt84:
;Splitter.c,369 :: 		tramaPDU[1]=0xFF;
	MOVLW       255
	MOVWF       _tramaPDU+1 
;Splitter.c,370 :: 		tramaPDU[2]=0x04;                   //Establece en 10 el numero de elementos de la trama de respuesta de error
	MOVLW       4
	MOVWF       _tramaPDU+2 
;Splitter.c,371 :: 		tramaPDU[3]=0xEE;                   //Cambia el campo de funcion por el codigo 0xEE para
	MOVLW       238
	MOVWF       _tramaPDU+3 
;Splitter.c,372 :: 		tramaPDU[4]=0xE1;                   //Codigo de error para funcion no disponible
	MOVLW       225
	MOVWF       _tramaPDU+4 
;Splitter.c,373 :: 		sizeTramaPDU = tramaPDU[2];         //Guarda en la variable sizeTramaPDU el valor del campo #Datos de la trama PDU
	MOVLW       4
	MOVWF       _sizeTramaPDU+0 
;Splitter.c,374 :: 		EnviarMensajeRS485(tramaRS485,sizeTramaPDU);   //Invoca a la funcion de Error pasandole como parametros el puerto, la Direccion y el tipo de error
	MOVLW       _tramaRS485+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVLW       4
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;Splitter.c,375 :: 		}
L_interrupt85:
L_interrupt83:
L_interrupt81:
;Splitter.c,376 :: 		} else {                                  //Si la direccion es diferente de FFh renvia la trama de peticion por el puerto UART2
	GOTO        L_interrupt86
L_interrupt79:
;Splitter.c,377 :: 		RenviarTrama(2,tramaRS485,t1Size);        //Invoca la funcion para renviar la trama por el puerto UART2
	MOVLW       2
	MOVWF       FARG_RenviarTrama_puerto+0 
	MOVLW       _tramaRS485+0
	MOVWF       FARG_RenviarTrama_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_RenviarTrama_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_RenviarTrama_numDatos+0 
	CALL        _RenviarTrama+0, 0
;Splitter.c,378 :: 		}
L_interrupt86:
;Splitter.c,379 :: 		}
L_interrupt78:
;Splitter.c,381 :: 		banTC = 0;                                    //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;Splitter.c,382 :: 		i1 = 0;                                       //Incializa el subindice de la trama de peticion
	CLRF        _i1+0 
;Splitter.c,384 :: 		}
L_interrupt77:
;Splitter.c,386 :: 		PIR1.F5 = 0;                                     //Limpia la bandera de interrupcion de UART1
	BCF         PIR1+0, 5 
;Splitter.c,387 :: 		IU1 = 0;                                         //Apaga el indicador de interrupcion por UART1
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Splitter.c,389 :: 		}
L_interrupt61:
;Splitter.c,484 :: 		if (TMR1IF_bit==1){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt87
;Splitter.c,485 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Splitter.c,486 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF         T1CON+0, 0 
;Splitter.c,487 :: 		if (contadorTOD<3){
	MOVLW       3
	SUBWF       _contadorTOD+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt88
;Splitter.c,488 :: 		EnviarMensajeRS485(tramaPDU, sizeTramaPDU);  //Reenvia la trama por el bus RS485
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        _sizeTramaPDU+0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;Splitter.c,489 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF        _contadorTOD+0, 1 
;Splitter.c,490 :: 		} else {
	GOTO        L_interrupt89
L_interrupt88:
;Splitter.c,492 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;Splitter.c,493 :: 		}
L_interrupt89:
;Splitter.c,494 :: 		}
L_interrupt87:
;Splitter.c,501 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt90
;Splitter.c,502 :: 		TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;Splitter.c,503 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF         T2CON+0, 2 
;Splitter.c,504 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;Splitter.c,505 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF        _i1+0 
;Splitter.c,506 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF        _banTC+0 
;Splitter.c,507 :: 		if (puertoTOT==1){
	MOVF        _puertoTOT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt91
;Splitter.c,508 :: 		EnviarNACK(1);                              //Envia un NACK por el puerto UART1 para solicitar el reenvio de la trama
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;Splitter.c,509 :: 		} else if (puertoTOT==2) {
	GOTO        L_interrupt92
L_interrupt91:
	MOVF        _puertoTOT+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt93
;Splitter.c,510 :: 		EnviarNACK(2);                              //Envia un NACK por el puerto UART2 para solicitar el reenvio de la trama
	MOVLW       2
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;Splitter.c,511 :: 		}
L_interrupt93:
L_interrupt92:
;Splitter.c,512 :: 		puertoTOT = 0;                                  //Encera la variable para evitar confusiones
	CLRF        _puertoTOT+0 
;Splitter.c,513 :: 		}
L_interrupt90:
;Splitter.c,515 :: 		}
L_end_interrupt:
L__interrupt108:
	RETFIE      1
; end of _interrupt

_main:

;Splitter.c,519 :: 		void main() {
;Splitter.c,521 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;Splitter.c,522 :: 		RE_DE = 0;                                        //Establece el Max485-1 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,523 :: 		ENABLE = 1;                                       //Enciende el modulo APC220
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;Splitter.c,524 :: 		SET = 1;
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;Splitter.c,525 :: 		i1=0;
	CLRF        _i1+0 
;Splitter.c,526 :: 		i2=0;
	CLRF        _i2+0 
;Splitter.c,527 :: 		contadorTOD = 0;                                  //Inicia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;Splitter.c,528 :: 		contadorNACK = 0;                                 //Inicia el contador de NACK
	CLRF        _contadorNACK+0 
;Splitter.c,530 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
