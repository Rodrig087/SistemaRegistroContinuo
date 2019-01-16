
_ConfiguracionPrincipal:

;RPi_Simulacion.c,52 :: 		void ConfiguracionPrincipal(){
;RPi_Simulacion.c,54 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;RPi_Simulacion.c,55 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;RPi_Simulacion.c,57 :: 		TRISB0_bit = 1;
	BSF         TRISB0_bit+0, BitPos(TRISB0_bit+0) 
;RPi_Simulacion.c,58 :: 		TRISB1_bit = 1;
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;RPi_Simulacion.c,59 :: 		TRISC2_bit = 0;
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;RPi_Simulacion.c,61 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;RPi_Simulacion.c,62 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;RPi_Simulacion.c,65 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;RPi_Simulacion.c,68 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV64,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW       2
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	CLRF        FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	MOVLW       1
	MOVWF       FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;RPi_Simulacion.c,71 :: 		INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
	BSF         INTCON+0, 4 
;RPi_Simulacion.c,72 :: 		INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
	BCF         INTCON+0, 1 
;RPi_Simulacion.c,73 :: 		INTCON3.INT1IE = 1;                                //Habilita la interrupcion externa INT1
	BSF         INTCON3+0, 3 
;RPi_Simulacion.c,74 :: 		INTCON3.INT1IF = 0;                                //Limpia la bandera de interrupcion externa INT1
	BCF         INTCON3+0, 0 
;RPi_Simulacion.c,78 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;RPi_Simulacion.c,80 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_EnviarMensajeSPI:

;RPi_Simulacion.c,86 :: 		void EnviarMensajeSPI(unsigned char *trama, unsigned short sizePDU){
;RPi_Simulacion.c,87 :: 		CS = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,88 :: 		for (x=0;x<sizePDU;x++){
	CLRF        _x+0 
L_EnviarMensajeSPI1:
	MOVLW       128
	BTFSC       _x+0, 7 
	MOVLW       127
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__EnviarMensajeSPI15
	MOVF        FARG_EnviarMensajeSPI_sizePDU+0, 0 
	SUBWF       _x+0, 0 
L__EnviarMensajeSPI15:
	BTFSC       STATUS+0, 0 
	GOTO        L_EnviarMensajeSPI2
;RPi_Simulacion.c,89 :: 		SSPBUF = trama[x];                             //Llena el buffer de salida con cada valor de la tramaSPI
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
;RPi_Simulacion.c,90 :: 		Delay_ms(1);
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
;RPi_Simulacion.c,88 :: 		for (x=0;x<sizePDU;x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,91 :: 		}
	GOTO        L_EnviarMensajeSPI1
L_EnviarMensajeSPI2:
;RPi_Simulacion.c,92 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,93 :: 		}
L_end_EnviarMensajeSPI:
	RETURN      0
; end of _EnviarMensajeSPI

_interrupt:

;RPi_Simulacion.c,97 :: 		void interrupt(){
;RPi_Simulacion.c,101 :: 		if (INTCON3.INT1IF==1){
	BTFSS       INTCON3+0, 0 
	GOTO        L_interrupt5
;RPi_Simulacion.c,102 :: 		INTCON3.INT1IF = 0;                             //Limpia la badera de interrupcion externa
	BCF         INTCON3+0, 0 
;RPi_Simulacion.c,106 :: 		funcionRpi = 0x01;                              //Funcion que se requiere realizar. 0x00:Lectura  0x01:Escritura
	MOVLW       1
	MOVWF       _funcionRpi+0 
;RPi_Simulacion.c,107 :: 		direccionRpi = 0x09;                            //Direccion del esclavo destinatario de la peticion
	MOVLW       9
	MOVWF       _direccionRpi+0 
;RPi_Simulacion.c,108 :: 		registroRPi = 0x02;                             //Registro que se desea leer o escribir
	MOVLW       2
	MOVWF       _registroRPi+0 
;RPi_Simulacion.c,110 :: 		tramaSPI[0] = 0xB0;                             //Cabecera
	MOVLW       176
	MOVWF       _tramaSPI+0 
;RPi_Simulacion.c,111 :: 		tramaSPI[1] = direccionRpi;                     //Direccion
	MOVLW       9
	MOVWF       _tramaSPI+1 
;RPi_Simulacion.c,112 :: 		tramaSPI[2] = funcionRpi;                       //Funcion
	MOVLW       1
	MOVWF       _tramaSPI+2 
;RPi_Simulacion.c,113 :: 		tramaSPI[3] = registroRPi;                      //Registro
	MOVLW       2
	MOVWF       _tramaSPI+3 
;RPi_Simulacion.c,121 :: 		}else{
L_interrupt6:
;RPi_Simulacion.c,123 :: 		tipoDato = 0x02;                             //0x00: Short, 0x01: Entero, 0x02: Float
	MOVLW       2
	MOVWF       _tipoDato+0 
;RPi_Simulacion.c,124 :: 		switch (tipoDato){
	GOTO        L_interrupt8
;RPi_Simulacion.c,125 :: 		case 0:
L_interrupt10:
;RPi_Simulacion.c,126 :: 		numDatos = 1;
	MOVLW       1
	MOVWF       _numDatos+0 
;RPi_Simulacion.c,127 :: 		tramaSPI[4] = numDatos;          //#Datos
	MOVLW       1
	MOVWF       _tramaSPI+4 
;RPi_Simulacion.c,128 :: 		tramaSPI[5] = 0x5C;              //Datos
	MOVLW       92
	MOVWF       _tramaSPI+5 
;RPi_Simulacion.c,129 :: 		tramaSPI[numDatos+5] = 0xB1;
	MOVLW       6
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVLW       _tramaSPI+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaSPI+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       177
	MOVWF       POSTINC1+0 
;RPi_Simulacion.c,130 :: 		break;
	GOTO        L_interrupt9
;RPi_Simulacion.c,131 :: 		case 1:
L_interrupt11:
;RPi_Simulacion.c,132 :: 		numDatos = 2;
	MOVLW       2
	MOVWF       _numDatos+0 
;RPi_Simulacion.c,133 :: 		tramaSPI[4] = numDatos;          //#Datos
	MOVLW       2
	MOVWF       _tramaSPI+4 
;RPi_Simulacion.c,134 :: 		tramaSPI[5] = 0x5C;              //Datos
	MOVLW       92
	MOVWF       _tramaSPI+5 
;RPi_Simulacion.c,135 :: 		tramaSPI[6] = 0x8F;
	MOVLW       143
	MOVWF       _tramaSPI+6 
;RPi_Simulacion.c,136 :: 		tramaSPI[numDatos+5] = 0xB1;
	MOVLW       7
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVLW       _tramaSPI+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaSPI+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       177
	MOVWF       POSTINC1+0 
;RPi_Simulacion.c,137 :: 		break;
	GOTO        L_interrupt9
;RPi_Simulacion.c,138 :: 		case 2:
L_interrupt12:
;RPi_Simulacion.c,139 :: 		numDatos = 4;
	MOVLW       4
	MOVWF       _numDatos+0 
;RPi_Simulacion.c,140 :: 		tramaSPI[4] = numDatos;          //#Datos
	MOVLW       4
	MOVWF       _tramaSPI+4 
;RPi_Simulacion.c,141 :: 		tramaSPI[5] = 0x5C;              //Datos
	MOVLW       92
	MOVWF       _tramaSPI+5 
;RPi_Simulacion.c,142 :: 		tramaSPI[6] = 0x8F;
	MOVLW       143
	MOVWF       _tramaSPI+6 
;RPi_Simulacion.c,143 :: 		tramaSPI[7] = 0x58;
	MOVLW       88
	MOVWF       _tramaSPI+7 
;RPi_Simulacion.c,144 :: 		tramaSPI[8] = 0x83;
	MOVLW       131
	MOVWF       _tramaSPI+8 
;RPi_Simulacion.c,145 :: 		tramaSPI[numDatos+5] = 0xB1;
	MOVLW       9
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVLW       _tramaSPI+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_tramaSPI+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       177
	MOVWF       POSTINC1+0 
;RPi_Simulacion.c,146 :: 		break;
	GOTO        L_interrupt9
;RPi_Simulacion.c,147 :: 		}
L_interrupt8:
	MOVF        _tipoDato+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt10
	MOVF        _tipoDato+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt11
	MOVF        _tipoDato+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt12
L_interrupt9:
;RPi_Simulacion.c,149 :: 		EnviarMensajeSPI(tramaSPI,(numDatos+6));
	MOVLW       _tramaSPI+0
	MOVWF       FARG_EnviarMensajeSPI_trama+0 
	MOVLW       hi_addr(_tramaSPI+0)
	MOVWF       FARG_EnviarMensajeSPI_trama+1 
	MOVLW       6
	ADDWF       _numDatos+0, 0 
	MOVWF       FARG_EnviarMensajeSPI_sizePDU+0 
	CALL        _EnviarMensajeSPI+0, 0
;RPi_Simulacion.c,153 :: 		}
L_interrupt5:
;RPi_Simulacion.c,154 :: 		}
L_end_interrupt:
L__interrupt17:
	RETFIE      1
; end of _interrupt

_main:

;RPi_Simulacion.c,157 :: 		void main() {
;RPi_Simulacion.c,159 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;RPi_Simulacion.c,160 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,161 :: 		byteTrama = 0;                                       //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;RPi_Simulacion.c,162 :: 		banTI = 0;                                           //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;RPi_Simulacion.c,163 :: 		banTC = 0;                                           //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;RPi_Simulacion.c,164 :: 		banTF = 0;                                           //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;RPi_Simulacion.c,166 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
