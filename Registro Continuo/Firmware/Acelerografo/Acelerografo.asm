
_ADXL355_init:

;adxl355_spi.c,105 :: 		void ADXL355_init(){
;adxl355_spi.c,106 :: 		delay_ms(100);
	PUSH	W10
	PUSH	W11
	MOV	#13, W8
	MOV	#13575, W7
L_ADXL355_init0:
	DEC	W7
	BRA NZ	L_ADXL355_init0
	DEC	W8
	BRA NZ	L_ADXL355_init0
;adxl355_spi.c,107 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|TEMP_OFF|MEASURING);
	MOV.B	#6, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,108 :: 		ADXL355_write_byte(Range, NO_HIGH_PASS_FILTER|_31_25_Hz);
	MOV.B	#5, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,109 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;adxl355_spi.c,112 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;adxl355_spi.c,113 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;adxl355_spi.c,114 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,115 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,116 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;adxl355_spi.c,117 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,118 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;adxl355_spi.c,121 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;adxl355_spi.c,122 :: 		unsigned char value = 0x00;
	PUSH	W10
;adxl355_spi.c,123 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,124 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,125 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,126 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;adxl355_spi.c,127 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,128 :: 		return value;
;adxl355_spi.c,129 :: 		}
;adxl355_spi.c,128 :: 		return value;
;adxl355_spi.c,129 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_word:

;adxl355_spi.c,132 :: 		unsigned int ADXL355_read_word(unsigned char address){
;adxl355_spi.c,133 :: 		unsigned char hb = 0x00;
	PUSH	W10
;adxl355_spi.c,134 :: 		unsigned char lb = 0x00;
;adxl355_spi.c,135 :: 		unsigned int temp = 0x0000;
;adxl355_spi.c,136 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,137 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,138 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,139 :: 		hb = SPI_Read(1);
	MOV	#1, W10
	CALL	_SPI_Read
; hb start address is: 2 (W1)
	MOV.B	W0, W1
;adxl355_spi.c,140 :: 		lb = SPI_Read(0);
	PUSH	W1
	CLR	W10
	CALL	_SPI_Read
	POP	W1
;adxl355_spi.c,141 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,142 :: 		temp = hb;
; temp start address is: 4 (W2)
	ZE	W1, W2
; hb end address is: 2 (W1)
;adxl355_spi.c,143 :: 		temp <<= 0x08;
	SL	W2, #8, W1
; temp end address is: 4 (W2)
;adxl355_spi.c,144 :: 		temp |= lb;
	ZE	W0, W0
	IOR	W1, W0, W0
;adxl355_spi.c,145 :: 		return temp;
;adxl355_spi.c,146 :: 		}
;adxl355_spi.c,145 :: 		return temp;
;adxl355_spi.c,146 :: 		}
L_end_ADXL355_read_word:
	POP	W10
	RETURN
; end of _ADXL355_read_word

_ADXL355_read_data:
	LNK	#4

