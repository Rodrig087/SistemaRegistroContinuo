
_ConfiguracionPrincipal:

;EsclavoAcelerometro.c,68 :: 		void ConfiguracionPrincipal(){
;EsclavoAcelerometro.c,70 :: 		ANSELA = 0;
	CLRF        ANSELA+0 
;EsclavoAcelerometro.c,71 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;EsclavoAcelerometro.c,72 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;EsclavoAcelerometro.c,74 :: 		TRISB0_bit = 1;                                    //Configura el pin B1 como entrada
	BSF         TRISB0_bit+0, BitPos(TRISB0_bit+0) 
;EsclavoAcelerometro.c,75 :: 		TRISB3_bit = 0;                                    //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;EsclavoAcelerometro.c,76 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;EsclavoAcelerometro.c,77 :: 		TRISB5_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;EsclavoAcelerometro.c,79 :: 		RCON.IPEN = 0;                                     //Importante: Parece ser el origen del problema de que solo funcionaba cuando se reseteaba el PIC
	BCF         RCON+0, 7 
;EsclavoAcelerometro.c,80 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;EsclavoAcelerometro.c,81 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;EsclavoAcelerometro.c,84 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	MOVLW       128
	MOVWF       FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	CLRF        FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;EsclavoAcelerometro.c,85 :: 		PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;EsclavoAcelerometro.c,86 :: 		PIR1.SSP1IF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,89 :: 		INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
	BSF         INTCON+0, 4 
;EsclavoAcelerometro.c,90 :: 		INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
	BCF         INTCON+0, 1 
;EsclavoAcelerometro.c,95 :: 		T2CON = 0x36;                                      //Timer2 Output Postscaler Select bits
	MOVLW       54
	MOVWF       T2CON+0 
;EsclavoAcelerometro.c,96 :: 		PR2 = 222;
	MOVLW       222
	MOVWF       PR2+0 
;EsclavoAcelerometro.c,97 :: 		PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion del TMR2
	BCF         PIR1+0, 1 
;EsclavoAcelerometro.c,98 :: 		PIE1.TMR2IE = 1;                                   //Habilita la interrupción de desbordamiento TMR2
	BSF         PIE1+0, 1 
;EsclavoAcelerometro.c,100 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoAcelerometro.c,102 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_pulsoAux:

;EsclavoAcelerometro.c,105 :: 		void pulsoAux(){
;EsclavoAcelerometro.c,107 :: 		AUX = 1;
	BSF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,108 :: 		Delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;EsclavoAcelerometro.c,109 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,111 :: 		}
L_end_pulsoAux:
	RETURN      0
; end of _pulsoAux

_interrupt:

;EsclavoAcelerometro.c,115 :: 		void interrupt(void){
;EsclavoAcelerometro.c,118 :: 		if (PIR1.SSP1IF==1){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt1
;EsclavoAcelerometro.c,120 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,121 :: 		buffer = SSP1BUF;                               //Guarda el contenido del bufeer (lectura)
	MOVF        SSP1BUF+0, 0 
	MOVWF       _buffer+0 
;EsclavoAcelerometro.c,124 :: 		if ((banTI==1)){                                //Verifica si la bandera de inicio de trama esta activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;EsclavoAcelerometro.c,125 :: 		banLec = 1;                                  //Activa la bandera de lectura
	MOVLW       1
	MOVWF       _banLec+0 
;EsclavoAcelerometro.c,126 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,127 :: 		i = 0;
	CLRF        _i+0 
;EsclavoAcelerometro.c,128 :: 		SSP1BUF = pduSPI[i];
	MOVLW       _pduSPI+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,129 :: 		}
L_interrupt2:
;EsclavoAcelerometro.c,130 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt27:
;EsclavoAcelerometro.c,131 :: 		SSP1BUF = pduSPI[i];
	MOVLW       _pduSPI+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,132 :: 		i++;
	INCF        _i+0, 1 
;EsclavoAcelerometro.c,133 :: 		}
L_interrupt5:
;EsclavoAcelerometro.c,134 :: 		if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt8
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt8
L__interrupt26:
;EsclavoAcelerometro.c,135 :: 		banLec = 0;                                  //Limpia la bandera de lectura
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,136 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,137 :: 		SSP1BUF = 0xFF;
	MOVLW       255
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,138 :: 		}
L_interrupt8:
;EsclavoAcelerometro.c,142 :: 		}
L_interrupt1:
;EsclavoAcelerometro.c,146 :: 		if (INTCON.INT0IF==1){
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt9
;EsclavoAcelerometro.c,147 :: 		INTCON.INT0IF = 0;                              //Limpia la badera de interrupcion externa
	BCF         INTCON+0, 1 
;EsclavoAcelerometro.c,148 :: 		contMuestras = 0;                               //Limpia el contador de muestras
	CLRF        _contMuestras+0 
;EsclavoAcelerometro.c,149 :: 		datos[0] = contMuestras;                        //Carga el primer valor de la trama de datos con el valor de la muestra actual
	CLRF        _datos+0 
;EsclavoAcelerometro.c,150 :: 		for (x=0;x<10;x++){
	CLRF        _x+0 
L_interrupt10:
	MOVLW       10
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt11
;EsclavoAcelerometro.c,151 :: 		pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOVLW       _pduSPI+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR1H 
	MOVF        _x+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVLW       _datos+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_datos+0)
	MOVWF       FSR0H 
	MOVF        _x+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoAcelerometro.c,150 :: 		for (x=0;x<10;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,152 :: 		}
	GOTO        L_interrupt10
L_interrupt11:
;EsclavoAcelerometro.c,153 :: 		banTI = 1;                                      //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;EsclavoAcelerometro.c,154 :: 		P1 = 1;                                         //Genera el pulso P1 para producir la interrupcion en la RPi
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,155 :: 		Delay_us(20);
	MOVLW       33
	MOVWF       R13, 0
L_interrupt13:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt13
;EsclavoAcelerometro.c,156 :: 		P1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,157 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;EsclavoAcelerometro.c,158 :: 		PR2 = 222;                                      //Se carga el valor del preload correspondiente al tiempo de 5ms
	MOVLW       222
	MOVWF       PR2+0 
;EsclavoAcelerometro.c,159 :: 		}
L_interrupt9:
;EsclavoAcelerometro.c,163 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt14
;EsclavoAcelerometro.c,164 :: 		TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;EsclavoAcelerometro.c,165 :: 		contMuestras++;                                 //Incrementa el contador de muestras
	INCF        _contMuestras+0, 1 
