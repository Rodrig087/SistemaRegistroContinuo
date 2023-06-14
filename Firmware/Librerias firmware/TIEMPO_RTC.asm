
_DS3234_init:

;TIEMPO_RTC.c,38 :: 		void DS3234_init(){
;TIEMPO_RTC.c,40 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	CLR	W13
	MOV	#28, W12
	CLR	W11
	MOV	#32, W10
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CALL	_SPI2_Init_Advanced
	SUB	#8, W15
;TIEMPO_RTC.c,41 :: 		DS3234_write_byte(Control,0x20);
	MOV.B	#32, W11
	MOV.B	#142, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,42 :: 		DS3234_write_byte(ControlStatus,0x08);
	MOV.B	#8, W11
	MOV.B	#143, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,43 :: 		SPI2_Init();
	CALL	_SPI2_Init
;TIEMPO_RTC.c,45 :: 		}
L_end_DS3234_init:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _DS3234_init

_DS3234_write_byte:

;TIEMPO_RTC.c,48 :: 		void DS3234_write_byte(unsigned char address, unsigned char value){
;TIEMPO_RTC.c,50 :: 		CS_DS3234 = 0;
	PUSH	W10
	BCLR	LATA2_bit, BitPos(LATA2_bit+0)
;TIEMPO_RTC.c,51 :: 		SPI2_Write(address);
	ZE	W10, W10
	CALL	_SPI2_Write
;TIEMPO_RTC.c,52 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;TIEMPO_RTC.c,53 :: 		CS_DS3234 = 1;
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;TIEMPO_RTC.c,55 :: 		}
L_end_DS3234_write_byte:
	POP	W10
	RETURN
; end of _DS3234_write_byte

_DS3234_read_byte:

;TIEMPO_RTC.c,58 :: 		unsigned char DS3234_read_byte(unsigned char address){
;TIEMPO_RTC.c,60 :: 		unsigned char value = 0x00;
	PUSH	W10
;TIEMPO_RTC.c,61 :: 		CS_DS3234 = 0;
	BCLR	LATA2_bit, BitPos(LATA2_bit+0)
;TIEMPO_RTC.c,62 :: 		SPI2_Write(address);
	ZE	W10, W10
	CALL	_SPI2_Write
;TIEMPO_RTC.c,63 :: 		value = SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;TIEMPO_RTC.c,64 :: 		CS_DS3234 = 1;
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;TIEMPO_RTC.c,65 :: 		return value;
;TIEMPO_RTC.c,67 :: 		}
;TIEMPO_RTC.c,65 :: 		return value;
;TIEMPO_RTC.c,67 :: 		}
L_end_DS3234_read_byte:
	POP	W10
	RETURN
; end of _DS3234_read_byte

_DS3234_setDate:
	LNK	#14

;TIEMPO_RTC.c,70 :: 		void DS3234_setDate(unsigned long longHora, unsigned long longFecha){
;TIEMPO_RTC.c,80 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
	PUSH	W10
	PUSH	W11
	PUSH.D	W12
	PUSH.D	W10
	CLR	W13
	MOV	#28, W12
	CLR	W11
	MOV	#32, W10
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CALL	_SPI2_Init_Advanced
	SUB	#8, W15
	POP.D	W10
;TIEMPO_RTC.c,82 :: 		hora = (char)(longHora / 3600);
	PUSH.D	W10
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
	MOV.B	W0, [W14+0]
;TIEMPO_RTC.c,83 :: 		minuto = (char)((longHora%3600) / 60);
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
;TIEMPO_RTC.c,84 :: 		segundo = (char)((longHora%3600) % 60);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W12
	MOV.B	W0, [W14+2]
;TIEMPO_RTC.c,86 :: 		anio = (char)(longFecha / 10000);
	PUSH.D	W12
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W12
	MOV.B	W0, [W14+4]
;TIEMPO_RTC.c,87 :: 		mes = (char)((longFecha%10000) / 100);
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
	MOV.B	W0, [W14+3]
;TIEMPO_RTC.c,88 :: 		dia = (char)((longFecha%10000) % 100);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
; dia start address is: 8 (W4)
	MOV.B	W0, W4
;TIEMPO_RTC.c,90 :: 		segundo = Dec2Bcd(segundo);
	MOV.B	[W14+2], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+2]
