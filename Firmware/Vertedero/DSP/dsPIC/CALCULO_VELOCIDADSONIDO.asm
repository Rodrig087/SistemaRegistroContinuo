
_CalcularVelocidadSonido:
	LNK	#4

;CALCULO_VELOCIDADSONIDO.c,2 :: 		float CalcularVelocidadSonido(){
;CALCULO_VELOCIDADSONIDO.c,6 :: 		Ow_Reset(&PORTA, 0);                                                       //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;CALCULO_VELOCIDADSONIDO.c,7 :: 		Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;CALCULO_VELOCIDADSONIDO.c,8 :: 		Ow_Write(&PORTA, 0, 0x44);                                                 //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;CALCULO_VELOCIDADSONIDO.c,9 :: 		Delay_us(100);
	MOV	#1333, W7
L_CalcularVelocidadSonido0:
	DEC	W7
	BRA NZ	L_CalcularVelocidadSonido0
	NOP
;CALCULO_VELOCIDADSONIDO.c,11 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;CALCULO_VELOCIDADSONIDO.c,12 :: 		Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;CALCULO_VELOCIDADSONIDO.c,13 :: 		Ow_Write(&PORTA, 0, 0xBE);                                                 //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;CALCULO_VELOCIDADSONIDO.c,14 :: 		Delay_us(100);
	MOV	#1333, W7
L_CalcularVelocidadSonido2:
	DEC	W7
	BRA NZ	L_CalcularVelocidadSonido2
	NOP
;CALCULO_VELOCIDADSONIDO.c,16 :: 		temperatura =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; temperatura start address is: 10 (W5)
	ZE	W0, W5
;CALCULO_VELOCIDADSONIDO.c,17 :: 		temperatura = (Ow_Read(&PORTA, 0) << 8) + temperatura;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; temperatura end address is: 10 (W5)
; temperatura start address is: 4 (W2)
	MOV	W0, W2
;CALCULO_VELOCIDADSONIDO.c,19 :: 		if (temperatura & 0x8000) {
	BTSS	W0, #15
	GOTO	L__CalcularVelocidadSonido5
;CALCULO_VELOCIDADSONIDO.c,20 :: 		temperatura = 0;                                                        //Si la temperatura es negativa la establece como cero.
	CLR	W2
; temperatura end address is: 4 (W2)
;CALCULO_VELOCIDADSONIDO.c,21 :: 		}
	GOTO	L_CalcularVelocidadSonido4
L__CalcularVelocidadSonido5:
;CALCULO_VELOCIDADSONIDO.c,19 :: 		if (temperatura & 0x8000) {
;CALCULO_VELOCIDADSONIDO.c,21 :: 		}
L_CalcularVelocidadSonido4:
;CALCULO_VELOCIDADSONIDO.c,23 :: 		temperatura_int = temperatura >> 4;                                        //Extrae la parte entera de la respuesta del sensor
; temperatura start address is: 4 (W2)
	LSR	W2, #4, W0
; temperatura_int start address is: 6 (W3)
	MOV	W0, W3
;CALCULO_VELOCIDADSONIDO.c,24 :: 		temperatura_Frac = ((temperatura & 0x000F) * 625) / 10000.;                //Extrae la parte decimal de la respuesta del sensor
	AND	W2, #15, W1
; temperatura end address is: 4 (W2)
	MOV	#625, W0
	MUL.UU	W1, W0, W0
	PUSH	W3
	CLR	W1
	CALL	__Long2Float
	MOV	#16384, W2
	MOV	#17948, W3
	CALL	__Div_FP
	POP	W3
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
;CALCULO_VELOCIDADSONIDO.c,25 :: 		temperatura_Float = temperatura_Int + temperatura_Frac;                    //Expresa la temperatura en punto flotante
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; temperatura_int end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
;CALCULO_VELOCIDADSONIDO.c,27 :: 		VSnd = 331.45 * sqrt(1+(temperatura_Float/273));
	MOV	#32768, W2
	MOV	#17288, W3
	CALL	__Div_FP
	MOV	#0, W2
	MOV	#16256, W3
	CALL	__AddSub_FP
	MOV.D	W0, W10
	CALL	_sqrt
	MOV	#47514, W2
	MOV	#17317, W3
	CALL	__Mul_FP
;CALCULO_VELOCIDADSONIDO.c,29 :: 		return VSnd;
;CALCULO_VELOCIDADSONIDO.c,31 :: 		}
;CALCULO_VELOCIDADSONIDO.c,29 :: 		return VSnd;
;CALCULO_VELOCIDADSONIDO.c,31 :: 		}
L_end_CalcularVelocidadSonido:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _CalcularVelocidadSonido
