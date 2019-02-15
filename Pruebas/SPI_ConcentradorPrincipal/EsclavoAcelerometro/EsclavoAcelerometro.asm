
_ConfiguracionPrincipal:

;EsclavoAcelerometro.c,76 :: 		void ConfiguracionPrincipal(){
;EsclavoAcelerometro.c,78 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;EsclavoAcelerometro.c,79 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;EsclavoAcelerometro.c,81 :: 		TRISB1_bit = 1;                                    //Configura el pin B1 como entrada
	BSF         TRISB1_bit+0, BitPos(TRISB1_bit+0) 
;EsclavoAcelerometro.c,82 :: 		TRISB3_bit = 0;                                    //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;EsclavoAcelerometro.c,83 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;EsclavoAcelerometro.c,84 :: 		TRISC1_bit = 0;                                    //Configura el pin C1 como salida
	BCF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;EsclavoAcelerometro.c,85 :: 		TRISC2_bit = 0;                                    //Configura el pin C2 como salida
	BCF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;EsclavoAcelerometro.c,87 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;EsclavoAcelerometro.c,88 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;EsclavoAcelerometro.c,91 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	MOVLW       128
	MOVWF       FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	CLRF        FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;EsclavoAcelerometro.c,92 :: 		PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;EsclavoAcelerometro.c,93 :: 		PIR1.SSP1IF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,95 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_ConfiguracionPrincipal0:
	DECFSZ      R13, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R12, 1, 1
	BRA         L_ConfiguracionPrincipal0
	DECFSZ      R11, 1, 1
	BRA         L_ConfiguracionPrincipal0
	NOP
	NOP
;EsclavoAcelerometro.c,97 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_pulsoAux:

;EsclavoAcelerometro.c,100 :: 		void pulsoAux(){
;EsclavoAcelerometro.c,102 :: 		AUX = 1;
	BSF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,103 :: 		Delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;EsclavoAcelerometro.c,104 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,106 :: 		}
L_end_pulsoAux:
	RETURN      0
; end of _pulsoAux

_interrupt:

;EsclavoAcelerometro.c,110 :: 		void interrupt(void){
;EsclavoAcelerometro.c,113 :: 		if (PIR1.SSP1IF==1){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt1
;EsclavoAcelerometro.c,115 :: 		buffer = SSP1BUF;                                //Guarda el contenido del bufeer (lectura)
	MOVF        SSP1BUF+0, 0 
	MOVWF       _buffer+0 
;EsclavoAcelerometro.c,116 :: 		Delay_us(50);
	MOVLW       83
	MOVWF       R13, 0
L_interrupt2:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt2
;EsclavoAcelerometro.c,117 :: 		pulsoAux();
	CALL        _pulsoAux+0, 0
;EsclavoAcelerometro.c,120 :: 		if ((buffer==0xB0)){               //Verifica si el primer byte es la cabecera de datos
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
;EsclavoAcelerometro.c,121 :: 		banLec = 1;                                  //Activa la bandera de lectura
	MOVLW       1
	MOVWF       _banLec+0 
;EsclavoAcelerometro.c,122 :: 		i = 0;
	CLRF        _i+0 
	CLRF        _i+1 
;EsclavoAcelerometro.c,123 :: 		}
L_interrupt3:
;EsclavoAcelerometro.c,124 :: 		if ((banLec==1)&&(buffer!=0xB0)){
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt6
	MOVF        _buffer+0, 0 
	XORLW       176
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
L__interrupt14:
;EsclavoAcelerometro.c,126 :: 		SSP1BUF = datosAcelerometro[i];
	MOVLW       _datosAcelerometro+0
	ADDWF       _i+0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_datosAcelerometro+0)
	ADDWFC      _i+1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_datosAcelerometro+0)
	MOVWF       TBLPTRU 
	MOVLW       0
	ADDWFC      TBLPTRU, 1 
	TBLRD*+
	MOVFF       TABLAT+0, SSP1BUF+0
;EsclavoAcelerometro.c,129 :: 		i++;
	INFSNZ      _i+0, 1 
	INCF        _i+1, 1 
;EsclavoAcelerometro.c,130 :: 		}
L_interrupt6:
;EsclavoAcelerometro.c,131 :: 		if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
L__interrupt13:
;EsclavoAcelerometro.c,132 :: 		banLec = 0;                                  //Limpia la bandera de medicion
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,133 :: 		i = 0;
	CLRF        _i+0 
	CLRF        _i+1 
;EsclavoAcelerometro.c,134 :: 		}
L_interrupt9:
;EsclavoAcelerometro.c,136 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,138 :: 		}
L_interrupt1:
;EsclavoAcelerometro.c,140 :: 		}
L_end_interrupt:
L__interrupt18:
	RETFIE      1
; end of _interrupt

_main:

;EsclavoAcelerometro.c,143 :: 		void main() {
;EsclavoAcelerometro.c,145 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;EsclavoAcelerometro.c,154 :: 		cabecera[0] = 58;
	MOVLW       58
	MOVWF       _cabecera+0 
;EsclavoAcelerometro.c,155 :: 		cabecera[1] = 25;
	MOVLW       25
	MOVWF       _cabecera+1 
;EsclavoAcelerometro.c,156 :: 		cabecera[2] = 66;
	MOVLW       66
	MOVWF       _cabecera+2 
;EsclavoAcelerometro.c,157 :: 		cabecera[3] = 22;
	MOVLW       22
	MOVWF       _cabecera+3 
;EsclavoAcelerometro.c,158 :: 		cabecera[4] = 32;
	MOVLW       32
	MOVWF       _cabecera+4 
;EsclavoAcelerometro.c,159 :: 		cabecera[5] = 0;
	CLRF        _cabecera+5 
;EsclavoAcelerometro.c,162 :: 		banLec = 0;
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,163 :: 		banEsC = 0;
	CLRF        _banEsc+0 
;EsclavoAcelerometro.c,164 :: 		i = 0;
	CLRF        _i+0 
	CLRF        _i+1 
;EsclavoAcelerometro.c,165 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,167 :: 		while(1){
L_main10:
;EsclavoAcelerometro.c,169 :: 		Delay_ms(500);
	MOVLW       13
	MOVWF       R11, 0
	MOVLW       175
	MOVWF       R12, 0
	MOVLW       182
	MOVWF       R13, 0
L_main12:
	DECFSZ      R13, 1, 1
	BRA         L_main12
	DECFSZ      R12, 1, 1
	BRA         L_main12
	DECFSZ      R11, 1, 1
	BRA         L_main12
	NOP
;EsclavoAcelerometro.c,170 :: 		i = 0;
	CLRF        _i+0 
	CLRF        _i+1 
;EsclavoAcelerometro.c,173 :: 		}
	GOTO        L_main10
;EsclavoAcelerometro.c,176 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
