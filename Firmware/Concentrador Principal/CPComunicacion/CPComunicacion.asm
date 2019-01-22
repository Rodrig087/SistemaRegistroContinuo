
_ConfiguracionPrincipal:

;CPComunicacion.c,67 :: 		void ConfiguracionPrincipal(){
;CPComunicacion.c,69 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;CPComunicacion.c,70 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;CPComunicacion.c,72 :: 		TRISB1_bit = 1;                                   //Configura el pin B1 como entrada
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;CPComunicacion.c,73 :: 		TRISB3_bit = 0;                                   //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;CPComunicacion.c,74 :: 		TRISB4_bit = 0;                                   //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;CPComunicacion.c,75 :: 		TRISC1_bit = 0;                                   //Configura el pin C1 como salida
	BCF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;CPComunicacion.c,76 :: 		TRISC2_bit = 0;                                   //Configura el pin C2 como salida
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;CPComunicacion.c,78 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;CPComunicacion.c,79 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;CPComunicacion.c,82 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;CPComunicacion.c,83 :: 		UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;CPComunicacion.c,86 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	CLRF        FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	MOVLW       1
	MOVWF       FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;CPComunicacion.c,87 :: 		PIE1.SSP1IE = 1;                                  //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;CPComunicacion.c,90 :: 		T1CON = 0x30;                                     //Timer1 Input Clock Prescale Select bits
	MOVLW       48
	MOVWF       T1CON+0 
;CPComunicacion.c,91 :: 		TMR1H = 0x0B;
	MOVLW       11
	MOVWF       TMR1H+0 
;CPComunicacion.c,92 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;CPComunicacion.c,93 :: 		PIR1.TMR1IF = 0;                                  //Limpia la bandera de interrupcion del TMR1
	BCF         PIR1+0, 0 
;CPComunicacion.c,94 :: 		PIE1.TMR1IE = 1;                                  //Habilita la interrupción de desbordamiento TMR1
	BSF         PIE1+0, 0 
;CPComunicacion.c,97 :: 		T2CON = 0x78;                                     //Timer2 Output Postscaler Select bits
	MOVLW       120
	MOVWF       T2CON+0 
;CPComunicacion.c,98 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,99 :: 		PIR1.TMR2IF = 0;                                  //Limpia la bandera de interrupcion del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,100 :: 		PIE1.TMR2IE = 1;                                  //Habilita la interrupción de desbordamiento TMR2
	BSF         PIE1+0, 1 
;CPComunicacion.c,102 :: 		Delay_ms(100);                                    //Espera hasta que se estabilicen los cambios
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
;CPComunicacion.c,104 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_CalcularCRC:

;CPComunicacion.c,110 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;CPComunicacion.c,113 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_CalcularCRC1:
	MOVF        FARG_CalcularCRC_tramaSize+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_CalcularCRC2
;CPComunicacion.c,114 :: 		CRC16^=*trama ++;
	MOVFF       FARG_CalcularCRC_trama+0, FSR2
	MOVFF       FARG_CalcularCRC_trama+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_CalcularCRC_trama+0, 1 
	INCF        FARG_CalcularCRC_trama+1, 1 
;CPComunicacion.c,115 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	CLRF        R2 
L_CalcularCRC4:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_CalcularCRC5
;CPComunicacion.c,116 :: 		if(CRC16 & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_CalcularCRC7
;CPComunicacion.c,117 :: 		CRC16 = (CRC16>>1)^POLMODBUS;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_CalcularCRC8
L_CalcularCRC7:
;CPComunicacion.c,119 :: 		CRC16>>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_CalcularCRC8:
;CPComunicacion.c,115 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	INCF        R2, 1 
;CPComunicacion.c,120 :: 		}
	GOTO        L_CalcularCRC4
L_CalcularCRC5:
;CPComunicacion.c,113 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	DECF        FARG_CalcularCRC_tramaSize+0, 1 
;CPComunicacion.c,121 :: 		}
	GOTO        L_CalcularCRC1
