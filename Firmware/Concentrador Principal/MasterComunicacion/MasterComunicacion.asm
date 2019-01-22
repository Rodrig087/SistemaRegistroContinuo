
_ConfiguracionPrincipal:

;MasterComunicacion.c,61 :: 		void ConfiguracionPrincipal(){
;MasterComunicacion.c,63 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;MasterComunicacion.c,64 :: 		TRISC4_bit = 0;
	BCF        TRISC4_bit+0, BitPos(TRISC4_bit+0)
;MasterComunicacion.c,66 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;MasterComunicacion.c,67 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;MasterComunicacion.c,69 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;MasterComunicacion.c,72 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;MasterComunicacion.c,73 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;MasterComunicacion.c,75 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;MasterComunicacion.c,77 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;MasterComunicacion.c,83 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;MasterComunicacion.c,86 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;MasterComunicacion.c,87 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;MasterComunicacion.c,88 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;MasterComunicacion.c,89 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;MasterComunicacion.c,90 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;MasterComunicacion.c,92 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;MasterComunicacion.c,88 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;MasterComunicacion.c,93 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;MasterComunicacion.c,86 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;MasterComunicacion.c,94 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;MasterComunicacion.c,95 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;MasterComunicacion.c,96 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeRS485:

;MasterComunicacion.c,100 :: 		void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
;MasterComunicacion.c,104 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+1
;MasterComunicacion.c,105 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+0
;MasterComunicacion.c,107 :: 		tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaRS485+0
;MasterComunicacion.c,108 :: 		tramaRS485[sizePDU+2]=*ptrCrcPdu;                  //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
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
;MasterComunicacion.c,109 :: 		tramaRS485[sizePDU+1]=*(ptrCrcPdu+1);              //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
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
;MasterComunicacion.c,110 :: 		tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
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
;MasterComunicacion.c,111 :: 		tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
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
;MasterComunicacion.c,112 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,113 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeRS48542
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
L__EnviarMensajeRS48542:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48510
;MasterComunicacion.c,114 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
L__EnviarMensajeRS48538:
;MasterComunicacion.c,116 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;MasterComunicacion.c,117 :: 		} else {
	GOTO       L_EnviarMensajeRS48515
L_EnviarMensajeRS48514:
;MasterComunicacion.c,118 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,119 :: 		}
L_EnviarMensajeRS48515:
;MasterComunicacion.c,113 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeRS485_i_L0+0, 1
;MasterComunicacion.c,120 :: 		}
	GOTO       L_EnviarMensajeRS4859
L_EnviarMensajeRS48510:
;MasterComunicacion.c,121 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48516:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeRS48517
	GOTO       L_EnviarMensajeRS48516
L_EnviarMensajeRS48517:
;MasterComunicacion.c,122 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,124 :: 		byteTrama=0;                                    //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;MasterComunicacion.c,128 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF        T1CON+0, 0
;MasterComunicacion.c,129 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,130 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW      11
	MOVWF      TMR1H+0
;MasterComunicacion.c,131 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;MasterComunicacion.c,132 :: 		}
L_end_EnviarMensajeRS485:
	RETURN
; end of _EnviarMensajeRS485

_VerificarCRC:

;MasterComunicacion.c,139 :: 		unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;MasterComunicacion.c,144 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;MasterComunicacion.c,145 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;MasterComunicacion.c,146 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC18:
	MOVF       VerificarCRC_j_L0+0, 0
	SUBWF      FARG_VerificarCRC_tramaPDUSize+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_VerificarCRC19
;MasterComunicacion.c,147 :: 		pdu[j] = trama[j+1];
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
;MasterComunicacion.c,146 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;MasterComunicacion.c,148 :: 		}
	GOTO       L_VerificarCRC18
