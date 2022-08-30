
_ADXL355_init:

;adxl355_spi.c,106 :: 		void ADXL355_init(short tMuestreo){
;adxl355_spi.c,107 :: 		ADXL355_write_byte(Reset,0x52);                                             //Resetea el dispositivo
	PUSH	W10
	PUSH	W11
	PUSH	W10
	MOV.B	#82, W11
	MOV.B	#47, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,108 :: 		Delay_ms(10);
	MOV	#2, W8
	MOV	#14464, W7
L_ADXL355_init0:
	DEC	W7
	BRA NZ	L_ADXL355_init0
	DEC	W8
	BRA NZ	L_ADXL355_init0
	NOP
	NOP
;adxl355_spi.c,109 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|STANDBY);
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,110 :: 		ADXL355_write_byte(Range, _2G);
	MOV.B	#1, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
	POP	W10
;adxl355_spi.c,111 :: 		switch (tMuestreo){
	GOTO	L_ADXL355_init2
;adxl355_spi.c,112 :: 		case 1:
L_ADXL355_init4:
;adxl355_spi.c,113 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_62_5_Hz);       //ODR=250Hz 1
	MOV.B	#4, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,114 :: 		break;
	GOTO	L_ADXL355_init3
;adxl355_spi.c,115 :: 		case 2:
L_ADXL355_init5:
;adxl355_spi.c,116 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_31_25_Hz);      //ODR=125Hz 2
	MOV.B	#5, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,117 :: 		break;
	GOTO	L_ADXL355_init3
;adxl355_spi.c,118 :: 		case 4:
L_ADXL355_init6:
;adxl355_spi.c,119 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_15_625_Hz);     //ODR=62.5Hz 4
	MOV.B	#6, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,120 :: 		break;
	GOTO	L_ADXL355_init3
;adxl355_spi.c,121 :: 		case 8:
L_ADXL355_init7:
;adxl355_spi.c,122 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_7_813_Hz );     //ODR=31.25Hz 8
	MOV.B	#7, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,123 :: 		break;
	GOTO	L_ADXL355_init3
;adxl355_spi.c,124 :: 		}
L_ADXL355_init2:
	CP.B	W10, #1
	BRA NZ	L__ADXL355_init293
	GOTO	L_ADXL355_init4
L__ADXL355_init293:
	CP.B	W10, #2
	BRA NZ	L__ADXL355_init294
	GOTO	L_ADXL355_init5
L__ADXL355_init294:
	CP.B	W10, #4
	BRA NZ	L__ADXL355_init295
	GOTO	L_ADXL355_init6
L__ADXL355_init295:
	CP.B	W10, #8
	BRA NZ	L__ADXL355_init296
	GOTO	L_ADXL355_init7
L__ADXL355_init296:
L_ADXL355_init3:
;adxl355_spi.c,125 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;adxl355_spi.c,128 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;adxl355_spi.c,129 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;adxl355_spi.c,130 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,131 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,132 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;adxl355_spi.c,133 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,134 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;adxl355_spi.c,137 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;adxl355_spi.c,138 :: 		unsigned char value = 0x00;
	PUSH	W10
;adxl355_spi.c,139 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,140 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,141 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,142 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;adxl355_spi.c,143 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,144 :: 		return value;
;adxl355_spi.c,145 :: 		}
;adxl355_spi.c,144 :: 		return value;
;adxl355_spi.c,145 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_data:

;adxl355_spi.c,148 :: 		unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
;adxl355_spi.c,151 :: 		if((ADXL355_read_byte(Status)&0x01)==1){                                 //Verifica que el bit DATA_RDY del registro Status este en alto
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W0
	AND	W0, #1, W0
	CP	W0, #1
	BRA Z	L__ADXL355_read_data300
	GOTO	L_ADXL355_read_data8
L__ADXL355_read_data300:
;adxl355_spi.c,152 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,153 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data9:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data301
	GOTO	L_ADXL355_read_data10
L__ADXL355_read_data301:
;adxl355_spi.c,154 :: 		muestra = ADXL355_read_byte(axisAddresses[j]);
	ZE	W2, W1
	MOV	#lo_addr(_axisAddresses), W0
	ADD	W0, W1, W0
	PUSH	W10
	MOV.B	[W0], W10
	CALL	_ADXL355_read_byte
	POP	W10
;adxl355_spi.c,155 :: 		vectorMuestra[j] = muestra;
	ZE	W2, W1
	ADD	W10, W1, W1
	MOV.B	W0, [W1]
;adxl355_spi.c,153 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,156 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data9
L_ADXL355_read_data10:
;adxl355_spi.c,157 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,158 :: 		} else {
	GOTO	L_ADXL355_read_data12
L_ADXL355_read_data8:
;adxl355_spi.c,159 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data13:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data302
	GOTO	L_ADXL355_read_data14
L__ADXL355_read_data302:
;adxl355_spi.c,160 :: 		vectorMuestra[j] = 0;
	ZE	W2, W0
	ADD	W10, W0, W1
	CLR	W0
	MOV.B	W0, [W1]
;adxl355_spi.c,159 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,161 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data13
L_ADXL355_read_data14:
;adxl355_spi.c,162 :: 		}
L_ADXL355_read_data12:
;adxl355_spi.c,163 :: 		return;
;adxl355_spi.c,164 :: 		}
L_end_ADXL355_read_data:
	RETURN
; end of _ADXL355_read_data

_ADXL355_read_FIFO:
	LNK	#2

;adxl355_spi.c,167 :: 		unsigned int ADXL355_read_FIFO(unsigned char *vectorFIFO){
;adxl355_spi.c,170 :: 		CS_ADXL355 = 0;
	PUSH	W10
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,171 :: 		SPI2_Write(add);
	PUSH	W10
	MOV	#35, W10
	CALL	_SPI2_Write
	POP	W10
;adxl355_spi.c,173 :: 		vectorFIFO[0] = SPI2_Read(0);
	MOV	W10, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,174 :: 		vectorFIFO[1] = SPI2_Read(1);
	ADD	W10, #1, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,175 :: 		vectorFIFO[2] = SPI2_Read(2);
	ADD	W10, #2, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,177 :: 		vectorFIFO[3] = SPI2_Read(0);
	ADD	W10, #3, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,178 :: 		vectorFIFO[4] = SPI2_Read(1);
	ADD	W10, #4, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,179 :: 		vectorFIFO[5] = SPI2_Read(2);
	ADD	W10, #5, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#2, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,181 :: 		vectorFIFO[6] = SPI2_Read(0);
	ADD	W10, #6, W0
	MOV	W0, [W14+0]
	PUSH	W10
	CLR	W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,182 :: 		vectorFIFO[7] = SPI2_Read(1);
	ADD	W10, #7, W0
	MOV	W0, [W14+0]
	PUSH	W10
	MOV	#1, W10
	CALL	_SPI2_Read
	POP	W10
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,183 :: 		vectorFIFO[8] = SPI2_Read(2);
	ADD	W10, #8, W0
	MOV	W0, [W14+0]
	MOV	#2, W10
	CALL	_SPI2_Read
	MOV	[W14+0], W1
	MOV.B	W0, [W1]
;adxl355_spi.c,184 :: 		CS_ADXL355 = 1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,185 :: 		Delay_us(5);
	MOV	#40, W7
L_ADXL355_read_FIFO16:
	DEC	W7
	BRA NZ	L_ADXL355_read_FIFO16
	NOP
	NOP
;adxl355_spi.c,187 :: 		}
;adxl355_spi.c,186 :: 		return;
;adxl355_spi.c,187 :: 		}
L_end_ADXL355_read_FIFO:
	POP	W10
	ULNK
	RETURN
; end of _ADXL355_read_FIFO

_GPS_init:

;tiempo_gps.c,12 :: 		void GPS_init()
;tiempo_gps.c,48 :: 		UART1_Write_Text("$PMTK220,1000*1F\r\n"); // Set position fix interval. Interval: Position fix interval [msec]. Must be larger than 200.
	PUSH	W10
	MOV	#lo_addr(?lstr1_Acelerografo), W10
	CALL	_UART1_Write_Text
;tiempo_gps.c,49 :: 		Delay_ms(1000);
	MOV	#123, W8
	MOV	#4681, W7
L_GPS_init18:
	DEC	W7
	BRA NZ	L_GPS_init18
	DEC	W8
	BRA NZ	L_GPS_init18
;tiempo_gps.c,50 :: 		UART1_Write_Text("$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29\r\n"); // GPRMC
	MOV	#lo_addr(?lstr2_Acelerografo), W10
	CALL	_UART1_Write_Text
;tiempo_gps.c,51 :: 		Delay_ms(1000);
	MOV	#123, W8
	MOV	#4681, W7
L_GPS_init20:
	DEC	W7
	BRA NZ	L_GPS_init20
	DEC	W8
	BRA NZ	L_GPS_init20
;tiempo_gps.c,52 :: 		}
L_end_GPS_init:
	POP	W10
	RETURN
; end of _GPS_init

_RecuperarFechaGPS:
	LNK	#28

;tiempo_gps.c,57 :: 		unsigned long RecuperarFechaGPS(unsigned char *tramaDatosGPS)
;tiempo_gps.c,63 :: 		char *ptrDatoStringF = &datoStringF;
	PUSH	W10
	ADD	W14, #16, W4
	MOV	W4, [W14+26]
; ptrDatoStringF start address is: 12 (W6)
	MOV	W4, W6
;tiempo_gps.c,64 :: 		datoStringF[2] = '\0';
	ADD	W4, #2, W1
	CLR	W0
	MOV.B	W0, [W1]
;tiempo_gps.c,65 :: 		tramaFecha[3] = '\0';
	ADD	W14, #0, W3
	MOV	W3, [W14+24]
	ADD	W3, #12, W2
	CLR	W0
	CLR	W1
	MOV.D	W0, [W2]
;tiempo_gps.c,68 :: 		datoStringF[0] = tramaDatosGPS[6];
	ADD	W10, #6, W0
	MOV.B	[W0], [W4]
;tiempo_gps.c,69 :: 		datoStringF[1] = tramaDatosGPS[7];
	ADD	W4, #1, W1
	ADD	W10, #7, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,70 :: 		tramaFecha[0] = atoi(ptrDatoStringF);
	MOV	W3, W0
	MOV	W0, [W14+20]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,73 :: 		datoStringF[0] = tramaDatosGPS[8];
	ADD	W10, #8, W1
	MOV	[W14+26], W0
	MOV.B	[W1], [W0]
;tiempo_gps.c,74 :: 		datoStringF[1] = tramaDatosGPS[9];
	ADD	W0, #1, W1
	ADD	W10, #9, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,75 :: 		tramaFecha[1] = atoi(ptrDatoStringF);
	MOV	[W14+24], W0
	ADD	W0, #4, W0
	MOV	W0, [W14+20]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,78 :: 		datoStringF[0] = tramaDatosGPS[10];
	ADD	W10, #10, W1
	MOV	[W14+26], W0
	MOV.B	[W1], [W0]
;tiempo_gps.c,79 :: 		datoStringF[1] = tramaDatosGPS[11];
	ADD	W0, #1, W1
	ADD	W10, #11, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,80 :: 		tramaFecha[2] = atoi(ptrDatoStringF);
	MOV	[W14+24], W0
	ADD	W0, #8, W0
	MOV	W0, [W14+20]
	MOV	W6, W10
; ptrDatoStringF end address is: 12 (W6)
	CALL	_atoi
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,82 :: 		fechaGPS = (tramaFecha[0] * 10000) + (tramaFecha[1] * 100) + (tramaFecha[2]); // 10000*dd + 100*mm + aa
	MOV	[W14+24], W2
	MOV.D	[W2], W0
	MOV	#10000, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+24], W2
	MOV	W0, [W14+20]
	MOV	W1, [W14+22]
	ADD	W2, #4, W2
	MOV.D	[W2], W0
	MOV	#100, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+20], W2
	MOV	[W14+22], W3
	ADD	W2, W0, W4
	ADDC	W3, W1, W5
	MOV	[W14+24], W0
	ADD	W0, #8, W2
	ADD	W4, [W2++], W0
	ADDC	W5, [W2--], W1
