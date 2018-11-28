
_ConfiguracionPrincipal:

;EComunicacionPrueba.c,67 :: 		void ConfiguracionPrincipal(){
;EComunicacionPrueba.c,69 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EComunicacionPrueba.c,70 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EComunicacionPrueba.c,71 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EComunicacionPrueba.c,73 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EComunicacionPrueba.c,74 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EComunicacionPrueba.c,77 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EComunicacionPrueba.c,78 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EComunicacionPrueba.c,81 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      2
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EComunicacionPrueba.c,84 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EComunicacionPrueba.c,85 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EComunicacionPrueba.c,86 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EComunicacionPrueba.c,88 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EComunicacionPrueba.c,90 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EComunicacionPrueba.c,96 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EComunicacionPrueba.c,99 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EComunicacionPrueba.c,100 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EComunicacionPrueba.c,101 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EComunicacionPrueba.c,102 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EComunicacionPrueba.c,103 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EComunicacionPrueba.c,105 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EComunicacionPrueba.c,101 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EComunicacionPrueba.c,106 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EComunicacionPrueba.c,99 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EComunicacionPrueba.c,107 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EComunicacionPrueba.c,108 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EComunicacionPrueba.c,109 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeRS485:

;EComunicacionPrueba.c,115 :: 		void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
;EComunicacionPrueba.c,119 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+1
;EComunicacionPrueba.c,120 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+0
;EComunicacionPrueba.c,122 :: 		tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaRS485+0
;EComunicacionPrueba.c,123 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVLW      2
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      R1+0
	MOVF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EComunicacionPrueba.c,124 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      R1+0
	INCF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;EComunicacionPrueba.c,125 :: 		tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
	MOVLW      3
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVLW      13
	MOVWF      INDF+0
;EComunicacionPrueba.c,126 :: 		tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
	MOVLW      4
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVLW      10
	MOVWF      INDF+0
;EComunicacionPrueba.c,127 :: 		for (i=0;i<(sizePDU+5);i++){
	CLRF       EnviarMensajeRS485_i_L0+0
L_EnviarMensajeRS4859:
	MOVLW      5
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
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
	GOTO       L__EnviarMensajeRS48560
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
L__EnviarMensajeRS48560:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48510
;EComunicacionPrueba.c,128 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
L__EnviarMensajeRS48555:
;EComunicacionPrueba.c,129 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSS      STATUS+0, 0
	DECF       R0+1, 1
	MOVF       R0+0, 0
	ADDWF      FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EComunicacionPrueba.c,130 :: 		} else {
	GOTO       L_EnviarMensajeRS48515
L_EnviarMensajeRS48514:
;EComunicacionPrueba.c,131 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EComunicacionPrueba.c,132 :: 		}
L_EnviarMensajeRS48515:
;EComunicacionPrueba.c,127 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeRS485_i_L0+0, 1
;EComunicacionPrueba.c,133 :: 		}
	GOTO       L_EnviarMensajeRS4859
L_EnviarMensajeRS48510:
;EComunicacionPrueba.c,134 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48516:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeRS48517
	GOTO       L_EnviarMensajeRS48516
L_EnviarMensajeRS48517:
;EComunicacionPrueba.c,135 :: 		}
L_end_EnviarMensajeRS485:
	RETURN
; end of _EnviarMensajeRS485

_VerificarCRC:

;EComunicacionPrueba.c,142 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EComunicacionPrueba.c,150 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EComunicacionPrueba.c,151 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EComunicacionPrueba.c,153 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC18:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC19
;EComunicacionPrueba.c,154 :: 		pdu[j] = trama[j+1];
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
;EComunicacionPrueba.c,153 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EComunicacionPrueba.c,155 :: 		}
	GOTO       L_VerificarCRC18
