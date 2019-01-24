
_ConfiguracionPrincipal:

;CPComunicacion.c,73 :: 		void ConfiguracionPrincipal(){
;CPComunicacion.c,75 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;CPComunicacion.c,76 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;CPComunicacion.c,78 :: 		TRISB1_bit = 1;                                    //Configura el pin B1 como entrada
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;CPComunicacion.c,79 :: 		TRISB3_bit = 0;                                    //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;CPComunicacion.c,80 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;CPComunicacion.c,81 :: 		TRISC1_bit = 0;                                    //Configura el pin C1 como salida
	BCF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;CPComunicacion.c,82 :: 		TRISC2_bit = 0;                                    //Configura el pin C2 como salida
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;CPComunicacion.c,84 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;CPComunicacion.c,85 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;CPComunicacion.c,88 :: 		PIE1.RC1IE = 1;                                    //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;CPComunicacion.c,89 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;CPComunicacion.c,92 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	CLRF        FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	MOVLW       1
	MOVWF       FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;CPComunicacion.c,93 :: 		PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;CPComunicacion.c,96 :: 		T1CON = 0x30;                                      //Timer1 Input Clock Prescale Select bits
	MOVLW       48
	MOVWF       T1CON+0 
;CPComunicacion.c,97 :: 		TMR1H = 0x0B;
	MOVLW       11
	MOVWF       TMR1H+0 
;CPComunicacion.c,98 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;CPComunicacion.c,99 :: 		PIR1.TMR1IF = 0;                                   //Limpia la bandera de interrupcion del TMR1
	BCF         PIR1+0, 0 
;CPComunicacion.c,100 :: 		PIE1.TMR1IE = 1;                                   //Habilita la interrupción de desbordamiento TMR1
	BSF         PIE1+0, 0 
;CPComunicacion.c,103 :: 		T2CON = 0x78;                                      //Timer2 Output Postscaler Select bits
	MOVLW       120
	MOVWF       T2CON+0 
;CPComunicacion.c,104 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,105 :: 		PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,106 :: 		PIE1.TMR2IE = 1;                                   //Habilita la interrupción de desbordamiento TMR2
	BSF         PIE1+0, 1 
;CPComunicacion.c,108 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;CPComunicacion.c,110 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_CalcularCRC:

;CPComunicacion.c,116 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;CPComunicacion.c,119 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_CalcularCRC1:
	MOVF        FARG_CalcularCRC_tramaSize+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_CalcularCRC2
;CPComunicacion.c,120 :: 		CRC16^=*trama ++;
	MOVFF       FARG_CalcularCRC_trama+0, FSR2
	MOVFF       FARG_CalcularCRC_trama+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_CalcularCRC_trama+0, 1 
	INCF        FARG_CalcularCRC_trama+1, 1 
;CPComunicacion.c,121 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	CLRF        R2 
L_CalcularCRC4:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_CalcularCRC5
;CPComunicacion.c,122 :: 		if(CRC16 & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_CalcularCRC7
;CPComunicacion.c,123 :: 		CRC16 = (CRC16>>1)^POLMODBUS;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_CalcularCRC8
L_CalcularCRC7:
;CPComunicacion.c,125 :: 		CRC16>>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_CalcularCRC8:
;CPComunicacion.c,121 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	INCF        R2, 1 
;CPComunicacion.c,126 :: 		}
	GOTO        L_CalcularCRC4
L_CalcularCRC5:
;CPComunicacion.c,119 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	DECF        FARG_CalcularCRC_tramaSize+0, 1 
;CPComunicacion.c,127 :: 		}
	GOTO        L_CalcularCRC1
L_CalcularCRC2:
;CPComunicacion.c,128 :: 		return CRC16;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;CPComunicacion.c,129 :: 		}
L_end_CalcularCRC:
	RETURN      0
; end of _CalcularCRC

_VerificarCRC:

;CPComunicacion.c,136 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;CPComunicacion.c,141 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        VerificarCRC_crcCalculado_L0+0 
	CLRF        VerificarCRC_crcCalculado_L0+1 
;CPComunicacion.c,142 :: 		crcTrama = 1;
	MOVLW       1
	MOVWF       VerificarCRC_crcTrama_L0+0 
	MOVLW       0
	MOVWF       VerificarCRC_crcTrama_L0+1 
