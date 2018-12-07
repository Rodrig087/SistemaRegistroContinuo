
_ConfiguracionPrincipal:

;EsclavoComunicacion.c,75 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacion.c,77 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoComunicacion.c,78 :: 		TRISB2_bit = 0;
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;EsclavoComunicacion.c,79 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoComunicacion.c,80 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoComunicacion.c,82 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoComunicacion.c,83 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoComunicacion.c,86 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoComunicacion.c,87 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoComunicacion.c,90 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      2
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoComunicacion.c,93 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;EsclavoComunicacion.c,94 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;EsclavoComunicacion.c,95 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;EsclavoComunicacion.c,96 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;EsclavoComunicacion.c,97 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;EsclavoComunicacion.c,98 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;EsclavoComunicacion.c,101 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;EsclavoComunicacion.c,102 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,103 :: 		PIR1.TMR2IF = 0;
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,104 :: 		PIE1.TMR2IE = 1;
	BSF        PIE1+0, 1
;EsclavoComunicacion.c,107 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EsclavoComunicacion.c,108 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,109 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EsclavoComunicacion.c,111 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_ConfiguracionPrincipal0:
	DECFSZ     R13+0, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R12+0, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R11+0, 1
	GOTO       L_ConfiguracionPrincipal0
	NOP
;EsclavoComunicacion.c,113 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacion.c,119 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacion.c,122 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EsclavoComunicacion.c,123 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EsclavoComunicacion.c,124 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EsclavoComunicacion.c,125 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EsclavoComunicacion.c,126 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacion.c,128 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EsclavoComunicacion.c,124 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EsclavoComunicacion.c,129 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacion.c,122 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EsclavoComunicacion.c,130 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacion.c,131 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EsclavoComunicacion.c,132 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeUART:

;EsclavoComunicacion.c,138 :: 		void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
;EsclavoComunicacion.c,142 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeUART_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+1
;EsclavoComunicacion.c,143 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeUART_CRCPDU_L0+0
	MOVWF      EnviarMensajeUART_ptrCRCPDU_L0+0
;EsclavoComunicacion.c,145 :: 		tramaSerial[0]=HDR;                                //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,146 :: 		tramaSerial[sizePDU+2] = *ptrCrcPdu;               //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVLW      2
	ADDWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      R1+0
	MOVF       EnviarMensajeUART_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,147 :: 		tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);           //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	MOVF       FARG_EnviarMensajeUART_sizePDU+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      R1+0
	INCF       EnviarMensajeUART_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,148 :: 		tramaSerial[sizePDU+3] = END1;                     //Añade el primer delimitador de final de trama
	MOVLW      3
	ADDWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVLW      13
	MOVWF      INDF+0
;EsclavoComunicacion.c,149 :: 		tramaSerial[sizePDU+4] = END2;                     //Añade el segundo delimitador de final de trama
	MOVLW      4
	ADDWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVLW      10
	MOVWF      INDF+0
;EsclavoComunicacion.c,150 :: 		for (i=0;i<(sizePDU+5);i++){
	CLRF       EnviarMensajeUART_i_L0+0
L_EnviarMensajeUART9:
	MOVLW      5
	ADDWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      R1+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__EnviarMensajeUART101
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeUART_i_L0+0, 0
L__EnviarMensajeUART101:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeUART10
;EsclavoComunicacion.c,151 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeUART_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
	MOVF       EnviarMensajeUART_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
L__EnviarMensajeUART96:
;EsclavoComunicacion.c,152 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
	MOVLW      1
	SUBWF      EnviarMensajeUART_i_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_EnviarMensajeUART_tramaPDU+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,153 :: 		} else {
	GOTO       L_EnviarMensajeUART15
L_EnviarMensajeUART14:
;EsclavoComunicacion.c,154 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeUART_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,155 :: 		}
L_EnviarMensajeUART15:
;EsclavoComunicacion.c,150 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeUART_i_L0+0, 1
;EsclavoComunicacion.c,156 :: 		}
	GOTO       L_EnviarMensajeUART9
