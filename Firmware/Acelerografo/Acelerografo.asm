
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
;Acelerografo.c,133 :: 		Delay_ms(1);
	MOV	#8000, W7
L_main2:
	DEC	W7
	BRA NZ	L_main2
	NOP
	NOP
;Acelerografo.c,134 :: 		}
	GOTO	L_main0
;Acelerografo.c,136 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main

_ConfiguracionPrincipal:

;Acelerografo.c,143 :: 		void ConfiguracionPrincipal()
;Acelerografo.c,147 :: 		CLKDIVbits.FRCDIV = 0;   // FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,148 :: 		CLKDIVbits.PLLPOST = 0;  // N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,149 :: 		CLKDIVbits.PLLPRE = 5;   // N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,150 :: 		PLLFBDbits.PLLDIV = 150; // M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,153 :: 		ANSELA = 0;      // Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,154 :: 		ANSELB = 0;      // Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,155 :: 		TRISA2_bit = 0;  // Configura el pin A2 como salida  *
	BCLR	TRISA2_bit, BitPos(TRISA2_bit+0)
;Acelerografo.c,156 :: 		TRISA3_bit = 0;  // Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,157 :: 		TRISA4_bit = 0;  // Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,158 :: 		TRISB4_bit = 0;  // Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,159 :: 		TRISB12_bit = 0; // Configura el pin B12 como salida *
	BCLR	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,161 :: 		TRISB10_bit = 1; // Configura el pin B10 como entrada *
	BSET	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,162 :: 		TRISB11_bit = 1; // Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,163 :: 		TRISB13_bit = 1; // Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,164 :: 		TRISB14_bit = 1;
	BSET	TRISB14_bit, BitPos(TRISB14_bit+0)
;Acelerografo.c,165 :: 		TRISB15_bit = 1; // Configura el pin B15 como entrada *
	BSET	TRISB15_bit, BitPos(TRISB15_bit+0)
;Acelerografo.c,167 :: 		INTCON2.GIE = 1; // Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,170 :: 		SPI1STAT.SPIEN = 1;                                                                                                                                                 // Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,171 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE); //*
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
;Acelerografo.c,172 :: 		SPI1IE_bit = 1;                                                                                                                                                     // Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,173 :: 		SPI1IF_bit = 0;                                                                                                                                                     // Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,174 :: 		IPC2bits.SPI1IP = 0x03;                                                                                                                                             // Prioridad de la interrupcion SPI1
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,177 :: 		RPINR22bits.SDI2R = 0x21; // Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,178 :: 		RPOR2bits.RP38R = 0x08;   // Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,179 :: 		RPOR1bits.RP37R = 0x09;   // Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,180 :: 		SPI2STATbits.SPIROV = 0;  // No Receive Overflow has occurred
	BCLR	SPI2STATbits, #6
;Acelerografo.c,181 :: 		SPI2STAT.SPIEN = 1;       // Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,182 :: 		SPI2_Init();              // Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,183 :: 		CS_DS3234 = 1;            // Pone en alto el CS del RTC
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;Acelerografo.c,184 :: 		CS_ADXL355 = 1;           // Pone en alto el CS del acelerometro
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;Acelerografo.c,187 :: 		RPINR18bits.U1RXR = 0x22; // Configura el pin RB2/RPI34 como Rx1 *
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
;Acelerografo.c,188 :: 		RPOR0bits.RP35R = 0x01;   // Configura el Tx1 en el pin RB3/RP35 *
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR0bits
;Acelerografo.c,189 :: 		U1RXIE_bit = 1;           // Habilita la interrupcion por UART1 RX *
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,190 :: 		U1RXIF_bit = 0;           // Limpia la bandera de interrupcion por UART1 RX *
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,191 :: 		IPC2bits.U1RXIP = 0x04;   // Prioridad de la interrupcion UART1 RX
	MOV	#16384, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,192 :: 		U1STAbits.URXISEL = 0x00;
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,193 :: 		UART1_Init(9600); // Inicializa el UART1 con una velocidad de 9600 baudios
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;Acelerografo.c,196 :: 		RPINR0 = 0x2F00;        // Asigna INT1 al RB15/RPI47 (SQW)
	MOV	#12032, W0
	MOV	WREG, RPINR0