;tiempo_gps.c,84 :: 		return fechaGPS;
;tiempo_gps.c,85 :: 		}
;tiempo_gps.c,84 :: 		return fechaGPS;
;tiempo_gps.c,85 :: 		}
L_end_RecuperarFechaGPS:
	POP	W10
	ULNK
	RETURN
; end of _RecuperarFechaGPS

_RecuperarHoraGPS:
	LNK	#28

;tiempo_gps.c,88 :: 		unsigned long RecuperarHoraGPS(unsigned char *tramaDatosGPS)
;tiempo_gps.c,94 :: 		char *ptrDatoString = &datoString;
	PUSH	W10
	ADD	W14, #16, W4
	MOV	W4, [W14+26]
; ptrDatoString start address is: 12 (W6)
	MOV	W4, W6
;tiempo_gps.c,95 :: 		datoString[2] = '\0';
	ADD	W4, #2, W1
	CLR	W0
	MOV.B	W0, [W1]
;tiempo_gps.c,96 :: 		tramaTiempo[3] = '\0';
	ADD	W14, #0, W3
	MOV	W3, [W14+24]
	ADD	W3, #12, W2
	CLR	W0
	CLR	W1
	MOV.D	W0, [W2]
;tiempo_gps.c,99 :: 		datoString[0] = tramaDatosGPS[0];
	MOV.B	[W10], [W4]
;tiempo_gps.c,100 :: 		datoString[1] = tramaDatosGPS[1];
	ADD	W4, #1, W1
	ADD	W10, #1, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,101 :: 		tramaTiempo[0] = atoi(ptrDatoString);
	MOV	W3, W0
	MOV	W0, [W14+20]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,104 :: 		datoString[0] = tramaDatosGPS[2];
	ADD	W10, #2, W1
	MOV	[W14+26], W0
	MOV.B	[W1], [W0]
;tiempo_gps.c,105 :: 		datoString[1] = tramaDatosGPS[3];
	ADD	W0, #1, W1
	ADD	W10, #3, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,106 :: 		tramaTiempo[1] = atoi(ptrDatoString);
	MOV	[W14+24], W0
	ADD	W0, #4, W0
	MOV	W0, [W14+20]
	PUSH	W10
	MOV	W6, W10
	CALL	_atoi
	POP	W10
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,109 :: 		datoString[0] = tramaDatosGPS[4];
	ADD	W10, #4, W1
	MOV	[W14+26], W0
	MOV.B	[W1], [W0]
;tiempo_gps.c,110 :: 		datoString[1] = tramaDatosGPS[5];
	ADD	W0, #1, W1
	ADD	W10, #5, W0
	MOV.B	[W0], [W1]
;tiempo_gps.c,111 :: 		tramaTiempo[2] = atoi(ptrDatoString);
	MOV	[W14+24], W0
	ADD	W0, #8, W0
	MOV	W0, [W14+20]
	MOV	W6, W10
; ptrDatoString end address is: 12 (W6)
	CALL	_atoi
	MOV	W0, W1
	ASR	W1, #15, W2
	MOV	[W14+20], W0
	MOV	W1, [W0++]
	MOV	W2, [W0--]
;tiempo_gps.c,113 :: 		horaGPS = (tramaTiempo[0] * 3600) + (tramaTiempo[1] * 60) + (tramaTiempo[2]); // Calcula el segundo actual = hh*3600 + mm*60 + ss
	MOV	[W14+24], W2
	MOV.D	[W2], W0
	MOV	#3600, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+24], W2
	MOV	W0, [W14+20]
	MOV	W1, [W14+22]
	ADD	W2, #4, W2
	MOV.D	[W2], W0
	MOV	#60, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+20], W2
	MOV	[W14+22], W3
	ADD	W2, W0, W4
	ADDC	W3, W1, W5
	MOV	[W14+24], W0
	ADD	W0, #8, W2
	ADD	W4, [W2++], W0
	ADDC	W5, [W2--], W1
;tiempo_gps.c,114 :: 		return horaGPS;
;tiempo_gps.c,115 :: 		}
;tiempo_gps.c,114 :: 		return horaGPS;
;tiempo_gps.c,115 :: 		}
L_end_RecuperarHoraGPS:
	POP	W10
	ULNK
	RETURN
; end of _RecuperarHoraGPS

_DS3234_init:

;tiempo_rtc.c,55 :: 		void DS3234_init(){
;tiempo_rtc.c,57 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
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
;tiempo_rtc.c,58 :: 		DS3234_write_byte(Control,0x20);
	MOV.B	#32, W11
	MOV.B	#142, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,59 :: 		DS3234_write_byte(ControlStatus,0x08);
	MOV.B	#8, W11
	MOV.B	#143, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,60 :: 		SPI2_Init();
	CALL	_SPI2_Init
;tiempo_rtc.c,62 :: 		}
L_end_DS3234_init:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _DS3234_init

_DS3234_write_byte:

;tiempo_rtc.c,65 :: 		void DS3234_write_byte(unsigned char address, unsigned char value){
;tiempo_rtc.c,67 :: 		CS_DS3234 = 0;
	PUSH	W10
	BCLR	LATA2_bit, BitPos(LATA2_bit+0)
;tiempo_rtc.c,68 :: 		SPI2_Write(address);
	ZE	W10, W10
	CALL	_SPI2_Write
;tiempo_rtc.c,69 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;tiempo_rtc.c,70 :: 		CS_DS3234 = 1;
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;tiempo_rtc.c,72 :: 		}
L_end_DS3234_write_byte:
	POP	W10
	RETURN
; end of _DS3234_write_byte

_DS3234_read_byte:

;tiempo_rtc.c,75 :: 		unsigned char DS3234_read_byte(unsigned char address){
;tiempo_rtc.c,77 :: 		unsigned char value = 0x00;
	PUSH	W10
;tiempo_rtc.c,78 :: 		CS_DS3234 = 0;
	BCLR	LATA2_bit, BitPos(LATA2_bit+0)
;tiempo_rtc.c,79 :: 		SPI2_Write(address);
	ZE	W10, W10
	CALL	_SPI2_Write
;tiempo_rtc.c,80 :: 		value = SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;tiempo_rtc.c,81 :: 		CS_DS3234 = 1;
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;tiempo_rtc.c,82 :: 		return value;
;tiempo_rtc.c,84 :: 		}
;tiempo_rtc.c,82 :: 		return value;
;tiempo_rtc.c,84 :: 		}
L_end_DS3234_read_byte:
	POP	W10
	RETURN
; end of _DS3234_read_byte

_DS3234_setDate:
	LNK	#14

;tiempo_rtc.c,87 :: 		void DS3234_setDate(unsigned long longHora, unsigned long longFecha){
;tiempo_rtc.c,97 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
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
;tiempo_rtc.c,99 :: 		hora = (short)(longHora / 3600);
	PUSH.D	W10
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
	MOV.B	W0, [W14+0]
;tiempo_rtc.c,100 :: 		minuto = (short)((longHora%3600) / 60);
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
;tiempo_rtc.c,101 :: 		segundo = (short)((longHora%3600) % 60);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W12
	MOV.B	W0, [W14+2]
;tiempo_rtc.c,103 :: 		dia = (short)(longFecha / 10000);
	PUSH.D	W12
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W12
	MOV.B	W0, [W14+3]
;tiempo_rtc.c,104 :: 		mes = (short)((longFecha%10000) / 100);
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
;tiempo_rtc.c,105 :: 		anio = (short)((longFecha%10000) % 100);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
; anio start address is: 8 (W4)
	MOV.B	W0, W4
;tiempo_rtc.c,107 :: 		segundo = Dec2Bcd(segundo);
	MOV.B	[W14+2], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+2]
;tiempo_rtc.c,108 :: 		minuto = Dec2Bcd(minuto);
	MOV.B	[W14+1], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+1]
;tiempo_rtc.c,109 :: 		hora = Dec2Bcd(hora);
	MOV.B	[W14+0], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+0]
;tiempo_rtc.c,110 :: 		dia = Dec2Bcd(dia);
	MOV.B	[W14+3], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+3]
;tiempo_rtc.c,111 :: 		mes = Dec2Bcd(mes);
	MOV.B	[W14+4], W10
	CALL	_Dec2Bcd
	MOV.B	W0, [W14+4]
;tiempo_rtc.c,112 :: 		anio = Dec2Bcd(anio);
	MOV.B	W4, W10
; anio end address is: 8 (W4)
	CALL	_Dec2Bcd
; anio start address is: 2 (W1)
	MOV.B	W0, W1
;tiempo_rtc.c,114 :: 		DS3234_write_byte(Segundos_Esc, segundo);
	MOV.B	[W14+2], W11
	MOV.B	#128, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,115 :: 		DS3234_write_byte(Minutos_Esc, minuto);
	MOV.B	[W14+1], W11
	MOV.B	#129, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,116 :: 		DS3234_write_byte(Horas_Esc, hora);
	MOV.B	[W14+0], W11
	MOV.B	#130, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,117 :: 		DS3234_write_byte(DiaMes_Esc, dia);
	MOV.B	[W14+3], W11
	MOV.B	#132, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,118 :: 		DS3234_write_byte(Mes_Esc, mes);
	MOV.B	[W14+4], W11
	MOV.B	#133, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,119 :: 		DS3234_write_byte(Anio_Esc, anio);
	MOV.B	W1, W11
; anio end address is: 2 (W1)
	MOV.B	#134, W10
	CALL	_DS3234_write_byte
;tiempo_rtc.c,121 :: 		SPI2_Init();
	CALL	_SPI2_Init
;tiempo_rtc.c,125 :: 		}
;tiempo_rtc.c,123 :: 		return;
;tiempo_rtc.c,125 :: 		}
L_end_DS3234_setDate:
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _DS3234_setDate

_RecuperarHoraRTC:
	LNK	#4

;tiempo_rtc.c,128 :: 		unsigned long RecuperarHoraRTC(){
;tiempo_rtc.c,136 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
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
;tiempo_rtc.c,138 :: 		valueRead = DS3234_read_byte(Segundos_Lec);
	CLR	W10
	CALL	_DS3234_read_byte
;tiempo_rtc.c,139 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,140 :: 		segundo = (long)valueRead;
; segundo start address is: 12 (W6)
	ZE	W0, W6
	CLR	W7
;tiempo_rtc.c,141 :: 		valueRead = DS3234_read_byte(Minutos_Lec);
	MOV.B	#1, W10
	CALL	_DS3234_read_byte
;tiempo_rtc.c,142 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,143 :: 		minuto = (long)valueRead;
; minuto start address is: 16 (W8)
	ZE	W0, W8
	CLR	W9
;tiempo_rtc.c,144 :: 		valueRead = DS3234_read_byte(Horas_Lec);
	MOV.B	#2, W10
	CALL	_DS3234_read_byte
;tiempo_rtc.c,145 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,146 :: 		hora = (long)valueRead;
	ZE	W0, W0
	CLR	W1
;tiempo_rtc.c,148 :: 		horaRTC = (hora*3600)+(minuto*60)+(segundo);                               //Calcula el segundo actual = hh*3600 + mm*60 + ss
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
;tiempo_rtc.c,150 :: 		SPI2_Init();
	CALL	_SPI2_Init
;tiempo_rtc.c,152 :: 		return horaRTC;
	MOV.D	W2, W0
; horaRTC end address is: 4 (W2)
;tiempo_rtc.c,154 :: 		}
;tiempo_rtc.c,152 :: 		return horaRTC;
;tiempo_rtc.c,154 :: 		}
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

