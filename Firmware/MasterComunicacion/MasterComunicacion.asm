
_ConfiguracionPrincipal:

;MasterComunicacion.c,62 :: 		void ConfiguracionPrincipal(){
;MasterComunicacion.c,64 :: 		ANSELA = 0;                                        //Configura PORTB como digital
	CLRF       ANSELA+0
;MasterComunicacion.c,65 :: 		ANSELB = 0;                                        //Configura PORTC como digital
	CLRF       ANSELB+0
;MasterComunicacion.c,66 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;MasterComunicacion.c,67 :: 		TRISB2_bit = 1;
	BSF        TRISB2_bit+0, BitPos(TRISB2_bit+0)
;MasterComunicacion.c,68 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;MasterComunicacion.c,69 :: 		TRISB5_bit = 0;
	BCF        TRISB5_bit+0, BitPos(TRISB5_bit+0)
;MasterComunicacion.c,70 :: 		TRISB6_bit = 0;
	BCF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;MasterComunicacion.c,72 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;MasterComunicacion.c,73 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;MasterComunicacion.c,76 :: 		APFCON0.RXDTSEL = 1;                               //Rx => RB2
	BSF        APFCON0+0, 7
;MasterComunicacion.c,77 :: 		APFCON1.TXCKSEL = 1;                               //Tx => RB5
	BSF        APFCON1+0, 0
;MasterComunicacion.c,78 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	BSF        BAUDCON+0, 3
	MOVLW      103
	MOVWF      SPBRG+0
	MOVLW      0
	MOVWF      SPBRG+1
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;MasterComunicacion.c,81 :: 		APFCON0.SDO1SEL = 1;                               //SDO1 => RA6
	BSF        APFCON0+0, 6
;MasterComunicacion.c,82 :: 		APFCON0.SS1SEL = 1;                                //SS1 => RA5
	BSF        APFCON0+0, 5
;MasterComunicacion.c,83 :: 		SPI1_Init();                                       //Inicializa el SPI1
	CALL       _SPI1_Init+0
;MasterComunicacion.c,86 :: 		T1CON = 0x30;
	MOVLW      48
	MOVWF      T1CON+0
;MasterComunicacion.c,87 :: 		TMR1IF_bit = 0;
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,88 :: 		TMR1H = 0x0B;
	MOVLW      11
	MOVWF      TMR1H+0
;MasterComunicacion.c,89 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;MasterComunicacion.c,90 :: 		TMR1IE_bit = 1;
	BSF        TMR1IE_bit+0, BitPos(TMR1IE_bit+0)
;MasterComunicacion.c,91 :: 		INTCON = 0xC0;
	MOVLW      192
	MOVWF      INTCON+0
;MasterComunicacion.c,94 :: 		T2CON = 0x78;
	MOVLW      120
	MOVWF      T2CON+0
;MasterComunicacion.c,95 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;MasterComunicacion.c,96 :: 		TMR2IE_bit	= 1;
	BSF        TMR2IE_bit+0, BitPos(TMR2IE_bit+0)
;MasterComunicacion.c,99 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;MasterComunicacion.c,100 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;MasterComunicacion.c,101 :: 		OPTION_REG.INTEDG = 0;                             //Activa la interrupcion en el flanco de bajada
	BCF        OPTION_REG+0, 6
;MasterComunicacion.c,103 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW      2
	MOVWF      R11
	MOVLW      4
	MOVWF      R12
	MOVLW      186
	MOVWF      R13
L_ConfiguracionPrincipal0:
	DECFSZ     R13, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R12, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R11, 1
	GOTO       L_ConfiguracionPrincipal0
	NOP
;MasterComunicacion.c,105 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;MasterComunicacion.c,111 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;MasterComunicacion.c,114 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;MasterComunicacion.c,115 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR0L
	MOVF       FARG_CalcularCRC_trama+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
	BTFSC      STATUS+0, 2
	INCF       FARG_CalcularCRC_trama+1, 1
;MasterComunicacion.c,116 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;MasterComunicacion.c,117 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;MasterComunicacion.c,118 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	LSRF       R3+1, 1
	RRF        R3+0, 1
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;MasterComunicacion.c,120 :: 		CRC16>>=1;
	LSRF       R3+1, 1
	RRF        R3+0, 1
L_CalcularCRC8:
;MasterComunicacion.c,116 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;MasterComunicacion.c,121 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;MasterComunicacion.c,114 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;MasterComunicacion.c,122 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;MasterComunicacion.c,123 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0
	MOVF       R3+1, 0
	MOVWF      R1
;MasterComunicacion.c,124 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeRS485:

;MasterComunicacion.c,128 :: 		void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
;MasterComunicacion.c,132 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+1, 0
	MOVWF      FARG_CalcularCRC_trama+1
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+0
	MOVF       R1, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+1
;MasterComunicacion.c,133 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+0
	MOVLW      hi_addr(EnviarMensajeRS485_CRCPDU_L0+0)
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+1
;MasterComunicacion.c,135 :: 		tramaRS485[0]=HDR;                                 //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _tramaRS485+0
;MasterComunicacion.c,136 :: 		tramaRS485[sizePDU+2] = *ptrCrcPdu;                //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVLW      2
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVLW      _tramaRS485+0
	ADDWF      R0, 0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	ADDWFC     R1, 0
	MOVWF      FSR1H
	MOVF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR0L
	MOVF       EnviarMensajeRS485_ptrCRCPDU_L0+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,137 :: 		tramaRS485[sizePDU+1] = *(ptrCrcPdu+1);            //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	ADDLW      1
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVLW      _tramaRS485+0
	ADDWF      R0, 0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	ADDWFC     R1, 0
	MOVWF      FSR1H
	MOVLW      1
	ADDWF      EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR0L
	MOVLW      0
	ADDWFC     EnviarMensajeRS485_ptrCRCPDU_L0+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,138 :: 		tramaRS485[sizePDU+3]=END1;                        //Añade el primer delimitador de final de trama
	MOVLW      3
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVLW      _tramaRS485+0
	ADDWF      R0, 0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	ADDWFC     R1, 0
	MOVWF      FSR1H
	MOVLW      13
	MOVWF      INDF1+0
;MasterComunicacion.c,139 :: 		tramaRS485[sizePDU+4]=END2;                        //Añade el segundo delimitador de final de trama
	MOVLW      4
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVLW      _tramaRS485+0
	ADDWF      R0, 0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	ADDWFC     R1, 0
	MOVWF      FSR1H
	MOVLW      10
	MOVWF      INDF1+0
;MasterComunicacion.c,140 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,141 :: 		for (i=0;i<(sizePDU+5);i++){
	CLRF       EnviarMensajeRS485_i_L0+0
L_EnviarMensajeRS4859:
	MOVLW      5
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R1
	CLRF       R2
	MOVLW      0
	ADDWFC     R2, 1
	MOVLW      128
	MOVWF      R0
	MOVLW      128
	XORWF      R2, 0
	SUBWF      R0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__EnviarMensajeRS48573
	MOVF       R1, 0
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
L__EnviarMensajeRS48573:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48510
;MasterComunicacion.c,142 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
L__EnviarMensajeRS48564:
;MasterComunicacion.c,143 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	SUBWFB     R1, 1
	MOVF       R0, 0
	ADDWF      FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     FARG_EnviarMensajeRS485_tramaPDU+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,144 :: 		} else {
	GOTO       L_EnviarMensajeRS48515
L_EnviarMensajeRS48514:
;MasterComunicacion.c,145 :: 		UART1_Write(tramaRS485[i]);                 //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVLW      _tramaRS485+0
	MOVWF      FSR0L
	MOVLW      hi_addr(_tramaRS485+0)
	MOVWF      FSR0H
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	ADDWF      FSR0L, 1
	BTFSC      STATUS+0, 0
	INCF       FSR0H, 1
	MOVF       INDF0+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,146 :: 		}
L_EnviarMensajeRS48515:
;MasterComunicacion.c,141 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeRS485_i_L0+0, 1
;MasterComunicacion.c,147 :: 		}
	GOTO       L_EnviarMensajeRS4859