;Acelerografo.c,197 :: 		INT1IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,198 :: 		INT1IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,199 :: 		IPC5bits.INT1IP = 0x02; // Prioridad en la interrupocion externa INT1
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,202 :: 		RPINR1 = 0x002E;        // Asigna INT2 al RB14/RPI46 (PPS)
	MOV	#46, W0
	MOV	WREG, RPINR1
;Acelerografo.c,203 :: 		INT2IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT2IE_bit, BitPos(INT2IE_bit+0)
;Acelerografo.c,204 :: 		INT2IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,205 :: 		IPC7bits.INT2IP = 0x01; // Prioridad en la interrupocion externa INT2
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
;Acelerografo.c,208 :: 		T1CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T1CON
;Acelerografo.c,209 :: 		T1CON.TON = 0;        // Apaga el TMR1
	BCLR	T1CON, #15
;Acelerografo.c,210 :: 		T1IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,211 :: 		T1IF_bit = 0;         // Limpia la bandera de interrupcion del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,212 :: 		PR1 = 62500;          // Car ga el preload para un tiempo de 100ms
	MOV	#62500, W0
	MOV	WREG, PR1
;Acelerografo.c,213 :: 		IPC0bits.T1IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,216 :: 		T2CON = 0x30;         // Prescalador
	MOV	#48, W0
	MOV	WREG, T2CON
;Acelerografo.c,217 :: 		T2CON.TON = 0;        // Apaga el TMR2
	BCLR	T2CON, #15
;Acelerografo.c,218 :: 		T2IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR2
	BSET	T2IE_bit, BitPos(T2IE_bit+0)
;Acelerografo.c,219 :: 		T2IF_bit = 0;         // Limpia la bandera de interrupcion del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,220 :: 		PR2 = 46875;          // Carga el preload para un tiempo de 300ms
	MOV	#46875, W0
	MOV	WREG, PR2
;Acelerografo.c,221 :: 		IPC1bits.T2IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;Acelerografo.c,224 :: 		T3CON = 0x20;         // Prescalador
	MOV	#32, W0
	MOV	WREG, T3CON
;Acelerografo.c,225 :: 		T3CON.TON = 0;        // Apaga el TMR3
	BCLR	T3CON, #15
;Acelerografo.c,226 :: 		T3IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR3
	BSET	T3IE_bit, BitPos(T3IE_bit+0)
;Acelerografo.c,227 :: 		T3IF_bit = 0;         // Limpia la bandera de interrupcion del TMR3
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,228 :: 		PR3 = 62500;          // Carga el preload para un tiempo de 500ms
	MOV	#62500, W0
	MOV	WREG, PR3
;Acelerografo.c,229 :: 		IPC2bits.T3IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR3
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC2bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,231 :: 		Delay_ms(200); // Espera hasta que se estabilicen los cambios
	MOV	#25, W8
	MOV	#27150, W7
L_ConfiguracionPrincipal4:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal4
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal4
	NOP
;Acelerografo.c,234 :: 		DS3234_init();              // inicializa el RTC
	CALL	_DS3234_init
;Acelerografo.c,236 :: 		Delay_ms(500);              // Espera hasta que se estabilicen los cambios del RTC
	MOV	#62, W8
	MOV	#2340, W7
L_ConfiguracionPrincipal6:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal6
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal6
	NOP
	NOP
;Acelerografo.c,239 :: 		ADXL355_init(tasaMuestreo); // Inicializa el modulo ADXL con la tasa de muestreo requerida
	MOV	#lo_addr(_tasaMuestreo), W0
	MOV.B	[W0], W10
	CALL	_ADXL355_init
;Acelerografo.c,242 :: 		GPS_init();
	CALL	_GPS_init
;Acelerografo.c,243 :: 		U1MODE.UARTEN = 0;
	BCLR	U1MODE, #15
;Acelerografo.c,246 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,247 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal8:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal8
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal8
	NOP
	NOP
;Acelerografo.c,248 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,249 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal10:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal10
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal10
	NOP
	NOP
;Acelerografo.c,250 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,252 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_InterrupcionP1:

;Acelerografo.c,257 :: 		void InterrupcionP1(unsigned char operacion)
;Acelerografo.c,259 :: 		banOperacion = 0;          // Encera la bandera para permitir una nueva peticion de operacion
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,260 :: 		tipoOperacion = operacion; // Carga en la variable el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	MOV.B	W10, [W0]
;Acelerografo.c,262 :: 		RP1 = 1;
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,263 :: 		Delay_us(20);
	MOV	#160, W7
L_InterrupcionP112:
	DEC	W7
	BRA NZ	L_InterrupcionP112
	NOP
	NOP
;Acelerografo.c,264 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,265 :: 		}
L_end_InterrupcionP1:
	RETURN
; end of _InterrupcionP1

_Muestrear:

;Acelerografo.c,270 :: 		void Muestrear()
;Acelerografo.c,273 :: 		if (banCiclo == 1)
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
;Acelerografo.c,275 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF | MEASURING); // Coloca el ADXL en modo medicion
	MOV.B	#4, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,276 :: 		T1CON.TON = 1;                                       // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,277 :: 		}
	GOTO	L_Muestrear15
L_Muestrear14:
;Acelerografo.c,278 :: 		else if (banCiclo == 2)
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Muestrear235
	GOTO	L_Muestrear16
L__Muestrear235:
;Acelerografo.c,281 :: 		banCiclo = 3; // Limpia la bandera de ciclo completo
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,283 :: 		tramaCompleta[0] = fuenteReloj; // LLena el primer elemento de la tramaCompleta con el identificador de fuente de reloj
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_fuenteReloj), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,284 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,285 :: 		numSetsFIFO = (numFIFO) / 3; // Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,288 :: 		for (x = 0; x < numSetsFIFO; x++)
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
;Acelerografo.c,290 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,291 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Muestrear20:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Muestrear237
	GOTO	L_Muestrear21
L__Muestrear237:
;Acelerografo.c,293 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
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
;Acelerografo.c,291 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,295 :: 		}
	GOTO	L_Muestrear20
L_Muestrear21:
;Acelerografo.c,288 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,296 :: 		}
	GOTO	L_Muestrear17
L_Muestrear18:
;Acelerografo.c,299 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
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
;Acelerografo.c,301 :: 		if ((x == 0) || (x % 9 == 0))
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
;Acelerografo.c,303 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras; // Funciona bien
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
;Acelerografo.c,304 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
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
;Acelerografo.c,305 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,306 :: 		}
	GOTO	L_Muestrear29
L_Muestrear28:
;Acelerografo.c,309 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
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
;Acelerografo.c,310 :: 		}
L_Muestrear29:
;Acelerografo.c,299 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,311 :: 		}
	GOTO	L_Muestrear23
L_Muestrear24:
;Acelerografo.c,314 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,315 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear30:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__Muestrear241
	GOTO	L_Muestrear31
L__Muestrear241:
;Acelerografo.c,317 :: 		tramaCompleta[2500 + x] = tiempo[x];
	MOV	#2500, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,315 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,318 :: 		}
	GOTO	L_Muestrear30
L_Muestrear31:
;Acelerografo.c,320 :: 		contMuestras = 0; // Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,321 :: 		contFIFO = 0;     // Limpia el contador de FIFOs
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,322 :: 		T1CON.TON = 1;    // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,324 :: 		banLec = 1; // Activa la bandera de lectura para enviar la trama
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,325 :: 		InterrupcionP1(0XB1);
	MOV.B	#177, W10
	CALL	_InterrupcionP1
;Acelerografo.c,327 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,328 :: 		}
L_Muestrear16:
L_Muestrear15:
;Acelerografo.c,330 :: 		}
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

;Acelerografo.c,338 :: 		void spi_1() org IVT_ADDR_SPI1INTERRUPT
;Acelerografo.c,341 :: 		SPI1IF_bit = 0;   // Limpia la bandera de interrupcion por SPI
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,342 :: 		buffer = SPI1BUF; // Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,346 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
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
;Acelerografo.c,348 :: 		banOperacion = 1;        // Activa la bandera para enviar el tipo de operacion requerido a la RPi
	MOV	#lo_addr(_banOperacion), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,349 :: 		SPI1BUF = tipoOperacion; // Carga en el buffer el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,346 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