;tiempo_rtc.c,157 :: 		unsigned long RecuperarFechaRTC(){
;tiempo_rtc.c,165 :: 		SPI2_Init_Advanced(_SPI_MASTER, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_64, _SPI_SS_DISABLE, _SPI_DATA_SAMPLE_MIDDLE, _SPI_CLK_IDLE_LOW, _SPI_ACTIVE_2_IDLE);
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
;tiempo_rtc.c,167 :: 		valueRead = DS3234_read_byte(DiaMes_Lec);
	MOV.B	#4, W10
	CALL	_DS3234_read_byte
;tiempo_rtc.c,168 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,169 :: 		dia = (long)valueRead;
; dia start address is: 12 (W6)
	ZE	W0, W6
	CLR	W7
;tiempo_rtc.c,170 :: 		valueRead = 0x1F & DS3234_read_byte(Mes_Lec);
	MOV.B	#5, W10
	CALL	_DS3234_read_byte
	ZE	W0, W0
	AND	W0, #31, W0
;tiempo_rtc.c,171 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,172 :: 		mes = (long)valueRead;
; mes start address is: 16 (W8)
	ZE	W0, W8
	CLR	W9
;tiempo_rtc.c,173 :: 		valueRead = DS3234_read_byte(Anio_Lec);
	MOV.B	#6, W10
	CALL	_DS3234_read_byte
;tiempo_rtc.c,174 :: 		valueRead = Bcd2Dec(valueRead);
	MOV.B	W0, W10
	CALL	_Bcd2Dec
;tiempo_rtc.c,175 :: 		anio = (long)valueRead;
	ZE	W0, W0
	CLR	W1
;tiempo_rtc.c,177 :: 		fechaRTC = (anio*10000)+(mes*100)+(dia);                                   //10000*aa + 100*mm + dd
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
;tiempo_rtc.c,179 :: 		SPI2_Init();
	CALL	_SPI2_Init
;tiempo_rtc.c,181 :: 		return fechaRTC;
	MOV.D	W2, W0
; fechaRTC end address is: 4 (W2)
;tiempo_rtc.c,183 :: 		}
;tiempo_rtc.c,181 :: 		return fechaRTC;
;tiempo_rtc.c,183 :: 		}
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

