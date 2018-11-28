
_ConfiguracionPrincipal:

;HSPrueba.c,53 :: 		void ConfiguracionPrincipal(){
;HSPrueba.c,55 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;HSPrueba.c,56 :: 		TRISC3_bit = 0;
	BCF        TRISC3_bit+0, BitPos(TRISC3_bit+0)
;HSPrueba.c,58 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;HSPrueba.c,59 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;HSPrueba.c,62 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;HSPrueba.c,65 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;HSPrueba.c,66 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;HSPrueba.c,67 :: 		OPTION_REG.INTEDG = 0;                             //Activa la interrupcion en el flanco de bajada
	BCF        OPTION_REG+0, 6
;HSPrueba.c,69 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;HSPrueba.c,71 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_CalcularCRC:

;HSPrueba.c,77 :: 		unsigned int CalcularCRC(unsigned char* trama, unsigned char tramaSize){
;HSPrueba.c,80 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	MOVLW      255
	MOVWF      R3+0
	MOVLW      255
	MOVWF      R3+1
L_CalcularCRC1:
	MOVF       FARG_CalcularCRC_tramaSize+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_CalcularCRC2
;HSPrueba.c,81 :: 		CRC16 ^=*trama ++;
	MOVF       FARG_CalcularCRC_trama+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORWF      R3+0, 1
	MOVLW      0
	XORWF      R3+1, 1
	INCF       FARG_CalcularCRC_trama+0, 1
;HSPrueba.c,82 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	CLRF       R2+0
L_CalcularCRC4:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalcularCRC5
;HSPrueba.c,83 :: 		if(CRC16 & 0x0001)
	BTFSS      R3+0, 0
	GOTO       L_CalcularCRC7
;HSPrueba.c,84 :: 		CRC16 = (CRC16 >>1)^POLMODBUS;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
	MOVLW      1
	XORWF      R3+0, 1
	MOVLW      160
	XORWF      R3+1, 1
	GOTO       L_CalcularCRC8
L_CalcularCRC7:
;HSPrueba.c,86 :: 		CRC16>>=1;
	RRF        R3+1, 1
	RRF        R3+0, 1
	BCF        R3+1, 7
L_CalcularCRC8:
;HSPrueba.c,82 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++){
	INCF       R2+0, 1
;HSPrueba.c,87 :: 		}
	GOTO       L_CalcularCRC4
L_CalcularCRC5:
;HSPrueba.c,80 :: 		for(CRC16=0xFFFF; tramaSize!=0; tramaSize --){
	DECF       FARG_CalcularCRC_tramaSize+0, 1
;HSPrueba.c,88 :: 		}
	GOTO       L_CalcularCRC1
L_CalcularCRC2:
;HSPrueba.c,89 :: 		return CRC16;
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
;HSPrueba.c,90 :: 		}
L_end_CalcularCRC:
	RETURN
; end of _CalcularCRC

_EnviarMensajeRS485:

