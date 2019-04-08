
_ADXL355_init:

;adxl355_spi.c,103 :: 		void ADXL355_init(){
;adxl355_spi.c,104 :: 		ADXL355_write_byte(POWER_CTL, DRDY_OFF|TEMP_OFF|MEASURING);
	PUSH	W10
	PUSH	W11
	MOV.B	#6, W11
	MOV.B	#45, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,105 :: 		ADXL355_write_byte(Range, _2G);
	MOV.B	#1, W11
	MOV.B	#44, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,106 :: 		ADXL355_write_byte(Filter, NO_HIGH_PASS_FILTER|_62_5_Hz);
	MOV.B	#4, W11
	MOV.B	#40, W10
	CALL	_ADXL355_write_byte
;adxl355_spi.c,107 :: 		}
L_end_ADXL355_init:
	POP	W11
	POP	W10
	RETURN
; end of _ADXL355_init

_ADXL355_write_byte:

;adxl355_spi.c,110 :: 		void ADXL355_write_byte(unsigned char address, unsigned char value){
;adxl355_spi.c,111 :: 		address = (address<<1)&0xFE;
	PUSH	W10
	ZE	W10, W0
	SL	W0, #1, W1
	MOV	#254, W0
	AND	W1, W0, W0
	MOV.B	W0, W10
;adxl355_spi.c,112 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,113 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,114 :: 		SPI2_Write(value);
	ZE	W11, W10
	CALL	_SPI2_Write
;adxl355_spi.c,115 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,116 :: 		}
L_end_ADXL355_write_byte:
	POP	W10
	RETURN
; end of _ADXL355_write_byte

_ADXL355_read_byte:

;adxl355_spi.c,119 :: 		unsigned char ADXL355_read_byte(unsigned char address){
;adxl355_spi.c,120 :: 		unsigned char value = 0x00;
	PUSH	W10
;adxl355_spi.c,121 :: 		address=(address<<1)|0x01;
	ZE	W10, W0
	SL	W0, #1, W0
	IOR	W0, #1, W0
	MOV.B	W0, W10
;adxl355_spi.c,122 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,123 :: 		SPI2_Write(address);
	ZE	W0, W10
	CALL	_SPI2_Write
;adxl355_spi.c,124 :: 		value=SPI2_Read(0);
	CLR	W10
	CALL	_SPI2_Read
;adxl355_spi.c,125 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,126 :: 		return value;
;adxl355_spi.c,127 :: 		}
;adxl355_spi.c,126 :: 		return value;
;adxl355_spi.c,127 :: 		}
L_end_ADXL355_read_byte:
	POP	W10
	RETURN
; end of _ADXL355_read_byte

_ADXL355_read_data:
	LNK	#2

