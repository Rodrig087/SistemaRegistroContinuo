
_ConfiguracionPrincipal:

;EsclavoComunicacion.c,77 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacion.c,79 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoComunicacion.c,80 :: 		TRISB2_bit = 0;
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;EsclavoComunicacion.c,81 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoComunicacion.c,82 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoComunicacion.c,84 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoComunicacion.c,85 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoComunicacion.c,88 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoComunicacion.c,89 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoComunicacion.c,92 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      2
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoComunicacion.c,95 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;EsclavoComunicacion.c,96 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;EsclavoComunicacion.c,97 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;EsclavoComunicacion.c,98 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;EsclavoComunicacion.c,99 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;EsclavoComunicacion.c,100 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;EsclavoComunicacion.c,103 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;EsclavoComunicacion.c,104 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,105 :: 		PIR1.TMR2IF = 0;
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,106 :: 		PIE1.TMR2IE = 1;
	BSF        PIE1+0, 1
;EsclavoComunicacion.c,109 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EsclavoComunicacion.c,110 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,111 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EsclavoComunicacion.c,113 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoComunicacion.c,115 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacion.c,121 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacion.c,124 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EsclavoComunicacion.c,125 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EsclavoComunicacion.c,126 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EsclavoComunicacion.c,127 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EsclavoComunicacion.c,128 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacion.c,130 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EsclavoComunicacion.c,126 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EsclavoComunicacion.c,131 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacion.c,124 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EsclavoComunicacion.c,132 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacion.c,133 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EsclavoComunicacion.c,134 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeUART:

;EsclavoComunicacion.c,140 :: 		void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
;EsclavoComunicacion.c,144 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeUART_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+1
;EsclavoComunicacion.c,145 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeUART_CRCPDU_L0+0
	MOVWF      EnviarMensajeUART_ptrCRCPDU_L0+0
;EsclavoComunicacion.c,147 :: 		tramaSerial[0]=HDR;                                //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,148 :: 		tramaSerial[sizePDU+2] = *ptrCrcPdu;               //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;EsclavoComunicacion.c,149 :: 		tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);           //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;EsclavoComunicacion.c,150 :: 		tramaSerial[sizePDU+3] = END1;                     //Añade el primer delimitador de final de trama
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
;EsclavoComunicacion.c,151 :: 		tramaSerial[sizePDU+4] = END2;                     //Añade el segundo delimitador de final de trama
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
;EsclavoComunicacion.c,152 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeUART111
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeUART_i_L0+0, 0
L__EnviarMensajeUART111:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeUART10
;EsclavoComunicacion.c,153 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeUART_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
	MOVF       EnviarMensajeUART_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
L__EnviarMensajeUART106:
;EsclavoComunicacion.c,154 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,155 :: 		} else {
	GOTO       L_EnviarMensajeUART15
L_EnviarMensajeUART14:
;EsclavoComunicacion.c,156 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeUART_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,157 :: 		}
L_EnviarMensajeUART15:
;EsclavoComunicacion.c,152 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeUART_i_L0+0, 1
;EsclavoComunicacion.c,158 :: 		}
	GOTO       L_EnviarMensajeUART9
L_EnviarMensajeUART10:
;EsclavoComunicacion.c,159 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeUART16:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeUART17
	GOTO       L_EnviarMensajeUART16
L_EnviarMensajeUART17:
;EsclavoComunicacion.c,167 :: 		}
L_end_EnviarMensajeUART:
	RETURN
; end of _EnviarMensajeUART

_EnviarMensajeError:

