
_ConfiguracionPrincipal:

;CPComunicacion.c,74 :: 		void ConfiguracionPrincipal(){
;CPComunicacion.c,76 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;CPComunicacion.c,77 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;CPComunicacion.c,79 :: 		TRISB1_bit = 1;                                    //Configura el pin B1 como entrada
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;CPComunicacion.c,80 :: 		TRISB3_bit = 0;                                    //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;CPComunicacion.c,81 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;CPComunicacion.c,82 :: 		TRISC1_bit = 0;                                    //Configura el pin C1 como salida
	BCF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;CPComunicacion.c,83 :: 		TRISC2_bit = 0;                                    //Configura el pin C2 como salida
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;CPComunicacion.c,85 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;CPComunicacion.c,86 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;CPComunicacion.c,89 :: 		PIE1.RC1IE = 1;                                    //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;CPComunicacion.c,90 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       1
	MOVWF       SPBRGH+0 
	MOVLW       3
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;CPComunicacion.c,93 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	MOVLW       128
	MOVWF       FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	CLRF        FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;CPComunicacion.c,94 :: 		PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;CPComunicacion.c,100 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_ConfiguracionPrincipal0:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionPrincipal0
	NOP
	NOP
;CPComunicacion.c,102 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_CalcularCRC:

;CPComunicacion.c,108 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;CPComunicacion.c,111 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_CalcularCRC1:
	MOVF        FARG_CalcularCRC_tramaSize+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_CalcularCRC2
;CPComunicacion.c,112 :: 		CRC16^=*trama ++;
	MOVFF       FARG_CalcularCRC_trama+0, FSR2
	MOVFF       FARG_CalcularCRC_trama+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_CalcularCRC_trama+0, 1 
	INCF        FARG_CalcularCRC_trama+1, 1 
;CPComunicacion.c,113 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	CLRF        R2 
L_CalcularCRC4:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_CalcularCRC5
;CPComunicacion.c,114 :: 		if(CRC16 & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_CalcularCRC7
;CPComunicacion.c,115 :: 		CRC16 = (CRC16>>1)^POLMODBUS;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_CalcularCRC8
L_CalcularCRC7:
;CPComunicacion.c,117 :: 		CRC16>>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_CalcularCRC8:
;CPComunicacion.c,113 :: 		for(ucCounter=0; ucCounter<8; ucCounter++){
	INCF        R2, 1 
;CPComunicacion.c,118 :: 		}
	GOTO        L_CalcularCRC4
L_CalcularCRC5:
;CPComunicacion.c,111 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize--){
	DECF        FARG_CalcularCRC_tramaSize+0, 1 
;CPComunicacion.c,119 :: 		}
	GOTO        L_CalcularCRC1
L_CalcularCRC2:
;CPComunicacion.c,120 :: 		return CRC16;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;CPComunicacion.c,121 :: 		}
L_end_CalcularCRC:
	RETURN      0
; end of _CalcularCRC

_VerificarCRC:

;CPComunicacion.c,128 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;CPComunicacion.c,133 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        VerificarCRC_crcCalculado_L0+0 
	CLRF        VerificarCRC_crcCalculado_L0+1 
;CPComunicacion.c,134 :: 		crcTrama = 1;
	MOVLW       1
	MOVWF       VerificarCRC_crcTrama_L0+0 
	MOVLW       0
	MOVWF       VerificarCRC_crcTrama_L0+1 
;CPComunicacion.c,135 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        VerificarCRC_j_L0+0 
L_VerificarCRC9:
	MOVF        FARG_VerificarCRC_tramaPDUSize+0, 0 
	SUBWF       VerificarCRC_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_VerificarCRC10
;CPComunicacion.c,136 :: 		pdu[j] = trama[j+1];
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
;CPComunicacion.c,135 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        VerificarCRC_j_L0+0, 1 
;CPComunicacion.c,137 :: 		}
	GOTO        L_VerificarCRC9
L_VerificarCRC10:
;CPComunicacion.c,138 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
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
;CPComunicacion.c,139 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW       VerificarCRC_crcTrama_L0+0
	MOVWF       VerificarCRC_ptrCRCTrama_L0+0 
	MOVLW       hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF       VerificarCRC_ptrCRCTrama_L0+1 
