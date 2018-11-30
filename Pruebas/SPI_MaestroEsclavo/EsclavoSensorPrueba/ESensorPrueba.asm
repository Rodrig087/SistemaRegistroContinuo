
_ConfiguracionPrincipal:

;ESensorPrueba.c,33 :: 		void ConfiguracionPrincipal(){
;ESensorPrueba.c,35 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;ESensorPrueba.c,36 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;ESensorPrueba.c,37 :: 		TRISA5_bit = 1;
	BSF        TRISA5_bit+0, BitPos(TRISA5_bit+0)
;ESensorPrueba.c,39 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;ESensorPrueba.c,40 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;ESensorPrueba.c,43 :: 		UART1_Init(19200);                                 //Inicializa el UART1 a 19200 bps
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;ESensorPrueba.c,47 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      4
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;ESensorPrueba.c,48 :: 		PIE1.SSPIE = 1;                                  //Habilita la interrupcion por SPI
	BSF        PIE1+0, 3
;ESensorPrueba.c,51 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;ESensorPrueba.c,52 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;ESensorPrueba.c,53 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de bajada
	BSF        OPTION_REG+0, 6
;ESensorPrueba.c,55 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_ConfiguracionPrincipal0:
	DECFSZ     R13+0, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R12+0, 1
	GOTO       L_ConfiguracionPrincipal0
	DECFSZ     R11+0, 1
	GOTO       L_ConfiguracionPrincipal0
	NOP
;ESensorPrueba.c,57 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;ESensorPrueba.c,66 :: 		void interrupt(){
;ESensorPrueba.c,69 :: 		if (INTCON.INTF==1){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt1
;ESensorPrueba.c,70 :: 		INTCON.INTF = 0;                                  //Limpia la badera de interrupcion externa
	BCF        INTCON+0, 1
;ESensorPrueba.c,71 :: 		SSPBUF = 0xBB;
	MOVLW      187
	MOVWF      SSPBUF+0
;ESensorPrueba.c,72 :: 		}
L_interrupt1:
;ESensorPrueba.c,75 :: 		if (PIR1.SSPIF){
	BTFSS      PIR1+0, 3
	GOTO       L_interrupt2
;ESensorPrueba.c,77 :: 		PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF        PIR1+0, 3
;ESensorPrueba.c,78 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;ESensorPrueba.c,79 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;ESensorPrueba.c,81 :: 		buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
	MOVF       SSPBUF+0, 0
	MOVWF      _buffer+0
;ESensorPrueba.c,83 :: 		if (buffer==0xA0){                                //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
;ESensorPrueba.c,84 :: 		banMed = 1;
	MOVLW      1
	MOVWF      _banMed+0
;ESensorPrueba.c,85 :: 		SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      160
	MOVWF      SSPBUF+0
;ESensorPrueba.c,86 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt4:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt4
;ESensorPrueba.c,87 :: 		}
L_interrupt3:
;ESensorPrueba.c,88 :: 		if ((banMed==1)&&(buffer!=0xA0)&&(buffer!=0xA1)){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
	MOVF       _buffer+0, 0
	XORLW      161
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt21:
;ESensorPrueba.c,89 :: 		registro = buffer;
	MOVF       _buffer+0, 0
	MOVWF      _registro+0
;ESensorPrueba.c,90 :: 		switch (registro){
	GOTO       L_interrupt8
;ESensorPrueba.c,91 :: 		case 1:
L_interrupt10:
;ESensorPrueba.c,92 :: 		numBytesSPI = 0x02;                //Si solicita leer el registro #1 establece que el numero de bytes que va a responder sera 2 (ejemplo)
	MOVLW      2
	MOVWF      _numBytesSPI+0
;ESensorPrueba.c,93 :: 		SSPBUF = numBytesSPI;              //Escribe la variable numBytesSPI en el buffer para enviarle al Maestro el numero de bytes que le va a responder
	MOVLW      2
	MOVWF      SSPBUF+0
;ESensorPrueba.c,94 :: 		break;
	GOTO       L_interrupt9
;ESensorPrueba.c,95 :: 		case 2:
L_interrupt11:
;ESensorPrueba.c,96 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;ESensorPrueba.c,97 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;ESensorPrueba.c,98 :: 		break;
	GOTO       L_interrupt9
;ESensorPrueba.c,99 :: 		default:
L_interrupt12:
;ESensorPrueba.c,100 :: 		SSPBUF = 0;                        //**Hay que revisar esto para que no de error**
	CLRF       SSPBUF+0
;ESensorPrueba.c,101 :: 		}
	GOTO       L_interrupt9
L_interrupt8:
	MOVF       _registro+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
	MOVF       _registro+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt11
	GOTO       L_interrupt12
L_interrupt9:
;ESensorPrueba.c,102 :: 		}
L_interrupt7:
;ESensorPrueba.c,103 :: 		if (buffer==0xA1){                                //Si detecta el delimitador de final de trama:
	MOVF       _buffer+0, 0
	XORLW      161
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;ESensorPrueba.c,104 :: 		banPet = 1;                                    //Activa la bandera de peticion
	MOVLW      1
	MOVWF      _banPet+0
;ESensorPrueba.c,105 :: 		banMed = 0;                                    //Limpia la bandera de medicion
	CLRF       _banMed+0
;ESensorPrueba.c,106 :: 		banResp = 0;                                   //Limpia la bandera de peticion. **Esto parece no ser necesario pero quiero asegurarme de que no entre al siguiente if sin antes pasar por el bucle
	CLRF       _banResp+0
;ESensorPrueba.c,107 :: 		UART1_Write(registro);                         //Manda por UART el valor del registro que solicito el Maestro (Es un ejemplo, no es necesario y se puede eliminar)
	MOVF       _registro+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;ESensorPrueba.c,108 :: 		SSPBUF = 0xB0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      176
	MOVWF      SSPBUF+0
;ESensorPrueba.c,109 :: 		}
L_interrupt13:
;ESensorPrueba.c,111 :: 		if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
	MOVF       _banResp+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;ESensorPrueba.c,112 :: 		if (i<numBytesSPI){
	MOVF       _numBytesSPI+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt15
;ESensorPrueba.c,113 :: 		SSPBUF = resSPI[i];
	MOVF       _i+0, 0
	ADDLW      _resSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;ESensorPrueba.c,114 :: 		i++;
	INCF       _i+0, 1
;ESensorPrueba.c,115 :: 		}
L_interrupt15:
;ESensorPrueba.c,116 :: 		}
L_interrupt14:
;ESensorPrueba.c,119 :: 		}
L_interrupt2:
;ESensorPrueba.c,121 :: 		}
L_end_interrupt:
L__interrupt24:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;ESensorPrueba.c,124 :: 		void main() {
;ESensorPrueba.c,126 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;ESensorPrueba.c,127 :: 		ECINT = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;ESensorPrueba.c,128 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;ESensorPrueba.c,129 :: 		i = 0;
	CLRF       _i+0
;ESensorPrueba.c,130 :: 		x = 0;
	CLRF       _x+0
;ESensorPrueba.c,131 :: 		banPet = 0;
	CLRF       _banPet+0
;ESensorPrueba.c,132 :: 		banResp = 0;
	CLRF       _banResp+0
;ESensorPrueba.c,133 :: 		banSPI = 0;
	CLRF       _banSPI+0
;ESensorPrueba.c,134 :: 		banMed = 0;
	CLRF       _banMed+0
;ESensorPrueba.c,135 :: 		respSPI = 0xC0;
	MOVLW      192
	MOVWF      _respSPI+0
;ESensorPrueba.c,136 :: 		SSPBUF = 0xA0;                                   //Carga un valor inicial en el buffer
	MOVLW      160
	MOVWF      SSPBUF+0
;ESensorPrueba.c,139 :: 		while(1){
L_main16:
;ESensorPrueba.c,141 :: 		if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
	MOVF       _banPet+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main18
;ESensorPrueba.c,142 :: 		Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main19:
	DECFSZ     R13+0, 1
	GOTO       L_main19
	DECFSZ     R12+0, 1
	GOTO       L_main19
	DECFSZ     R11+0, 1
	GOTO       L_main19
	NOP
	NOP
;ESensorPrueba.c,143 :: 		resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
	MOVLW      131
	MOVWF      _resSPI+0
;ESensorPrueba.c,144 :: 		resSPI[1] = 0x58;
	MOVLW      88
	MOVWF      _resSPI+1
;ESensorPrueba.c,145 :: 		resSPI[2] = 0x8F;
	MOVLW      143
	MOVWF      _resSPI+2
;ESensorPrueba.c,146 :: 		resSPI[3] = 0x5C;
	MOVLW      92
	MOVWF      _resSPI+3
;ESensorPrueba.c,147 :: 		i=0;
	CLRF       _i+0
;ESensorPrueba.c,149 :: 		ECINT = 1;                               //Genera un pulso en alto para producir una interrupcion externa en el Master
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;ESensorPrueba.c,150 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_main20:
	DECFSZ     R13+0, 1
	GOTO       L_main20
	DECFSZ     R12+0, 1
	GOTO       L_main20
	NOP
	NOP
;ESensorPrueba.c,151 :: 		ECINT = 0;
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;ESensorPrueba.c,152 :: 		banPet = 0;                              //Limpia la bandera de peticion SPI
	CLRF       _banPet+0
;ESensorPrueba.c,153 :: 		banResp = 1;                             //Activa la bandera de respuesta SPI
	MOVLW      1
	MOVWF      _banResp+0
;ESensorPrueba.c,155 :: 		}
L_main18:
;ESensorPrueba.c,157 :: 		}
	GOTO       L_main16
;ESensorPrueba.c,159 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
