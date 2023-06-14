
_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,73 :: 		void main()
;Acelerografo.c,76 :: 		tasaMuestreo = 1; // 1=250Hz, 2=125Hz, 4=62.5Hz, 8=31.25Hz
	MOV	#lo_addr(_tasaMuestreo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,77 :: 		numTMR1 = (tasaMuestreo * 10) - 1; // Calcula el numero de veces que tienen que desbordarse el TMR1 para cada tasa de muestreo
	MOV	#lo_addr(_numTMR1), W1
	MOV.B	#9, W0
	MOV.B	W0, [W1]
;Acelerografo.c,79 :: 		banOperacion = 0;
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,80 :: 		tipoOperacion = 0;
	MOV	#lo_addr(_tipoOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,82 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,83 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,84 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,85 :: 		banCiclo = 0;
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,86 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,88 :: 		banSetGPS = 0;
	MOV	#lo_addr(_banSetGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,89 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,90 :: 		banTFGPS = 0;
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,91 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,92 :: 		stsGPS = 0;
	MOV	#lo_addr(_stsGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,93 :: 		fuenteReloj = 0;
	MOV	#lo_addr(_fuenteReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,94 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,96 :: 		banMuestrear = 0; // Inicia el programa con esta bandera en bajo para permitir que la RPi envie la peticion de inicio de muestreo
	MOV	#lo_addr(_banMuestrear), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,97 :: 		banInicio = 0;    // Bandera de inicio de muestreo
	MOV	#lo_addr(_banInicio), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,98 :: 		banLeer = 0;
	MOV	#lo_addr(_banLeer), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,99 :: 		banConf = 0;
	MOV	#lo_addr(_banConf), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,101 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,102 :: 		x = 0;
	CLR	W0
	MOV	W0, _x
;Acelerografo.c,103 :: 		y = 0;
	CLR	W0
	MOV	W0, _y
;Acelerografo.c,104 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,105 :: 		horaSistema = 0;
	CLR	W0
	CLR	W1
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,106 :: 		referenciaTiempo = 0;
	MOV	#lo_addr(_referenciaTiempo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,107 :: 		contTimeout1 = 0;
	MOV	#lo_addr(_contTimeout1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,109 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,110 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,111 :: 		contFIFO = 0;
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,112 :: 		numFIFO = 0;
	MOV	#lo_addr(_numFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,113 :: 		numSetsFIFO = 0;
	MOV	#lo_addr(_numSetsFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,114 :: 		contTimer1 = 0;
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,115 :: 		contTimer3 = 0;
	MOV	#lo_addr(_contTimer3), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,117 :: 		byteGPS = 0;
	MOV	#lo_addr(_byteGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,118 :: 		banInitGPS = 0;
	MOV	#lo_addr(_banInitGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,121 :: 		banInicializar = 0;
	MOV	#lo_addr(_banInicializar), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,123 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,124 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,125 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,127 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,129 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,131 :: 		while (1)
L_main0:
;Acelerografo.c,163 :: 		Delay_ms(1);
	MOV	#8000, W7
L_main2:
	DEC	W7
	BRA NZ	L_main2
	NOP
	NOP
;Acelerografo.c,164 :: 		}
	GOTO	L_main0
;Acelerografo.c,166 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main

_ConfiguracionPrincipal:

;Acelerografo.c,173 :: 		void ConfiguracionPrincipal()
;Acelerografo.c,177 :: 		CLKDIVbits.FRCDIV = 0;   // FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,178 :: 		CLKDIVbits.PLLPOST = 0;  // N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,179 :: 		CLKDIVbits.PLLPRE = 5;   // N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,180 :: 		PLLFBDbits.PLLDIV = 150; // M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,183 :: 		ANSELA = 0;      // Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,184 :: 		ANSELB = 0;      // Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,185 :: 		TRISA2_bit = 0;  // Configura el pin A2 como salida  *
	BCLR	TRISA2_bit, BitPos(TRISA2_bit+0)
;Acelerografo.c,186 :: 		TRISA3_bit = 0;  // Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,187 :: 		TRISA4_bit = 0;  // Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,188 :: 		TRISB4_bit = 0;  // Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,189 :: 		TRISB12_bit = 0; // Configura el pin B12 como salida *
	BCLR	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,191 :: 		TRISB10_bit = 1; // Configura el pin B10 como entrada *
	BSET	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,192 :: 		TRISB11_bit = 1; // Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,193 :: 		TRISB13_bit = 1; // Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,194 :: 		TRISB14_bit = 1;
	BSET	TRISB14_bit, BitPos(TRISB14_bit+0)
;Acelerografo.c,195 :: 		TRISB15_bit = 1; // Configura el pin B15 como entrada *
	BSET	TRISB15_bit, BitPos(TRISB15_bit+0)
;Acelerografo.c,197 :: 		INTCON2.GIE = 1; // Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,200 :: 		SPI1STAT.SPIEN = 1;                                                                                                                                                 // Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,201 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE); //*
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
;Acelerografo.c,202 :: 		SPI1IE_bit = 1;                                                                                                                                                     // Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,203 :: 		SPI1IF_bit = 0;                                                                                                                                                     // Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,204 :: 		IPC2bits.SPI1IP = 0x03;                                                                                                                                             // Prioridad de la interrupcion SPI1
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,207 :: 		RPINR22bits.SDI2R = 0x21; // Configura el pin RB1/RPI33 como SDI2 *
	MOV.B	#33, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR22bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#127, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(RPINR22bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR22bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,208 :: 		RPOR2bits.RP38R = 0x08;   // Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,209 :: 		RPOR1bits.RP37R = 0x09;   // Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,210 :: 		SPI2STATbits.SPIROV = 0;  // No Receive Overflow has occurred
	BCLR	SPI2STATbits, #6
