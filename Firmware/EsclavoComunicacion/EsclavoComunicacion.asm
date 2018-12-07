
_ConfiguracionPrincipal:

;EsclavoComunicacion.c,76 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacion.c,78 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoComunicacion.c,79 :: 		TRISB2_bit = 0;
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;EsclavoComunicacion.c,80 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoComunicacion.c,81 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoComunicacion.c,83 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoComunicacion.c,84 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoComunicacion.c,87 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoComunicacion.c,88 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoComunicacion.c,91 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      2
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoComunicacion.c,94 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;EsclavoComunicacion.c,95 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;EsclavoComunicacion.c,96 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;EsclavoComunicacion.c,97 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;EsclavoComunicacion.c,98 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;EsclavoComunicacion.c,99 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;EsclavoComunicacion.c,102 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;EsclavoComunicacion.c,103 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,104 :: 		PIR1.TMR2IF = 0;
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,105 :: 		PIE1.TMR2IE = 1;
	BSF        PIE1+0, 1
;EsclavoComunicacion.c,108 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EsclavoComunicacion.c,109 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,110 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EsclavoComunicacion.c,112 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoComunicacion.c,114 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacion.c,120 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacion.c,123 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EsclavoComunicacion.c,124 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EsclavoComunicacion.c,125 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EsclavoComunicacion.c,126 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EsclavoComunicacion.c,127 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacion.c,129 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EsclavoComunicacion.c,125 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EsclavoComunicacion.c,130 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacion.c,123 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EsclavoComunicacion.c,131 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacion.c,132 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EsclavoComunicacion.c,133 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeUART:

;EsclavoComunicacion.c,139 :: 		void EnviarMensajeUART(unsigned char *tramaPDU, unsigned char sizePDU){
;EsclavoComunicacion.c,143 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeUART_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeUART_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeUART_CRCPDU_L0+1
;EsclavoComunicacion.c,144 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeUART_CRCPDU_L0+0
	MOVWF      EnviarMensajeUART_ptrCRCPDU_L0+0
;EsclavoComunicacion.c,146 :: 		tramaSerial[0]=HDR;                                //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,147 :: 		tramaSerial[sizePDU+2] = *ptrCrcPdu;               //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;EsclavoComunicacion.c,148 :: 		tramaSerial[sizePDU+1] = *(ptrCrcPdu+1);           //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;EsclavoComunicacion.c,149 :: 		tramaSerial[sizePDU+3] = END1;                     //Añade el primer delimitador de final de trama
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
;EsclavoComunicacion.c,150 :: 		tramaSerial[sizePDU+4] = END2;                     //Añade el segundo delimitador de final de trama
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
;EsclavoComunicacion.c,151 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeUART109
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeUART_i_L0+0, 0
L__EnviarMensajeUART109:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeUART10
;EsclavoComunicacion.c,152 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeUART_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
	MOVF       EnviarMensajeUART_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeUART_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeUART14
L__EnviarMensajeUART104:
;EsclavoComunicacion.c,153 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,154 :: 		} else {
	GOTO       L_EnviarMensajeUART15
L_EnviarMensajeUART14:
;EsclavoComunicacion.c,155 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeUART_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,156 :: 		}
L_EnviarMensajeUART15:
;EsclavoComunicacion.c,151 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeUART_i_L0+0, 1
;EsclavoComunicacion.c,157 :: 		}
	GOTO       L_EnviarMensajeUART9
L_EnviarMensajeUART10:
;EsclavoComunicacion.c,158 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeUART16:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeUART17
	GOTO       L_EnviarMensajeUART16
L_EnviarMensajeUART17:
;EsclavoComunicacion.c,166 :: 		}
L_end_EnviarMensajeUART:
	RETURN
; end of _EnviarMensajeUART

_EnviarMensajeError:

;EsclavoComunicacion.c,172 :: 		void EnviarMensajeError(unsigned short numRegistro,unsigned short codigoError){
;EsclavoComunicacion.c,177 :: 		errorPDU[0] = idEsclavo;
	MOVF       _idEsclavo+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+0
;EsclavoComunicacion.c,178 :: 		errorPDU[1] = 0xEE;                                //Cambia el valor del campo Funcion por el codigo 0xEE para indicar que se ha producido un error
	MOVLW      238
	MOVWF      EnviarMensajeError_errorPDU_L0+1
;EsclavoComunicacion.c,179 :: 		errorPDU[2] = numRegistro;                         //Numero de registro que se solocito leer/escribir
	MOVF       FARG_EnviarMensajeError_numRegistro+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+2
;EsclavoComunicacion.c,180 :: 		errorPDU[3] = 0x01;                                //Numero de datos del pyload de la trama PDU
	MOVLW      1
	MOVWF      EnviarMensajeError_errorPDU_L0+3
;EsclavoComunicacion.c,181 :: 		errorPDU[4] = codigoError;                         //Codigo de error producido
	MOVF       FARG_EnviarMensajeError_codigoError+0, 0
	MOVWF      EnviarMensajeError_errorPDU_L0+4
;EsclavoComunicacion.c,182 :: 		CRCerrorPDU = CalcularCRC(errorPDU,5);             //Calcula el CRC de la trama errorPDU
	MOVLW      EnviarMensajeError_errorPDU_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVLW      5
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeError_CRCerrorPDU_L0+1
;EsclavoComunicacion.c,183 :: 		ptrCRCerrorPDU = &CRCerrorPDU;                     //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeError_CRCerrorPDU_L0+0
	MOVWF      EnviarMensajeError_ptrCRCerrorPDU_L0+0
;EsclavoComunicacion.c,185 :: 		tramaSerial[0] = HDR;                              //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaSerial+0
;EsclavoComunicacion.c,186 :: 		tramaSerial[6] = *(ptrCRCerrorPDU+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	INCF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+6
;EsclavoComunicacion.c,187 :: 		tramaSerial[7] = *ptrCRCerrorPDU;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVF       EnviarMensajeError_ptrCRCerrorPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      _tramaSerial+7
;EsclavoComunicacion.c,188 :: 		tramaSerial[8] = END1;                             //Añade el primer delimitador de final de trama
	MOVLW      13
	MOVWF      _tramaSerial+8
;EsclavoComunicacion.c,189 :: 		tramaSerial[9] = END2;                             //Añade el segundo delimitador de final de trama
	MOVLW      10
	MOVWF      _tramaSerial+9
;EsclavoComunicacion.c,190 :: 		for (i=0;i<(10);i++){
	CLRF       EnviarMensajeError_i_L0+0
L_EnviarMensajeError18:
	MOVLW      10
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeError19
;EsclavoComunicacion.c,191 :: 		if ((i>=1)&&(i<=5)){
	MOVLW      1
	SUBWF      EnviarMensajeError_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
	MOVF       EnviarMensajeError_i_L0+0, 0
	SUBLW      5
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeError23
L__EnviarMensajeError105:
;EsclavoComunicacion.c,192 :: 		UART1_Write(errorPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,193 :: 		} else {
	GOTO       L_EnviarMensajeError24
L_EnviarMensajeError23:
;EsclavoComunicacion.c,194 :: 		UART1_Write(tramaSerial[i]);                //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeError_i_L0+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,195 :: 		}
L_EnviarMensajeError24:
;EsclavoComunicacion.c,190 :: 		for (i=0;i<(10);i++){
	INCF       EnviarMensajeError_i_L0+0, 1
;EsclavoComunicacion.c,196 :: 		}
	GOTO       L_EnviarMensajeError18
L_EnviarMensajeError19:
;EsclavoComunicacion.c,197 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeError25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeError26
	GOTO       L_EnviarMensajeError25
L_EnviarMensajeError26:
;EsclavoComunicacion.c,198 :: 		}
L_end_EnviarMensajeError:
	RETURN
; end of _EnviarMensajeError

_VerificarCRC:

;EsclavoComunicacion.c,205 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacion.c,213 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,214 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EsclavoComunicacion.c,216 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC27:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC28
;EsclavoComunicacion.c,217 :: 		pdu[j] = trama[j+1];
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
;EsclavoComunicacion.c,216 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EsclavoComunicacion.c,218 :: 		}
	GOTO       L_VerificarCRC27
L_VerificarCRC28:
;EsclavoComunicacion.c,220 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,222 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EsclavoComunicacion.c,223 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;EsclavoComunicacion.c,224 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;EsclavoComunicacion.c,226 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC112
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC112:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC30
;EsclavoComunicacion.c,227 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EsclavoComunicacion.c,228 :: 		} else {
L_VerificarCRC30:
;EsclavoComunicacion.c,229 :: 		return 0;
	CLRF       R0+0
;EsclavoComunicacion.c,231 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacion.c,237 :: 		void EnviarACK(){
;EsclavoComunicacion.c,238 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,239 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK32:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK33
	GOTO       L_EnviarACK32
L_EnviarACK33:
;EsclavoComunicacion.c,240 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacion.c,246 :: 		void EnviarNACK(){
;EsclavoComunicacion.c,247 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,248 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK34:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK35
	GOTO       L_EnviarNACK34
L_EnviarNACK35:
;EsclavoComunicacion.c,249 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_IdentificarEsclavo:

;EsclavoComunicacion.c,255 :: 		void IdentificarEsclavo(){
;EsclavoComunicacion.c,256 :: 		petSPI[0] = 0xA0;
	MOVLW      160
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,257 :: 		petSPI[1] = 0xA1;
	MOVLW      161
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,258 :: 		petSPI[2] = 0xA2;
	MOVLW      162
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,259 :: 		petSPI[3] = 0xA3;
	MOVLW      163
	MOVWF      _petSPI+3
;EsclavoComunicacion.c,260 :: 		petSPI[4] = 0xA4;
	MOVLW      164
	MOVWF      _petSPI+4
;EsclavoComunicacion.c,261 :: 		petSPI[5] = 0xA5;
	MOVLW      165
	MOVWF      _petSPI+5
;EsclavoComunicacion.c,262 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,263 :: 		for (x=0;x<6;x++){
	CLRF       _x+0
L_IdentificarEsclavo36:
	MOVLW      6
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_IdentificarEsclavo37
;EsclavoComunicacion.c,264 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,265 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo39
;EsclavoComunicacion.c,266 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo40:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo41
	GOTO       L_IdentificarEsclavo40
L_IdentificarEsclavo41:
;EsclavoComunicacion.c,267 :: 		idEsclavo = SSPBUF;               //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _idEsclavo+0
;EsclavoComunicacion.c,268 :: 		}
L_IdentificarEsclavo39:
;EsclavoComunicacion.c,269 :: 		if (x==3){
	MOVF       _x+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo42
;EsclavoComunicacion.c,270 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo43:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo44
	GOTO       L_IdentificarEsclavo43
L_IdentificarEsclavo44:
;EsclavoComunicacion.c,271 :: 		funcEsclavo = SSPBUF;              //Recupera el numero de funciones disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _funcEsclavo+0
;EsclavoComunicacion.c,272 :: 		}
L_IdentificarEsclavo42:
;EsclavoComunicacion.c,273 :: 		if (x==4){
	MOVF       _x+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo45
;EsclavoComunicacion.c,274 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo46:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo47
	GOTO       L_IdentificarEsclavo46
L_IdentificarEsclavo47:
;EsclavoComunicacion.c,275 :: 		regLecturaEsclavo = SSPBUF;        //Recupera el numero de registros de lectura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regLecturaEsclavo+0
;EsclavoComunicacion.c,276 :: 		}
L_IdentificarEsclavo45:
;EsclavoComunicacion.c,277 :: 		if (x==5){
	MOVF       _x+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo48
;EsclavoComunicacion.c,278 :: 		while (SSPSTAT.BF!=1);
L_IdentificarEsclavo49:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_IdentificarEsclavo50
	GOTO       L_IdentificarEsclavo49
L_IdentificarEsclavo50:
;EsclavoComunicacion.c,279 :: 		regEscrituraEsclavo = SSPBUF;      //Recupera el numero de registros de escritura disponibles en el modulo EsclavoSensor
	MOVF       SSPBUF+0, 0
	MOVWF      _regEscrituraEsclavo+0
;EsclavoComunicacion.c,280 :: 		}
L_IdentificarEsclavo48:
;EsclavoComunicacion.c,282 :: 		Delay_ms(1);
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
;EsclavoComunicacion.c,263 :: 		for (x=0;x<6;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,283 :: 		}
	GOTO       L_IdentificarEsclavo36
L_IdentificarEsclavo37:
;EsclavoComunicacion.c,284 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,285 :: 		}
L_end_IdentificarEsclavo:
	RETURN
; end of _IdentificarEsclavo

_EnviarSolicitudLectura:

;EsclavoComunicacion.c,291 :: 		void EnviarSolicitudLectura(unsigned short registroLectura){
;EsclavoComunicacion.c,292 :: 		petSPI[0] = 0xB0;                        //Cabecera de trama de solicitud de medicion
	MOVLW      176
	MOVWF      _petSPI+0
;EsclavoComunicacion.c,293 :: 		petSPI[1] = registroLectura;             //Codigo del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudLectura_registroLectura+0, 0
	MOVWF      _petSPI+1
;EsclavoComunicacion.c,294 :: 		petSPI[2] = 0xB1;                        //Delimitador de final de trama
	MOVLW      177
	MOVWF      _petSPI+2
;EsclavoComunicacion.c,295 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,296 :: 		for (x=0;x<3;x++){
	CLRF       _x+0
L_EnviarSolicitudLectura52:
	MOVLW      3
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudLectura53
;EsclavoComunicacion.c,297 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,298 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarSolicitudLectura55
;EsclavoComunicacion.c,299 :: 		while (SSPSTAT.BF!=1);
L_EnviarSolicitudLectura56:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_EnviarSolicitudLectura57
	GOTO       L_EnviarSolicitudLectura56
L_EnviarSolicitudLectura57:
;EsclavoComunicacion.c,300 :: 		numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _numBytesSPI+0
;EsclavoComunicacion.c,301 :: 		}
L_EnviarSolicitudLectura55:
;EsclavoComunicacion.c,302 :: 		Delay_ms(1);
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
;EsclavoComunicacion.c,296 :: 		for (x=0;x<3;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,303 :: 		}
	GOTO       L_EnviarSolicitudLectura52
L_EnviarSolicitudLectura53:
;EsclavoComunicacion.c,304 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,305 :: 		banMed = 1;                              //Activa la bandera de medicion para evitar que existan falsos positivos en la interrupcion externa
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoComunicacion.c,306 :: 		}
L_end_EnviarSolicitudLectura:
	RETURN
; end of _EnviarSolicitudLectura

_EnviarSolicitudEscritura:

;EsclavoComunicacion.c,312 :: 		void EnviarSolicitudEscritura(unsigned short registroEscritura,unsigned char* datos, unsigned short sizeDatos){
;EsclavoComunicacion.c,313 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,314 :: 		SSPBUF = registroEscritura;              //Llena el buffer de salida con el valor del registro que se quiere leer
	MOVF       FARG_EnviarSolicitudEscritura_registroEscritura+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,315 :: 		Delay_ms(1);
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
;EsclavoComunicacion.c,316 :: 		for (x=0;x<sizeDatos;x++){
	CLRF       _x+0
L_EnviarSolicitudEscritura60:
	MOVF       FARG_EnviarSolicitudEscritura_sizeDatos+0, 0
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarSolicitudEscritura61
;EsclavoComunicacion.c,317 :: 		SSPBUF = datos[x];                   //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDWF      FARG_EnviarSolicitudEscritura_datos+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,318 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_EnviarSolicitudEscritura63:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarSolicitudEscritura63
	DECFSZ     R12+0, 1
	GOTO       L_EnviarSolicitudEscritura63
	NOP
	NOP
;EsclavoComunicacion.c,316 :: 		for (x=0;x<sizeDatos;x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,319 :: 		}
	GOTO       L_EnviarSolicitudEscritura60
L_EnviarSolicitudEscritura61:
;EsclavoComunicacion.c,320 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,321 :: 		}
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

;EsclavoComunicacion.c,327 :: 		void interrupt(){
;EsclavoComunicacion.c,331 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt64
;EsclavoComunicacion.c,332 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoComunicacion.c,333 :: 		if (banMed==1){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt65
;EsclavoComunicacion.c,335 :: 		CS = 0;                                      //Coloca en bajo el pin CS para abrir la transmision
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,336 :: 		for (x=0;x<(numBytesSPI+1);x++){
	CLRF       _x+0
L_interrupt66:
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
	GOTO       L__interrupt120
	MOVF       R1+0, 0
	SUBWF      _x+0, 0
L__interrupt120:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt67
;EsclavoComunicacion.c,337 :: 		SSPBUF = 0xCC;                           //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
	MOVLW      204
	MOVWF      SSPBUF+0
;EsclavoComunicacion.c,338 :: 		if ((x>0)){
	MOVF       _x+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt69
;EsclavoComunicacion.c,339 :: 		while (SSPSTAT.BF!=1);
L_interrupt70:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt71
	GOTO       L_interrupt70
L_interrupt71:
;EsclavoComunicacion.c,340 :: 		resSPI[x+3] = SSPBUF;                 //Guarda la respuesta del EsclavoSensor en el vector resSPI a partir de la cuarta posicion
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
;EsclavoComunicacion.c,341 :: 		}
L_interrupt69:
;EsclavoComunicacion.c,342 :: 		Delay_us(200);
	MOVLW      133
	MOVWF      R13+0
L_interrupt72:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt72
;EsclavoComunicacion.c,336 :: 		for (x=0;x<(numBytesSPI+1);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,343 :: 		}
	GOTO       L_interrupt66
L_interrupt67:
;EsclavoComunicacion.c,344 :: 		CS = 1;                                      //Coloca en alto el pin CS para cerrar la transmision
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,346 :: 		resSPI[0] = idEsclavo;                       //Guarda en la primera posicion del vector PDU de respuesta el id del Esclavo
	MOVF       _idEsclavo+0, 0
	MOVWF      _resSPI+0
;EsclavoComunicacion.c,347 :: 		resSPI[1] = t1Funcion;                       //Guarda en la segunda posicion del vector PDU el codigo de funcion requerido
	MOVF       _t1Funcion+0, 0
	MOVWF      _resSPI+1
;EsclavoComunicacion.c,348 :: 		resSPI[2] = t1Registro;                      //Guarda en la tercera posicion del vector PDU el # de registro requerido
	MOVF       _t1Registro+0, 0
	MOVWF      _resSPI+2
;EsclavoComunicacion.c,349 :: 		resSPI[3] = numBytesSPI;                     //Guarda en la cuarta posicion del vector PDU de respuesta el numero de bytes del payload
	MOVF       _numBytesSPI+0, 0
	MOVWF      _resSPI+3
;EsclavoComunicacion.c,351 :: 		}
L_interrupt65:
;EsclavoComunicacion.c,352 :: 		banMed=0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,354 :: 		EnviarMensajeUART(resSPI,(numBytesSPI+4));
	MOVLW      _resSPI+0
	MOVWF      FARG_EnviarMensajeUART_tramaPDU+0
	MOVLW      4
	ADDWF      _numBytesSPI+0, 0
	MOVWF      FARG_EnviarMensajeUART_sizePDU+0
	CALL       _EnviarMensajeUART+0
;EsclavoComunicacion.c,356 :: 		}
L_interrupt64:
;EsclavoComunicacion.c,364 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt73
;EsclavoComunicacion.c,366 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,367 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoComunicacion.c,368 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,370 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt74
;EsclavoComunicacion.c,371 :: 		if ((byteTrama==ACK)){                          //Verifica si recibio un ACK
	MOVF       _byteTrama+0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt75
;EsclavoComunicacion.c,373 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,374 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,375 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,376 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,377 :: 		}
L_interrupt75:
;EsclavoComunicacion.c,379 :: 		if ((byteTrama==NACK)){                         //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt76
;EsclavoComunicacion.c,381 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,382 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,383 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt77
;EsclavoComunicacion.c,385 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;EsclavoComunicacion.c,386 :: 		} else {
	GOTO       L_interrupt78
L_interrupt77:
;EsclavoComunicacion.c,387 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,388 :: 		}
L_interrupt78:
;EsclavoComunicacion.c,389 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,390 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,391 :: 		}
L_interrupt76:
;EsclavoComunicacion.c,393 :: 		if ((byteTrama==HDR)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt79
;EsclavoComunicacion.c,394 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoComunicacion.c,395 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,396 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,398 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,399 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,400 :: 		}
L_interrupt79:
;EsclavoComunicacion.c,401 :: 		}
L_interrupt74:
;EsclavoComunicacion.c,403 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt80
;EsclavoComunicacion.c,404 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,405 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,406 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt81
;EsclavoComunicacion.c,407 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,408 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoComunicacion.c,409 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoComunicacion.c,410 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,411 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,412 :: 		} else {
	GOTO       L_interrupt82
L_interrupt81:
;EsclavoComunicacion.c,413 :: 		tramaSerial[i1] = byteTrama;              //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaSerial+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,414 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoComunicacion.c,415 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,416 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,417 :: 		}
L_interrupt82:
;EsclavoComunicacion.c,418 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt83
;EsclavoComunicacion.c,419 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoComunicacion.c,420 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoComunicacion.c,421 :: 		t1IdEsclavo = tramaSerial[1];             //Guarda el byte de Id de esclavo del campo PDU
	MOVF       _tramaSerial+1, 0
	MOVWF      _t1IdEsclavo+0
;EsclavoComunicacion.c,422 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,423 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,424 :: 		}
L_interrupt83:
;EsclavoComunicacion.c,425 :: 		}
L_interrupt80:
;EsclavoComunicacion.c,427 :: 		if (banTC==1){                                             //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt84
;EsclavoComunicacion.c,428 :: 		if (t1IdEsclavo==IdEsclavo){                            //Verifica si coincide el Id de esclavo para seguir con el procesamiento de la peticion
	MOVF       _t1IdEsclavo+0, 0
	XORWF      _idEsclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt85
;EsclavoComunicacion.c,429 :: 		t1Size = tramaSerial[4]+4;                          //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
	MOVLW      4
	ADDWF      _tramaSerial+4, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _t1Size+0
;EsclavoComunicacion.c,430 :: 		t1Funcion = tramaSerial[2];                         //Guarda el byte de funcion reequerida del campo PDU
	MOVF       _tramaSerial+2, 0
	MOVWF      _t1Funcion+0
;EsclavoComunicacion.c,431 :: 		t1Registro = tramaSerial[3];                        //Guarda el byte de # de registro que se quiere leer/escribir
	MOVF       _tramaSerial+3, 0
	MOVWF      _t1Registro+0
;EsclavoComunicacion.c,432 :: 		tramaOk = VerificarCRC(tramaSerial,t1Size);         //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaSerial+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       R0+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,433 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt86
;EsclavoComunicacion.c,434 :: 		EnviarACK();                                    //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EsclavoComunicacion.c,437 :: 		if (t1Funcion<=funcEsclavo){
	MOVF       _t1Funcion+0, 0
	SUBWF      _funcEsclavo+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt87
;EsclavoComunicacion.c,438 :: 		if (t1Funcion==0){                           //Verifica si se solicito una funcion de lectura
	MOVF       _t1Funcion+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt88
;EsclavoComunicacion.c,439 :: 		if (t1Registro<regLecturaEsclavo){        //Verifica si existe el registro de lectura solicitado
	MOVF       _regLecturaEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt89
;EsclavoComunicacion.c,440 :: 		EnviarSolicitudLectura(t1Registro);    //Envia una solicitud de lectura del registro especificado al modulo EsclavoSensor
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarSolicitudLectura_registroLectura+0
	CALL       _EnviarSolicitudLectura+0
;EsclavoComunicacion.c,441 :: 		} else {
	GOTO       L_interrupt90
L_interrupt89:
;EsclavoComunicacion.c,442 :: 		EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,443 :: 		}
L_interrupt90:
;EsclavoComunicacion.c,444 :: 		} else {                                     //Caso contrario se trata de una funcion de escritura
	GOTO       L_interrupt91
L_interrupt88:
;EsclavoComunicacion.c,445 :: 		if (t1Registro<regEscrituraEsclavo){      //Verifica si existe el registro de lectura solicitado
	MOVF       _regEscrituraEsclavo+0, 0
	SUBWF      _t1Registro+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt92
;EsclavoComunicacion.c,446 :: 		for (x=0;x<(tramaSerial[4]);x++){
	CLRF       _x+0
L_interrupt93:
	MOVF       _tramaSerial+4, 0
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt94
;EsclavoComunicacion.c,447 :: 		datosEscritura[x]=tramaSerial[x+5];      //Carga el vector payload con los valores de la trama serial
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
;EsclavoComunicacion.c,446 :: 		for (x=0;x<(tramaSerial[4]);x++){
	INCF       _x+0, 1
;EsclavoComunicacion.c,448 :: 		}
	GOTO       L_interrupt93
L_interrupt94:
;EsclavoComunicacion.c,450 :: 		EnviarSolicitudEscritura(t1Registro,datosEscritura,tramaSerial[4]);
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarSolicitudEscritura_registroEscritura+0
	MOVLW      _datosEscritura+0
	MOVWF      FARG_EnviarSolicitudEscritura_datos+0
	MOVF       _tramaSerial+4, 0
	MOVWF      FARG_EnviarSolicitudEscritura_sizeDatos+0
	CALL       _EnviarSolicitudEscritura+0
;EsclavoComunicacion.c,451 :: 		} else {
	GOTO       L_interrupt96
L_interrupt92:
;EsclavoComunicacion.c,452 :: 		EnviarMensajeError(t1Registro,0xE1);   //Envia un mensaje de error con el codigo de "Registro no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      225
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,453 :: 		}
L_interrupt96:
;EsclavoComunicacion.c,454 :: 		}
L_interrupt91:
;EsclavoComunicacion.c,455 :: 		} else {
	GOTO       L_interrupt97
L_interrupt87:
;EsclavoComunicacion.c,456 :: 		EnviarMensajeError(t1Registro,0xE0);         //Envia un mensaje de error con el codigo de "Funcion no disponible"
	MOVF       _t1Registro+0, 0
	MOVWF      FARG_EnviarMensajeError_numRegistro+0
	MOVLW      224
	MOVWF      FARG_EnviarMensajeError_codigoError+0
	CALL       _EnviarMensajeError+0
;EsclavoComunicacion.c,457 :: 		}
L_interrupt97:
;EsclavoComunicacion.c,458 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt98
L_interrupt86:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt99
;EsclavoComunicacion.c,459 :: 		EnviarNACK();                                   //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,460 :: 		}
L_interrupt99:
L_interrupt98:
;EsclavoComunicacion.c,461 :: 		}
L_interrupt85:
;EsclavoComunicacion.c,462 :: 		banTC = 0;                               //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoComunicacion.c,463 :: 		i1 = 0;                                  //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoComunicacion.c,464 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,465 :: 		}
L_interrupt84:
;EsclavoComunicacion.c,467 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EsclavoComunicacion.c,468 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,469 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,471 :: 		}
L_interrupt73:
;EsclavoComunicacion.c,477 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt100
;EsclavoComunicacion.c,478 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,479 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,480 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt101
;EsclavoComunicacion.c,482 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;EsclavoComunicacion.c,483 :: 		} else {
	GOTO       L_interrupt102
L_interrupt101:
;EsclavoComunicacion.c,485 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,486 :: 		}
L_interrupt102:
;EsclavoComunicacion.c,487 :: 		}
L_interrupt100:
;EsclavoComunicacion.c,494 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt103
;EsclavoComunicacion.c,495 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,496 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,497 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,498 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,499 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;EsclavoComunicacion.c,500 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,501 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,502 :: 		}
L_interrupt103:
;EsclavoComunicacion.c,504 :: 		}
L_end_interrupt:
L__interrupt119:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoComunicacion.c,508 :: 		void main() {
;EsclavoComunicacion.c,510 :: 		ConfiguracionPrincipal();                          //Inicia las configuraciones necesarias
	CALL       _ConfiguracionPrincipal+0
;EsclavoComunicacion.c,511 :: 		IdentificarEsclavo();                              //Con esta funcion determina cual es el codigo identificador del dispositivo EsclavoSensor conectado por SPI
	CALL       _IdentificarEsclavo+0
;EsclavoComunicacion.c,512 :: 		CS = 1;                                            //Desabilita el CS
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoComunicacion.c,513 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,514 :: 		IU1 = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,515 :: 		i1=0;
	CLRF       _i1+0
;EsclavoComunicacion.c,516 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,517 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,518 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,519 :: 		banTC = 0;
	CLRF       _banTC+0
;EsclavoComunicacion.c,520 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,521 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoComunicacion.c,522 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