L_VerificarCRC19:
;EComunicacionPrueba.c,157 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EComunicacionPrueba.c,159 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EComunicacionPrueba.c,160 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;EComunicacionPrueba.c,161 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;EComunicacionPrueba.c,163 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC62
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC62:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC21
;EComunicacionPrueba.c,164 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EComunicacionPrueba.c,165 :: 		} else {
L_VerificarCRC21:
;EComunicacionPrueba.c,166 :: 		return 0;
	CLRF       R0+0
;EComunicacionPrueba.c,168 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EComunicacionPrueba.c,174 :: 		void EnviarACK(){
;EComunicacionPrueba.c,175 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EComunicacionPrueba.c,176 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK23:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK24
	GOTO       L_EnviarACK23
L_EnviarACK24:
;EComunicacionPrueba.c,177 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EComunicacionPrueba.c,183 :: 		void EnviarNACK(){
;EComunicacionPrueba.c,184 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EComunicacionPrueba.c,185 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK26
	GOTO       L_EnviarNACK25
L_EnviarNACK26:
;EComunicacionPrueba.c,186 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;EComunicacionPrueba.c,197 :: 		void interrupt(){
;EComunicacionPrueba.c,201 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt27
;EComunicacionPrueba.c,202 :: 		INTCON.INTF = 0;                                //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;EComunicacionPrueba.c,203 :: 		Delay_ms(10);                                   //**Sin esto no funciona y no se porque**
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_interrupt28:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt28
	DECFSZ     R12+0, 1
	GOTO       L_interrupt28
	NOP
;EComunicacionPrueba.c,204 :: 		CS = 0;                                         //Coloca en bajo el pin CS para abrir la transmision
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EComunicacionPrueba.c,205 :: 		for (x=0;x<=numBytesSPI;x++){
	CLRF       _x+0
L_interrupt29:
	MOVF       _x+0, 0
	SUBWF      _numBytesSPI+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt30
;EComunicacionPrueba.c,206 :: 		SSPBUF = 0xBB;                              //Envia x cantidad de bytes al esclavo segun el numero de bytes+1 que haya solicitado en la respuesta de la solicitud de medicion
	MOVLW      187
	MOVWF      SSPBUF+0
;EComunicacionPrueba.c,207 :: 		if ((x>0)){
	MOVF       _x+0, 0
	SUBLW      0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt32
;EComunicacionPrueba.c,208 :: 		while (SSPSTAT.BF!=1);
L_interrupt33:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt34
	GOTO       L_interrupt33
L_interrupt34:
;EComunicacionPrueba.c,209 :: 		UART1_Write(SSPBUF);
	MOVF       SSPBUF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EComunicacionPrueba.c,210 :: 		}
L_interrupt32:
;EComunicacionPrueba.c,211 :: 		Delay_us(200);
	MOVLW      133
	MOVWF      R13+0
L_interrupt35:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt35
;EComunicacionPrueba.c,205 :: 		for (x=0;x<=numBytesSPI;x++){
	INCF       _x+0, 1
;EComunicacionPrueba.c,212 :: 		}
	GOTO       L_interrupt29
L_interrupt30:
;EComunicacionPrueba.c,213 :: 		CS = 1;                                         //Coloca en alto el pin CS para cerrar la transmision
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EComunicacionPrueba.c,214 :: 		}
L_interrupt27:
;EComunicacionPrueba.c,217 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt36
;EComunicacionPrueba.c,219 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EComunicacionPrueba.c,221 :: 		if ((byteTrama==HDR)&&(banTI==0)){
	MOVF       R0+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
L__interrupt56:
;EComunicacionPrueba.c,222 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EComunicacionPrueba.c,223 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EComunicacionPrueba.c,224 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EComunicacionPrueba.c,225 :: 		}
L_interrupt39:
;EComunicacionPrueba.c,227 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt40
;EComunicacionPrueba.c,228 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt41
;EComunicacionPrueba.c,229 :: 		tramaRS485[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EComunicacionPrueba.c,230 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EComunicacionPrueba.c,231 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EComunicacionPrueba.c,232 :: 		} else {
	GOTO       L_interrupt42
L_interrupt41:
;EComunicacionPrueba.c,233 :: 		tramaRS485[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EComunicacionPrueba.c,234 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EComunicacionPrueba.c,235 :: 		}
L_interrupt42:
;EComunicacionPrueba.c,236 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt43
;EComunicacionPrueba.c,237 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EComunicacionPrueba.c,238 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EComunicacionPrueba.c,239 :: 		t1Size = tramaRS485[2];                   //Guarda el byte de longitud del campo PDU
	MOVF       _tramaRS485+2, 0
	MOVWF      _t1Size+0
;EComunicacionPrueba.c,240 :: 		}
L_interrupt43:
;EComunicacionPrueba.c,241 :: 		}
L_interrupt40:
;EComunicacionPrueba.c,243 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt44
;EComunicacionPrueba.c,244 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       _t1Size+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EComunicacionPrueba.c,245 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt45
;EComunicacionPrueba.c,246 :: 		EnviarACK();                             //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EComunicacionPrueba.c,248 :: 		petSPI[0] = 0xA0;                        //Cabecera de trama de solicitud de medicion
	MOVLW      160
	MOVWF      _petSPI+0
;EComunicacionPrueba.c,249 :: 		petSPI[1] = 0x01;                        //Codigo del registro que se quiere leer
	MOVLW      1
	MOVWF      _petSPI+1
;EComunicacionPrueba.c,250 :: 		petSPI[2] = 0xA1;                        //Delimitador de final de trama
	MOVLW      161
	MOVWF      _petSPI+2
;EComunicacionPrueba.c,252 :: 		CS = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EComunicacionPrueba.c,253 :: 		for (x=0;x<3;x++){
	CLRF       _x+0
L_interrupt46:
	MOVLW      3
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt47
;EComunicacionPrueba.c,254 :: 		SSPBUF = petSPI[x];                  //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF       _x+0, 0
	ADDLW      _petSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EComunicacionPrueba.c,255 :: 		if (x==2){
	MOVF       _x+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt49
;EComunicacionPrueba.c,256 :: 		while (SSPSTAT.BF!=1);
L_interrupt50:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_interrupt51
	GOTO       L_interrupt50
L_interrupt51:
;EComunicacionPrueba.c,257 :: 		numBytesSPI = SSPBUF;             //Recupera el valor de # de bytes que el Esclavo enviara en la solicitud de respuesta, (esto ocurre al enviar el tercer byte)
	MOVF       SSPBUF+0, 0
	MOVWF      _numBytesSPI+0
;EComunicacionPrueba.c,258 :: 		}
L_interrupt49:
;EComunicacionPrueba.c,259 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_interrupt52:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt52
	DECFSZ     R12+0, 1
	GOTO       L_interrupt52
	NOP
	NOP
;EComunicacionPrueba.c,253 :: 		for (x=0;x<3;x++){
	INCF       _x+0, 1
;EComunicacionPrueba.c,260 :: 		}
	GOTO       L_interrupt46
L_interrupt47:
;EComunicacionPrueba.c,261 :: 		CS = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EComunicacionPrueba.c,263 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt53
L_interrupt45:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt54
;EComunicacionPrueba.c,264 :: 		EnviarNACK();                            //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EComunicacionPrueba.c,265 :: 		}
L_interrupt54:
L_interrupt53:
;EComunicacionPrueba.c,266 :: 		banTC = 0;                                   //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EComunicacionPrueba.c,267 :: 		i1 = 0;                                      //Limpia el subindice de trama
	CLRF       _i1+0
;EComunicacionPrueba.c,268 :: 		banTI = 0;
	CLRF       _banTI+0
;EComunicacionPrueba.c,269 :: 		}
L_interrupt44:
;EComunicacionPrueba.c,271 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EComunicacionPrueba.c,273 :: 		}
L_interrupt36:
;EComunicacionPrueba.c,275 :: 		}
L_end_interrupt:
L__interrupt66:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EComunicacionPrueba.c,280 :: 		void main() {
;EComunicacionPrueba.c,282 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EComunicacionPrueba.c,283 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EComunicacionPrueba.c,284 :: 		i1=0;
	CLRF       _i1+0
;EComunicacionPrueba.c,285 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EComunicacionPrueba.c,286 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EComunicacionPrueba.c,287 :: 		banTI=0;
	CLRF       _banTI+0
;EComunicacionPrueba.c,288 :: 		banTC=0;
	CLRF       _banTC+0
;EComunicacionPrueba.c,289 :: 		banTF=0;
	CLRF       _banTF+0
;EComunicacionPrueba.c,290 :: 		banPet=0;
	CLRF       _banPet+0
;EComunicacionPrueba.c,292 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