;tiempo_rtc.c,186 :: 		unsigned long IncrementarFecha(unsigned long longFecha){
;tiempo_rtc.c,193 :: 		anio = longFecha / 10000;
	PUSH.D	W10
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
; anio start address is: 4 (W2)
	MOV.D	W0, W2
;tiempo_rtc.c,194 :: 		mes = (longFecha%10000) / 100;
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
;tiempo_rtc.c,195 :: 		dia = (longFecha%10000) % 100;
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
;tiempo_rtc.c,197 :: 		if (dia<28){
	CP	W0, #28
	CPB	W1, #0
	BRA LTU	L__IncrementarFecha314
	GOTO	L_IncrementarFecha22
L__IncrementarFecha314:
;tiempo_rtc.c,198 :: 		dia++;
; dia start address is: 16 (W8)
	ADD	W6, #1, W8
	ADDC	W7, #0, W9
; dia end address is: 12 (W6)
;tiempo_rtc.c,199 :: 		} else {
; dia end address is: 16 (W8)
	MOV.D	W4, W6
	GOTO	L_IncrementarFecha23
L_IncrementarFecha22:
;tiempo_rtc.c,200 :: 		if (mes==2){
; dia start address is: 12 (W6)
	CP	W4, #2
	CPB	W5, #0
	BRA Z	L__IncrementarFecha315
	GOTO	L_IncrementarFecha24
L__IncrementarFecha315:
;tiempo_rtc.c,202 :: 		if (((anio-16)%4)==0){
	SUB	W2, #16, W0
	SUBB	W3, #0, W1
	AND	W0, #3, W0
	AND	W1, #0, W1
	CP	W0, #0
	CPB	W1, #0
	BRA Z	L__IncrementarFecha316
	GOTO	L_IncrementarFecha25
L__IncrementarFecha316:
;tiempo_rtc.c,203 :: 		if (dia==29){
	CP	W6, #29
	CPB	W7, #0
	BRA Z	L__IncrementarFecha317
	GOTO	L_IncrementarFecha26
L__IncrementarFecha317:
; dia end address is: 12 (W6)
;tiempo_rtc.c,204 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;tiempo_rtc.c,205 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
;tiempo_rtc.c,206 :: 		} else {
; dia end address is: 0 (W0)
	GOTO	L_IncrementarFecha27
L_IncrementarFecha26:
;tiempo_rtc.c,207 :: 		dia++;
; dia start address is: 0 (W0)
; dia start address is: 12 (W6)
	ADD	W6, #1, W0
	ADDC	W7, #0, W1
; dia end address is: 12 (W6)
; mes end address is: 8 (W4)
; dia end address is: 0 (W0)
;tiempo_rtc.c,208 :: 		}
L_IncrementarFecha27:
;tiempo_rtc.c,209 :: 		} else {
; dia start address is: 0 (W0)
; mes start address is: 8 (W4)
	MOV.D	W0, W8
; dia end address is: 0 (W0)
	MOV.D	W4, W6
	GOTO	L_IncrementarFecha28
L_IncrementarFecha25:
;tiempo_rtc.c,210 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;tiempo_rtc.c,211 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
	MOV.D	W0, W8
; mes end address is: 8 (W4)
; dia end address is: 0 (W0)
	MOV.D	W4, W6
;tiempo_rtc.c,212 :: 		}
L_IncrementarFecha28:
;tiempo_rtc.c,213 :: 		} else {
; mes start address is: 12 (W6)
; dia start address is: 16 (W8)
; mes end address is: 12 (W6)
; dia end address is: 16 (W8)
	GOTO	L_IncrementarFecha29
L_IncrementarFecha24:
;tiempo_rtc.c,214 :: 		if (dia<30){
; mes start address is: 8 (W4)
; dia start address is: 12 (W6)
	CP	W6, #30
	CPB	W7, #0
	BRA LTU	L__IncrementarFecha318
	GOTO	L_IncrementarFecha30
L__IncrementarFecha318:
;tiempo_rtc.c,215 :: 		dia++;
; dia start address is: 0 (W0)
	ADD	W6, #1, W0
	ADDC	W7, #0, W1
; dia end address is: 12 (W6)
;tiempo_rtc.c,216 :: 		} else {
	PUSH.D	W4
; dia end address is: 0 (W0)
	MOV.D	W2, W4
	MOV.D	W0, W2
	POP.D	W0
	GOTO	L_IncrementarFecha31
L_IncrementarFecha30:
;tiempo_rtc.c,217 :: 		if (mes==4||mes==6||mes==9||mes==11){
; dia start address is: 12 (W6)
	CP	W4, #4
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha319
	GOTO	L__IncrementarFecha207
L__IncrementarFecha319:
	CP	W4, #6
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha320
	GOTO	L__IncrementarFecha206
L__IncrementarFecha320:
	CP	W4, #9
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha321
	GOTO	L__IncrementarFecha205
L__IncrementarFecha321:
	CP	W4, #11
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha322
	GOTO	L__IncrementarFecha204
L__IncrementarFecha322:
	MOV.D	W4, W0
	MOV.D	W6, W4
	GOTO	L_IncrementarFecha34
L__IncrementarFecha207:
L__IncrementarFecha206:
L__IncrementarFecha205:
L__IncrementarFecha204:
;tiempo_rtc.c,218 :: 		if (dia==30){
	CP	W6, #30
	CPB	W7, #0
	BRA Z	L__IncrementarFecha323
	GOTO	L_IncrementarFecha35
L__IncrementarFecha323:
; dia end address is: 12 (W6)
;tiempo_rtc.c,219 :: 		dia = 1;
; dia start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;tiempo_rtc.c,220 :: 		mes++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
;tiempo_rtc.c,221 :: 		} else {
	PUSH.D	W0
; dia end address is: 0 (W0)
	MOV.D	W4, W0
	POP.D	W4
	GOTO	L_IncrementarFecha36
L_IncrementarFecha35:
;tiempo_rtc.c,222 :: 		dia++;
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
;tiempo_rtc.c,223 :: 		}
L_IncrementarFecha36:
;tiempo_rtc.c,224 :: 		}
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
L_IncrementarFecha34:
;tiempo_rtc.c,225 :: 		if ((dia!=1)&&(mes==1||mes==3||mes==5||mes==7||mes==8||mes==10)){
; mes start address is: 0 (W0)
; dia start address is: 8 (W4)
	CP	W4, #1
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha324
	GOTO	L__IncrementarFecha217
L__IncrementarFecha324:
	CP	W0, #1
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha325
	GOTO	L__IncrementarFecha213
L__IncrementarFecha325:
	CP	W0, #3
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha326
	GOTO	L__IncrementarFecha212
L__IncrementarFecha326:
	CP	W0, #5
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha327
	GOTO	L__IncrementarFecha211
L__IncrementarFecha327:
	CP	W0, #7
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha328
	GOTO	L__IncrementarFecha210
L__IncrementarFecha328:
	CP	W0, #8
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha329
	GOTO	L__IncrementarFecha209
L__IncrementarFecha329:
	CP	W0, #10
	CPB	W1, #0
	BRA NZ	L__IncrementarFecha330
	GOTO	L__IncrementarFecha208
L__IncrementarFecha330:
	GOTO	L_IncrementarFecha41
L__IncrementarFecha213:
L__IncrementarFecha212:
L__IncrementarFecha211:
L__IncrementarFecha210:
L__IncrementarFecha209:
L__IncrementarFecha208:
L__IncrementarFecha201:
;tiempo_rtc.c,226 :: 		if (dia==31){
	CP	W4, #31
	CPB	W5, #0
	BRA Z	L__IncrementarFecha331
	GOTO	L_IncrementarFecha42
L__IncrementarFecha331:
;tiempo_rtc.c,227 :: 		dia = 1;
	MOV	#1, W4
	MOV	#0, W5
;tiempo_rtc.c,228 :: 		mes++;
	ADD	W0, #1, W0
	ADDC	W1, #0, W1
;tiempo_rtc.c,229 :: 		} else {
	GOTO	L_IncrementarFecha43
L_IncrementarFecha42:
;tiempo_rtc.c,230 :: 		dia++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
;tiempo_rtc.c,231 :: 		}
L_IncrementarFecha43:
;tiempo_rtc.c,232 :: 		}
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
L_IncrementarFecha41:
;tiempo_rtc.c,225 :: 		if ((dia!=1)&&(mes==1||mes==3||mes==5||mes==7||mes==8||mes==10)){
; mes start address is: 0 (W0)
; dia start address is: 8 (W4)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
	GOTO	L__IncrementarFecha214
L__IncrementarFecha217:
L__IncrementarFecha214:
;tiempo_rtc.c,233 :: 		if ((dia!=1)&&(mes==12)){
; dia start address is: 8 (W4)
; mes start address is: 0 (W0)
	CP	W4, #1
	CPB	W5, #0
	BRA NZ	L__IncrementarFecha332
	GOTO	L__IncrementarFecha218
L__IncrementarFecha332:
	CP	W0, #12
	CPB	W1, #0
	BRA Z	L__IncrementarFecha333
	GOTO	L__IncrementarFecha219
L__IncrementarFecha333:
L__IncrementarFecha200:
;tiempo_rtc.c,234 :: 		if (dia==31){
	CP	W4, #31
	CPB	W5, #0
	BRA Z	L__IncrementarFecha334
	GOTO	L_IncrementarFecha47
L__IncrementarFecha334:
; mes end address is: 0 (W0)
;tiempo_rtc.c,235 :: 		dia = 1;
	MOV	#1, W4
	MOV	#0, W5
;tiempo_rtc.c,236 :: 		mes = 1;
; mes start address is: 0 (W0)
	MOV	#1, W0
	MOV	#0, W1
;tiempo_rtc.c,237 :: 		anio++;
	ADD	W2, #1, W2
	ADDC	W3, #0, W3
;tiempo_rtc.c,238 :: 		} else {
	GOTO	L_IncrementarFecha48
L_IncrementarFecha47:
;tiempo_rtc.c,239 :: 		dia++;
	ADD	W4, #1, W4
	ADDC	W5, #0, W5
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
;tiempo_rtc.c,240 :: 		}
L_IncrementarFecha48:
;tiempo_rtc.c,233 :: 		if ((dia!=1)&&(mes==12)){
; dia start address is: 8 (W4)
; anio start address is: 4 (W2)
; mes start address is: 0 (W0)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	GOTO	L__IncrementarFecha216
L__IncrementarFecha218:
L__IncrementarFecha216:
; mes start address is: 0 (W0)
; anio start address is: 4 (W2)
; dia start address is: 8 (W4)
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	GOTO	L__IncrementarFecha215
L__IncrementarFecha219:
L__IncrementarFecha215:
;tiempo_rtc.c,242 :: 		}
; dia start address is: 8 (W4)
; anio start address is: 4 (W2)
; mes start address is: 0 (W0)
	PUSH.D	W2
; dia end address is: 8 (W4)
; mes end address is: 0 (W0)
; anio end address is: 4 (W2)
	MOV.D	W4, W2
	POP.D	W4
L_IncrementarFecha31:
;tiempo_rtc.c,243 :: 		}
; mes start address is: 0 (W0)
; anio start address is: 8 (W4)
; dia start address is: 4 (W2)
	MOV.D	W0, W6
; mes end address is: 0 (W0)
; anio end address is: 8 (W4)
; dia end address is: 4 (W2)
	MOV.D	W2, W8
	MOV.D	W4, W2
L_IncrementarFecha29:
;tiempo_rtc.c,245 :: 		}
; dia start address is: 16 (W8)
; anio start address is: 4 (W2)
; mes start address is: 12 (W6)
; mes end address is: 12 (W6)
; anio end address is: 4 (W2)
; dia end address is: 16 (W8)
L_IncrementarFecha23:
;tiempo_rtc.c,247 :: 		fechaInc = (anio*10000)+(mes*100)+(dia);                                   //10000*aa + 100*mm + dd
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
;tiempo_rtc.c,248 :: 		return fechaInc;
;tiempo_rtc.c,250 :: 		}
L_end_IncrementarFecha:
	ULNK
	RETURN
; end of _IncrementarFecha

_AjustarTiempoSistema:
	LNK	#14

;tiempo_rtc.c,253 :: 		void AjustarTiempoSistema(unsigned long longHora, unsigned long longFecha, unsigned short *tramaTiempoSistema){
	MOV	[W14-8], W0
	MOV	W0, [W14-8]
;tiempo_rtc.c,262 :: 		hora = (short)(longHora / 3600);
	PUSH.D	W12
	PUSH.D	W10
	MOV	#3600, W2
	MOV	#0, W3
	MOV.D	W10, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W10
	MOV.B	W0, [W14+0]
;tiempo_rtc.c,263 :: 		minuto = (short)((longHora%3600) / 60);
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
;tiempo_rtc.c,264 :: 		segundo = (short)((longHora%3600) % 60);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#60, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
	POP.D	W12
	MOV.B	W0, [W14+2]
;tiempo_rtc.c,266 :: 		anio = (short)(longFecha / 10000);
	PUSH.D	W12
	MOV	#10000, W2
	MOV	#0, W3
	MOV.D	W12, W0
	CLR	W4
	CALL	__Divide_32x32
	POP.D	W12
	MOV.B	W0, [W14+4]
;tiempo_rtc.c,267 :: 		mes = (short)((longFecha%10000) / 100);
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
;tiempo_rtc.c,268 :: 		dia = (short)((longFecha%10000) % 100);
	MOV	[W14+10], W0
	MOV	[W14+12], W1
	MOV	#100, W2
	MOV	#0, W3
	CLR	W4
	CALL	__Modulus_32x32
; dia start address is: 4 (W2)
	MOV.B	W0, W2
;tiempo_rtc.c,270 :: 		tramaTiempoSistema[0] = anio;
	MOV	[W14-8], W1
	MOV.B	[W14+4], W0
	MOV.B	W0, [W1]
;tiempo_rtc.c,271 :: 		tramaTiempoSistema[1] = mes;
	MOV	[W14-8], W0
	ADD	W0, #1, W1
	MOV.B	[W14+3], W0
	MOV.B	W0, [W1]
;tiempo_rtc.c,272 :: 		tramaTiempoSistema[2] = dia;
	MOV	[W14-8], W0
	INC2	W0
	MOV.B	W2, [W0]
; dia end address is: 4 (W2)
;tiempo_rtc.c,273 :: 		tramaTiempoSistema[3] = hora;
	MOV	[W14-8], W0
	ADD	W0, #3, W1
	MOV.B	[W14+0], W0
	MOV.B	W0, [W1]
;tiempo_rtc.c,274 :: 		tramaTiempoSistema[4] = minuto;
	MOV	[W14-8], W0
	ADD	W0, #4, W1
	MOV.B	[W14+1], W0
	MOV.B	W0, [W1]
;tiempo_rtc.c,275 :: 		tramaTiempoSistema[5] = segundo;
	MOV	[W14-8], W0
	ADD	W0, #5, W1
	MOV.B	[W14+2], W0
	MOV.B	W0, [W1]
;tiempo_rtc.c,277 :: 		}
L_end_AjustarTiempoSistema:
	ULNK
	RETURN
; end of _AjustarTiempoSistema

_RecuperarFechaRPI:
	LNK	#4

;tiempo_rpi.c,10 :: 		unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi){
;tiempo_rpi.c,14 :: 		fechaRPi = ((long)tramaTiempoRpi[0]*10000)+((long)tramaTiempoRpi[1]*100)+((long)tramaTiempoRpi[2]);      //10000*dd + 100*mm + aa
	ZE	[W10], W0
	CLR	W1
	MOV	#10000, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	ADD	W10, #1, W0
	ZE	[W0], W0
	CLR	W1
	MOV	#100, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	ADD	W2, W0, W2
	ADDC	W3, W1, W3
	ADD	W10, #2, W0
	ZE	[W0], W0
	CLR	W1
	ADD	W2, W0, W0
	ADDC	W3, W1, W1
;tiempo_rpi.c,16 :: 		return fechaRPi;
;tiempo_rpi.c,18 :: 		}
L_end_RecuperarFechaRPI:
	ULNK
	RETURN
; end of _RecuperarFechaRPI

_RecuperarHoraRPI:
	LNK	#4

;tiempo_rpi.c,21 :: 		unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi){
;tiempo_rpi.c,25 :: 		horaRPi = ((long)tramaTiempoRpi[3]*3600)+((long)tramaTiempoRpi[4]*60)+((long)tramaTiempoRpi[5]);      //Calcula el segundo actual = hh*3600 + mm*60 + ss
	ADD	W10, #3, W0
	ZE	[W0], W0
	CLR	W1
	MOV	#3600, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	ADD	W10, #4, W0
	ZE	[W0], W0
	CLR	W1
	MOV	#60, W2
	MOV	#0, W3
	CALL	__Multiply_32x32
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	ADD	W2, W0, W2
	ADDC	W3, W1, W3
	ADD	W10, #5, W0
	ZE	[W0], W0
	CLR	W1
	ADD	W2, W0, W0
	ADDC	W3, W1, W1
;tiempo_rpi.c,27 :: 		return horaRPi;
;tiempo_rpi.c,29 :: 		}
L_end_RecuperarHoraRPI:
	ULNK
	RETURN
; end of _RecuperarHoraRPI

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 50
	MOV	#4, W0
	IOR	68

;Acelerografo.c,69 :: 		void main()
;Acelerografo.c,74 :: 		tasaMuestreo = 1; // 1=250Hz, 2=125Hz, 4=62.5Hz, 8=31.25Hz
	PUSH	W10
	MOV	#lo_addr(_tasaMuestreo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,76 :: 		numTMR1 = (tasaMuestreo * 10) - 1; // Calcula el numero de veces que tienen que desbordarse el TMR1 para cada tasa de muestreo
	MOV	#lo_addr(_numTMR1), W1
	MOV.B	#9, W0
	MOV.B	W0, [W1]
;Acelerografo.c,78 :: 		banOperacion = 0;
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,79 :: 		tipoOperacion = 0;
	MOV	#lo_addr(_tipoOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,81 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,82 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,83 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,84 :: 		banCiclo = 0;
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,85 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,87 :: 		banSetGPS = 0;
	MOV	#lo_addr(_banSetGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,88 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,89 :: 		banTFGPS = 0;
	MOV	#lo_addr(_banTFGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,90 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,91 :: 		stsGPS = 0;
	MOV	#lo_addr(_stsGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,92 :: 		fuenteReloj = 0;
	MOV	#lo_addr(_fuenteReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,93 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,95 :: 		banMuestrear = 0; // Inicia el programa con esta bandera en bajo para permitir que la RPi envie la peticion de inicio de muestreo
	MOV	#lo_addr(_banMuestrear), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,96 :: 		banInicio = 0;    // Bandera de inicio de muestreo
	MOV	#lo_addr(_banInicio), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,97 :: 		banLeer = 0;
	MOV	#lo_addr(_banLeer), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,98 :: 		banConf = 0;
	MOV	#lo_addr(_banConf), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,100 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,101 :: 		x = 0;
	CLR	W0
	MOV	W0, _x
;Acelerografo.c,102 :: 		y = 0;
	CLR	W0
	MOV	W0, _y
;Acelerografo.c,103 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,104 :: 		horaSistema = 0;
	CLR	W0
	CLR	W1
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,105 :: 		referenciaTiempo = 0;
	MOV	#lo_addr(_referenciaTiempo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,106 :: 		contTimeout1 = 0;
	MOV	#lo_addr(_contTimeout1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,108 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,109 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,110 :: 		contFIFO = 0;
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,111 :: 		numFIFO = 0;
	MOV	#lo_addr(_numFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,112 :: 		numSetsFIFO = 0;
	MOV	#lo_addr(_numSetsFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,113 :: 		contTimer1 = 0;
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,114 :: 		contTimer3 = 0;
	MOV	#lo_addr(_contTimer3), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,116 :: 		byteGPS = 0;
	MOV	#lo_addr(_byteGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,117 :: 		banInitGPS = 0;
	MOV	#lo_addr(_banInitGPS), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,120 :: 		banInicializar = 0;
	MOV	#lo_addr(_banInicializar), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,122 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,123 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,124 :: 		LedTest = 1;
	BSET	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,126 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,128 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,130 :: 		while (1)
L_main49:
;Acelerografo.c,132 :: 		if (banInicializar == 1)
	MOV	#lo_addr(_banInicializar), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main339
	GOTO	L_main51
L__main339:
;Acelerografo.c,135 :: 		DS3234_init();              // inicializa el RTC
	CALL	_DS3234_init
;Acelerografo.c,136 :: 		ADXL355_init(tasaMuestreo); // Inicializa el modulo ADXL con la tasa de muestreo requerida
	MOV	#lo_addr(_tasaMuestreo), W0
	MOV.B	[W0], W10
	CALL	_ADXL355_init
;Acelerografo.c,137 :: 		banInicializar = 0;         // Desactiva la bandera para salir del bucle
	MOV	#lo_addr(_banInicializar), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,140 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,141 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_main52:
	DEC	W7
	BRA NZ	L_main52
	DEC	W8
	BRA NZ	L_main52
	NOP
	NOP
	NOP
;Acelerografo.c,142 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,143 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_main54:
	DEC	W7
	BRA NZ	L_main54
	DEC	W8
	BRA NZ	L_main54
	NOP
	NOP
	NOP
;Acelerografo.c,144 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,145 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_main56:
	DEC	W7
	BRA NZ	L_main56
	DEC	W8
	BRA NZ	L_main56
	NOP
	NOP
	NOP
;Acelerografo.c,146 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,147 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_main58:
	DEC	W7
	BRA NZ	L_main58
	DEC	W8
	BRA NZ	L_main58
	NOP
	NOP
	NOP
;Acelerografo.c,148 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,149 :: 		}
L_main51:
;Acelerografo.c,151 :: 		Delay_ms(1);
	MOV	#8000, W7