;CPComunicacion.c,143 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        VerificarCRC_j_L0+0 
L_VerificarCRC9:
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	SUBWF       VerificarCRC_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_VerificarCRC10
;CPComunicacion.c,144 :: 		pdu[j] = trama[j+1];
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
;CPComunicacion.c,143 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        VerificarCRC_j_L0+0, 1 
;CPComunicacion.c,145 :: 		}
	GOTO        L_VerificarCRC9
L_VerificarCRC10:
;CPComunicacion.c,146 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
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
;CPComunicacion.c,147 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW       VerificarCRC_crcTrama_L0+0
	MOVWF       VerificarCRC_ptrCRCTrama_L0+0 
	MOVLW       hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF       VerificarCRC_ptrCRCTrama_L0+1 
;CPComunicacion.c,148 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;CPComunicacion.c,149 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;CPComunicacion.c,150 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        VerificarCRC_crcCalculado_L0+1, 0 
	XORWF       VerificarCRC_crcTrama_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__VerificarCRC97
	MOVF        VerificarCRC_crcTrama_L0+0, 0 
	XORWF       VerificarCRC_crcCalculado_L0+0, 0 
L__VerificarCRC97:
	BTFSS       STATUS+0, 2 
	GOTO        L_VerificarCRC12
;CPComunicacion.c,151 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_VerificarCRC
;CPComunicacion.c,152 :: 		} else {
L_VerificarCRC12:
;CPComunicacion.c,153 :: 		return 0;
	CLRF        R0 
;CPComunicacion.c,155 :: 		}
L_end_VerificarCRC:
	RETURN      0
; end of _VerificarCRC

_EnviarACK:

;CPComunicacion.c,161 :: 		void EnviarACK(unsigned char puerto){
;CPComunicacion.c,162 :: 		if (puerto==1){
	MOVF        FARG_EnviarACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK14
;CPComunicacion.c,163 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,164 :: 		UART1_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,165 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK15:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK16
	GOTO        L_EnviarACK15
L_EnviarACK16:
;CPComunicacion.c,166 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,167 :: 		} else {
	GOTO        L_EnviarACK17
L_EnviarACK14:
;CPComunicacion.c,168 :: 		UART2_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       170
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,169 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK18:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK19
	GOTO        L_EnviarACK18
L_EnviarACK19:
;CPComunicacion.c,170 :: 		}
L_EnviarACK17:
;CPComunicacion.c,171 :: 		}
L_end_EnviarACK:
	RETURN      0
; end of _EnviarACK

_EnviarNACK:

;CPComunicacion.c,177 :: 		void EnviarNACK(unsigned char puerto){
;CPComunicacion.c,178 :: 		if (puerto==1){
	MOVF        FARG_EnviarNACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK20
;CPComunicacion.c,179 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,180 :: 		UART1_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       175
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,181 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK21:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK22
	GOTO        L_EnviarNACK21
L_EnviarNACK22:
;CPComunicacion.c,182 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,183 :: 		} else {
	GOTO        L_EnviarNACK23
L_EnviarNACK20:
;CPComunicacion.c,184 :: 		UART2_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       175
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,185 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK24:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK25
	GOTO        L_EnviarNACK24
L_EnviarNACK25:
;CPComunicacion.c,186 :: 		}
L_EnviarNACK23:
;CPComunicacion.c,187 :: 		}
L_end_EnviarNACK:
	RETURN      0
; end of _EnviarNACK

_EnviarMensajeRS485:

;CPComunicacion.c,193 :: 		void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
;CPComunicacion.c,197 :: 		CRCPDU = CalcularCRC(PDU, sizePDU);                //Calcula el CRC de la trama PDU
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
;CPComunicacion.c,198 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW       EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+0 
	MOVLW       hi_addr(EnviarMensajeRS485_CRCPDU_L0+0)
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+1 
;CPComunicacion.c,200 :: 		tramaRS485[0] = HDR;                               //Añade la cabecera a la trama a enviar
	MOVLW       58
	MOVWF       _tramaRS485+0 