;Acelerografo.c,211 :: 		SPI2STAT.SPIEN = 1;       // Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,212 :: 		SPI2_Init();              // Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,213 :: 		CS_DS3234 = 1;            // Pone en alto el CS del RTC
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;Acelerografo.c,214 :: 		CS_ADXL355 = 1;           // Pone en alto el CS del acelerometro
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;Acelerografo.c,217 :: 		RPINR18bits.U1RXR = 0x22; // Configura el pin RB2/RPI34 como Rx1 *
	MOV.B	#34, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#127, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,218 :: 		RPOR0bits.RP35R = 0x01;   // Configura el Tx1 en el pin RB3/RP35 *
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR0bits
;Acelerografo.c,219 :: 		U1RXIE_bit = 1;           // Habilita la interrupcion por UART1 RX *
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,220 :: 		U1RXIF_bit = 0;           // Limpia la bandera de interrupcion por UART1 RX *
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,221 :: 		IPC2bits.U1RXIP = 0x04;   // Prioridad de la interrupcion UART1 RX
	MOV	#16384, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,222 :: 		U1STAbits.URXISEL = 0x00;
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,223 :: 		UART1_Init(9600); // Inicializa el UART1 con una velocidad de 9600 baudios
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;Acelerografo.c,226 :: 		RPINR0 = 0x2F00;        // Asigna INT1 al RB15/RPI47 (SQW)
	MOV	#12032, W0
	MOV	WREG, RPINR0
;Acelerografo.c,227 :: 		INT1IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,228 :: 		INT1IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,229 :: 		IPC5bits.INT1IP = 0x02; // Prioridad en la interrupocion externa INT1
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,232 :: 		RPINR1 = 0x002E;        // Asigna INT2 al RB14/RPI46 (PPS)
	MOV	#46, W0
	MOV	WREG, RPINR1
;Acelerografo.c,233 :: 		INT2IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT2IE_bit, BitPos(INT2IE_bit+0)
;Acelerografo.c,234 :: 		INT2IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,235 :: 		IPC7bits.INT2IP = 0x01; // Prioridad en la interrupocion externa INT2
	MOV.B	#16, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC7bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#112, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(IPC7bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC7bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,238 :: 		T1CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T1CON
;Acelerografo.c,239 :: 		T1CON.TON = 0;        // Apaga el TMR1
	BCLR	T1CON, #15
;Acelerografo.c,240 :: 		T1IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,241 :: 		T1IF_bit = 0;         // Limpia la bandera de interrupcion del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,242 :: 		PR1 = 62500;          // Car ga el preload para un tiempo de 100ms
	MOV	#62500, W0
	MOV	WREG, PR1
;Acelerografo.c,243 :: 		IPC0bits.T1IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,246 :: 		T2CON = 0x30;         // Prescalador
	MOV	#48, W0
	MOV	WREG, T2CON
;Acelerografo.c,247 :: 		T2CON.TON = 0;        // Apaga el TMR2
	BCLR	T2CON, #15
;Acelerografo.c,248 :: 		T2IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR2
	BSET	T2IE_bit, BitPos(T2IE_bit+0)
;Acelerografo.c,249 :: 		T2IF_bit = 0;         // Limpia la bandera de interrupcion del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,250 :: 		PR2 = 46875;          // Carga el preload para un tiempo de 300ms
	MOV	#46875, W0
	MOV	WREG, PR2
;Acelerografo.c,251 :: 		IPC1bits.T2IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;Acelerografo.c,254 :: 		T3CON = 0x20;         // Prescalador
	MOV	#32, W0
	MOV	WREG, T3CON
;Acelerografo.c,255 :: 		T3CON.TON = 0;        // Apaga el TMR3
	BCLR	T3CON, #15
;Acelerografo.c,256 :: 		T3IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR3
	BSET	T3IE_bit, BitPos(T3IE_bit+0)
;Acelerografo.c,257 :: 		T3IF_bit = 0;         // Limpia la bandera de interrupcion del TMR3
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,258 :: 		PR3 = 62500;          // Carga el preload para un tiempo de 500ms
	MOV	#62500, W0
	MOV	WREG, PR3
;Acelerografo.c,259 :: 		IPC2bits.T3IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR3
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC2bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,261 :: 		Delay_ms(200); // Espera hasta que se estabilicen los cambios
	MOV	#25, W8
	MOV	#27150, W7
L_ConfiguracionPrincipal4:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal4
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal4
	NOP
;Acelerografo.c,264 :: 		DS3234_init();              // inicializa el RTC
	CALL	_DS3234_init
;Acelerografo.c,266 :: 		Delay_ms(500);              // Espera hasta que se estabilicen los cambios del RTC
	MOV	#62, W8
	MOV	#2340, W7
L_ConfiguracionPrincipal6:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal6
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal6
	NOP
	NOP
;Acelerografo.c,269 :: 		ADXL355_init(tasaMuestreo); // Inicializa el modulo ADXL con la tasa de muestreo requerida
	MOV	#lo_addr(_tasaMuestreo), W0
	MOV.B	[W0], W10
	CALL	_ADXL355_init
;Acelerografo.c,272 :: 		GPS_init();
	CALL	_GPS_init
;Acelerografo.c,273 :: 		U1MODE.UARTEN = 0;
	BCLR	U1MODE, #15
;Acelerografo.c,276 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,277 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal8:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal8
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal8
	NOP
	NOP