;EsclavoComunicacion.c,173 :: 		void EnviarMensajeError(unsigned short numRegistro,unsigned short codigoError){
;EsclavoComunicacion.c,178 :: 		errorPDU[0] = idEsclavo;
	MOVF       _idEsclavo+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+0
;EsclavoComunicacion.c,179 :: 		errorPDU[1] = 0xEE;                                //Cambia el valor del campo Funcion por el codigo 0xEE para indicar que se ha producido un error
	MOVLW      238
	MOVWF      EnviarMensajeError_errorPDU_L0+1
;EsclavoComunicacion.c,180 :: 		errorPDU[2] = numRegistro;                         //Numero de registro que se solocito leer/escribir
	MOVF       FARG_EnviarMensajeError_numRegistro+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+2
;EsclavoComunicacion.c,181 :: 		errorPDU[3] = 0x01;                                //Numero de datos del pyload de la trama PDU
	MOVLW      1
	MOVWF      EnviarMensajeError_errorPDU_L0+3
;EsclavoComunicacion.c,182 :: 		errorPDU[4] = codigoError;                         //Codigo de error producido
	MOVF       FARG_EnviarMensajeError_codigoError+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+4
;EsclavoComunicacion.c,183 :: 		CRCerrorPDU = CalcularCRC(errorPDU,5);             //Calcula el CRC de la trama errorPDU
	MOVLW      EnviarMensajeError_errorPDU_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVLW      5
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+1
;EsclavoComunicacion.c,184 :: 		ptrCRCerrorPDU = &CRCerrorPDU;                     //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVWF      EnviarMensajeError_ptrCRCerrorPDU_L0+0
;EsclavoComunicacion.c,186 :: 		tramaSerial[0] = HDR;                              //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,187 :: 		tramaSerial[6] = *(ptrCRCerrorPDU+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	INCF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+6
;EsclavoComunicacion.c,188 :: 		tramaSerial[7] = *ptrCRCerrorPDU;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+7
;EsclavoComunicacion.c,189 :: 		tramaSerial[8] = END1;                             //Añade el primer delimitador de final de trama
	MOVLW      13
	MOVWF      _tramaSerial+8
;EsclavoComunicacion.c,190 :: 		tramaSerial[9] = END2;                             //Añade el segundo delimitador de final de trama
	MOVLW      10
	MOVWF      _tramaSerial+9
;EsclavoComunicacion.c,191 :: 		for (i=0;i<(10);i++){
	CLRF       EnviarMensajeError_i_L0+0
L_EnviarMensajeError18:
	MOVLW      10
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeError19
;EsclavoComunicacion.c,192 :: 		if ((i>=1)&&(i<=5)){
	MOVLW      1
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
	MOVF       EnviarMensajeError_i_L0+0, 0
	SUBLW      5
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
L__EnviarMensajeError107:
;EsclavoComunicacion.c,193 :: 		UART1_Write(errorPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,194 :: 		} else {
	GOTO       L_EnviarMensajeError24
L_EnviarMensajeError23:
;EsclavoComunicacion.c,195 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeError_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,196 :: 		}
L_EnviarMensajeError24:
;EsclavoComunicacion.c,191 :: 		for (i=0;i<(10);i++){
	INCF       EnviarMensajeError_i_L0+0, 1
;EsclavoComunicacion.c,197 :: 		}
	GOTO       L_EnviarMensajeError18
L_EnviarMensajeError19:
;EsclavoComunicacion.c,198 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeError25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeError26
	GOTO       L_EnviarMensajeError25
L_EnviarMensajeError26:
;EsclavoComunicacion.c,199 :: 		}
L_end_EnviarMensajeError:
	RETURN
; end of _EnviarMensajeError

_VerificarCRC:

;EsclavoComunicacion.c,206 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacion.c,214 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,215 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EsclavoComunicacion.c,217 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC27:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC28
;EsclavoComunicacion.c,218 :: 		pdu[j] = trama[j+1];
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
;EsclavoComunicacion.c,217 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EsclavoComunicacion.c,219 :: 		}
	GOTO       L_VerificarCRC27
L_VerificarCRC28:
;EsclavoComunicacion.c,221 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,223 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EsclavoComunicacion.c,224 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;EsclavoComunicacion.c,225 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;EsclavoComunicacion.c,227 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC114
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC114:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC30
;EsclavoComunicacion.c,228 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EsclavoComunicacion.c,229 :: 		} else {
L_VerificarCRC30:
;EsclavoComunicacion.c,230 :: 		return 0;
	CLRF       R0+0
;EsclavoComunicacion.c,232 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacion.c,238 :: 		void EnviarACK(){
;EsclavoComunicacion.c,239 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,240 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK32:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK33
	GOTO       L_EnviarACK32
L_EnviarACK33:
;EsclavoComunicacion.c,241 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacion.c,247 :: 		void EnviarNACK(){
;EsclavoComunicacion.c,248 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,249 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK34:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK35
	GOTO       L_EnviarNACK34
L_EnviarNACK35:
;EsclavoComunicacion.c,250 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_IdentificarEsclavo:

;EsclavoComunicacion.c,256 :: 		void IdentificarEsclavo(){
;EsclavoComunicacion.c,257 :: 		petSPI[0] = 0xA0;
	MOVLW      160
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,258 :: 		petSPI[1] = 0xA1;
	MOVLW      161
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,259 :: 		petSPI[2] = 0xA2;
	MOVLW      162
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,260 :: 		petSPI[3] = 0xA3;
	MOVLW      163
	MOVWF      _petSPI+3
;EsclavoComunicacion.c,261 :: 		petSPI[4] = 0xA4;
	MOVLW      164
	MOVWF      _petSPI+4
;EsclavoComunicacion.c,262 :: 		petSPI[5] = 0xA5;
	MOVLW      165
	MOVWF      _petSPI+5
;EsclavoComunicacion.c,263 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,264 :: 		for (x=0;x<6;x++){
	CLRF       _x+0
L_IdentificarEsclavo36:
	MOVLW      6
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_IdentificarEsclavo37
;EsclavoComunicacion.c,265 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,266 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo39
;EsclavoComunicacion.c,267 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo40:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo41
	GOTO       L_IdentificarEsclavo40
L_IdentificarEsclavo41:
;EsclavoComunicacion.c,268 :: 		idEsclavo = SSPBUF;               //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _idEsclavo+0
;EsclavoComunicacion.c,269 :: 		}
L_IdentificarEsclavo39:
;EsclavoComunicacion.c,270 :: 		if (x==3){
	MOVF       _x+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo42
;EsclavoComunicacion.c,271 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo43:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo44
	GOTO       L_IdentificarEsclavo43
L_IdentificarEsclavo44:
;EsclavoComunicacion.c,272 :: 		funcEsclavo = SSPBUF;              //Recupera el numero de funciones disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _funcEsclavo+0
;EsclavoComunicacion.c,273 :: 		}
L_IdentificarEsclavo42:
;EsclavoComunicacion.c,274 :: 		if (x==4){
	MOVF       _x+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo45
;EsclavoComunicacion.c,275 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo46:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo47
	GOTO       L_IdentificarEsclavo46
L_IdentificarEsclavo47:
;EsclavoComunicacion.c,276 :: 		regLecturaEsclavo = SSPBUF;        //Recupera el numero de registros de lectura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regLecturaEsclavo+0
;EsclavoComunicacion.c,277 :: 		}
L_IdentificarEsclavo45:
;EsclavoComunicacion.c,278 :: 		if (x==5){
	MOVF       _x+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo48
;EsclavoComunicacion.c,279 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo49:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo50
	GOTO       L_IdentificarEsclavo49
L_IdentificarEsclavo50:
;EsclavoComunicacion.c,280 :: 		regEscrituraEsclavo = SSPBUF;      //Recupera el numero de registros de escritura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regEscrituraEsclavo+0
;EsclavoComunicacion.c,281 :: 		}
L_IdentificarEsclavo48:
;EsclavoComunicacion.c,283 :: 		Delay_ms(1);
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
;EsclavoComunicacion.c,264 :: 		for (x=0;x<6;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,284 :: 		}
	GOTO       L_IdentificarEsclavo36
L_IdentificarEsclavo37:
;EsclavoComunicacion.c,285 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,286 :: 		}
L_end_IdentificarEsclavo:
	RETURN
; end of _IdentificarEsclavo

_EnviarSolicitudLectura:

;EsclavoComunicacion.c,292 :: 		void EnviarSolicitudLectura(unsigned short registroLectura){
;EsclavoComunicacion.c,293 :: 		petSPI[0] = 0xB0;                        //Cabecera de trama de solicitud de medicion
	MOVLW      176
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,294 :: 		petSPI[1] = registroLectura;             //Codigo del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudLectura_registroLectura+0, 0
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,295 :: 		petSPI[2] = 0xB1;                        //Delimitador de final de trama
	MOVLW      177
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,296 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,297 :: 		for (x=0;x<3;x++){
	CLRF       _x+0
L_EnviarSolicitudLectura52:
	MOVLW      3
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudLectura53
;EsclavoComunicacion.c,298 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,299 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarSolicitudLectura55
;EsclavoComunicacion.c,300 :: 		while (SSPSTAT.BF!=1);
L_EnviarSolicitudLectura56:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_EnviarSolicitudLectura57
	GOTO       L_EnviarSolicitudLectura56
L_EnviarSolicitudLectura57:
;EsclavoComunicacion.c,301 :: 		numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _numBytesSPI+0
;EsclavoComunicacion.c,302 :: 		}
L_EnviarSolicitudLectura55:
;EsclavoComunicacion.c,303 :: 		Delay_ms(1);
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
;EsclavoComunicacion.c,297 :: 		for (x=0;x<3;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,304 :: 		}
	GOTO       L_EnviarSolicitudLectura52
L_EnviarSolicitudLectura53:
;EsclavoComunicacion.c,305 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,306 :: 		banMed = 1;                              //Activa la bandera de medicion para evitar que existan falsos positivos en la interrupcion externa
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoComunicacion.c,307 :: 		}
L_end_EnviarSolicitudLectura:
	RETURN
; end of _EnviarSolicitudLectura

_EnviarSolicitudEscritura:

;EsclavoComunicacion.c,313 :: 		void EnviarSolicitudEscritura(unsigned short registroEscritura, unsigned short numDatos, unsigned char* datos){
;EsclavoComunicacion.c,314 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,315 :: 		SSPBUF = 0XD0;                           //Llena el buffer de salida con el valor de la cabecera de solicitud de escritura
	MOVLW      208
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,316 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudEscritura59:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudEscritura59
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudEscritura59
	NOP
	NOP
;EsclavoComunicacion.c,317 :: 		SSPBUF = registroEscritura;              //Llena el buffer de salida con el valor del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudEscritura_registroEscritura+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,318 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudEscritura60:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudEscritura60
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudEscritura60
	NOP
	NOP
;EsclavoComunicacion.c,319 :: 		SSPBUF = numDatos;                       //Llena el buffer de salida con el valor del numero de datos
	MOVF       FARG_EnviarSolicitudEscritura_numDatos+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,320 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudEscritura61:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudEscritura61
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudEscritura61
	NOP
	NOP
;EsclavoComunicacion.c,321 :: 		for (x=0;x<numDatos;x++){
	CLRF       _x+0
L_EnviarSolicitudEscritura62:
	MOVF       FARG_EnviarSolicitudEscritura_numDatos+0, 0
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudEscritura63
;EsclavoComunicacion.c,322 :: 		SSPBUF = datos[x];                   //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDWF      FARG_EnviarSolicitudEscritura_datos+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,323 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudEscritura65:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudEscritura65
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudEscritura65
	NOP
	NOP
;EsclavoComunicacion.c,321 :: 		for (x=0;x<numDatos;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,324 :: 		}
	GOTO       L_EnviarSolicitudEscritura62
L_EnviarSolicitudEscritura63:
;EsclavoComunicacion.c,325 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,327 :: 		}
L_end_EnviarSolicitudEscritura:
	RETURN
; end of _EnviarSolicitudEscritura

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;EsclavoComunicacion.c,333 :: 		void interrupt(){
;EsclavoComunicacion.c,337 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt66
;EsclavoComunicacion.c,338 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,339 :: 		if (banMed==1){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt67
;EsclavoComunicacion.c,341 :: 		CS = 0;                                      //Coloca en bajo el pin CS para abrir la transmision
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,342 :: 		for (x=0;x<(numBytesSPI+1);x++){
	CLRF       _x+0
L_interrupt68:
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
	GOTO       L__interrupt122
	MOVF       R1+0, 0
	SUBWF      _x+0, 0
L__interrupt122:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt69
;EsclavoComunicacion.c,343 :: 		SSPBUF = 0xCC;                           //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
	MOVLW      204
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,344 :: 		if ((x>0)){
	MOVF       _x+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt71
;EsclavoComunicacion.c,345 :: 		while (SSPSTAT.BF!=1);
L_interrupt72:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt73
	GOTO       L_interrupt72
L_interrupt73:
;EsclavoComunicacion.c,346 :: 		resSPI[x+3] = SSPBUF;                 //Guarda la respuesta del EsclavoSensor en el vector resSPI a partir de la cuarta posicion
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
;EsclavoComunicacion.c,347 :: 		}
L_interrupt71:
;EsclavoComunicacion.c,348 :: 		Delay_us(200);
	MOVLW      133
	MOVWF      R13+0
L_interrupt74:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt74
;EsclavoComunicacion.c,342 :: 		for (x=0;x<(numBytesSPI+1);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,349 :: 		}
	GOTO       L_interrupt68
L_interrupt69:
;EsclavoComunicacion.c,350 :: 		CS = 1;                                      //Coloca en alto el pin CS para cerrar la transmision
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,352 :: 		resSPI[0] = idEsclavo;                       //Guarda en la primera posicion del vector PDU de respuesta el id del Esclavo
	MOVF       _idEsclavo+0, 0
	MOVWF      _resSPI+0
;EsclavoComunicacion.c,353 :: 		resSPI[1] = t1Funcion;                       //Guarda en la segunda posicion del vector PDU el codigo de funcion requerido
	MOVF       _t1Funcion+0, 0
	MOVWF      _resSPI+1
;EsclavoComunicacion.c,354 :: 		resSPI[2] = t1Registro;                      //Guarda en la tercera posicion del vector PDU el # de registro requerido
	MOVF       _t1Registro+0, 0
	MOVWF      _resSPI+2
;EsclavoComunicacion.c,355 :: 		resSPI[3] = numBytesSPI;                     //Guarda en la cuarta posicion del vector PDU de respuesta el numero de bytes del payload
	MOVF       _numBytesSPI+0, 0
	MOVWF      _resSPI+3
;EsclavoComunicacion.c,357 :: 		}
L_interrupt67:
;EsclavoComunicacion.c,358 :: 		banMed=0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,360 :: 		EnviarMensajeUART(resSPI,(numBytesSPI+4));
	MOVLW      _resSPI+0
	MOVWF      FARG_EnviarMensajeUART_tramaPDU+0
	MOVLW      4
	ADDWF      _numBytesSPI+0, 0
	MOVWF      FARG_EnviarMensajeUART_sizePDU+0
	CALL       _EnviarMensajeUART+0
;EsclavoComunicacion.c,362 :: 		}
L_interrupt66:
;EsclavoComunicacion.c,370 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt75
;EsclavoComunicacion.c,372 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,373 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoComunicacion.c,374 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,376 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt76
;EsclavoComunicacion.c,377 :: 		if ((byteTrama==ACK)){                          //Verifica si recibio un ACK
	MOVF       _byteTrama+0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt77
;EsclavoComunicacion.c,379 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,380 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,381 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,382 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,383 :: 		}
L_interrupt77:
;EsclavoComunicacion.c,385 :: 		if ((byteTrama==NACK)){                         //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt78
;EsclavoComunicacion.c,387 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,388 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,389 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt79
;EsclavoComunicacion.c,391 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;EsclavoComunicacion.c,392 :: 		} else {
	GOTO       L_interrupt80
L_interrupt79:
;EsclavoComunicacion.c,393 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,394 :: 		}
L_interrupt80:
;EsclavoComunicacion.c,395 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,396 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,397 :: 		}
L_interrupt78:
;EsclavoComunicacion.c,399 :: 		if ((byteTrama==HDR)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt81
;EsclavoComunicacion.c,400 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoComunicacion.c,401 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,402 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,404 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,405 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,406 :: 		}
L_interrupt81:
;EsclavoComunicacion.c,407 :: 		}
L_interrupt76:
;EsclavoComunicacion.c,409 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt82
;EsclavoComunicacion.c,410 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,411 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,412 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt83
;EsclavoComunicacion.c,413 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,414 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoComunicacion.c,415 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoComunicacion.c,416 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,417 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,418 :: 		} else {
	GOTO       L_interrupt84
L_interrupt83:
;EsclavoComunicacion.c,419 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,420 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoComunicacion.c,421 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,422 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,423 :: 		}
L_interrupt84:
;EsclavoComunicacion.c,424 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt85
;EsclavoComunicacion.c,425 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoComunicacion.c,426 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoComunicacion.c,427 :: 		t1IdEsclavo = tramaSerial[1];             //Guarda el byte de Id de esclavo del campo PDU
	MOVF       _tramaSerial+1, 0
	MOVWF      _t1IdEsclavo+0
;EsclavoComunicacion.c,428 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,429 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,430 :: 		}
L_interrupt85:
;EsclavoComunicacion.c,431 :: 		}
L_interrupt82:
;EsclavoComunicacion.c,433 :: 		if (banTC==1){                                             //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt86
;EsclavoComunicacion.c,434 :: 		if (t1IdEsclavo==IdEsclavo){                            //Verifica si coincide el Id de esclavo para seguir con el procesamiento de la peticion
	MOVF       _t1IdEsclavo+0, 0
	XORWF      _idEsclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt87
;EsclavoComunicacion.c,435 :: 		numDatosEsc = tramaSerial[4];
	MOVF       _tramaSerial+4, 0
	MOVWF      _numDatosEsc+0
;EsclavoComunicacion.c,436 :: 		t1Size = numDatosEsc+4;                             //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
	MOVLW      4
	ADDWF      _tramaSerial+4, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _t1Size+0
;EsclavoComunicacion.c,437 :: 		t1Funcion = tramaSerial[2];                         //Guarda el byte de funcion reequerida del campo PDU
	MOVF       _tramaSerial+2, 0
	MOVWF      _t1Funcion+0
;EsclavoComunicacion.c,438 :: 		t1Registro = tramaSerial[3];                        //Guarda el byte de # de registro que se quiere leer/escribir
	MOVF       _tramaSerial+3, 0
	MOVWF      _t1Registro+0
;EsclavoComunicacion.c,439 :: 		tramaOk = VerificarCRC(tramaSerial,t1Size);         //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaSerial+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       R0+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,440 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt88
;EsclavoComunicacion.c,441 :: 		EnviarACK();                                    //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EsclavoComunicacion.c,444 :: 		if (t1Funcion<=funcEsclavo){
	MOVF       _t1Funcion+0, 0
	SUBWF      _funcEsclavo+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt89
;EsclavoComunicacion.c,445 :: 		if (t1Funcion==0){                           //Verifica si se solicito una funcion de lectura
	MOVF       _t1Funcion+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt90
;EsclavoComunicacion.c,446 :: 		if (t1Registro<regLecturaEsclavo){        //Verifica si existe el registro de lectura solicitado
	MOVF       _regLecturaEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt91
;EsclavoComunicacion.c,447 :: 		EnviarSolicitudLectura(t1Registro);    //Envia una solicitud de lectura del registro especificado al modulo EsclavoSensor
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarSolicitudLectura_registroLectura+0
	CALL       _EnviarSolicitudLectura+0
;EsclavoComunicacion.c,448 :: 		} else {
	GOTO       L_interrupt92
L_interrupt91:
;EsclavoComunicacion.c,449 :: 		EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,450 :: 		}
L_interrupt92:
;EsclavoComunicacion.c,451 :: 		} else {                                     //Caso contrario se trata de una funcion de escritura
	GOTO       L_interrupt93
L_interrupt90:
;EsclavoComunicacion.c,452 :: 		if (t1Registro<regEscrituraEsclavo){      //Verifica si existe el registro de lectura solicitado
	MOVF       _regEscrituraEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt94
;EsclavoComunicacion.c,453 :: 		for (x=0;x<(tramaSerial[4]);x++){
	CLRF       _x+0
L_interrupt95:
	MOVF       _tramaSerial+4, 0
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt96
;EsclavoComunicacion.c,454 :: 		datosEscritura[x]=tramaSerial[x+5];      //Carga el vector payload con los valores de la trama serial
	MOVF       _x+0, 0
	ADDLW      _datosEscritura+0
	MOVWF      R2+0
	MOVLW      5
	ADDWF      _x+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,453 :: 		for (x=0;x<(tramaSerial[4]);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,455 :: 		}
	GOTO       L_interrupt95
L_interrupt96:
;EsclavoComunicacion.c,457 :: 		EnviarSolicitudEscritura(t1Registro,numDatosEsc,datosEscritura);
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarSolicitudEscritura_registroEscritura+0
	MOVF       _numDatosEsc+0, 0
	MOVWF      FARG_EnviarSolicitudEscritura_numDatos+0
	MOVLW      _datosEscritura+0
	MOVWF      FARG_EnviarSolicitudEscritura_datos+0
	CALL       _EnviarSolicitudEscritura+0
;EsclavoComunicacion.c,458 :: 		} else {
	GOTO       L_interrupt98
L_interrupt94:
;EsclavoComunicacion.c,459 :: 		EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,460 :: 		}
L_interrupt98:
;EsclavoComunicacion.c,461 :: 		}
L_interrupt93:
;EsclavoComunicacion.c,462 :: 		} else {
	GOTO       L_interrupt99
L_interrupt89:
;EsclavoComunicacion.c,463 :: 		EnviarMensajeError(t1Registro,0xE0);         //Envia un mensaje de error con el codigo de "Funcion no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      224
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,464 :: 		}
L_interrupt99:
;EsclavoComunicacion.c,465 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt100
L_interrupt88:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt101
;EsclavoComunicacion.c,466 :: 		EnviarNACK();                                   //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,467 :: 		}
L_interrupt101:
L_interrupt100:
;EsclavoComunicacion.c,468 :: 		}
L_interrupt87:
;EsclavoComunicacion.c,469 :: 		banTC = 0;                               //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoComunicacion.c,470 :: 		i1 = 0;                                  //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoComunicacion.c,471 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,472 :: 		}
L_interrupt86:
;EsclavoComunicacion.c,474 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EsclavoComunicacion.c,475 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,476 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,478 :: 		}
L_interrupt75:
;EsclavoComunicacion.c,484 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt102
;EsclavoComunicacion.c,485 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,486 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,487 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt103
;EsclavoComunicacion.c,489 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;EsclavoComunicacion.c,490 :: 		} else {
	GOTO       L_interrupt104
L_interrupt103:
;EsclavoComunicacion.c,492 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,493 :: 		}
L_interrupt104:
;EsclavoComunicacion.c,494 :: 		}
L_interrupt102:
;EsclavoComunicacion.c,501 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt105
;EsclavoComunicacion.c,502 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,503 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,504 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,505 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,506 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;EsclavoComunicacion.c,507 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,508 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,509 :: 		}
L_interrupt105:
;EsclavoComunicacion.c,511 :: 		}
L_end_interrupt:
L__interrupt121:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoComunicacion.c,515 :: 		void main() {
;EsclavoComunicacion.c,517 :: 		ConfiguracionPrincipal();                          //Inicia las configuraciones necesarias
	CALL       _ConfiguracionPrincipal+0
;EsclavoComunicacion.c,518 :: 		IdentificarEsclavo();                              //Con esta funcion determina cual es el codigo identificador del dispositivo EsclavoSensor conectado por SPI
	CALL       _IdentificarEsclavo+0
;EsclavoComunicacion.c,519 :: 		CS = 1;                                            //Desabilita el CS
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,520 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,521 :: 		IU1 = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,522 :: 		i1=0;
	CLRF       _i1+0
;EsclavoComunicacion.c,523 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,524 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,525 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,526 :: 		banTC = 0;
	CLRF       _banTC+0
;EsclavoComunicacion.c,527 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,528 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,529 :: 		numDatosEsc = 0;
	CLRF       _numDatosEsc+0
;EsclavoComunicacion.c,530 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
