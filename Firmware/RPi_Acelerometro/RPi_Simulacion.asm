
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
;RPi_Simulacion.c,63 :: 		SPI1_Init_Advanced(_SPI_MASTER_OSC_DIV4,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
	CLRF        FARG_SPI1_Init_Advanced_master+0 
	MOVLW       128
	MOVWF       FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	CLRF        FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;RPi_Simulacion.c,65 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;RPi_Simulacion.c,67 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_ProbarSPI:

;RPi_Simulacion.c,72 :: 		void ProbarSPI(){
;RPi_Simulacion.c,74 :: 		CS = 0;
	BCF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,75 :: 		SSPBUF = 0xB0;
	MOVLW       176
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,76 :: 		Delay_us(100);
	MOVLW       166
	MOVWF       R13, 0
L_ProbarSPI1:
	DECFSZ      R13, 1, 1
	BRA         L_ProbarSPI1
	NOP
;RPi_Simulacion.c,77 :: 		for (x=0;x<6;x++){
	CLRF        _x+0 
L_ProbarSPI2:
	MOVLW       128
	XORWF       _x+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ProbarSPI3
;RPi_Simulacion.c,78 :: 		SSPBUF = 0xBB;
	MOVLW       187
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,79 :: 		Delay_us(100);
	MOVLW       166
	MOVWF       R13, 0
L_ProbarSPI5:
	DECFSZ      R13, 1, 1
	BRA         L_ProbarSPI5
	NOP
;RPi_Simulacion.c,77 :: 		for (x=0;x<6;x++){
	INCF        _x+0, 1 
;RPi_Simulacion.c,80 :: 		}
	GOTO        L_ProbarSPI2
L_ProbarSPI3:
;RPi_Simulacion.c,81 :: 		SSPBUF = 0xB1;
	MOVLW       177
	MOVWF       SSPBUF+0 
;RPi_Simulacion.c,82 :: 		Delay_us(100);
	MOVLW       166
	MOVWF       R13, 0
L_ProbarSPI6:
	DECFSZ      R13, 1, 1
	BRA         L_ProbarSPI6
	NOP
;RPi_Simulacion.c,83 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,84 :: 		}
L_end_ProbarSPI:
	RETURN      0
; end of _ProbarSPI

_main:

;RPi_Simulacion.c,88 :: 		void main() {
;RPi_Simulacion.c,90 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;RPi_Simulacion.c,91 :: 		CS = 1;
	BSF         RC2_bit+0, BitPos(RC2_bit+0) 
;RPi_Simulacion.c,92 :: 		byteTrama = 0;                                       //Limpia la variable del byte de la trama de peticion
	CLRF        _byteTrama+0 
;RPi_Simulacion.c,93 :: 		banTI = 0;                                           //Limpia la bandera de inicio de trama
	CLRF        _banTI+0 
;RPi_Simulacion.c,94 :: 		banTC = 0;                                           //Limpia la bandera de trama completa
	CLRF        _banTC+0 
;RPi_Simulacion.c,95 :: 		banTF = 0;                                           //Limpia la bandera de final de trama
	CLRF        _banTF+0 
;RPi_Simulacion.c,97 :: 		while(1){
L_main7:
;RPi_Simulacion.c,99 :: 		ProbarSPI();
	CALL        _ProbarSPI+0, 0
;RPi_Simulacion.c,100 :: 		Delay_ms(1000);
	MOVLW       26
	MOVWF       R11, 0
	MOVLW       94
	MOVWF       R12, 0
	MOVLW       110
	MOVWF       R13, 0
L_main9:
	DECFSZ      R13, 1, 1
	BRA         L_main9
	DECFSZ      R12, 1, 1
	BRA         L_main9
	DECFSZ      R11, 1, 1
	BRA         L_main9
	NOP
;RPi_Simulacion.c,102 :: 		}
	GOTO        L_main7
;RPi_Simulacion.c,104 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
