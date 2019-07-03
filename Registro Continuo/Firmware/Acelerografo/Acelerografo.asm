
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
	BRA Z	L__ADXL355_read_data142
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data142:
;adxl355_spi.c,137 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,138 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data3:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data143
	GOTO	L_ADXL355_read_data4
L__ADXL355_read_data143:
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
	BRA LTU	L__ADXL355_read_data144
	GOTO	L_ADXL355_read_data8
L__ADXL355_read_data144:
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

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,71 :: 		void main() {
;Acelerografo.c,73 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,74 :: 		ConfigurarGPS();
	CALL	_ConfigurarGPS
;Acelerografo.c,76 :: 		tiempo[0] = 12;                                                            //Hora
	MOV	#lo_addr(_tiempo), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,77 :: 		tiempo[1] = 12;                                                            //Minuto
	MOV	#lo_addr(_tiempo+1), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,78 :: 		tiempo[2] = 12;                                                            //Segundo
	MOV	#lo_addr(_tiempo+2), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,79 :: 		tiempo[3] = 12;                                                            //Dia
	MOV	#lo_addr(_tiempo+3), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,80 :: 		tiempo[4] = 12;                                                            //Mes
	MOV	#lo_addr(_tiempo+4), W1
	MOV.B	#12, W0
	MOV.B	W0, [W1]
;Acelerografo.c,81 :: 		tiempo[5] = 19;                                                            //Año
	MOV	#lo_addr(_tiempo+5), W1
	MOV.B	#19, W0
	MOV.B	W0, [W1]
;Acelerografo.c,83 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,84 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
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
;Acelerografo.c,87 :: 		banSetGPS = 0;
	MOV	#lo_addr(_banSetGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,88 :: 		banTIGPS = 0;
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,89 :: 		banTFGPS = 0;
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,90 :: 		banTCGPS = 0;
	MOV	#lo_addr(_banTCGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,92 :: 		banMuestrear = 0;
	MOV	#lo_addr(_banMuestrear), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,93 :: 		banLeer = 0;
	MOV	#lo_addr(_banLeer), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,94 :: 		banConf = 0;
	MOV	#lo_addr(_banConf), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,96 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,97 :: 		x = 0;
	CLR	W0
	MOV	W0, _x
;Acelerografo.c,98 :: 		y = 0;
	CLR	W0
	MOV	W0, _y
;Acelerografo.c,99 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,100 :: 		tiempoSistema = 0;
	CLR	W0
	CLR	W1
	MOV	W0, _tiempoSistema
	MOV	W1, _tiempoSistema+2
;Acelerografo.c,101 :: 		fechaSistema = 190101;
	MOV	#59029, W0
	MOV	#2, W1
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,102 :: 		segundoDeAjuste = (3600*tiempoDeAjuste[0]) + (60*tiempoDeAjuste[1]);       //Calcula el segundo en el que se efectuara el ajuste de hora = hh*3600 + mm*60
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
;Acelerografo.c,104 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,105 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,106 :: 		contFIFO = 0;
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,107 :: 		numFIFO = 0;
	MOV	#lo_addr(_numFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,108 :: 		numSetsFIFO = 0;
	MOV	#lo_addr(_numSetsFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,109 :: 		contTimer1 = 0;
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,111 :: 		byteGPS = 0;
	MOV	#lo_addr(_byteGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,113 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,114 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,116 :: 		puntero_8 = &auxiliar;
	MOV	#lo_addr(_auxiliar), W0
	MOV	W0, _puntero_8
;Acelerografo.c,118 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,120 :: 		banInicio = 0;
	MOV	#lo_addr(_banInicio), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,121 :: 		U1RXIE_bit = 1;                                                            //Habilita la interrupcion por UARTRx
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,122 :: 		INT1IE_bit = 1;
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,124 :: 		while(1){
L_main12:
;Acelerografo.c,126 :: 		Delay_ms(500);
	MOV	#62, W8
	MOV	#2340, W7
L_main14:
	DEC	W7
	BRA NZ	L_main14
	DEC	W8
	BRA NZ	L_main14
	NOP
	NOP
;Acelerografo.c,128 :: 		}
	GOTO	L_main12
;Acelerografo.c,130 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main

_ConfiguracionPrincipal:

;Acelerografo.c,139 :: 		void ConfiguracionPrincipal(){
;Acelerografo.c,142 :: 		CLKDIVbits.FRCDIV = 0;                                                     //FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,143 :: 		CLKDIVbits.PLLPOST = 0;                                                    //N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,144 :: 		CLKDIVbits.PLLPRE = 5;                                                     //N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,145 :: 		PLLFBDbits.PLLDIV = 150;                                                   //M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,148 :: 		ANSELA = 0;                                                                //Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,149 :: 		ANSELB = 0;                                                                //Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,150 :: 		TRISA3_bit = 0;                                                            //Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,151 :: 		TRISA4_bit = 0;                                                            //Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,152 :: 		TRISB4_bit = 0;                                                            //Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,153 :: 		TRISB10_bit = 1;                                                           //Configura el pin B10 como entrada *
	BSET	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,154 :: 		TRISB11_bit = 1;                                                           //Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,155 :: 		TRISB12_bit = 1;                                                           //Configura el pin B12 como entrada *
	BSET	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,156 :: 		TRISB13_bit = 1;                                                           //Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,158 :: 		INTCON2.GIE = 1;                                                           //Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,161 :: 		RPINR18bits.U1RXR = 0x22;                                                  //Configura el pin RB2/RPI34 como Rx1 *
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
;Acelerografo.c,162 :: 		RPOR0bits.RP35R = 0x01;                                                    //Configura el Tx1 en el pin RB3/RP35 *
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR0bits
;Acelerografo.c,163 :: 		UART1_Init(9600);                                                          //Inicializa el UART1 con una velocidad de 9600 baudios
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;Acelerografo.c,164 :: 		U1RXIE_bit = 1;                                                            //Habilita la interrupcion por UART1 RX *
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,165 :: 		U1RXIF_bit = 0;                                                            //Limpia la bandera de interrupcion por UART1 RX *
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,166 :: 		IPC2bits.U1RXIP = 0x04;                                                    //Prioridad de la interrupcion UART1 RX
	MOV	#16384, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,169 :: 		SPI1STAT.SPIEN = 1;                                                        //Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,170 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
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
;Acelerografo.c,171 :: 		SPI1IE_bit = 1;                                                            //Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,172 :: 		SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,173 :: 		IPC2bits.SPI1IP = 0x03;                                                    //Prioridad de la interrupcion SPI1
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,176 :: 		RPINR22bits.SDI2R = 0x21;                                                  //Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,177 :: 		RPOR2bits.RP38R = 0x08;                                                    //Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,178 :: 		RPOR1bits.RP37R = 0x09;                                                    //Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,179 :: 		SPI2STAT.SPIEN = 1;                                                        //Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,180 :: 		SPI2_Init();                                                               //Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,183 :: 		RPINR0 = 0x2E00;                                                           //Asigna INT1 al RB14/RPI46
	MOV	#11776, W0
	MOV	WREG, RPINR0
;Acelerografo.c,184 :: 		INT1IE_bit = 0;                                                            //Habilita la interrupcion externa INT1
	BCLR	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,185 :: 		INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,186 :: 		IPC5bits.INT1IP = 0x01;                                                    //Prioridad en la interrupocion externa 1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,189 :: 		T1CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T1CON
;Acelerografo.c,190 :: 		T1CON.TON = 0;                                                             //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,191 :: 		T1IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,192 :: 		T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,193 :: 		PR1 = 62500;                                                               //Car ga el preload para un tiempo de 100ms
	MOV	#62500, W0
	MOV	WREG, PR1
;Acelerografo.c,194 :: 		IPC0bits.T1IP = 0x02;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,197 :: 		T2CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T2CON
;Acelerografo.c,198 :: 		T2CON.TON = 0;                                                             //Apaga el Timer2
	BCLR	T2CON, #15
;Acelerografo.c,199 :: 		T2IE_bit = 1;                                                              //Habilita la interrupción de desbordamiento TMR2
	BSET	T2IE_bit, BitPos(T2IE_bit+0)
;Acelerografo.c,200 :: 		T2IF_bit = 0;                                                              //Limpia la bandera de interrupcion del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,201 :: 		PR2 = 46875;                                                               //Carga el preload para un tiempo de 75ms
	MOV	#46875, W0
	MOV	WREG, PR2
;Acelerografo.c,202 :: 		IPC1bits.T2IP = 0x05;                                                      //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;Acelerografo.c,204 :: 		ADXL355_init();
	CALL	_ADXL355_init
;Acelerografo.c,206 :: 		Delay_ms(200);                                                             //Espera hasta que se estabilicen los cambios
	MOV	#25, W8
	MOV	#27150, W7
L_ConfiguracionPrincipal16:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal16
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal16
	NOP
;Acelerografo.c,208 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_Muestrear:

;Acelerografo.c,213 :: 		void Muestrear(){
;Acelerografo.c,215 :: 		if (banCiclo==0){
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Muestrear150
	GOTO	L_Muestrear18
L__Muestrear150:
;Acelerografo.c,217 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);                   //Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,219 :: 		} else {
	GOTO	L_Muestrear19
L_Muestrear18:
;Acelerografo.c,221 :: 		banCiclo = 0;                                                      //Limpia la bandera de ciclo completo
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,223 :: 		tramaCompleta[0] = contCiclos;                                     //LLena el primer elemento de la tramaCompleta con el contador de ciclos
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_contCiclos), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,224 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,225 :: 		numSetsFIFO = (numFIFO)/3;                                         //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,228 :: 		for (x=0;x<numSetsFIFO;x++){
	CLR	W0
	MOV	W0, _x
L_Muestrear20:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Muestrear151
	GOTO	L_Muestrear21
L__Muestrear151:
;Acelerografo.c,229 :: 		ADXL355_read_FIFO(datosLeidos);                                //Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,230 :: 		for (y=0;y<9;y++){
	CLR	W0
	MOV	W0, _y
L_Muestrear23:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Muestrear152
	GOTO	L_Muestrear24
L__Muestrear152:
;Acelerografo.c,231 :: 		datosFIFO[y+(x*9)] = datosLeidos[y];                       //LLena la trama datosFIFO
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
;Acelerografo.c,230 :: 		for (y=0;y<9;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,232 :: 		}
	GOTO	L_Muestrear23
L_Muestrear24:
;Acelerografo.c,228 :: 		for (x=0;x<numSetsFIFO;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,233 :: 		}
	GOTO	L_Muestrear20
L_Muestrear21:
;Acelerografo.c,236 :: 		for (x=0;x<(numSetsFIFO*9);x++){
	CLR	W0
	MOV	W0, _x
L_Muestrear26:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Muestrear153
	GOTO	L_Muestrear27
L__Muestrear153:
;Acelerografo.c,237 :: 		if ((x==0)||(x%9==0)){
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Muestrear154
	GOTO	L__Muestrear105
L__Muestrear154:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Muestrear155
	GOTO	L__Muestrear104
L__Muestrear155:
	GOTO	L_Muestrear31
L__Muestrear105:
L__Muestrear104:
;Acelerografo.c,238 :: 		tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
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
;Acelerografo.c,239 :: 		tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
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
;Acelerografo.c,240 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,241 :: 		} else {
	GOTO	L_Muestrear32
L_Muestrear31:
;Acelerografo.c,242 :: 		tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
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
;Acelerografo.c,243 :: 		}
L_Muestrear32:
;Acelerografo.c,236 :: 		for (x=0;x<(numSetsFIFO*9);x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,244 :: 		}
	GOTO	L_Muestrear26
L_Muestrear27:
;Acelerografo.c,247 :: 		AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_tiempoSistema, W10
	MOV	_tiempoSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,248 :: 		for (x=0;x<6;x++){
	CLR	W0
	MOV	W0, _x
L_Muestrear33:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__Muestrear156
	GOTO	L_Muestrear34
L__Muestrear156:
;Acelerografo.c,249 :: 		tramaCompleta[2500+x] = tiempo[x];
	MOV	#2500, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,248 :: 		for (x=0;x<6;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,250 :: 		}
	GOTO	L_Muestrear33
L_Muestrear34:
;Acelerografo.c,252 :: 		banTI = 1;                                                         //Activa la bandera de inicio de trama para permitir el envio de la trama por SPI
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,253 :: 		RP1 = 1;                                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,254 :: 		Delay_us(20);
	MOV	#160, W7
L_Muestrear36:
	DEC	W7
	BRA NZ	L_Muestrear36
	NOP
	NOP
;Acelerografo.c,255 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,257 :: 		}
L_Muestrear19:
;Acelerografo.c,259 :: 		contCiclos++;                                                          //Incrementa el contador de ciclos
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,260 :: 		contMuestras = 0;                                                      //Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,261 :: 		contFIFO = 0;                                                          //Limpia el contador de FIFOs
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,263 :: 		if (ADXL355_read_byte(POWER_CTL)&0x01==1){
	MOV.B	#45, W10
	CALL	_ADXL355_read_byte
	BTSS	W0, #0
	GOTO	L_Muestrear38
;Acelerografo.c,264 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|MEASURING);                  //Coloca el ADXL en modo medicion
	MOV.B	#4, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,265 :: 		}
L_Muestrear38:
;Acelerografo.c,267 :: 		T1CON.TON = 1;                                                         //Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,269 :: 		}
L_end_Muestrear:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Muestrear

_ConfigurarGPS:

;Acelerografo.c,275 :: 		void ConfigurarGPS(){
;Acelerografo.c,276 :: 		UART1_Write_Text("$PMTK605*31\r\n");
	PUSH	W10
	PUSH	W11
	MOV	#lo_addr(?lstr1_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,277 :: 		UART1_Write_Text("$PMTK220,1000*1F\r\n");
	MOV	#lo_addr(?lstr2_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,278 :: 		UART1_Write_Text("$PMTK251,115200*1F\r\n");
	MOV	#lo_addr(?lstr3_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,279 :: 		Delay_ms(1000);                                                            //Tiempo necesario para que se de efecto el cambio de configuracion
	MOV	#123, W8
	MOV	#4681, W7
L_ConfigurarGPS39:
	DEC	W7
	BRA NZ	L_ConfigurarGPS39
	DEC	W8
	BRA NZ	L_ConfigurarGPS39
;Acelerografo.c,280 :: 		UART1_Init(115200);
	MOV	#49664, W10
	MOV	#1, W11
	CALL	_UART1_Init
;Acelerografo.c,281 :: 		UART1_Write_Text("$PMTK313,1*2E\r\n");
	MOV	#lo_addr(?lstr4_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,282 :: 		UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n");
	MOV	#lo_addr(?lstr5_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,283 :: 		UART1_Write_Text("$PMTK319,1*24\r\n");
	MOV	#lo_addr(?lstr6_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,284 :: 		UART1_Write_Text("$PMTK413*34\r\n");
	MOV	#lo_addr(?lstr7_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,285 :: 		UART1_Write_Text("$PMTK513,1*28\r\n");
	MOV	#lo_addr(?lstr8_Acelerografo), W10
	CALL	_UART1_Write_Text
;Acelerografo.c,286 :: 		Delay_ms(1000);
	MOV	#123, W8
	MOV	#4681, W7
L_ConfigurarGPS41:
	DEC	W7
	BRA NZ	L_ConfigurarGPS41
	DEC	W8
	BRA NZ	L_ConfigurarGPS41
;Acelerografo.c,287 :: 		}
L_end_ConfigurarGPS:
	POP	W11
	POP	W10
	RETURN
; end of _ConfigurarGPS

_RecuperarFechaGPS:
	LNK	#12

;Acelerografo.c,292 :: 		unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS){
;Acelerografo.c,297 :: 		char *ptrDatoStringF = &datoStringF;
	ADD	W14, #8, W2
;Acelerografo.c,298 :: 		datoStringF[2] = '\0';
	ADD	W2, #2, W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,299 :: 		tramaFecha[3] = '\0';
	ADD	W14, #0, W4
	ADD	W4, #6, W1
	CLR	W0
	MOV	W0, [W1]
;Acelerografo.c,304 :: 		datoStringF[0] = '1';
	MOV.B	#49, W0
	MOV.B	W0, [W2]
;Acelerografo.c,305 :: 		datoStringF[1] = '7';
	ADD	W2, #1, W1
	MOV.B	#55, W0
	MOV.B	W0, [W1]
;Acelerografo.c,307 :: 		tramaFecha[0] =  17;
	MOV	#17, W0
	MOV	W0, [W4]
;Acelerografo.c,312 :: 		datoStringF[0] = '0';
	MOV.B	#48, W0
	MOV.B	W0, [W2]
;Acelerografo.c,313 :: 		datoStringF[1] = '6';
	ADD	W2, #1, W1
	MOV.B	#54, W0
	MOV.B	W0, [W1]
;Acelerografo.c,315 :: 		tramaFecha[1] = 6;
	ADD	W4, #2, W1
	MOV	#6, W0
	MOV	W0, [W1]
;Acelerografo.c,320 :: 		datoStringF[0] = '1';
	MOV.B	#49, W0
	MOV.B	W0, [W2]
;Acelerografo.c,321 :: 		datoStringF[1] = '9';
	ADD	W2, #1, W1
	MOV.B	#57, W0
	MOV.B	W0, [W1]
;Acelerografo.c,323 :: 		tramaFecha[2] = 0;
	ADD	W4, #4, W1
	CLR	W0
	MOV	W0, [W1]
;Acelerografo.c,326 :: 		fechaGPS = (tramaFecha[0]*3600)+(tramaFecha[1]*60)+(tramaFecha[2]);
	MOV	[W4], W1
	MOV	#3600, W0
	MUL.UU	W1, W0, W2
	ADD	W4, #2, W1
	MOV	#60, W0
	MUL.UU	W0, [W1], W0
	ADD	W2, W0, W1
	ADD	W4, #4, W0
	ADD	W1, [W0], W0
; fechaGPS start address is: 4 (W2)
	MOV	W0, W2
	CLR	W3
;Acelerografo.c,328 :: 		return fechaGPS;
	MOV.D	W2, W0
; fechaGPS end address is: 4 (W2)
;Acelerografo.c,330 :: 		}
L_end_RecuperarFechaGPS:
	ULNK
	RETURN
; end of _RecuperarFechaGPS

_AjustarTiempoSistema:
	LNK	#14

;Acelerografo.c,376 :: 		void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema){
	MOV	[W14-8], W0
	MOV	W0, [W14-8]
;Acelerografo.c,385 :: 		hora = longHora / 3600;
	PUSH.D	W12
	PUSH.D	W10
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
	MOV.B	W0, [W14+0]
;Acelerografo.c,386 :: 		minuto = (longHora%3600) / 60;
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Modulus_32x32
	MOV	W0, [W14+10]
	MOV	W1, [W14+12]
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Divide_32x32
	MOV.B	W0, [W14+1]
;Acelerografo.c,387 :: 		segundo = (longHora%3600) % 60;
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W12
	MOV.B	W0, [W14+2]
;Acelerografo.c,389 :: 		dia = longFecha / 10000;
	PUSH.D	W12
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W12
	MOV.B	W0, [W14+3]
;Acelerografo.c,390 :: 		mes = (longFecha%10000) / 100;
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Modulus_32x32
	MOV	W0, [W14+10]
	MOV	W1, [W14+12]
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Divide_32x32
	MOV.B	W0, [W14+4]
;Acelerografo.c,391 :: 		anio = (longFecha%10000) % 100;
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
; anio start address is: 4 (W2)
	MOV.B	W0, W2
;Acelerografo.c,393 :: 		tramaTiempoSistema[0] = hora;
	MOV	[W14-8], W1
	MOV.B	[W14+0], W0
	MOV.B	W0, [W1]
;Acelerografo.c,394 :: 		tramaTiempoSistema[1] = minuto;
	MOV	[W14-8], W0
	ADD	W0, #1, W1
	MOV.B	[W14+1], W0
	MOV.B	W0, [W1]
;Acelerografo.c,395 :: 		tramaTiempoSistema[2] = segundo;
	MOV	[W14-8], W0
	ADD	W0, #2, W1
	MOV.B	[W14+2], W0
	MOV.B	W0, [W1]
;Acelerografo.c,396 :: 		tramaTiempoSistema[3] = dia;
	MOV	[W14-8], W0
	ADD	W0, #3, W1
	MOV.B	[W14+3], W0
	MOV.B	W0, [W1]
;Acelerografo.c,397 :: 		tramaTiempoSistema[4] = mes;
	MOV	[W14-8], W0
	ADD	W0, #4, W1
	MOV.B	[W14+4], W0
	MOV.B	W0, [W1]
;Acelerografo.c,398 :: 		tramaTiempoSistema[5] = anio;
	MOV	[W14-8], W0
	ADD	W0, #5, W0
	MOV.B	W2, [W0]
; anio end address is: 4 (W2)
;Acelerografo.c,400 :: 		banSetReloj = 1;                                                           //Cambia el estado de la bandera cuando ha terminado de configurar el reloj
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,402 :: 		}
L_end_AjustarTiempoSistema:
	ULNK
	RETURN
; end of _AjustarTiempoSistema

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,411 :: 		void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
;Acelerografo.c,413 :: 		SPI1IF_bit = 0;                                                            //Limpia la bandera de interrupcion por SPI
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,414 :: 		buffer = SPI1BUF;                                                          //Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,417 :: 		if ((buffer==0xA0)&&(banMuestrear==0)){
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#160, W0
	CP.B	W1, W0
	BRA Z	L__spi_1161
	GOTO	L__spi_1112
L__spi_1161:
	MOV	#lo_addr(_banMuestrear), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1162
	GOTO	L__spi_1111
L__spi_1162:
L__spi_1110:
;Acelerografo.c,418 :: 		banInicio = 2;
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,417 :: 		if ((buffer==0xA0)&&(banMuestrear==0)){
L__spi_1112:
L__spi_1111:
;Acelerografo.c,423 :: 		if ((buffer==0xB0)&&(banLeer==0)){
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#176, W0
	CP.B	W1, W0
	BRA Z	L__spi_1163
	GOTO	L__spi_1114
L__spi_1163:
	MOV	#lo_addr(_banLeer), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1164
	GOTO	L__spi_1113
L__spi_1164:
L__spi_1109:
;Acelerografo.c,424 :: 		banLeer = 1;
	MOV	#lo_addr(_banLeer), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,425 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,423 :: 		if ((buffer==0xB0)&&(banLeer==0)){
L__spi_1114:
L__spi_1113:
;Acelerografo.c,427 :: 		if ((banLeer==1)&&(buffer!=0xB0)&&(buffer!=0xBF)){
	MOV	#lo_addr(_banLeer), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1165
	GOTO	L__spi_1117
L__spi_1165:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#176, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1166
	GOTO	L__spi_1116
L__spi_1166:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#191, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1167
	GOTO	L__spi_1115
L__spi_1167:
L__spi_1108:
;Acelerografo.c,428 :: 		SPI1BUF = tiempo[i];
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,429 :: 		i++;
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,427 :: 		if ((banLeer==1)&&(buffer!=0xB0)&&(buffer!=0xBF)){
L__spi_1117:
L__spi_1116:
L__spi_1115:
;Acelerografo.c,431 :: 		if ((banLeer==1)&&(buffer==0xBF)){
	MOV	#lo_addr(_banLeer), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1168
	GOTO	L__spi_1119
L__spi_1168:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#191, W0
	CP.B	W1, W0
	BRA Z	L__spi_1169
	GOTO	L__spi_1118
L__spi_1169:
L__spi_1107:
;Acelerografo.c,432 :: 		banLeer = 0;
	MOV	#lo_addr(_banLeer), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,431 :: 		if ((banLeer==1)&&(buffer==0xBF)){
L__spi_1119:
L__spi_1118:
;Acelerografo.c,436 :: 		if ((buffer==0xC0)&&(banConf==0)){
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#192, W0
	CP.B	W1, W0
	BRA Z	L__spi_1170
	GOTO	L__spi_1121
L__spi_1170:
	MOV	#lo_addr(_banConf), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1171
	GOTO	L__spi_1120
L__spi_1171:
L__spi_1106:
L__spi_1121:
L__spi_1120:
;Acelerografo.c,456 :: 		}
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

_int_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,461 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT {
;Acelerografo.c,463 :: 		INT1IF_bit = 0;                                                            //Limpia la bandera de interrupcion externa INT1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,465 :: 		AjustarTiempoSistema(tiempoSistema, fechaSistema, tiempo);
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_tiempoSistema, W10
	MOV	_tiempoSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,466 :: 		RP1 = 1;                                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,467 :: 		Delay_us(20);
	MOV	#160, W7
L_int_158:
	DEC	W7
	BRA NZ	L_int_158
	NOP
	NOP
;Acelerografo.c,468 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,470 :: 		if (tiempoSistema==segundoDeAjuste){
	MOV	_tiempoSistema, W1
	MOV	_tiempoSistema+2, W2
	MOV	#lo_addr(_segundoDeAjuste), W0
	CP	W1, [W0++]
	CPB	W2, [W0--]
	BRA Z	L__int_1173
	GOTO	L_int_160
L__int_1173:
;Acelerografo.c,471 :: 		U1RXIE_bit = 1;                                                         //Enciende la interrupcion por UARTRx para igualar el tiempo del sistema con el GPS
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,472 :: 		} else {
	GOTO	L_int_161
L_int_160:
;Acelerografo.c,473 :: 		tiempoSistema++;                                                        //Si el reloj esta igualado incrementa la cuenta del segundo
	MOV	#1, W1
	MOV	#0, W2
	MOV	#lo_addr(_tiempoSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,474 :: 		}
L_int_161:
;Acelerografo.c,478 :: 		if (banInicio==1){
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1174
	GOTO	L_int_162
L__int_1174:
;Acelerografo.c,482 :: 		}
L_int_162:
;Acelerografo.c,484 :: 		}
L_end_int_1:
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
; end of _int_1

_Timer1Int:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,488 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT{
;Acelerografo.c,490 :: 		T1IF_bit = 0;                                                              //Limpia la bandera de interrupcion por desbordamiento del Timer1
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,492 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES); //75                            //Lee el numero de muestras disponibles en el FIFO
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,494 :: 		numSetsFIFO = (numFIFO)/3;                 //25                            //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,498 :: 		for (x=0;x<numSetsFIFO;x++){
	CLR	W0
	MOV	W0, _x
L_Timer1Int63:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Timer1Int176
	GOTO	L_Timer1Int64
L__Timer1Int176:
;Acelerografo.c,499 :: 		ADXL355_read_FIFO(datosLeidos);                                        //Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,500 :: 		for (y=0;y<9;y++){
	CLR	W0
	MOV	W0, _y
L_Timer1Int66:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Timer1Int177
	GOTO	L_Timer1Int67
L__Timer1Int177:
;Acelerografo.c,501 :: 		datosFIFO[y+(x*9)] = datosLeidos[y];                               //LLena la trama datosFIFO
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
;Acelerografo.c,500 :: 		for (y=0;y<9;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,502 :: 		}
	GOTO	L_Timer1Int66
L_Timer1Int67:
;Acelerografo.c,498 :: 		for (x=0;x<numSetsFIFO;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,503 :: 		}
	GOTO	L_Timer1Int63
L_Timer1Int64:
;Acelerografo.c,506 :: 		for (x=0;x<(numSetsFIFO*9);x++){      //0-224
	CLR	W0
	MOV	W0, _x
L_Timer1Int69:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Timer1Int178
	GOTO	L_Timer1Int70
L__Timer1Int178:
;Acelerografo.c,507 :: 		if ((x==0)||(x%9==0)){
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int179
	GOTO	L__Timer1Int124
L__Timer1Int179:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int180
	GOTO	L__Timer1Int123
L__Timer1Int180:
	GOTO	L_Timer1Int74
L__Timer1Int124:
L__Timer1Int123:
;Acelerografo.c,508 :: 		tramaCompleta[contFIFO+contMuestras+x] = contMuestras;
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
;Acelerografo.c,510 :: 		tramaCompleta[contFIFO+contMuestras+x+1] = datosFIFO[x];
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
;Acelerografo.c,511 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,512 :: 		} else {
	GOTO	L_Timer1Int75
L_Timer1Int74:
;Acelerografo.c,513 :: 		tramaCompleta[contFIFO+contMuestras+x] = datosFIFO[x];
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
;Acelerografo.c,514 :: 		}
L_Timer1Int75:
;Acelerografo.c,506 :: 		for (x=0;x<(numSetsFIFO*9);x++){      //0-224
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,515 :: 		}
	GOTO	L_Timer1Int69
L_Timer1Int70:
;Acelerografo.c,517 :: 		contFIFO = (contMuestras*9);                                               //Incrementa el contador de FIFOs
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	MOV	W0, _contFIFO
;Acelerografo.c,519 :: 		contTimer1++;                                                              //Incrementa una unidad cada vez que entra a la interrupcion por Timer1
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,521 :: 		if (contTimer1==9){                                                        //Verifica si se recibio los 5 FIFOS
	MOV	#lo_addr(_contTimer1), W0
	MOV.B	[W0], W0
	CP.B	W0, #9
	BRA Z	L__Timer1Int181
	GOTO	L_Timer1Int76
L__Timer1Int181:
;Acelerografo.c,522 :: 		T1CON.TON = 0;                                                          //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,523 :: 		banCiclo = 1;                                                           //Activa la bandera que indica que se completo un ciclo de medicion
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,524 :: 		contTimer1 = 0;                                                         //Limpia el contador de interrupciones por Timer1
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,525 :: 		}
L_Timer1Int76:
;Acelerografo.c,529 :: 		}
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

;Acelerografo.c,533 :: 		void Timer2Int() org IVT_ADDR_T2INTERRUPT{
;Acelerografo.c,535 :: 		T2IF_bit = 0;
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,537 :: 		}
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

_urx_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,542 :: 		void urx_1() org  IVT_ADDR_U1RXINTERRUPT {
;Acelerografo.c,544 :: 		U1RXIF_bit = 0;
	PUSH	W10
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,545 :: 		byteGPS = UART1_Read();                                                    //Lee el byte de la trama enviada por el GPS
	CALL	_UART1_Read
	MOV	#lo_addr(_byteGPS), W1
	MOV.B	W0, [W1]
;Acelerografo.c,547 :: 		if (banTIGPS==0){
	MOV	#lo_addr(_banTIGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__urx_1184
	GOTO	L_urx_177
L__urx_1184:
;Acelerografo.c,548 :: 		if ((byteGPS==0x24)&&(i_gps==0)){                                       //Verifica si el primer byte recibido es el simbolo "$" que indica el inicio de una trama GPS
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#36, W0
	CP.B	W1, W0
	BRA Z	L__urx_1185
	GOTO	L__urx_1129
L__urx_1185:
	MOV	_i_gps, W0
	CP	W0, #0
	BRA Z	L__urx_1186
	GOTO	L__urx_1128
L__urx_1186:
L__urx_1127:
;Acelerografo.c,549 :: 		banTIGPS = 1;                                                        //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTIGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,550 :: 		i_gps = 0;                                                           //Limpia el subindice de la trama GPS
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,548 :: 		if ((byteGPS==0x24)&&(i_gps==0)){                                       //Verifica si el primer byte recibido es el simbolo "$" que indica el inicio de una trama GPS
L__urx_1129:
L__urx_1128:
;Acelerografo.c,552 :: 		}
L_urx_177:
;Acelerografo.c,554 :: 		if (banTIGPS==1){
	MOV	#lo_addr(_banTIGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1187
	GOTO	L_urx_181
L__urx_1187:
;Acelerografo.c,555 :: 		if (byteGPS!=0x2A){                                                     //0x2A = "*"
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#42, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1188
	GOTO	L_urx_182
L__urx_1188:
;Acelerografo.c,556 :: 		tramaGPS[i_gps] = byteGPS;                                           //LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,557 :: 		banTFGPS = 0;                                                        //Limpia la bandera de final de trama
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,558 :: 		if (i_gps<70){
	MOV	#70, W1
	MOV	#lo_addr(_i_gps), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1189
	GOTO	L_urx_183
L__urx_1189:
;Acelerografo.c,559 :: 		i_gps++;                                                          //Incrementa el valor del subindice mientras sea menor a 70
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,560 :: 		}
L_urx_183:
;Acelerografo.c,561 :: 		if ((i_gps>1)&&(tramaGPS[1]!=0x47)){                                 //Verifica si el segundo elemento guardado es diferente de G
	MOV	_i_gps, W0
	CP	W0, #1
	BRA GTU	L__urx_1190
	GOTO	L__urx_1131
L__urx_1190:
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1191
	GOTO	L__urx_1130
L__urx_1191:
L__urx_1126:
;Acelerografo.c,562 :: 		i_gps = 0;                                                        //Limpia el subindice para almacenar la trama desde el principio
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,563 :: 		banTIGPS = 0;                                                     //Limpia la bandera de inicio de trama
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,564 :: 		banTCGPS = 0;                                                     //Limpia la bandera de trama completa
	MOV	#lo_addr(_banTCGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,561 :: 		if ((i_gps>1)&&(tramaGPS[1]!=0x47)){                                 //Verifica si el segundo elemento guardado es diferente de G
L__urx_1131:
L__urx_1130:
;Acelerografo.c,566 :: 		} else {
	GOTO	L_urx_187
L_urx_182:
;Acelerografo.c,567 :: 		tramaGPS[i_gps] = byteGPS;
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,568 :: 		banTFGPS = 1;                                                        //Activa la bandera de final de trama GPS
	MOV	#lo_addr(_banTFGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,569 :: 		}
L_urx_187:
;Acelerografo.c,570 :: 		if (banTFGPS==1){
	MOV	#lo_addr(_banTFGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1192
	GOTO	L_urx_188
L__urx_1192:
;Acelerografo.c,571 :: 		banTIGPS = 0;                                                        //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,572 :: 		banTCGPS = 1;                                                        //Activa la bandera de trama completa
	MOV	#lo_addr(_banTCGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,573 :: 		}
L_urx_188:
;Acelerografo.c,574 :: 		}
L_urx_181:
;Acelerografo.c,576 :: 		if (banTCGPS==1){
	MOV	#lo_addr(_banTCGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1193
	GOTO	L_urx_189
L__urx_1193:
;Acelerografo.c,577 :: 		if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){      //"GPRMC" y "A"
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA Z	L__urx_1194
	GOTO	L__urx_1137
L__urx_1194:
	MOV	#lo_addr(_tramaGPS+2), W0
	MOV.B	[W0], W1
	MOV.B	#80, W0
	CP.B	W1, W0
	BRA Z	L__urx_1195
	GOTO	L__urx_1136
L__urx_1195:
	MOV	#lo_addr(_tramaGPS+3), W0
	MOV.B	[W0], W1
	MOV.B	#82, W0
	CP.B	W1, W0
	BRA Z	L__urx_1196
	GOTO	L__urx_1135
L__urx_1196:
	MOV	#lo_addr(_tramaGPS+4), W0
	MOV.B	[W0], W1
	MOV.B	#77, W0
	CP.B	W1, W0
	BRA Z	L__urx_1197
	GOTO	L__urx_1134
L__urx_1197:
	MOV	#lo_addr(_tramaGPS+5), W0
	MOV.B	[W0], W1
	MOV.B	#67, W0
	CP.B	W1, W0
	BRA Z	L__urx_1198
	GOTO	L__urx_1133
L__urx_1198:
	MOV	#lo_addr(_tramaGPS+18), W0
	MOV.B	[W0], W1
	MOV.B	#65, W0
	CP.B	W1, W0
	BRA Z	L__urx_1199
	GOTO	L__urx_1132
L__urx_1199:
L__urx_1125:
;Acelerografo.c,578 :: 		for (x=0;x<6;x++){
	CLR	W0
	MOV	W0, _x
L_urx_193:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__urx_1200
	GOTO	L_urx_194
L__urx_1200:
;Acelerografo.c,579 :: 		datosGPS[x] = tramaGPS[7+x];                                     //Guarda los datos de hhmmss
	MOV	#lo_addr(_datosGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W2
	MOV	_x, W0
	ADD	W0, #7, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,578 :: 		for (x=0;x<6;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,580 :: 		}
	GOTO	L_urx_193
L_urx_194:
;Acelerografo.c,581 :: 		for (x=50;x<60;x++){
	MOV	#50, W0
	MOV	W0, _x
L_urx_196:
	MOV	#60, W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1201
	GOTO	L_urx_197
L__urx_1201:
;Acelerografo.c,582 :: 		if (tramaGPS[x]==0x2C){                                          //Busca el simbolo "," a partir de la posicion 50
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W1
	MOV.B	#44, W0
	CP.B	W1, W0
	BRA Z	L__urx_1202
	GOTO	L_urx_199
L__urx_1202:
;Acelerografo.c,583 :: 		for (y=0;y<6;y++){
	CLR	W0
	MOV	W0, _y
L_urx_1100:
	MOV	_y, W0
	CP	W0, #6
	BRA LTU	L__urx_1203
	GOTO	L_urx_1101
L__urx_1203:
;Acelerografo.c,584 :: 		datosGPS[6+y] = tramaGPS[x+y+1];                         //Guarda los datos de DDMMAA en la trama datosGPS
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
;Acelerografo.c,583 :: 		for (y=0;y<6;y++){
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,585 :: 		}
	GOTO	L_urx_1100
L_urx_1101:
;Acelerografo.c,586 :: 		}
L_urx_199:
;Acelerografo.c,581 :: 		for (x=50;x<60;x++){
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,587 :: 		}
	GOTO	L_urx_196
L_urx_197:
;Acelerografo.c,588 :: 		banSetGPS = 1;                                                       //Activa esta bandera si se logro recuperar la hora del GPS;
	MOV	#lo_addr(_banSetGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,590 :: 		datosGPS[0] = '1';
	MOV	#lo_addr(_datosGPS), W1
	MOV.B	#49, W0
	MOV.B	W0, [W1]
;Acelerografo.c,591 :: 		datosGPS[1] = '7';
	MOV	#lo_addr(_datosGPS+1), W1
	MOV.B	#55, W0
	MOV.B	W0, [W1]
;Acelerografo.c,592 :: 		datosGPS[2] = '2';
	MOV	#lo_addr(_datosGPS+2), W1
	MOV.B	#50, W0
	MOV.B	W0, [W1]
;Acelerografo.c,593 :: 		datosGPS[3] = '4';
	MOV	#lo_addr(_datosGPS+3), W1
	MOV.B	#52, W0
	MOV.B	W0, [W1]
;Acelerografo.c,594 :: 		datosGPS[4] = '0';
	MOV	#lo_addr(_datosGPS+4), W1
	MOV.B	#48, W0
	MOV.B	W0, [W1]
;Acelerografo.c,595 :: 		datosGPS[5] = '0';
	MOV	#lo_addr(_datosGPS+5), W1
	MOV.B	#48, W0
	MOV.B	W0, [W1]
;Acelerografo.c,597 :: 		datosGPS[6] = '2';
	MOV	#lo_addr(_datosGPS+6), W1
	MOV.B	#50, W0
	MOV.B	W0, [W1]
;Acelerografo.c,598 :: 		datosGPS[7] = '6';
	MOV	#lo_addr(_datosGPS+7), W1
	MOV.B	#54, W0
	MOV.B	W0, [W1]
;Acelerografo.c,599 :: 		datosGPS[8] = '0';
	MOV	#lo_addr(_datosGPS+8), W1
	MOV.B	#48, W0
	MOV.B	W0, [W1]
;Acelerografo.c,600 :: 		datosGPS[9] = '6';
	MOV	#lo_addr(_datosGPS+9), W1
	MOV.B	#54, W0
	MOV.B	W0, [W1]
;Acelerografo.c,601 :: 		datosGPS[10] = '1';
	MOV	#lo_addr(_datosGPS+10), W1
	MOV.B	#49, W0
	MOV.B	W0, [W1]
;Acelerografo.c,602 :: 		datosGPS[11] = '9';
	MOV	#lo_addr(_datosGPS+11), W1
	MOV.B	#57, W0
	MOV.B	W0, [W1]
;Acelerografo.c,603 :: 		datosGPS[12] = '\0';
	MOV	#lo_addr(_datosGPS+12), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,605 :: 		tiempoSistema = RecuperarFechaGPS(datosGPS);
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarFechaGPS
	MOV	W0, _tiempoSistema
	MOV	W1, _tiempoSistema+2
;Acelerografo.c,606 :: 		fechaSistema = RecuperarFechaGPS(datosGPS);
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarFechaGPS
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,611 :: 		U1RXIE_bit = 0;                                                      //Apaga la interrupcion por UARTRx
	BCLR	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,577 :: 		if ( tramaGPS[1]==0x47 && tramaGPS[2]==0x50 && tramaGPS[3]==0x52 && tramaGPS[4]==0x4D && tramaGPS[5]==0x43 && tramaGPS[18]==0x41 ){      //"GPRMC" y "A"
L__urx_1137:
L__urx_1136:
L__urx_1135:
L__urx_1134:
L__urx_1133:
L__urx_1132:
;Acelerografo.c,616 :: 		i_gps = 0;                                                              //Limpia el subindice para almacenar la trama desde el principio
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,617 :: 		banTIGPS = 0;                                                           //Limpia la bandera de inicio de trama
	MOV	#lo_addr(_banTIGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,618 :: 		banTCGPS = 0;                                                           //Limpia la bandera de trama completa
	MOV	#lo_addr(_banTCGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,619 :: 		}
L_urx_189:
;Acelerografo.c,621 :: 		}
L_end_urx_1:
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