;Acelerografo.c,278 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,279 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal10:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal10
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal10
	NOP
	NOP
;Acelerografo.c,280 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,282 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_InterrupcionP1:

;Acelerografo.c,287 :: 		void InterrupcionP1(unsigned char operacion)
;Acelerografo.c,289 :: 		banOperacion = 0;          // Encera la bandera para permitir una nueva peticion de operacion
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,290 :: 		tipoOperacion = operacion; // Carga en la variable el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	MOV.B	W10, [W0]
;Acelerografo.c,292 :: 		RP1 = 1;
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,293 :: 		Delay_us(20);
	MOV	#160, W7
L_InterrupcionP112:
	DEC	W7
	BRA NZ	L_InterrupcionP112
	NOP
	NOP
;Acelerografo.c,294 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,295 :: 		}
L_end_InterrupcionP1:
	RETURN
; end of _InterrupcionP1

_Muestrear:

;Acelerografo.c,300 :: 		void Muestrear()
;Acelerografo.c,303 :: 		if (banCiclo == 1)
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Muestrear234
	GOTO	L_Muestrear14
L__Muestrear234:
;Acelerografo.c,305 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF | MEASURING); // Coloca el ADXL en modo medicion
	MOV.B	#4, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,306 :: 		T1CON.TON = 1;                                       // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,307 :: 		}
	GOTO	L_Muestrear15
L_Muestrear14:
;Acelerografo.c,308 :: 		else if (banCiclo == 2)
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Muestrear235
	GOTO	L_Muestrear16
L__Muestrear235:
;Acelerografo.c,311 :: 		banCiclo = 3; // Limpia la bandera de ciclo completo
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,313 :: 		tramaCompleta[0] = fuenteReloj; // LLena el primer elemento de la tramaCompleta con el identificador de fuente de reloj
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_fuenteReloj), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,314 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,315 :: 		numSetsFIFO = (numFIFO) / 3; // Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,318 :: 		for (x = 0; x < numSetsFIFO; x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear17:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Muestrear236
	GOTO	L_Muestrear18
L__Muestrear236:
;Acelerografo.c,320 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,321 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Muestrear20:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Muestrear237
	GOTO	L_Muestrear21
L__Muestrear237:
;Acelerografo.c,323 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
	MOV	_x, W1
	MOV	#9, W0
	MUL.UU	W1, W0, W2
	MOV	#lo_addr(_y), W0
	ADD	W2, [W0], W1
	MOV	#lo_addr(_datosFIFO), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosLeidos), W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,321 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,325 :: 		}
	GOTO	L_Muestrear20
L_Muestrear21:
;Acelerografo.c,318 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,326 :: 		}
	GOTO	L_Muestrear17
L_Muestrear18:
;Acelerografo.c,329 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear23:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Muestrear238
	GOTO	L_Muestrear24
L__Muestrear238:
;Acelerografo.c,331 :: 		if ((x == 0) || (x % 9 == 0))
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Muestrear239
	GOTO	L__Muestrear152
L__Muestrear239:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Muestrear240
	GOTO	L__Muestrear151
L__Muestrear240:
	GOTO	L_Muestrear28
L__Muestrear152:
L__Muestrear151:
;Acelerografo.c,333 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras; // Funciona bien
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,334 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosFIFO), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,335 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,336 :: 		}
	GOTO	L_Muestrear29
L_Muestrear28:
;Acelerografo.c,339 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosFIFO), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,340 :: 		}
L_Muestrear29:
;Acelerografo.c,329 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,341 :: 		}
	GOTO	L_Muestrear23
L_Muestrear24:
;Acelerografo.c,344 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,345 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear30:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__Muestrear241
	GOTO	L_Muestrear31
L__Muestrear241:
;Acelerografo.c,347 :: 		tramaCompleta[2500 + x] = tiempo[x];
	MOV	#2500, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,345 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,348 :: 		}
	GOTO	L_Muestrear30
L_Muestrear31:
;Acelerografo.c,350 :: 		contMuestras = 0; // Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,351 :: 		contFIFO = 0;     // Limpia el contador de FIFOs
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,352 :: 		T1CON.TON = 1;    // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,354 :: 		banLec = 1; // Activa la bandera de lectura para enviar la trama
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,355 :: 		InterrupcionP1(0XB1);
	MOV.B	#177, W10
	CALL	_InterrupcionP1
;Acelerografo.c,357 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,358 :: 		}
L_Muestrear16:
L_Muestrear15:
;Acelerografo.c,360 :: 		}
L_end_Muestrear:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Muestrear

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,368 :: 		void spi_1() org IVT_ADDR_SPI1INTERRUPT
;Acelerografo.c,371 :: 		SPI1IF_bit = 0;   // Limpia la bandera de interrupcion por SPI
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,372 :: 		buffer = SPI1BUF; // Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,376 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
	MOV	#lo_addr(_banOperacion), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1243
	GOTO	L__spi_1173
L__spi_1243:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#160, W0
	CP.B	W1, W0
	BRA Z	L__spi_1244
	GOTO	L__spi_1172
L__spi_1244:
L__spi_1171:
;Acelerografo.c,378 :: 		banOperacion = 1;        // Activa la bandera para enviar el tipo de operacion requerido a la RPi
	MOV	#lo_addr(_banOperacion), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,379 :: 		SPI1BUF = tipoOperacion; // Carga en el buffer el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,376 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
L__spi_1173:
L__spi_1172:
;Acelerografo.c,381 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
	MOV	#lo_addr(_banOperacion), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1245
	GOTO	L__spi_1175
L__spi_1245:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#240, W0
	CP.B	W1, W0
	BRA Z	L__spi_1246
	GOTO	L__spi_1174
