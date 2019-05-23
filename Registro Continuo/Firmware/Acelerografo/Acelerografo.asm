
_ADXL355_init:

;adxl355_spi.c,104 :: 		void ADXL355_init(){
;adxl355_spi.c,105 :: 		ADXL355_write_byte(Reset,0x52);                                             //Resetea el dispositivo
	PUSH	W10
	PUSH	W11
	MOV.B	#82, W11
	MOV.B	#47, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,106 :: 		Delay_ms(10);
	MOV	#2, W8
	MOV	#14464, W7
L_ADXL355_init0:
	DEC	W7
	BRA NZ	L_ADXL355_init0
	DEC	W8
	BRA NZ	L_ADXL355_init0
	NOP
	NOP
;adxl355_spi.c,107 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,108 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_62_5_Hz);
	MOV.B	#4, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,109 :: 		ADXL355_write_byte(Range, _2G);
	MOV.B	#1, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,110 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;adxl355_spi.c,113 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;adxl355_spi.c,114 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;adxl355_spi.c,115 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,116 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,117 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;adxl355_spi.c,118 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,119 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;adxl355_spi.c,122 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;adxl355_spi.c,123 :: 		unsigned char value = 0x00;
	PUSH	W10
;adxl355_spi.c,124 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,125 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,126 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,127 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;adxl355_spi.c,128 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,129 :: 		return value;
;adxl355_spi.c,130 :: 		}
;adxl355_spi.c,129 :: 		return value;
;adxl355_spi.c,130 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_data:

;adxl355_spi.c,133 :: 		unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
;adxl355_spi.c,136 :: 		if((ADXL355_read_byte(Status)&0x01)==1){                                 //Verifica que el bit DATA_RDY del registro Status este en alto
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W0
	AND	W0, #1, W0
	CP	W0, #1
	BRA Z	L__ADXL355_read_data111
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data111:
;adxl355_spi.c,137 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,138 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data3:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data112
	GOTO	L_ADXL355_read_data4
L__ADXL355_read_data112:
;adxl355_spi.c,139 :: 		muestra = ADXL355_read_byte(axisAddresses[j]);
	ZE	W2, W1
	MOV	#lo_addr(_axisAddresses), W0
	ADD	W0, W1, W0
	PUSH	W10
	MOV.B	[W0], W10
	CALL	_ADXL355_read_byte
	POP	W10
;adxl355_spi.c,140 :: 		vectorMuestra[j] = muestra;
	ZE	W2, W1
	ADD	W10, W1, W1
	MOV.B	W0, [W1]
;adxl355_spi.c,138 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,141 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data3
L_ADXL355_read_data4:
;adxl355_spi.c,142 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,143 :: 		} else {
	GOTO	L_ADXL355_read_data6
L_ADXL355_read_data2:
;adxl355_spi.c,144 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data7:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data113
	GOTO	L_ADXL355_read_data8
L__ADXL355_read_data113:
;adxl355_spi.c,145 :: 		vectorMuestra[j] = 0;
	ZE	W2, W0
	ADD	W10, W0, W1
	CLR	W0
	MOV.B	W0, [W1]
;adxl355_spi.c,144 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,146 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data7
L_ADXL355_read_data8:
;adxl355_spi.c,147 :: 		}
L_ADXL355_read_data6:
;adxl355_spi.c,148 :: 		return;
;adxl355_spi.c,149 :: 		}
L_end_ADXL355_read_data:
	RETURN
; end of _ADXL355_read_data

_ADXL355_read_FIFO:
	LNK	#2

;adxl355_spi.c,152 :: 		unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO){
;adxl355_spi.c,155 :: 		CS_ADXL355 = 0;
	PUSH	W10
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,156 :: 		SPI2_Write(add);
	PUSH	W10
	MOV	#35, W10
	CALL	_SPI2_Write
	POP	W10
;adxl355_spi.c,158 :: 		vectorFIFO[0] = SPI2_Read(0);
	MOV	W10, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,159 :: 		vectorFIFO[1] = SPI2_Read(1);
	ADD	W10, #1, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,160 :: 		vectorFIFO[2] = SPI2_Read(2);
	ADD	W10, #2, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,162 :: 		vectorFIFO[3] = SPI2_Read(0);
	ADD	W10, #3, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,163 :: 		vectorFIFO[4] = SPI2_Read(1);
	ADD	W10, #4, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,164 :: 		vectorFIFO[5] = SPI2_Read(2);
	ADD	W10, #5, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,166 :: 		vectorFIFO[6] = SPI2_Read(0);
	ADD	W10, #6, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,167 :: 		vectorFIFO[7] = SPI2_Read(1);
	ADD	W10, #7, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,168 :: 		vectorFIFO[8] = SPI2_Read(2);
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	MOV	#2, W10
	CALL	_SPI2_Read
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,169 :: 		CS_ADXL355 = 1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,170 :: 		Delay_us(5);
	MOV	#40, W7
L_ADXL355_read_FIFO10:
	DEC	W7
	BRA NZ	L_ADXL355_read_FIFO10
	NOP
	NOP
;adxl355_spi.c,172 :: 		}
;adxl355_spi.c,171 :: 		return;
;adxl355_spi.c,172 :: 		}
L_end_ADXL355_read_FIFO:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_read_FIFO