;adxl355_spi.c,148 :: 		unsigned int ADXL355_read_data(unsigned char address){
;adxl355_spi.c,151 :: 		puntero_8=&dato;
	PUSH	W10
	ADD	W14, #0, W0
; puntero_8 start address is: 4 (W2)
	MOV	W0, W2
;adxl355_spi.c,152 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,153 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,154 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,155 :: 		*(puntero_8+0) = SPI_Read(2);
	MOV	W2, W0
	MOV	W0, [W14+2]
	PUSH	W2
	MOV	#2, W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,156 :: 		*(puntero_8+1) = SPI_Read(1);
	ADD	W2, #1, W0
	MOV	W0, [W14+2]
	PUSH	W2
	MOV	#1, W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,157 :: 		*(puntero_8+2) = SPI_Read(0);
	ADD	W2, #2, W0
	MOV	W0, [W14+2]
	PUSH	W2
	CLR	W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,158 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,159 :: 		bandera=*(puntero_8+0)&0x80;
	ZE	[W2], W1
; puntero_8 end address is: 4 (W2)
	MOV	#128, W0
	AND	W1, W0, W4
;adxl355_spi.c,160 :: 		auxiliar=*dato;
	MOV	[W14+0], W0
;adxl355_spi.c,161 :: 		auxiliar=auxiliar>>12;
	MOV.D	[W0], W2
	LSR	W2, #12, W0
	SL	W3, #4, W1
	IOR	W0, W1, W0
	ASR	W3, #12, W1
; auxiliar start address is: 4 (W2)
	MOV.D	W0, W2
;adxl355_spi.c,162 :: 		if(bandera!=0){
	CP.B	W4, #0
	BRA NZ	L__ADXL355_read_data45
	GOTO	L__ADXL355_read_data33
L__ADXL355_read_data45:
;adxl355_spi.c,163 :: 		auxiliar=auxiliar|0xFFF00000;
	MOV	#0, W0
	MOV	#65520, W1
; auxiliar start address is: 0 (W0)
	IOR	W2, W0, W0
	IOR	W3, W1, W1
; auxiliar end address is: 4 (W2)
	MOV	W1, W2
	MOV	W0, W1
; auxiliar end address is: 0 (W0)
;adxl355_spi.c,164 :: 		}
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data33:
;adxl355_spi.c,162 :: 		if(bandera!=0){
	MOV	W2, W1
	MOV	W3, W2
;adxl355_spi.c,164 :: 		}
L_ADXL355_read_data2:
;adxl355_spi.c,165 :: 		return auxiliar;
; auxiliar start address is: 2 (W1)
	MOV	W1, W0
; auxiliar end address is: 2 (W1)
;adxl355_spi.c,166 :: 		}
;adxl355_spi.c,165 :: 		return auxiliar;
;adxl355_spi.c,166 :: 		}
L_end_ADXL355_read_data:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_read_data

_get_values:

;adxl355_spi.c,169 :: 		void get_values(signed int *x_val, signed int *y_val, signed int *z_val){
;adxl355_spi.c,170 :: 		*x_val = ADXL355_read_data(XDATA3);
	PUSH	W10
	PUSH	W12
	PUSH.D	W10
	MOV.B	#8, W10
	CALL	_ADXL355_read_data
	POP.D	W10
	MOV	W0, [W10]
;adxl355_spi.c,171 :: 		*y_val = ADXL355_read_data(YDATA3);
	PUSH	W11
	MOV.B	#11, W10
	CALL	_ADXL355_read_data
	POP	W11
	MOV	W0, [W11]
;adxl355_spi.c,172 :: 		*z_val = ADXL355_read_data(ZDATA3);
	MOV.B	#14, W10
	CALL	_ADXL355_read_data
	POP	W12
	MOV	W0, [W12]
;adxl355_spi.c,173 :: 		}
L_end_get_values:
	POP	W10
	RETURN
; end of _get_values

_ADXL355_muestra:
	LNK	#2

;adxl355_spi.c,176 :: 		unsigned int ADXL355_muestra( unsigned char *puntero_8){
;adxl355_spi.c,177 :: 		CS_ADXL355=0;
	PUSH	W10
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,178 :: 		SPI2_Write(0x11); //Es la dirección 0x08 de XDATA desplazada y colocada el modo lectura
	PUSH	W10
	MOV	#17, W10
	CALL	_SPI2_Write
	POP	W10
;adxl355_spi.c,179 :: 		*(puntero_8+0) = SPI_Read(8);
	MOV	W10, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#8, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,180 :: 		*(puntero_8+1) = SPI_Read(7);
	ADD	W10, #1, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#7, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,181 :: 		*(puntero_8+2) = SPI_Read(6);
	ADD	W10, #2, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#6, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,182 :: 		*(puntero_8+3) = SPI_Read(5);
	ADD	W10, #3, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#5, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,183 :: 		*(puntero_8+4) = SPI_Read(4);
	ADD	W10, #4, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#4, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,184 :: 		*(puntero_8+5) = SPI_Read(3);
	ADD	W10, #5, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#3, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,185 :: 		*(puntero_8+6) = SPI_Read(2);
	ADD	W10, #6, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,186 :: 		*(puntero_8+7) = SPI_Read(1);
	ADD	W10, #7, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,187 :: 		*(puntero_8+8) = SPI_Read(0);
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	CLR	W10
	CALL	_SPI_Read
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,188 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,190 :: 		}
;adxl355_spi.c,189 :: 		return;
;adxl355_spi.c,190 :: 		}
L_end_ADXL355_muestra:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_muestra