;EsclavoAcelerometro.c,166 :: 		datos[0] = contMuestras;                        //Carga el primer valor de la trama de datos con el valor de la muestra actual
	MOVF        _contMuestras+0, 0 
	MOVWF       _datos+0 
;EsclavoAcelerometro.c,167 :: 		for (x=0;x<10;x++){
	CLRF        _x+0 
L_interrupt15:
	MOVLW       10
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt16
;EsclavoAcelerometro.c,168 :: 		pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOVLW       _pduSPI+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR1H 
	MOVF        _x+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVLW       _datos+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_datos+0)
	MOVWF       FSR0H 
	MOVF        _x+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoAcelerometro.c,167 :: 		for (x=0;x<10;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,169 :: 		}
	GOTO        L_interrupt15
L_interrupt16:
;EsclavoAcelerometro.c,170 :: 		if (contMuestras==NUM_MUESTRAS){
	MOVF        _contMuestras+0, 0 
	XORLW       199
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt18
;EsclavoAcelerometro.c,171 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF         T2CON+0, 2 
;EsclavoAcelerometro.c,172 :: 		for (x=10;x<15;x++){
	MOVLW       10
	MOVWF       _x+0 
L_interrupt19:
	MOVLW       15
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt20
;EsclavoAcelerometro.c,173 :: 		pduSPI[x]=cabecera[x-10];                //Carga el vector de salida de datos SPI con los datos de la cabecera
	MOVLW       _pduSPI+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR1H 
	MOVF        _x+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVLW       10
	SUBWF       _x+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _cabecera+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_cabecera+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoAcelerometro.c,172 :: 		for (x=10;x<15;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,174 :: 		}
	GOTO        L_interrupt19
L_interrupt20:
;EsclavoAcelerometro.c,175 :: 		}
L_interrupt18:
;EsclavoAcelerometro.c,176 :: 		banTI = 1;                                      //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;EsclavoAcelerometro.c,177 :: 		P2 = 1;                                         //Genera el pulso P2 para producir la interrupcion en la RPi
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,178 :: 		Delay_us(20);
	MOVLW       33
	MOVWF       R13, 0
L_interrupt22:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt22
;EsclavoAcelerometro.c,179 :: 		P2 = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,180 :: 		}
L_interrupt14:
;EsclavoAcelerometro.c,182 :: 		}
L_end_interrupt:
L__interrupt31:
	RETFIE      1