L__spi_1173:
L__spi_1172:
;Acelerografo.c,351 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
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
;Acelerografo.c,353 :: 		banOperacion = 0;  // Limpia la bandera
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,354 :: 		tipoOperacion = 0; // Limpia la variable de tipo de operacion
	MOV	#lo_addr(_tipoOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,351 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
L__spi_1175:
L__spi_1174:
;Acelerografo.c,360 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
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
;Acelerografo.c,362 :: 		banMuestrear = 1;
	MOV	#lo_addr(_banMuestrear), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,363 :: 		banCiclo = 1;
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,360 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
L__spi_1177:
L__spi_1176:
;Acelerografo.c,365 :: 		if ((banMuestrear == 1) && (buffer != 0xA1) && (buffer != 0xF1))
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
;Acelerografo.c,367 :: 		banInicio = 1;  // Bandera que permite el inicio del muestreo dentro de la interrupcion INT1
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,365 :: 		if ((banMuestrear == 1) && (buffer != 0xA1) && (buffer != 0xF1))
L__spi_1180:
L__spi_1179:
L__spi_1178:
;Acelerografo.c,378 :: 		if ((banMuestrear == 1) && (buffer == 0xF1))
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
;Acelerografo.c,380 :: 		banMuestrear = 0;
	MOV	#lo_addr(_banMuestrear), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,378 :: 		if ((banMuestrear == 1) && (buffer == 0xF1))
L__spi_1182:
L__spi_1181:
;Acelerografo.c,384 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
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
;Acelerografo.c,387 :: 		banInitGPS = 1;
	MOV	#lo_addr(_banInitGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,388 :: 		SPI1BUF = 0x47; // Ascii: G
	MOV	#71, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,384 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
L__spi_1184:
L__spi_1183:
;Acelerografo.c,390 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
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
;Acelerografo.c,394 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,395 :: 		Delay_ms(150);
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
;Acelerografo.c,396 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,397 :: 		Delay_ms(150);
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
;Acelerografo.c,398 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,399 :: 		Delay_ms(150);
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
;Acelerografo.c,400 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,401 :: 		Delay_ms(150);
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
;Acelerografo.c,402 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,403 :: 		Delay_ms(150);
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
;Acelerografo.c,404 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,390 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
L__spi_1186:
L__spi_1185:
;Acelerografo.c,408 :: 		if ((banLec == 1) && (buffer == 0xA3))
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
;Acelerografo.c,410 :: 		banLec = 2; // Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,411 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,412 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,408 :: 		if ((banLec == 1) && (buffer == 0xA3))
L__spi_1188:
L__spi_1187:
;Acelerografo.c,414 :: 		if ((banLec == 2) && (buffer != 0xF3))
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
;Acelerografo.c,416 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,417 :: 		i++;
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,414 :: 		if ((banLec == 2) && (buffer != 0xF3))
L__spi_1190:
L__spi_1189:
;Acelerografo.c,419 :: 		if ((banLec == 2) && (buffer == 0xF3))
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
;Acelerografo.c,421 :: 		banLec = 0; // Limpia la bandera de lectura                        ****AQUI Me QUEDE
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,422 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,419 :: 		if ((banLec == 2) && (buffer == 0xF3))
L__spi_1192:
L__spi_1191:
;Acelerografo.c,428 :: 		if ((banEsc == 0) && (buffer == 0xA4))
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
;Acelerografo.c,430 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,431 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,428 :: 		if ((banEsc == 0) && (buffer == 0xA4))
L__spi_1194:
L__spi_1193:
;Acelerografo.c,433 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
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
;Acelerografo.c,435 :: 		tiempoRPI[j] = buffer;
	MOV	#lo_addr(_tiempoRPI), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,436 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,433 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