;TIEMPO_RTC.c,91 :: 		minuto = Dec2Bcd(minuto);
	MOV.B	[W14+1], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+1]
;TIEMPO_RTC.c,92 :: 		hora = Dec2Bcd(hora);
	MOV.B	[W14+0], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+0]
;TIEMPO_RTC.c,93 :: 		dia = Dec2Bcd(dia);
	MOV.B	W4, W10
; dia end address is: 8 (W4)
	CALL	_Dec2Bcd
; dia start address is: 8 (W4)
	MOV.B	W0, W4
;TIEMPO_RTC.c,94 :: 		mes = Dec2Bcd(mes);
	MOV.B	[W14+3], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+3]
;TIEMPO_RTC.c,95 :: 		anio = Dec2Bcd(anio);
	MOV.B	[W14+4], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+4]
;TIEMPO_RTC.c,97 :: 		DS3234_write_byte(Segundos_Esc, segundo);
	MOV.B	[W14+2], W11
	MOV.B	#128, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,98 :: 		DS3234_write_byte(Minutos_Esc, minuto);
	MOV.B	[W14+1], W11
	MOV.B	#129, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,99 :: 		DS3234_write_byte(Horas_Esc, hora);
	MOV.B	[W14+0], W11
	MOV.B	#130, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,100 :: 		DS3234_write_byte(DiaMes_Esc, dia);
	MOV.B	W4, W11
; dia end address is: 8 (W4)
	MOV.B	#132, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,101 :: 		DS3234_write_byte(Mes_Esc, mes);
	MOV.B	[W14+3], W11
	MOV.B	#133, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,102 :: 		DS3234_write_byte(Anio_Esc, anio);
	MOV.B	[W14+4], W11
	MOV.B	#134, W10
	CALL	_DS3234_write_byte
;TIEMPO_RTC.c,104 :: 		SPI2_Init();
	CALL	_SPI2_Init
;TIEMPO_RTC.c,108 :: 		}
;TIEMPO_RTC.c,106 :: 		return;
;TIEMPO_RTC.c,108 :: 		}
L_end_DS3234_setDate:
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _DS3234_setDate

_RecuperarHoraRTC:
	LNK	#4

;TIEMPO_RTC.c,111 :: 		unsigned long RecuperarHoraRTC(){
;TIEMPO_RTC.c,119 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	CLR	W13
	MOV	#28, W12
	CLR	W11
	MOV	#32, W10
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CALL	_SPI2_Init_Advanced
	SUB	#8, W15
;TIEMPO_RTC.c,121 :: 		valueRead = DS3234_read_byte(Segundos_Lec);
	CLR	W10
	CALL	_DS3234_read_byte
;TIEMPO_RTC.c,122 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,123 :: 		segundo = (long)valueRead;
; segundo start address is: 12 (W6)
	ZE	W0, W6
	CLR	W7
;TIEMPO_RTC.c,124 :: 		valueRead = DS3234_read_byte(Minutos_Lec);
	MOV.B	#1, W10
	CALL	_DS3234_read_byte
;TIEMPO_RTC.c,125 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,126 :: 		minuto = (long)valueRead;
; minuto start address is: 16 (W8)
	ZE	W0, W8
	CLR	W9
;TIEMPO_RTC.c,127 :: 		valueRead = DS3234_read_byte(Horas_Lec);
	MOV.B	#2, W10
	CALL	_DS3234_read_byte
;TIEMPO_RTC.c,128 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,129 :: 		hora = (long)valueRead;
	ZE	W0, W0
	CLR	W1
;TIEMPO_RTC.c,131 :: 		horaRTC = (hora*3600)+(minuto*60)+(segundo);                               //Calcula el segundo actual = hh*3600 + mm*60 + ss
	MOV	#3600, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV.D	W8, W0
	MOV	#60, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
; minuto end address is: 16 (W8)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	ADD	W2, W0, W0
	ADDC	W3, W1, W1
; horaRTC start address is: 4 (W2)
	ADD	W0, W6, W2
	ADDC	W1, W7, W3
; segundo end address is: 12 (W6)
;TIEMPO_RTC.c,133 :: 		SPI2_Init();
	CALL	_SPI2_Init
;TIEMPO_RTC.c,135 :: 		return horaRTC;
	MOV.D	W2, W0
; horaRTC end address is: 4 (W2)
;TIEMPO_RTC.c,137 :: 		}
;TIEMPO_RTC.c,135 :: 		return horaRTC;
;TIEMPO_RTC.c,137 :: 		}
L_end_RecuperarHoraRTC:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _RecuperarHoraRTC