L__spi_1246:
L__spi_1170:
;Acelerografo.c,383 :: 		banOperacion = 0;  // Limpia la bandera
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,384 :: 		tipoOperacion = 0; // Limpia la variable de tipo de operacion
	MOV	#lo_addr(_tipoOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,381 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
L__spi_1175:
L__spi_1174:
;Acelerografo.c,390 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
	MOV	#lo_addr(_banMuestrear), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1247
	GOTO	L__spi_1177
L__spi_1247:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#161, W0
	CP.B	W1, W0
	BRA Z	L__spi_1248
	GOTO	L__spi_1176
L__spi_1248:
L__spi_1169:
;Acelerografo.c,392 :: 		banMuestrear = 1;
	MOV	#lo_addr(_banMuestrear), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,393 :: 		banCiclo = 1;
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,390 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
L__spi_1177:
L__spi_1176:
;Acelerografo.c,395 :: 		if ((banMuestrear == 1) && (buffer != 0xA1) && (buffer != 0xF1))
	MOV	#lo_addr(_banMuestrear), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1249
	GOTO	L__spi_1180
L__spi_1249:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#161, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1250
	GOTO	L__spi_1179
L__spi_1250:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#241, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1251
	GOTO	L__spi_1178
L__spi_1251:
L__spi_1168:
;Acelerografo.c,397 :: 		banInicio = 1;  // Bandera que permite el inicio del muestreo dentro de la interrupcion INT1
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,395 :: 		if ((banMuestrear == 1) && (buffer != 0xA1) && (buffer != 0xF1))
L__spi_1180:
L__spi_1179:
L__spi_1178:
;Acelerografo.c,408 :: 		if ((banMuestrear == 1) && (buffer == 0xF1))
	MOV	#lo_addr(_banMuestrear), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1252
	GOTO	L__spi_1182
L__spi_1252:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#241, W0
	CP.B	W1, W0
	BRA Z	L__spi_1253
	GOTO	L__spi_1181
L__spi_1253:
L__spi_1167:
;Acelerografo.c,410 :: 		banMuestrear = 0;
	MOV	#lo_addr(_banMuestrear), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,408 :: 		if ((banMuestrear == 1) && (buffer == 0xF1))
L__spi_1182:
L__spi_1181:
;Acelerografo.c,414 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
	MOV	#lo_addr(_banInitGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1254
	GOTO	L__spi_1184
L__spi_1254:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#162, W0
	CP.B	W1, W0
	BRA Z	L__spi_1255
	GOTO	L__spi_1183
L__spi_1255:
L__spi_1166:
;Acelerografo.c,417 :: 		banInitGPS = 1;
	MOV	#lo_addr(_banInitGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,418 :: 		SPI1BUF = 0x47; // Ascii: G
	MOV	#71, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,414 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
L__spi_1184:
L__spi_1183:
;Acelerografo.c,420 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
	MOV	#lo_addr(_banInitGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1256
	GOTO	L__spi_1186
L__spi_1256:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#242, W0
	CP.B	W1, W0
	BRA Z	L__spi_1257
	GOTO	L__spi_1185
L__spi_1257:
L__spi_1165:
;Acelerografo.c,424 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,425 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_154:
	DEC	W7
	BRA NZ	L_spi_154
	DEC	W8
	BRA NZ	L_spi_154
	NOP
	NOP
	NOP
;Acelerografo.c,426 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,427 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_156:
	DEC	W7
	BRA NZ	L_spi_156
	DEC	W8
	BRA NZ	L_spi_156
	NOP
	NOP
	NOP
;Acelerografo.c,428 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,429 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_158:
	DEC	W7
	BRA NZ	L_spi_158
	DEC	W8
	BRA NZ	L_spi_158
	NOP
	NOP
	NOP
;Acelerografo.c,430 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,431 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_160:
	DEC	W7
	BRA NZ	L_spi_160
	DEC	W8
	BRA NZ	L_spi_160
	NOP
	NOP
	NOP
;Acelerografo.c,432 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,433 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_162:
	DEC	W7
	BRA NZ	L_spi_162
	DEC	W8
	BRA NZ	L_spi_162
	NOP
	NOP
	NOP