L__spi_1197:
L__spi_1196:
L__spi_1195:
;Acelerografo.c,438 :: 		if ((banEsc == 1) && (buffer == 0xF4))
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
;Acelerografo.c,440 :: 		horaSistema = RecuperarHoraRPI(tiempoRPI);               // Recupera la hora de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarHoraRPI
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,441 :: 		fechaSistema = RecuperarFechaRPI(tiempoRPI);             // Recupera la fecha de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarFechaRPI
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,442 :: 		fuenteReloj = 0;                                         // Fuente de reloj = RPi
	MOV	#lo_addr(_fuenteReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,445 :: 		T3CON.TON = 1;
	BSET	T3CON, #15
;Acelerografo.c,446 :: 		TMR3 = 0;
	CLR	TMR3
;Acelerografo.c,448 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,438 :: 		if ((banEsc == 1) && (buffer == 0xF4))
L__spi_1199:
L__spi_1198:
;Acelerografo.c,453 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
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
;Acelerografo.c,455 :: 		banSetReloj = 2;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,456 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,457 :: 		SPI1BUF = fuenteReloj; // Envia el indicador de fuente de reloj (0:RTC, 1:GPS)
	MOV	#lo_addr(_fuenteReloj), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,453 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
L__spi_1201:
L__spi_1200:
;Acelerografo.c,459 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
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
;Acelerografo.c,461 :: 		SPI1BUF = tiempo[j];
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,462 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,459 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
L__spi_1204:
L__spi_1203:
L__spi_1202:
;Acelerografo.c,464 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
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
;Acelerografo.c,466 :: 		banSetReloj = 1; // Reactiva la bandera de lectura
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,467 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,464 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
L__spi_1206:
L__spi_1205:
;Acelerografo.c,471 :: 		if ((banEsc == 0) && (buffer == 0xA6))
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
;Acelerografo.c,473 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,471 :: 		if ((banEsc == 0) && (buffer == 0xA6))
L__spi_1208:
L__spi_1207:
;Acelerografo.c,475 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
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
;Acelerografo.c,477 :: 		referenciaTiempo = buffer; // Recupera la opcion de referencia de tiempo solicitada
	MOV	#lo_addr(_referenciaTiempo), W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,475 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
L__spi_1211:
L__spi_1210:
L__spi_1209:
;Acelerografo.c,479 :: 		if ((banEsc == 1) && (buffer == 0xF6))
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
;Acelerografo.c,481 :: 		if (referenciaTiempo == 1)
	MOV	#lo_addr(_referenciaTiempo), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1285
	GOTO	L_spi_1100
L__spi_1285:
;Acelerografo.c,484 :: 		banGPSI = 1;       // Activa la bandera de inicio de trama  del GPS
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,485 :: 		banGPSC = 0;       // Limpia la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,486 :: 		U1MODE.UARTEN = 1; // Inicializa el UART1
	BSET	U1MODE, #15
;Acelerografo.c,488 :: 		T2CON.TON = 1;
	BSET	T2CON, #15
;Acelerografo.c,489 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,490 :: 		}
	GOTO	L_spi_1101
L_spi_1100:
;Acelerografo.c,494 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,495 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,496 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,497 :: 		fuenteReloj = 2;                                         // Fuente de reloj = RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,498 :: 		InterrupcionP1(0xB2);                                    // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,499 :: 		}
L_spi_1101:
;Acelerografo.c,500 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,501 :: 		banSetReloj = 1; // Activa esta bandera para usar la hora/fecha recuperada
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,479 :: 		if ((banEsc == 1) && (buffer == 0xF6))
L__spi_1213:
L__spi_1212:
;Acelerografo.c,504 :: 		}
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

;Acelerografo.c,511 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT
;Acelerografo.c,514 :: 		INT1IF_bit = 0; // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,516 :: 		if (banSetReloj == 1)
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1287
	GOTO	L_int_1102
L__int_1287:
;Acelerografo.c,518 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,519 :: 		horaSistema++; // Incrementa el reloj del sistema
	MOV	#1, W1
	MOV	#0, W2
	MOV	#lo_addr(_horaSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,521 :: 		if (horaSistema == 86400)
	MOV	_horaSistema, W2
	MOV	_horaSistema+2, W3
	MOV	#20864, W0
	MOV	#1, W1
	CP	W2, W0
	CPB	W3, W1
	BRA Z	L__int_1288
	GOTO	L_int_1103