L_EnviarMensajeUART10:
;EsclavoComunicacion.c,157 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeUART16:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeUART17
	GOTO       L_EnviarMensajeUART16
L_EnviarMensajeUART17:
;EsclavoComunicacion.c,165 :: 		}
L_end_EnviarMensajeUART:
	RETURN
; end of _EnviarMensajeUART

_EnviarMensajeError:

;EsclavoComunicacion.c,171 :: 		void EnviarMensajeError(unsigned short codigoError, unsigned short numRegistro){
;EsclavoComunicacion.c,176 :: 		errorPDU[0] = idEsclavo;
	MOVF       _idEsclavo+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+0
;EsclavoComunicacion.c,177 :: 		errorPDU[1] = 0xEE;                                //Cambia el valor del campo Funcion por el codigo 0xEE para indicar que se ha producido un error
	MOVLW      238
	MOVWF      EnviarMensajeError_errorPDU_L0+1
;EsclavoComunicacion.c,178 :: 		errorPDU[2] = numRegistro;                         //Numero de registro que se solocito leer/escribir
	MOVF       FARG_EnviarMensajeError_numRegistro+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+2
;EsclavoComunicacion.c,179 :: 		errorPDU[3] = 0x01;                                //Numero de datos del pyload de la trama PDU
	MOVLW      1
	MOVWF      EnviarMensajeError_errorPDU_L0+3
;EsclavoComunicacion.c,180 :: 		errorPDU[4] = codigoError;                         //Codigo de error producido
	MOVF       FARG_EnviarMensajeError_codigoError+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+4
;EsclavoComunicacion.c,181 :: 		CRCerrorPDU = CalcularCRC(errorPDU,5);             //Calcula el CRC de la trama errorPDU
	MOVLW      EnviarMensajeError_errorPDU_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVLW      5
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+1
;EsclavoComunicacion.c,182 :: 		ptrCRCerrorPDU = &CRCerrorPDU;                     //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVWF      EnviarMensajeError_ptrCRCerrorPDU_L0+0
;EsclavoComunicacion.c,184 :: 		tramaSerial[0] = HDR;                              //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,185 :: 		tramaSerial[6] = *(ptrCRCerrorPDU+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	INCF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+6
;EsclavoComunicacion.c,186 :: 		tramaSerial[7] = *ptrCRCerrorPDU;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+7
;EsclavoComunicacion.c,187 :: 		tramaSerial[8] = END1;                             //Añade el primer delimitador de final de trama
	MOVLW      13
	MOVWF      _tramaSerial+8
;EsclavoComunicacion.c,188 :: 		tramaSerial[9] = END2;                             //Añade el segundo delimitador de final de trama
	MOVLW      10
	MOVWF      _tramaSerial+9
;EsclavoComunicacion.c,189 :: 		for (i=0;i<(10);i++){
	CLRF       EnviarMensajeError_i_L0+0
L_EnviarMensajeError18:
	MOVLW      10
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeError19
;EsclavoComunicacion.c,190 :: 		if ((i>=1)&&(i<=5)){
	MOVLW      1
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
	MOVF       EnviarMensajeError_i_L0+0, 0
	SUBLW      5
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
L__EnviarMensajeError97:
;EsclavoComunicacion.c,191 :: 		UART1_Write(errorPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
	MOVLW      1
	SUBWF      EnviarMensajeError_i_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      EnviarMensajeError_errorPDU_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,192 :: 		} else {
	GOTO       L_EnviarMensajeError24
L_EnviarMensajeError23:
;EsclavoComunicacion.c,193 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeError_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,194 :: 		}
L_EnviarMensajeError24:
;EsclavoComunicacion.c,189 :: 		for (i=0;i<(10);i++){
	INCF       EnviarMensajeError_i_L0+0, 1
;EsclavoComunicacion.c,195 :: 		}
	GOTO       L_EnviarMensajeError18
L_EnviarMensajeError19:
;EsclavoComunicacion.c,196 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeError25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeError26
	GOTO       L_EnviarMensajeError25
L_EnviarMensajeError26:
;EsclavoComunicacion.c,197 :: 		}
L_end_EnviarMensajeError:
	RETURN
; end of _EnviarMensajeError

_VerificarCRC:

;EsclavoComunicacion.c,204 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacion.c,212 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,213 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EsclavoComunicacion.c,215 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC27:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC28
;EsclavoComunicacion.c,216 :: 		pdu[j] = trama[j+1];
	MOVF       VerificarCRC_j_L0+0, 0
	ADDLW      VerificarCRC_pdu_L0+0
	MOVWF      R2+0
	MOVF       VerificarCRC_j_L0+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,215 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EsclavoComunicacion.c,217 :: 		}
	GOTO       L_VerificarCRC27
L_VerificarCRC28:
;EsclavoComunicacion.c,219 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,221 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EsclavoComunicacion.c,222 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW      2
	ADDWF      FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       VerificarCRC_ptrCRCTrama_L0+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,223 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	INCF       VerificarCRC_ptrCRCTrama_L0+0, 0
	MOVWF      R2+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,225 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC104
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC104:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC30
;EsclavoComunicacion.c,226 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EsclavoComunicacion.c,227 :: 		} else {
L_VerificarCRC30:
;EsclavoComunicacion.c,228 :: 		return 0;
	CLRF       R0+0
;EsclavoComunicacion.c,230 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacion.c,236 :: 		void EnviarACK(){
;EsclavoComunicacion.c,237 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,238 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK32:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK33
	GOTO       L_EnviarACK32
L_EnviarACK33:
;EsclavoComunicacion.c,239 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacion.c,245 :: 		void EnviarNACK(){
;EsclavoComunicacion.c,246 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,247 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK34:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK35
	GOTO       L_EnviarNACK34
L_EnviarNACK35:
;EsclavoComunicacion.c,248 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_IdentificarEsclavo:

;EsclavoComunicacion.c,254 :: 		void IdentificarEsclavo(){
;EsclavoComunicacion.c,255 :: 		petSPI[0] = 0xA0;
	MOVLW      160
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,256 :: 		petSPI[1] = 0xA1;
	MOVLW      161
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,257 :: 		petSPI[2] = 0xA2;
	MOVLW      162
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,258 :: 		petSPI[3] = 0xA3;
	MOVLW      163
	MOVWF      _petSPI+3
;EsclavoComunicacion.c,259 :: 		petSPI[4] = 0xA4;
	MOVLW      164
	MOVWF      _petSPI+4
;EsclavoComunicacion.c,260 :: 		petSPI[5] = 0xA5;
	MOVLW      165
	MOVWF      _petSPI+5
;EsclavoComunicacion.c,261 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,262 :: 		for (x=0;x<6;x++){
	CLRF       _x+0
L_IdentificarEsclavo36:
	MOVLW      6
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_IdentificarEsclavo37
;EsclavoComunicacion.c,263 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,264 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo39
;EsclavoComunicacion.c,265 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo40:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo41
	GOTO       L_IdentificarEsclavo40
L_IdentificarEsclavo41:
;EsclavoComunicacion.c,266 :: 		idEsclavo = SSPBUF;               //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _idEsclavo+0
;EsclavoComunicacion.c,267 :: 		}
L_IdentificarEsclavo39:
;EsclavoComunicacion.c,268 :: 		if (x==3){
	MOVF       _x+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo42
;EsclavoComunicacion.c,269 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo43:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo44
	GOTO       L_IdentificarEsclavo43
L_IdentificarEsclavo44:
;EsclavoComunicacion.c,270 :: 		funcEsclavo = SSPBUF;              //Recupera el numero de funciones disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _funcEsclavo+0
;EsclavoComunicacion.c,271 :: 		}
L_IdentificarEsclavo42:
;EsclavoComunicacion.c,272 :: 		if (x==4){
	MOVF       _x+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo45
;EsclavoComunicacion.c,273 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo46:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo47
	GOTO       L_IdentificarEsclavo46
L_IdentificarEsclavo47:
;EsclavoComunicacion.c,274 :: 		regLecturaEsclavo = SSPBUF;        //Recupera el numero de registros de lectura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regLecturaEsclavo+0
;EsclavoComunicacion.c,275 :: 		}
L_IdentificarEsclavo45:
;EsclavoComunicacion.c,276 :: 		if (x==5){
	MOVF       _x+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo48
;EsclavoComunicacion.c,277 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo49:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo50
	GOTO       L_IdentificarEsclavo49
L_IdentificarEsclavo50:
;EsclavoComunicacion.c,278 :: 		regEscrituraEsclavo = SSPBUF;      //Recupera el numero de registros de escritura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regEscrituraEsclavo+0
;EsclavoComunicacion.c,279 :: 		}
L_IdentificarEsclavo48:
;EsclavoComunicacion.c,281 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_IdentificarEsclavo51:
	DECFSZ     R13+0, 1
	GOTO       L_IdentificarEsclavo51
	DECFSZ     R12+0, 1
	GOTO       L_IdentificarEsclavo51
	NOP
	NOP
;EsclavoComunicacion.c,262 :: 		for (x=0;x<6;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,282 :: 		}
	GOTO       L_IdentificarEsclavo36
L_IdentificarEsclavo37:
;EsclavoComunicacion.c,283 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,284 :: 		}
L_end_IdentificarEsclavo:
	RETURN
; end of _IdentificarEsclavo

_EnviarSolicitudLectura:

;EsclavoComunicacion.c,290 :: 		void EnviarSolicitudLectura(unsigned short registroEsclavo){
;EsclavoComunicacion.c,291 :: 		petSPI[0] = 0xB0;                        //Cabecera de trama de solicitud de medicion
	MOVLW      176
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,292 :: 		petSPI[1] = registroEsclavo;             //Codigo del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudLectura_registroEsclavo+0, 0
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,293 :: 		petSPI[2] = 0xB1;                        //Delimitador de final de trama
	MOVLW      177
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,294 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,295 :: 		for (x=0;x<3;x++){
	CLRF       _x+0
L_EnviarSolicitudLectura52:
	MOVLW      3
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudLectura53
;EsclavoComunicacion.c,296 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,297 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarSolicitudLectura55
;EsclavoComunicacion.c,298 :: 		while (SSPSTAT.BF!=1);
L_EnviarSolicitudLectura56:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_EnviarSolicitudLectura57
	GOTO       L_EnviarSolicitudLectura56
L_EnviarSolicitudLectura57:
;EsclavoComunicacion.c,299 :: 		numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _numBytesSPI+0
;EsclavoComunicacion.c,300 :: 		}
L_EnviarSolicitudLectura55:
;EsclavoComunicacion.c,301 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudLectura58:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudLectura58
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudLectura58
	NOP
	NOP
;EsclavoComunicacion.c,295 :: 		for (x=0;x<3;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,302 :: 		}
	GOTO       L_EnviarSolicitudLectura52
L_EnviarSolicitudLectura53:
;EsclavoComunicacion.c,303 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,304 :: 		banMed = 1;                              //Activa la bandera de medicion para evitar que existan falsos positivos en la interrupcion externa
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoComunicacion.c,305 :: 		}
L_end_EnviarSolicitudLectura:
	RETURN
; end of _EnviarSolicitudLectura

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;EsclavoComunicacion.c,311 :: 		void interrupt(){
;EsclavoComunicacion.c,315 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt59
;EsclavoComunicacion.c,316 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,317 :: 		if (banMed==1){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt60
;EsclavoComunicacion.c,319 :: 		CS = 0;                                      //Coloca en bajo el pin CS para abrir la transmision
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,320 :: 		for (x=0;x<(numBytesSPI+1);x++){
	CLRF       _x+0
L_interrupt61:
	MOVF       _numBytesSPI+0, 0
	ADDLW      1
	MOVWF      R1+0
	CLRF       R1+1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVLW      128
	MOVWF      R0+0
	MOVLW      128
	XORWF      R1+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt111
	MOVF       R1+0, 0
	SUBWF      _x+0, 0
L__interrupt111:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt62
;EsclavoComunicacion.c,321 :: 		SSPBUF = 0xCC;                           //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
	MOVLW      204
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,322 :: 		if ((x>0)){
	MOVF       _x+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt64
;EsclavoComunicacion.c,323 :: 		while (SSPSTAT.BF!=1);
L_interrupt65:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt66
	GOTO       L_interrupt65
L_interrupt66:
;EsclavoComunicacion.c,324 :: 		resSPI[x+3] = SSPBUF;                 //Guarda la respuesta del EsclavoSensor en el vector resSPI a partir de la cuarta posicion
	MOVLW      3
	ADDWF      _x+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _resSPI+0
	MOVWF      FSR
	MOVF       SSPBUF+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,325 :: 		}
L_interrupt64:
;EsclavoComunicacion.c,326 :: 		Delay_us(200);
	MOVLW      133
	MOVWF      R13+0
L_interrupt67:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt67
;EsclavoComunicacion.c,320 :: 		for (x=0;x<(numBytesSPI+1);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,327 :: 		}
	GOTO       L_interrupt61
L_interrupt62:
;EsclavoComunicacion.c,328 :: 		CS = 1;                                      //Coloca en alto el pin CS para cerrar la transmision
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,330 :: 		resSPI[0] = idEsclavo;                       //Guarda en la primera posicion del vector PDU de respuesta el id del Esclavo
	MOVF       _idEsclavo+0, 0
	MOVWF      _resSPI+0
;EsclavoComunicacion.c,331 :: 		resSPI[1] = t1Funcion;                       //Guarda en la segunda posicion del vector PDU el codigo de funcion requerido
	MOVF       _t1Funcion+0, 0
	MOVWF      _resSPI+1
;EsclavoComunicacion.c,332 :: 		resSPI[2] = t1Registro;                      //Guarda en la tercera posicion del vector PDU el # de registro requerido
	MOVF       _t1Registro+0, 0
	MOVWF      _resSPI+2
;EsclavoComunicacion.c,333 :: 		resSPI[3] = numBytesSPI;                     //Guarda en la cuarta posicion del vector PDU de respuesta el numero de bytes del payload
	MOVF       _numBytesSPI+0, 0
	MOVWF      _resSPI+3
;EsclavoComunicacion.c,335 :: 		}
L_interrupt60:
;EsclavoComunicacion.c,336 :: 		banMed=0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,338 :: 		EnviarMensajeUART(resSPI,(numBytesSPI+4));
	MOVLW      _resSPI+0
	MOVWF      FARG_EnviarMensajeUART_tramaPDU+0
	MOVLW      4
	ADDWF      _numBytesSPI+0, 0
	MOVWF      FARG_EnviarMensajeUART_sizePDU+0
	CALL       _EnviarMensajeUART+0
;EsclavoComunicacion.c,340 :: 		}
L_interrupt59:
;EsclavoComunicacion.c,348 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt68
;EsclavoComunicacion.c,350 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,351 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoComunicacion.c,352 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,354 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt69
;EsclavoComunicacion.c,355 :: 		if ((byteTrama==ACK)){                          //Verifica si recibio un ACK
	MOVF       _byteTrama+0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt70
;EsclavoComunicacion.c,357 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,358 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,359 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,360 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,361 :: 		}
L_interrupt70:
;EsclavoComunicacion.c,363 :: 		if ((byteTrama==NACK)){                         //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt71
;EsclavoComunicacion.c,365 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,366 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,367 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt72
;EsclavoComunicacion.c,369 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;EsclavoComunicacion.c,370 :: 		} else {
	GOTO       L_interrupt73
L_interrupt72:
;EsclavoComunicacion.c,371 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,372 :: 		}
L_interrupt73:
;EsclavoComunicacion.c,373 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,374 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,375 :: 		}
L_interrupt71:
;EsclavoComunicacion.c,377 :: 		if ((byteTrama==HDR)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt74
;EsclavoComunicacion.c,378 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoComunicacion.c,379 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,380 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,382 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,383 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,384 :: 		}
L_interrupt74:
;EsclavoComunicacion.c,385 :: 		}
L_interrupt69:
;EsclavoComunicacion.c,387 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt75
;EsclavoComunicacion.c,388 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,389 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,390 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt76
;EsclavoComunicacion.c,391 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,392 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoComunicacion.c,393 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoComunicacion.c,394 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,395 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,396 :: 		} else {
	GOTO       L_interrupt77
L_interrupt76:
;EsclavoComunicacion.c,397 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,398 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoComunicacion.c,399 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,400 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,401 :: 		}
L_interrupt77:
;EsclavoComunicacion.c,402 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt78
;EsclavoComunicacion.c,403 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoComunicacion.c,404 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoComunicacion.c,405 :: 		t1IdEsclavo = tramaSerial[1];             //Guarda el byte de Id de esclavo del campo PDU
	MOVF       _tramaSerial+1, 0
	MOVWF      _t1IdEsclavo+0
;EsclavoComunicacion.c,406 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,407 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,408 :: 		}
L_interrupt78:
;EsclavoComunicacion.c,409 :: 		}
L_interrupt75:
;EsclavoComunicacion.c,411 :: 		if (banTC==1){                                             //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt79
;EsclavoComunicacion.c,412 :: 		if (t1IdEsclavo==IdEsclavo){                            //Verifica si coincide el Id de esclavo para seguir con el procesamiento de la peticion
	MOVF       _t1IdEsclavo+0, 0
	XORWF      _idEsclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt80
;EsclavoComunicacion.c,413 :: 		t1Size = tramaSerial[4]+4;                          //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
	MOVLW      4
	ADDWF      _tramaSerial+4, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _t1Size+0
;EsclavoComunicacion.c,414 :: 		t1Funcion = tramaSerial[2];                         //Guarda el byte de funcion reequerida del campo PDU
	MOVF       _tramaSerial+2, 0
	MOVWF      _t1Funcion+0
;EsclavoComunicacion.c,415 :: 		t1Registro = tramaSerial[3];                        //Guarda el byte de # de registro que se quiere leer/escribir
	MOVF       _tramaSerial+3, 0
	MOVWF      _t1Registro+0
;EsclavoComunicacion.c,416 :: 		tramaOk = VerificarCRC(tramaSerial,t1Size);         //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaSerial+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       R0+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,417 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt81
;EsclavoComunicacion.c,418 :: 		EnviarACK();                                    //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EsclavoComunicacion.c,421 :: 		if (t1Funcion<=funcEsclavo){
	MOVF       _t1Funcion+0, 0
	SUBWF      _funcEsclavo+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt82
;EsclavoComunicacion.c,422 :: 		if (t1Funcion==0){                           //Verifica si se solicito una funcion de lectura
	MOVF       _t1Funcion+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt83
;EsclavoComunicacion.c,423 :: 		if (t1Registro<regLecturaEsclavo){        //Verifica si existe el registro de lectura solicitado
	MOVF       _regLecturaEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt84
;EsclavoComunicacion.c,424 :: 		EnviarSolicitudLectura(t1Registro);    //Envia una solicitud de lectura del registro especificado al modulo EsclavoSensor
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarSolicitudLectura_registroEsclavo+0
	CALL       _EnviarSolicitudLectura+0
;EsclavoComunicacion.c,425 :: 		} else {
	GOTO       L_interrupt85
L_interrupt84:
;EsclavoComunicacion.c,426 :: 		EnviarMensajeError(0xE1,t1Registro);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,427 :: 		}
L_interrupt85:
;EsclavoComunicacion.c,428 :: 		} else {                                     //Caso contrario se trata de una funcion de escritura
	GOTO       L_interrupt86
L_interrupt83:
;EsclavoComunicacion.c,429 :: 		if (t1Registro<regEscrituraEsclavo){      //Verifica si existe el registro de lectura solicitado
	MOVF       _regEscrituraEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt87
;EsclavoComunicacion.c,431 :: 		} else {
	GOTO       L_interrupt88
L_interrupt87:
;EsclavoComunicacion.c,432 :: 		EnviarMensajeError(0xE1,t1Registro);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,433 :: 		}
L_interrupt88:
;EsclavoComunicacion.c,434 :: 		}
L_interrupt86:
;EsclavoComunicacion.c,435 :: 		} else {
	GOTO       L_interrupt89
L_interrupt82:
;EsclavoComunicacion.c,436 :: 		EnviarMensajeError(0xE0,t1Registro);         //Envia un mensaje de error con el codigo de "Funcion no disponible"
	MOVLW      224
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,437 :: 		}
L_interrupt89:
;EsclavoComunicacion.c,438 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt90
L_interrupt81:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt91
;EsclavoComunicacion.c,439 :: 		EnviarNACK();                                   //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,440 :: 		}
L_interrupt91:
L_interrupt90:
;EsclavoComunicacion.c,441 :: 		}
L_interrupt80:
;EsclavoComunicacion.c,442 :: 		banTC = 0;                               //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoComunicacion.c,443 :: 		i1 = 0;                                  //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoComunicacion.c,444 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,445 :: 		}
L_interrupt79:
;EsclavoComunicacion.c,447 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EsclavoComunicacion.c,448 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,449 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,451 :: 		}
L_interrupt68:
;EsclavoComunicacion.c,457 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt92
;EsclavoComunicacion.c,458 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,459 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,460 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt93
;EsclavoComunicacion.c,462 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;EsclavoComunicacion.c,463 :: 		} else {
	GOTO       L_interrupt94
L_interrupt93:
;EsclavoComunicacion.c,465 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,466 :: 		}
L_interrupt94:
;EsclavoComunicacion.c,467 :: 		}
L_interrupt92:
;EsclavoComunicacion.c,474 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt95
;EsclavoComunicacion.c,475 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,476 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,477 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,478 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,479 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;EsclavoComunicacion.c,480 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,481 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,482 :: 		}
L_interrupt95:
;EsclavoComunicacion.c,484 :: 		}
L_end_interrupt:
L__interrupt110:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoComunicacion.c,488 :: 		void main() {
;EsclavoComunicacion.c,490 :: 		ConfiguracionPrincipal();                          //Inicia las configuraciones necesarias
	CALL       _ConfiguracionPrincipal+0
;EsclavoComunicacion.c,491 :: 		IdentificarEsclavo();                              //Con esta funcion determina cual es el codigo identificador del dispositivo EsclavoSensor conectado por SPI
	CALL       _IdentificarEsclavo+0
;EsclavoComunicacion.c,492 :: 		CS = 1;                                            //Desabilita el CS
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,493 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,494 :: 		IU1 = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,495 :: 		i1=0;
	CLRF       _i1+0
;EsclavoComunicacion.c,496 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,497 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,498 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,499 :: 		banTC = 0;
	CLRF       _banTC+0
;EsclavoComunicacion.c,500 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,501 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,502 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