;Acelerografo.c,434 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,420 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
L__spi_1186:
L__spi_1185:
;Acelerografo.c,438 :: 		if ((banLec == 1) && (buffer == 0xA3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1258
	GOTO	L__spi_1188
L__spi_1258:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#163, W0
	CP.B	W1, W0
	BRA Z	L__spi_1259
	GOTO	L__spi_1187
L__spi_1259:
L__spi_1164:
;Acelerografo.c,440 :: 		banLec = 2; // Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,441 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,442 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,438 :: 		if ((banLec == 1) && (buffer == 0xA3))
L__spi_1188:
L__spi_1187:
;Acelerografo.c,444 :: 		if ((banLec == 2) && (buffer != 0xF3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1260
	GOTO	L__spi_1190
L__spi_1260:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#243, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1261
	GOTO	L__spi_1189
L__spi_1261:
L__spi_1163:
;Acelerografo.c,446 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,447 :: 		i++;
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,444 :: 		if ((banLec == 2) && (buffer != 0xF3))
L__spi_1190:
L__spi_1189:
;Acelerografo.c,449 :: 		if ((banLec == 2) && (buffer == 0xF3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1262
	GOTO	L__spi_1192
L__spi_1262:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#243, W0
	CP.B	W1, W0
	BRA Z	L__spi_1263
	GOTO	L__spi_1191
L__spi_1263:
L__spi_1162:
;Acelerografo.c,451 :: 		banLec = 0; // Limpia la bandera de lectura                        ****AQUI Me QUEDE
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,452 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,449 :: 		if ((banLec == 2) && (buffer == 0xF3))
L__spi_1192:
L__spi_1191:
;Acelerografo.c,458 :: 		if ((banEsc == 0) && (buffer == 0xA4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1264
	GOTO	L__spi_1194
L__spi_1264:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#164, W0
	CP.B	W1, W0
	BRA Z	L__spi_1265
	GOTO	L__spi_1193
L__spi_1265:
L__spi_1161:
;Acelerografo.c,460 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,461 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,458 :: 		if ((banEsc == 0) && (buffer == 0xA4))
L__spi_1194:
L__spi_1193:
;Acelerografo.c,463 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1266
	GOTO	L__spi_1197
L__spi_1266:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#164, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1267
	GOTO	L__spi_1196
L__spi_1267:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#244, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1268
	GOTO	L__spi_1195
L__spi_1268:
L__spi_1160:
;Acelerografo.c,465 :: 		tiempoRPI[j] = buffer;
	MOV	#lo_addr(_tiempoRPI), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,466 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,463 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
L__spi_1197:
L__spi_1196:
L__spi_1195:
;Acelerografo.c,468 :: 		if ((banEsc == 1) && (buffer == 0xF4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1269
	GOTO	L__spi_1199
L__spi_1269:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#244, W0
	CP.B	W1, W0
	BRA Z	L__spi_1270
	GOTO	L__spi_1198
L__spi_1270:
L__spi_1159:
;Acelerografo.c,470 :: 		horaSistema = RecuperarHoraRPI(tiempoRPI);               // Recupera la hora de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarHoraRPI
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,471 :: 		fechaSistema = RecuperarFechaRPI(tiempoRPI);             // Recupera la fecha de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarFechaRPI
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,472 :: 		DS3234_setDate(horaSistema, fechaSistema);               // Configura la hora en el RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	CALL	_DS3234_setDate
;Acelerografo.c,473 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,474 :: 		fuenteReloj = 0;                                         // Fuente de reloj = RPi
	MOV	#lo_addr(_fuenteReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,475 :: 		InterrupcionP1(0XB2);
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,476 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,477 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,468 :: 		if ((banEsc == 1) && (buffer == 0xF4))
L__spi_1199:
L__spi_1198:
;Acelerografo.c,481 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1271
	GOTO	L__spi_1201
L__spi_1271:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#165, W0
	CP.B	W1, W0
	BRA Z	L__spi_1272
	GOTO	L__spi_1200
L__spi_1272:
L__spi_1158:
;Acelerografo.c,483 :: 		banSetReloj = 2;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,484 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,485 :: 		SPI1BUF = fuenteReloj; // Envia el indicador de fuente de reloj (0:RTC, 1:GPS)
	MOV	#lo_addr(_fuenteReloj), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,481 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
L__spi_1201:
L__spi_1200:
;Acelerografo.c,487 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1273
	GOTO	L__spi_1204
L__spi_1273:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#165, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1274
	GOTO	L__spi_1203
L__spi_1274:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#245, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1275
	GOTO	L__spi_1202
L__spi_1275:
L__spi_1157:
;Acelerografo.c,489 :: 		SPI1BUF = tiempo[j];
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,490 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,487 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
L__spi_1204:
L__spi_1203:
L__spi_1202:
;Acelerografo.c,492 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1276
	GOTO	L__spi_1206
L__spi_1276:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#245, W0
	CP.B	W1, W0
	BRA Z	L__spi_1277
	GOTO	L__spi_1205
L__spi_1277:
L__spi_1156:
;Acelerografo.c,494 :: 		banSetReloj = 1; // Reactiva la bandera de lectura
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,495 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,492 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
L__spi_1206:
L__spi_1205:
;Acelerografo.c,499 :: 		if ((banEsc == 0) && (buffer == 0xA6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1278
	GOTO	L__spi_1208
L__spi_1278:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#166, W0
	CP.B	W1, W0
	BRA Z	L__spi_1279
	GOTO	L__spi_1207
L__spi_1279:
L__spi_1155:
;Acelerografo.c,501 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,499 :: 		if ((banEsc == 0) && (buffer == 0xA6))
L__spi_1208:
L__spi_1207:
;Acelerografo.c,503 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1280
	GOTO	L__spi_1211
L__spi_1280:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#166, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1281
	GOTO	L__spi_1210
L__spi_1281:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#246, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1282
	GOTO	L__spi_1209
L__spi_1282:
L__spi_1154:
;Acelerografo.c,505 :: 		referenciaTiempo = buffer; // Recupera la opcion de referencia de tiempo solicitada
	MOV	#lo_addr(_referenciaTiempo), W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,503 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
L__spi_1211:
L__spi_1210:
L__spi_1209:
;Acelerografo.c,507 :: 		if ((banEsc == 1) && (buffer == 0xF6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1283
	GOTO	L__spi_1213
L__spi_1283:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#246, W0
	CP.B	W1, W0
	BRA Z	L__spi_1284
	GOTO	L__spi_1212
L__spi_1284:
L__spi_1153:
;Acelerografo.c,509 :: 		if (referenciaTiempo == 1)
	MOV	#lo_addr(_referenciaTiempo), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1285
	GOTO	L_spi_1100
L__spi_1285:
;Acelerografo.c,512 :: 		banGPSI = 1;       // Activa la bandera de inicio de trama  del GPS
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,513 :: 		banGPSC = 0;       // Limpia la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,514 :: 		U1MODE.UARTEN = 1; // Inicializa el UART1
	BSET	U1MODE, #15
;Acelerografo.c,516 :: 		T2CON.TON = 1;
	BSET	T2CON, #15
;Acelerografo.c,517 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,518 :: 		}
	GOTO	L_spi_1101
L_spi_1100:
;Acelerografo.c,522 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,523 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,524 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,525 :: 		fuenteReloj = 2;                                         // Fuente de reloj = RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,526 :: 		InterrupcionP1(0xB2);                                    // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,527 :: 		}
L_spi_1101:
;Acelerografo.c,528 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,529 :: 		banSetReloj = 1; // Activa esta bandera para usar la hora/fecha recuperada
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,507 :: 		if ((banEsc == 1) && (buffer == 0xF6))
L__spi_1213:
L__spi_1212:
;Acelerografo.c,532 :: 		}
L_end_spi_1:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _spi_1

_int_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,537 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT
;Acelerografo.c,540 :: 		INT1IF_bit = 0; // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,542 :: 		if (banSetReloj == 1)
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1287
	GOTO	L_int_1102
L__int_1287:
;Acelerografo.c,544 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,545 :: 		horaSistema++; // Incrementa el reloj del sistema
	MOV	#1, W1
	MOV	#0, W2
	MOV	#lo_addr(_horaSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,548 :: 		if (horaSistema == 86400)
	MOV	_horaSistema, W2
	MOV	_horaSistema+2, W3
	MOV	#20864, W0
	MOV	#1, W1
	CP	W2, W0
	CPB	W3, W1
	BRA Z	L__int_1288
	GOTO	L_int_1103
L__int_1288:
;Acelerografo.c,550 :: 		horaSistema = 0; //(24*3600)+(0*60)+(0) = 86400
	CLR	W0
	CLR	W1
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,551 :: 		}
L_int_1103:
;Acelerografo.c,553 :: 		if (banInicio == 1)
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1289
	GOTO	L_int_1104
L__int_1289:
;Acelerografo.c,556 :: 		Muestrear();
	CALL	_Muestrear
;Acelerografo.c,557 :: 		}
L_int_1104:
;Acelerografo.c,558 :: 		}
L_int_1102:
;Acelerografo.c,559 :: 		}
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

_int_2:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,563 :: 		void int_2() org IVT_ADDR_INT2INTERRUPT
;Acelerografo.c,566 :: 		INT2IF_bit = 0; // Limpia la bandera de interrupcion externa INT2
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,568 :: 		if (banSyncReloj == 1)
	MOV	#lo_addr(_banSyncReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_2291
	GOTO	L_int_2105
L__int_2291:
;Acelerografo.c,572 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,573 :: 		horaSistema = horaSistema + 2; // Incrementa el reloj del sistema en 2 segundos
	MOV	#2, W1
	MOV	#0, W2
	MOV	#lo_addr(_horaSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,577 :: 		T3CON.TON = 1;
	BSET	T3CON, #15
;Acelerografo.c,578 :: 		TMR3 = 0;
	CLR	TMR3
;Acelerografo.c,591 :: 		}
L_int_2105:
;Acelerografo.c,592 :: 		}
L_end_int_2:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _int_2

_Timer1Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,596 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT
;Acelerografo.c,599 :: 		T1IF_bit = 0; // Limpia la bandera de interrupcion por desbordamiento del Timer1
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,601 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES); // 75                            //Lee el numero de muestras disponibles en el FIFO
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,602 :: 		numSetsFIFO = (numFIFO) / 3;               // 25                            //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,605 :: 		for (x = 0; x < numSetsFIFO; x++)
	CLR	W0
	MOV	W0, _x
L_Timer1Int106:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Timer1Int293
	GOTO	L_Timer1Int107
L__Timer1Int293:
;Acelerografo.c,607 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,608 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Timer1Int109:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Timer1Int294
	GOTO	L_Timer1Int110
L__Timer1Int294:
;Acelerografo.c,610 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
	MOV	_x, W1
	MOV	#9, W0
	MUL.UU	W1, W0, W2
	MOV	#lo_addr(_y), W0
	ADD	W2, [W0], W1
	MOV	#lo_addr(_datosFIFO), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosLeidos), W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,608 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,611 :: 		}
	GOTO	L_Timer1Int109
L_Timer1Int110:
;Acelerografo.c,605 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,612 :: 		}
	GOTO	L_Timer1Int106
L_Timer1Int107:
;Acelerografo.c,615 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	CLR	W0
	MOV	W0, _x
L_Timer1Int112:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Timer1Int295
	GOTO	L_Timer1Int113
L__Timer1Int295:
;Acelerografo.c,617 :: 		if ((x == 0) || (x % 9 == 0))
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int296
	GOTO	L__Timer1Int216
L__Timer1Int296:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int297
	GOTO	L__Timer1Int215
L__Timer1Int297:
	GOTO	L_Timer1Int117
L__Timer1Int216:
L__Timer1Int215:
;Acelerografo.c,619 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras;
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,620 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosFIFO), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,621 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,622 :: 		}
	GOTO	L_Timer1Int118
L_Timer1Int117:
;Acelerografo.c,625 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#lo_addr(_contFIFO), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_datosFIFO), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,626 :: 		}
L_Timer1Int118:
;Acelerografo.c,615 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,627 :: 		}
	GOTO	L_Timer1Int112
L_Timer1Int113:
;Acelerografo.c,629 :: 		contFIFO = (contMuestras * 9); // Incrementa el contador de FIFOs
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	MOV	W0, _contFIFO
;Acelerografo.c,631 :: 		contTimer1++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer1
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,633 :: 		if (contTimer1 == numTMR1)
	MOV	#lo_addr(_contTimer1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_numTMR1), W0
	CP.B	W1, [W0]
	BRA Z	L__Timer1Int298
	GOTO	L_Timer1Int119
L__Timer1Int298:
;Acelerografo.c,635 :: 		T1CON.TON = 0;  // Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,636 :: 		banCiclo = 2;   // Activa la bandera que indica que se completo un ciclo de medicion
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,637 :: 		contTimer1 = 0; // Limpia el contador de interrupciones por Timer1
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,638 :: 		}
L_Timer1Int119:
;Acelerografo.c,639 :: 		}
L_end_Timer1Int:
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _Timer1Int