L_CalcularCRC2:
;CPComunicacion.c,122 :: 		return CRC16;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;CPComunicacion.c,123 :: 		}
L_end_CalcularCRC:
	RETURN      0
; end of _CalcularCRC

_VerificarCRC:

;CPComunicacion.c,130 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;CPComunicacion.c,135 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        VerificarCRC_crcCalculado_L0+0 
	CLRF        VerificarCRC_crcCalculado_L0+1 
;CPComunicacion.c,136 :: 		crcTrama = 1;
	MOVLW       1
	MOVWF       VerificarCRC_crcTrama_L0+0 
	MOVLW       0
	MOVWF       VerificarCRC_crcTrama_L0+1 
;CPComunicacion.c,137 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        VerificarCRC_j_L0+0 
L_VerificarCRC9:
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	SUBWF       VerificarCRC_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_VerificarCRC10
;CPComunicacion.c,138 :: 		pdu[j] = trama[j+1];
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
;CPComunicacion.c,137 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        VerificarCRC_j_L0+0, 1 
;CPComunicacion.c,140 :: 		}
	GOTO        L_VerificarCRC9
L_VerificarCRC10:
;CPComunicacion.c,141 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
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
;CPComunicacion.c,142 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW       VerificarCRC_crcTrama_L0+0
	MOVWF       VerificarCRC_ptrCRCTrama_L0+0 
	MOVLW       hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF       VerificarCRC_ptrCRCTrama_L0+1 
;CPComunicacion.c,143 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;CPComunicacion.c,144 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;CPComunicacion.c,145 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        VerificarCRC_crcCalculado_L0+1, 0 
	XORWF       VerificarCRC_crcTrama_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__VerificarCRC99
	MOVF        VerificarCRC_crcTrama_L0+0, 0 
	XORWF       VerificarCRC_crcCalculado_L0+0, 0 
L__VerificarCRC99:
	BTFSS       STATUS+0, 2 
	GOTO        L_VerificarCRC12
;CPComunicacion.c,146 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_VerificarCRC
;CPComunicacion.c,147 :: 		} else {
L_VerificarCRC12:
;CPComunicacion.c,148 :: 		return 0;
	CLRF        R0 
;CPComunicacion.c,150 :: 		}
L_end_VerificarCRC:
	RETURN      0
; end of _VerificarCRC

_EnviarACK:

;CPComunicacion.c,156 :: 		void EnviarACK(unsigned char puerto){
;CPComunicacion.c,158 :: 		if (puerto==1){
	MOVF        FARG_EnviarACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK14
;CPComunicacion.c,159 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,160 :: 		UART1_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,161 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK15:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK16
	GOTO        L_EnviarACK15
L_EnviarACK16:
;CPComunicacion.c,162 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,163 :: 		} else {
	GOTO        L_EnviarACK17
L_EnviarACK14:
;CPComunicacion.c,164 :: 		UART2_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       170
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,165 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK18:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK19
	GOTO        L_EnviarACK18
L_EnviarACK19:
;CPComunicacion.c,166 :: 		}
L_EnviarACK17:
;CPComunicacion.c,167 :: 		}
L_end_EnviarACK:
	RETURN      0
; end of _EnviarACK

_EnviarNACK:

;CPComunicacion.c,173 :: 		void EnviarNACK(unsigned char puerto){
;CPComunicacion.c,175 :: 		if (puerto==1){
	MOVF        FARG_EnviarNACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK20
;CPComunicacion.c,176 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,177 :: 		UART1_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       175
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,178 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK21:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK22
	GOTO        L_EnviarNACK21
L_EnviarNACK22:
;CPComunicacion.c,179 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,180 :: 		} else {
	GOTO        L_EnviarNACK23
L_EnviarNACK20:
;CPComunicacion.c,181 :: 		UART2_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       175
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,182 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK24:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK25
	GOTO        L_EnviarNACK24
L_EnviarNACK25:
;CPComunicacion.c,183 :: 		}
L_EnviarNACK23:
;CPComunicacion.c,184 :: 		}
L_end_EnviarNACK:
	RETURN      0