L__int_1288:
;Acelerografo.c,523 :: 		horaSistema = 0; //(24*3600)+(0*60)+(0) = 86400
	CLR	W0
	CLR	W1
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,524 :: 		}
L_int_1103:
;Acelerografo.c,525 :: 		if (banInicio == 1)
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1289
	GOTO	L_int_1104
L__int_1289:
;Acelerografo.c,527 :: 		Muestrear();
	CALL	_Muestrear
;Acelerografo.c,528 :: 		}
L_int_1104:
;Acelerografo.c,529 :: 		}
L_int_1102:
;Acelerografo.c,530 :: 		}
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

;Acelerografo.c,533 :: 		void int_2() org IVT_ADDR_INT2INTERRUPT
;Acelerografo.c,536 :: 		INT2IF_bit = 0; // Limpia la bandera de interrupcion externa INT2
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,538 :: 		if (banSyncReloj == 1)
	MOV	#lo_addr(_banSyncReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_2291
	GOTO	L_int_2105
L__int_2291:
;Acelerografo.c,541 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,543 :: 		horaSistema = horaSistema + 1; // Correccion 230901: Incrementa el reloj del sistema en 1 segundo
	MOV	#1, W1
	MOV	#0, W2
	MOV	#lo_addr(_horaSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,545 :: 		T3CON.TON = 1;
	BSET	T3CON, #15
;Acelerografo.c,546 :: 		TMR3 = 0;
	CLR	TMR3
;Acelerografo.c,547 :: 		}
L_int_2105:
;Acelerografo.c,548 :: 		}
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

;Acelerografo.c,587 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT
;Acelerografo.c,590 :: 		T1IF_bit = 0; // Limpia la bandera de interrupcion por desbordamiento del Timer1
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,592 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES); // 75                            //Lee el numero de muestras disponibles en el FIFO
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,593 :: 		numSetsFIFO = (numFIFO) / 3;               // 25                            //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,596 :: 		for (x = 0; x < numSetsFIFO; x++)
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
;Acelerografo.c,598 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,599 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Timer1Int109:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Timer1Int294
	GOTO	L_Timer1Int110
L__Timer1Int294:
;Acelerografo.c,601 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
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
;Acelerografo.c,599 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,602 :: 		}
	GOTO	L_Timer1Int109
L_Timer1Int110:
;Acelerografo.c,596 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,603 :: 		}
	GOTO	L_Timer1Int106
L_Timer1Int107:
;Acelerografo.c,606 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
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
;Acelerografo.c,608 :: 		if ((x == 0) || (x % 9 == 0))
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
;Acelerografo.c,610 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras;
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
;Acelerografo.c,611 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
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
;Acelerografo.c,612 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,613 :: 		}
	GOTO	L_Timer1Int118
L_Timer1Int117:
;Acelerografo.c,616 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
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
;Acelerografo.c,617 :: 		}
L_Timer1Int118:
;Acelerografo.c,606 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,618 :: 		}
	GOTO	L_Timer1Int112
L_Timer1Int113:
;Acelerografo.c,620 :: 		contFIFO = (contMuestras * 9); // Incrementa el contador de FIFOs
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	MOV	W0, _contFIFO
;Acelerografo.c,622 :: 		contTimer1++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer1
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,624 :: 		if (contTimer1 == numTMR1)
	MOV	#lo_addr(_contTimer1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_numTMR1), W0
	CP.B	W1, [W0]
	BRA Z	L__Timer1Int298
	GOTO	L_Timer1Int119
L__Timer1Int298:
;Acelerografo.c,626 :: 		T1CON.TON = 0;  // Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,627 :: 		banCiclo = 2;   // Activa la bandera que indica que se completo un ciclo de medicion
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,628 :: 		contTimer1 = 0; // Limpia el contador de interrupciones por Timer1
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,629 :: 		}
L_Timer1Int119:
;Acelerografo.c,630 :: 		}
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

;Acelerografo.c,634 :: 		void Timer2Int() org IVT_ADDR_T2INTERRUPT
;Acelerografo.c,637 :: 		T2IF_bit = 0;   // Limpia la bandera de interrupcion por desbordamiento del Timer2
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,638 :: 		contTimeout1++; // Incrementa el contador de Timeout
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimeout1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,641 :: 		if (contTimeout1 == 4)
	MOV	#lo_addr(_contTimeout1), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA Z	L__Timer2Int300
	GOTO	L_Timer2Int120