;CPComunicacion.c,140 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;CPComunicacion.c,141 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;CPComunicacion.c,142 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        VerificarCRC_crcCalculado_L0+1, 0 
	XORWF       VerificarCRC_crcTrama_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__VerificarCRC51
	MOVF        VerificarCRC_crcTrama_L0+0, 0 
	XORWF       VerificarCRC_crcCalculado_L0+0, 0 
L__VerificarCRC51:
	BTFSS       STATUS+0, 2 
	GOTO        L_VerificarCRC12
;CPComunicacion.c,143 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_VerificarCRC
;CPComunicacion.c,144 :: 		} else {
L_VerificarCRC12:
;CPComunicacion.c,145 :: 		return 0;
	CLRF        R0 
;CPComunicacion.c,147 :: 		}
L_end_VerificarCRC:
	RETURN      0
; end of _VerificarCRC

_EnviarACK:

;CPComunicacion.c,153 :: 		void EnviarACK(unsigned char puerto){
;CPComunicacion.c,154 :: 		if (puerto==1){
	MOVF        FARG_EnviarACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK14
;CPComunicacion.c,155 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,156 :: 		UART1_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,157 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK15:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK16
	GOTO        L_EnviarACK15
L_EnviarACK16:
;CPComunicacion.c,158 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,159 :: 		} else {
	GOTO        L_EnviarACK17
L_EnviarACK14:
;CPComunicacion.c,160 :: 		UART2_Write(ACK);                               //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       170
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,161 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK18:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarACK19
	GOTO        L_EnviarACK18
L_EnviarACK19:
;CPComunicacion.c,162 :: 		}
L_EnviarACK17:
;CPComunicacion.c,163 :: 		}
L_end_EnviarACK:
	RETURN      0
; end of _EnviarACK

_EnviarNACK:

;CPComunicacion.c,169 :: 		void EnviarNACK(unsigned char puerto){
;CPComunicacion.c,170 :: 		if (puerto==1){
	MOVF        FARG_EnviarNACK_puerto+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK20
;CPComunicacion.c,171 :: 		RE_DE = 1;                                      //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,172 :: 		UART1_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW       175
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,173 :: 		while(UART1_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK21:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK22
	GOTO        L_EnviarNACK21
L_EnviarNACK22:
;CPComunicacion.c,174 :: 		RE_DE = 0;                                      //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,175 :: 		} else {
	GOTO        L_EnviarNACK23
L_EnviarNACK20:
;CPComunicacion.c,176 :: 		UART2_Write(NACK);                              //Envia el valor de la Cabecera de la trama ACK por el puerto UART2
	MOVLW       175
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;CPComunicacion.c,177 :: 		while(UART2_Tx_Idle()==0);                      //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK24:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarNACK25
	GOTO        L_EnviarNACK24
L_EnviarNACK25:
;CPComunicacion.c,178 :: 		}
L_EnviarNACK23:
;CPComunicacion.c,179 :: 		}
L_end_EnviarNACK:
	RETURN      0
; end of _EnviarNACK

_EnviarMensajeRS485:

;CPComunicacion.c,185 :: 		void EnviarMensajeRS485(unsigned char *PDU, unsigned char sizePDU){
;CPComunicacion.c,189 :: 		CRCPDU = CalcularCRC(PDU, sizePDU);                //Calcula el CRC de la trama PDU
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
;CPComunicacion.c,190 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW       EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+0 
	MOVLW       hi_addr(EnviarMensajeRS485_CRCPDU_L0+0)
	MOVWF       EnviarMensajeRS485_ptrCRCPDU_L0+1 
;CPComunicacion.c,192 :: 		tramaRS485[0] = HDR;                               //Añade la cabecera a la trama a enviar
	MOVLW       58
	MOVWF       _tramaRS485+0 
;CPComunicacion.c,193 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;CPComunicacion.c,194 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;CPComunicacion.c,195 :: 		tramaRS485[sizePDU+3] = END1;                      //Añade el primer delimitador de final de trama
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
;CPComunicacion.c,196 :: 		tramaRS485[sizePDU+4] = END2;                      //Añade el segundo delimitador de final de trama
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
;CPComunicacion.c,197 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,198 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO        L__EnviarMensajeRS48555
	MOVF        R1, 0 
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
L__EnviarMensajeRS48555:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48527
;CPComunicacion.c,199 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW       1
	SUBWF       EnviarMensajeRS485_i_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
	MOVF        EnviarMensajeRS485_i_L0+0, 0 
	SUBWF       FARG_EnviarMensajeRS485_sizePDU+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_EnviarMensajeRS48531
L__EnviarMensajeRS48547:
;CPComunicacion.c,201 :: 		UART1_Write(PDU[i-1]);                      //Envia el contenido de la trama PDU a travez del UART1
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
;CPComunicacion.c,202 :: 		} else {
	GOTO        L_EnviarMensajeRS48532
L_EnviarMensajeRS48531:
;CPComunicacion.c,203 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
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
;CPComunicacion.c,204 :: 		}
L_EnviarMensajeRS48532:
;CPComunicacion.c,198 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF        EnviarMensajeRS485_i_L0+0, 1 
;CPComunicacion.c,205 :: 		}
	GOTO        L_EnviarMensajeRS48526