; end of _interrupt

_main:

;EsclavoAcelerometro.c,185 :: 		void main() {
;EsclavoAcelerometro.c,187 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;EsclavoAcelerometro.c,189 :: 		cabecera[0] = 19;                                  //Año
	MOVLW       19
	MOVWF       _cabecera+0 
;EsclavoAcelerometro.c,190 :: 		cabecera[1] = 49;                                  //Dia
	MOVLW       49
	MOVWF       _cabecera+1 
;EsclavoAcelerometro.c,191 :: 		cabecera[2] = 9;                                   //Hora
	MOVLW       9
	MOVWF       _cabecera+2 
;EsclavoAcelerometro.c,192 :: 		cabecera[3] = 30;                                  //Minuto
	MOVLW       30
	MOVWF       _cabecera+3 
;EsclavoAcelerometro.c,193 :: 		cabecera[4] = 0;                                   //Segundo
	CLRF        _cabecera+4 
;EsclavoAcelerometro.c,195 :: 		datos[1] = 11;
	MOVLW       11
	MOVWF       _datos+1 
;EsclavoAcelerometro.c,196 :: 		datos[2] = 12;
	MOVLW       12
	MOVWF       _datos+2 
;EsclavoAcelerometro.c,197 :: 		datos[3] = 13;
	MOVLW       13
	MOVWF       _datos+3 
;EsclavoAcelerometro.c,198 :: 		datos[4] = 21;
	MOVLW       21
	MOVWF       _datos+4 
;EsclavoAcelerometro.c,199 :: 		datos[5] = 22;
	MOVLW       22
	MOVWF       _datos+5 
;EsclavoAcelerometro.c,200 :: 		datos[6] = 23;
	MOVLW       23
	MOVWF       _datos+6 
;EsclavoAcelerometro.c,201 :: 		datos[7] = 31;
	MOVLW       31
	MOVWF       _datos+7 
;EsclavoAcelerometro.c,202 :: 		datos[8] = 32;
	MOVLW       32
	MOVWF       _datos+8 
;EsclavoAcelerometro.c,203 :: 		datos[9] = 33;
	MOVLW       33
	MOVWF       _datos+9 
;EsclavoAcelerometro.c,208 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,209 :: 		banLec = 0;
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,210 :: 		i = 0;
	CLRF        _i+0 
;EsclavoAcelerometro.c,211 :: 		x = 0;
	CLRF        _x+0 
;EsclavoAcelerometro.c,212 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,214 :: 		contMuestras = 0;
	CLRF        _contMuestras+0 
;EsclavoAcelerometro.c,215 :: 		P1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,216 :: 		P2 = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,218 :: 		SSP1BUF = 0xFF;
	MOVLW       255
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,220 :: 		while(1){
L_main23:
;EsclavoAcelerometro.c,222 :: 		Delay_ms(500);
	MOVLW       13
	MOVWF       R11, 0
	MOVLW       175
	MOVWF       R12, 0
	MOVLW       182
	MOVWF       R13, 0
L_main25:
	DECFSZ      R13, 1, 1
	BRA         L_main25
	DECFSZ      R12, 1, 1
	BRA         L_main25
	DECFSZ      R11, 1, 1
	BRA         L_main25
	NOP
;EsclavoAcelerometro.c,224 :: 		}
	GOTO        L_main23
;EsclavoAcelerometro.c,227 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