L_main60:
	DEC	W7
	BRA NZ	L_main60
	NOP
	NOP
;Acelerografo.c,152 :: 		}
	GOTO	L_main49
;Acelerografo.c,153 :: 		}
L_end_main:
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main

_ConfiguracionPrincipal:

;Acelerografo.c,160 :: 		void ConfiguracionPrincipal()
;Acelerografo.c,164 :: 		CLKDIVbits.FRCDIV = 0;   // FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,165 :: 		CLKDIVbits.PLLPOST = 0;  // N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,166 :: 		CLKDIVbits.PLLPRE = 5;   // N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,167 :: 		PLLFBDbits.PLLDIV = 150; // M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,170 :: 		ANSELA = 0;      // Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,171 :: 		ANSELB = 0;      // Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,172 :: 		TRISA2_bit = 0;  // Configura el pin A2 como salida  *
	BCLR	TRISA2_bit, BitPos(TRISA2_bit+0)
;Acelerografo.c,173 :: 		TRISA3_bit = 0;  // Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,174 :: 		TRISA4_bit = 0;  // Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,175 :: 		TRISB4_bit = 0;  // Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,176 :: 		TRISB12_bit = 0; // Configura el pin B12 como salida *
	BCLR	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,178 :: 		TRISB10_bit = 1; // Configura el pin B10 como entrada *
	BSET	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,179 :: 		TRISB11_bit = 1; // Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,180 :: 		TRISB13_bit = 1; // Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,181 :: 		TRISB14_bit = 1;
	BSET	TRISB14_bit, BitPos(TRISB14_bit+0)
;Acelerografo.c,182 :: 		TRISB15_bit = 1; // Configura el pin B15 como entrada *
	BSET	TRISB15_bit, BitPos(TRISB15_bit+0)
;Acelerografo.c,184 :: 		INTCON2.GIE = 1; // Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,187 :: 		SPI1STAT.SPIEN = 1;                                                                                                                                                 // Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,188 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE); //*
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
;Acelerografo.c,189 :: 		SPI1IE_bit = 1;                                                                                                                                                     // Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,190 :: 		SPI1IF_bit = 0;                                                                                                                                                     // Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,191 :: 		IPC2bits.SPI1IP = 0x03;                                                                                                                                             // Prioridad de la interrupcion SPI1
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,194 :: 		RPINR22bits.SDI2R = 0x21; // Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,195 :: 		RPOR2bits.RP38R = 0x08;   // Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,196 :: 		RPOR1bits.RP37R = 0x09;   // Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,197 :: 		SPI2STATbits.SPIROV = 0;  // No Receive Overflow has occurred
	BCLR	SPI2STATbits, #6
;Acelerografo.c,198 :: 		SPI2STAT.SPIEN = 1;       // Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,199 :: 		SPI2_Init();              // Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,200 :: 		CS_DS3234 = 1;            // Pone en alto el CS del RTC
	BSET	LATA2_bit, BitPos(LATA2_bit+0)
;Acelerografo.c,201 :: 		CS_ADXL355 = 1;           // Pone en alto el CS del acelerometro
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;Acelerografo.c,204 :: 		RPINR18bits.U1RXR = 0x22; // Configura el pin RB2/RPI34 como Rx1 *
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
;Acelerografo.c,205 :: 		RPOR0bits.RP35R = 0x01;   // Configura el Tx1 en el pin RB3/RP35 *
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR0bits
;Acelerografo.c,206 :: 		U1RXIE_bit = 1;           // Habilita la interrupcion por UART1 RX *
	BSET	U1RXIE_bit, BitPos(U1RXIE_bit+0)
;Acelerografo.c,207 :: 		U1RXIF_bit = 0;           // Limpia la bandera de interrupcion por UART1 RX *
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,208 :: 		IPC2bits.U1RXIP = 0x04;   // Prioridad de la interrupcion UART1 RX
	MOV	#16384, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC2bits
;Acelerografo.c,209 :: 		U1STAbits.URXISEL = 0x00;
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(U1STAbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,210 :: 		UART1_Init(9600); // Inicializa el UART1 con una velocidad de 9600 baudios
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;Acelerografo.c,213 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF | STANDBY); // Coloco el ADXL en modo STANDBY para pausar las conversiones y limpiar el FIFO
	MOV.B	#5, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,216 :: 		RPINR0 = 0x2F00;        // Asigna INT1 al RB15/RPI47 (SQW)
	MOV	#12032, W0
	MOV	WREG, RPINR0
;Acelerografo.c,217 :: 		INT1IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,218 :: 		INT1IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,219 :: 		IPC5bits.INT1IP = 0x02; // Prioridad en la interrupocion externa INT1
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC5bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC5bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,222 :: 		RPINR1 = 0x002E;        // Asigna INT2 al RB14/RPI46 (PPS)
	MOV	#46, W0
	MOV	WREG, RPINR1
;Acelerografo.c,223 :: 		INT2IE_bit = 1;         // Habilita la interrupcion externa INT1
	BSET	INT2IE_bit, BitPos(INT2IE_bit+0)
;Acelerografo.c,224 :: 		INT2IF_bit = 0;         // Limpia la bandera de interrupcion externa INT1
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,225 :: 		IPC7bits.INT2IP = 0x01; // Prioridad en la interrupocion externa INT2
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
;Acelerografo.c,228 :: 		T1CON = 0x0020;
	MOV	#32, W0
	MOV	WREG, T1CON
;Acelerografo.c,229 :: 		T1CON.TON = 0;        // Apaga el TMR1
	BCLR	T1CON, #15
;Acelerografo.c,230 :: 		T1IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,231 :: 		T1IF_bit = 0;         // Limpia la bandera de interrupcion del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,232 :: 		PR1 = 62500;          // Car ga el preload para un tiempo de 100ms
	MOV	#62500, W0
	MOV	WREG, PR1
;Acelerografo.c,233 :: 		IPC0bits.T1IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;Acelerografo.c,236 :: 		T2CON = 0x30;         // Prescalador
	MOV	#48, W0
	MOV	WREG, T2CON
;Acelerografo.c,237 :: 		T2CON.TON = 0;        // Apaga el TMR2
	BCLR	T2CON, #15
;Acelerografo.c,238 :: 		T2IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR2
	BSET	T2IE_bit, BitPos(T2IE_bit+0)
;Acelerografo.c,239 :: 		T2IF_bit = 0;         // Limpia la bandera de interrupcion del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,240 :: 		PR2 = 46875;          // Carga el preload para un tiempo de 300ms
	MOV	#46875, W0
	MOV	WREG, PR2
;Acelerografo.c,241 :: 		IPC1bits.T2IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#8192, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;Acelerografo.c,244 :: 		T3CON = 0x20;         // Prescalador
	MOV	#32, W0
	MOV	WREG, T3CON
;Acelerografo.c,245 :: 		T3CON.TON = 0;        // Apaga el TMR3
	BCLR	T3CON, #15
;Acelerografo.c,246 :: 		T3IE_bit = 1;         // Habilita la interrupcion de desbordamiento TMR3
	BSET	T3IE_bit, BitPos(T3IE_bit+0)
;Acelerografo.c,247 :: 		T3IF_bit = 0;         // Limpia la bandera de interrupcion del TMR3
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,248 :: 		PR3 = 62500;          // Carga el preload para un tiempo de 500ms
	MOV	#62500, W0
	MOV	WREG, PR3
;Acelerografo.c,249 :: 		IPC2bits.T3IP = 0x02; // Prioridad de la interrupcion por desbordamiento del TMR3
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC2bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC2bits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,251 :: 		Delay_ms(200); // Espera hasta que se estabilicen los cambios
	MOV	#25, W8
	MOV	#27150, W7
L_ConfiguracionPrincipal62:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal62
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal62
	NOP
;Acelerografo.c,254 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,255 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal64:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal64
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal64
	NOP
	NOP
;Acelerografo.c,256 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,257 :: 		Delay_ms(300);
	MOV	#37, W8
	MOV	#40725, W7
L_ConfiguracionPrincipal66:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal66
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal66
	NOP
	NOP
;Acelerografo.c,258 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,261 :: 		banInicializar = 1;
	MOV	#lo_addr(_banInicializar), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,262 :: 		}
L_end_ConfiguracionPrincipal:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _ConfiguracionPrincipal

_InterrupcionP1:

;Acelerografo.c,267 :: 		void InterrupcionP1(unsigned short operacion)
;Acelerografo.c,269 :: 		banOperacion = 0;          // Encera la bandera para permitir una nueva peticion de operacion
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,270 :: 		tipoOperacion = operacion; // Carga en la variable el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	MOV.B	W10, [W0]
;Acelerografo.c,272 :: 		RP1 = 1;
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,273 :: 		Delay_us(20);
	MOV	#160, W7
L_InterrupcionP168:
	DEC	W7
	BRA NZ	L_InterrupcionP168
	NOP
	NOP
;Acelerografo.c,274 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,275 :: 		}
L_end_InterrupcionP1:
	RETURN
; end of _InterrupcionP1

_Muestrear:

;Acelerografo.c,280 :: 		void Muestrear()
;Acelerografo.c,283 :: 		if (banCiclo == 0)
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Muestrear344
	GOTO	L_Muestrear70
L__Muestrear344:
;Acelerografo.c,285 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF | MEASURING); // Coloca el ADXL en modo medicion
	MOV.B	#4, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;Acelerografo.c,286 :: 		T1CON.TON = 1;                                       // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,287 :: 		}
	GOTO	L_Muestrear71
L_Muestrear70:
;Acelerografo.c,288 :: 		else if (banCiclo == 1)
	MOV	#lo_addr(_banCiclo), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Muestrear345
	GOTO	L_Muestrear72
L__Muestrear345:
;Acelerografo.c,291 :: 		banCiclo = 2; // Limpia la bandera de ciclo completo
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,294 :: 		tramaCompleta[0] = fuenteReloj; // LLena el primer elemento de la tramaCompleta con el identificador de fuente de reloj
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_fuenteReloj), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,295 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES);
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,296 :: 		numSetsFIFO = (numFIFO) / 3; // Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,299 :: 		for (x = 0; x < numSetsFIFO; x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear73:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Muestrear346
	GOTO	L_Muestrear74
L__Muestrear346:
;Acelerografo.c,301 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,302 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Muestrear76:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Muestrear347
	GOTO	L_Muestrear77
L__Muestrear347:
;Acelerografo.c,304 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
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
;Acelerografo.c,302 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,305 :: 		}
	GOTO	L_Muestrear76
L_Muestrear77:
;Acelerografo.c,299 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,306 :: 		}
	GOTO	L_Muestrear73
L_Muestrear74:
;Acelerografo.c,309 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear79:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Muestrear348
	GOTO	L_Muestrear80
L__Muestrear348:
;Acelerografo.c,311 :: 		if ((x == 0) || (x % 9 == 0))
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Muestrear349
	GOTO	L__Muestrear222
L__Muestrear349:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Muestrear350
	GOTO	L__Muestrear221
L__Muestrear350:
	GOTO	L_Muestrear84
L__Muestrear222:
L__Muestrear221:
;Acelerografo.c,313 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras; // Funciona bien
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
;Acelerografo.c,314 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
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
;Acelerografo.c,315 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,316 :: 		}
	GOTO	L_Muestrear85
L_Muestrear84:
;Acelerografo.c,319 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
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
;Acelerografo.c,320 :: 		}
L_Muestrear85:
;Acelerografo.c,309 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,321 :: 		}
	GOTO	L_Muestrear79
L_Muestrear80:
;Acelerografo.c,324 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo);
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,325 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_Muestrear86:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__Muestrear351
	GOTO	L_Muestrear87
L__Muestrear351:
;Acelerografo.c,327 :: 		tramaCompleta[2500 + x] = tiempo[x];
	MOV	#2500, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_tramaCompleta), W0
	ADD	W0, W1, W2
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], [W2]
;Acelerografo.c,325 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,328 :: 		}
	GOTO	L_Muestrear86