L_EnviarMensajeRS48527:
;CPComunicacion.c,206 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48533:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_EnviarMensajeRS48534
	GOTO        L_EnviarMensajeRS48533
L_EnviarMensajeRS48534:
;CPComunicacion.c,207 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,209 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF         T1CON+0, 0 
;CPComunicacion.c,210 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;CPComunicacion.c,211 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW       11
	MOVWF       TMR1H+0 
;CPComunicacion.c,212 :: 		TMR1L = 0xDC;
	MOVLW       220
	MOVWF       TMR1L+0 
;CPComunicacion.c,213 :: 		}
L_end_EnviarMensajeRS485:
	RETURN      0
; end of _EnviarMensajeRS485

_EnviarMensajeSPI:

;CPComunicacion.c,220 :: 		void EnviarMensajeSPI(unsigned char *trama, unsigned char pduSize2){
;CPComunicacion.c,222 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        EnviarMensajeSPI_j_L0+0 
L_EnviarMensajeSPI35:
	MOVF        FARG_EnviarMensajeSPI_pduSize2+0, 0 
	SUBWF       EnviarMensajeSPI_j_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeSPI36
;CPComunicacion.c,223 :: 		pduSPI[j] = trama[j+1];
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
;CPComunicacion.c,224 :: 		UART1_Write(pduSPI[j]);
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
;CPComunicacion.c,222 :: 		for (j=0;j<pduSize2;j++){                          //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        EnviarMensajeSPI_j_L0+0, 1 
;CPComunicacion.c,225 :: 		}
	GOTO        L_EnviarMensajeSPI35
L_EnviarMensajeSPI36:
;CPComunicacion.c,226 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,227 :: 		Delay_ms(1);
	MOVLW       7
	MOVWF       R12, 0
	MOVLW       125
	MOVWF       R13, 0
L_EnviarMensajeSPI38:
	DECFSZ      R13, 1, 1
	BRA         L_EnviarMensajeSPI38
	DECFSZ      R12, 1, 1
	BRA         L_EnviarMensajeSPI38
;CPComunicacion.c,228 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,229 :: 		}
L_end_EnviarMensajeSPI:
	RETURN      0
; end of _EnviarMensajeSPI

_EnviarErrorSPI:

;CPComunicacion.c,235 :: 		void EnviarErrorSPI(unsigned char *trama, unsigned short codigoError){
;CPComunicacion.c,236 :: 		pduSPI[0] = trama[0];                              //Guarda el identificador de la trama PDU de peticion
	MOVFF       FARG_EnviarErrorSPI_trama+0, FSR0
	MOVFF       FARG_EnviarErrorSPI_trama+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _pduSPI+0 
;CPComunicacion.c,237 :: 		pduSPI[1] = 0xEE;                                  //Agrega el codigo 0xEE para indicar que se trata de un mensaje de error
	MOVLW       238
	MOVWF       _pduSPI+1 
;CPComunicacion.c,238 :: 		pduSPI[2] = trama[2];                              //Guarda el numero de registro que se queria leer o escribir
	MOVLW       2
	ADDWF       FARG_EnviarErrorSPI_trama+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_EnviarErrorSPI_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _pduSPI+2 
;CPComunicacion.c,239 :: 		pduSPI[3] = 0x01;                                  //Indica eñ numero de bytes de pyload que se va a enviar
	MOVLW       1
	MOVWF       _pduSPI+3 
;CPComunicacion.c,240 :: 		pduSPI[4] = codigoError;                           //Agrega el codigo de error producido
	MOVF        FARG_EnviarErrorSPI_codigoError+0, 0 
	MOVWF       _pduSPI+4 
;CPComunicacion.c,241 :: 		t1Size = 5;
	MOVLW       5
	MOVWF       _t1Size+0 
;CPComunicacion.c,242 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,243 :: 		Delay_ms(1);
	MOVLW       7
	MOVWF       R12, 0
	MOVLW       125
	MOVWF       R13, 0
L_EnviarErrorSPI39:
	DECFSZ      R13, 1, 1
	BRA         L_EnviarErrorSPI39
	DECFSZ      R12, 1, 1
	BRA         L_EnviarErrorSPI39
;CPComunicacion.c,244 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,245 :: 		}
L_end_EnviarErrorSPI:
	RETURN      0
