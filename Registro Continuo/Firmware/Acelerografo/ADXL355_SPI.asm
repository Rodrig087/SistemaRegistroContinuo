
_ADXL355_init:

;ADXL355_SPI.c,114 :: 		void ADXL355_init()
;ADXL355_SPI.c,116 :: 		SPI2_Init();  //Inicialización del modulo I2C 2
	PUSH	W10
	PUSH	W11
	CALL	_SPI2_Init
;ADXL355_SPI.c,117 :: 		delay_ms(100);
	MOV	#13, W8
	MOV	#13575, W7
L_ADXL355_init0:
	DEC	W7
	BRA NZ	L_ADXL355_init0
	DEC	W8
	BRA NZ	L_ADXL355_init0
;ADXL355_SPI.c,118 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|TEMP_OFF|MEASURING);
	MOV.B	#6, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,119 :: 		ADXL355_write_byte(Range, I2C_HS|_2G);
	MOV.B	#129, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,120 :: 		ADXL355_write_byte(Range, NO_HIGH_PASS_FILTER|_31_25_Hz);
	MOV.B	#5, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;ADXL355_SPI.c,122 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;ADXL355_SPI.c,125 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value)
;ADXL355_SPI.c,128 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,129 :: 		CS_ADXL355=0;
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,130 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,131 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,132 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,133 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_write_word:

;ADXL355_SPI.c,136 :: 		void ADXL355_write_word(unsigned char address, unsigned int value)
;ADXL355_SPI.c,138 :: 		unsigned int temp = 0x0000;
	PUSH	W10
;ADXL355_SPI.c,140 :: 		temp = value & 0xFF00;
	MOV	#65280, W0
	AND	W11, W0, W0
;ADXL355_SPI.c,141 :: 		temp >>= 8;
	LSR	W0, #8, W0
; temp start address is: 4 (W2)
	MOV	W0, W2
;ADXL355_SPI.c,143 :: 		address=(address<<1)&0xFE;
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,144 :: 		CS_ADXL355=0;
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,145 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,146 :: 		SPI2_Write(value);
	MOV	W11, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,147 :: 		SPI2_Write(temp);
	MOV	W2, W10
; temp end address is: 4 (W2)
	CALL	_SPI2_Write
;ADXL355_SPI.c,148 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,150 :: 		}
L_end_ADXL355_write_word:
	POP	W10
	RETURN
; end of _ADXL355_write_word

_ADXL355_read_byte:

;ADXL355_SPI.c,153 :: 		unsigned char ADXL355_read_byte(unsigned char address)
;ADXL355_SPI.c,155 :: 		unsigned char value = 0x00;
	PUSH	W10
;ADXL355_SPI.c,156 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,157 :: 		CS_ADXL355=0;
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,158 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,159 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;ADXL355_SPI.c,160 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,162 :: 		return value;
;ADXL355_SPI.c,163 :: 		}
;ADXL355_SPI.c,162 :: 		return value;
;ADXL355_SPI.c,163 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_word:

;ADXL355_SPI.c,166 :: 		unsigned int ADXL355_read_word(unsigned char address)
;ADXL355_SPI.c,168 :: 		unsigned char hb = 0x00;
	PUSH	W10
;ADXL355_SPI.c,169 :: 		unsigned char lb = 0x00;
;ADXL355_SPI.c,170 :: 		unsigned int temp = 0x0000;
;ADXL355_SPI.c,171 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,172 :: 		CS_ADXL355=0;
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,173 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,174 :: 		hb = SPI_Read(1);
	MOV	#1, W10
	CALL	_SPI_Read
; hb start address is: 2 (W1)
	MOV.B	W0, W1
;ADXL355_SPI.c,175 :: 		lb = SPI_Read(0);
	PUSH	W1
	CLR	W10
	CALL	_SPI_Read
	POP	W1
;ADXL355_SPI.c,176 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,177 :: 		temp = hb;
; temp start address is: 4 (W2)
	ZE	W1, W2
; hb end address is: 2 (W1)
;ADXL355_SPI.c,178 :: 		temp <<= 0x08;
	SL	W2, #8, W1
; temp end address is: 4 (W2)
;ADXL355_SPI.c,179 :: 		temp |= lb;
	ZE	W0, W0
	IOR	W1, W0, W0
;ADXL355_SPI.c,180 :: 		return temp;
;ADXL355_SPI.c,181 :: 		}
;ADXL355_SPI.c,180 :: 		return temp;
;ADXL355_SPI.c,181 :: 		}
L_end_ADXL355_read_word:
	POP	W10
	RETURN
; end of _ADXL355_read_word

_ADXL355_read_data:
	LNK	#4

;ADXL355_SPI.c,183 :: 		unsigned int ADXL355_read_data(unsigned char address)
;ADXL355_SPI.c,187 :: 		puntero_8=&dato;
	PUSH	W10
	ADD	W14, #0, W0
; puntero_8 start address is: 4 (W2)
	MOV	W0, W2