L_Muestrear87:
;Acelerografo.c,330 :: 		contMuestras = 0; // Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,331 :: 		contFIFO = 0;     // Limpia el contador de FIFOs
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,332 :: 		T1CON.TON = 1;    // Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,334 :: 		banLec = 1; // Activa la bandera de lectura para enviar la trama
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,335 :: 		InterrupcionP1(0XB1);
	MOV.B	#177, W10
	CALL	_InterrupcionP1
;Acelerografo.c,337 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,338 :: 		}
L_Muestrear72:
L_Muestrear71:
;Acelerografo.c,340 :: 		contCiclos++; // Incrementa el contador de ciclos
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,341 :: 		}
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

;Acelerografo.c,349 :: 		void spi_1() org IVT_ADDR_SPI1INTERRUPT
;Acelerografo.c,352 :: 		SPI1IF_bit = 0;   // Limpia la bandera de interrupcion por SPI
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,353 :: 		buffer = SPI1BUF; // Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,357 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
	MOV	#lo_addr(_banOperacion), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1353
	GOTO	L__spi_1241
L__spi_1353:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#160, W0
	CP.B	W1, W0
	BRA Z	L__spi_1354
	GOTO	L__spi_1240
L__spi_1354:
L__spi_1239:
;Acelerografo.c,359 :: 		banOperacion = 1;        // Activa la bandera para enviar el tipo de operacion requerido a la RPi
	MOV	#lo_addr(_banOperacion), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,360 :: 		SPI1BUF = tipoOperacion; // Carga en el buffer el tipo de operacion requerido
	MOV	#lo_addr(_tipoOperacion), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,357 :: 		if ((banOperacion == 0) && (buffer == 0xA0))
L__spi_1241:
L__spi_1240:
;Acelerografo.c,362 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
	MOV	#lo_addr(_banOperacion), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1355
	GOTO	L__spi_1243
L__spi_1355:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#240, W0
	CP.B	W1, W0
	BRA Z	L__spi_1356
	GOTO	L__spi_1242
L__spi_1356:
L__spi_1238:
;Acelerografo.c,364 :: 		banOperacion = 0;  // Limpia la bandera
	MOV	#lo_addr(_banOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,365 :: 		tipoOperacion = 0; // Limpia la variable de tipo de operacion
	MOV	#lo_addr(_tipoOperacion), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,362 :: 		if ((banOperacion == 1) && (buffer == 0xF0))
L__spi_1243:
L__spi_1242:
;Acelerografo.c,371 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
	MOV	#lo_addr(_banMuestrear), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1357
	GOTO	L__spi_1245
L__spi_1357:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#161, W0
	CP.B	W1, W0
	BRA Z	L__spi_1358
	GOTO	L__spi_1244
L__spi_1358:
L__spi_1237:
;Acelerografo.c,373 :: 		banMuestrear = 1; // Cambia el estado de la bandera para que no inicie el muestreo mas de una vez de manera consecutiva
	MOV	#lo_addr(_banMuestrear), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,374 :: 		banCiclo = 0;
	MOV	#lo_addr(_banCiclo), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,375 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,376 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,377 :: 		contFIFO = 0;
	CLR	W0
	MOV	W0, _contFIFO
;Acelerografo.c,378 :: 		numFIFO = 0;
	MOV	#lo_addr(_numFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,379 :: 		numSetsFIFO = 0;
	MOV	#lo_addr(_numSetsFIFO), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,380 :: 		contTimer1 = 0;
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,382 :: 		banInicio = 1;
	MOV	#lo_addr(_banInicio), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,371 :: 		if ((banMuestrear == 0) && (buffer == 0xA1))
L__spi_1245:
L__spi_1244:
;Acelerografo.c,386 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
	MOV	#lo_addr(_banInitGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1359
	GOTO	L__spi_1247
L__spi_1359:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#162, W0
	CP.B	W1, W0
	BRA Z	L__spi_1360
	GOTO	L__spi_1246
L__spi_1360:
L__spi_1236:
;Acelerografo.c,389 :: 		banInitGPS = 1;
	MOV	#lo_addr(_banInitGPS), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,390 :: 		SPI1BUF = 0x47; // Ascii: G
	MOV	#71, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,386 :: 		if ((banInitGPS == 0) && (buffer == 0xA2))
L__spi_1247:
L__spi_1246:
;Acelerografo.c,392 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
	MOV	#lo_addr(_banInitGPS), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1361
	GOTO	L__spi_1249
L__spi_1361:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#242, W0
	CP.B	W1, W0
	BRA Z	L__spi_1362
	GOTO	L__spi_1248
L__spi_1362:
L__spi_1235:
;Acelerografo.c,394 :: 		GPS_init();
	CALL	_GPS_init
;Acelerografo.c,396 :: 		LedTest = 0;
	BCLR	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,397 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_1104:
	DEC	W7
	BRA NZ	L_spi_1104
	DEC	W8
	BRA NZ	L_spi_1104
	NOP
	NOP
	NOP
;Acelerografo.c,398 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,399 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_1106:
	DEC	W7
	BRA NZ	L_spi_1106
	DEC	W8
	BRA NZ	L_spi_1106
	NOP
	NOP
	NOP
;Acelerografo.c,400 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,401 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_1108:
	DEC	W7
	BRA NZ	L_spi_1108
	DEC	W8
	BRA NZ	L_spi_1108
	NOP
	NOP
	NOP
;Acelerografo.c,402 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,403 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_1110:
	DEC	W7
	BRA NZ	L_spi_1110
	DEC	W8
	BRA NZ	L_spi_1110
	NOP
	NOP
	NOP
;Acelerografo.c,404 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,405 :: 		Delay_ms(150);
	MOV	#19, W8
	MOV	#20362, W7
L_spi_1112:
	DEC	W7
	BRA NZ	L_spi_1112
	DEC	W8
	BRA NZ	L_spi_1112
	NOP
	NOP
	NOP
;Acelerografo.c,406 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,392 :: 		if ((banInitGPS == 1) && (buffer == 0xF2))
L__spi_1249:
L__spi_1248:
;Acelerografo.c,410 :: 		if ((banLec == 1) && (buffer == 0xA3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1363
	GOTO	L__spi_1251
L__spi_1363:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#163, W0
	CP.B	W1, W0
	BRA Z	L__spi_1364
	GOTO	L__spi_1250
L__spi_1364:
L__spi_1234:
;Acelerografo.c,412 :: 		banLec = 2; // Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,413 :: 		i = 0;
	CLR	W0
	MOV	W0, _i
;Acelerografo.c,414 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,410 :: 		if ((banLec == 1) && (buffer == 0xA3))
L__spi_1251:
L__spi_1250:
;Acelerografo.c,416 :: 		if ((banLec == 2) && (buffer != 0xF3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1365
	GOTO	L__spi_1253
L__spi_1365:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#243, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1366
	GOTO	L__spi_1252
L__spi_1366:
L__spi_1233:
;Acelerografo.c,418 :: 		SPI1BUF = tramaCompleta[i];
	MOV	#lo_addr(_tramaCompleta), W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,419 :: 		i++;
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,416 :: 		if ((banLec == 2) && (buffer != 0xF3))
L__spi_1253:
L__spi_1252:
;Acelerografo.c,421 :: 		if ((banLec == 2) && (buffer == 0xF3))
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1367
	GOTO	L__spi_1255
L__spi_1367:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#243, W0
	CP.B	W1, W0
	BRA Z	L__spi_1368
	GOTO	L__spi_1254
L__spi_1368:
L__spi_1232:
;Acelerografo.c,423 :: 		banLec = 0; // Limpia la bandera de lectura                        ****AQUI Me QUEDE
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,424 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,421 :: 		if ((banLec == 2) && (buffer == 0xF3))
L__spi_1255:
L__spi_1254:
;Acelerografo.c,430 :: 		if ((banEsc == 0) && (buffer == 0xA4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1369
	GOTO	L__spi_1257
L__spi_1369:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#164, W0
	CP.B	W1, W0
	BRA Z	L__spi_1370
	GOTO	L__spi_1256
L__spi_1370:
L__spi_1231:
;Acelerografo.c,432 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,433 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,430 :: 		if ((banEsc == 0) && (buffer == 0xA4))
L__spi_1257:
L__spi_1256:
;Acelerografo.c,435 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1371
	GOTO	L__spi_1260
L__spi_1371:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#164, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1372
	GOTO	L__spi_1259
L__spi_1372:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#244, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1373
	GOTO	L__spi_1258
L__spi_1373:
L__spi_1230:
;Acelerografo.c,437 :: 		tiempoRPI[j] = buffer;
	MOV	#lo_addr(_tiempoRPI), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,438 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,435 :: 		if ((banEsc == 1) && (buffer != 0xA4) && (buffer != 0xF4))
L__spi_1260:
L__spi_1259:
L__spi_1258:
;Acelerografo.c,440 :: 		if ((banEsc == 1) && (buffer == 0xF4))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1374
	GOTO	L__spi_1262
L__spi_1374:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#244, W0
	CP.B	W1, W0
	BRA Z	L__spi_1375
	GOTO	L__spi_1261
L__spi_1375:
L__spi_1229:
;Acelerografo.c,442 :: 		horaSistema = RecuperarHoraRPI(tiempoRPI);               // Recupera la hora de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarHoraRPI
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,443 :: 		fechaSistema = RecuperarFechaRPI(tiempoRPI);             // Recupera la fecha de la RPi
	MOV	#lo_addr(_tiempoRPI), W10
	CALL	_RecuperarFechaRPI
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,444 :: 		DS3234_setDate(horaSistema, fechaSistema);               // Configura la hora en el RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	CALL	_DS3234_setDate
;Acelerografo.c,445 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,446 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,447 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,448 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,449 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,450 :: 		InterrupcionP1(0XB2);
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,440 :: 		if ((banEsc == 1) && (buffer == 0xF4))
L__spi_1262:
L__spi_1261:
;Acelerografo.c,454 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1376
	GOTO	L__spi_1264
L__spi_1376:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#165, W0
	CP.B	W1, W0
	BRA Z	L__spi_1377
	GOTO	L__spi_1263
L__spi_1377:
L__spi_1228:
;Acelerografo.c,456 :: 		banSetReloj = 2;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,457 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;Acelerografo.c,458 :: 		SPI1BUF = fuenteReloj; // Envia el indicador de fuente de reloj (0:RTC, 1:GPS)
	MOV	#lo_addr(_fuenteReloj), W0
	ZE	[W0], W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,454 :: 		if ((banSetReloj == 1) && (buffer == 0xA5))
L__spi_1264:
L__spi_1263:
;Acelerografo.c,460 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1378
	GOTO	L__spi_1267
L__spi_1378:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#165, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1379
	GOTO	L__spi_1266
L__spi_1379:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#245, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1380
	GOTO	L__spi_1265
L__spi_1380:
L__spi_1227:
;Acelerografo.c,462 :: 		SPI1BUF = tiempo[j];
	MOV	#lo_addr(_tiempo), W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,463 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,460 :: 		if ((banSetReloj == 2) && (buffer != 0xA5) && (buffer != 0xF5))
L__spi_1267:
L__spi_1266:
L__spi_1265:
;Acelerografo.c,465 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__spi_1381
	GOTO	L__spi_1269
L__spi_1381:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#245, W0
	CP.B	W1, W0
	BRA Z	L__spi_1382
	GOTO	L__spi_1268
L__spi_1382:
L__spi_1226:
;Acelerografo.c,467 :: 		banSetReloj = 1; // Reactiva la bandera de lectura
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,468 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,465 :: 		if ((banSetReloj == 2) && (buffer == 0xF5))
L__spi_1269:
L__spi_1268:
;Acelerografo.c,472 :: 		if ((banEsc == 0) && (buffer == 0xA6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__spi_1383
	GOTO	L__spi_1271
L__spi_1383:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#166, W0
	CP.B	W1, W0
	BRA Z	L__spi_1384
	GOTO	L__spi_1270
L__spi_1384:
L__spi_1225:
;Acelerografo.c,474 :: 		banEsc = 1;
	MOV	#lo_addr(_banEsc), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,472 :: 		if ((banEsc == 0) && (buffer == 0xA6))
L__spi_1271:
L__spi_1270:
;Acelerografo.c,476 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1385
	GOTO	L__spi_1274
L__spi_1385:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#166, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1386
	GOTO	L__spi_1273
L__spi_1386:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#246, W0
	CP.B	W1, W0
	BRA NZ	L__spi_1387
	GOTO	L__spi_1272
L__spi_1387:
L__spi_1224:
;Acelerografo.c,478 :: 		referenciaTiempo = buffer; // Recupera la opcion de referencia de tiempo solicitada
	MOV	#lo_addr(_referenciaTiempo), W1
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,476 :: 		if ((banEsc == 1) && (buffer != 0xA6) && (buffer != 0xF6))
L__spi_1274:
L__spi_1273:
L__spi_1272:
;Acelerografo.c,480 :: 		if ((banEsc == 1) && (buffer == 0xF6))
	MOV	#lo_addr(_banEsc), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1388
	GOTO	L__spi_1276
L__spi_1388:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#246, W0
	CP.B	W1, W0
	BRA Z	L__spi_1389
	GOTO	L__spi_1275
L__spi_1389:
L__spi_1223:
;Acelerografo.c,482 :: 		if (referenciaTiempo == 1)
	MOV	#lo_addr(_referenciaTiempo), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_1390
	GOTO	L_spi_1150
L__spi_1390:
;Acelerografo.c,485 :: 		banGPSI = 1;       // Activa la bandera de inicio de trama  del GPS
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,486 :: 		banGPSC = 0;       // Limpia la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,487 :: 		U1MODE.UARTEN = 1; // Inicializa el UART1
	BSET	U1MODE, #15
;Acelerografo.c,489 :: 		T2CON.TON = 1;
	BSET	T2CON, #15
;Acelerografo.c,490 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,491 :: 		}
	GOTO	L_spi_1151
L_spi_1150:
;Acelerografo.c,495 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,496 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,497 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,498 :: 		fuenteReloj = 2;                                         // Fuente de reloj = RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,499 :: 		InterrupcionP1(0xB2);                                    // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,500 :: 		}
L_spi_1151:
;Acelerografo.c,501 :: 		banEsc = 0;
	MOV	#lo_addr(_banEsc), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,502 :: 		banSetReloj = 1; // Activa esta bandera para usar la hora/fecha recuperada
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,480 :: 		if ((banEsc == 1) && (buffer == 0xF6))
L__spi_1276:
L__spi_1275:
;Acelerografo.c,505 :: 		}
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

;Acelerografo.c,510 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT
;Acelerografo.c,513 :: 		INT1IF_bit = 0; // Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,515 :: 		if (banSetReloj == 1)
	MOV	#lo_addr(_banSetReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1392
	GOTO	L_int_1152
L__int_1392:
;Acelerografo.c,517 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,518 :: 		horaSistema++; // Incrementa el reloj del sistema
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
	BRA Z	L__int_1393
	GOTO	L_int_1153
L__int_1393:
;Acelerografo.c,523 :: 		horaSistema = 0; //(24*3600)+(0*60)+(0) = 86400
	CLR	W0
	CLR	W1
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,524 :: 		}
L_int_1153:
;Acelerografo.c,526 :: 		if (banInicio == 1)
	MOV	#lo_addr(_banInicio), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_1394
	GOTO	L_int_1154
L__int_1394:
;Acelerografo.c,529 :: 		Muestrear();
	CALL	_Muestrear
;Acelerografo.c,530 :: 		}
L_int_1154:
;Acelerografo.c,531 :: 		}
L_int_1152:
;Acelerografo.c,532 :: 		}
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

;Acelerografo.c,536 :: 		void int_2() org IVT_ADDR_INT2INTERRUPT
;Acelerografo.c,539 :: 		INT2IF_bit = 0; // Limpia la bandera de interrupcion externa INT2
	BCLR	INT2IF_bit, BitPos(INT2IF_bit+0)
;Acelerografo.c,541 :: 		if (banSyncReloj == 1)
	MOV	#lo_addr(_banSyncReloj), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__int_2396
	GOTO	L_int_2155
L__int_2396:
;Acelerografo.c,545 :: 		LedTest = ~LedTest;
	BTG	LATB12_bit, BitPos(LATB12_bit+0)
;Acelerografo.c,546 :: 		horaSistema = horaSistema + 2; // Incrementa el reloj del sistema en 2 segundos
	MOV	#2, W1
	MOV	#0, W2
	MOV	#lo_addr(_horaSistema), W0
	ADD	W1, [W0], [W0++]
	ADDC	W2, [W0], [W0--]
;Acelerografo.c,550 :: 		T3CON.TON = 1;
	BSET	T3CON, #15
;Acelerografo.c,551 :: 		TMR3 = 0;
	CLR	TMR3
;Acelerografo.c,564 :: 		}
L_int_2155:
;Acelerografo.c,565 :: 		}
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