;HSPrueba.c,96 :: 		void EnviarMensajeRS485(unsigned char *tramaPDU, unsigned char sizePDU){
;HSPrueba.c,100 :: 		CRCPDU = CalcularCRC(tramaPDU, sizePDU);           //Calcula el CRC de la trama pdu
	MOVF       FARG_EnviarMensajeRS485_tramaPDU+0, 0
	MOVWF      FARG_CalcularCRC_trama+0
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      FARG_CalcularCRC_tramaSize+0
	CALL       _CalcularCRC+0
	MOVF       R0+0, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+0
	MOVF       R0+1, 0
	MOVWF      EnviarMensajeRS485_CRCPDU_L0+1
;HSPrueba.c,101 :: 		ptrCRCPDU = &CRCPDU;                               //Asociacion del puntero CrcTramaError
	MOVLW      EnviarMensajeRS485_CRCPDU_L0+0
	MOVWF      EnviarMensajeRS485_ptrCRCPDU_L0+0
;HSPrueba.c,102 :: 		trama[0]=HDR;                                      //Añade la cabecera a la trama a enviar
	MOVLW      58
	MOVWF      _trama+0
;HSPrueba.c,103 :: 		trama[sizePDU+2]=*ptrCrcPdu;                       //Asigna al elemento CRC_LSB de la trama de respuesta el LSB de la variable crcTramaError
	MOVLW      2
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _trama+0
	MOVWF      R1+0
	MOVF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;HSPrueba.c,104 :: 		trama[sizePDU+1]=*(ptrCrcPdu+1);                   //Asigna al elemento CRC_MSB de la trama de respuesta el MSB de la variable crcTramaError
	MOVF       FARG_EnviarMensajeRS485_sizePDU+0, 0
	ADDLW      1
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _trama+0
	MOVWF      R1+0
	INCF       EnviarMensajeRS485_ptrCRCPDU_L0+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;HSPrueba.c,105 :: 		trama[sizePDU+3]=END1;                             //Añade el primer delimitador de final de trama
	MOVLW      3
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _trama+0
	MOVWF      FSR
	MOVLW      13
	MOVWF      INDF+0
;HSPrueba.c,106 :: 		trama[sizePDU+4]=END2;                             //Añade el segundo delimitador de final de trama
	MOVLW      4
	ADDWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	MOVF       R0+0, 0
	ADDLW      _trama+0
	MOVWF      FSR
	MOVLW      10
	MOVWF      INDF+0
;HSPrueba.c,107 :: 		for (i=0;i<(sizePDU+5);i++){
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
	GOTO       L__EnviarMensajeRS48525
	MOVF       R1+0, 0
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
L__EnviarMensajeRS48525:
	BTFSC      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48510
;HSPrueba.c,108 :: 		if ((i>=1)&&(i<=sizePDU)){
	MOVLW      1
	SUBWF      EnviarMensajeRS485_i_L0+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	SUBWF      FARG_EnviarMensajeRS485_sizePDU+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_EnviarMensajeRS48514
L__EnviarMensajeRS48521:
;HSPrueba.c,109 :: 		UART1_Write(tramaPDU[i-1]);                 //Envia el contenido de la trama PDU a travez del UART1
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
;HSPrueba.c,110 :: 		} else {
	GOTO       L_EnviarMensajeRS48515
L_EnviarMensajeRS48514:
;HSPrueba.c,111 :: 		UART1_Write(trama[i]);                      //Envia el contenido del resto de la trama de peticion a travez del UART1
	MOVF       EnviarMensajeRS485_i_L0+0, 0
	ADDLW      _trama+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;HSPrueba.c,112 :: 		}
L_EnviarMensajeRS48515:
;HSPrueba.c,107 :: 		for (i=0;i<(sizePDU+5);i++){
	INCF       EnviarMensajeRS485_i_L0+0, 1
;HSPrueba.c,113 :: 		}
	GOTO       L_EnviarMensajeRS4859
L_EnviarMensajeRS48510:
;HSPrueba.c,114 :: 		while(UART1_Tx_Idle()==0);                         //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_EnviarMensajeRS48516:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_EnviarMensajeRS48517
	GOTO       L_EnviarMensajeRS48516
L_EnviarMensajeRS48517:
;HSPrueba.c,115 :: 		TOUT = 1;
	BSF        RC3_bit+0, BitPos(RC3_bit+0)
;HSPrueba.c,116 :: 		Delay_ms(200);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      8
	MOVWF      R12+0
	MOVLW      119
	MOVWF      R13+0
L_EnviarMensajeRS48518:
	DECFSZ     R13+0, 1
	GOTO       L_EnviarMensajeRS48518
	DECFSZ     R12+0, 1
	GOTO       L_EnviarMensajeRS48518
	DECFSZ     R11+0, 1
	GOTO       L_EnviarMensajeRS48518
;HSPrueba.c,117 :: 		TOUT = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;HSPrueba.c,118 :: 		}
L_end_EnviarMensajeRS485:
	RETURN
; end of _EnviarMensajeRS485

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;HSPrueba.c,123 :: 		void interrupt(){
;HSPrueba.c,127 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt19
;HSPrueba.c,128 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;HSPrueba.c,129 :: 		INTCON.INTF=0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;HSPrueba.c,130 :: 		PDU[0]=0x03;                                    //Ejemplo de trama PDU
	MOVLW      3
	MOVWF      _PDU+0
;HSPrueba.c,131 :: 		PDU[1]=0x05;
	MOVLW      5
	MOVWF      _PDU+1
;HSPrueba.c,132 :: 		PDU[2]=0x05;
	MOVLW      5
	MOVWF      _PDU+2
;HSPrueba.c,133 :: 		PDU[3]=0x06;
	MOVLW      6
	MOVWF      _PDU+3
;HSPrueba.c,134 :: 		PDU[4]=0x07;
	MOVLW      7
	MOVWF      _PDU+4
;HSPrueba.c,135 :: 		sizePDU = PDU[1];                               //Guarda el dato de la longitud de la trama PDU
	MOVLW      5
	MOVWF      _sizePDU+0
;HSPrueba.c,136 :: 		EnviarMensajeRS485(PDU, sizePDU);               //Invoca a la funcion para enviar la peticion
	MOVLW      _PDU+0
	MOVWF      FARG_EnviarMensajeRS485_tramaPDU+0
	MOVLW      5
	MOVWF      FARG_EnviarMensajeRS485_sizePDU+0
	CALL       _EnviarMensajeRS485+0
;HSPrueba.c,137 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;HSPrueba.c,138 :: 		}
L_interrupt19:
;HSPrueba.c,139 :: 		}
L_end_interrupt:
L__interrupt27:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;HSPrueba.c,142 :: 		void main() {
;HSPrueba.c,144 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;HSPrueba.c,145 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;HSPrueba.c,146 :: 		TOUT = 1;
	BSF        RC3_bit+0, BitPos(RC3_bit+0)
;HSPrueba.c,147 :: 		Delay_ms(200);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      8
	MOVWF      R12+0
	MOVLW      119
	MOVWF      R13+0
L_main20:
	DECFSZ     R13+0, 1
	GOTO       L_main20
	DECFSZ     R12+0, 1
	GOTO       L_main20
	DECFSZ     R11+0, 1
	GOTO       L_main20
;HSPrueba.c,148 :: 		TOUT = 0;
	BCF        RC3_bit+0, BitPos(RC3_bit+0)
;HSPrueba.c,150 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
