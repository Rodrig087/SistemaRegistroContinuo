
_ConfiguracionPrincipal:

;RPi_Simulacion.c,53 :: 		void ConfiguracionPrincipal(){
;RPi_Simulacion.c,55 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;RPi_Simulacion.c,56 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;RPi_Simulacion.c,58 :: 		TRISB0_bit = 1;
	BSF         TRISB0_bit+0, BitPos(TRISB0_bit+0) 
;RPi_Simulacion.c,59 :: 		TRISB1_bit = 1;
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;RPi_Simulacion.c,60 :: 		TRISC2_bit = 0;
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;RPi_Simulacion.c,62 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;RPi_Simulacion.c,63 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;RPi_Simulacion.c,66 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;RPi_Simulacion.c,69 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW       2
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	CLRF        FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	MOVLW       1
	MOVWF       FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;RPi_Simulacion.c,72 :: 		INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
	BSF         INTCON+0, 4 
;RPi_Simulacion.c,73 :: 		INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
	BCF         INTCON+0, 1 
;RPi_Simulacion.c,74 :: 		INTCON3.INT1IE = 1;                                //Habilita la interrupcion externa INT1
	BSF         INTCON3+0, 3 
;RPi_Simulacion.c,75 :: 		INTCON3.INT1IF = 0;                                //Limpia la bandera de interrupcion externa INT1
	BCF         INTCON3+0, 0 
;RPi_Simulacion.c,79 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_ConfiguracionPrincipal0:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionPrincipal0
	NOP
;RPi_Simulacion.c,81 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_EnviarMensajeSPI:

;RPi_Simulacion.c,87 :: 		void EnviarMensajeSPI(unsigned char *trama, unsigned short sizePDU){
;RPi_Simulacion.c,88 :: 		CS = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,89 :: 		for (x=0;x<sizePDU;x++){
	CLRF        _x+0 
L_EnviarMensajeSPI1:
	MOVLW       128
	BTFSC       _x+0, 7 
	MOVLW       127
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__EnviarMensajeSPI39
	MOVF        FARG_EnviarMensajeSPI_sizePDU+0, 0 
	SUBWF       _x+0, 0 
L__EnviarMensajeSPI39:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeSPI2
;RPi_Simulacion.c,90 :: 		SSPBUF = trama[x];                             //Llena el buffer de salida con cada valor de la tramaSPI
	MOVF        _x+0, 0 
	ADDWF       FARG_EnviarMensajeSPI_trama+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	BTFSC       _x+0, 7 
	MOVLW       255
	ADDWFC      FARG_EnviarMensajeSPI_trama+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,91 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_EnviarMensajeSPI4:
	DECFSZ      R13, 1, 1
	BRA         L_EnviarMensajeSPI4
	DECFSZ      R12, 1, 1
	BRA         L_EnviarMensajeSPI4
	NOP
	NOP
;RPi_Simulacion.c,89 :: 		for (x=0;x<sizePDU;x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,92 :: 		}
	GOTO        L_EnviarMensajeSPI1
L_EnviarMensajeSPI2:
;RPi_Simulacion.c,93 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,94 :: 		}
L_end_EnviarMensajeSPI:
	RETURN      0
; end of _EnviarMensajeSPI

_RecuperarRespuestaSPI:

;RPi_Simulacion.c,100 :: 		unsigned short RecuperarRespuestaSPI(){
;RPi_Simulacion.c,111 :: 		tramaSPI[0] = 0xC0;
	MOVLW       192
	MOVWF       _tramaSPI+0 
;RPi_Simulacion.c,112 :: 		tramaSPI[1] = 0xCC;
	MOVLW       204
	MOVWF       _tramaSPI+1 
;RPi_Simulacion.c,113 :: 		tramaSPI[2] = 0xC1;
	MOVLW       193
	MOVWF       _tramaSPI+2 
;RPi_Simulacion.c,114 :: 		CS = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,115 :: 		for (x=0;x<3;x++){
	CLRF        _x+0 
L_RecuperarRespuestaSPI5:
	MOVLW       128
	XORWF       _x+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_RecuperarRespuestaSPI6
;RPi_Simulacion.c,116 :: 		SSPBUF = tramaSPI[x];                          //Llena el buffer de salida con cada valor de la tramaSPI
	MOVLW       _tramaSPI+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_tramaSPI+0)
	MOVWF       FSR0H 
	MOVF        _x+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _x+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,117 :: 		if (x==2){
	MOVF        _x+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_RecuperarRespuestaSPI8
;RPi_Simulacion.c,118 :: 		while (SSP1STAT.BF!=1);
L_RecuperarRespuestaSPI9:
	BTFSC       SSP1STAT+0, 0 
	GOTO        L_RecuperarRespuestaSPI10
	GOTO        L_RecuperarRespuestaSPI9
L_RecuperarRespuestaSPI10:
;RPi_Simulacion.c,119 :: 		numBytes = SSPBUF;                          //Recupera el numero de bytes de la trama de respuesta
	MOVF        SSPBUF+0, 0 
	MOVWF       RecuperarRespuestaSPI_numBytes_L0+0 
;RPi_Simulacion.c,120 :: 		}
L_RecuperarRespuestaSPI8:
;RPi_Simulacion.c,121 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_RecuperarRespuestaSPI11:
	DECFSZ      R13, 1, 1
	BRA         L_RecuperarRespuestaSPI11
	DECFSZ      R12, 1, 1
	BRA         L_RecuperarRespuestaSPI11
	NOP
	NOP
;RPi_Simulacion.c,115 :: 		for (x=0;x<3;x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,122 :: 		}
	GOTO        L_RecuperarRespuestaSPI5
L_RecuperarRespuestaSPI6:
;RPi_Simulacion.c,123 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,125 :: 		Delay_ms(100);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_RecuperarRespuestaSPI12:
	DECFSZ      R13, 1, 1
	BRA         L_RecuperarRespuestaSPI12
	DECFSZ      R12, 1, 1
	BRA         L_RecuperarRespuestaSPI12
	DECFSZ      R11, 1, 1
	BRA         L_RecuperarRespuestaSPI12
	NOP
;RPi_Simulacion.c,127 :: 		if ((numbytes!=0xC0)||(numbytes!=0xCC)||(numbytes!=0xC1)||(numbytes!=0x00)){
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	XORLW       192
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI36
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	XORLW       204
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI36
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	XORLW       193
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI36
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI36
	GOTO        L_RecuperarRespuestaSPI15
L__RecuperarRespuestaSPI36:
;RPi_Simulacion.c,128 :: 		CS = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,129 :: 		SSPBUF = 0xD0;
	MOVLW       208
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,130 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_RecuperarRespuestaSPI16:
	DECFSZ      R13, 1, 1
	BRA         L_RecuperarRespuestaSPI16
	DECFSZ      R12, 1, 1
	BRA         L_RecuperarRespuestaSPI16
	NOP
	NOP
;RPi_Simulacion.c,131 :: 		for (x=0;x<(numBytes);x++){
	CLRF        _x+0 
L_RecuperarRespuestaSPI17:
	MOVLW       128
	BTFSC       _x+0, 7 
	MOVLW       127
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI41
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	SUBWF       _x+0, 0 
L__RecuperarRespuestaSPI41:
	BTFSC       STATUS+0, 0 
	GOTO        L_RecuperarRespuestaSPI18
;RPi_Simulacion.c,132 :: 		SSPBUF = 0xDD;
	MOVLW       221
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,133 :: 		while (SSP1STAT.BF!=1);
L_RecuperarRespuestaSPI20:
	BTFSC       SSP1STAT+0, 0 
	GOTO        L_RecuperarRespuestaSPI21
	GOTO        L_RecuperarRespuestaSPI20
L_RecuperarRespuestaSPI21:
;RPi_Simulacion.c,134 :: 		tramaRespuesta[x] = SSPBUF;
	MOVLW       _tramaRespuesta+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaRespuesta+0)
	MOVWF       FSR1H 
	MOVF        _x+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _x+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        SSPBUF+0, 0 
	MOVWF       POSTINC1+0 
;RPi_Simulacion.c,135 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_RecuperarRespuestaSPI22:
	DECFSZ      R13, 1, 1
	BRA         L_RecuperarRespuestaSPI22
	DECFSZ      R12, 1, 1
	BRA         L_RecuperarRespuestaSPI22
	NOP
	NOP
;RPi_Simulacion.c,131 :: 		for (x=0;x<(numBytes);x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,136 :: 		}
	GOTO        L_RecuperarRespuestaSPI17
L_RecuperarRespuestaSPI18:
;RPi_Simulacion.c,137 :: 		SSPBUF = 0xD1;
	MOVLW       209
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,138 :: 		Delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_RecuperarRespuestaSPI23:
	DECFSZ      R13, 1, 1
	BRA         L_RecuperarRespuestaSPI23
	DECFSZ      R12, 1, 1
	BRA         L_RecuperarRespuestaSPI23
	NOP
	NOP
;RPi_Simulacion.c,139 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,140 :: 		}
L_RecuperarRespuestaSPI15:
;RPi_Simulacion.c,142 :: 		for (x=0;x<(numBytes);x++){
	CLRF        _x+0 
L_RecuperarRespuestaSPI24:
	MOVLW       128
	BTFSC       _x+0, 7 
	MOVLW       127
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__RecuperarRespuestaSPI42
	MOVF        RecuperarRespuestaSPI_numBytes_L0+0, 0 
	SUBWF       _x+0, 0 
L__RecuperarRespuestaSPI42:
	BTFSC       STATUS+0, 0 
	GOTO        L_RecuperarRespuestaSPI25
;RPi_Simulacion.c,143 :: 		UART1_Write(tramaRespuesta[x]);
	MOVLW       _tramaRespuesta+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_tramaRespuesta+0)
	MOVWF       FSR0H 
	MOVF        _x+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _x+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;RPi_Simulacion.c,142 :: 		for (x=0;x<(numBytes);x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,144 :: 		}
	GOTO        L_RecuperarRespuestaSPI24
L_RecuperarRespuestaSPI25:
;RPi_Simulacion.c,146 :: 		}
L_end_RecuperarRespuestaSPI:
	RETURN      0
; end of _RecuperarRespuestaSPI

_interrupt:

;RPi_Simulacion.c,150 :: 		void interrupt(){
;RPi_Simulacion.c,154 :: 		if (INTCON3.INT1IF==1){
	BTFSS       INTCON3+0, 0 
	GOTO        L_interrupt27
;RPi_Simulacion.c,155 :: 		INTCON3.INT1IF = 0;                             //Limpia la badera de interrupcion externa
	BCF         INTCON3+0, 0 
;RPi_Simulacion.c,159 :: 		funcionRpi = 0x00;                              //Funcion que se requiere realizar. 0x00:Lectura  0x01:Escritura
	CLRF        _funcionRpi+0 
;RPi_Simulacion.c,160 :: 		direccionRpi = 0x09;                            //Direccion del esclavo destinatario de la peticion
	MOVLW       9
	MOVWF       _direccionRpi+0 
;RPi_Simulacion.c,161 :: 		registroRPi = 0x02;                             //Registro que se desea leer o escribir
	MOVLW       2
	MOVWF       _registroRPi+0 
;RPi_Simulacion.c,163 :: 		tramaSPI[0] = 0xB0;                             //Cabecera
	MOVLW       176
	MOVWF       _tramaSPI+0 
;RPi_Simulacion.c,164 :: 		tramaSPI[1] = direccionRpi;                     //Direccion
	MOVLW       9
	MOVWF       _tramaSPI+1 
;RPi_Simulacion.c,165 :: 		tramaSPI[2] = funcionRpi;                       //Funcion
	CLRF        _tramaSPI+2 
;RPi_Simulacion.c,166 :: 		tramaSPI[3] = registroRPi;                      //Registro
	MOVLW       2
	MOVWF       _tramaSPI+3 
;RPi_Simulacion.c,170 :: 		tramaSPI[4] = 0x00;                          //#Datos
	CLRF        _tramaSPI+4 
;RPi_Simulacion.c,171 :: 		tramaSPI[5] = 0xB1;                          //Fin
	MOVLW       177
	MOVWF       _tramaSPI+5 
;RPi_Simulacion.c,172 :: 		EnviarMensajeSPI(tramaSPI,6);
	MOVLW       _tramaSPI+0
	MOVWF       FARG_EnviarMensajeSPI_trama+0 
	MOVLW       hi_addr(_tramaSPI+0)
	MOVWF       FARG_EnviarMensajeSPI_trama+1 
	MOVLW       6
	MOVWF       FARG_EnviarMensajeSPI_sizePDU+0 
	CALL        _EnviarMensajeSPI+0, 0
;RPi_Simulacion.c,204 :: 		}
L_interrupt29:
;RPi_Simulacion.c,206 :: 		}
L_interrupt27:
;RPi_Simulacion.c,211 :: 		if (INTCON.INT0IF==1){
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt35
;RPi_Simulacion.c,212 :: 		INTCON.INT0IF = 0;                                //Limpia la badera de interrupcion externa
	BCF         INTCON+0, 1 
;RPi_Simulacion.c,213 :: 		RecuperarRespuestaSPI();
	CALL        _RecuperarRespuestaSPI+0, 0
;RPi_Simulacion.c,214 :: 		}
L_interrupt35:
;RPi_Simulacion.c,216 :: 		}
L_end_interrupt:
L__interrupt44:
	RETFIE      1
; end of _interrupt

_main:

;RPi_Simulacion.c,219 :: 		void main() {
;RPi_Simulacion.c,221 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;RPi_Simulacion.c,222 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,223 :: 		byteTrama = 0;                                       //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;RPi_Simulacion.c,224 :: 		banTI = 0;                                           //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;RPi_Simulacion.c,225 :: 		banTC = 0;                                           //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;RPi_Simulacion.c,226 :: 		banTF = 0;                                           //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;RPi_Simulacion.c,228 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