;Acelerografo.c,569 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT
;Acelerografo.c,572 :: 		T1IF_bit = 0; // Limpia la bandera de interrupcion por desbordamiento del Timer1
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,574 :: 		numFIFO = ADXL355_read_byte(FIFO_ENTRIES); // 75                            //Lee el numero de muestras disponibles en el FIFO
	MOV.B	#5, W10
	CALL	_ADXL355_read_byte
	MOV	#lo_addr(_numFIFO), W1
	MOV.B	W0, [W1]
;Acelerografo.c,575 :: 		numSetsFIFO = (numFIFO) / 3;               // 25                            //Lee el numero de sets disponibles en el FIFO
	ZE	W0, W0
	MOV	#3, W2
	REPEAT	#17
	DIV.S	W0, W2
	MOV	W0, W1
	MOV	#lo_addr(_numSetsFIFO), W0
	MOV.B	W1, [W0]
;Acelerografo.c,578 :: 		for (x = 0; x < numSetsFIFO; x++)
	CLR	W0
	MOV	W0, _x
L_Timer1Int156:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__Timer1Int398
	GOTO	L_Timer1Int157
L__Timer1Int398:
;Acelerografo.c,580 :: 		ADXL355_read_FIFO(datosLeidos); // Lee una sola posicion del FIFO
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_FIFO
;Acelerografo.c,581 :: 		for (y = 0; y < 9; y++)
	CLR	W0
	MOV	W0, _y
L_Timer1Int159:
	MOV	_y, W0
	CP	W0, #9
	BRA LTU	L__Timer1Int399
	GOTO	L_Timer1Int160
L__Timer1Int399:
;Acelerografo.c,583 :: 		datosFIFO[y + (x * 9)] = datosLeidos[y]; // LLena la trama datosFIFO
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
;Acelerografo.c,581 :: 		for (y = 0; y < 9; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,584 :: 		}
	GOTO	L_Timer1Int159
L_Timer1Int160:
;Acelerografo.c,578 :: 		for (x = 0; x < numSetsFIFO; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,585 :: 		}
	GOTO	L_Timer1Int156
L_Timer1Int157:
;Acelerografo.c,588 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	CLR	W0
	MOV	W0, _x
L_Timer1Int162:
	MOV	#lo_addr(_numSetsFIFO), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W2
	MOV	#lo_addr(_x), W0
	CP	W2, [W0]
	BRA GTU	L__Timer1Int400
	GOTO	L_Timer1Int163
L__Timer1Int400:
;Acelerografo.c,590 :: 		if ((x == 0) || (x % 9 == 0))
	MOV	_x, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int401
	GOTO	L__Timer1Int279
L__Timer1Int401:
	MOV	_x, W0
	MOV	#9, W2
	REPEAT	#17
	DIV.U	W0, W2
	MOV	W1, W0
	CP	W0, #0
	BRA NZ	L__Timer1Int402
	GOTO	L__Timer1Int278
L__Timer1Int402:
	GOTO	L_Timer1Int167
L__Timer1Int279:
L__Timer1Int278:
;Acelerografo.c,592 :: 		tramaCompleta[contFIFO + contMuestras + x] = contMuestras;
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
;Acelerografo.c,593 :: 		tramaCompleta[contFIFO + contMuestras + x + 1] = datosFIFO[x];
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
;Acelerografo.c,594 :: 		contMuestras++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,595 :: 		}
	GOTO	L_Timer1Int168
L_Timer1Int167:
;Acelerografo.c,598 :: 		tramaCompleta[contFIFO + contMuestras + x] = datosFIFO[x];
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
;Acelerografo.c,599 :: 		}
L_Timer1Int168:
;Acelerografo.c,588 :: 		for (x = 0; x < (numSetsFIFO * 9); x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,600 :: 		}
	GOTO	L_Timer1Int162
L_Timer1Int163:
;Acelerografo.c,602 :: 		contFIFO = (contMuestras * 9); // Incrementa el contador de FIFOs
	MOV	#lo_addr(_contMuestras), W0
	ZE	[W0], W1
	MOV	#9, W0
	MUL.SS	W1, W0, W0
	MOV	W0, _contFIFO
;Acelerografo.c,604 :: 		contTimer1++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer1
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,606 :: 		if (contTimer1 == numTMR1)
	MOV	#lo_addr(_contTimer1), W0
	ZE	[W0], W1
	MOV	#lo_addr(_numTMR1), W0
	SE	[W0], W0
	CP	W1, W0
	BRA Z	L__Timer1Int403
	GOTO	L_Timer1Int169
L__Timer1Int403:
;Acelerografo.c,608 :: 		T1CON.TON = 0;  // Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,609 :: 		banCiclo = 1;   // Activa la bandera que indica que se completo un ciclo de medicion
	MOV	#lo_addr(_banCiclo), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,610 :: 		contTimer1 = 0; // Limpia el contador de interrupciones por Timer1
	MOV	#lo_addr(_contTimer1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,611 :: 		}
L_Timer1Int169:
;Acelerografo.c,612 :: 		}
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

;Acelerografo.c,616 :: 		void Timer2Int() org IVT_ADDR_T2INTERRUPT
;Acelerografo.c,619 :: 		T2IF_bit = 0;   // Limpia la bandera de interrupcion por desbordamiento del Timer2
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;Acelerografo.c,620 :: 		contTimeout1++; // Incrementa el contador de Timeout
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimeout1), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,623 :: 		if (contTimeout1 == 4)
	MOV	#lo_addr(_contTimeout1), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA Z	L__Timer2Int405
	GOTO	L_Timer2Int170
L__Timer2Int405:
;Acelerografo.c,625 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,626 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,627 :: 		contTimeout1 = 0;
	MOV	#lo_addr(_contTimeout1), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,629 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,630 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,631 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,632 :: 		fuenteReloj = 5;                                         //**Indica que se obtuvo la hora del RTC
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#5, W0
	MOV.B	W0, [W1]
;Acelerografo.c,633 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,634 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,635 :: 		}
L_Timer2Int170:
;Acelerografo.c,636 :: 		}
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

;Acelerografo.c,640 :: 		void Timer3Int() org IVT_ADDR_T3INTERRUPT
;Acelerografo.c,642 :: 		T3IF_bit = 0;
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	BCLR	T3IF_bit, BitPos(T3IF_bit+0)
;Acelerografo.c,644 :: 		contTimer3++; // Incrementa una unidad cada vez que entra a la interrupcion por Timer3
	MOV.B	#1, W1
	MOV	#lo_addr(_contTimer3), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,647 :: 		if (contTimer3 == 5)
	MOV	#lo_addr(_contTimer3), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA Z	L__Timer3Int407
	GOTO	L_Timer3Int171
L__Timer3Int407:
;Acelerografo.c,649 :: 		DS3234_setDate(horaSistema, fechaSistema); // Configura la hora en el RTC con la hora recuperada de la RPi
	MOV	_fechaSistema, W12
	MOV	_fechaSistema+2, W13
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	CALL	_DS3234_setDate
;Acelerografo.c,651 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,652 :: 		banSetReloj = 1; // Activa esta bandera para continuar trabajando con el pulso SQW
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,655 :: 		InterrupcionP1(0xB2);
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,656 :: 		contTimer3 = 0; // Encera el contador
	MOV	#lo_addr(_contTimer3), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,657 :: 		T3CON.TON = 0;  // Apaga el Timer3
	BCLR	T3CON, #15