_Timer2Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,643 :: 		void Timer2Int() org IVT_ADDR_T2INTERRUPT
;Acelerografo.c,646 :: 		T2IF_bit = 0;   // Limpia la bandera de interrupcion por desbordamiento del Timer2
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,647 :: 		contTimeout1++; // Incrementa el contador de Timeout
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimeout1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,650 :: 		if (contTimeout1 == 4)
	MOV	#lo_addr(_contTimeout1), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA Z	L__Timer2Int300
	GOTO	L_Timer2Int120
L__Timer2Int300:
;Acelerografo.c,652 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,653 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,654 :: 		contTimeout1 = 0;
	MOV	#lo_addr(_contTimeout1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,656 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,657 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,658 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,659 :: 		fuenteReloj = 5;                                         //**Indica que se obtuvo la hora del RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#5, W0
	MOV.B	W0, [W1]
;Acelerografo.c,660 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,661 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,662 :: 		}
L_Timer2Int120:
;Acelerografo.c,663 :: 		}
L_end_Timer2Int:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _Timer2Int

_Timer3Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,667 :: 		void Timer3Int() org IVT_ADDR_T3INTERRUPT
;Acelerografo.c,669 :: 		T3IF_bit = 0;
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,671 :: 		contTimer3++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer3
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer3), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,674 :: 		if (contTimer3 == 5)
	MOV	#lo_addr(_contTimer3), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA Z	L__Timer3Int302
	GOTO	L_Timer3Int121