; end of _EnviarErrorSPI

_ProbarSPI:

;CPComunicacion.c,250 :: 		void ProbarSPI(){
;CPComunicacion.c,254 :: 		}
L_end_ProbarSPI:
	RETURN      0
; end of _ProbarSPI

_interrupt:

;CPComunicacion.c,259 :: 		void interrupt(void){
;CPComunicacion.c,262 :: 		if (PIR1.SSP1IF){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt40
;CPComunicacion.c,264 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;CPComunicacion.c,265 :: 		buffer = SSPBUF;                                //Guarda el contenido del bufeer (lectura)
	MOVF        SSPBUF+0, 0 
	MOVWF       _buffer+0 
;CPComunicacion.c,266 :: 		AUX = 1;
	BSF         RB3_bit+0, BitPos(RB3_bit+0) 
;CPComunicacion.c,267 :: 		Delay_us(2);
	MOVLW       3
	MOVWF       R13, 0
L_interrupt41:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt41
;CPComunicacion.c,268 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;CPComunicacion.c,291 :: 		}
L_interrupt40:
;CPComunicacion.c,295 :: 		if (INTCON.INT0IF==1){
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt42
;CPComunicacion.c,296 :: 		INTCON.INT0IF = 0;                                //Limpia la badera de interrupcion externa
	BCF         INTCON+0, 1 
;CPComunicacion.c,298 :: 		if (banBoton==0){
	MOVF        _banBoton+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt43
;CPComunicacion.c,299 :: 		UART1_Write(0x2A);
	MOVLW       42
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;CPComunicacion.c,300 :: 		RInt = 1;                                          //Envia el pulso para generar la interrupcion externa en la RPi
	BSF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,301 :: 		Delay_ms(1);
	MOVLW       7
	MOVWF       R12, 0
	MOVLW       125
	MOVWF       R13, 0
L_interrupt44:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt44
	DECFSZ      R12, 1, 1
	BRA         L_interrupt44
;CPComunicacion.c,302 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,303 :: 		banBoton = 1;
	MOVLW       1
	MOVWF       _banBoton+0 
;CPComunicacion.c,304 :: 		}
L_interrupt43:
;CPComunicacion.c,305 :: 		}
L_interrupt42:
;CPComunicacion.c,307 :: 		}
L_end_interrupt:
L__interrupt60:
	RETFIE      1
; end of _interrupt

_main:

;CPComunicacion.c,311 :: 		void main() {
;CPComunicacion.c,313 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;CPComunicacion.c,314 :: 		RE_DE = 0;                                               //Establece el Max485-1 en modo de lectura;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;CPComunicacion.c,315 :: 		RInt = 0;
	BCF         RC1_bit+0, BitPos(RC1_bit+0) 
;CPComunicacion.c,316 :: 		i1=0;
	CLRF        _i1+0 
;CPComunicacion.c,317 :: 		contadorTOD = 0;                                         //Inicia el contador de Time-Out-Dispositivo
	CLRF        _contadorTOD+0 
;CPComunicacion.c,318 :: 		contadorNACK = 0;                                        //Inicia el contador de NACK
	CLRF        _contadorNACK+0 
;CPComunicacion.c,319 :: 		banTI=0;                                                 //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;CPComunicacion.c,320 :: 		banTC=0;                                                 //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;CPComunicacion.c,321 :: 		banTF=0;                                                 //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;CPComunicacion.c,322 :: 		banEsc = 0;
	CLRF        _banEsc+0 
;CPComunicacion.c,323 :: 		banBoton = 0;
	CLRF        _banBoton+0 
;CPComunicacion.c,325 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;CPComunicacion.c,326 :: 		t1Size = 0;
	CLRF        _t1Size+0 
;CPComunicacion.c,328 :: 		while(1){
L_main45:
;CPComunicacion.c,339 :: 		}
	GOTO        L_main45
;CPComunicacion.c,341 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