;Acelerografo.c,658 :: 		}
L_Timer3Int171:
;Acelerografo.c,659 :: 		}
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

;Acelerografo.c,663 :: 		void urx_1() org IVT_ADDR_U1RXINTERRUPT
;Acelerografo.c,666 :: 		byteGPS = U1RXREG; // Lee el byte de la trama enviada por el GPS
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_byteGPS), W1
	MOV.B	U1RXREG, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,667 :: 		U1STA.OERR = 0;    // Limpia este bit para limpiar el FIFO UART1
	BCLR	U1STA, #1
;Acelerografo.c,670 :: 		if (banGPSI == 3)
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__urx_1409
	GOTO	L_urx_1172
L__urx_1409:
;Acelerografo.c,672 :: 		if (byteGPS != 0x2A)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#42, W0
	CP.B	W1, W0
	BRA NZ	L__urx_1410
	GOTO	L_urx_1173
L__urx_1410:
;Acelerografo.c,674 :: 		tramaGPS[i_gps] = byteGPS; // LLena la tramaGPS hasta recibir el ultimo simbolo ("*") de la trama GPS
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,675 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,676 :: 		}
	GOTO	L_urx_1174
L_urx_1173:
;Acelerografo.c,679 :: 		banGPSI = 0; // Limpia la bandera de inicio de trama
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,680 :: 		banGPSC = 1; // Activa la bandera de trama completa
	MOV	#lo_addr(_banGPSC), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,681 :: 		}
L_urx_1174:
;Acelerografo.c,682 :: 		}
L_urx_1172:
;Acelerografo.c,685 :: 		if ((banGPSI == 1))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1411
	GOTO	L_urx_1175
L__urx_1411:
;Acelerografo.c,687 :: 		if (byteGPS == 0x24)
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], W1
	MOV.B	#36, W0
	CP.B	W1, W0
	BRA Z	L__urx_1412
	GOTO	L_urx_1176
L__urx_1412:
;Acelerografo.c,689 :: 		banGPSI = 2;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;Acelerografo.c,690 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,691 :: 		}
L_urx_1176:
;Acelerografo.c,692 :: 		}
L_urx_1175:
;Acelerografo.c,693 :: 		if ((banGPSI == 2) && (i_gps < 6))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__urx_1413
	GOTO	L__urx_1284
L__urx_1413:
	MOV	_i_gps, W0
	CP	W0, #6
	BRA LTU	L__urx_1414
	GOTO	L__urx_1283
L__urx_1414:
L__urx_1282:
;Acelerografo.c,695 :: 		tramaGPS[i_gps] = byteGPS; // Recupera los datos de cabecera de la trama GPS: ["$", "G", "P", "R", "M", "C"]
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], W1
	MOV	#lo_addr(_byteGPS), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,696 :: 		i_gps++;
	MOV	#1, W1
	MOV	#lo_addr(_i_gps), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,693 :: 		if ((banGPSI == 2) && (i_gps < 6))
L__urx_1284:
L__urx_1283:
;Acelerografo.c,698 :: 		if ((banGPSI == 2) && (i_gps == 6))
	MOV	#lo_addr(_banGPSI), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__urx_1415
	GOTO	L__urx_1291
L__urx_1415:
	MOV	_i_gps, W0
	CP	W0, #6
	BRA Z	L__urx_1416
	GOTO	L__urx_1290
L__urx_1416:
L__urx_1281:
;Acelerografo.c,701 :: 		T2CON.TON = 0;
	BCLR	T2CON, #15
;Acelerografo.c,702 :: 		TMR2 = 0;
	CLR	TMR2
;Acelerografo.c,704 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
	MOV	#lo_addr(_tramaGPS+1), W0
	MOV.B	[W0], W1
	MOV.B	#71, W0
	CP.B	W1, W0
	BRA Z	L__urx_1417
	GOTO	L__urx_1289
L__urx_1417:
	MOV	#lo_addr(_tramaGPS+2), W0
	MOV.B	[W0], W1
	MOV.B	#80, W0
	CP.B	W1, W0
	BRA Z	L__urx_1418
	GOTO	L__urx_1288
L__urx_1418:
	MOV	#lo_addr(_tramaGPS+3), W0
	MOV.B	[W0], W1
	MOV.B	#82, W0
	CP.B	W1, W0
	BRA Z	L__urx_1419
	GOTO	L__urx_1287
L__urx_1419:
	MOV	#lo_addr(_tramaGPS+4), W0
	MOV.B	[W0], W1
	MOV.B	#77, W0
	CP.B	W1, W0
	BRA Z	L__urx_1420
	GOTO	L__urx_1286
L__urx_1420:
	MOV	#lo_addr(_tramaGPS+5), W0
	MOV.B	[W0], W1
	MOV.B	#67, W0
	CP.B	W1, W0
	BRA Z	L__urx_1421
	GOTO	L__urx_1285
L__urx_1421:
L__urx_1280:
;Acelerografo.c,706 :: 		banGPSI = 3;
	MOV	#lo_addr(_banGPSI), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,707 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,708 :: 		}
	GOTO	L_urx_1186
;Acelerografo.c,704 :: 		if (tramaGPS[1] == 'G' && tramaGPS[2] == 'P' && tramaGPS[3] == 'R' && tramaGPS[4] == 'M' && tramaGPS[5] == 'C')
L__urx_1289:
L__urx_1288:
L__urx_1287:
L__urx_1286:
L__urx_1285:
;Acelerografo.c,711 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,712 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,713 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,715 :: 		horaSistema = RecuperarHoraRTC();                        // Recupera la hora del RTC
	CALL	_RecuperarHoraRTC
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,716 :: 		fechaSistema = RecuperarFechaRTC();                      // Recupera la fecha del RTC
	CALL	_RecuperarFechaRTC
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,717 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del RTC
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,718 :: 		fuenteReloj = 4;                                         // Fuente reloj: RTC/E4
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
;Acelerografo.c,719 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,720 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi y a los nodos                                                   //Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,721 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,722 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,723 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,724 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,725 :: 		}
L_urx_1186:
;Acelerografo.c,698 :: 		if ((banGPSI == 2) && (i_gps == 6))
L__urx_1291:
L__urx_1290:
;Acelerografo.c,729 :: 		if (banGPSC == 1)
	MOV	#lo_addr(_banGPSC), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__urx_1422
	GOTO	L_urx_1187
L__urx_1422:
;Acelerografo.c,732 :: 		for (x = 0; x < 6; x++)
	CLR	W0
	MOV	W0, _x
L_urx_1188:
	MOV	_x, W0
	CP	W0, #6
	BRA LTU	L__urx_1423
	GOTO	L_urx_1189
L__urx_1423:
;Acelerografo.c,734 :: 		datosGPS[x] = tramaGPS[x + 1]; // Guarda los datos de hhmmss
	MOV	#lo_addr(_datosGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W2
	MOV	_x, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_tramaGPS), W0
	ADD	W0, W1, W0
	MOV.B	[W0], [W2]
;Acelerografo.c,732 :: 		for (x = 0; x < 6; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,735 :: 		}
	GOTO	L_urx_1188
L_urx_1189:
;Acelerografo.c,737 :: 		for (x = 44; x < 54; x++)
	MOV	#44, W0
	MOV	W0, _x
L_urx_1191:
	MOV	#54, W1
	MOV	#lo_addr(_x), W0
	CP	W1, [W0]
	BRA GTU	L__urx_1424
	GOTO	L_urx_1192
L__urx_1424:
;Acelerografo.c,739 :: 		if (tramaGPS[x] == 0x2C)
	MOV	#lo_addr(_tramaGPS), W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], W0
	MOV.B	[W0], W1
	MOV.B	#44, W0
	CP.B	W1, W0
	BRA Z	L__urx_1425
	GOTO	L_urx_1194
L__urx_1425:
;Acelerografo.c,741 :: 		for (y = 0; y < 6; y++)
	CLR	W0
	MOV	W0, _y
L_urx_1195:
	MOV	_y, W0
	CP	W0, #6
	BRA LTU	L__urx_1426
	GOTO	L_urx_1196
L__urx_1426:
;Acelerografo.c,743 :: 		datosGPS[6 + y] = tramaGPS[x + y + 1]; // Guarda los datos de DDMMAA en la trama datosGPS
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
;Acelerografo.c,741 :: 		for (y = 0; y < 6; y++)
	MOV	#1, W1
	MOV	#lo_addr(_y), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,744 :: 		}
	GOTO	L_urx_1195
L_urx_1196:
;Acelerografo.c,745 :: 		}
L_urx_1194:
;Acelerografo.c,737 :: 		for (x = 44; x < 54; x++)
	MOV	#1, W1
	MOV	#lo_addr(_x), W0
	ADD	W1, [W0], [W0]
;Acelerografo.c,746 :: 		}
	GOTO	L_urx_1191
L_urx_1192:
;Acelerografo.c,747 :: 		horaSistema = RecuperarHoraGPS(datosGPS);                // Recupera la hora del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarHoraGPS
	MOV	W0, _horaSistema
	MOV	W1, _horaSistema+2
;Acelerografo.c,748 :: 		fechaSistema = RecuperarFechaGPS(datosGPS);              // Recupera la fecha del GPS
	MOV	#lo_addr(_datosGPS), W10
	CALL	_RecuperarFechaGPS
	MOV	W0, _fechaSistema
	MOV	W1, _fechaSistema+2
;Acelerografo.c,749 :: 		AjustarTiempoSistema(horaSistema, fechaSistema, tiempo); // Actualiza los datos de la trama tiempo con la hora y fecha recuperadas del gps
	MOV.D	W0, W12
	MOV	_horaSistema, W10
	MOV	_horaSistema+2, W11
	MOV	#lo_addr(_tiempo), W0
	PUSH	W0
	CALL	_AjustarTiempoSistema
	SUB	#2, W15
;Acelerografo.c,752 :: 		if (tramaGPS[12] == 0x41)
	MOV	#lo_addr(_tramaGPS+12), W0
	MOV.B	[W0], W1
	MOV.B	#65, W0
	CP.B	W1, W0
	BRA Z	L__urx_1427
	GOTO	L_urx_1198
L__urx_1427:
;Acelerografo.c,754 :: 		fuenteReloj = 1; // Fuente reloj: GPS
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,755 :: 		banSyncReloj = 1;
	MOV	#lo_addr(_banSyncReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,756 :: 		banSetReloj = 0;
	MOV	#lo_addr(_banSetReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,757 :: 		}
	GOTO	L_urx_1199
L_urx_1198:
;Acelerografo.c,760 :: 		fuenteReloj = 3; // Fuente reloj: GPS/E3
	MOV	#lo_addr(_fuenteReloj), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;Acelerografo.c,761 :: 		banSyncReloj = 0;
	MOV	#lo_addr(_banSyncReloj), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,762 :: 		banSetReloj = 1;
	MOV	#lo_addr(_banSetReloj), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,763 :: 		InterrupcionP1(0xB2); // Envia la hora local a la RPi
	MOV.B	#178, W10
	CALL	_InterrupcionP1
;Acelerografo.c,764 :: 		}
L_urx_1199:
;Acelerografo.c,765 :: 		banGPSI = 0;
	MOV	#lo_addr(_banGPSI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,766 :: 		banGPSC = 0;
	MOV	#lo_addr(_banGPSC), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,767 :: 		i_gps = 0;
	CLR	W0
	MOV	W0, _i_gps
;Acelerografo.c,768 :: 		U1MODE.UARTEN = 0; // Desactiva el UART1
	BCLR	U1MODE, #15
;Acelerografo.c,769 :: 		}
L_urx_1187:
;Acelerografo.c,772 :: 		U1RXIF_bit = 0;
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;Acelerografo.c,773 :: 		}
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