L__Timer2Int300:
;Acelerografo.c,643 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,644 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,645 :: 		contTimeout1 = 0;
	MOV	#lo_addr(_contTimeout1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,647 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,648 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,649 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,650 :: 		fuenteReloj = 5;                                         //**Indica que se obtuvo la hora del RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#5, W0
	MOV.B	W0, [W1]
;Acelerografo.c,651 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,652 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,653 :: 		}
L_Timer2Int120:
;Acelerografo.c,654 :: 		}
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

;Acelerografo.c,658 :: 		void Timer3Int() org IVT_ADDR_T3INTERRUPT
;Acelerografo.c,660 :: 		T3IF_bit = 0;
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,662 :: 		contTimer3++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer3
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer3), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,665 :: 		if (contTimer3 == 5)
	MOV	#lo_addr(_contTimer3), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA Z	L__Timer3Int302
	GOTO	L_Timer3Int121
L__Timer3Int302:
;Acelerografo.c,667 :: 		DS3234_setDate(horaSistema, fechaSistema); // Configura la hora en el RTC con la hora recuperada de la RPi
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	CALL	_DS3234_setDate
;Acelerografo.c,669 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,670 :: 		banSetReloj = 1; // Activa esta bandera para continuar trabajando con el pulso SQW
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,673 :: 		InterrupcionP1(0xB2);
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,674 :: 		contTimer3 = 0; // Encera el contador
	MOV	#lo_addr(_contTimer3), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,675 :: 		T3CON.TON = 0;  // Apaga el Timer3
	BCLR	T3CON, #15
;Acelerografo.c,676 :: 		}
L_Timer3Int121:
;Acelerografo.c,677 :: 		}
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

;Acelerografo.c,681 :: 		void urx_1() org IVT_ADDR_U1RXINTERRUPT
;Acelerografo.c,684 :: 		byteGPS = U1RXREG; // Lee el byte de la trama enviada por el GPS
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_byteGPS), W1
	MOV.B	U1RXREG, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,685 :: 		U1STA.OERR = 0;    // Limpia este bit para limpiar el FIFO UART1
	BCLR	U1STA, #1
;Acelerografo.c,688 :: 		if (banGPSI == 3)
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__urx_1304
	GOTO	L_urx_1122
L__urx_1304:
;Acelerografo.c,690 :: 		if (byteGPS != 0x2A)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#42, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1305
	GOTO	L_urx_1123
L__urx_1305:
;Acelerografo.c,692 :: 		tramaGPS[i_gps] = byteGPS; // LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,693 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,694 :: 		}
	GOTO	L_urx_1124
L_urx_1123:
;Acelerografo.c,697 :: 		banGPSI = 0; // Limpia la bandera de inicio de trama
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,698 :: 		banGPSC = 1; // Activa la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,699 :: 		}
L_urx_1124:
;Acelerografo.c,700 :: 		}
L_urx_1122:
;Acelerografo.c,703 :: 		if ((banGPSI == 1))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1306
	GOTO	L_urx_1125
L__urx_1306:
;Acelerografo.c,705 :: 		if (byteGPS == 0x24)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#36, W0
	CP.B	W1, W0
	BRA Z	L__urx_1307
	GOTO	L_urx_1126
L__urx_1307:
;Acelerografo.c,707 :: 		banGPSI = 2;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,708 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,709 :: 		}
L_urx_1126:
;Acelerografo.c,710 :: 		}
L_urx_1125:
;Acelerografo.c,711 :: 		if ((banGPSI == 2) && (i_gps < 6))
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
;Acelerografo.c,713 :: 		tramaGPS[i_gps] = byteGPS; // Recupera los datos de cabecera de la trama GPS: ["$", "G", "P", "R", "M", "C"]
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,714 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,711 :: 		if ((banGPSI == 2) && (i_gps < 6))
L__urx_1221:
L__urx_1220:
;Acelerografo.c,716 :: 		if ((banGPSI == 2) && (i_gps == 6))
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
;Acelerografo.c,719 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,720 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,722 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
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
;Acelerografo.c,724 :: 		banGPSI = 3;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,725 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,726 :: 		}
	GOTO	L_urx_1136