_ConfiguracionPrincipal:

;Acelerografo.c,63 :: 		void ConfiguracionPrincipal(){
;Acelerografo.c,66 :: 		CLKDIVbits.FRCDIV = 0;                                                     //FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,67 :: 		CLKDIVbits.PLLPOST = 0;                                                    //N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,68 :: 		CLKDIVbits.PLLPRE = 5;                                                     //N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,69 :: 		PLLFBDbits.PLLDIV = 150;                                                   //M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,72 :: 		ANSELA = 0;                                                                //Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,73 :: 		ANSELB = 0;                                                                //Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,74 :: 		TRISA3_bit = 0;                                                            //Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,75 :: 		TRISA4_bit = 0;                                                            //Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,76 :: 		TRISB4_bit = 0;                                                            //Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,77 :: 		TRISB10_bit = 1;                                                           //Configura el pin B10 como entrada *
	BSET	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,78 :: 		TRISB11_bit = 1;                                                           //Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,79 :: 		TRISB12_bit = 1;                                                           //Configura el pin B12 como entrada *
	BSET	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,80 :: 		TRISB13_bit = 1;                                                           //Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,82 :: 		INTCON2.GIE = 1;                                                           //Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,85 :: 		RPINR18bits.U1RXR = 0x22;                                                  //Configura el pin RB2/RPI34 como Rx1 *
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
;Acelerografo.c,86 :: 		RPOR0bits.RP35R = 0x01;                                                    //Configura el Tx1 en el pin RB3/RP35 *
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR0bits
;Acelerografo.c,87 :: 		UART1_Init(9600);                                                          //Inicializa el UART1 con una velocidad de 9600 baudios
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;Acelerografo.c,88 :: 		U1RXIE_bit = 0;                                                            //Habilita la interrupcion por UART1 RX *
	BCLR	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,89 :: 		U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion por UART1 RX *
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,90 :: 		IPC2bits.U1RXIP = 0x04;                                                    //Prioridad de la interrupcion UART1 RX
	MOV	#16384, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,93 :: 		SPI1STAT.SPIEN = 1;                                                        //Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,94 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
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
;Acelerografo.c,95 :: 		SPI1IE_bit = 1;                                                            //Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,96 :: 		SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,97 :: 		IPC2bits.SPI1IP = 0x03;                                                    //Prioridad de la interrupcion SPI1
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,100 :: 		RPINR22bits.SDI2R = 0x21;                                                  //Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,101 :: 		RPOR2bits.RP38R = 0x08;                                                    //Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,102 :: 		RPOR1bits.RP37R = 0x09;                                                    //Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,103 :: 		SPI2STAT.SPIEN = 1;                                                        //Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,104 :: 		SPI2_Init();                                                               //Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,107 :: 		RPINR0 = 0x2E00;                                                           //Asigna INT1 al RB14/RPI46
	MOV	#11776, W0
	MOV	WREG, RPINR0
;Acelerografo.c,108 :: 		INT1IE_bit = 0;                                                            //Habilita la interrupcion externa INT1
	BCLR	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,109 :: 		INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,110 :: 		IPC5bits.INT1IP = 0x01;                                                    //Prioridad en la interrupocion externa 1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,113 :: 		T1CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T1CON
;Acelerografo.c,114 :: 		T1CON.TON = 0;                                                             //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,115 :: 		T1IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,116 :: 		T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,117 :: 		PR1 = 62500;                                                               //Carga el preload para un tiempo de 100ms
	MOV	#62500, W0
	MOV	WREG, PR1
;Acelerografo.c,118 :: 		IPC0bits.T1IP = 0x02;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,121 :: 		T2CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T2CON
;Acelerografo.c,122 :: 		T2CON.TON = 0;                                                             //Apaga el Timer2
	BCLR	T2CON, #15
;Acelerografo.c,123 :: 		T2IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR2
	BSET	T2IE_bit, BitPos(T2IE_bit+0)
;Acelerografo.c,124 :: 		T2IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,125 :: 		PR2 = 46875;                                                               //Carga el preload para un tiempo de 75ms
	MOV	#46875, W0
	MOV	WREG, PR2
;Acelerografo.c,126 :: 		IPC1bits.T2IP = 0x05;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;Acelerografo.c,128 :: 		ADXL355_init();
	CALL	_ADXL355_init
;Acelerografo.c,130 :: 		Delay_ms(200);                                                             //Espera hasta que se estabilicen los cambios
	MOV	#25, W8
	MOV	#27150, W7
L_ConfiguracionPrincipal12:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal12
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal12
	NOP
;Acelerografo.c,132 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_ConfigurarGPS:

;Acelerografo.c,137 :: 		void ConfigurarGPS(){
;Acelerografo.c,138 :: 		UART1_Write_Text("$PMTK605*31\r\n");
	PUSH	W10
	PUSH	W11
	MOV	#lo_addr(?lstr1_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,140 :: 		UART1_Write_Text("$PMTK220,1000*1F\r\n");
	MOV	#lo_addr(?lstr2_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,141 :: 		UART1_Write_Text("$PMTK251,115200*1F\r\n");
	MOV	#lo_addr(?lstr3_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,142 :: 		Delay_ms(1000);                                                            //Tiempo necesario para que se de efecto el cambio de configuracion
	MOV	#123, W8
	MOV	#4681, W7
L_ConfigurarGPS14:
	DEC	W7
	BRA NZ	L_ConfigurarGPS14
	DEC	W8
	BRA NZ	L_ConfigurarGPS14
;Acelerografo.c,143 :: 		UART1_Init(115200);
	MOV	#49664, W10
	MOV	#1, W11
	CALL	_UART1_Init
;Acelerografo.c,144 :: 		UART1_Write_Text("$PMTK313,1*2E\r\n");
	MOV	#lo_addr(?lstr4_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,145 :: 		UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
	MOV	#lo_addr(?lstr5_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,146 :: 		UART1_Write_Text("$PMTK319,1*24\r\n");
	MOV	#lo_addr(?lstr6_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,147 :: 		UART1_Write_Text("$PMTK413*34\r\n");
	MOV	#lo_addr(?lstr7_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,148 :: 		UART1_Write_Text("$PMTK513,1*28\r\n");
	MOV	#lo_addr(?lstr8_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,149 :: 		}
L_end_ConfigurarGPS:
	POP	W11
	POP	W10
	RETURN
; end of _ConfigurarGPS

_AjustarRelojSistema:
	LNK	#8

;Acelerografo.c,154 :: 		void AjustarRelojSistema(unsigned char *tramaDatosGPS, unsigned char *tramaTiempo){
;Acelerografo.c,157 :: 		char *ptrDatoString = &datoString;
	PUSH	W10
	ADD	W14, #0, W2
	MOV	W2, [W14+6]
; ptrDatoString start address is: 12 (W6)
	MOV	W2, W6
;Acelerografo.c,158 :: 		datoString[2] = '\0';
	ADD	W2, #2, W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,160 :: 		datoString[0] = tramaDatosGPS[0];
	MOV.B	[W10], [W2]
;Acelerografo.c,161 :: 		datoString[1] = tramaDatosGPS[1];
	ADD	W2, #1, W1
	ADD	W10, #1, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,162 :: 		tramaTiempo[0] = (short) atoi(ptrDatoString);
	MOV	W11, W0
	MOV	W0, [W14+4]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,164 :: 		datoString[0] = tramaDatosGPS[2];
	ADD	W10, #2, W1
	MOV	[W14+6], W0
	MOV.B	[W1], [W0]
;Acelerografo.c,165 :: 		datoString[1] = tramaDatosGPS[3];
	ADD	W0, #1, W1
	ADD	W10, #3, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,166 :: 		tramaTiempo[1] = (short) atoi(ptrDatoString);
	ADD	W11, #1, W0
	MOV	W0, [W14+4]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,168 :: 		datoString[0] = tramaDatosGPS[4];
	ADD	W10, #4, W1
	MOV	[W14+6], W0
	MOV.B	[W1], [W0]
;Acelerografo.c,169 :: 		datoString[1] = tramaDatosGPS[5];
	ADD	W0, #1, W1
	ADD	W10, #5, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,170 :: 		tramaTiempo[2] = (short) atoi(ptrDatoString);
	ADD	W11, #2, W0
	MOV	W0, [W14+4]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,172 :: 		datoString[0] = tramaDatosGPS[6];
	ADD	W10, #6, W1
	MOV	[W14+6], W0
	MOV.B	[W1], [W0]
;Acelerografo.c,173 :: 		datoString[1] = tramaDatosGPS[7];
	ADD	W0, #1, W1
	ADD	W10, #7, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,174 :: 		tramaTiempo[3] = (short) atoi(ptrDatoString);
	ADD	W11, #3, W0
	MOV	W0, [W14+4]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,176 :: 		datoString[0] = tramaDatosGPS[8];
	ADD	W10, #8, W1
	MOV	[W14+6], W0
	MOV.B	[W1], [W0]
;Acelerografo.c,177 :: 		datoString[1] = tramaDatosGPS[9];
	ADD	W0, #1, W1
	ADD	W10, #9, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,178 :: 		tramaTiempo[4] = (short) atoi(ptrDatoString);
	ADD	W11, #4, W0
	MOV	W0, [W14+4]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,180 :: 		datoString[0] = tramaDatosGPS[10];
	ADD	W10, #10, W1
	MOV	[W14+6], W0
	MOV.B	[W1], [W0]
;Acelerografo.c,181 :: 		datoString[1] = tramaDatosGPS[11];
	ADD	W0, #1, W1
	ADD	W10, #11, W0
	MOV.B	[W0], [W1]
;Acelerografo.c,182 :: 		tramaTiempo[5] = (short) atoi(ptrDatoString);
	ADD	W11, #5, W0
	MOV	W0, [W14+4]
	MOV	W6, W10
; ptrDatoString end address is: 12 (W6)
	CALL	_atoi
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;Acelerografo.c,189 :: 		tiempoSegundos = (tramaTiempo[0]*3600)+(tramaTiempo[1]*60)+(tramaTiempo[2]);        //Calcula el segundo actual = hh*3600 + mm*60 + ss
	ZE	[W11], W1
	MOV	#3600, W0
	MUL.SS	W1, W0, W2
	ADD	W11, #1, W0
	ZE	[W0], W1
	MOV	#60, W0
	MUL.SS	W1, W0, W0
	ADD	W2, W0, W1
	ADD	W11, #2, W0
	ZE	[W0], W0
	ADD	W1, W0, W0
	ASR	W0, #15, W1
	MOV	W0, _tiempoSegundos
	MOV	W1, _tiempoSegundos+2
;Acelerografo.c,190 :: 		banSetReloj = 1;                                                                    //Cambia el estado de la bandera cuando ha terminado de configurar el reloj
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,192 :: 		}
L_end_AjustarRelojSistema:
	POP	W10
	ULNK
	RETURN
; end of _AjustarRelojSistema

_int_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,200 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT {
;Acelerografo.c,202 :: 		INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
	PUSH	W10
	PUSH	W11
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,204 :: 		if (banInicio==1){
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1119
	GOTO	L_int_116
L__int_1119:
;Acelerografo.c,205 :: 		if (banSetReloj==1){                                                    //Verifica si la hora del sistema se configuro satisfactoriamente
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1120
	GOTO	L_int_117
L__int_1120:
;Acelerografo.c,206 :: 		banInicio=2;                                                         //Cambia el estado de la bandera banInicio para permitir el muestreo de la señal
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,207 :: 		} else {
	GOTO	L_int_118
L_int_117:
;Acelerografo.c,208 :: 		U1RXIE_bit = 1;                                                         //Habilita la interrupcion por UARTRx
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,209 :: 		}
L_int_118:
;Acelerografo.c,210 :: 		}
L_int_116:
;Acelerografo.c,214 :: 		if (banInicio==2){
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__int_1121
	GOTO	L_int_119
L__int_1121:
;Acelerografo.c,215 :: 		if (banCiclo==0){
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__int_1122
	GOTO	L_int_120
L__int_1122:
;Acelerografo.c,217 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                   //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,219 :: 		} else {
	GOTO	L_int_121
L_int_120:
;Acelerografo.c,221 :: 		banCiclo = 0;                                                      //Limpia la bandera de ciclo completo
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,223 :: 		tramaCompleta[0] = contCiclos;                                     //LLena el primer elemento de la tramaCompleta con el contador de ciclos
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_contCiclos), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,225 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,227 :: 		numSetsFIFO = (numFIFO)/3;                                         //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,230 :: 		for (x=0;x<numSetsFIFO;x++){
	CLR	W0
	MOV	W0, _x
L_int_122:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__int_1123
	GOTO	L_int_123
L__int_1123:
;Acelerografo.c,231 :: 		ADXL355_read_FIFO(datosLeidos);                               //Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,232 :: 		for (y=0;y<9;y++){
	CLR	W0
	MOV	W0, _y
L_int_125:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__int_1124
	GOTO	L_int_126
L__int_1124:
;Acelerografo.c,233 :: 		datosFIFO[y+(x*9)] = datosLeidos[y];                       //LLena la trama datosFIFO
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
;Acelerografo.c,232 :: 		for (y=0;y<9;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,234 :: 		}
	GOTO	L_int_125
L_int_126:
;Acelerografo.c,230 :: 		for (x=0;x<numSetsFIFO;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,235 :: 		}
	GOTO	L_int_122
L_int_123:
;Acelerografo.c,240 :: 		for (x=0;x<(numSetsFIFO*9);x++){
	CLR	W0
	MOV	W0, _x
L_int_128:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__int_1125
	GOTO	L_int_129
L__int_1125:
;Acelerografo.c,241 :: 		if ((x==0)||(x%9==0)){
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__int_1126
	GOTO	L__int_190
L__int_1126:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__int_1127
	GOTO	L__int_189
L__int_1127:
	GOTO	L_int_133
L__int_190:
L__int_189:
;Acelerografo.c,242 :: 		tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
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
;Acelerografo.c,243 :: 		tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
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
;Acelerografo.c,244 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,245 :: 		} else {
	GOTO	L_int_134
L_int_133:
;Acelerografo.c,246 :: 		tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
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
;Acelerografo.c,247 :: 		}
L_int_134:
;Acelerografo.c,240 :: 		for (x=0;x<(numSetsFIFO*9);x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,248 :: 		}
	GOTO	L_int_128
L_int_129:
;Acelerografo.c,251 :: 		for (x=0;x<6;x++){
	CLR	W0
	MOV	W0, _x
L_int_135:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__int_1128
	GOTO	L_int_136
L__int_1128:
;Acelerografo.c,252 :: 		tramaCompleta[2500+x] = tiempo[x];
	MOV	#2500, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,251 :: 		for (x=0;x<6;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,253 :: 		}
	GOTO	L_int_135
L_int_136:
;Acelerografo.c,255 :: 		banTI = 1;                                                         //Activa la bandera de inicio de trama para permitir el envio de la trama por SPI
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,256 :: 		RP1 = 1;                                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,257 :: 		Delay_us(20);
	MOV	#160, W7
L_int_138:
	DEC	W7
	BRA NZ	L_int_138
	NOP
	NOP
;Acelerografo.c,258 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,260 :: 		}
L_int_121:
;Acelerografo.c,262 :: 		contCiclos++;                                                          //Incrementa el contador de ciclos
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,263 :: 		contMuestras = 0;                                                      //Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,264 :: 		contFIFO = 0;                                                          //Limpia el contador de FIFOs
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,266 :: 		if (ADXL355_read_byte(POWER_CTL)&0x01==1){
	MOV.B	#45, W10
	CALL	_ADXL355_read_byte
	BTSS	W0, #0
	GOTO	L_int_140
;Acelerografo.c,267 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|MEASURING);                  //Coloca el ADXL en modo medicion
	MOV.B	#4, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,268 :: 		}
L_int_140:
;Acelerografo.c,270 :: 		T1CON.TON = 1;                                                         //Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,272 :: 		}
L_int_119:
;Acelerografo.c,277 :: 		}
L_end_int_1:
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
; end of _int_1

_Timer1Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,281 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT{
;Acelerografo.c,283 :: 		T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion por desbordamiento del Timer1
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,286 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES); //75                            //Lee el numero de muestras disponibles en el FIFO
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,288 :: 		numSetsFIFO = (numFIFO)/3;                 //25                            //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,292 :: 		for (x=0;x<numSetsFIFO;x++){
	CLR	W0
	MOV	W0, _x
L_Timer1Int41:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Timer1Int130
	GOTO	L_Timer1Int42
L__Timer1Int130:
;Acelerografo.c,293 :: 		ADXL355_read_FIFO(datosLeidos);                                        //Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,294 :: 		for (y=0;y<9;y++){
	CLR	W0
	MOV	W0, _y
L_Timer1Int44:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Timer1Int131
	GOTO	L_Timer1Int45
L__Timer1Int131:
;Acelerografo.c,295 :: 		datosFIFO[y+(x*9)] = datosLeidos[y];                               //LLena la trama datosFIFO
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
;Acelerografo.c,294 :: 		for (y=0;y<9;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,296 :: 		}
	GOTO	L_Timer1Int44
L_Timer1Int45:
;Acelerografo.c,292 :: 		for (x=0;x<numSetsFIFO;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,297 :: 		}
	GOTO	L_Timer1Int41
L_Timer1Int42:
;Acelerografo.c,300 :: 		for (x=0;x<(numSetsFIFO*9);x++){      //0-224
	CLR	W0
	MOV	W0, _x
L_Timer1Int47:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Timer1Int132
	GOTO	L_Timer1Int48
L__Timer1Int132:
;Acelerografo.c,301 :: 		if ((x==0)||(x%9==0)){
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int133
	GOTO	L__Timer1Int93
L__Timer1Int133:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int134
	GOTO	L__Timer1Int92
L__Timer1Int134:
	GOTO	L_Timer1Int52
L__Timer1Int93:
L__Timer1Int92:
;Acelerografo.c,302 :: 		tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
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
;Acelerografo.c,304 :: 		tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
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
;Acelerografo.c,306 :: 		} else {
	GOTO	L_Timer1Int53
L_Timer1Int52:
;Acelerografo.c,307 :: 		tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
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
;Acelerografo.c,308 :: 		}
L_Timer1Int53:
;Acelerografo.c,300 :: 		for (x=0;x<(numSetsFIFO*9);x++){      //0-224
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,309 :: 		}
	GOTO	L_Timer1Int47
L_Timer1Int48:
;Acelerografo.c,311 :: 		contFIFO = (contMuestras*9);                                               //Incrementa el contador de FIFOs
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	MOV	W0, _contFIFO
;Acelerografo.c,313 :: 		contTimer1++;                                                              //Incrementa una unidad cada vez que entra a la interrupcion por Timer1
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,315 :: 		if (contTimer1==9){                                                        //Verifica si se recibio los 5 FIFOS
	MOV	#lo_addr(_contTimer1), W0
	MOV.B	[W0], W0
	CP.B	W0, #9
	BRA Z	L__Timer1Int135
	GOTO	L_Timer1Int54
L__Timer1Int135:
;Acelerografo.c,316 :: 		T1CON.TON = 0;                                                          //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,317 :: 		banCiclo = 1;                                                           //Activa la bandera que indica que se completo un ciclo de medicion
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,318 :: 		contTimer1 = 0;                                                         //Limpia el contador de interrupciones por Timer1
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,319 :: 		}
L_Timer1Int54:
;Acelerografo.c,323 :: 		}
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

;Acelerografo.c,327 :: 		void Timer2Int() org IVT_ADDR_T2INTERRUPT{
;Acelerografo.c,329 :: 		T2IF_bit = 0;
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,331 :: 		}
L_end_Timer2Int:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	50
	POP	DSWPAG
	RETFIE
; end of _Timer2Int

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,335 :: 		void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
;Acelerografo.c,337 :: 		SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,338 :: 		buffer = SPI1BUF;                                                          //Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,340 :: 		if ((banTI==1)){                                                           //Verifica si la bandera de inicio de trama esta activa
	MOV	#lo_addr(_banTI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1138
	GOTO	L_spi_155
L__spi_1138:
;Acelerografo.c,341 :: 		banLec = 1;                                                             //Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,342 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,343 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,344 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,345 :: 		}
L_spi_155:
;Acelerografo.c,346 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1139
	GOTO	L__spi_197
L__spi_1139:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1140
	GOTO	L__spi_196
L__spi_1140:
L__spi_195:
;Acelerografo.c,347 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,348 :: 		i++;
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,346 :: 		if ((banLec==1)&&(buffer!=0xB1)){
L__spi_197:
L__spi_196:
;Acelerografo.c,350 :: 		if ((banLec==1)&&(buffer==0xB1)){                                          //Si detecta el delimitador de final de trama:
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1141
	GOTO	L__spi_199
L__spi_1141:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA Z	L__spi_1142
	GOTO	L__spi_198
L__spi_1142:
L__spi_194:
;Acelerografo.c,351 :: 		banLec = 0;                                                             //Limpia la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,352 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,353 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,350 :: 		if ((banLec==1)&&(buffer==0xB1)){                                          //Si detecta el delimitador de final de trama:
L__spi_199:
L__spi_198:
;Acelerografo.c,356 :: 		}
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

_urx_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,360 :: 		void urx_1() org  IVT_ADDR_U1RXINTERRUPT {
;Acelerografo.c,362 :: 		U1RXIF_bit = 0;
	PUSH	W10
	PUSH	W11
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,363 :: 		byteGPS = UART1_Read();                                                    //Lee el byte de la trama enviada por el GPS
	CALL	_UART1_Read
	MOV	#lo_addr(_byteGPS), W1
	MOV.B	W0, [W1]
;Acelerografo.c,369 :: 		if (banTIGPS==0){
	MOV	#lo_addr(_banTIGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__urx_1144
	GOTO	L_urx_162
L__urx_1144:
;Acelerografo.c,370 :: 		if (byteGPS == 0x24){                                                   //Verifica si el byte recibido es el simbolo "$" que indica el inicio de una trama GPS
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#36, W0
	CP.B	W1, W0
	BRA Z	L__urx_1145
	GOTO	L_urx_163
L__urx_1145:
;Acelerografo.c,371 :: 		banTIGPS = 1;                                                        //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTIGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,372 :: 		i_gps = 0;                                                           //Limpia el subindice de la trama GPS
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,373 :: 		}
L_urx_163:
;Acelerografo.c,374 :: 		}
L_urx_162:
;Acelerografo.c,376 :: 		if (banTIGPS==1){                                                          //llego
	MOV	#lo_addr(_banTIGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1146
	GOTO	L_urx_164
L__urx_1146:
;Acelerografo.c,378 :: 		if (byteGPS!=0x2A){
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#42, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1147
	GOTO	L_urx_165
L__urx_1147:
;Acelerografo.c,379 :: 		tramaGPS[i_gps] = byteGPS;                                           //LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,380 :: 		banTFGPS = 0;                                                        //Limpia la bandera de final de trama
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,381 :: 		if (i_gps<70){
	MOV	#70, W1
	MOV	#lo_addr(_i_gps), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1148
	GOTO	L_urx_166
L__urx_1148:
;Acelerografo.c,382 :: 		i_gps++;                                                          //Incrementa el valor del subindice mientras sea menor a 70
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,383 :: 		}
L_urx_166:
;Acelerografo.c,384 :: 		if (tramaGPS[1]!=0x47){                                              //Verifica si el segundo elemento guardado es una "P"
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1149
	GOTO	L_urx_167
L__urx_1149:
;Acelerografo.c,385 :: 		RP2 = 1;
	BSET	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,386 :: 		banTIGPS = 0;                                                     //Detiene el proceso limpiando la bandera banTIGPS
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,387 :: 		U1RXIE_bit = 0;                                                   //Apaga la interrupcion por UARTRx
	BCLR	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,389 :: 		}
L_urx_167:
;Acelerografo.c,390 :: 		} else {
	GOTO	L_urx_168
L_urx_165:
;Acelerografo.c,391 :: 		tramaGPS[i_gps] = byteGPS;
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,392 :: 		banTFGPS = 1;                                                        //Activa la bandera de final de trama GPS
	MOV	#lo_addr(_banTFGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,394 :: 		}
L_urx_168:
;Acelerografo.c,395 :: 		if (banTFGPS==1){
	MOV	#lo_addr(_banTFGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1150
	GOTO	L_urx_169
L__urx_1150:
;Acelerografo.c,396 :: 		banTIGPS = 0;                                                        //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,397 :: 		banTCGPS = 1;                                                        //Activa la bandera de trama completa
	MOV	#lo_addr(_banTCGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,398 :: 		}
L_urx_169:
;Acelerografo.c,399 :: 		}
L_urx_164:
;Acelerografo.c,401 :: 		if (banTCGPS==1){
	MOV	#lo_addr(_banTCGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1151
	GOTO	L_urx_170
L__urx_1151:
;Acelerografo.c,402 :: 		if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){      //"GPRMC" y "A"
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA Z	L__urx_1152
	GOTO	L__urx_1106
L__urx_1152:
	MOV	#lo_addr(_tramaGPS+2), W0
	MOV.B	[W0], W1
	MOV.B	#80, W0
	CP.B	W1, W0
	BRA Z	L__urx_1153
	GOTO	L__urx_1105
L__urx_1153:
	MOV	#lo_addr(_tramaGPS+3), W0
	MOV.B	[W0], W1
	MOV.B	#82, W0
	CP.B	W1, W0
	BRA Z	L__urx_1154
	GOTO	L__urx_1104
L__urx_1154:
	MOV	#lo_addr(_tramaGPS+4), W0
	MOV.B	[W0], W1
	MOV.B	#77, W0
	CP.B	W1, W0
	BRA Z	L__urx_1155
	GOTO	L__urx_1103
L__urx_1155:
	MOV	#lo_addr(_tramaGPS+5), W0
	MOV.B	[W0], W1
	MOV.B	#67, W0
	CP.B	W1, W0
	BRA Z	L__urx_1156
	GOTO	L__urx_1102
L__urx_1156:
	MOV	#lo_addr(_tramaGPS+18), W0
	MOV.B	[W0], W1
	MOV.B	#65, W0
	CP.B	W1, W0
	BRA Z	L__urx_1157
	GOTO	L__urx_1101
L__urx_1157:
L__urx_1100:
;Acelerografo.c,403 :: 		for (x=0;x<6;x++){
	CLR	W0
	MOV	W0, _x
L_urx_174:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__urx_1158
	GOTO	L_urx_175
L__urx_1158:
;Acelerografo.c,404 :: 		datosGPS[x] = tramaGPS[7+x];                                     //Guarda los datos de hhmmss
	MOV	#lo_addr(_datosGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W2
	MOV	_x, W0
	ADD	W0, #7, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,403 :: 		for (x=0;x<6;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,405 :: 		}
	GOTO	L_urx_174
L_urx_175:
;Acelerografo.c,406 :: 		for (x=50;x<60;x++){
	MOV	#50, W0
	MOV	W0, _x
L_urx_177:
	MOV	#60, W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1159
	GOTO	L_urx_178
L__urx_1159:
;Acelerografo.c,407 :: 		if (tramaGPS[x]==0x2C){                                          //Busca el simbolo "," a partir de la posicion 50
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W1
	MOV.B	#44, W0
	CP.B	W1, W0
	BRA Z	L__urx_1160
	GOTO	L_urx_180
L__urx_1160:
;Acelerografo.c,408 :: 		for (y=0;y<6;y++){
	CLR	W0
	MOV	W0, _y
L_urx_181:
	MOV	_y, W0
	CP	W0, #6
	BRA LTU	L__urx_1161
	GOTO	L_urx_182
L__urx_1161:
;Acelerografo.c,409 :: 		datosGPS[6+y] = tramaGPS[x+y+1];                         //Guarda los datos de DDMMAA en la trama datosGPS
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
;Acelerografo.c,408 :: 		for (y=0;y<6;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,410 :: 		}
	GOTO	L_urx_181
L_urx_182:
;Acelerografo.c,411 :: 		}
L_urx_180:
;Acelerografo.c,406 :: 		for (x=50;x<60;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,412 :: 		}
	GOTO	L_urx_177
L_urx_178:
;Acelerografo.c,413 :: 		AjustarRelojSistema(datosGPS, tiempo);
	MOV	#lo_addr(_tiempo), W11
	MOV	#lo_addr(_datosGPS), W10
	CALL	_AjustarRelojSistema
;Acelerografo.c,402 :: 		if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){      //"GPRMC" y "A"
L__urx_1106:
L__urx_1105:
L__urx_1104:
L__urx_1103:
L__urx_1102:
L__urx_1101:
;Acelerografo.c,416 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,417 :: 		banTIGPS = 0;
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,418 :: 		banTCGPS = 0;
	MOV	#lo_addr(_banTCGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,419 :: 		U1RXIE_bit = 0;                                                         //Apaga la interrupcion por UARTRx
	BCLR	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,420 :: 		}
L_urx_170:
;Acelerografo.c,422 :: 		}
L_end_urx_1:
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

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,426 :: 		void main() {
;Acelerografo.c,428 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,429 :: 		ConfigurarGPS();
	CALL	_ConfigurarGPS
;Acelerografo.c,431 :: 		tiempo[0] = 12;                                                            //Hora
	MOV	#lo_addr(_tiempo), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,432 :: 		tiempo[1] = 12;                                                            //Minuto
	MOV	#lo_addr(_tiempo+1), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,433 :: 		tiempo[2] = 0;                                                             //Segundo
	MOV	#lo_addr(_tiempo+2), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,434 :: 		tiempo[3] = 1;                                                             //Dia
	MOV	#lo_addr(_tiempo+3), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,435 :: 		tiempo[4] = 1;                                                             //Mes
	MOV	#lo_addr(_tiempo+4), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,436 :: 		tiempo[5] = 19;                                                            //Año
	MOV	#lo_addr(_tiempo+5), W1
	MOV.B	#19, W0
	MOV.B	W0, [W1]
;Acelerografo.c,438 :: 		datosLeidos[0] = 111;
	MOV	#lo_addr(_datosLeidos), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,439 :: 		datosLeidos[1] = 111;
	MOV	#lo_addr(_datosLeidos+1), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,440 :: 		datosLeidos[2] = 111;
	MOV	#lo_addr(_datosLeidos+2), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,441 :: 		datosLeidos[3] = 111;
	MOV	#lo_addr(_datosLeidos+3), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,442 :: 		datosLeidos[4] = 111;
	MOV	#lo_addr(_datosLeidos+4), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,443 :: 		datosLeidos[5] = 111;
	MOV	#lo_addr(_datosLeidos+5), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,444 :: 		datosLeidos[6] = 111;
	MOV	#lo_addr(_datosLeidos+6), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,445 :: 		datosLeidos[7] = 111;
	MOV	#lo_addr(_datosLeidos+7), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,446 :: 		datosLeidos[8] = 111;
	MOV	#lo_addr(_datosLeidos+8), W1
	MOV.B	#111, W0
	MOV.B	W0, [W1]
;Acelerografo.c,448 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,449 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,450 :: 		banCiclo = 0;
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,451 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,452 :: 		banTIGPS = 0;
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,453 :: 		banTFGPS = 0;
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,454 :: 		banTCGPS = 0;
	MOV	#lo_addr(_banTCGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,456 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,457 :: 		x = 0;
	CLR	W0
	MOV	W0, _x
;Acelerografo.c,458 :: 		y = 0;
	CLR	W0
	MOV	W0, _y
;Acelerografo.c,459 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,460 :: 		tiempoSegundos = 0;
	CLR	W0
	CLR	W1
	MOV	W0, _tiempoSegundos
	MOV	W1, _tiempoSegundos+2
;Acelerografo.c,461 :: 		segundoDeAjuste = (3600*tiempoDeAjuste[0]) + (60*tiempoDeAjuste[1]);       //Calcula el segundo en el que se efectuara el ajuste de hora = hh*3600 + mm*60
	MOV	#lo_addr(_tiempoDeAjuste), W0
	ZE	[W0], W1
	MOV	#3600, W0
	MUL.SS	W0, W1, W2
	MOV	#60, W1
	MOV	#lo_addr(_tiempoDeAjuste+1), W0
	ZE	[W0], W0
	MUL.SS	W1, W0, W0
	ADD	W2, W0, W0
	ASR	W0, #15, W1
	MOV	W0, _segundoDeAjuste
	MOV	W1, _segundoDeAjuste+2
;Acelerografo.c,463 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,464 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,465 :: 		contFIFO = 0;
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,466 :: 		numFIFO = 0;
	MOV	#lo_addr(_numFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,467 :: 		numSetsFIFO = 0;
	MOV	#lo_addr(_numSetsFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,468 :: 		contTimer1 = 0;
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,470 :: 		byteGPS = 0;
	MOV	#lo_addr(_byteGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,472 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,473 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,475 :: 		puntero_8 = &auxiliar;
	MOV	#lo_addr(_auxiliar), W0
	MOV	W0, _puntero_8
;Acelerografo.c,477 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,479 :: 		banInicio = 2;
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,480 :: 		INT1IE_bit = 1;                                                            //Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,482 :: 		while(1){
L_main84:
;Acelerografo.c,484 :: 		Delay_ms(500);
	MOV	#62, W8
	MOV	#2340, W7
L_main86:
	DEC	W7
	BRA NZ	L_main86
	DEC	W8
	BRA NZ	L_main86
	NOP
	NOP
;Acelerografo.c,486 :: 		}
	GOTO	L_main84
;Acelerografo.c,488 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
