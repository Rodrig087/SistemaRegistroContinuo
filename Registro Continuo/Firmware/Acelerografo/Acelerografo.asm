
_ADXL355_init:

;adxl355_spi.c,104 :: 		void ADXL355_init(){
;adxl355_spi.c,105 :: 		ADXL355_write_byte(Reset, 0x52);
	PUSH	W10
	PUSH	W11
	MOV.B	#82, W11
	MOV.B	#47, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,106 :: 		ADXL355_write_byte(0x2D, 0x01);
	MOV.B	#1, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,107 :: 		ADXL355_write_byte(Status, 0xFF);
	MOV.B	#255, W11
	MOV.B	#4, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,109 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|TEMP_OFF|MEASURING);
	MOV.B	#6, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,110 :: 		ADXL355_write_byte(Range, INT_ACTIVE_HIGH |_2G);
	MOV.B	#1, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,111 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_62_5_Hz);
	MOV.B	#4, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,113 :: 		ADXL355_write_byte(FIFO_SAMPLES, 0x02);
	MOV.B	#2, W11
	MOV.B	#41, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,114 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;adxl355_spi.c,117 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;adxl355_spi.c,118 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;adxl355_spi.c,119 :: 		CS_ADXL355 = 0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,120 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,121 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;adxl355_spi.c,122 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,123 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;adxl355_spi.c,126 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;adxl355_spi.c,127 :: 		unsigned char value = 0x00;
	PUSH	W10
;adxl355_spi.c,128 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,129 :: 		CS_ADXL355 = 0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,130 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,131 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;adxl355_spi.c,132 :: 		CS_ADXL355 = 1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,133 :: 		return value;
;adxl355_spi.c,134 :: 		}
;adxl355_spi.c,133 :: 		return value;
;adxl355_spi.c,134 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_data:
	LNK	#2