L_EnviarMensajeRS48510:
;MasterComunicacion.c,148 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48516:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeRS48517
	GOTO       L_EnviarMensajeRS48516
L_EnviarMensajeRS48517:
;MasterComunicacion.c,149 :: 		RE_DE = 0;                                         //Establece el Max485-2 en modo de lectura;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,151 :: 		T1CON.TMR1ON = 1;                                  //Enciende el Timer1
	BSF        T1CON+0, 0
;MasterComunicacion.c,152 :: 		TMR1IF_bit = 0;                                    //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,153 :: 		TMR1H = 0x0B;                                      //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW      11
	MOVWF      TMR1H+0
;MasterComunicacion.c,154 :: 		TMR1L = 0xDC;
	MOVLW      220
	MOVWF      TMR1L+0
;MasterComunicacion.c,155 :: 		}
L_end_EnviarMensajeRS485:
	RETURN
; end of _EnviarMensajeRS485

_VerificarCRC:

;MasterComunicacion.c,162 :: 		unsigned int VerificarCRC(unsigned char* trama, unsigned char tramaPDUSize){
;MasterComunicacion.c,167 :: 		crcCalculado = 0;                                  //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF       VerificarCRC_crcCalculado_L0+0
	CLRF       VerificarCRC_crcCalculado_L0+1
;MasterComunicacion.c,168 :: 		crcTrama = 1;
	MOVLW      1
	MOVWF      VerificarCRC_crcTrama_L0+0
	MOVLW      0
	MOVWF      VerificarCRC_crcTrama_L0+1
;MasterComunicacion.c,169 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF       VerificarCRC_j_L0+0
L_VerificarCRC18:
	MOVF       VerificarCRC_j_L0+0, 0
	SUBWF      FARG_VerificarCRC_tramaPDUSize+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_VerificarCRC19
;MasterComunicacion.c,170 :: 		pdu[j] = trama[j+1];
	MOVF       VerificarCRC_j_L0+0, 0
	ADDWF      VerificarCRC_pdu_L0+0, 0
	MOVWF      FSR1L
	MOVLW      0
	ADDWFC     VerificarCRC_pdu_L0+1, 0
	MOVWF      FSR1H
	MOVF       VerificarCRC_j_L0+0, 0
	ADDLW      1
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVF       R0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     FARG_VerificarCRC_trama+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,169 :: 		for (j=0;j<=(tramaPDUSize);j++){                   //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF       VerificarCRC_j_L0+0, 1
;MasterComunicacion.c,171 :: 		}
	GOTO       L_VerificarCRC18
L_VerificarCRC19:
;MasterComunicacion.c,172 :: 		crcCalculado = CalcularCRC(pdu, tramaPDUSize);     //Invoca la funcion para el calculo del CRC de la trama PDU
	MOVF       VerificarCRC_pdu_L0+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       VerificarCRC_pdu_L0+1, 0
	MOVWF      FARG_CalcularCRC_trama+1
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0, 0
	MOVWF      VerificarCRC_crcCalculado_L0+0
	MOVF       R1, 0
	MOVWF      VerificarCRC_crcCalculado_L0+1
;MasterComunicacion.c,173 :: 		ptrCRCTrama = &CRCTrama;                           //Asociacion del puntero CRCPDU
	MOVLW      VerificarCRC_crcTrama_L0+0
	MOVWF      VerificarCRC_ptrCRCTrama_L0+0
	MOVLW      hi_addr(VerificarCRC_crcTrama_L0+0)
	MOVWF      VerificarCRC_ptrCRCTrama_L0+1
;MasterComunicacion.c,174 :: 		*ptrCRCTrama = trama[tramaPDUSize+2];              //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW      2
	ADDWF      FARG_VerificarCRC_tramaPDUSize+0, 0
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVF       R0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     FARG_VerificarCRC_trama+1, 0
	MOVWF      FSR0H
	MOVF       VerificarCRC_ptrCRCTrama_L0+0, 0
	MOVWF      FSR1L
	MOVF       VerificarCRC_ptrCRCTrama_L0+1, 0
	MOVWF      FSR1H
	MOVF       INDF0+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,175 :: 		*(ptrCRCTrama+1) = trama[tramaPDUSize+1];          //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW      1
	ADDWF      VerificarCRC_ptrCRCTrama_L0+0, 0
	MOVWF      FSR1L
	MOVLW      0
	ADDWFC     VerificarCRC_ptrCRCTrama_L0+1, 0
	MOVWF      FSR1H
	MOVF       FARG_VerificarCRC_tramaPDUSize+0, 0
	ADDLW      1
	MOVWF      R0
	CLRF       R1
	MOVLW      0
	ADDWFC     R1, 1
	MOVF       R0, 0
	ADDWF      FARG_VerificarCRC_trama+0, 0
	MOVWF      FSR0L
	MOVF       R1, 0
	ADDWFC     FARG_VerificarCRC_trama+1, 0
	MOVWF      FSR0H
	MOVF       INDF0+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,176 :: 		if (crcCalculado==CRCTrama) {                      //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF       VerificarCRC_crcCalculado_L0+1, 0
	XORWF      VerificarCRC_crcTrama_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__VerificarCRC75
	MOVF       VerificarCRC_crcTrama_L0+0, 0
	XORWF      VerificarCRC_crcCalculado_L0+0, 0
L__VerificarCRC75:
	BTFSS      STATUS+0, 2
	GOTO       L_VerificarCRC21
;MasterComunicacion.c,177 :: 		return 1;
	MOVLW      1
	MOVWF      R0
	MOVLW      0
	MOVWF      R1
	GOTO       L_end_VerificarCRC
;MasterComunicacion.c,178 :: 		} else {
L_VerificarCRC21:
;MasterComunicacion.c,179 :: 		return 0;
	CLRF       R0
	CLRF       R1
;MasterComunicacion.c,181 :: 		}
L_end_VerificarCRC:
	RETURN
; end of _VerificarCRC

_EnviarACK:

;MasterComunicacion.c,187 :: 		void EnviarACK(){
;MasterComunicacion.c,188 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,189 :: 		UART1_Write(ACK);                                  //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,190 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarACK23:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarACK24
	GOTO       L_EnviarACK23
L_EnviarACK24:
;MasterComunicacion.c,191 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,192 :: 		}
L_end_EnviarACK:
	RETURN
; end of _EnviarACK

_EnviarNACK:

;MasterComunicacion.c,198 :: 		void EnviarNACK(){
;MasterComunicacion.c,199 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,200 :: 		UART1_Write(NACK);                                 //Envia el valor de la Cabecera de la trama ACK por el puerto UART1
	MOVLW      175
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;MasterComunicacion.c,201 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarNACK25:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarNACK26
	GOTO       L_EnviarNACK25
L_EnviarNACK26:
;MasterComunicacion.c,202 :: 		RE_DE = 0;                                         //Establece el Max485 en modo de lectura;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,203 :: 		}
L_end_EnviarNACK:
	RETURN
; end of _EnviarNACK

_interrupt:

;MasterComunicacion.c,209 :: 		void interrupt(){
;MasterComunicacion.c,213 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt27
;MasterComunicacion.c,214 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;MasterComunicacion.c,216 :: 		tramaSPI[0]=0x03;                               //Ejemplo de trama de peticion enviada por la RPi
	MOVLW      3
	MOVWF      _tramaSPI+0
;MasterComunicacion.c,217 :: 		tramaSPI[1]=0x04;                               //CRC=0xF3C2
	MOVLW      4
	MOVWF      _tramaSPI+1
;MasterComunicacion.c,218 :: 		tramaSPI[2]=0x05;
	MOVLW      5
	MOVWF      _tramaSPI+2
;MasterComunicacion.c,219 :: 		tramaSPI[3]=0x06;
	MOVLW      6
	MOVWF      _tramaSPI+3
;MasterComunicacion.c,221 :: 		direccionRpi = tramaSPI[0];                     //Guarda el dato de la direccion del dispositvo con que se desea comunicar
	MOVF       _tramaSPI+0, 0
	MOVWF      _direccionRpi+0
;MasterComunicacion.c,222 :: 		sizeSPI = tramaSPI[1];                          //Guarda el dato de la longitud de la trama PDU
	MOVLW      4
	MOVWF      _sizeSPI+0
;MasterComunicacion.c,223 :: 		funcionRpi = tramaSPI[2];                       //Guarda el dato de la funcion requerida
	MOVLW      5
	MOVWF      _funcionRpi+0
;MasterComunicacion.c,225 :: 		if (direccionRpi==0xFD || direccionRpi==0xFE || direccionRpi==0xFF){
	MOVF       _tramaSPI+0, 0
	XORLW      253
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt69
	MOVF       _direccionRpi+0, 0
	XORLW      254
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt69
	MOVF       _direccionRpi+0, 0
	XORLW      255
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt69
	GOTO       L_interrupt30
L__interrupt69:
;MasterComunicacion.c,226 :: 		if (funcionRpi==0x01){                       //Verifica el campo de Funcion para ver si se trata de una sincronizacion de segundos
	MOVF       _funcionRpi+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt31
;MasterComunicacion.c,228 :: 		} else if (funcionRpi==0x02){                //Verifica el campo de Funcion para ver si se trata de una solicitud de sincronizacion de fecha y hora
	GOTO       L_interrupt32
L_interrupt31:
	MOVF       _funcionRpi+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt33
;MasterComunicacion.c,230 :: 		} else {
	GOTO       L_interrupt34
L_interrupt33:
;MasterComunicacion.c,231 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);    //Invoca a la funcion para enviar la peticion
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVLW      hi_addr(_tramaSPI+0)
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+1
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;MasterComunicacion.c,232 :: 		}
L_interrupt34:
L_interrupt32:
;MasterComunicacion.c,233 :: 		} else {
	GOTO       L_interrupt35
L_interrupt30:
;MasterComunicacion.c,234 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);       //Invoca a la funcion para enviar la peticion
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVLW      hi_addr(_tramaSPI+0)
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+1
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;MasterComunicacion.c,236 :: 		T1CON.TMR1ON = 1;                            //Enciende el Timer1
	BSF        T1CON+0, 0
;MasterComunicacion.c,237 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,238 :: 		TMR1H = 0x0B;                                //Se carga el valor del preload correspondiente al tiempo de 250ms
	MOVLW      11
	MOVWF      TMR1H+0
;MasterComunicacion.c,239 :: 		TMR1L = 0xDC;                                //al parecer este valor se pierde cada vez que entra a la interrupcion
	MOVLW      220
	MOVWF      TMR1L+0
;MasterComunicacion.c,240 :: 		}
L_interrupt35:
;MasterComunicacion.c,242 :: 		}
L_interrupt27:
;MasterComunicacion.c,250 :: 		if (PIR1.F5==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt36
;MasterComunicacion.c,252 :: 		IU1 = 1;                                        //Enciende el indicador de interrupcion por UART1
	BSF        RB6_bit+0, BitPos(RB6_bit+0)
;MasterComunicacion.c,253 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0, 0
	MOVWF      _byteTrama+0
;MasterComunicacion.c,255 :: 		if ((byteTrama==ACK)&&(banTI==0)){              //Verifica si recibio un ACK
	MOVF       R0, 0
	XORLW      170
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
L__interrupt68:
;MasterComunicacion.c,257 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;MasterComunicacion.c,258 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,259 :: 		}
L_interrupt39:
;MasterComunicacion.c,261 :: 		if ((byteTrama==NACK)&&(banTI==0)){             //Verifica si recibio un NACK
	MOVF       _byteTrama+0, 0
	XORLW      175
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt42
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt42
L__interrupt67:
;MasterComunicacion.c,263 :: 		T1CON.TMR1ON = 0;                            //Apaga el Timer1
	BCF        T1CON+0, 0
;MasterComunicacion.c,264 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,265 :: 		if (contadorNACK<3){
	MOVLW      3
	SUBWF      _contadorNACK+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt43
;MasterComunicacion.c,266 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);    //Si recibe un NACK como respuesta, le renvia la trama
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVLW      hi_addr(_tramaSPI+0)
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+1
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;MasterComunicacion.c,267 :: 		contadorNACK++;                           //Incrrmenta en una unidad el valor del contador de NACK
	INCF       _contadorNACK+0, 1
;MasterComunicacion.c,268 :: 		} else {
	GOTO       L_interrupt44
L_interrupt43:
;MasterComunicacion.c,270 :: 		contadorNACK = 0;                         //Limpia el contador de Time-Out-Trama
	CLRF       _contadorNACK+0
;MasterComunicacion.c,271 :: 		}
L_interrupt44:
;MasterComunicacion.c,273 :: 		}
L_interrupt42:
;MasterComunicacion.c,275 :: 		if ((byteTrama==HDR)&&(banTI==0)){
	MOVF       _byteTrama+0, 0
	XORLW      58
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt47
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt47
L__interrupt66:
;MasterComunicacion.c,276 :: 		tramaRS485[0]=byteTrama;                     //Guarda el primer byte de la trama en la primera posicion de la trama de peticion
	MOVF       _byteTrama+0, 0
	MOVWF      _tramaRS485+0
;MasterComunicacion.c,277 :: 		banTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;MasterComunicacion.c,278 :: 		i1 = 1;                                      //Define en 1 el subindice de la trama de peticion
	MOVLW      1
	MOVWF      _i1+0
;MasterComunicacion.c,279 :: 		tramaOk = 0;                                 //Limpia la variable que indica si la trama ha llegado correctamente
	CLRF       _tramaOk+0
;MasterComunicacion.c,281 :: 		T2CON.TMR2ON = 1;                            //Enciende el Timer2
	BSF        T2CON+0, 2
;MasterComunicacion.c,282 :: 		PR2 = 249;                                   //Se carga el valor del preload correspondiente al tiempo de 2ms
	MOVLW      249
	MOVWF      PR2+0
;MasterComunicacion.c,283 :: 		}
L_interrupt47:
;MasterComunicacion.c,285 :: 		if (banTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt48
;MasterComunicacion.c,286 :: 		T2CON.TMR2ON = 0;                            //Detiene el Time-Out-Trama
	BCF        T2CON+0, 2
;MasterComunicacion.c,287 :: 		if (i1==1){
	MOVF       _i1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt49
;MasterComunicacion.c,288 :: 		tramaRS485[i1] = byteTrama;               //Guarda el byte de Direccion en la segunda posicion del vector de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	MOVWF      FSR1H
	MOVF       _i1+0, 0
	ADDWF      FSR1L, 1
	MOVLW      0
	BTFSC      _i1+0, 7
	MOVLW      255
	ADDWFC     FSR1H, 1
	MOVF       _byteTrama+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,289 :: 		i1 = 2;                                   //Incrementa el subindice de la trama de peticion en una unidad
	MOVLW      2
	MOVWF      _i1+0
;MasterComunicacion.c,290 :: 		T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
	BSF        T2CON+0, 2
;MasterComunicacion.c,291 :: 		} else if (i1=2){
	GOTO       L_interrupt50
L_interrupt49:
	MOVLW      2
	MOVWF      _i1+0
;MasterComunicacion.c,292 :: 		tramaRS485[i1] = byteTrama;               //Guarda el byte de #Datos en la tercera posicion del vector de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FSR1L
	MOVLW      hi_addr(_tramaRS485+0)
	MOVWF      FSR1H
	MOVF       _i1+0, 0
	ADDWF      FSR1L, 1
	MOVLW      0
	BTFSC      _i1+0, 7
	MOVLW      255
	ADDWFC     FSR1H, 1
	MOVF       _byteTrama+0, 0
	MOVWF      INDF1+0
;MasterComunicacion.c,293 :: 		t1Size = byteTrama;                       //Guarda en la variable t1Size el valor del campo #Datos
	MOVF       _byteTrama+0, 0
	MOVWF      _t1Size+0
;MasterComunicacion.c,294 :: 		i1 = 3;                                   //Incrementa el subindice de la trama de peticion en una unidad
	MOVLW      3
	MOVWF      _i1+0
;MasterComunicacion.c,295 :: 		T2CON.TMR2ON = 1;                         //Enciende el Time-Out-Trama
	BSF        T2CON+0, 2
;MasterComunicacion.c,305 :: 		}
L_interrupt52:
L_interrupt50:
;MasterComunicacion.c,306 :: 		}
L_interrupt48:
;MasterComunicacion.c,308 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt57
;MasterComunicacion.c,310 :: 		tramaOk = VerificarCRC(tramaRS485,t1Size);   //Calcula y verifica el CRC de la trama de peticion
	MOVLW      _tramaRS485+0
	MOVWF      FARG_VerificarCRC_trama+0
	MOVLW      hi_addr(_tramaRS485+0)
	MOVWF      FARG_VerificarCRC_trama+1
	MOVF       _t1Size+0, 0
	MOVWF      FARG_VerificarCRC_tramaPDUSize+0
	CALL       _VerificarCRC+0
	MOVF       R0, 0
	MOVWF      _tramaOk+0
