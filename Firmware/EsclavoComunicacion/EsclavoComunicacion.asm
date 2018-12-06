
_ConfiguracionPrincipal:

;EsclavoComunicacion.c,72 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacion.c,74 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoComunicacion.c,75 :: 		TRISB2_bit = 0;
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;EsclavoComunicacion.c,76 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoComunicacion.c,77 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoComunicacion.c,79 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoComunicacion.c,80 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoComunicacion.c,83 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoComunicacion.c,84 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoComunicacion.c,87 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      2
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoComunicacion.c,90 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;EsclavoComunicacion.c,91 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;EsclavoComunicacion.c,92 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;EsclavoComunicacion.c,93 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;EsclavoComunicacion.c,94 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;EsclavoComunicacion.c,95 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;EsclavoComunicacion.c,98 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;EsclavoComunicacion.c,99 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,100 :: 		PIR1.TMR2IF = 0;
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,101 :: 		PIE1.TMR2IE = 1;
	BSF        PIE1+0, 1
;EsclavoComunicacion.c,104 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EsclavoComunicacion.c,105 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,106 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EsclavoComunicacion.c,108 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoComunicacion.c,110 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacion.c,116 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacion.c,119 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EsclavoComunicacion.c,120 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EsclavoComunicacion.c,121 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EsclavoComunicacion.c,122 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EsclavoComunicacion.c,123 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacion.c,125 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EsclavoComunicacion.c,121 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EsclavoComunicacion.c,126 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacion.c,119 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EsclavoComunicacion.c,127 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacion.c,128 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EsclavoComunicacion.c,129 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeUART:

;EsclavoComunicacion.c,135 :: 		void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
;EsclavoComunicacion.c,139 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeUART_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+1
;EsclavoComunicacion.c,140 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeUART_CRCPDU_L0+0
	MOVWF      EnviarMensajeUART_ptrCRCPDU_L0+0
;EsclavoComunicacion.c,142 :: 		tramaSerial[0]=HDR;                                //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,143 :: 		tramaSerial[sizePDU+2] = *ptrCrcPdu;               //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;EsclavoComunicacion.c,144 :: 		tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);           //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;EsclavoComunicacion.c,145 :: 		tramaSerial[sizePDU+3] = END1;                     //Añade el primer delimitador de final de trama
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
;EsclavoComunicacion.c,146 :: 		tramaSerial[sizePDU+4] = END2;                     //Añade el segundo delimitador de final de trama
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
;EsclavoComunicacion.c,147 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeUART89
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeUART_i_L0+0, 0
L__EnviarMensajeUART89:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeUART10
;EsclavoComunicacion.c,148 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeUART_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
	MOVF       EnviarMensajeUART_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
L__EnviarMensajeUART84:
;EsclavoComunicacion.c,149 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,150 :: 		} else {
	GOTO       L_EnviarMensajeUART15
L_EnviarMensajeUART14:
;EsclavoComunicacion.c,151 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeUART_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,152 :: 		}
L_EnviarMensajeUART15:
;EsclavoComunicacion.c,147 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeUART_i_L0+0, 1
;EsclavoComunicacion.c,153 :: 		}
	GOTO       L_EnviarMensajeUART9
L_EnviarMensajeUART10:
;EsclavoComunicacion.c,154 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeUART16:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeUART17
	GOTO       L_EnviarMensajeUART16
L_EnviarMensajeUART17:
;EsclavoComunicacion.c,162 :: 		}
L_end_EnviarMensajeUART:
	RETURN
; end of _EnviarMensajeUART

_EnviarMensajeError:

;EsclavoComunicacion.c,168 :: 		void EnviarMensajeError(unsigned short codigoError){
;EsclavoComunicacion.c,173 :: 		errorPDU[0] = idEsclavo;
	MOVF       _idEsclavo+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+0
;EsclavoComunicacion.c,174 :: 		errorPDU[1] = 0x01;                                //Numero de datos del campo #Datos de la trama PDU
	MOVLW      1
	MOVWF      EnviarMensajeError_errorPDU_L0+1
;EsclavoComunicacion.c,175 :: 		errorPDU[2] = 0xEE;                                //Cambia el valor del campo Funcion por el codigo 0xEE para indicar que se ha producido un error
	MOVLW      238
	MOVWF      EnviarMensajeError_errorPDU_L0+2
;EsclavoComunicacion.c,176 :: 		errorPDU[3] = codigoError;                         //Carga el campo de datos con el codigo del error producido
	MOVF       FARG_EnviarMensajeError_codigoError+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+3
;EsclavoComunicacion.c,177 :: 		CRCerrorPDU = CalcularCRC(errorPDU,4);             //Calcula el CRC de la trama errorPDU
	MOVLW      EnviarMensajeError_errorPDU_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVLW      4
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+1
;EsclavoComunicacion.c,178 :: 		ptrCRCerrorPDU = &CRCerrorPDU;                     //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVWF      EnviarMensajeError_ptrCRCerrorPDU_L0+0
;EsclavoComunicacion.c,180 :: 		tramaSerial[0] = HDR;                              //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,181 :: 		tramaSerial[6] = *ptrCRCerrorPDU;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+6
;EsclavoComunicacion.c,182 :: 		tramaSerial[5] = *(ptrCRCerrorPDU+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	INCF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+5
;EsclavoComunicacion.c,183 :: 		tramaSerial[7] = END1;                             //Añade el primer delimitador de final de trama
	MOVLW      13
	MOVWF      _tramaSerial+7
;EsclavoComunicacion.c,184 :: 		tramaSerial[8] = END2;                             //Añade el segundo delimitador de final de trama
	MOVLW      10
	MOVWF      _tramaSerial+8
;EsclavoComunicacion.c,185 :: 		for (i=0;i<(9);i++){
	CLRF       EnviarMensajeError_i_L0+0
L_EnviarMensajeError18:
	MOVLW      9
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeError19
;EsclavoComunicacion.c,186 :: 		if ((i>=1)&&(i<=4)){
	MOVLW      1
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
	MOVF       EnviarMensajeError_i_L0+0, 0
	SUBLW      4
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
L__EnviarMensajeError85:
;EsclavoComunicacion.c,187 :: 		UART1_Write(errorPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,188 :: 		} else {
	GOTO       L_EnviarMensajeError24
L_EnviarMensajeError23:
;EsclavoComunicacion.c,189 :: 		UART1_Write(tramaSerial[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeError_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,190 :: 		}
L_EnviarMensajeError24:
;EsclavoComunicacion.c,185 :: 		for (i=0;i<(9);i++){
	INCF       EnviarMensajeError_i_L0+0, 1
;EsclavoComunicacion.c,191 :: 		}
	GOTO       L_EnviarMensajeError18
L_EnviarMensajeError19:
;EsclavoComunicacion.c,192 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeError25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeError26
	GOTO       L_EnviarMensajeError25
L_EnviarMensajeError26:
;EsclavoComunicacion.c,193 :: 		}
L_end_EnviarMensajeError:
	RETURN
; end of _EnviarMensajeError

_VerificarCRC:

;EsclavoComunicacion.c,200 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacion.c,208 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,209 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EsclavoComunicacion.c,211 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC27:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC28
;EsclavoComunicacion.c,212 :: 		pdu[j] = trama[j+1];
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
;EsclavoComunicacion.c,211 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EsclavoComunicacion.c,213 :: 		}
	GOTO       L_VerificarCRC27
L_VerificarCRC28:
;EsclavoComunicacion.c,215 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,217 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EsclavoComunicacion.c,218 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;EsclavoComunicacion.c,219 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;EsclavoComunicacion.c,221 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC92
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC92:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC30
;EsclavoComunicacion.c,222 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EsclavoComunicacion.c,223 :: 		} else {
L_VerificarCRC30:
;EsclavoComunicacion.c,224 :: 		return 0;
	CLRF       R0+0
;EsclavoComunicacion.c,226 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacion.c,232 :: 		void EnviarACK(){
;EsclavoComunicacion.c,233 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,234 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK32:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK33
	GOTO       L_EnviarACK32
L_EnviarACK33:
;EsclavoComunicacion.c,235 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacion.c,241 :: 		void EnviarNACK(){
;EsclavoComunicacion.c,242 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,243 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK34:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK35
	GOTO       L_EnviarNACK34
L_EnviarNACK35:
;EsclavoComunicacion.c,244 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_EnviarSolicitudMedicion:

;EsclavoComunicacion.c,250 :: 		void EnviarSolicitudMedicion(unsigned short registroEsclavo){
;EsclavoComunicacion.c,251 :: 		petSPI[0] = 0xB0;                        //Cabecera de trama de solicitud de medicion
	MOVLW      176
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,252 :: 		petSPI[1] = registroEsclavo;             //Codigo del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudMedicion_registroEsclavo+0, 0
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,253 :: 		petSPI[2] = 0xB1;                        //Delimitador de final de trama
	MOVLW      177
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,254 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,255 :: 		for (x=0;x<3;x++){
	CLRF       _x+0
L_EnviarSolicitudMedicion36:
	MOVLW      3
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudMedicion37
;EsclavoComunicacion.c,256 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,257 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarSolicitudMedicion39
;EsclavoComunicacion.c,258 :: 		while (SSPSTAT.BF!=1);
L_EnviarSolicitudMedicion40:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_EnviarSolicitudMedicion41
	GOTO       L_EnviarSolicitudMedicion40
L_EnviarSolicitudMedicion41:
;EsclavoComunicacion.c,259 :: 		numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _numBytesSPI+0
;EsclavoComunicacion.c,260 :: 		}
L_EnviarSolicitudMedicion39:
;EsclavoComunicacion.c,261 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudMedicion42:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudMedicion42
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudMedicion42
	NOP
	NOP
;EsclavoComunicacion.c,255 :: 		for (x=0;x<3;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,262 :: 		}
	GOTO       L_EnviarSolicitudMedicion36
L_EnviarSolicitudMedicion37:
;EsclavoComunicacion.c,263 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,264 :: 		banMed = 1;                              //Activa la bandera de medicion para evitar que existan falsos positivos en la interrupcion externa
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoComunicacion.c,265 :: 		}
L_end_EnviarSolicitudMedicion:
	RETURN
; end of _EnviarSolicitudMedicion

_IdentificarEsclavo:

;EsclavoComunicacion.c,271 :: 		void IdentificarEsclavo(){
;EsclavoComunicacion.c,272 :: 		petSPI[0] = 0xA0;
	MOVLW      160
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,273 :: 		petSPI[1] = 0xA1;
	MOVLW      161
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,274 :: 		petSPI[2] = 0xA2;
	MOVLW      162
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,275 :: 		petSPI[3] = 0xA3;
	MOVLW      163
	MOVWF      _petSPI+3
;EsclavoComunicacion.c,276 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,277 :: 		for (x=0;x<4;x++){
	CLRF       _x+0
L_IdentificarEsclavo43:
	MOVLW      4
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_IdentificarEsclavo44
;EsclavoComunicacion.c,278 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,279 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo46
;EsclavoComunicacion.c,280 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo47:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo48
	GOTO       L_IdentificarEsclavo47
L_IdentificarEsclavo48:
;EsclavoComunicacion.c,281 :: 		idEsclavo = SSPBUF;               //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _idEsclavo+0
;EsclavoComunicacion.c,282 :: 		}
L_IdentificarEsclavo46:
;EsclavoComunicacion.c,283 :: 		if (x==3){
	MOVF       _x+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo49
;EsclavoComunicacion.c,284 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo50:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo51
	GOTO       L_IdentificarEsclavo50
L_IdentificarEsclavo51:
;EsclavoComunicacion.c,285 :: 		funcEsclavo = SSPBUF;              //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _funcEsclavo+0
;EsclavoComunicacion.c,286 :: 		}
L_IdentificarEsclavo49:
;EsclavoComunicacion.c,287 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_IdentificarEsclavo52:
	DECFSZ     R13+0, 1
	GOTO       L_IdentificarEsclavo52
	DECFSZ     R12+0, 1
	GOTO       L_IdentificarEsclavo52
	NOP
	NOP
;EsclavoComunicacion.c,277 :: 		for (x=0;x<4;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,288 :: 		}
	GOTO       L_IdentificarEsclavo43
L_IdentificarEsclavo44:
;EsclavoComunicacion.c,289 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,290 :: 		}
L_end_IdentificarEsclavo:
	RETURN
; end of _IdentificarEsclavo

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;EsclavoComunicacion.c,296 :: 		void interrupt(){
;EsclavoComunicacion.c,300 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt53
;EsclavoComunicacion.c,301 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,302 :: 		if (banMed==1){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt54
;EsclavoComunicacion.c,304 :: 		CS = 0;                                      //Coloca en bajo el pin CS para abrir la transmision
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,305 :: 		for (x=0;x<(numBytesSPI+1);x++){
	CLRF       _x+0
L_interrupt55:
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
	GOTO       L__interrupt99
	MOVF       R1+0, 0
	SUBWF      _x+0, 0
L__interrupt99:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt56
;EsclavoComunicacion.c,306 :: 		SSPBUF = 0xCC;                           //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
	MOVLW      204
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,307 :: 		if ((x>0)){
	MOVF       _x+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt58
;EsclavoComunicacion.c,308 :: 		while (SSPSTAT.BF!=1);
L_interrupt59:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt60
	GOTO       L_interrupt59
L_interrupt60:
;EsclavoComunicacion.c,309 :: 		resSPI[x+2] = SSPBUF;                 //Guarda la respuesta del EsclavoSensor en el vector resSPI a partir de la cuarta posicion
	MOVLW      2
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
;EsclavoComunicacion.c,310 :: 		}
L_interrupt58:
;EsclavoComunicacion.c,311 :: 		Delay_us(200);
	MOVLW      133
	MOVWF      R13+0
L_interrupt61:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt61
;EsclavoComunicacion.c,305 :: 		for (x=0;x<(numBytesSPI+1);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,312 :: 		}
	GOTO       L_interrupt55
L_interrupt56:
;EsclavoComunicacion.c,313 :: 		CS = 1;                                      //Coloca en alto el pin CS para cerrar la transmision
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,315 :: 		resSPI[0] = idEsclavo;                       //Guarda en la primera posicion del vector PDU de respuesta el id del Esclavo
	MOVF       _idEsclavo+0, 0
	MOVWF      _resSPI+0
;EsclavoComunicacion.c,316 :: 		resSPI[1] = numBytesSPI + 3;                 //Guarda en la primera posicion del vector PDU de respuesta el numero de bytes de la trama PDU
	MOVLW      3
	ADDWF      _numBytesSPI+0, 0
	MOVWF      _resSPI+1
;EsclavoComunicacion.c,317 :: 		resSPI[2] = t1Funcion;
	MOVF       _t1Funcion+0, 0
	MOVWF      _resSPI+2
;EsclavoComunicacion.c,319 :: 		}
L_interrupt54:
;EsclavoComunicacion.c,320 :: 		banMed=0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,322 :: 		EnviarMensajeUART(resSPI,(numBytesSPI+3));
	MOVLW      _resSPI+0
	MOVWF      FARG_EnviarMensajeUART_tramaPDU+0
	MOVLW      3
	ADDWF      _numBytesSPI+0, 0
	MOVWF      FARG_EnviarMensajeUART_sizePDU+0
	CALL       _EnviarMensajeUART+0
;EsclavoComunicacion.c,324 :: 		}
L_interrupt53:
;EsclavoComunicacion.c,332 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt62
;EsclavoComunicacion.c,334 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,335 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoComunicacion.c,336 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,338 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt63
;EsclavoComunicacion.c,339 :: 		if ((byteTrama==ACK)){                          //Verifica si recibio un ACK
	MOVF       _byteTrama+0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt64
;EsclavoComunicacion.c,341 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,342 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,343 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,344 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,345 :: 		}
L_interrupt64:
;EsclavoComunicacion.c,347 :: 		if ((byteTrama==NACK)){                         //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt65
;EsclavoComunicacion.c,349 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,350 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,351 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt66
;EsclavoComunicacion.c,353 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;EsclavoComunicacion.c,354 :: 		} else {
	GOTO       L_interrupt67
L_interrupt66:
;EsclavoComunicacion.c,355 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,356 :: 		}
L_interrupt67:
;EsclavoComunicacion.c,357 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,358 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,359 :: 		}
L_interrupt65:
;EsclavoComunicacion.c,361 :: 		if ((byteTrama==HDR)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt68
;EsclavoComunicacion.c,362 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoComunicacion.c,363 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,364 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,366 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,367 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,368 :: 		}
L_interrupt68:
;EsclavoComunicacion.c,369 :: 		}
L_interrupt63:
;EsclavoComunicacion.c,371 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt69
;EsclavoComunicacion.c,372 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,373 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,374 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt70
;EsclavoComunicacion.c,375 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,376 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoComunicacion.c,377 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoComunicacion.c,378 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,379 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,380 :: 		} else {
	GOTO       L_interrupt71
L_interrupt70:
;EsclavoComunicacion.c,381 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,382 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoComunicacion.c,383 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,384 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,385 :: 		}
L_interrupt71:
;EsclavoComunicacion.c,386 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt72
;EsclavoComunicacion.c,387 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoComunicacion.c,388 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoComunicacion.c,389 :: 		t1IdEsclavo = tramaSerial[1];             //Guarda el byte de Id de esclavo del campo PDU
	MOVF       _tramaSerial+1, 0
	MOVWF      _t1IdEsclavo+0
;EsclavoComunicacion.c,390 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,391 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,392 :: 		}
L_interrupt72:
;EsclavoComunicacion.c,393 :: 		}
L_interrupt69:
;EsclavoComunicacion.c,395 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt73
;EsclavoComunicacion.c,396 :: 		if (t1IdEsclavo==IdEsclavo){                 //Verifica si coincide el Id de esclavo para seguir con el procesamiento de la peticion
	MOVF       _t1IdEsclavo+0, 0
	XORWF      _idEsclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt74
;EsclavoComunicacion.c,397 :: 		t1Size = tramaSerial[2]+3;               //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
	MOVLW      3
	ADDWF      _tramaSerial+2, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _t1Size+0
;EsclavoComunicacion.c,398 :: 		t1Funcion = tramaSerial[3];              //Guarda el byte de funcion reequerida del campo PDU
	MOVF       _tramaSerial+3, 0
	MOVWF      _t1Funcion+0
;EsclavoComunicacion.c,399 :: 		tramaOk = VerificarCRC(tramaSerial,t1Size);   //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaSerial+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       R0+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,400 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt75
;EsclavoComunicacion.c,401 :: 		EnviarACK();                         //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EsclavoComunicacion.c,404 :: 		if (t1Funcion<=funcEsclavo){
	MOVF       _t1Funcion+0, 0
	SUBWF      _funcEsclavo+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt76
;EsclavoComunicacion.c,405 :: 		EnviarSolicitudMedicion(tramaSerial[4]);       //Envia una solicitud de medicion al EsclavoSensor
	MOVF       _tramaSerial+4, 0
	MOVWF      FARG_EnviarSolicitudMedicion_registroEsclavo+0
	CALL       _EnviarSolicitudMedicion+0
;EsclavoComunicacion.c,406 :: 		} else {
	GOTO       L_interrupt77
L_interrupt76:
;EsclavoComunicacion.c,407 :: 		EnviarMensajeError(0xE0);         //Envia un mensaje de error con el codigo de "Funcion no disponible"
	MOVLW      224
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,408 :: 		}
L_interrupt77:
;EsclavoComunicacion.c,410 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt78
L_interrupt75:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt79
;EsclavoComunicacion.c,411 :: 		EnviarNACK();                        //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,412 :: 		}
L_interrupt79:
L_interrupt78:
;EsclavoComunicacion.c,413 :: 		}
L_interrupt74:
;EsclavoComunicacion.c,414 :: 		banTC = 0;                               //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoComunicacion.c,415 :: 		i1 = 0;                                  //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoComunicacion.c,416 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,417 :: 		}
L_interrupt73:
;EsclavoComunicacion.c,419 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EsclavoComunicacion.c,420 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,421 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,423 :: 		}
L_interrupt62:
;EsclavoComunicacion.c,429 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt80
;EsclavoComunicacion.c,430 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,431 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,432 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt81
;EsclavoComunicacion.c,434 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;EsclavoComunicacion.c,435 :: 		} else {
	GOTO       L_interrupt82
L_interrupt81:
;EsclavoComunicacion.c,437 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,438 :: 		}
L_interrupt82:
;EsclavoComunicacion.c,439 :: 		}
L_interrupt80:
;EsclavoComunicacion.c,446 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt83
;EsclavoComunicacion.c,447 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,448 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,449 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,450 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,451 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;EsclavoComunicacion.c,452 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,453 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,454 :: 		}
L_interrupt83:
;EsclavoComunicacion.c,456 :: 		}
L_end_interrupt:
L__interrupt98:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoComunicacion.c,460 :: 		void main() {
;EsclavoComunicacion.c,462 :: 		ConfiguracionPrincipal();                          //Inicia las configuraciones necesarias
	CALL       _ConfiguracionPrincipal+0
;EsclavoComunicacion.c,463 :: 		IdentificarEsclavo();                              //Con esta funcion determina cual es el codigo identificador del dispositivo EsclavoSensor conectado por SPI
	CALL       _IdentificarEsclavo+0
;EsclavoComunicacion.c,464 :: 		CS = 1;                                            //Desabilita el CS
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,465 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,466 :: 		IU1 = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,467 :: 		i1=0;
	CLRF       _i1+0
;EsclavoComunicacion.c,468 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,469 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,470 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,471 :: 		banTC = 0;
	CLRF       _banTC+0
;EsclavoComunicacion.c,472 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,473 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,474 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