L__Timer3Int302:
;Acelerografo.c,676 :: 		DS3234_setDate(horaSistema, fechaSistema); // Configura la hora en el RTC con la hora recuperada de la RPi
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	CALL	_DS3234_setDate
;Acelerografo.c,678 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,679 :: 		banSetReloj = 1; // Activa esta bandera para continuar trabajando con el pulso SQW
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,682 :: 		InterrupcionP1(0xB2);
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,683 :: 		contTimer3 = 0; // Encera el contador
	MOV	#lo_addr(_contTimer3), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,684 :: 		T3CON.TON = 0;  // Apaga el Timer3
	BCLR	T3CON, #15
;Acelerografo.c,685 :: 		}
L_Timer3Int121:
;Acelerografo.c,686 :: 		}
L_end_Timer3Int:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _Timer3Int

_urx_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,690 :: 		void urx_1() org IVT_ADDR_U1RXINTERRUPT
;Acelerografo.c,693 :: 		byteGPS = U1RXREG; // Lee el byte de la trama enviada por el GPS
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_byteGPS), W1
	MOV.B	U1RXREG, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,694 :: 		U1STA.OERR = 0;    // Limpia este bit para limpiar el FIFO UART1
	BCLR	U1STA, #1
;Acelerografo.c,697 :: 		if (banGPSI == 3)
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__urx_1304
	GOTO	L_urx_1122
L__urx_1304:
;Acelerografo.c,699 :: 		if (byteGPS != 0x2A)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#42, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1305
	GOTO	L_urx_1123
L__urx_1305:
;Acelerografo.c,701 :: 		tramaGPS[i_gps] = byteGPS; // LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,702 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,703 :: 		}
	GOTO	L_urx_1124
L_urx_1123:
;Acelerografo.c,706 :: 		banGPSI = 0; // Limpia la bandera de inicio de trama
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,707 :: 		banGPSC = 1; // Activa la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,708 :: 		}
L_urx_1124:
;Acelerografo.c,709 :: 		}
L_urx_1122:
;Acelerografo.c,712 :: 		if ((banGPSI == 1))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1306
	GOTO	L_urx_1125
L__urx_1306:
;Acelerografo.c,714 :: 		if (byteGPS == 0x24)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#36, W0
	CP.B	W1, W0
	BRA Z	L__urx_1307
	GOTO	L_urx_1126
L__urx_1307:
;Acelerografo.c,716 :: 		banGPSI = 2;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,717 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,718 :: 		}
L_urx_1126:
;Acelerografo.c,719 :: 		}
L_urx_1125:
;Acelerografo.c,720 :: 		if ((banGPSI == 2) && (i_gps < 6))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__urx_1308
	GOTO	L__urx_1221
L__urx_1308:
	MOV	_i_gps, W0
	CP	W0, #6
	BRA LTU	L__urx_1309
	GOTO	L__urx_1220
L__urx_1309:
L__urx_1219:
;Acelerografo.c,722 :: 		tramaGPS[i_gps] = byteGPS; // Recupera los datos de cabecera de la trama GPS: ["$", "G", "P", "R", "M", "C"]
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,723 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,720 :: 		if ((banGPSI == 2) && (i_gps < 6))
L__urx_1221:
L__urx_1220:
;Acelerografo.c,725 :: 		if ((banGPSI == 2) && (i_gps == 6))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__urx_1310
	GOTO	L__urx_1228