;CPComunicacion.c,201 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;CPComunicacion.c,202 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;CPComunicacion.c,203 :: 		tramaRS485[sizePDU+3] = END1;                      //Añade el primer delimitador de final de trama
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
;CPComunicacion.c,204 :: 		tramaRS485[sizePDU+4] = END2;                      //Añade el segundo delimitador de final de trama
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
;CPComunicacion.c,205 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,206 :: 		for (i=0;i<(sizePDU+5);i++){
	CLRF        EnviarMensajeRS485_i_L0+0 
L_EnviarMensajeRS48526:
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
	GOTO        L__EnviarMensajeRS485101
	MOVF        R1, 0 
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
L__EnviarMensajeRS485101:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48527
;CPComunicacion.c,207 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW       1
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
	MOVF        EnviarMensajeRS485_i_L0+0, 0 
	SUBWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
L__EnviarMensajeRS48585:
;CPComunicacion.c,209 :: 		UART1_Write(PDU[i-1]);                      //Envia el contenido de la trama PDU a travez del UART1
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
;CPComunicacion.c,210 :: 		} else {
	GOTO        L_EnviarMensajeRS48532
L_EnviarMensajeRS48531:
;CPComunicacion.c,211 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
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
;CPComunicacion.c,212 :: 		}
L_EnviarMensajeRS48532:
;CPComunicacion.c,206 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF        EnviarMensajeRS485_i_L0+0, 1 
;CPComunicacion.c,213 :: 		}
	GOTO        L_EnviarMensajeRS48526
L_EnviarMensajeRS48527:
;CPComunicacion.c,214 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48533:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarMensajeRS48534
	GOTO        L_EnviarMensajeRS48533
L_EnviarMensajeRS48534:
;CPComunicacion.c,215 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,217 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF         T1CON+0, 0 
;CPComunicacion.c,218 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,219 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW       11
	MOVWF       TMR1H+0 
;CPComunicacion.c,220 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;CPComunicacion.c,221 :: 		}
L_end_EnviarMensajeRS485:
	RETURN      0
; end of _EnviarMensajeRS485

_EnviarMensajeSPI:

;CPComunicacion.c,228 :: 		void EnviarMensajeSPI(unsigned char *trama, unsigned char pduSize2){
;CPComunicacion.c,230 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        EnviarMensajeSPI_j_L0+0 
L_EnviarMensajeSPI35:
	MOVF        FARG_EnviarMensajeSPI_pduSize2+0, 0 
	SUBWF       EnviarMensajeSPI_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeSPI36
;CPComunicacion.c,231 :: 		pduSPI[j] = trama[j+1];
	MOVLW       _pduSPI+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR1H 
	MOVF        EnviarMensajeSPI_j_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        EnviarMensajeSPI_j_L0+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_EnviarMensajeSPI_trama+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_EnviarMensajeSPI_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;CPComunicacion.c,232 :: 		UART1_Write(pduSPI[j]);
	MOVLW       _pduSPI+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR0H 
	MOVF        EnviarMensajeSPI_j_L0+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,230 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        EnviarMensajeSPI_j_L0+0, 1 
;CPComunicacion.c,233 :: 		}
	GOTO        L_EnviarMensajeSPI35
L_EnviarMensajeSPI36:
;CPComunicacion.c,234 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,235 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_EnviarMensajeSPI38:
	DECFSZ      R13, 1, 1
	BRA         L_EnviarMensajeSPI38
	DECFSZ      R12, 1, 1
	BRA         L_EnviarMensajeSPI38
	NOP
	NOP
;CPComunicacion.c,236 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,237 :: 		}
L_end_EnviarMensajeSPI:
	RETURN      0
; end of _EnviarMensajeSPI

_EnviarErrorSPI:

;CPComunicacion.c,243 :: 		void EnviarErrorSPI(unsigned char *trama, unsigned short codigoError){
;CPComunicacion.c,244 :: 		pduSPI[0] = trama[0];                              //Guarda el identificador de la trama PDU de peticion
	MOVFF       FARG_EnviarErrorSPI_trama+0, FSR0
	MOVFF       FARG_EnviarErrorSPI_trama+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _pduSPI+0 
;CPComunicacion.c,245 :: 		pduSPI[1] = 0xEE;                                  //Agrega el codigo 0xEE para indicar que se trata de un mensaje de error
	MOVLW       238
	MOVWF       _pduSPI+1 
;CPComunicacion.c,246 :: 		pduSPI[2] = trama[2];                              //Guarda el numero de registro que se queria leer o escribir
	MOVLW       2
	ADDWF       FARG_EnviarErrorSPI_trama+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_EnviarErrorSPI_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _pduSPI+2 
;CPComunicacion.c,247 :: 		pduSPI[3] = 0x01;                                  //Indica eñ numero de bytes de pyload que se va a enviar
	MOVLW       1
	MOVWF       _pduSPI+3 
;CPComunicacion.c,248 :: 		pduSPI[4] = codigoError;                           //Agrega el codigo de error producido
	MOVF        FARG_EnviarErrorSPI_codigoError+0, 0 
	MOVWF       _pduSPI+4 
;CPComunicacion.c,249 :: 		t1Size = 5;
	MOVLW       5
	MOVWF       _t1Size+0 
;CPComunicacion.c,250 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,251 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_EnviarErrorSPI39:
	DECFSZ      R13, 1, 1
	BRA         L_EnviarErrorSPI39
	DECFSZ      R12, 1, 1
	BRA         L_EnviarErrorSPI39
	NOP
	NOP
;CPComunicacion.c,252 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,253 :: 		}
L_end_EnviarErrorSPI:
	RETURN      0
; end of _EnviarErrorSPI

_interrupt:

;CPComunicacion.c,258 :: 		void interrupt(void){
;CPComunicacion.c,261 :: 		if (PIR1.SSP1IF){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt40
;CPComunicacion.c,263 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;CPComunicacion.c,265 :: 		buffer = SSPBUF;                                //Guarda el contenido del bufeer (lectura)
	MOVF        SSPBUF+0, 0 
	MOVWF       _buffer+0 
;CPComunicacion.c,268 :: 		if ((buffer==0xB0)&&(banEsc==0)){               //Verifica si el primer byte es la cabecera de datos
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt43
	MOVF        _banEsc+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt43
L__interrupt93:
;CPComunicacion.c,269 :: 		banLec = 1;                                  //Activa la bandera de lectura
	MOVLW       1
	MOVWF       _banLec+0 
;CPComunicacion.c,270 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,271 :: 		}
L_interrupt43:
;CPComunicacion.c,272 :: 		if ((banLec==1)&&(buffer!=0xB0)){
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt46
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt46
L__interrupt92:
;CPComunicacion.c,273 :: 		tramaPDU[i] = buffer;
	MOVLW       _tramaPDU+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FSR1H 
	MOVF        _i+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _buffer+0, 0 
	MOVWF       POSTINC1+0 
;CPComunicacion.c,274 :: 		i++;
	INCF        _i+0, 1 
;CPComunicacion.c,275 :: 		}
L_interrupt46:
;CPComunicacion.c,276 :: 		if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt49
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt49
L__interrupt91:
;CPComunicacion.c,277 :: 		banLec = 0;                                  //Limpia la bandera de medicion
	CLRF        _banLec+0 
;CPComunicacion.c,278 :: 		banResp = 0;                                 //Activa la bandera de respuesta
	CLRF        _banResp+0 
;CPComunicacion.c,279 :: 		pduSize = i-1;
	DECF        _i+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _pduSize+0 
;CPComunicacion.c,280 :: 		EnviarMensajeRS485(tramaPDU,pduSize);
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        R0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;CPComunicacion.c,281 :: 		}
L_interrupt49:
;CPComunicacion.c,284 :: 		if ((buffer==0xC0)&&(banResp==0)){              //
	MOVF        _buffer+0, 0 
	XORLW       192
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt52
	MOVF        _banResp+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt52
L__interrupt90:
;CPComunicacion.c,285 :: 		banResp = 1;
	MOVLW       1
	MOVWF       _banResp+0 
;CPComunicacion.c,286 :: 		}
L_interrupt52:
;CPComunicacion.c,287 :: 		if ((buffer==0xCC)&&(banResp==1)){              //
	MOVF        _buffer+0, 0 
	XORLW       204
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt55
	MOVF        _banResp+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt55
L__interrupt89:
;CPComunicacion.c,288 :: 		banResp = 0;
	CLRF        _banResp+0 
;CPComunicacion.c,289 :: 		banSPI = 1;
	MOVLW       1
	MOVWF       _banSPI+0 
;CPComunicacion.c,290 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,291 :: 		SSPBUF = t1Size;
	MOVF        _t1Size+0, 0 
	MOVWF       SSPBUF+0 
;CPComunicacion.c,292 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_interrupt56:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt56
	DECFSZ      R12, 1, 1
	BRA         L_interrupt56
	NOP
	NOP
;CPComunicacion.c,293 :: 		}
L_interrupt55:
;CPComunicacion.c,296 :: 		if ((buffer==0xD0)&&(banSPI==1)){
	MOVF        _buffer+0, 0 
	XORLW       208
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt59
	MOVF        _banSPI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt59
L__interrupt88:
;CPComunicacion.c,297 :: 		banSPI = 2;
	MOVLW       2
	MOVWF       _banSPI+0 
;CPComunicacion.c,298 :: 		}
L_interrupt59:
;CPComunicacion.c,299 :: 		if ((buffer!=0xD1)&&(banSPI==2)){                     //
	MOVF        _buffer+0, 0 
	XORLW       209
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt62
	MOVF        _banSPI+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt62
L__interrupt87:
;CPComunicacion.c,300 :: 		SSPBUF = pduSPI[i];
	MOVLW       _pduSPI+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       SSPBUF+0 
;CPComunicacion.c,301 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_interrupt63:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt63
	DECFSZ      R12, 1, 1
	BRA         L_interrupt63
	NOP
	NOP
;CPComunicacion.c,302 :: 		i++;
	INCF        _i+0, 1 
;CPComunicacion.c,303 :: 		}
L_interrupt62:
;CPComunicacion.c,304 :: 		if ((buffer==0xD1)&&(banSPI==2)){
	MOVF        _buffer+0, 0 
	XORLW       209
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt66
	MOVF        _banSPI+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt66
L__interrupt86:
;CPComunicacion.c,305 :: 		banSPI = 0;
	CLRF        _banSPI+0 
;CPComunicacion.c,306 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,307 :: 		}
L_interrupt66:
;CPComunicacion.c,309 :: 		}
L_interrupt40:
;CPComunicacion.c,316 :: 		if(PIR1.RC1IF==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt67
;CPComunicacion.c,318 :: 		IU1 = 1;                                              //Enciende el indicador de interrupcion por UART1
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;CPComunicacion.c,319 :: 		byteTrama = UART1_Read();                             //Lee el byte de la trama de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _byteTrama+0 
;CPComunicacion.c,321 :: 		if (banTI==0){
	MOVF        _banTI+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt68
;CPComunicacion.c,322 :: 		if ((byteTrama==ACK)){                            //Verifica si recibio un ACK
	MOVF        _byteTrama+0, 0 
	XORLW       170
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt69
;CPComunicacion.c,324 :: 		T1CON.TMR1ON = 0;                              //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,325 :: 		TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,326 :: 		banTI=0;                                       //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,327 :: 		byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;CPComunicacion.c,328 :: 		}
L_interrupt69:
;CPComunicacion.c,329 :: 		if ((byteTrama==NACK)){                           //Verifica si recibio un NACK
	MOVF        _byteTrama+0, 0 
	XORLW       175
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt70
;CPComunicacion.c,331 :: 		T1CON.TMR1ON = 0;                              //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,332 :: 		TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,333 :: 		if (contadorNACK<3){
	MOVLW       3
	SUBWF       _contadorNACK+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt71
;CPComunicacion.c,334 :: 		EnviarMensajeRS485(tramaPDU,pduSize);       //Si recibe un NACK como respuesta, le renvia la trama
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        _pduSize+0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;CPComunicacion.c,335 :: 		contadorNACK++;                             //Incrementa en una unidad el valor del contador de NACK
	INCF        _contadorNACK+0, 1 
;CPComunicacion.c,336 :: 		} else {
	GOTO        L_interrupt72
L_interrupt71:
;CPComunicacion.c,337 :: 		contadorNACK = 0;                           //Limpia el contador de Time-Out-Trama
	CLRF        _contadorNACK+0 
;CPComunicacion.c,338 :: 		EnviarErrorSPI(tramaPDU,0xE1);              //Responde al Master notificandole del error
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarErrorSPI_trama+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarErrorSPI_trama+1 
	MOVLW       225
	MOVWF       FARG_EnviarErrorSPI_codigoError+0 
	CALL        _EnviarErrorSPI+0, 0
;CPComunicacion.c,339 :: 		}
L_interrupt72:
;CPComunicacion.c,340 :: 		banTI=0;                                       //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,341 :: 		byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;CPComunicacion.c,342 :: 		}
L_interrupt70:
;CPComunicacion.c,343 :: 		if ((byteTrama==HDR)){
	MOVF        _byteTrama+0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt73
;CPComunicacion.c,344 :: 		banTI = 1;                                     //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;CPComunicacion.c,345 :: 		i1 = 0;                                        //Define en 1 el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,346 :: 		tramaOk = 9;                                   //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW       9
	MOVWF       _tramaOk+0 
;CPComunicacion.c,348 :: 		T2CON.TMR2ON = 1;                              //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,349 :: 		PR2 = 249;                                     //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,350 :: 		}
L_interrupt73:
;CPComunicacion.c,351 :: 		}
L_interrupt68:
;CPComunicacion.c,355 :: 		if (banTI==1){                                        //Verifica que la bandera de inicio de trama este activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt74
;CPComunicacion.c,356 :: 		PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,357 :: 		T2CON.TMR2ON = 0;                                  //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,358 :: 		if (byteTrama!=END2){                              //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _byteTrama+0, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt75
;CPComunicacion.c,359 :: 		tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
	MOVLW       _tramaRS485+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;CPComunicacion.c,360 :: 		i1++;                                           //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _i1+0, 1 
;CPComunicacion.c,361 :: 		banTF = 0;                                      //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;CPComunicacion.c,362 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,363 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,364 :: 		} else {
	GOTO        L_interrupt76
L_interrupt75:
;CPComunicacion.c,365 :: 		tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
	MOVLW       _tramaRS485+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FSR1H 
	MOVF        _i1+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _byteTrama+0, 0 
	MOVWF       POSTINC1+0 
;CPComunicacion.c,366 :: 		banTF = 1;                                      //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _banTF+0 
;CPComunicacion.c,367 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,368 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,369 :: 		}
L_interrupt76:
;CPComunicacion.c,370 :: 		if (BanTF==1){                                     //Verifica que se cumpla la condicion de final de trama
	MOVF        _banTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt77
;CPComunicacion.c,371 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _banTI+0 
;CPComunicacion.c,372 :: 		banTC = 1;                                      //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _banTC+0 
;CPComunicacion.c,373 :: 		t1Size = tramaRS485[4]+4;                       //calcula la longitud de la trama PDU sumando 4 al valor del campo #Datos
	MOVLW       4
	ADDWF       _tramaRS485+4, 0 
	MOVWF       _t1Size+0 
;CPComunicacion.c,374 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,375 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,376 :: 		}
L_interrupt77:
;CPComunicacion.c,377 :: 		}
L_interrupt74:
;CPComunicacion.c,380 :: 		if (banTC==1){                                        //Verifica que se haya completado de llenar la trama de peticion
	MOVF        _banTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt78
;CPComunicacion.c,381 :: 		tramaOk = 0;
	CLRF        _tramaOk+0 
;CPComunicacion.c,382 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);         //Calcula y verifica el CRC de la trama de peticion
	MOVLW       _tramaRS485+0
	MOVWF       FARG_VerificarCRC_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_VerificarCRC_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_VerificarCRC_tramaPDUSize+0 
	CALL        _VerificarCRC+0, 0
	MOVF        R0, 0 
	MOVWF       _tramaOk+0 
;CPComunicacion.c,383 :: 		if (tramaOk==1){
	MOVF        R0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt79
;CPComunicacion.c,384 :: 		EnviarACK(1);                                  //Si la trama llego sin errores responde con un ACK al H/S
	MOVLW       1
	MOVWF       FARG_EnviarACK_puerto+0 
	CALL        _EnviarACK+0, 0
;CPComunicacion.c,385 :: 		EnviarMensajeSPI(tramaRS485,t1Size);           //Invoca esta funcion para enviar los datos a la RPi por SPI
	MOVLW       _tramaRS485+0
	MOVWF       FARG_EnviarMensajeSPI_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_EnviarMensajeSPI_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_EnviarMensajeSPI_pduSize2+0 
	CALL        _EnviarMensajeSPI+0, 0
;CPComunicacion.c,386 :: 		} else {
	GOTO        L_interrupt80
L_interrupt79:
;CPComunicacion.c,387 :: 		EnviarNACK(1);                                 //Si hubo algun error en la trama se envia un NACK al H/S
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;CPComunicacion.c,388 :: 		}
L_interrupt80:
;CPComunicacion.c,389 :: 		banTI = 0;                                         //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,390 :: 		banTC = 0;                                         //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;CPComunicacion.c,391 :: 		i1 = 0;                                            //Incializa el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,392 :: 		}
L_interrupt78:
;CPComunicacion.c,394 :: 		IU1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;CPComunicacion.c,396 :: 		}
L_interrupt67:
;CPComunicacion.c,401 :: 		if (TMR1IF_bit==1){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt81
;CPComunicacion.c,402 :: 		TMR1IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,403 :: 		T1CON.TMR1ON = 0;                                     //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,404 :: 		if (contadorTOD<3){
	MOVLW       3
	SUBWF       _contadorTOD+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt82
;CPComunicacion.c,405 :: 		EnviarMensajeRS485(tramaPDU,pduSize);              //Reenvia la trama por el bus RS485
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        _pduSize+0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;CPComunicacion.c,406 :: 		contadorTOD++;                                     //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF        _contadorTOD+0, 1 
;CPComunicacion.c,407 :: 		} else {
	GOTO        L_interrupt83
L_interrupt82:
;CPComunicacion.c,408 :: 		EnviarErrorSPI(tramaPDU,0xE0);                     //Responde al Master notificandole del error
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarErrorSPI_trama+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarErrorSPI_trama+1 
	MOVLW       224
	MOVWF       FARG_EnviarErrorSPI_codigoError+0 
	CALL        _EnviarErrorSPI+0, 0
;CPComunicacion.c,409 :: 		contadorTOD = 0;                                   //Limpia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;CPComunicacion.c,410 :: 		}
L_interrupt83:
;CPComunicacion.c,411 :: 		}
L_interrupt81:
;CPComunicacion.c,418 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt84
;CPComunicacion.c,419 :: 		TMR2IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;CPComunicacion.c,420 :: 		T2CON.TMR2ON = 0;                                     //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,421 :: 		banTI = 0;                                            //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,422 :: 		i1 = 0;                                               //Limpia el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,423 :: 		banTC = 0;                                            //Limpia la bandera de trama completa(Por si acaso)
	CLRF        _banTC+0 
;CPComunicacion.c,424 :: 		EnviarNACK(1);
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;CPComunicacion.c,425 :: 		}
L_interrupt84:
;CPComunicacion.c,427 :: 		}
L_end_interrupt:
L__interrupt105:
	RETFIE      1
; end of _interrupt

_main:

;CPComunicacion.c,431 :: 		void main() {
;CPComunicacion.c,433 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;CPComunicacion.c,434 :: 		RE_DE = 0;                                               //Establece el Max485-1 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,435 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,436 :: 		i1=0;
	CLRF        _i1+0 
;CPComunicacion.c,437 :: 		contadorTOD = 0;                                         //Inicia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;CPComunicacion.c,438 :: 		contadorNACK = 0;                                        //Inicia el contador de NACK
	CLRF        _contadorNACK+0 
;CPComunicacion.c,439 :: 		banTI=0;                                                 //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,440 :: 		banTC=0;                                                 //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;CPComunicacion.c,441 :: 		banTF=0;                                                 //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;CPComunicacion.c,443 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;CPComunicacion.c,444 :: 		t1Size = 0;
	CLRF        _t1Size+0 
;CPComunicacion.c,446 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
