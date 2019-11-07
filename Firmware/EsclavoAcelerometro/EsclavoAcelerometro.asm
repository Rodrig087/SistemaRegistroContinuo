
_ConfiguracionPrincipal:

;EsclavoAcelerometro.c,53 :: 		void ConfiguracionPrincipal(){
;EsclavoAcelerometro.c,55 :: 		ANSELA = 0;
	CLRF        ANSELA+0 
;EsclavoAcelerometro.c,56 :: 		ANSELB = 0;                                        //Configura PORTB como digital
	CLRF        ANSELB+0 
;EsclavoAcelerometro.c,57 :: 		ANSELC = 0;                                        //Configura PORTC como digital
	CLRF        ANSELC+0 
;EsclavoAcelerometro.c,59 :: 		TRISB0_bit = 1;                                    //Configura el pin B1 como entrada
	BSF         TRISB0_bit+0, BitPos(TRISB0_bit+0) 
;EsclavoAcelerometro.c,60 :: 		TRISB3_bit = 0;                                    //Configura el pin B3 como salida
	BCF         TRISB3_bit+0, BitPos(TRISB3_bit+0) 
;EsclavoAcelerometro.c,61 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;EsclavoAcelerometro.c,62 :: 		TRISB5_bit = 0;                                    //Configura el pin B4 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;EsclavoAcelerometro.c,64 :: 		RCON.IPEN = 0;                                     //Importante: Parece ser el origen del problema de que solo funcionaba cuando se reseteaba el PIC
	BCF         RCON+0, 7 
;EsclavoAcelerometro.c,65 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;EsclavoAcelerometro.c,66 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;EsclavoAcelerometro.c,69 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_END,_SPI_CLK_IDLE_HIGH,_SPI_HIGH_2_LOW);
	MOVLW       4
	MOVWF       FARG_SPI1_Init_Advanced_master+0 
	MOVLW       128
	MOVWF       FARG_SPI1_Init_Advanced_data_sample+0 
	MOVLW       16
	MOVWF       FARG_SPI1_Init_Advanced_clock_idle+0 
	CLRF        FARG_SPI1_Init_Advanced_transmit_edge+0 
	CALL        _SPI1_Init_Advanced+0, 0
;EsclavoAcelerometro.c,70 :: 		PIE1.SSP1IE = 1;                                   //Habilita la interrupcion por SPI
	BSF         PIE1+0, 3 
;EsclavoAcelerometro.c,71 :: 		PIR1.SSP1IF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,74 :: 		INTCON.INT0IE = 1;                                 //Habilita la interrupcion externa INT0
	BSF         INTCON+0, 4 
;EsclavoAcelerometro.c,75 :: 		INTCON.INT0IF = 0;                                 //Limpia la bandera de interrupcion externa INT0
	BCF         INTCON+0, 1 
;EsclavoAcelerometro.c,78 :: 		T2CON = 0x36;                                      //Timer2 Output Postscaler Select bits
	MOVLW       54
	MOVWF       T2CON+0 
;EsclavoAcelerometro.c,80 :: 		PR2 = T2;
	MOVLW       222
	MOVWF       PR2+0 
;EsclavoAcelerometro.c,81 :: 		PIR1.TMR2IF = 0;                                   //Limpia la bandera de interrupcion del TMR2
	BCF         PIR1+0, 1 
;EsclavoAcelerometro.c,82 :: 		PIE1.TMR2IE = 1;                                   //Habilita la interrupción de desbordamiento TMR2
	BSF         PIE1+0, 1 
;EsclavoAcelerometro.c,84 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoAcelerometro.c,86 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN      0
; end of _ConfiguracionPrincipal

_pulsoAux:

;EsclavoAcelerometro.c,90 :: 		void pulsoAux(){
;EsclavoAcelerometro.c,92 :: 		AUX = 1;
	BSF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,93 :: 		Delay_us(1);
	NOP
	NOP
	NOP
	NOP
	NOP
;EsclavoAcelerometro.c,94 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,96 :: 		}
L_end_pulsoAux:
	RETURN      0