;adxl355_spi.c,130 :: 		unsigned int ADXL355_read_data(unsigned char *vectorMuestra){
;adxl355_spi.c,133 :: 		if((ADXL355_read_byte(Status)&0x01)==1){                                 //Verifica que el bit DATA_RDY del registro Status este en alto
	PUSH	W10
	MOV.B	#4, W10
	CALL	_ADXL355_read_byte
	POP	W10
	ZE	W0, W0
	AND	W0, #1, W0
	CP	W0, #1
	BRA Z	L__ADXL355_read_data53
	GOTO	L_ADXL355_read_data0
L__ADXL355_read_data53:
;adxl355_spi.c,134 :: 		CS_ADXL355=0;
	BCLR	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,135 :: 		for (j=0;j<9;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data1:
; j start address is: 4 (W2)
	CP.B	W2, #9
	BRA LTU	L__ADXL355_read_data54
	GOTO	L_ADXL355_read_data2
L__ADXL355_read_data54:
;adxl355_spi.c,136 :: 		muestra = ADXL355_read_byte(axisAddresses[j]);
	ZE	W2, W1
	MOV	#lo_addr(_axisAddresses), W0
	ADD	W0, W1, W0
	PUSH	W10
	MOV.B	[W0], W10
	CALL	_ADXL355_read_byte
	POP	W10
; muestra start address is: 6 (W3)
	MOV.B	W0, W3
;adxl355_spi.c,137 :: 		if (j==2||j==5||j==8){
	CP.B	W2, #2
	BRA NZ	L__ADXL355_read_data55
	GOTO	L__ADXL355_read_data42
L__ADXL355_read_data55:
	CP.B	W2, #5
	BRA NZ	L__ADXL355_read_data56
	GOTO	L__ADXL355_read_data41
L__ADXL355_read_data56:
	CP.B	W2, #8
	BRA NZ	L__ADXL355_read_data57
	GOTO	L__ADXL355_read_data40
L__ADXL355_read_data57:
	GOTO	L_ADXL355_read_data6
L__ADXL355_read_data42:
L__ADXL355_read_data41:
L__ADXL355_read_data40:
;adxl355_spi.c,138 :: 		vectorMuestra[j] = (muestra>>4)&0x0F;
	ZE	W2, W0
	ADD	W10, W0, W1
	ZE	W3, W0
; muestra end address is: 6 (W3)
	LSR	W0, #4, W0
	ZE	W0, W0
	AND	W0, #15, W0
	MOV.B	W0, [W1]
;adxl355_spi.c,139 :: 		} else {
	GOTO	L_ADXL355_read_data7
L_ADXL355_read_data6:
;adxl355_spi.c,140 :: 		vectorMuestra[j] = muestra;
; muestra start address is: 6 (W3)
	ZE	W2, W0
	ADD	W10, W0, W0
	MOV.B	W3, [W0]
; muestra end address is: 6 (W3)
;adxl355_spi.c,141 :: 		}
L_ADXL355_read_data7:
;adxl355_spi.c,135 :: 		for (j=0;j<9;j++){
	INC.B	W2
;adxl355_spi.c,142 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data1
L_ADXL355_read_data2:
;adxl355_spi.c,143 :: 		CS_ADXL355=1;
	BSET	LATA3_bit, BitPos(LATA3_bit+0)
;adxl355_spi.c,144 :: 		} else {
	GOTO	L_ADXL355_read_data8
L_ADXL355_read_data0:
;adxl355_spi.c,145 :: 		for (j=0;j<8;j++){
; j start address is: 4 (W2)
	CLR	W2
; j end address is: 4 (W2)
L_ADXL355_read_data9:
; j start address is: 4 (W2)
	CP.B	W2, #8
	BRA LTU	L__ADXL355_read_data58
	GOTO	L_ADXL355_read_data10
L__ADXL355_read_data58:
;adxl355_spi.c,146 :: 		vectorMuestra[j] = 0;
	ZE	W2, W0
	ADD	W10, W0, W1
	CLR	W0
	MOV.B	W0, [W1]
;adxl355_spi.c,145 :: 		for (j=0;j<8;j++){
	INC.B	W2
;adxl355_spi.c,147 :: 		}
; j end address is: 4 (W2)
	GOTO	L_ADXL355_read_data9
L_ADXL355_read_data10:
;adxl355_spi.c,148 :: 		vectorMuestra[8] = (ADXL355_read_byte(Status)&0x7F);                //Rellena el ultimo byte de la trama con el contenido del registro Status
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
;adxl355_spi.c,149 :: 		}
L_ADXL355_read_data8:
;adxl355_spi.c,150 :: 		return;
;adxl355_spi.c,151 :: 		}
L_end_ADXL355_read_data:
	ULNK
	RETURN
; end of _ADXL355_read_data

_ConfiguracionPrincipal:

;Acelerografo.c,51 :: 		void ConfiguracionPrincipal(){
;Acelerografo.c,54 :: 		CLKDIVbits.FRCDIV = 0;                             //FIN=FRC/1
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	CLKDIVbits, W1
	MOV	#63743, W0
	AND	W1, W0, W0
	MOV	WREG, CLKDIVbits
;Acelerografo.c,55 :: 		CLKDIVbits.PLLPOST = 0;                            //N2=2
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,56 :: 		CLKDIVbits.PLLPRE = 5;                             //N1=7
	MOV.B	#5, W0
	MOV.B	W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(CLKDIVbits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;Acelerografo.c,57 :: 		PLLFBDbits.PLLDIV = 150;                           //M=152
	MOV	#150, W0
	MOV	W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	#511, W0
	AND	W1, W0, W1
	MOV	#lo_addr(PLLFBDbits), W0
	XOR	W1, [W0], W1
	MOV	W1, PLLFBDbits
;Acelerografo.c,59 :: 		ANSELA = 0;                                        //Configura PORTA como digital     *
	CLR	ANSELA
;Acelerografo.c,60 :: 		ANSELB = 0;                                        //Configura PORTB como digital     *
	CLR	ANSELB
;Acelerografo.c,61 :: 		TRISA3_bit = 0;                                    //Configura el pin A3 como salida  *
	BCLR	TRISA3_bit, BitPos(TRISA3_bit+0)
;Acelerografo.c,62 :: 		TRISA4_bit = 0;                                    //Configura el pin A4 como salida  *
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;Acelerografo.c,63 :: 		TRISB4_bit = 0;                                    //Configura el pin B4 como salida  *
	BCLR	TRISB4_bit, BitPos(TRISB4_bit+0)
;Acelerografo.c,64 :: 		TRISB10_bit = 0;                                   //Configura el pin B10 como entrada *
	BCLR	TRISB10_bit, BitPos(TRISB10_bit+0)
;Acelerografo.c,65 :: 		TRISB11_bit = 1;                                   //Configura el pin B11 como entrada *
	BSET	TRISB11_bit, BitPos(TRISB11_bit+0)
;Acelerografo.c,66 :: 		TRISB12_bit = 1;                                   //Configura el pin B12 como entrada *
	BSET	TRISB12_bit, BitPos(TRISB12_bit+0)
;Acelerografo.c,67 :: 		TRISB13_bit = 1;                                   //Configura el pin B13 como entrada *
	BSET	TRISB13_bit, BitPos(TRISB13_bit+0)
;Acelerografo.c,69 :: 		INTCON2.GIE = 1;                                   //Habilita las interrupciones globales *
	BSET	INTCON2, #15
;Acelerografo.c,76 :: 		SPI1STAT.SPIEN = 1;                                //Habilita el SPI1 *
	BSET	SPI1STAT, #15
;Acelerografo.c,77 :: 		SPI1_Init_Advanced(_SPI_SLAVE, _SPI_8_BIT, _SPI_PRESCALE_SEC_1, _SPI_PRESCALE_PRI_1, _SPI_SS_ENABLE, _SPI_DATA_SAMPLE_END, _SPI_CLK_IDLE_HIGH, _SPI_ACTIVE_2_IDLE);        //*
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
;Acelerografo.c,78 :: 		SPI1IE_bit = 1;                                    //Habilita la interrupcion por SPI1  *
	BSET	SPI1IE_bit, BitPos(SPI1IE_bit+0)
;Acelerografo.c,79 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI *
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,82 :: 		RPINR22bits.SDI2R = 0x21;                          //Configura el pin RB1/RPI33 como SDI2 *
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
;Acelerografo.c,83 :: 		RPOR2bits.RP38R = 0x08;                            //Configura el SDO2 en el pin RB6/RP38 *
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
;Acelerografo.c,84 :: 		RPOR1bits.RP37R = 0x09;                            //Configura el SCK2 en el pin RB5/RP37 *
	MOV	#2304, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	#16128, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR1bits
;Acelerografo.c,85 :: 		SPI2STAT.SPIEN = 1;                                //Habilita el SPI2 *
	BSET	SPI2STAT, #15
;Acelerografo.c,86 :: 		SPI2_Init();                                       //Inicializa el modulo SPI2
	CALL	_SPI2_Init
;Acelerografo.c,89 :: 		RPINR0 = 0x2E00;                                   //Asigna INT1 al RB14/RPI46
	MOV	#11776, W0
	MOV	WREG, RPINR0
;Acelerografo.c,90 :: 		INT1IE_bit = 1;                                    //Habilita la interrupcion externa INT1
	BSET	INT1IE_bit, BitPos(INT1IE_bit+0)
;Acelerografo.c,91 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,92 :: 		IPC0 = 0x0001;                                     //Prioridad en la interrupocion externa 1
	MOV	#1, W0
	MOV	WREG, IPC0
;Acelerografo.c,95 :: 		T1CON = 0x0010;
	MOV	#16, W0
	MOV	WREG, T1CON
;Acelerografo.c,96 :: 		T1CON.TON = 0;                                     //Apaga el Timer1
	BCLR	T1CON, #15
;Acelerografo.c,97 :: 		T1IE_bit = 1;                                      //Habilita la interrupción de desbordamiento TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;Acelerografo.c,98 :: 		T1IF_bit = 0;                                      //Limpia la bandera de interrupcion del TMR2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,99 :: 		IPC0 = 0x1000;                                     //Prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#4096, W0
	MOV	WREG, IPC0
;Acelerografo.c,100 :: 		PR1 = 25000;
	MOV	#25000, W0
	MOV	WREG, PR1
;Acelerografo.c,102 :: 		ADXL355_init();
	CALL	_ADXL355_init
;Acelerografo.c,104 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOV	#13, W8
	MOV	#13575, W7
L_ConfiguracionPrincipal12:
	DEC	W7
	BRA NZ	L_ConfiguracionPrincipal12
	DEC	W8
	BRA NZ	L_ConfiguracionPrincipal12
;Acelerografo.c,106 :: 		}
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

;Acelerografo.c,114 :: 		void int_1() org IVT_ADDR_INT1INTERRUPT {
;Acelerografo.c,115 :: 		INT1IF_bit = 0;                                    //Limpia la bandera de interrupcion externa INT1
	PUSH	W10
	BCLR	INT1IF_bit, BitPos(INT1IF_bit+0)
;Acelerografo.c,116 :: 		contMuestras = 0;                                  //Limpia el contador de muestras
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,118 :: 		pduSPI[0] = contCiclos;                            //Carga el primer valor de la trama que se enviara por el SPI con el valor de la muestra actual
	MOV	#lo_addr(_pduSPI), W1
	MOV	#lo_addr(_contCiclos), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,119 :: 		ADXL355_read_data(datosLeidos);
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_data
;Acelerografo.c,120 :: 		for (x=1;x<10;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_int_114:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__int_161
	GOTO	L_int_115
L__int_161:
;Acelerografo.c,121 :: 		pduSPI[x]=datosLeidos[x-1];                    //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
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
;Acelerografo.c,120 :: 		for (x=1;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,122 :: 		}
	GOTO	L_int_114
L_int_115:
;Acelerografo.c,124 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,125 :: 		RP1 = 1;                                           //Genera el pulso P1 para producir la interrupcion en la RPi
	BSET	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,126 :: 		Delay_us(20);
	MOV	#160, W7
L_int_117:
	DEC	W7
	BRA NZ	L_int_117
	NOP
	NOP
;Acelerografo.c,127 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,128 :: 		T1CON.TON = 1;                                     //Enciende el Timer1
	BSET	T1CON, #15
;Acelerografo.c,129 :: 		contCiclos++;
	MOV.B	#1, W1
	MOV	#lo_addr(_contCiclos), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,130 :: 		}
L_end_int_1:
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

;Acelerografo.c,133 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT{
;Acelerografo.c,134 :: 		T1IF_bit = 0;
	PUSH	W10
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;Acelerografo.c,135 :: 		contMuestras++;                                    //Incrementa el contador de muestras
	MOV.B	#1, W1
	MOV	#lo_addr(_contMuestras), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,137 :: 		pduSPI[0] = contMuestras;                          //Carga el primer valor de la trama de datos con el valor de la muestra actual
	MOV	#lo_addr(_pduSPI), W1
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], [W1]
;Acelerografo.c,138 :: 		ADXL355_read_data(datosLeidos);
	MOV	#lo_addr(_datosLeidos), W10
	CALL	_ADXL355_read_data
;Acelerografo.c,139 :: 		for (x=1;x<10;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_Timer1Int19:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Timer1Int63
	GOTO	L_Timer1Int20
L__Timer1Int63:
;Acelerografo.c,140 :: 		pduSPI[x]=datosLeidos[x-1];                      //Carga el vector de salida de datos SPI con los datos de simulacion de muestreo
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
;Acelerografo.c,139 :: 		for (x=1;x<10;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,141 :: 		}
	GOTO	L_Timer1Int19
L_Timer1Int20:
;Acelerografo.c,142 :: 		if (contMuestras==NUM_MUESTRAS){
	MOV	#lo_addr(_contMuestras), W0
	MOV.B	[W0], W1
	MOV.B	#199, W0
	CP.B	W1, W0
	BRA Z	L__Timer1Int64
	GOTO	L_Timer1Int22
L__Timer1Int64:
;Acelerografo.c,143 :: 		T1CON.TON = 0;                                  //Apaga el Timer2
	BCLR	T1CON, #15
;Acelerografo.c,144 :: 		for (x=10;x<15;x++){
	MOV	#lo_addr(_x), W1
	MOV.B	#10, W0
	MOV.B	W0, [W1]
L_Timer1Int23:
	MOV	#lo_addr(_x), W0
	MOV.B	[W0], W0
	CP.B	W0, #15
	BRA LTU	L__Timer1Int65
	GOTO	L_Timer1Int24
L__Timer1Int65:
;Acelerografo.c,145 :: 		pduSPI[x]=tiempo[x-10];                     //Carga el vector de salida de datos SPI con los datos de la cabecera
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
;Acelerografo.c,144 :: 		for (x=10;x<15;x++){
	MOV.B	#1, W1
	MOV	#lo_addr(_x), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,146 :: 		}
	GOTO	L_Timer1Int23
L_Timer1Int24:
;Acelerografo.c,147 :: 		}
L_Timer1Int22:
;Acelerografo.c,149 :: 		banTI = 1;                                         //Activa la bandera de inicio de trama
	MOV	#lo_addr(_banTI), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,150 :: 		RP2 = 1;                                           //Genera el pulso P2 para producir la interrupcion en la RPi
	BSET	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,151 :: 		Delay_us(20);
	MOV	#160, W7
L_Timer1Int26:
	DEC	W7
	BRA NZ	L_Timer1Int26
	NOP
	NOP
;Acelerografo.c,152 :: 		RP2 = 0;                                           //Limpia la bandera de interrupcion por desbordamiento del Timer1
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,153 :: 		}
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

_spi_1:
	PUSH	DSWPAG
	PUSH	50
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;Acelerografo.c,156 :: 		void spi_1() org  IVT_ADDR_SPI1INTERRUPT {
;Acelerografo.c,157 :: 		SPI1IF_bit = 0;                                    //Limpia la bandera de interrupcion por SPI
	BCLR	SPI1IF_bit, BitPos(SPI1IF_bit+0)
;Acelerografo.c,158 :: 		buffer = SPI1BUF;                                  //Guarda el contenido del bufeer (lectura)
	MOV	#lo_addr(_buffer), W1
	MOV.B	SPI1BUF, WREG
	MOV.B	W0, [W1]
;Acelerografo.c,160 :: 		if ((banTI==1)){                                   //Verifica si la bandera de inicio de trama esta activa
	MOV	#lo_addr(_banTI), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_167
	GOTO	L_spi_128
L__spi_167:
;Acelerografo.c,161 :: 		banLec = 1;                                     //Activa la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;Acelerografo.c,162 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,163 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,164 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,165 :: 		}
L_spi_128:
;Acelerografo.c,166 :: 		if ((banLec==1)&&(buffer!=0xB1)){
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_168
	GOTO	L__spi_146
L__spi_168:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA NZ	L__spi_169
	GOTO	L__spi_145
L__spi_169:
L__spi_144:
;Acelerografo.c,167 :: 		SPI1BUF = pduSPI[i];
	MOV	#lo_addr(_i), W0
	ZE	[W0], W1
	MOV	#lo_addr(_pduSPI), W0
	ADD	W0, W1, W0
	MOV.B	[W0], W0
	ZE	W0, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,168 :: 		i++;
	MOV.B	#1, W1
	MOV	#lo_addr(_i), W0
	ADD.B	W1, [W0], [W0]
;Acelerografo.c,166 :: 		if ((banLec==1)&&(buffer!=0xB1)){
L__spi_146:
L__spi_145:
;Acelerografo.c,170 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
	MOV	#lo_addr(_banLec), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__spi_170
	GOTO	L__spi_148
L__spi_170:
	MOV	#lo_addr(_buffer), W0
	MOV.B	[W0], W1
	MOV.B	#177, W0
	CP.B	W1, W0
	BRA Z	L__spi_171
	GOTO	L__spi_147
L__spi_171:
L__spi_143:
;Acelerografo.c,171 :: 		banLec = 0;                                     //Limpia la bandera de lectura
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,172 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,173 :: 		SPI1BUF = 0xFF;
	MOV	#255, W0
	MOV	WREG, SPI1BUF
;Acelerografo.c,170 :: 		if ((banLec==1)&&(buffer==0xB1)){                  //Si detecta el delimitador de final de trama:
L__spi_148:
L__spi_147:
;Acelerografo.c,175 :: 		}
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

;Acelerografo.c,182 :: 		void main() {
;Acelerografo.c,184 :: 		ConfiguracionPrincipal();
	CALL	_ConfiguracionPrincipal
;Acelerografo.c,186 :: 		tiempo[0] = 19;                                    //Año
	MOV	#lo_addr(_tiempo), W1
	MOV.B	#19, W0
	MOV.B	W0, [W1]
;Acelerografo.c,187 :: 		tiempo[1] = 49;                                    //Dia
	MOV	#lo_addr(_tiempo+1), W1
	MOV.B	#49, W0
	MOV.B	W0, [W1]
;Acelerografo.c,188 :: 		tiempo[2] = 9;                                     //Hora
	MOV	#lo_addr(_tiempo+2), W1
	MOV.B	#9, W0
	MOV.B	W0, [W1]
;Acelerografo.c,189 :: 		tiempo[3] = 30;                                    //Minuto
	MOV	#lo_addr(_tiempo+3), W1
	MOV.B	#30, W0
	MOV.B	W0, [W1]
;Acelerografo.c,190 :: 		tiempo[4] = 0;                                     //Segundo
	MOV	#lo_addr(_tiempo+4), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,196 :: 		banTI = 0;
	MOV	#lo_addr(_banTI), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,197 :: 		banLec = 0;
	MOV	#lo_addr(_banLec), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,198 :: 		i = 0;
	MOV	#lo_addr(_i), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,199 :: 		x = 0;
	MOV	#lo_addr(_x), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,201 :: 		contMuestras = 0;
	MOV	#lo_addr(_contMuestras), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,202 :: 		contCiclos = 0;
	MOV	#lo_addr(_contCiclos), W1
	CLR	W0
	MOV.B	W0, [W1]
;Acelerografo.c,203 :: 		RP1 = 0;
	BCLR	LATA4_bit, BitPos(LATA4_bit+0)
;Acelerografo.c,204 :: 		RP2 = 0;
	BCLR	LATB4_bit, BitPos(LATB4_bit+0)
;Acelerografo.c,206 :: 		puntero_8 = &auxiliar;
	MOV	#lo_addr(_auxiliar), W0
	MOV	W0, _puntero_8
;Acelerografo.c,208 :: 		SPI1BUF = 0x00;
	CLR	SPI1BUF
;Acelerografo.c,210 :: 		while(1){
L_main35:
;Acelerografo.c,212 :: 		Delay_ms(500);
	MOV	#62, W8
	MOV	#2340, W7
L_main37:
	DEC	W7
	BRA NZ	L_main37
	DEC	W8
	BRA NZ	L_main37
	NOP
	NOP
;Acelerografo.c,214 :: 		}
	GOTO	L_main35
;Acelerografo.c,216 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