L__urx_1310:
	MOV	_i_gps, W0
	CP	W0, #6
	BRA Z	L__urx_1311
	GOTO	L__urx_1227
L__urx_1311:
L__urx_1218:
;Acelerografo.c,728 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,729 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,731 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA Z	L__urx_1312
	GOTO	L__urx_1226
L__urx_1312:
	MOV	#lo_addr(_tramaGPS+2), W0
	MOV.B	[W0], W1
	MOV.B	#80, W0
	CP.B	W1, W0
	BRA Z	L__urx_1313
	GOTO	L__urx_1225
L__urx_1313:
	MOV	#lo_addr(_tramaGPS+3), W0
	MOV.B	[W0], W1
	MOV.B	#82, W0
	CP.B	W1, W0
	BRA Z	L__urx_1314
	GOTO	L__urx_1224
L__urx_1314:
	MOV	#lo_addr(_tramaGPS+4), W0
	MOV.B	[W0], W1
	MOV.B	#77, W0
	CP.B	W1, W0
	BRA Z	L__urx_1315
	GOTO	L__urx_1223
L__urx_1315:
	MOV	#lo_addr(_tramaGPS+5), W0
	MOV.B	[W0], W1
	MOV.B	#67, W0
	CP.B	W1, W0
	BRA Z	L__urx_1316
	GOTO	L__urx_1222
L__urx_1316:
L__urx_1217:
;Acelerografo.c,733 :: 		banGPSI = 3;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,734 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,735 :: 		}
	GOTO	L_urx_1136
;Acelerografo.c,731 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
L__urx_1226:
L__urx_1225:
L__urx_1224:
L__urx_1223:
L__urx_1222:
;Acelerografo.c,738 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,739 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,740 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,742 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,743 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,744 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,745 :: 		fuenteReloj = 4;                                         // Fuente reloj: RTC/E4
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
;Acelerografo.c,746 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,747 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi y a los nodos                                                   //Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,748 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,749 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,750 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,751 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,752 :: 		}
L_urx_1136:
;Acelerografo.c,725 :: 		if ((banGPSI == 2) && (i_gps == 6))
L__urx_1228:
L__urx_1227:
;Acelerografo.c,756 :: 		if (banGPSC == 1)
	MOV	#lo_addr(_banGPSC), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1317
	GOTO	L_urx_1137
L__urx_1317:
;Acelerografo.c,759 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_urx_1138:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__urx_1318
	GOTO	L_urx_1139
L__urx_1318:
;Acelerografo.c,761 :: 		datosGPS[x] = tramaGPS[x + 1]; // Guarda los datos de hhmmss
	MOV	#lo_addr(_datosGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W2
	MOV	_x, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,759 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,762 :: 		}
	GOTO	L_urx_1138
L_urx_1139:
;Acelerografo.c,764 :: 		for (x = 44; x < 54; x++)
	MOV	#44, W0
	MOV	W0, _x
L_urx_1141:
	MOV	#54, W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1319
	GOTO	L_urx_1142
L__urx_1319:
;Acelerografo.c,766 :: 		if (tramaGPS[x] == 0x2C)
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W1
	MOV.B	#44, W0
	CP.B	W1, W0
	BRA Z	L__urx_1320
	GOTO	L_urx_1144
L__urx_1320:
;Acelerografo.c,768 :: 		for (y = 0; y < 6; y++)
	CLR	W0
	MOV	W0, _y
L_urx_1145:
	MOV	_y, W0
	CP	W0, #6
	BRA LTU	L__urx_1321
	GOTO	L_urx_1146
L__urx_1321:
;Acelerografo.c,770 :: 		datosGPS[6 + y] = tramaGPS[x + y + 1]; // Guarda los datos de DDMMAA en la trama datosGPS
	MOV	_y, W0
	ADD	W0, #6, W1
	MOV	#lo_addr(_datosGPS), W0
	ADD	W0, W1, W2
	MOV	_x, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,768 :: 		for (y = 0; y < 6; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,771 :: 		}
	GOTO	L_urx_1145
L_urx_1146:
;Acelerografo.c,772 :: 		}
L_urx_1144:
;Acelerografo.c,764 :: 		for (x = 44; x < 54; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,773 :: 		}
	GOTO	L_urx_1141
L_urx_1142:
;Acelerografo.c,774 :: 		horaSistema = RecuperarHoraGPS(datosGPS);                // Recupera la hora del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarHoraGPS
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,775 :: 		fechaSistema = RecuperarFechaGPS(datosGPS);              // Recupera la fecha del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarFechaGPS
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,776 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del gps
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,779 :: 		if (tramaGPS[12] == 0x41)
	MOV	#lo_addr(_tramaGPS+12), W0
	MOV.B	[W0], W1
	MOV.B	#65, W0
	CP.B	W1, W0
	BRA Z	L__urx_1322
	GOTO	L_urx_1148
L__urx_1322:
;Acelerografo.c,781 :: 		fuenteReloj = 1; // Fuente reloj: GPS
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,782 :: 		banSyncReloj = 1;
	MOV	#lo_addr(_banSyncReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,783 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,784 :: 		}
	GOTO	L_urx_1149
L_urx_1148:
;Acelerografo.c,787 :: 		fuenteReloj = 3; // Fuente reloj: GPS/E3
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,788 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,789 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,790 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,791 :: 		}
L_urx_1149:
;Acelerografo.c,792 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,793 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,794 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,795 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,796 :: 		}
L_urx_1137:
;Acelerografo.c,799 :: 		U1RXIF_bit = 0;
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,800 :: 		}
L_end_urx_1:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _urx_1