_RecuperarFechaRTC:
	LNK	#4

;TIEMPO_RTC.c,140 :: 		unsigned long RecuperarFechaRTC(){
;TIEMPO_RTC.c,148 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	CLR	W13
	MOV	#28, W12
	CLR	W11
	MOV	#32, W10
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CLR	W0
	PUSH	W0
	CALL	_SPI2_Init_Advanced
	SUB	#8, W15
;TIEMPO_RTC.c,150 :: 		valueRead = DS3234_read_byte(DiaMes_Lec);
	MOV.B	#4, W10
	CALL	_DS3234_read_byte
;TIEMPO_RTC.c,151 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,152 :: 		dia = (long)valueRead;
; dia start address is: 12 (W6)
	ZE	W0, W6
	CLR	W7
;TIEMPO_RTC.c,153 :: 		valueRead = 0x1F & DS3234_read_byte(Mes_Lec);
	MOV.B	#5, W10
	CALL	_DS3234_read_byte
	ZE	W0, W0
	AND	W0, #31, W0
;TIEMPO_RTC.c,154 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,155 :: 		mes = (long)valueRead;
; mes start address is: 16 (W8)
	ZE	W0, W8
	CLR	W9
;TIEMPO_RTC.c,156 :: 		valueRead = DS3234_read_byte(Anio_Lec);
	MOV.B	#6, W10
	CALL	_DS3234_read_byte
;TIEMPO_RTC.c,157 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;TIEMPO_RTC.c,158 :: 		anio = (long)valueRead;
	ZE	W0, W0
	CLR	W1
;TIEMPO_RTC.c,160 :: 		fechaRTC = (anio*10000)+(mes*100)+(dia);                                   //10000*aa + 100*mm + dd
	MOV	#10000, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV.D	W8, W0
	MOV	#100, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
; mes end address is: 16 (W8)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	ADD	W2, W0, W0
	ADDC	W3, W1, W1
; fechaRTC start address is: 4 (W2)
	ADD	W0, W6, W2
	ADDC	W1, W7, W3
; dia end address is: 12 (W6)
;TIEMPO_RTC.c,162 :: 		SPI2_Init();
	CALL	_SPI2_Init
;TIEMPO_RTC.c,164 :: 		return fechaRTC;
	MOV.D	W2, W0
; fechaRTC end address is: 4 (W2)
;TIEMPO_RTC.c,166 :: 		}
;TIEMPO_RTC.c,164 :: 		return fechaRTC;
;TIEMPO_RTC.c,166 :: 		}
L_end_RecuperarFechaRTC:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _RecuperarFechaRTC

_IncrementarFecha:
	LNK	#4

