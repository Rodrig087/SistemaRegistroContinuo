
_ConfiguracionPrincipal:

;EsclavoSensor.c,35 :: 		void ConfiguracionPrincipal(){
;EsclavoSensor.c,37 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoSensor.c,38 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoSensor.c,39 :: 		TRISA5_bit = 1;
	BSF        TRISA5_bit+0, BitPos(TRISA5_bit+0)
;EsclavoSensor.c,41 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoSensor.c,42 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoSensor.c,45 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      4
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoSensor.c,46 :: 		PIE1.SSPIE = 1;                                  //Habilita la interrupcion por SPI
	BSF        PIE1+0, 3
;EsclavoSensor.c,48 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoSensor.c,50 :: 		}
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

;EsclavoSensor.c,59 :: 		void interrupt(){
;EsclavoSensor.c,62 :: 		if (PIR1.SSPIF){
	BTFSS      PIR1+0, 3
	GOTO       L_interrupt1
;EsclavoSensor.c,64 :: 		PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF        PIR1+0, 3
;EsclavoSensor.c,65 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,66 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,68 :: 		buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
	MOVF       SSPBUF+0, 0
	MOVWF      _buffer+0
;EsclavoSensor.c,71 :: 		if (buffer==0xA0){                                //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
;EsclavoSensor.c,72 :: 		banMed = 1;
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoSensor.c,73 :: 		SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,74 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt3:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt3
;EsclavoSensor.c,75 :: 		}
L_interrupt2:
;EsclavoSensor.c,76 :: 		if ((banMed==1)&&(buffer!=0xA0)){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt6
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt6
L__interrupt27:
;EsclavoSensor.c,77 :: 		registro = buffer;
	MOVF       _buffer+0, 0
	MOVWF      _registro+0
;EsclavoSensor.c,78 :: 		switch (registro){
	GOTO       L_interrupt7
;EsclavoSensor.c,79 :: 		case 1:
L_interrupt9:
;EsclavoSensor.c,80 :: 		numBytesSPI = 0x02;                //Si solicita leer el registro #1 establece que el numero de bytes que va a responder sera 3 (ejemplo), uno de direccion y dos de datos
	MOVLW      2
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,81 :: 		SSPBUF = numBytesSPI;              //Escribe la variable numBytesSPI en el buffer para enviarle al Maestro el numero de bytes que le va a responder
	MOVLW      2
	MOVWF      SSPBUF+0
;EsclavoSensor.c,82 :: 		break;
	GOTO       L_interrupt8
;EsclavoSensor.c,83 :: 		case 2:
L_interrupt10:
;EsclavoSensor.c,84 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,85 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,86 :: 		break;
	GOTO       L_interrupt8
;EsclavoSensor.c,87 :: 		default:
L_interrupt11:
;EsclavoSensor.c,88 :: 		SSPBUF = 0;                        //**Hay que revisar esto para que no de error**
	CLRF       SSPBUF+0
;EsclavoSensor.c,89 :: 		}
	GOTO       L_interrupt8
L_interrupt7:
	MOVF       _registro+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt9
	MOVF       _registro+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
	GOTO       L_interrupt11
L_interrupt8:
;EsclavoSensor.c,90 :: 		}
L_interrupt6:
;EsclavoSensor.c,91 :: 		if (buffer==0xA1){                                //Si detecta el delimitador de final de trama:
	MOVF       _buffer+0, 0
	XORLW      161
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;EsclavoSensor.c,92 :: 		banPet = 1;                                    //Activa la bandera de peticion
	MOVLW      1
	MOVWF      _banPet+0
;EsclavoSensor.c,93 :: 		banMed = 0;                                    //Limpia la bandera de medicion
	CLRF       _banMed+0
;EsclavoSensor.c,94 :: 		banResp = 0;                                   //Limpia la bandera de peticion. **Esto parece no ser necesario pero quiero asegurarme de que no entre al siguiente if sin antes pasar por el bucle
	CLRF       _banResp+0
;EsclavoSensor.c,95 :: 		SSPBUF = 0xB0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      176
	MOVWF      SSPBUF+0
;EsclavoSensor.c,96 :: 		}
L_interrupt12:
;EsclavoSensor.c,99 :: 		if (buffer==0xC0){                                //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      192
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;EsclavoSensor.c,100 :: 		banId = 1;                                     //Activa la bandera de escritura de Id
	MOVLW      1
	MOVWF      _banId+0
;EsclavoSensor.c,101 :: 		SSPBUF = 0xC0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      192
	MOVWF      SSPBUF+0
;EsclavoSensor.c,102 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt14:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt14
;EsclavoSensor.c,103 :: 		}
L_interrupt13:
;EsclavoSensor.c,104 :: 		if ((banId==1)&&(buffer==0xC1)){
	MOVF       _banId+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
	MOVF       _buffer+0, 0
	XORLW      193
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
L__interrupt26:
;EsclavoSensor.c,105 :: 		SSPBUF = idEsclavo;
	MOVLW      9
	MOVWF      SSPBUF+0
;EsclavoSensor.c,106 :: 		}
L_interrupt17:
;EsclavoSensor.c,107 :: 		if (buffer==0xC2){                                //Si detecta el delimitador de final de trama:
	MOVF       _buffer+0, 0
	XORLW      194
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt18
;EsclavoSensor.c,108 :: 		banId = 0;                                     //Limpia la bandera de escritura de Id
	CLRF       _banId+0
;EsclavoSensor.c,109 :: 		SSPBUF = 0xA0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,110 :: 		}
L_interrupt18:
;EsclavoSensor.c,113 :: 		if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
	MOVF       _banResp+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt19
;EsclavoSensor.c,114 :: 		if (i<numBytesSPI){
	MOVF       _numBytesSPI+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt20
;EsclavoSensor.c,115 :: 		SSPBUF = resSPI[i];
	MOVF       _i+0, 0
	ADDLW      _resSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoSensor.c,116 :: 		i++;
	INCF       _i+0, 1
;EsclavoSensor.c,117 :: 		}
L_interrupt20:
;EsclavoSensor.c,118 :: 		}
L_interrupt19:
;EsclavoSensor.c,121 :: 		}
L_interrupt1:
;EsclavoSensor.c,123 :: 		}
L_end_interrupt:
L__interrupt30:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoSensor.c,126 :: 		void main() {
;EsclavoSensor.c,128 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EsclavoSensor.c,129 :: 		ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,130 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,131 :: 		i = 0;
	CLRF       _i+0
;EsclavoSensor.c,132 :: 		x = 0;
	CLRF       _x+0
;EsclavoSensor.c,133 :: 		banPet = 0;
	CLRF       _banPet+0
;EsclavoSensor.c,134 :: 		banResp = 0;
	CLRF       _banResp+0
;EsclavoSensor.c,135 :: 		banSPI = 0;
	CLRF       _banSPI+0
;EsclavoSensor.c,136 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoSensor.c,137 :: 		banId = 0;
	CLRF       _banId+0
;EsclavoSensor.c,139 :: 		respSPI = 0xC0;
	MOVLW      192
	MOVWF      _respSPI+0
;EsclavoSensor.c,140 :: 		SSPBUF = 0xC0;                                   //Carga un valor inicial en el buffer
	MOVLW      192
	MOVWF      SSPBUF+0
;EsclavoSensor.c,143 :: 		while(1){
L_main21:
;EsclavoSensor.c,145 :: 		if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
	MOVF       _banPet+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main23
;EsclavoSensor.c,146 :: 		Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main24:
	DECFSZ     R13+0, 1
	GOTO       L_main24
	DECFSZ     R12+0, 1
	GOTO       L_main24
	DECFSZ     R11+0, 1
	GOTO       L_main24
	NOP
	NOP
;EsclavoSensor.c,147 :: 		resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
	MOVLW      131
	MOVWF      _resSPI+0
;EsclavoSensor.c,148 :: 		resSPI[1] = 0x58;
	MOVLW      88
	MOVWF      _resSPI+1
;EsclavoSensor.c,149 :: 		resSPI[2] = 0x8F;
	MOVLW      143
	MOVWF      _resSPI+2
;EsclavoSensor.c,150 :: 		resSPI[3] = 0x5C;
	MOVLW      92
	MOVWF      _resSPI+3
;EsclavoSensor.c,151 :: 		i=0;
	CLRF       _i+0
;EsclavoSensor.c,153 :: 		ECINT = 0;                               //Genera un pulso en bajo para producir una interrupcion externa en el Master
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,154 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_main25:
	DECFSZ     R13+0, 1
	GOTO       L_main25
	DECFSZ     R12+0, 1
	GOTO       L_main25
	NOP
	NOP
;EsclavoSensor.c,155 :: 		ECINT = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,156 :: 		banPet = 0;                              //Limpia la bandera de peticion SPI
	CLRF       _banPet+0
;EsclavoSensor.c,157 :: 		banResp = 1;                             //Activa la bandera de respuesta SPI
	MOVLW      1
	MOVWF      _banResp+0
;EsclavoSensor.c,159 :: 		}
L_main23:
;EsclavoSensor.c,161 :: 		}
	GOTO       L_main21
;EsclavoSensor.c,163 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