; end of _pulsoAux

_interrupt:

;EsclavoAcelerometro.c,100 :: 		void interrupt(void){
;EsclavoAcelerometro.c,103 :: 		if (PIR1.SSP1IF==1){
	BTFSS       PIR1+0, 3 
	GOTO        L_interrupt1
;EsclavoAcelerometro.c,105 :: 		PIR1.SSP1IF = 0;                                //Limpia la bandera de interrupcion por SPI
	BCF         PIR1+0, 3 
;EsclavoAcelerometro.c,106 :: 		buffer = SSP1BUF;                               //Guarda el contenido del bufeer (lectura)
	MOVF        SSP1BUF+0, 0 
	MOVWF       _buffer+0 
;EsclavoAcelerometro.c,109 :: 		if ((banTI==1)){                                //Verifica si la bandera de inicio de trama esta activa
	MOVF        _banTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;EsclavoAcelerometro.c,110 :: 		banLec = 1;                                  //Activa la bandera de lectura
	MOVLW       1
	MOVWF       _banLec+0 
;EsclavoAcelerometro.c,111 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,112 :: 		i = 0;
	CLRF        _i+0 
;EsclavoAcelerometro.c,113 :: 		SSP1BUF = pduSPI[i];
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
;EsclavoAcelerometro.c,114 :: 		}
L_interrupt2:
;EsclavoAcelerometro.c,115 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt30:
;EsclavoAcelerometro.c,116 :: 		SSP1BUF = pduSPI[i];
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
;EsclavoAcelerometro.c,117 :: 		i++;
	INCF        _i+0, 1 
;EsclavoAcelerometro.c,118 :: 		}
L_interrupt5:
;EsclavoAcelerometro.c,119 :: 		if ((banLec==1)&&(buffer==0xB1)){               //Si detecta el delimitador de final de trama:
	MOVF        _banLec+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt8
	MOVF        _buffer+0, 0 
	XORLW       177
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt8
L__interrupt29:
;EsclavoAcelerometro.c,120 :: 		banLec = 0;                                  //Limpia la bandera de lectura
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,121 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,122 :: 		SSP1BUF = 0xFF;
	MOVLW       255
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,123 :: 		}
L_interrupt8:
;EsclavoAcelerometro.c,125 :: 		}
L_interrupt1:
;EsclavoAcelerometro.c,129 :: 		if (INTCON.INT0IF==1){
	BTFSS       INTCON+0, 1 
	GOTO        L_interrupt9
;EsclavoAcelerometro.c,130 :: 		INTCON.INT0IF = 0;                              //Limpia la badera de interrupcion externa
	BCF         INTCON+0, 1 
;EsclavoAcelerometro.c,131 :: 		contMuestras = 0;                               //Limpia el contador de muestras
	CLRF        _contMuestras+0 
;EsclavoAcelerometro.c,132 :: 		datos[0] = contCiclos;                          //Carga el primer valor de la trama de datos con el valor de la muestra actual
	MOVF        _contCiclos+0, 0 
	MOVWF       _datos+0 
;EsclavoAcelerometro.c,133 :: 		for (x=0;x<10;x++){
	CLRF        _x+0 
L_interrupt10:
	MOVLW       10
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt11
;EsclavoAcelerometro.c,134 :: 		pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
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
;EsclavoAcelerometro.c,133 :: 		for (x=0;x<10;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,135 :: 		}
	GOTO        L_interrupt10
L_interrupt11:
;EsclavoAcelerometro.c,136 :: 		banTI = 1;                                      //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;EsclavoAcelerometro.c,137 :: 		P1 = 1;                                         //Genera el pulso P1 para producir la interrupcion en la RPi
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,138 :: 		Delay_us(20);
	MOVLW       33
	MOVWF       R13, 0
L_interrupt13:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt13
;EsclavoAcelerometro.c,139 :: 		P1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,140 :: 		T2CON.TMR2ON = 1;                               //Enciende el Timer2
	BSF         T2CON+0, 2 
;EsclavoAcelerometro.c,141 :: 		PR2 = T2;                                      //Se carga el valor del preload correspondiente al tiempo de 5ms
	MOVLW       222
	MOVWF       PR2+0 
;EsclavoAcelerometro.c,142 :: 		contCiclos++;
	INCF        _contCiclos+0, 1 
;EsclavoAcelerometro.c,143 :: 		}
L_interrupt9:
;EsclavoAcelerometro.c,147 :: 		if (TMR2IF_bit==1){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_interrupt14
;EsclavoAcelerometro.c,148 :: 		TMR2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;EsclavoAcelerometro.c,149 :: 		contMuestras++;                                 //Incrementa el contador de muestras
	INCF        _contMuestras+0, 1 
;EsclavoAcelerometro.c,150 :: 		datos[0] = contMuestras;                        //Carga el primer valor de la trama de datos con el valor del contador de muestras
	MOVF        _contMuestras+0, 0 
	MOVWF       _datos+0 
;EsclavoAcelerometro.c,151 :: 		for (x=0;x<10;x++){
	CLRF        _x+0 
L_interrupt15:
	MOVLW       10
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt16
;EsclavoAcelerometro.c,152 :: 		pduSPI[x]=datos[x];                         //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
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
;EsclavoAcelerometro.c,151 :: 		for (x=0;x<10;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,153 :: 		}
	GOTO        L_interrupt15
L_interrupt16:
;EsclavoAcelerometro.c,154 :: 		if (contMuestras==NUM_MUESTRAS){
	MOVF        _contMuestras+0, 0 
	XORLW       199
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt18
;EsclavoAcelerometro.c,155 :: 		T2CON.TMR2ON = 0;                            //Apaga el Timer2
	BCF         T2CON+0, 2 
;EsclavoAcelerometro.c,156 :: 		for (x=1;x<10;x++){
	MOVLW       1
	MOVWF       _x+0 
L_interrupt19:
	MOVLW       10
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt20
;EsclavoAcelerometro.c,157 :: 		pduSPI[x]=66;                            //Trama de prueba
	MOVLW       _pduSPI+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_pduSPI+0)
	MOVWF       FSR1H 
	MOVF        _x+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVLW       66
	MOVWF       POSTINC1+0 
;EsclavoAcelerometro.c,156 :: 		for (x=1;x<10;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,158 :: 		}
	GOTO        L_interrupt19
L_interrupt20:
;EsclavoAcelerometro.c,159 :: 		for (x=10;x<15;x++){
	MOVLW       10
	MOVWF       _x+0 
L_interrupt22:
	MOVLW       15
	SUBWF       _x+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_interrupt23
;EsclavoAcelerometro.c,160 :: 		pduSPI[x]=tiempo[x-10];                //Carga el vector de salida de datos SPI con los datos de la cabecera
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
	MOVLW       _tiempo+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_tiempo+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;EsclavoAcelerometro.c,159 :: 		for (x=10;x<15;x++){
	INCF        _x+0, 1 
;EsclavoAcelerometro.c,161 :: 		}
	GOTO        L_interrupt22
L_interrupt23:
;EsclavoAcelerometro.c,162 :: 		}
L_interrupt18:
;EsclavoAcelerometro.c,163 :: 		banTI = 1;                                      //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _banTI+0 
;EsclavoAcelerometro.c,164 :: 		P2 = 1;                                         //Genera el pulso P2 para producir la interrupcion en la RPi
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,165 :: 		Delay_us(20);
	MOVLW       33
	MOVWF       R13, 0
L_interrupt25:
	DECFSZ      R13, 1, 1
	BRA         L_interrupt25
;EsclavoAcelerometro.c,166 :: 		P2 = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,167 :: 		}
L_interrupt14:
;EsclavoAcelerometro.c,169 :: 		}
L_end_interrupt:
L__interrupt34:
	RETFIE      1
; end of _interrupt

_main:

;EsclavoAcelerometro.c,172 :: 		void main() {
;EsclavoAcelerometro.c,174 :: 		ConfiguracionPrincipal();
	CALL        _ConfiguracionPrincipal+0, 0
;EsclavoAcelerometro.c,176 :: 		tiempo[0] = 19;                                  //Año
	MOVLW       19
	MOVWF       _tiempo+0 
;EsclavoAcelerometro.c,177 :: 		tiempo[1] = 49;                                  //Dia
	MOVLW       49
	MOVWF       _tiempo+1 
;EsclavoAcelerometro.c,178 :: 		tiempo[2] = 9;                                   //Hora
	MOVLW       9
	MOVWF       _tiempo+2 
;EsclavoAcelerometro.c,179 :: 		tiempo[3] = 30;                                  //Minuto
	MOVLW       30
	MOVWF       _tiempo+3 
;EsclavoAcelerometro.c,180 :: 		tiempo[4] = 0;                                   //Segundo
	CLRF        _tiempo+4 
;EsclavoAcelerometro.c,182 :: 		datos[1] = 11;
	MOVLW       11
	MOVWF       _datos+1 
;EsclavoAcelerometro.c,183 :: 		datos[2] = 12;
	MOVLW       12
	MOVWF       _datos+2 
;EsclavoAcelerometro.c,184 :: 		datos[3] = 13;
	MOVLW       13
	MOVWF       _datos+3 
;EsclavoAcelerometro.c,185 :: 		datos[4] = 21;
	MOVLW       21
	MOVWF       _datos+4 
;EsclavoAcelerometro.c,186 :: 		datos[5] = 22;
	MOVLW       22
	MOVWF       _datos+5 
;EsclavoAcelerometro.c,187 :: 		datos[6] = 23;
	MOVLW       23
	MOVWF       _datos+6 
;EsclavoAcelerometro.c,188 :: 		datos[7] = 31;
	MOVLW       31
	MOVWF       _datos+7 
;EsclavoAcelerometro.c,189 :: 		datos[8] = 32;
	MOVLW       32
	MOVWF       _datos+8 
;EsclavoAcelerometro.c,190 :: 		datos[9] = 33;
	MOVLW       33
	MOVWF       _datos+9 
;EsclavoAcelerometro.c,192 :: 		banTI = 0;
	CLRF        _banTI+0 
;EsclavoAcelerometro.c,193 :: 		banLec = 0;
	CLRF        _banLec+0 
;EsclavoAcelerometro.c,194 :: 		i = 0;
	CLRF        _i+0 
;EsclavoAcelerometro.c,195 :: 		x = 0;
	CLRF        _x+0 
;EsclavoAcelerometro.c,196 :: 		AUX = 0;
	BCF         RB3_bit+0, BitPos(RB3_bit+0) 
;EsclavoAcelerometro.c,198 :: 		contMuestras = 0;
	CLRF        _contMuestras+0 
;EsclavoAcelerometro.c,199 :: 		contCiclos = 0;
	CLRF        _contCiclos+0 
;EsclavoAcelerometro.c,200 :: 		P1 = 0;
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;EsclavoAcelerometro.c,201 :: 		P2 = 0;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;EsclavoAcelerometro.c,203 :: 		SSP1BUF = 0xFF;
	MOVLW       255
	MOVWF       SSP1BUF+0 
;EsclavoAcelerometro.c,205 :: 		while(1){
L_main26:
;EsclavoAcelerometro.c,207 :: 		Delay_ms(500);
	MOVLW       13
	MOVWF       R11, 0
	MOVLW       175
	MOVWF       R12, 0
	MOVLW       182
	MOVWF       R13, 0
L_main28:
	DECFSZ      R13, 1, 1
	BRA         L_main28
	DECFSZ      R12, 1, 1
	BRA         L_main28
	DECFSZ      R11, 1, 1
	BRA         L_main28
	NOP
;EsclavoAcelerometro.c,209 :: 		}
	GOTO        L_main26
;EsclavoAcelerometro.c,212 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