_ConfiguracionPrincipal:

;Acelerografo.c,48 :: 		void ConfiguracionPrincipal(){
;Acelerografo.c,51 :: 		CLKDIVbits.FRCDIV = 0;                             //FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,52 :: 		CLKDIVbits.PLLPOST = 0;                            //N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,53 :: 		CLKDIVbits.PLLPRE = 5;                             //N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,54 :: 		PLLFBDbits.PLLDIV = 150;                           //M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,56 :: 		ANSELA = 0;                                        //Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,57 :: 		ANSELB = 0;                                        //Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,58 :: 		TRISA3_bit = 0;                                    //Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,59 :: 		TRISA4_bit = 0;                                    //Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,60 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,61 :: 		TRISB13_bit = 1;                                   //Configura el pin B1 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,63 :: 		INTCON2.GIE = 1;                                   //Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,70 :: 		SPI1STAT.SPIEN = 1;                                //Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,71 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
	MOV	#3, W13
	MOV	#28, W12
	CLR	W11
	CLR	W10
	CLR	W0
	PUSH	W0
	MOV	#64, W0
	PUSH	W0
	MOV	#512, W0
	PUSH	W0
	MOV	#128, W0
	PUSH	W0
	CALL	_SPI1_Init_Advanced
	SUB	#8, W15
;Acelerografo.c,72 :: 		SPI1IE_bit = 1;                                    //Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,73 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,76 :: 		RPINR22 = 0x0021;                                  //Configura el pin RB1/RPI33 como SDI2 *
	MOV	#33, W0
	MOV	WREG, RPINR22
;Acelerografo.c,77 :: 		RPOR2bits.RP38R = 0x08;                            //Configura el SDO2 en el pin RB6/RP38 *
	MOV.B	#8, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPOR2bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(RPOR2bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPOR2bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,78 :: 		RPOR1bits.RP37R = 0x09;                            //Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,79 :: 		SPI2STAT.SPIEN = 1;                                //Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,80 :: 		SPI2_Init();                                       //Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,83 :: 		RPINR0 = 0x2E00;                                   //Asigna INT1 al RB14/RPI46
	MOV	#11776, W0
	MOV	WREG, RPINR0
;Acelerografo.c,84 :: 		INT1IE_bit = 1;                                    //Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,85 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,86 :: 		IPC0 = 0x0001;                                     //Prioridad en la interrupocion externa 1
	MOV	#1, W0
	MOV	WREG, IPC0
;Acelerografo.c,89 :: 		T1CON = 0x0010;
	MOV	#16, W0
	MOV	WREG, T1CON
;Acelerografo.c,90 :: 		T1CON.TON = 0;                                     //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,91 :: 		T1IE_bit = 1;                                      //Habilita la interrupción de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,92 :: 		T1IF_bit = 0;                                      //Limpia la bandera de interrupcion del TMR2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,93 :: 		IPC0 = 0x1000;                                     //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#4096, W0
	MOV	WREG, IPC0
;Acelerografo.c,94 :: 		PR1 = 25000;
	MOV	#25000, W0
	MOV	WREG, PR1
;Acelerografo.c,96 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOV	#13, W8
	MOV	#13575, W7
L_ConfiguracionPrincipal3:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal3
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal3
;Acelerografo.c,98 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_int_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,106 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT {
;Acelerografo.c,107 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,108 :: 		contMuestras = 0;                                  //Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,109 :: 		datos[0] = contCiclos;                             //Carga el primer valor de la trama de datos con el valor de la muestra actual
	MOV	#lo_addr(_datos), W1
	MOV	#lo_addr(_contCiclos), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,110 :: 		for (x=0;x<10;x++){
	MOV	#lo_addr(_x), W1
	CLR	W0
	MOV.B	W0, [W1]
L_int_15:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__int_150
	GOTO	L_int_16
L__int_150:
;Acelerografo.c,111 :: 		pduSPI[x]=datos[x];                            //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,110 :: 		for (x=0;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,112 :: 		}
	GOTO	L_int_15
L_int_16:
;Acelerografo.c,113 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,114 :: 		RP1 = 1;                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,115 :: 		Delay_us(20);
	MOV	#160, W7
L_int_18:
	DEC	W7
	BRA NZ	L_int_18
	NOP
	NOP
;Acelerografo.c,116 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,117 :: 		T1CON.TON = 1;                                     //Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,118 :: 		contCiclos++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,119 :: 		}
L_end_int_1:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _int_1

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,122 :: 		void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
;Acelerografo.c,123 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,124 :: 		buffer = SPI1BUF;                                  //Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,126 :: 		if ((banTI==1)){                                   //Verifica si la bandera de inicio de trama esta activa
	MOV	#lo_addr(_banTI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_152
	GOTO	L_spi_110
L__spi_152:
;Acelerografo.c,127 :: 		banLec = 1;                                     //Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,128 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,129 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,130 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,131 :: 		}
L_spi_110:
;Acelerografo.c,132 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_153
	GOTO	L__spi_137
L__spi_153:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA NZ	L__spi_154
	GOTO	L__spi_136
L__spi_154:
L__spi_135:
;Acelerografo.c,133 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,134 :: 		i++;
	MOV.B	#1, W1
	MOV	#lo_addr(_i), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,132 :: 		if ((banLec==1)&&(buffer!=0xB1)){
L__spi_137:
L__spi_136:
;Acelerografo.c,136 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_155
	GOTO	L__spi_139
L__spi_155:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA Z	L__spi_156
	GOTO	L__spi_138
L__spi_156:
L__spi_134:
;Acelerografo.c,137 :: 		banLec = 0;                                     //Limpia la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,138 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,139 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,136 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
L__spi_139:
L__spi_138:
;Acelerografo.c,141 :: 		}
L_end_spi_1:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _spi_1

_Timer1Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,143 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT{
;Acelerografo.c,144 :: 		T1IF_bit = 0;
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,145 :: 		contMuestras++;                                    //Incrementa el contador de muestras
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,146 :: 		datos[0] = contMuestras;                           //Carga el primer valor de la trama de datos con el valor del contador de muestras
	MOV	#lo_addr(_datos), W1
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,147 :: 		for (x=0;x<10;x++){
	MOV	#lo_addr(_x), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Timer1Int17:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Timer1Int58
	GOTO	L_Timer1Int18
L__Timer1Int58:
;Acelerografo.c,148 :: 		pduSPI[x]=datos[x];                            //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_datos), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,147 :: 		for (x=0;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,149 :: 		}
	GOTO	L_Timer1Int17
L_Timer1Int18:
;Acelerografo.c,150 :: 		if (contMuestras==NUM_MUESTRAS){
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], W1
	MOV.B	#199, W0
	CP.B	W1, W0
	BRA Z	L__Timer1Int59
	GOTO	L_Timer1Int20
L__Timer1Int59:
;Acelerografo.c,151 :: 		T1CON.TON = 0;                                  //Apaga el Timer2
	BCLR	T1CON, #15
;Acelerografo.c,152 :: 		for (x=1;x<10;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_Timer1Int21:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Timer1Int60
	GOTO	L_Timer1Int22
L__Timer1Int60:
;Acelerografo.c,153 :: 		pduSPI[x]=66;                               //Trama de prueba
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W1
	MOV.B	#66, W0
	MOV.B	W0, [W1]
;Acelerografo.c,152 :: 		for (x=1;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,154 :: 		}
	GOTO	L_Timer1Int21
L_Timer1Int22:
;Acelerografo.c,155 :: 		for (x=10;x<15;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#10, W0
	MOV.B	W0, [W1]
L_Timer1Int24:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #15
	BRA LTU	L__Timer1Int61
	GOTO	L_Timer1Int25
L__Timer1Int61:
;Acelerografo.c,156 :: 		pduSPI[x]=tiempo[x-10];                     //Carga el vector de salida de datos SPI con los datos de la cabecera
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_x), W0
	ZE	[W0], W0
	SUB	W0, #10, W1
	MOV	#lo_addr(_tiempo), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,155 :: 		for (x=10;x<15;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,157 :: 		}
	GOTO	L_Timer1Int24
L_Timer1Int25:
;Acelerografo.c,158 :: 		}
L_Timer1Int20:
;Acelerografo.c,159 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,160 :: 		RP2 = 1;                                           //Genera el pulso P2 para producir la interrupcion en la RPi
	BSET	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,161 :: 		Delay_us(20);
	MOV	#160, W7
L_Timer1Int27:
	DEC	W7
	BRA NZ	L_Timer1Int27
	NOP
	NOP
;Acelerografo.c,162 :: 		RP2 = 0;                                           //Limpia la bandera de interrupcion por desbordamiento del Timer1
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,166 :: 		}
L_end_Timer1Int:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _Timer1Int

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,173 :: 		void main() {
;Acelerografo.c,175 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,177 :: 		tiempo[0] = 19;                                    //Año
	MOV	#lo_addr(_tiempo), W1
	MOV.B	#19, W0
	MOV.B	W0, [W1]
;Acelerografo.c,178 :: 		tiempo[1] = 49;                                    //Dia
	MOV	#lo_addr(_tiempo+1), W1
	MOV.B	#49, W0
	MOV.B	W0, [W1]
;Acelerografo.c,179 :: 		tiempo[2] = 9;                                     //Hora
	MOV	#lo_addr(_tiempo+2), W1
	MOV.B	#9, W0
	MOV.B	W0, [W1]
;Acelerografo.c,180 :: 		tiempo[3] = 30;                                    //Minuto
	MOV	#lo_addr(_tiempo+3), W1
	MOV.B	#30, W0
	MOV.B	W0, [W1]
;Acelerografo.c,181 :: 		tiempo[4] = 0;                                     //Segundo
	MOV	#lo_addr(_tiempo+4), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,183 :: 		datos[1] = 11;
	MOV	#lo_addr(_datos+1), W1
	MOV.B	#11, W0
	MOV.B	W0, [W1]
;Acelerografo.c,184 :: 		datos[2] = 12;
	MOV	#lo_addr(_datos+2), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,185 :: 		datos[3] = 13;
	MOV	#lo_addr(_datos+3), W1
	MOV.B	#13, W0
	MOV.B	W0, [W1]
;Acelerografo.c,186 :: 		datos[4] = 21;
	MOV	#lo_addr(_datos+4), W1
	MOV.B	#21, W0
	MOV.B	W0, [W1]
;Acelerografo.c,187 :: 		datos[5] = 22;
	MOV	#lo_addr(_datos+5), W1
	MOV.B	#22, W0
	MOV.B	W0, [W1]
;Acelerografo.c,188 :: 		datos[6] = 23;
	MOV	#lo_addr(_datos+6), W1
	MOV.B	#23, W0
	MOV.B	W0, [W1]
;Acelerografo.c,189 :: 		datos[7] = 31;
	MOV	#lo_addr(_datos+7), W1
	MOV.B	#31, W0
	MOV.B	W0, [W1]
;Acelerografo.c,190 :: 		datos[8] = 32;
	MOV	#lo_addr(_datos+8), W1
	MOV.B	#32, W0
	MOV.B	W0, [W1]
;Acelerografo.c,191 :: 		datos[9] = 33;
	MOV	#lo_addr(_datos+9), W1
	MOV.B	#33, W0
	MOV.B	W0, [W1]
;Acelerografo.c,193 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,194 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,195 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,196 :: 		x = 0;
	MOV	#lo_addr(_x), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,198 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,199 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,200 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,201 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,203 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,205 :: 		while(1){
L_main29:
;Acelerografo.c,207 :: 		Delay_ms(500);
	MOV	#62, W8
	MOV	#2340, W7
L_main31:
	DEC	W7
	BRA NZ	L_main31
	DEC	W8
	BRA NZ	L_main31
	NOP
	NOP
;Acelerografo.c,209 :: 		}
	GOTO	L_main29
;Acelerografo.c,211 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