;ADXL355_SPI.c,188 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;ADXL355_SPI.c,189 :: 		CS_ADXL355=0;
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,190 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;ADXL355_SPI.c,191 :: 		*(puntero_8+0) = SPI_Read(2);
	MOV	W2, W0
	MOV	W0, [W14+2]
	PUSH	W2
	MOV	#2, W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,192 :: 		*(puntero_8+1) = SPI_Read(1);
	ADD	W2, #1, W0
	MOV	W0, [W14+2]
	PUSH	W2
	MOV	#1, W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,193 :: 		*(puntero_8+2) = SPI_Read(0);
	ADD	W2, #2, W0
	MOV	W0, [W14+2]
	PUSH	W2
	CLR	W10
	CALL	_SPI_Read
	POP	W2
	MOV	[W14+2], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,194 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,196 :: 		bandera=*(puntero_8+0)&0x80;
	ZE	[W2], W1
; puntero_8 end address is: 4 (W2)
	MOV	#128, W0
	AND	W1, W0, W4
;ADXL355_SPI.c,197 :: 		auxiliar=*dato;
	MOV	[W14+0], W0
;ADXL355_SPI.c,198 :: 		auxiliar=auxiliar>>12;
	MOV.D	[W0], W2
	LSR	W2, #12, W0
	SL	W3, #4, W1
	IOR	W0, W1, W0
	ASR	W3, #12, W1
; auxiliar start address is: 4 (W2)
	MOV.D	W0, W2
;ADXL355_SPI.c,199 :: 		if(bandera!=0){
	CP.B	W4, #0
	BRA NZ	L__ADXL355_read_data10
	GOTO	L__ADXL355_read_data3
L__ADXL355_read_data10:
;ADXL355_SPI.c,200 :: 		auxiliar=auxiliar|0xFFF00000;
	MOV	#0, W0
	MOV	#65520, W1
; auxiliar start address is: 0 (W0)
	IOR	W2, W0, W0
	IOR	W3, W1, W1
; auxiliar end address is: 4 (W2)
	MOV	W1, W2
	MOV	W0, W1
; auxiliar end address is: 0 (W0)
;ADXL355_SPI.c,201 :: 		}
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data3:
;ADXL355_SPI.c,199 :: 		if(bandera!=0){
	MOV	W2, W1
	MOV	W3, W2
;ADXL355_SPI.c,201 :: 		}
L_ADXL355_read_data2:
;ADXL355_SPI.c,202 :: 		return auxiliar;
; auxiliar start address is: 2 (W1)
	MOV	W1, W0
; auxiliar end address is: 2 (W1)
;ADXL355_SPI.c,203 :: 		}
;ADXL355_SPI.c,202 :: 		return auxiliar;
;ADXL355_SPI.c,203 :: 		}
L_end_ADXL355_read_data:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_read_data

_get_values:

;ADXL355_SPI.c,206 :: 		void get_values(signed int *x_val, signed int *y_val, signed int *z_val)
;ADXL355_SPI.c,209 :: 		*x_val = ADXL355_read_data(XDATA3);
	PUSH	W10
	PUSH	W12
	PUSH.D	W10
	MOV.B	#8, W10
	CALL	_ADXL355_read_data
	POP.D	W10
	MOV	W0, [W10]
;ADXL355_SPI.c,210 :: 		*y_val = ADXL355_read_data(YDATA3);
	PUSH	W11
	MOV.B	#11, W10
	CALL	_ADXL355_read_data
	POP	W11
	MOV	W0, [W11]
;ADXL355_SPI.c,211 :: 		*z_val = ADXL355_read_data(ZDATA3);
	MOV.B	#14, W10
	CALL	_ADXL355_read_data
	POP	W12
	MOV	W0, [W12]
;ADXL355_SPI.c,212 :: 		}
L_end_get_values:
	POP	W10
	RETURN
; end of _get_values

_ADXL355_muestra:
	LNK	#2

;ADXL355_SPI.c,215 :: 		unsigned int ADXL355_muestra( unsigned char *puntero_8)
;ADXL355_SPI.c,218 :: 		CS_ADXL355=0;
	PUSH	W10
	BCLR	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,219 :: 		SPI2_Write(0x11); //Es la dirección 0x08 de XDATA desplazada y colocada el modo lectura
	PUSH	W10
	MOV	#17, W10
	CALL	_SPI2_Write
	POP	W10
;ADXL355_SPI.c,221 :: 		*(puntero_8+0) = SPI_Read(8);
	MOV	W10, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#8, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,222 :: 		*(puntero_8+1) = SPI_Read(7);
	ADD	W10, #1, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#7, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,223 :: 		*(puntero_8+2) = SPI_Read(6);
	ADD	W10, #2, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#6, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,224 :: 		*(puntero_8+3) = SPI_Read(5);
	ADD	W10, #3, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#5, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,225 :: 		*(puntero_8+4) = SPI_Read(4);
	ADD	W10, #4, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#4, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,226 :: 		*(puntero_8+5) = SPI_Read(3);
	ADD	W10, #5, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#3, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,227 :: 		*(puntero_8+6) = SPI_Read(2);
	ADD	W10, #6, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,228 :: 		*(puntero_8+7) = SPI_Read(1);
	ADD	W10, #7, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,229 :: 		*(puntero_8+8) = SPI_Read(0);
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	CLR	W10
	CALL	_SPI_Read
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;ADXL355_SPI.c,230 :: 		CS_ADXL355=1;
	BSET	LATA0_bit, BitPos(LATA0_bit+0)
;ADXL355_SPI.c,232 :: 		}
;ADXL355_SPI.c,231 :: 		return;
;ADXL355_SPI.c,232 :: 		}
L_end_ADXL355_muestra:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_muestra
