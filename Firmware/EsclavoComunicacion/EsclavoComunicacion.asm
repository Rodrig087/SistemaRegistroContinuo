
_ConfiguracionPrincipal:

;EsclavoComunicacion.c,67 :: 		void ConfiguracionPrincipal(){
;EsclavoComunicacion.c,69 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoComunicacion.c,70 :: 		TRISB1_bit = 0;
	BCF        TRISB1_bit+0, BitPos(TRISB1_bit+0)
;EsclavoComunicacion.c,71 :: 		TRISB2_bit = 0;
	BCF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;EsclavoComunicacion.c,72 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoComunicacion.c,74 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoComunicacion.c,75 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoComunicacion.c,78 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoComunicacion.c,79 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoComunicacion.c,83 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;EsclavoComunicacion.c,84 :: 		PIR1.TMR1IF = 0;
	BCF        PIR1+0, 0
;EsclavoComunicacion.c,85 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;EsclavoComunicacion.c,86 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;EsclavoComunicacion.c,87 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;EsclavoComunicacion.c,88 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;EsclavoComunicacion.c,91 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;EsclavoComunicacion.c,92 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,93 :: 		PIR1.TMR2IF = 0;
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,94 :: 		PIE1.TMR2IE = 1;
	BSF        PIE1+0, 1
;EsclavoComunicacion.c,101 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoComunicacion.c,103 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;EsclavoComunicacion.c,109 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;EsclavoComunicacion.c,112 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;EsclavoComunicacion.c,113 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;EsclavoComunicacion.c,114 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;EsclavoComunicacion.c,115 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;EsclavoComunicacion.c,116 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;EsclavoComunicacion.c,118 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;EsclavoComunicacion.c,114 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;EsclavoComunicacion.c,119 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;EsclavoComunicacion.c,112 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;EsclavoComunicacion.c,120 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;EsclavoComunicacion.c,121 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;EsclavoComunicacion.c,122 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeRS485:

;EsclavoComunicacion.c,128 :: 		void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
;EsclavoComunicacion.c,132 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+1
;EsclavoComunicacion.c,133 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+0
;EsclavoComunicacion.c,135 :: 		tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaRS485+0
;EsclavoComunicacion.c,136 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;EsclavoComunicacion.c,137 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;EsclavoComunicacion.c,138 :: 		tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
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
;EsclavoComunicacion.c,139 :: 		tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
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
;EsclavoComunicacion.c,140 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,141 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeRS48558
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
L__EnviarMensajeRS48558:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48510
;EsclavoComunicacion.c,142 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
L__EnviarMensajeRS48551:
;EsclavoComunicacion.c,143 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;EsclavoComunicacion.c,144 :: 		} else {
	GOTO       L_EnviarMensajeRS48515
L_EnviarMensajeRS48514:
;EsclavoComunicacion.c,145 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,146 :: 		}
L_EnviarMensajeRS48515:
;EsclavoComunicacion.c,141 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeRS485_i_L0+0, 1
;EsclavoComunicacion.c,147 :: 		}
	GOTO       L_EnviarMensajeRS4859
L_EnviarMensajeRS48510:
;EsclavoComunicacion.c,148 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48516:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeRS48517
	GOTO       L_EnviarMensajeRS48516
L_EnviarMensajeRS48517:
;EsclavoComunicacion.c,149 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,157 :: 		}
L_end_EnviarMensajeRS485:
	RETURN
; end of _EnviarMensajeRS485

_VerificarCRC:

;EsclavoComunicacion.c,164 :: 		unsigned short VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;EsclavoComunicacion.c,172 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,173 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;EsclavoComunicacion.c,175 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC18:
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	SUBWF      VerificarCRC_j_L0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_VerificarCRC19
;EsclavoComunicacion.c,176 :: 		pdu[j] = trama[j+1];
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
;EsclavoComunicacion.c,175 :: 		for (j=0;j<tramaPDUSize;j++){                      //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;EsclavoComunicacion.c,177 :: 		}
	GOTO       L_VerificarCRC18
L_VerificarCRC19:
;EsclavoComunicacion.c,179 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;EsclavoComunicacion.c,181 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;EsclavoComunicacion.c,182 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;EsclavoComunicacion.c,183 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;EsclavoComunicacion.c,185 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC60
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC60:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC21
;EsclavoComunicacion.c,186 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_VerificarCRC
;EsclavoComunicacion.c,187 :: 		} else {
L_VerificarCRC21:
;EsclavoComunicacion.c,188 :: 		return 0;
	CLRF       R0+0
;EsclavoComunicacion.c,190 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;EsclavoComunicacion.c,196 :: 		void EnviarACK(){
;EsclavoComunicacion.c,197 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,198 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,199 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK23:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK24
	GOTO       L_EnviarACK23
L_EnviarACK24:
;EsclavoComunicacion.c,200 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,201 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;EsclavoComunicacion.c,207 :: 		void EnviarNACK(){
;EsclavoComunicacion.c,208 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,209 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoComunicacion.c,210 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK26
	GOTO       L_EnviarNACK25
L_EnviarNACK26:
;EsclavoComunicacion.c,211 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,212 :: 		}
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

;EsclavoComunicacion.c,218 :: 		void interrupt(){
;EsclavoComunicacion.c,245 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt27
;EsclavoComunicacion.c,247 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,248 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoComunicacion.c,249 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,251 :: 		if ((byteTrama==ACK)&&(banTI==0)){              //Verifica si recibio un ACK
	MOVF       R0+0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt30
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt30
L__interrupt54:
;EsclavoComunicacion.c,253 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,254 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,255 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,256 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,257 :: 		}
L_interrupt30:
;EsclavoComunicacion.c,259 :: 		if ((byteTrama==NACK)&&(banTI==0)){             //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt33
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt33
L__interrupt53:
;EsclavoComunicacion.c,261 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,262 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,263 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt34
;EsclavoComunicacion.c,264 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);    //Si recibe un NACK como respuesta, le renvia la trama
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;EsclavoComunicacion.c,265 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;EsclavoComunicacion.c,266 :: 		} else {
	GOTO       L_interrupt35
L_interrupt34:
;EsclavoComunicacion.c,268 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,269 :: 		}
L_interrupt35:
;EsclavoComunicacion.c,270 :: 		banTI=0;                                     //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,271 :: 		byteTrama=0;                                 //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;EsclavoComunicacion.c,272 :: 		}
L_interrupt33:
;EsclavoComunicacion.c,274 :: 		if ((byteTrama==HDR)&&(banTI==0)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt38
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt38
L__interrupt52:
;EsclavoComunicacion.c,275 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoComunicacion.c,276 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,277 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,279 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,280 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,281 :: 		}
L_interrupt38:
;EsclavoComunicacion.c,283 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
;EsclavoComunicacion.c,284 :: 		PIR1.TMR2IF = 0;                             //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,285 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,286 :: 		if (byteTrama!=END2){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt40
;EsclavoComunicacion.c,287 :: 		tramaRS485[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,288 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoComunicacion.c,289 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoComunicacion.c,290 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,291 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,292 :: 		} else {
	GOTO       L_interrupt41
L_interrupt40:
;EsclavoComunicacion.c,293 :: 		tramaRS485[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoComunicacion.c,294 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoComunicacion.c,295 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoComunicacion.c,296 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoComunicacion.c,297 :: 		}
L_interrupt41:
;EsclavoComunicacion.c,298 :: 		if (BanTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt42
;EsclavoComunicacion.c,299 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoComunicacion.c,300 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoComunicacion.c,301 :: 		t1Size = tramaRS485[2];                   //Guarda el byte de longitud del campo PDU
	MOVF       _tramaRS485+2, 0
	MOVWF      _t1Size+0
;EsclavoComunicacion.c,302 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,303 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,304 :: 		}
L_interrupt42:
;EsclavoComunicacion.c,305 :: 		}
L_interrupt39:
;EsclavoComunicacion.c,307 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt43
;EsclavoComunicacion.c,308 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       _t1Size+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;EsclavoComunicacion.c,309 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt44
;EsclavoComunicacion.c,310 :: 		EnviarACK();                             //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;EsclavoComunicacion.c,311 :: 		} else if (tramaOk==0) {
	GOTO       L_interrupt45
L_interrupt44:
	MOVF       _tramaOk+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt46
;EsclavoComunicacion.c,312 :: 		EnviarNACK();                            //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,313 :: 		}
L_interrupt46:
L_interrupt45:
;EsclavoComunicacion.c,314 :: 		banTC = 0;                                   //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoComunicacion.c,315 :: 		i1 = 0;                                      //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoComunicacion.c,316 :: 		banTI = 0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,317 :: 		}
L_interrupt43:
;EsclavoComunicacion.c,319 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;EsclavoComunicacion.c,320 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,321 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,323 :: 		}
L_interrupt27:
;EsclavoComunicacion.c,329 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt47
;EsclavoComunicacion.c,330 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;EsclavoComunicacion.c,331 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;EsclavoComunicacion.c,332 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt48
;EsclavoComunicacion.c,333 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);       //Reenvia la trama por el bus RS485
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;EsclavoComunicacion.c,334 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;EsclavoComunicacion.c,335 :: 		} else {
	GOTO       L_interrupt49
L_interrupt48:
;EsclavoComunicacion.c,337 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,338 :: 		}
L_interrupt49:
;EsclavoComunicacion.c,339 :: 		}
L_interrupt47:
;EsclavoComunicacion.c,346 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt50
;EsclavoComunicacion.c,347 :: 		PIR1.TMR2IF = 0;                                //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoComunicacion.c,348 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoComunicacion.c,349 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;EsclavoComunicacion.c,350 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoComunicacion.c,351 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;EsclavoComunicacion.c,352 :: 		banTF = 0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,353 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;EsclavoComunicacion.c,354 :: 		}
L_interrupt50:
;EsclavoComunicacion.c,356 :: 		}
L_end_interrupt:
L__interrupt64:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoComunicacion.c,360 :: 		void main() {
;EsclavoComunicacion.c,362 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EsclavoComunicacion.c,363 :: 		RE_DE = 1;                                         //Establece el Max485-1 en modo de lectura;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;EsclavoComunicacion.c,364 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoComunicacion.c,365 :: 		IU1 = 0;
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;EsclavoComunicacion.c,366 :: 		i1=0;
	CLRF       _i1+0
;EsclavoComunicacion.c,367 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;EsclavoComunicacion.c,368 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;EsclavoComunicacion.c,369 :: 		banTI=0;
	CLRF       _banTI+0
;EsclavoComunicacion.c,370 :: 		banTC=0;
	CLRF       _banTC+0
;EsclavoComunicacion.c,371 :: 		banTF=0;
	CLRF       _banTF+0
;EsclavoComunicacion.c,372 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