L_VerificarCRC19:
;MasterComunicacion.c,149 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVLW      VerificarCRC_pdu_L0+0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R0+1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;MasterComunicacion.c,150 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
;MasterComunicacion.c,151 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
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
;MasterComunicacion.c,152 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
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
;MasterComunicacion.c,153 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC44
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC44:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC21
;MasterComunicacion.c,154 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	GOTO       L_end_VerificarCRC
;MasterComunicacion.c,155 :: 		} else {
L_VerificarCRC21:
;MasterComunicacion.c,156 :: 		return 0;
	CLRF       R0+0
	CLRF       R0+1
;MasterComunicacion.c,158 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;MasterComunicacion.c,164 :: 		void EnviarACK(){
;MasterComunicacion.c,165 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,166 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,167 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK23:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK24
	GOTO       L_EnviarACK23
L_EnviarACK24:
;MasterComunicacion.c,168 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,169 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;MasterComunicacion.c,175 :: 		void EnviarNACK(){
;MasterComunicacion.c,176 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,177 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,178 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK26
	GOTO       L_EnviarNACK25
L_EnviarNACK26:
;MasterComunicacion.c,179 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,180 :: 		}
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

;MasterComunicacion.c,185 :: 		void interrupt(){
;MasterComunicacion.c,193 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt27
;MasterComunicacion.c,195 :: 		IU1 = 1;
	BSF        RC4_bit+0, BitPos(RC4_bit+0)
;MasterComunicacion.c,197 :: 		IU1 = 0;
	BCF        RC4_bit+0, BitPos(RC4_bit+0)
;MasterComunicacion.c,199 :: 		byteTrama = UART1_Read();                           //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;MasterComunicacion.c,201 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt28
;MasterComunicacion.c,202 :: 		if ((byteTrama==HDR)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt29
;MasterComunicacion.c,203 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;MasterComunicacion.c,204 :: 		i1 = 0;                                      //Define en 1 el subindice de la trama de peticion
	CLRF       _i1+0
;MasterComunicacion.c,205 :: 		tramaOk = 9;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	MOVLW      9
	MOVWF      _tramaOk+0
;MasterComunicacion.c,206 :: 		}
L_interrupt29:
;MasterComunicacion.c,207 :: 		}
L_interrupt28:
;MasterComunicacion.c,209 :: 		if (banTI==1){                                      //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt30
;MasterComunicacion.c,210 :: 		if (byteTrama!=END2){                            //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt31
;MasterComunicacion.c,211 :: 		tramaRS485[i1] = byteTrama;                   //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;MasterComunicacion.c,212 :: 		i1++;                                         //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;MasterComunicacion.c,213 :: 		banTF = 0;                                    //Limpia la bandera de final de trama
	CLRF       _banTF+0
;MasterComunicacion.c,214 :: 		} else {
	GOTO       L_interrupt32
L_interrupt31:
;MasterComunicacion.c,215 :: 		tramaRS485[i1] = byteTrama;                   //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _tramaRS485+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;MasterComunicacion.c,216 :: 		banTF = 1;                                    //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;MasterComunicacion.c,217 :: 		}
L_interrupt32:
;MasterComunicacion.c,218 :: 		if (BanTF==1){                                   //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt33
;MasterComunicacion.c,219 :: 		banTI = 0;                                    //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;MasterComunicacion.c,220 :: 		banTC = 1;                                    //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;MasterComunicacion.c,221 :: 		}
L_interrupt33:
;MasterComunicacion.c,222 :: 		}
L_interrupt30:
;MasterComunicacion.c,224 :: 		if (banTC==1){
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt34
;MasterComunicacion.c,225 :: 		t1Size = tramaRS485[4]+4;                        //Calcula la longitud de la trama PDU sumando 3 al valor del campo #Datos
	MOVLW      4
	ADDWF      _tramaRS485+4, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      _t1Size+0
;MasterComunicacion.c,226 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);       //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVF       R0+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0+0, 0
	MOVWF      _tramaOk+0
;MasterComunicacion.c,227 :: 		if (tramaOk==1){
	MOVF       R0+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt35
;MasterComunicacion.c,228 :: 		EnviarACK();
	CALL       _EnviarACK+0
;MasterComunicacion.c,230 :: 		Delay_ms(1000);                           //Simula un tiempo de procesamiento largo (un segundo);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_interrupt36:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt36
	DECFSZ     R12+0, 1
	GOTO       L_interrupt36
	DECFSZ     R11+0, 1
	GOTO       L_interrupt36
	NOP
	NOP
;MasterComunicacion.c,231 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);          //Invoca a la funcion para enviar la peticion
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;MasterComunicacion.c,233 :: 		}else{
	GOTO       L_interrupt37
L_interrupt35:
;MasterComunicacion.c,234 :: 		EnviarNACK();
	CALL       _EnviarNACK+0
;MasterComunicacion.c,235 :: 		}
L_interrupt37:
;MasterComunicacion.c,236 :: 		banTC = 0;                                       //Limpia la bandera de trama completa
	CLRF       _banTC+0
;MasterComunicacion.c,237 :: 		i1 = 0;                                          //Limpia el subindice de trama
	CLRF       _i1+0
;MasterComunicacion.c,238 :: 		banTI = 0;
	CLRF       _banTI+0
;MasterComunicacion.c,239 :: 		}
L_interrupt34:
;MasterComunicacion.c,241 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;MasterComunicacion.c,243 :: 		}
L_interrupt27:
;MasterComunicacion.c,245 :: 		}
L_end_interrupt:
L__interrupt48:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;MasterComunicacion.c,249 :: 		void main() {
;MasterComunicacion.c,251 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;MasterComunicacion.c,252 :: 		RE_DE = 1;                                         //Establece el Max485-1 en modo de lectura;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;MasterComunicacion.c,253 :: 		i1=0;
	CLRF       _i1+0
;MasterComunicacion.c,254 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;MasterComunicacion.c,255 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;MasterComunicacion.c,256 :: 		byteTrama = 0;                                     //Limpia la variable del byte de la trama de peticion
	CLRF       _byteTrama+0
;MasterComunicacion.c,258 :: 		banTI = 0;                                         //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;MasterComunicacion.c,259 :: 		banTC = 0;                                         //Limpia la bandera de trama completa
	CLRF       _banTC+0
;MasterComunicacion.c,260 :: 		banTF = 0;                                         //Limpia la bandera de final de trama
	CLRF       _banTF+0
;MasterComunicacion.c,261 :: 		banLR = 0;
	CLRF       _banLR+0
;MasterComunicacion.c,264 :: 		sizeSPI = 8;
	MOVLW      8
	MOVWF      _sizeSPI+0
;MasterComunicacion.c,265 :: 		tramaSPI[0] = 0x09;                             //Id esclavo
	MOVLW      9
	MOVWF      _tramaSPI+0
;MasterComunicacion.c,266 :: 		tramaSPI[1] = 0x01;                             //Codigo de funcion que se quiere ejecutar (00=Lectura, 01=Escritura)
	MOVLW      1
	MOVWF      _tramaSPI+1
;MasterComunicacion.c,267 :: 		tramaSPI[2] = 0x02;                             //# de registro que se quiere leer/escribir
	MOVLW      2
	MOVWF      _tramaSPI+2
;MasterComunicacion.c,268 :: 		tramaSPI[3] = sizeSPI-4;                        //# de datos del payload, como se trata de una solicitud de escritura no es necesario ningun dato adicioanl al registro que se quiere leer
	MOVLW      4
	MOVWF      _tramaSPI+3
;MasterComunicacion.c,269 :: 		tramaSPI[4] = 0xD1;                             //Datos ejemplo
	MOVLW      209
	MOVWF      _tramaSPI+4
;MasterComunicacion.c,270 :: 		tramaSPI[5] = 0xD2;
	MOVLW      210
	MOVWF      _tramaSPI+5
;MasterComunicacion.c,271 :: 		tramaSPI[6] = 0xD3;
	MOVLW      211
	MOVWF      _tramaSPI+6
;MasterComunicacion.c,272 :: 		tramaSPI[7] = 0xD4;
	MOVLW      212
	MOVWF      _tramaSPI+7
;MasterComunicacion.c,274 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