;Acelerografo.c,722 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
L__urx_1226:
L__urx_1225:
L__urx_1224:
L__urx_1223:
L__urx_1222:
;Acelerografo.c,729 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,730 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,731 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,733 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,734 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,735 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,736 :: 		fuenteReloj = 4;                                         // Fuente reloj: RTC/E4
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
;Acelerografo.c,737 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,738 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi y a los nodos                                                   //Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,739 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,740 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,741 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,742 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,743 :: 		}
L_urx_1136:
;Acelerografo.c,716 :: 		if ((banGPSI == 2) && (i_gps == 6))
L__urx_1228:
L__urx_1227:
;Acelerografo.c,747 :: 		if (banGPSC == 1)
	MOV	#lo_addr(_banGPSC), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1317
	GOTO	L_urx_1137
L__urx_1317:
;Acelerografo.c,750 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_urx_1138:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__urx_1318
	GOTO	L_urx_1139
L__urx_1318:
;Acelerografo.c,752 :: 		datosGPS[x] = tramaGPS[x + 1]; // Guarda los datos de hhmmss
	MOV	#lo_addr(_datosGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W2
	MOV	_x, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,750 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,753 :: 		}
	GOTO	L_urx_1138
L_urx_1139:
;Acelerografo.c,755 :: 		for (x = 44; x < 54; x++)
	MOV	#44, W0
	MOV	W0, _x
L_urx_1141:
	MOV	#54, W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1319
	GOTO	L_urx_1142
L__urx_1319:
;Acelerografo.c,757 :: 		if (tramaGPS[x] == 0x2C)
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W1
	MOV.B	#44, W0
	CP.B	W1, W0
	BRA Z	L__urx_1320
	GOTO	L_urx_1144
L__urx_1320:
;Acelerografo.c,759 :: 		for (y = 0; y < 6; y++)
	CLR	W0
	MOV	W0, _y
L_urx_1145:
	MOV	_y, W0
	CP	W0, #6
	BRA LTU	L__urx_1321
	GOTO	L_urx_1146
L__urx_1321:
;Acelerografo.c,761 :: 		datosGPS[6 + y] = tramaGPS[x + y + 1]; // Guarda los datos de DDMMAA en la trama datosGPS
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
;Acelerografo.c,759 :: 		for (y = 0; y < 6; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,762 :: 		}
	GOTO	L_urx_1145
L_urx_1146:
;Acelerografo.c,763 :: 		}
L_urx_1144:
;Acelerografo.c,755 :: 		for (x = 44; x < 54; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,764 :: 		}
	GOTO	L_urx_1141
L_urx_1142:
;Acelerografo.c,765 :: 		horaSistema = RecuperarHoraGPS(datosGPS);                // Recupera la hora del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarHoraGPS
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,766 :: 		fechaSistema = RecuperarFechaGPS(datosGPS);              // Recupera la fecha del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarFechaGPS
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,767 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del gps
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,770 :: 		if (tramaGPS[12] == 0x41)
	MOV	#lo_addr(_tramaGPS+12), W0
	MOV.B	[W0], W1
	MOV.B	#65, W0
	CP.B	W1, W0
	BRA Z	L__urx_1322
	GOTO	L_urx_1148
L__urx_1322:
;Acelerografo.c,772 :: 		fuenteReloj = 1; // Fuente reloj: GPS
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,773 :: 		banSyncReloj = 1;
	MOV	#lo_addr(_banSyncReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,774 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,775 :: 		}
	GOTO	L_urx_1149
L_urx_1148:
;Acelerografo.c,778 :: 		fuenteReloj = 3; // Fuente reloj: GPS/E3
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,779 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,780 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,781 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,782 :: 		}
L_urx_1149:
;Acelerografo.c,783 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,784 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,785 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,786 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,787 :: 		}
L_urx_1137:
;Acelerografo.c,790 :: 		U1RXIF_bit = 0;
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,791 :: 		}
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
