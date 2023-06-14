
_ADXL355_init:

;ADXL355_SPI.c,8 :: 		void ADXL355_init(short tMuestreo){
;ADXL355_SPI.c,9 :: 		ADXL355_write_byte(Reset,0x52);                                             //Resetea el dispositivo
	PUSH	W10
	PUSH	W11
	PUSH	W10
	MOV.B	#82, W11
	MOV.B	#47, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,10 :: 		Delay_ms(10);
	MOV	#2, W8
	MOV	#14464, W7
L_ADXL355_init0:
	DEC	W7
	BRA NZ	L_ADXL355_init0
	DEC	W8
	BRA NZ	L_ADXL355_init0
	NOP
	NOP
;ADXL355_SPI.c,11 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,12 :: 		ADXL355_write_byte(Range, _2G);
	MOV.B	#1, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
	POP	W10
;ADXL355_SPI.c,13 :: 		switch (tMuestreo){
	GOTO	L_ADXL355_init2
;ADXL355_SPI.c,14 :: 		case 1:
L_ADXL355_init4:
;ADXL355_SPI.c,15 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_62_5_Hz);       //ODR=250Hz 1
	MOV.B	#4, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,16 :: 		break;
	GOTO	L_ADXL355_init3
;ADXL355_SPI.c,17 :: 		case 2:
L_ADXL355_init5:
;ADXL355_SPI.c,18 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_31_25_Hz);      //ODR=125Hz 2
	MOV.B	#5, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,19 :: 		break;
	GOTO	L_ADXL355_init3
;ADXL355_SPI.c,20 :: 		case 4:
L_ADXL355_init6:
;ADXL355_SPI.c,21 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_15_625_Hz);     //ODR=62.5Hz 4
	MOV.B	#6, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,22 :: 		break;
	GOTO	L_ADXL355_init3
;ADXL355_SPI.c,23 :: 		case 8:
L_ADXL355_init7:
;ADXL355_SPI.c,24 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_7_813_Hz );     //ODR=31.25Hz 8
	MOV.B	#7, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,25 :: 		break;
	GOTO	L_ADXL355_init3
;ADXL355_SPI.c,26 :: 		}
L_ADXL355_init2:
	CP.B	W10, #1
	BRA NZ	L__ADXL355_init19
	GOTO	L_ADXL355_init4
L__ADXL355_init19:
	CP.B	W10, #2
	BRA NZ	L__ADXL355_init20
	GOTO	L_ADXL355_init5
L__ADXL355_init20:
	CP.B	W10, #4
	BRA NZ	L__ADXL355_init21
	GOTO	L_ADXL355_init6
L__ADXL355_init21:
	CP.B	W10, #8
	BRA NZ	L__ADXL355_init22
	GOTO	L_ADXL355_init7
L__ADXL355_init22:
L_ADXL355_init3:
;ADXL355_SPI.c,27 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;ADXL355_SPI.c,30 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;ADXL355_SPI.c,31 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,32 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,33 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,34 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,35 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,36 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;ADXL355_SPI.c,39 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;ADXL355_SPI.c,40 :: 		unsigned char value = 0x00;
	PUSH	W10
;ADXL355_SPI.c,41 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,42 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,43 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,44 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;ADXL355_SPI.c,45 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,46 :: 		return value;
;ADXL355_SPI.c,47 :: 		}
;ADXL355_SPI.c,46 :: 		return value;
;ADXL355_SPI.c,47 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_data:

;ADXL355_SPI.c,50 :: 		unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
;ADXL355_SPI.c,53 :: 		if((ADXL355_read_byte(Status)&0x01)==1){                                 //Verifica que el bit DATA_RDY del registro Status este en alto
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W0
	AND	W0, #1, W0
	CP	W0, #1
	BRA Z	L__ADXL355_read_data26
	GOTO	L_ADXL355_read_data8
L__ADXL355_read_data26:
;ADXL355_SPI.c,54 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,55 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data9:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data27
	GOTO	L_ADXL355_read_data10
L__ADXL355_read_data27:
;ADXL355_SPI.c,56 :: 		muestra = ADXL355_read_byte(axisAddresses[j]);
	ZE	W2, W1
	MOV	#lo_addr(_axisAddresses), W0
	ADD	W0, W1, W0
	PUSH	W10
	MOV.B	[W0], W10
	CALL	_ADXL355_read_byte
	POP	W10
;ADXL355_SPI.c,57 :: 		vectorMuestra[j] = muestra;
	ZE	W2, W1
	ADD	W10, W1, W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,55 :: 		for (j=0;j<9;j++){
	INC.B	W2
;ADXL355_SPI.c,58 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data9
L_ADXL355_read_data10:
;ADXL355_SPI.c,59 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,60 :: 		} else {
	GOTO	L_ADXL355_read_data12
L_ADXL355_read_data8:
;ADXL355_SPI.c,61 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data13:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data28
	GOTO	L_ADXL355_read_data14
L__ADXL355_read_data28:
;ADXL355_SPI.c,62 :: 		vectorMuestra[j] = 0;
	ZE	W2, W0
	ADD	W10, W0, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADXL355_SPI.c,61 :: 		for (j=0;j<9;j++){
	INC.B	W2
;ADXL355_SPI.c,63 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data13
L_ADXL355_read_data14:
;ADXL355_SPI.c,64 :: 		}
L_ADXL355_read_data12:
;ADXL355_SPI.c,65 :: 		return;
;ADXL355_SPI.c,66 :: 		}
L_end_ADXL355_read_data:
	RETURN
; end of _ADXL355_read_data

_ADXL355_read_FIFO:
	LNK	#2

;ADXL355_SPI.c,69 :: 		unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO){
;ADXL355_SPI.c,72 :: 		CS_ADXL355 = 0;
	PUSH	W10
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,73 :: 		SPI2_Write(add);
	PUSH	W10
	MOV	#35, W10
	CALL	_SPI2_Write
	POP	W10
;ADXL355_SPI.c,75 :: 		vectorFIFO[0] = SPI2_Read(0);
	MOV	W10, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,76 :: 		vectorFIFO[1] = SPI2_Read(1);
	ADD	W10, #1, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,77 :: 		vectorFIFO[2] = SPI2_Read(2);
	ADD	W10, #2, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,79 :: 		vectorFIFO[3] = SPI2_Read(0);
	ADD	W10, #3, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,80 :: 		vectorFIFO[4] = SPI2_Read(1);
	ADD	W10, #4, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,81 :: 		vectorFIFO[5] = SPI2_Read(2);
	ADD	W10, #5, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,83 :: 		vectorFIFO[6] = SPI2_Read(0);
	ADD	W10, #6, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,84 :: 		vectorFIFO[7] = SPI2_Read(1);
	ADD	W10, #7, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,85 :: 		vectorFIFO[8] = SPI2_Read(2);
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	MOV	#2, W10
	CALL	_SPI2_Read
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,86 :: 		CS_ADXL355 = 1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;ADXL355_SPI.c,87 :: 		Delay_us(5);
	MOV	#40, W7
L_ADXL355_read_FIFO16:
	DEC	W7
	BRA NZ	L_ADXL355_read_FIFO16
	NOP
	NOP
;ADXL355_SPI.c,89 :: 		}
;ADXL355_SPI.c,88 :: 		return;
;ADXL355_SPI.c,89 :: 		}
L_end_ADXL355_read_FIFO:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_read_FIFO