;MasterComunicacion.c,312 :: 		if (tramaOk==1){
	MOVF       R0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt58
;MasterComunicacion.c,313 :: 		EnviarACK();                             //Si la trama llego sin errores responde con un ACK al esclavo
	CALL       _EnviarACK+0
;MasterComunicacion.c,315 :: 		} else {
	GOTO       L_interrupt59
L_interrupt58:
;MasterComunicacion.c,316 :: 		EnviarNACK();                            //Si hubo algun error en la trama se envia un ACK al H/S para que reenvie la trama
	CALL       _EnviarNACK+0
;MasterComunicacion.c,317 :: 		}
L_interrupt59:
;MasterComunicacion.c,318 :: 		banTC = 0;                                   //Limpia la bandera de trama completa
	CLRF       _banTC+0
;MasterComunicacion.c,319 :: 		i1 = 0;                                      //Limpia el subindice de trama
	CLRF       _i1+0
;MasterComunicacion.c,321 :: 		}
L_interrupt57:
;MasterComunicacion.c,323 :: 		PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion de UART2
	BCF        PIR1+0, 5
;MasterComunicacion.c,324 :: 		IU1 = 0;                                        //Apaga el indicador de interrupcion por UART2
	BCF        RB6_bit+0, BitPos(RB6_bit+0)
