
_RecuperarFechaRPI:
	LNK	#4

;TIEMPO_RPI.c,8 :: 		unsigned long RecuperarFechaRPI(unsigned char *tramaTiempoRpi){
;TIEMPO_RPI.c,12 :: 		fechaRPi = ((unsigned long)tramaTiempoRpi[0]*10000)+((unsigned long)tramaTiempoRpi[1]*100)+((unsigned long)tramaTiempoRpi[2]);      //10000*aa + 100*mm + dd
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
;TIEMPO_RPI.c,14 :: 		return fechaRPi;
;TIEMPO_RPI.c,16 :: 		}
L_end_RecuperarFechaRPI:
	ULNK
	RETURN
; end of _RecuperarFechaRPI

_RecuperarHoraRPI:
	LNK	#4

;TIEMPO_RPI.c,19 :: 		unsigned long RecuperarHoraRPI(unsigned char *tramaTiempoRpi){
;TIEMPO_RPI.c,23 :: 		horaRPi = ((unsigned long)tramaTiempoRpi[3]*3600)+((unsigned long)tramaTiempoRpi[4]*60)+((unsigned long)tramaTiempoRpi[5]);      //Calcula el segundo actual = hh*3600 + mm*60 + ss
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
;TIEMPO_RPI.c,25 :: 		return horaRPi;
;TIEMPO_RPI.c,27 :: 		}
L_end_RecuperarHoraRPI:
	ULNK
	RETURN
; end of _RecuperarHoraRPI