;TIEMPO_RTC.c,169 :: 		unsigned long IncrementarFecha(unsigned long longFecha){
;TIEMPO_RTC.c,176 :: 		anio = longFecha / 10000;
	PUSH.D	W10
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
; anio start address is: 4 (W2)
	MOV.D	W0, W2
;TIEMPO_RTC.c,177 :: 		mes = (longFecha%10000) / 100;
	PUSH.D	W2
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Modulus_32x32
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W2
; mes start address is: 8 (W4)
	MOV.D	W0, W4
;TIEMPO_RTC.c,178 :: 		dia = (longFecha%10000) % 100;
	MOV	[W14+0], W0
	MOV	[W14+2], W1
	PUSH.D	W4
	PUSH.D	W2
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W2
	POP.D	W4
; dia start address is: 12 (W6)
	MOV.D	W0, W6
;TIEMPO_RTC.c,180 :: 		if (dia<28){
	CP	W0, #28
	CPB	W1, #0
	BRA LTU	L__IncrementarFecha54
	GOTO	L_IncrementarFecha0
L__IncrementarFecha54:
;TIEMPO_RTC.c,181 :: 		dia++;
; dia start address is: 16 (W8)
	ADD	W6, #1, W8
	ADDC	W7, #0, W9
; dia end address is: 12 (W6)
;TIEMPO_RTC.c,182 :: 		} else {
; dia end address is: 16 (W8)
	MOV.D	W4, W6
	GOTO	L_IncrementarFecha1
L_IncrementarFecha0:
;TIEMPO_RTC.c,183 :: 		if (mes==2){
; dia start address is: 12 (W6)
	CP	W4, #2
	CPB	W5, #0
	BRA Z	L__IncrementarFecha55
	GOTO	L_IncrementarFecha2
L__IncrementarFecha55:
;TIEMPO_RTC.c,185 :: 		if (((anio-16)%4)==0){
	SUB	W2, #16, W0
	SUBB	W3, #0, W1
	AND	W0, #3, W0
	AND	W1, #0, W1
	CP	W0, #0
	CPB	W1, #0
	BRA Z	L__IncrementarFecha56
	GOTO	L_IncrementarFecha3
L__IncrementarFecha56:
;TIEMPO_RTC.c,186 :: 		if (dia==29){
	CP	W6, #29
	CPB	W7, #0
	BRA Z	L__IncrementarFecha57
	GOTO	L_IncrementarFecha4
L__IncrementarFecha57:
; dia end address is: 12 (W6)
;TIEMPO_RTC.c,187 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;TIEMPO_RTC.c,188 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
;TIEMPO_RTC.c,189 :: 		} else {
; dia end address is: 0 (W0)
	GOTO	L_IncrementarFecha5
L_IncrementarFecha4:
;TIEMPO_RTC.c,190 :: 		dia++;
; dia start address is: 0 (W0)
; dia start address is: 12 (W6)
	ADD	W6, #1, W0
	ADDC	W7, #0, W1
; dia end address is: 12 (W6)
; mes end address is: 8 (W4)
; dia end address is: 0 (W0)
;TIEMPO_RTC.c,191 :: 		}
L_IncrementarFecha5:
;TIEMPO_RTC.c,192 :: 		} else {
; dia start address is: 0 (W0)
; mes start address is: 8 (W4)
	MOV.D	W0, W8
; dia end address is: 0 (W0)
	MOV.D	W4, W6
	GOTO	L_IncrementarFecha6
L_IncrementarFecha3:
;TIEMPO_RTC.c,193 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;TIEMPO_RTC.c,194 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
	MOV.D	W0, W8
; mes end address is: 8 (W4)
; dia end address is: 0 (W0)
	MOV.D	W4, W6
;TIEMPO_RTC.c,195 :: 		}
L_IncrementarFecha6:
;TIEMPO_RTC.c,196 :: 		} else {
; mes start address is: 12 (W6)
; dia start address is: 16 (W8)
; mes end address is: 12 (W6)
; dia end address is: 16 (W8)
	GOTO	L_IncrementarFecha7
L_IncrementarFecha2:
;TIEMPO_RTC.c,197 :: 		if (dia<30){
; mes start address is: 8 (W4)
; dia start address is: 12 (W6)
	CP	W6, #30
	CPB	W7, #0
	BRA LTU	L__IncrementarFecha58
	GOTO	L_IncrementarFecha8
L__IncrementarFecha58:
;TIEMPO_RTC.c,198 :: 		dia++;
; dia start address is: 0 (W0)
	ADD	W6, #1, W0
	ADDC	W7, #0, W1
; dia end address is: 12 (W6)
;TIEMPO_RTC.c,199 :: 		} else {
	PUSH.D	W4
; dia end address is: 0 (W0)
	MOV.D	W2, W4
	MOV.D	W0, W2
	POP.D	W0
	GOTO	L_IncrementarFecha9
L_IncrementarFecha8:
;TIEMPO_RTC.c,200 :: 		if (mes==4||mes==6||mes==9||mes==11){
; dia start address is: 12 (W6)
	CP	W4, #4
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha59
	GOTO	L__IncrementarFecha34
L__IncrementarFecha59:
	CP	W4, #6
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha60
	GOTO	L__IncrementarFecha33
L__IncrementarFecha60:
	CP	W4, #9
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha61
	GOTO	L__IncrementarFecha32
L__IncrementarFecha61:
	CP	W4, #11
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha62
	GOTO	L__IncrementarFecha31
L__IncrementarFecha62:
	MOV.D	W4, W0
	MOV.D	W6, W4
	GOTO	L_IncrementarFecha12
L__IncrementarFecha34:
L__IncrementarFecha33:
L__IncrementarFecha32:
L__IncrementarFecha31:
;TIEMPO_RTC.c,201 :: 		if (dia==30){
	CP	W6, #30
	CPB	W7, #0
	BRA Z	L__IncrementarFecha63
	GOTO	L_IncrementarFecha13
L__IncrementarFecha63:
; dia end address is: 12 (W6)
;TIEMPO_RTC.c,202 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;TIEMPO_RTC.c,203 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
;TIEMPO_RTC.c,204 :: 		} else {
	PUSH.D	W0
; dia end address is: 0 (W0)
	MOV.D	W4, W0
	POP.D	W4
	GOTO	L_IncrementarFecha14
L_IncrementarFecha13:
;TIEMPO_RTC.c,205 :: 		dia++;
; dia start address is: 0 (W0)
; dia start address is: 12 (W6)
	ADD	W6, #1, W0
	ADDC	W7, #0, W1
; dia end address is: 12 (W6)
	PUSH.D	W0
; mes end address is: 8 (W4)
; dia end address is: 0 (W0)
	MOV.D	W4, W0
	POP.D	W4
;TIEMPO_RTC.c,206 :: 		}
L_IncrementarFecha14:
;TIEMPO_RTC.c,207 :: 		}
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
L_IncrementarFecha12:
;TIEMPO_RTC.c,208 :: 		if ((dia!=1)&&(mes==1||mes==3||mes==5||mes==7||mes==8||mes==10)){
; mes start address is: 0 (W0)
; dia start address is: 8 (W4)
	CP	W4, #1
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha64
	GOTO	L__IncrementarFecha44
L__IncrementarFecha64:
	CP	W0, #1
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha65
	GOTO	L__IncrementarFecha40
L__IncrementarFecha65:
	CP	W0, #3
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha66
	GOTO	L__IncrementarFecha39
L__IncrementarFecha66:
	CP	W0, #5
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha67
	GOTO	L__IncrementarFecha38
L__IncrementarFecha67:
	CP	W0, #7
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha68
	GOTO	L__IncrementarFecha37
L__IncrementarFecha68:
	CP	W0, #8
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha69
	GOTO	L__IncrementarFecha36
L__IncrementarFecha69:
	CP	W0, #10
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha70
	GOTO	L__IncrementarFecha35
L__IncrementarFecha70:
	GOTO	L_IncrementarFecha19
L__IncrementarFecha40:
L__IncrementarFecha39:
L__IncrementarFecha38:
L__IncrementarFecha37:
L__IncrementarFecha36:
L__IncrementarFecha35:
L__IncrementarFecha28:
;TIEMPO_RTC.c,209 :: 		if (dia==31){
	CP	W4, #31
	CPB	W5, #0
	BRA Z	L__IncrementarFecha71
	GOTO	L_IncrementarFecha20
L__IncrementarFecha71:
;TIEMPO_RTC.c,210 :: 		dia = 1;
	MOV	#1, W4
	MOV	#0, W5
;TIEMPO_RTC.c,211 :: 		mes++;
	ADD	W0, #1, W0
	ADDC	W1, #0, W1
;TIEMPO_RTC.c,212 :: 		} else {
	GOTO	L_IncrementarFecha21
L_IncrementarFecha20:
;TIEMPO_RTC.c,213 :: 		dia++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
;TIEMPO_RTC.c,214 :: 		}
L_IncrementarFecha21:
;TIEMPO_RTC.c,215 :: 		}
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
L_IncrementarFecha19:
;TIEMPO_RTC.c,208 :: 		if ((dia!=1)&&(mes==1||mes==3||mes==5||mes==7||mes==8||mes==10)){
; mes start address is: 0 (W0)
; dia start address is: 8 (W4)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
	GOTO	L__IncrementarFecha41
L__IncrementarFecha44:
L__IncrementarFecha41:
;TIEMPO_RTC.c,216 :: 		if ((dia!=1)&&(mes==12)){
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
	CP	W4, #1
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha72
	GOTO	L__IncrementarFecha45
L__IncrementarFecha72:
	CP	W0, #12
	CPB	W1, #0
	BRA Z	L__IncrementarFecha73
	GOTO	L__IncrementarFecha46
L__IncrementarFecha73:
L__IncrementarFecha27:
;TIEMPO_RTC.c,217 :: 		if (dia==31){
	CP	W4, #31
	CPB	W5, #0
	BRA Z	L__IncrementarFecha74
	GOTO	L_IncrementarFecha25
L__IncrementarFecha74:
; mes end address is: 0 (W0)
;TIEMPO_RTC.c,218 :: 		dia = 1;
	MOV	#1, W4
	MOV	#0, W5
;TIEMPO_RTC.c,219 :: 		mes = 1;
; mes start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;TIEMPO_RTC.c,220 :: 		anio++;
	ADD	W2, #1, W2
	ADDC	W3, #0, W3
;TIEMPO_RTC.c,221 :: 		} else {
	GOTO	L_IncrementarFecha26
L_IncrementarFecha25:
;TIEMPO_RTC.c,222 :: 		dia++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
;TIEMPO_RTC.c,223 :: 		}
L_IncrementarFecha26:
;TIEMPO_RTC.c,216 :: 		if ((dia!=1)&&(mes==12)){
; dia start address is: 8 (W4)
; anio start address is: 4 (W2)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	GOTO	L__IncrementarFecha43
L__IncrementarFecha45:
L__IncrementarFecha43:
; mes start address is: 0 (W0)
; anio start address is: 4 (W2)
; dia start address is: 8 (W4)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	GOTO	L__IncrementarFecha42
L__IncrementarFecha46:
L__IncrementarFecha42:
;TIEMPO_RTC.c,225 :: 		}
; dia start address is: 8 (W4)
; anio start address is: 4 (W2)
; mes start address is: 0 (W0)
	PUSH.D	W2
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	MOV.D	W4, W2
	POP.D	W4
L_IncrementarFecha9:
;TIEMPO_RTC.c,226 :: 		}
; mes start address is: 0 (W0)
; anio start address is: 8 (W4)
; dia start address is: 4 (W2)
	MOV.D	W0, W6
; mes end address is: 0 (W0)
; anio end address is: 8 (W4)
; dia end address is: 4 (W2)
	MOV.D	W2, W8
	MOV.D	W4, W2
L_IncrementarFecha7:
;TIEMPO_RTC.c,228 :: 		}
; dia start address is: 16 (W8)
; anio start address is: 4 (W2)
; mes start address is: 12 (W6)
; mes end address is: 12 (W6)
; anio end address is: 4 (W2)
; dia end address is: 16 (W8)
L_IncrementarFecha1:
;TIEMPO_RTC.c,230 :: 		fechaInc = (anio*10000)+(mes*100)+(dia);                                   //10000*aa + 100*mm + dd
; mes start address is: 12 (W6)
; anio start address is: 4 (W2)
; dia start address is: 16 (W8)
	MOV	#10000, W0
	MOV	#0, W1
	CALL	__Multiply_32x32
; anio end address is: 4 (W2)
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV.D	W6, W0
	MOV	#100, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
; mes end address is: 12 (W6)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	ADD	W2, W0, W0
	ADDC	W3, W1, W1
	ADD	W0, W8, W0
	ADDC	W1, W9, W1
; dia end address is: 16 (W8)
;TIEMPO_RTC.c,231 :: 		return fechaInc;
;TIEMPO_RTC.c,233 :: 		}
L_end_IncrementarFecha:
	ULNK
	RETURN
; end of _IncrementarFecha

_AjustarTiempoSistema:
	LNK	#14

;TIEMPO_RTC.c,236 :: 		void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned char *tramaTiempoSistema){
	MOV	[W14-8], W0
	MOV	W0, [W14-8]
;TIEMPO_RTC.c,245 :: 		hora = (char)(longHora / 3600);
	PUSH.D	W12
	PUSH.D	W10
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
	MOV.B	W0, [W14+0]
;TIEMPO_RTC.c,246 :: 		minuto = (char)((longHora%3600) / 60);
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
;TIEMPO_RTC.c,247 :: 		segundo = (char)((longHora%3600) % 60);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W12
	MOV.B	W0, [W14+2]
;TIEMPO_RTC.c,249 :: 		anio = (char)(longFecha / 10000);
	PUSH.D	W12
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W12
	MOV.B	W0, [W14+4]
;TIEMPO_RTC.c,250 :: 		mes = (char)((longFecha%10000) / 100);
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
	MOV.B	W0, [W14+3]
;TIEMPO_RTC.c,251 :: 		dia = (char)((longFecha%10000) % 100);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
; dia start address is: 4 (W2)
	MOV.B	W0, W2
;TIEMPO_RTC.c,253 :: 		tramaTiempoSistema[0] = anio;
	MOV	[W14-8], W1
	MOV.B	[W14+4], W0
	MOV.B	W0, [W1]
;TIEMPO_RTC.c,254 :: 		tramaTiempoSistema[1] = mes;
	MOV	[W14-8], W0
	ADD	W0, #1, W1
	MOV.B	[W14+3], W0
	MOV.B	W0, [W1]
;TIEMPO_RTC.c,255 :: 		tramaTiempoSistema[2] = dia;
	MOV	[W14-8], W0
	INC2	W0
	MOV.B	W2, [W0]
; dia end address is: 4 (W2)
;TIEMPO_RTC.c,256 :: 		tramaTiempoSistema[3] = hora;
	MOV	[W14-8], W0
	ADD	W0, #3, W1
	MOV.B	[W14+0], W0
	MOV.B	W0, [W1]
;TIEMPO_RTC.c,257 :: 		tramaTiempoSistema[4] = minuto;
	MOV	[W14-8], W0
	ADD	W0, #4, W1
	MOV.B	[W14+1], W0
	MOV.B	W0, [W1]
;TIEMPO_RTC.c,258 :: 		tramaTiempoSistema[5] = segundo;
	MOV	[W14-8], W0
	ADD	W0, #5, W1
	MOV.B	[W14+2], W0
	MOV.B	W0, [W1]
;TIEMPO_RTC.c,260 :: 		}
L_end_AjustarTiempoSistema:
	ULNK
	RETURN
; end of _AjustarTiempoSistema