; end of _EnviarNACK

_EnviarMensajeRS485:

;CPComunicacion.c,190 :: 		void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
;CPComunicacion.c,194 :: 		CRCPDU = CalcularCRC(PDU, sizePDU);                //Calcula el CRC de la trama PDU
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
;CPComunicacion.c,195 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW       EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+0 
	MOVLW       hi_addr(EnviarMensajeRS485_CRCPDU_L0+0)
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+1 
;CPComunicacion.c,197 :: 		tramaRS485[0] = HDR;                               //Añade la cabecera a la trama a enviar
	MOVLW       58
	MOVWF       _tramaRS485+0 
;CPComunicacion.c,198 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;CPComunicacion.c,199 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;CPComunicacion.c,200 :: 		tramaRS485[sizePDU+3] = END1;                      //Añade el primer delimitador de final de trama
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
;CPComunicacion.c,201 :: 		tramaRS485[sizePDU+4] = END2;                      //Añade el segundo delimitador de final de trama
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
;CPComunicacion.c,202 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,203 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO        L__EnviarMensajeRS485103
	MOVF        R1, 0 
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
L__EnviarMensajeRS485103:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48527
;CPComunicacion.c,204 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW       1
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
	MOVF        EnviarMensajeRS485_i_L0+0, 0 
	SUBWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
L__EnviarMensajeRS48587:
;CPComunicacion.c,205 :: 		UART1_Write(PDU[i-1]);                      //Envia el contenido de la trama PDU a travez del UART1
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
;CPComunicacion.c,206 :: 		} else {
	GOTO        L_EnviarMensajeRS48532
L_EnviarMensajeRS48531:
;CPComunicacion.c,207 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
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
;CPComunicacion.c,208 :: 		}
L_EnviarMensajeRS48532:
;CPComunicacion.c,203 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF        EnviarMensajeRS485_i_L0+0, 1 
;CPComunicacion.c,209 :: 		}
	GOTO        L_EnviarMensajeRS48526
L_EnviarMensajeRS48527:
;CPComunicacion.c,210 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48533:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarMensajeRS48534
	GOTO        L_EnviarMensajeRS48533
L_EnviarMensajeRS48534:
;CPComunicacion.c,211 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,213 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF         T1CON+0, 0 
;CPComunicacion.c,214 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,215 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW       11
	MOVWF       TMR1H+0 
;CPComunicacion.c,216 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;CPComunicacion.c,217 :: 		}
L_end_EnviarMensajeRS485:
	RETURN      0
; end of _EnviarMensajeRS485

_EnviarMensajeSPI:

;CPComunicacion.c,223 :: 		void EnviarMensajeSPI(unsigned char *trama, unsigned char pduSize2){
;CPComunicacion.c,225 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        EnviarMensajeSPI_j_L0+0 
L_EnviarMensajeSPI35:
	MOVF        FARG_EnviarMensajeSPI_pduSize2+0, 0 
	SUBWF       EnviarMensajeSPI_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeSPI36
;CPComunicacion.c,226 :: 		pduSPI[j] = trama[j+1];
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
;CPComunicacion.c,227 :: 		UART1_Write(pduSPI[j]);
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
;CPComunicacion.c,225 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        EnviarMensajeSPI_j_L0+0, 1 
;CPComunicacion.c,228 :: 		}
	GOTO        L_EnviarMensajeSPI35
L_EnviarMensajeSPI36:
;CPComunicacion.c,229 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,230 :: 		Delay_ms(1);
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
;CPComunicacion.c,231 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,232 :: 		}
L_end_EnviarMensajeSPI:
	RETURN      0
; end of _EnviarMensajeSPI

_interrupt:

;CPComunicacion.c,237 :: 		void interrupt(void){
;CPComunicacion.c,240 :: 		if (PIR1.SSP1IF){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt39
;CPComunicacion.c,242 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;CPComunicacion.c,244 :: 		buffer = SSPBUF;                                //Guarda el contenido del bufeer (lectura)
	MOVF        SSPBUF+0, 0 
	MOVWF       _buffer+0 
;CPComunicacion.c,247 :: 		if ((buffer==0xB0)&&(banEsc==0)){               //Verifica si el primer byte es la cabecera de datos
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt42
	MOVF        _banEsc+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt42
L__interrupt95:
;CPComunicacion.c,248 :: 		banLec = 1;                                  //Activa la bandera de lectura
	MOVLW       1
	MOVWF       _banLec+0 
;CPComunicacion.c,249 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,250 :: 		}
L_interrupt42:
;CPComunicacion.c,251 :: 		if ((banLec==1)&&(buffer!=0xB0)){
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt45
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt45
L__interrupt94:
;CPComunicacion.c,252 :: 		tramaPDU[i] = buffer;
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
;CPComunicacion.c,253 :: 		i++;
	INCF        _i+0, 1 
;CPComunicacion.c,254 :: 		}
L_interrupt45:
;CPComunicacion.c,255 :: 		if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt48
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt48
L__interrupt93:
;CPComunicacion.c,256 :: 		banLec = 0;                                  //Limpia la bandera de medicion
	CLRF        _banLec+0 
;CPComunicacion.c,257 :: 		banResp = 0;                                 //Activa la bandera de respuesta
	CLRF        _banResp+0 
;CPComunicacion.c,258 :: 		pduSize = i-1;
	DECF        _i+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _pduSize+0 
;CPComunicacion.c,259 :: 		EnviarMensajeRS485(tramaPDU,pduSize);
	MOVLW       _tramaPDU+0
	MOVWF       FARG_EnviarMensajeRS485_PDU+0 
	MOVLW       hi_addr(_tramaPDU+0)
	MOVWF       FARG_EnviarMensajeRS485_PDU+1 
	MOVF        R0, 0 
	MOVWF       FARG_EnviarMensajeRS485_sizePDU+0 
	CALL        _EnviarMensajeRS485+0, 0
;CPComunicacion.c,260 :: 		}
L_interrupt48:
;CPComunicacion.c,263 :: 		if ((buffer==0xC0)&&(banResp==0)){              //
	MOVF        _buffer+0, 0 
	XORLW       192
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt51
	MOVF        _banResp+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt51
L__interrupt92:
;CPComunicacion.c,264 :: 		banResp = 1;
	MOVLW       1
	MOVWF       _banResp+0 
;CPComunicacion.c,265 :: 		}
L_interrupt51:
;CPComunicacion.c,266 :: 		if ((buffer==0xCC)&&(banResp==1)){              //
	MOVF        _buffer+0, 0 
	XORLW       204
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt54
	MOVF        _banResp+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt54
L__interrupt91:
;CPComunicacion.c,267 :: 		banResp = 0;
	CLRF        _banResp+0 
;CPComunicacion.c,268 :: 		banSPI = 1;
	MOVLW       1
	MOVWF       _banSPI+0 
;CPComunicacion.c,269 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,270 :: 		SSPBUF = t1Size;
	MOVF        _t1Size+0, 0 
	MOVWF       SSPBUF+0 
;CPComunicacion.c,271 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_interrupt55:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt55
	DECFSZ      R12, 1, 1
	BRA         L_interrupt55
	NOP
	NOP
;CPComunicacion.c,272 :: 		}
L_interrupt54:
;CPComunicacion.c,275 :: 		if ((buffer==0xD0)&&(banSPI==1)){
	MOVF        _buffer+0, 0 
	XORLW       208
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt58
	MOVF        _banSPI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt58
L__interrupt90:
;CPComunicacion.c,276 :: 		banSPI = 2;
	MOVLW       2
	MOVWF       _banSPI+0 
;CPComunicacion.c,277 :: 		}
L_interrupt58:
;CPComunicacion.c,278 :: 		if ((buffer!=0xD1)&&(banSPI==2)){              //
	MOVF        _buffer+0, 0 
	XORLW       209
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt61
	MOVF        _banSPI+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt61
L__interrupt89:
;CPComunicacion.c,279 :: 		SSPBUF = pduSPI[i];
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
;CPComunicacion.c,280 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_interrupt62:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt62
	DECFSZ      R12, 1, 1
	BRA         L_interrupt62
	NOP
	NOP
;CPComunicacion.c,281 :: 		i++;
	INCF        _i+0, 1 
;CPComunicacion.c,282 :: 		}
L_interrupt61:
;CPComunicacion.c,283 :: 		if ((buffer==0xD1)&&(banSPI==2)){
	MOVF        _buffer+0, 0 
	XORLW       209
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt65
	MOVF        _banSPI+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt65
L__interrupt88:
;CPComunicacion.c,284 :: 		banSPI = 0;
	CLRF        _banSPI+0 
;CPComunicacion.c,285 :: 		i = 0;
	CLRF        _i+0 
;CPComunicacion.c,286 :: 		}
L_interrupt65:
;CPComunicacion.c,288 :: 		}
L_interrupt39:
;CPComunicacion.c,295 :: 		if(PIR1.RC1IF==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt66
;CPComunicacion.c,297 :: 		IU1 = 1;                                              //Enciende el indicador de interrupcion por UART1
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;CPComunicacion.c,298 :: 		byteTrama = UART1_Read();                             //Lee el byte de la trama de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _byteTrama+0 
;CPComunicacion.c,300 :: 		if (banTI==0){
	MOVF        _banTI+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt67
;CPComunicacion.c,301 :: 		if ((byteTrama==ACK)){                            //Verifica si recibio un ACK
	MOVF        _byteTrama+0, 0 
	XORLW       170
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt68
;CPComunicacion.c,303 :: 		T1CON.TMR1ON = 0;                              //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,304 :: 		TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,305 :: 		banTI=0;                                       //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,306 :: 		byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;CPComunicacion.c,307 :: 		}
L_interrupt68:
;CPComunicacion.c,308 :: 		if ((byteTrama==NACK)){                           //Verifica si recibio un NACK
	MOVF        _byteTrama+0, 0 
	XORLW       175
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt69
;CPComunicacion.c,310 :: 		T1CON.TMR1ON = 0;                              //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,311 :: 		TMR1IF_bit = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,312 :: 		if (contadorNACK<3){
	MOVLW       3
	SUBWF       _contadorNACK+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt70
;CPComunicacion.c,314 :: 		contadorNACK++;                             //Incrementa en una unidad el valor del contador de NACK
	INCF        _contadorNACK+0, 1 
;CPComunicacion.c,315 :: 		} else {
	GOTO        L_interrupt71
L_interrupt70:
;CPComunicacion.c,316 :: 		contadorNACK = 0;                           //Limpia el contador de Time-Out-Trama
	CLRF        _contadorNACK+0 
;CPComunicacion.c,317 :: 		}
L_interrupt71:
;CPComunicacion.c,318 :: 		banTI=0;                                       //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,319 :: 		byteTrama=0;                                   //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;CPComunicacion.c,320 :: 		}
L_interrupt69:
;CPComunicacion.c,321 :: 		if ((byteTrama==HDR)){
	MOVF        _byteTrama+0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt72
;CPComunicacion.c,322 :: 		banTI = 1;                                     //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;CPComunicacion.c,323 :: 		i1 = 0;                                        //Define en 1 el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,324 :: 		tramaOk = 9;                                   //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW       9
	MOVWF       _tramaOk+0 
;CPComunicacion.c,326 :: 		T2CON.TMR2ON = 1;                              //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,327 :: 		PR2 = 249;                                     //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,328 :: 		}
L_interrupt72:
;CPComunicacion.c,329 :: 		}
L_interrupt67:
;CPComunicacion.c,333 :: 		if (banTI==1){                                        //Verifica que la bandera de inicio de trama este activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt73
;CPComunicacion.c,334 :: 		PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,335 :: 		T2CON.TMR2ON = 0;                                  //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,336 :: 		if (byteTrama!=END2){                              //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _byteTrama+0, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt74
;CPComunicacion.c,337 :: 		tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
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
;CPComunicacion.c,338 :: 		i1++;                                           //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _i1+0, 1 
;CPComunicacion.c,339 :: 		banTF = 0;                                      //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;CPComunicacion.c,340 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,341 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,342 :: 		} else {
	GOTO        L_interrupt75
L_interrupt74:
;CPComunicacion.c,343 :: 		tramaRS485[i1] = byteTrama;                     //Almacena el dato en la trama de respuesta
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
;CPComunicacion.c,344 :: 		banTF = 1;                                      //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _banTF+0 
;CPComunicacion.c,345 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;CPComunicacion.c,346 :: 		PR2 = 249;
	MOVLW       249
	MOVWF       PR2+0 
;CPComunicacion.c,347 :: 		}
L_interrupt75:
;CPComunicacion.c,348 :: 		if (BanTF==1){                                     //Verifica que se cumpla la condicion de final de trama
	MOVF        _banTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt76
;CPComunicacion.c,349 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _banTI+0 
;CPComunicacion.c,350 :: 		banTC = 1;                                      //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _banTC+0 
;CPComunicacion.c,351 :: 		t1Size = tramaRS485[4]+4;                       //calcula la longitud de la trama PDU sumando 4 al valor del campo #Datos
	MOVLW       4
	ADDWF       _tramaRS485+4, 0 
	MOVWF       _t1Size+0 
;CPComunicacion.c,352 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         PIR1+0, 1 
;CPComunicacion.c,353 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,354 :: 		}
L_interrupt76:
;CPComunicacion.c,355 :: 		}
L_interrupt73:
;CPComunicacion.c,358 :: 		if (banTC==1){                                        //Verifica que se haya completado de llenar la trama de peticion
	MOVF        _banTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt77
;CPComunicacion.c,359 :: 		tramaOk = 0;
	CLRF        _tramaOk+0 
;CPComunicacion.c,360 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);         //Calcula y verifica el CRC de la trama de peticion
	MOVLW       _tramaRS485+0
	MOVWF       FARG_VerificarCRC_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_VerificarCRC_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_VerificarCRC_tramaPDUSize+0 
	CALL        _VerificarCRC+0, 0
	MOVF        R0, 0 
	MOVWF       _tramaOk+0 
;CPComunicacion.c,361 :: 		if (tramaOk==1){
	MOVF        R0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt78
;CPComunicacion.c,362 :: 		EnviarACK(1);                                  //Si la trama llego sin errores responde con un ACK al H/S
	MOVLW       1
	MOVWF       FARG_EnviarACK_puerto+0 
	CALL        _EnviarACK+0, 0
;CPComunicacion.c,363 :: 		EnviarMensajeSPI(tramaRS485,t1Size);         //Invoca esta funcion para enviar los datos a la RPi por SPI
	MOVLW       _tramaRS485+0
	MOVWF       FARG_EnviarMensajeSPI_trama+0 
	MOVLW       hi_addr(_tramaRS485+0)
	MOVWF       FARG_EnviarMensajeSPI_trama+1 
	MOVF        _t1Size+0, 0 
	MOVWF       FARG_EnviarMensajeSPI_pduSize2+0 
	CALL        _EnviarMensajeSPI+0, 0
;CPComunicacion.c,364 :: 		} else {
	GOTO        L_interrupt79
L_interrupt78:
;CPComunicacion.c,365 :: 		EnviarNACK(1);                                 //Si hubo algun error en la trama se envia un NACK al H/S
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;CPComunicacion.c,366 :: 		}
L_interrupt79:
;CPComunicacion.c,367 :: 		banTI = 0;                                         //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,368 :: 		banTC = 0;                                         //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;CPComunicacion.c,369 :: 		i1 = 0;                                            //Incializa el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,370 :: 		}
L_interrupt77:
;CPComunicacion.c,372 :: 		IU1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;CPComunicacion.c,374 :: 		}
L_interrupt66:
;CPComunicacion.c,379 :: 		if (TMR1IF_bit==1){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt80
;CPComunicacion.c,380 :: 		TMR1IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,381 :: 		T1CON.TMR1ON = 0;                                     //Apaga el Timer1
	BCF         T1CON+0, 0 
;CPComunicacion.c,382 :: 		if (contadorTOD<3){
	MOVLW       3
	SUBWF       _contadorTOD+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt81
;CPComunicacion.c,384 :: 		contadorTOD++;                                     //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF        _contadorTOD+0, 1 
;CPComunicacion.c,385 :: 		} else {
	GOTO        L_interrupt82
L_interrupt81:
;CPComunicacion.c,387 :: 		contadorTOD = 0;                                   //Limpia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;CPComunicacion.c,388 :: 		}
L_interrupt82:
;CPComunicacion.c,389 :: 		}
L_interrupt80:
;CPComunicacion.c,396 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt83
;CPComunicacion.c,397 :: 		TMR2IF_bit = 0;                                       //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;CPComunicacion.c,398 :: 		T2CON.TMR2ON = 0;                                     //Apaga el Timer2
	BCF         T2CON+0, 2 
;CPComunicacion.c,399 :: 		banTI = 0;                                            //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,400 :: 		i1 = 0;                                               //Limpia el subindice de la trama de peticion
	CLRF        _i1+0 
;CPComunicacion.c,401 :: 		banTC = 0;                                            //Limpia la bandera de trama completa(Por si acaso)
	CLRF        _banTC+0 
;CPComunicacion.c,402 :: 		if (puertoTOT==1){
	MOVF        _puertoTOT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt84
;CPComunicacion.c,403 :: 		EnviarNACK(1);                                    //Envia un NACK por el puerto UART1 para solicitar el reenvio de la trama
	MOVLW       1
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;CPComunicacion.c,404 :: 		} else if (puertoTOT==2) {
	GOTO        L_interrupt85
L_interrupt84:
	MOVF        _puertoTOT+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt86
;CPComunicacion.c,405 :: 		EnviarNACK(2);                                    //Envia un NACK por el puerto UART2 para solicitar el reenvio de la trama
	MOVLW       2
	MOVWF       FARG_EnviarNACK_puerto+0 
	CALL        _EnviarNACK+0, 0
;CPComunicacion.c,406 :: 		}
L_interrupt86:
L_interrupt85:
;CPComunicacion.c,407 :: 		puertoTOT = 0;                                        //Encera la variable para evitar confusiones
	CLRF        _puertoTOT+0 
;CPComunicacion.c,408 :: 		}
L_interrupt83:
;CPComunicacion.c,410 :: 		}
L_end_interrupt:
L__interrupt106:
	RETFIE      1
; end of _interrupt

_main:

;CPComunicacion.c,414 :: 		void main() {
;CPComunicacion.c,416 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;CPComunicacion.c,417 :: 		RE_DE = 0;                                               //Establece el Max485-1 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,418 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,419 :: 		i1=0;
	CLRF        _i1+0 
;CPComunicacion.c,420 :: 		i2=0;
	CLRF        _i2+0 
;CPComunicacion.c,421 :: 		contadorTOD = 0;                                         //Inicia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;CPComunicacion.c,422 :: 		contadorNACK = 0;                                        //Inicia el contador de NACK
	CLRF        _contadorNACK+0 
;CPComunicacion.c,423 :: 		banTI=0;                                                 //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,424 :: 		banTC=0;                                                 //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;CPComunicacion.c,425 :: 		banTF=0;                                                 //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;CPComunicacion.c,427 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;CPComunicacion.c,428 :: 		t1Size = 0;
	CLRF        _t1Size+0 
;CPComunicacion.c,430 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