;adxl355_spi.c,137 :: 		unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
;adxl355_spi.c,140 :: 		if((ADXL355_read_byte(Status)&0x01)==1){                                 //Verifica que el bit DATA_RDY del registro Status este en alto
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W0
	AND	W0, #1, W0
	CP	W0, #1
	BRA Z	L__ADXL355_read_data56
	GOTO	L_ADXL355_read_data0
L__ADXL355_read_data56:
;adxl355_spi.c,141 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,142 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data1:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data57
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data57:
;adxl355_spi.c,143 :: 		muestra = ADXL355_read_byte(axisAddresses[j]);
	ZE	W2, W1
	MOV	#lo_addr(_axisAddresses), W0
	ADD	W0, W1, W0
	PUSH	W10
	MOV.B	[W0], W10
	CALL	_ADXL355_read_byte
	POP	W10
; muestra start address is: 6 (W3)
	MOV.B	W0, W3
;adxl355_spi.c,144 :: 		if (j==2||j==5||j==8){
	CP.B	W2, #2
	BRA NZ	L__ADXL355_read_data58
	GOTO	L__ADXL355_read_data45
L__ADXL355_read_data58:
	CP.B	W2, #5
	BRA NZ	L__ADXL355_read_data59
	GOTO	L__ADXL355_read_data44
L__ADXL355_read_data59:
	CP.B	W2, #8
	BRA NZ	L__ADXL355_read_data60
	GOTO	L__ADXL355_read_data43
L__ADXL355_read_data60:
	GOTO	L_ADXL355_read_data6
L__ADXL355_read_data45:
L__ADXL355_read_data44:
L__ADXL355_read_data43:
;adxl355_spi.c,145 :: 		vectorMuestra[j] = (muestra>>4)&0x0F;
	ZE	W2, W0
	ADD	W10, W0, W1
	ZE	W3, W0
; muestra end address is: 6 (W3)
	LSR	W0, #4, W0
	ZE	W0, W0
	AND	W0, #15, W0
	MOV.B	W0, [W1]
;adxl355_spi.c,146 :: 		} else {
	GOTO	L_ADXL355_read_data7
L_ADXL355_read_data6:
;adxl355_spi.c,147 :: 		vectorMuestra[j] = muestra;
; muestra start address is: 6 (W3)
	ZE	W2, W0
	ADD	W10, W0, W0
	MOV.B	W3, [W0]
; muestra end address is: 6 (W3)
;adxl355_spi.c,148 :: 		}
L_ADXL355_read_data7:
;adxl355_spi.c,142 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,149 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data1
L_ADXL355_read_data2:
;adxl355_spi.c,150 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,151 :: 		} else {
	GOTO	L_ADXL355_read_data8
L_ADXL355_read_data0:
;adxl355_spi.c,152 :: 		for (j=0;j<8;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data9:
; j start address is: 4 (W2)
	CP.B	W2, #8
	BRA LTU	L__ADXL355_read_data61
	GOTO	L_ADXL355_read_data10
L__ADXL355_read_data61:
;adxl355_spi.c,153 :: 		vectorMuestra[j] = 0;
	ZE	W2, W0
	ADD	W10, W0, W1
	CLR	W0
	MOV.B	W0, [W1]
;adxl355_spi.c,152 :: 		for (j=0;j<8;j++){
	INC.B	W2
;adxl355_spi.c,154 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data9
L_ADXL355_read_data10:
;adxl355_spi.c,155 :: 		vectorMuestra[8] = (ADXL355_read_byte(Status)&0x7F);                //Rellena el ultimo byte de la trama con el contenido del registro Status
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W1
	MOV	#127, W0
	AND	W1, W0, W1
	MOV	[W14+0], W0
	MOV.B	W1, [W0]
;adxl355_spi.c,156 :: 		}
L_ADXL355_read_data8:
;adxl355_spi.c,157 :: 		return;
;adxl355_spi.c,158 :: 		}
L_end_ADXL355_read_data:
	ULNK
	RETURN
; end of _ADXL355_read_data

_ADXL355_read_FIFO:
	LNK	#6

;adxl355_spi.c,161 :: 		unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO, unsigned short numFIFO){
;adxl355_spi.c,166 :: 		CS_ADXL355 = 0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,167 :: 		SPI2_Write(add);
	PUSH	W10
	MOV	#35, W10
	CALL	_SPI2_Write
	POP	W10
;adxl355_spi.c,168 :: 		for (j=0; j<numFIFO; j++){
	CLR	W0
	MOV.B	W0, [W14+0]
L_ADXL355_read_FIFO12:
	ADD	W14, #0, W0
	CP.B	W11, [W0]
	BRA GTU	L__ADXL355_read_FIFO63
	GOTO	L_ADXL355_read_FIFO13
L__ADXL355_read_FIFO63:
;adxl355_spi.c,169 :: 		vectorFIFO[0+(j*9)] = SPI_Read(8);                                  //DATA X
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#8, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,170 :: 		vectorFIFO[1+(j*9)] = SPI_Read(7);
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	INC	W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#7, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,171 :: 		vectorFIFO[2+(j*9)] = SPI_Read(6)&0x0F;                             //Comprueba que se obtuvo el LSB del DATA X
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	INC2	W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#6, W10
	CALL	_SPI_Read
	POP.D	W10
	AND	W0, #15, W1
	MOV	[W14+4], W0
	MOV.B	W1, [W0]
;adxl355_spi.c,172 :: 		vectorFIFO[3+(j*9)] = SPI_Read(5);                                  //DATA Y
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #3, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#5, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,173 :: 		vectorFIFO[4+(j*9)] = SPI_Read(4);
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #4, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#4, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,174 :: 		vectorFIFO[5+(j*9)] = SPI_Read(3)&0x0F;                             //Comprueba que se obtuvo el LSB del DATA Y
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #5, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#3, W10
	CALL	_SPI_Read
	POP.D	W10
	AND	W0, #15, W1
	MOV	[W14+4], W0
	MOV.B	W1, [W0]
;adxl355_spi.c,175 :: 		vectorFIFO[6+(j*9)] = SPI_Read(2);                                  //DATA Z
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #6, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#2, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,176 :: 		vectorFIFO[7+(j*9)] = SPI_Read(1);
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #7, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	MOV	#1, W10
	CALL	_SPI_Read
	POP.D	W10
	MOV	[W14+4], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,177 :: 		vectorFIFO[8+(j*9)] = SPI_Read(0)&0x0F;                             //Comprueba que se obtuvo el LSB del DATA Z
	ADD	W14, #0, W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	ADD	W0, #8, W0
	ADD	W10, W0, W0
	MOV	W0, [W14+4]
	PUSH.D	W10
	CLR	W10
	CALL	_SPI_Read
	POP.D	W10
	AND	W0, #15, W1
	MOV	[W14+4], W0
	MOV.B	W1, [W0]
;adxl355_spi.c,168 :: 		for (j=0; j<numFIFO; j++){
	MOV.B	[W14+0], W1
	ADD	W14, #0, W0
	ADD.B	W1, #1, [W0]
;adxl355_spi.c,178 :: 		}
	GOTO	L_ADXL355_read_FIFO12
L_ADXL355_read_FIFO13:
;adxl355_spi.c,179 :: 		CS_ADXL355 = 1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,180 :: 		return;
;adxl355_spi.c,181 :: 		}
L_end_ADXL355_read_FIFO:
	ULNK
	RETURN
; end of _ADXL355_read_FIFO

_ConfiguracionPrincipal:

;Acelerografo.c,53 :: 		void ConfiguracionPrincipal(){
;Acelerografo.c,56 :: 		CLKDIVbits.FRCDIV = 0;                             //FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,57 :: 		CLKDIVbits.PLLPOST = 0;                            //N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,58 :: 		CLKDIVbits.PLLPRE = 5;                             //N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,59 :: 		PLLFBDbits.PLLDIV = 150;                           //M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,61 :: 		ANSELA = 0;                                        //Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,62 :: 		ANSELB = 0;                                        //Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,63 :: 		TRISA3_bit = 0;                                    //Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,64 :: 		TRISA4_bit = 0;                                    //Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,65 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,66 :: 		TRISB10_bit = 0;                                   //Configura el pin B10 como entrada *
	BCLR	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,67 :: 		TRISB11_bit = 1;                                   //Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,68 :: 		TRISB12_bit = 1;                                   //Configura el pin B12 como entrada *
	BSET	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,69 :: 		TRISB13_bit = 1;                                   //Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,71 :: 		INTCON2.GIE = 1;                                   //Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,78 :: 		SPI1STAT.SPIEN = 1;                                //Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,79 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
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
;Acelerografo.c,80 :: 		SPI1IE_bit = 1;                                    //Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,81 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,82 :: 		IPC2bits.SPI1IP = 0x04;
	MOV	#1024, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,85 :: 		RPINR22bits.SDI2R = 0x21;                          //Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,86 :: 		RPOR2bits.RP38R = 0x08;                            //Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,87 :: 		RPOR1bits.RP37R = 0x09;                            //Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,88 :: 		SPI2STAT.SPIEN = 1;                                //Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,89 :: 		SPI2_Init();                                       //Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,92 :: 		RPINR0 = 0x2E00;                                   //Asigna INT1 al RB14/RPI46
	MOV	#11776, W0
	MOV	WREG, RPINR0
;Acelerografo.c,93 :: 		INT1IE_bit = 1;                                    //Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,94 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,95 :: 		IPC5bits.INT1IP = 0x01;                            //Prioridad en la interrupocion externa 1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,104 :: 		T1CON = 0x0010;
	MOV	#16, W0
	MOV	WREG, T1CON
;Acelerografo.c,105 :: 		T1CON.TON = 0;                                     //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,106 :: 		T1IE_bit = 1;                                      //Habilita la interrupción de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,107 :: 		T1IF_bit = 0;                                      //Limpia la bandera de interrupcion del TMR2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,109 :: 		PR1 = 20000;                                       //Preload 4ms
	MOV	#20000, W0
	MOV	WREG, PR1
;Acelerografo.c,110 :: 		IPC0bits.T1IP = 0x02;                              //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,112 :: 		ADXL355_init();
	CALL	_ADXL355_init
;Acelerografo.c,114 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOV	#13, W8
	MOV	#13575, W7
L_ConfiguracionPrincipal15:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal15
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal15
;Acelerografo.c,116 :: 		}
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

;Acelerografo.c,124 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT {
;Acelerografo.c,125 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	PUSH	W10
	PUSH	W11
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,126 :: 		contMuestras = 0;                                  //Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,128 :: 		pduSPI[0] = contCiclos;                            //Carga el primer valor de la trama que se enviara por el SPI con el valor de la muestra actual
	MOV	#lo_addr(_pduSPI), W1
	MOV	#lo_addr(_contCiclos), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,130 :: 		ADXL355_read_FIFO(datosLeidos, 1);                 //Lee el contenido del FIFO
	MOV.B	#1, W11
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,131 :: 		for (x=1;x<10;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_int_117:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__int_166
	GOTO	L_int_118
L__int_166:
;Acelerografo.c,132 :: 		pduSPI[x]=datosLeidos[x-1];                    //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_x), W0
	ZE	[W0], W0
	SUB	W0, #1, W1
	MOV	#lo_addr(_datosLeidos), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,131 :: 		for (x=1;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,133 :: 		}
	GOTO	L_int_117
L_int_118:
;Acelerografo.c,135 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,136 :: 		RP1 = 1;                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,137 :: 		Delay_us(20);
	MOV	#160, W7
L_int_120:
	DEC	W7
	BRA NZ	L_int_120
	NOP
	NOP
;Acelerografo.c,138 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,139 :: 		T1CON.TON = 1;                                     //Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,140 :: 		contCiclos++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,141 :: 		}
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

;Acelerografo.c,144 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT{
;Acelerografo.c,145 :: 		T1IF_bit = 0;
	PUSH	W10
	PUSH	W11
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,146 :: 		contMuestras++;                                    //Incrementa el contador de muestras
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,148 :: 		pduSPI[0] = contMuestras;                          //Carga el primer valor de la trama de datos con el valor de la muestra actual
	MOV	#lo_addr(_pduSPI), W1
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,150 :: 		ADXL355_read_FIFO(datosLeidos, 1);                 //Lee el contenido del FIFO
	MOV.B	#1, W11
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,151 :: 		for (x=1;x<10;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_Timer1Int22:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Timer1Int68
	GOTO	L_Timer1Int23
L__Timer1Int68:
;Acelerografo.c,152 :: 		pduSPI[x]=datosLeidos[x-1];                    //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
	MOV	#lo_addr(_x), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_x), W0
	ZE	[W0], W0
	SUB	W0, #1, W1
	MOV	#lo_addr(_datosLeidos), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,151 :: 		for (x=1;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,153 :: 		}
	GOTO	L_Timer1Int22
L_Timer1Int23:
;Acelerografo.c,154 :: 		if (contMuestras==NUM_MUESTRAS){
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], W1
	MOV.B	#199, W0
	CP.B	W1, W0
	BRA Z	L__Timer1Int69
	GOTO	L_Timer1Int25
L__Timer1Int69:
;Acelerografo.c,155 :: 		T1CON.TON = 0;                                  //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,156 :: 		for (x=10;x<15;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#10, W0
	MOV.B	W0, [W1]
L_Timer1Int26:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #15
	BRA LTU	L__Timer1Int70
	GOTO	L_Timer1Int27
L__Timer1Int70:
;Acelerografo.c,157 :: 		pduSPI[x]=tiempo[x-10];                     //Carga el vector de salida de datos SPI con los datos de la cabecera
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
;Acelerografo.c,156 :: 		for (x=10;x<15;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,158 :: 		}
	GOTO	L_Timer1Int26
L_Timer1Int27:
;Acelerografo.c,159 :: 		}
L_Timer1Int25:
;Acelerografo.c,161 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,163 :: 		RP2 = 1;                                         //Genera el pulso P2 para producir la interrupcion en la RPi
	BSET	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,164 :: 		Delay_us(20);
	MOV	#160, W7
L_Timer1Int29:
	DEC	W7
	BRA NZ	L_Timer1Int29
	NOP
	NOP
;Acelerografo.c,165 :: 		RP2 = 0;                                         //Limpia la bandera de interrupcion por desbordamiento del Timer1
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,166 :: 		}
L_end_Timer1Int:
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
; end of _Timer1Int

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,169 :: 		void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
;Acelerografo.c,170 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,171 :: 		buffer = SPI1BUF;                                  //Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,173 :: 		if ((banTI==1)){                                   //Verifica si la bandera de inicio de trama esta activa
	MOV	#lo_addr(_banTI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_172
	GOTO	L_spi_131
L__spi_172:
;Acelerografo.c,174 :: 		banLec = 1;                                     //Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,175 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,176 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,177 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,178 :: 		}
L_spi_131:
;Acelerografo.c,179 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_173
	GOTO	L__spi_149
L__spi_173:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA NZ	L__spi_174
	GOTO	L__spi_148
L__spi_174:
L__spi_147:
;Acelerografo.c,180 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,181 :: 		i++;
	MOV.B	#1, W1
	MOV	#lo_addr(_i), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,179 :: 		if ((banLec==1)&&(buffer!=0xB1)){
L__spi_149:
L__spi_148:
;Acelerografo.c,183 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_175
	GOTO	L__spi_151
L__spi_175:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA Z	L__spi_176
	GOTO	L__spi_150
L__spi_176:
L__spi_146:
;Acelerografo.c,184 :: 		banLec = 0;                                     //Limpia la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,185 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,186 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,183 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
L__spi_151:
L__spi_150:
;Acelerografo.c,188 :: 		}
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

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,201 :: 		void main() {
;Acelerografo.c,203 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,205 :: 		tiempo[0] = 19;                                    //Año
	MOV	#lo_addr(_tiempo), W1
	MOV.B	#19, W0
	MOV.B	W0, [W1]
;Acelerografo.c,206 :: 		tiempo[1] = 49;                                    //Dia
	MOV	#lo_addr(_tiempo+1), W1
	MOV.B	#49, W0
	MOV.B	W0, [W1]
;Acelerografo.c,207 :: 		tiempo[2] = 9;                                     //Hora
	MOV	#lo_addr(_tiempo+2), W1
	MOV.B	#9, W0
	MOV.B	W0, [W1]
;Acelerografo.c,208 :: 		tiempo[3] = 30;                                    //Minuto
	MOV	#lo_addr(_tiempo+3), W1
	MOV.B	#30, W0
	MOV.B	W0, [W1]
;Acelerografo.c,209 :: 		tiempo[4] = 0;                                     //Segundo
	MOV	#lo_addr(_tiempo+4), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,215 :: 		datosLeidos[0] = 0x01;
	MOV	#lo_addr(_datosLeidos), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,216 :: 		datosLeidos[1] = 0x02;
	MOV	#lo_addr(_datosLeidos+1), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,217 :: 		datosLeidos[2] = 0x03;
	MOV	#lo_addr(_datosLeidos+2), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,218 :: 		datosLeidos[3] = 0x01;
	MOV	#lo_addr(_datosLeidos+3), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,219 :: 		datosLeidos[4] = 0x02;
	MOV	#lo_addr(_datosLeidos+4), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,220 :: 		datosLeidos[5] = 0x03;
	MOV	#lo_addr(_datosLeidos+5), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,221 :: 		datosLeidos[6] = 0x01;
	MOV	#lo_addr(_datosLeidos+6), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,222 :: 		datosLeidos[7] = 0x02;
	MOV	#lo_addr(_datosLeidos+7), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,223 :: 		datosLeidos[8] = 0x03;
	MOV	#lo_addr(_datosLeidos+8), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,225 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,226 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,227 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,228 :: 		x = 0;
	MOV	#lo_addr(_x), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,230 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,231 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,232 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,233 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,235 :: 		puntero_8 = &auxiliar;
	MOV	#lo_addr(_auxiliar), W0
	MOV	W0, _puntero_8
;Acelerografo.c,237 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,239 :: 		while(1){
L_main38:
;Acelerografo.c,241 :: 		Delay_ms(500);
	MOV	#62, W8
	MOV	#2340, W7
L_main40:
	DEC	W7
	BRA NZ	L_main40
	DEC	W8
	BRA NZ	L_main40
	NOP
	NOP
;Acelerografo.c,243 :: 		}
	GOTO	L_main38
;Acelerografo.c,245 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