;MasterComunicacion.c,327 :: 		}
L_interrupt36:
;MasterComunicacion.c,333 :: 		if (PIR1.TMR1IF==1){
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt60
;MasterComunicacion.c,334 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;MasterComunicacion.c,335 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF        T1CON+0, 0
;MasterComunicacion.c,336 :: 		if (contadorTOD<3){
	MOVLW      3
	SUBWF      _contadorTOD+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt61
;MasterComunicacion.c,337 :: 		EnviarMensajeRS485(tramaSPI, sizeSPI);       //Reenvia la trama por el bus RS485
	MOVLW      _tramaSPI+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVLW      hi_addr(_tramaSPI+0)
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+1
	MOVF       _sizeSPI+0, 0
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;MasterComunicacion.c,338 :: 		contadorTOD++;                               //Incrementa el contador de Time-Out-Dispositivo en una unidad
	INCF       _contadorTOD+0, 1
;MasterComunicacion.c,339 :: 		} else {
	GOTO       L_interrupt62
L_interrupt61:
;MasterComunicacion.c,341 :: 		contadorTOD = 0;                             //Limpia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;MasterComunicacion.c,342 :: 		}
L_interrupt62:
;MasterComunicacion.c,343 :: 		}
L_interrupt60:
;MasterComunicacion.c,350 :: 		if (PIR1.TMR2IF==1){
	BTFSS      PIR1+0, 1
	GOTO       L_interrupt63
;MasterComunicacion.c,351 :: 		TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        TMR2IF_bit+0, BitPos(TMR2IF_bit+0)
;MasterComunicacion.c,352 :: 		T2CON.TMR2ON = 0;                               //Apaga el Timer2
	BCF        T2CON+0, 2
;MasterComunicacion.c,353 :: 		banTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;MasterComunicacion.c,354 :: 		i1 = 0;                                         //Limpia el subindice de la trama de peticion
	CLRF       _i1+0
;MasterComunicacion.c,355 :: 		banTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF       _banTC+0
;MasterComunicacion.c,356 :: 		EnviarNACK();                                   //Envia un NACK para solicitar el reenvio de la trama
	CALL       _EnviarNACK+0
;MasterComunicacion.c,357 :: 		}
L_interrupt63:
;MasterComunicacion.c,359 :: 		}
L_end_interrupt:
L__interrupt79:
	RETFIE     %s
; end of _interrupt

_main:

;MasterComunicacion.c,363 :: 		void main() {
;MasterComunicacion.c,365 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;MasterComunicacion.c,366 :: 		RE_DE = 0;                                         //Establece el Max485-1 en modo de lectura;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;MasterComunicacion.c,367 :: 		i1=0;
	CLRF       _i1+0
;MasterComunicacion.c,368 :: 		contadorTOD = 0;                                   //Inicia el contador de Time-Out-Dispositivo
	CLRF       _contadorTOD+0
;MasterComunicacion.c,369 :: 		contadorNACK = 0;                                  //Inicia el contador de NACK
	CLRF       _contadorNACK+0
;MasterComunicacion.c,370 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
