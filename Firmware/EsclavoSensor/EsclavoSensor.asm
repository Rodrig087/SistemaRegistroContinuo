
_ConfiguracionPrincipal:

;EsclavoSensor.c,56 :: 		void ConfiguracionPrincipal(){
;EsclavoSensor.c,58 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoSensor.c,59 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoSensor.c,60 :: 		TRISA5_bit = 1;
	BSF        TRISA5_bit+0, BitPos(TRISA5_bit+0)
;EsclavoSensor.c,62 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoSensor.c,63 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoSensor.c,66 :: 		SPI1_Init_Advanced(_SPI_SLAVE_SS_ENABLE,_SPI_DATA_SAMPLE_MIDDLE,_SPI_CLK_IDLE_HIGH,_SPI_LOW_2_HIGH);
	MOVLW      4
	MOVWF      FARG_SPI1_Init_Advanced_master+0
	CLRF       FARG_SPI1_Init_Advanced_data_sample+0
	MOVLW      16
	MOVWF      FARG_SPI1_Init_Advanced_clock_idle+0
	MOVLW      1
	MOVWF      FARG_SPI1_Init_Advanced_transmit_edge+0
	CALL       _SPI1_Init_Advanced+0
;EsclavoSensor.c,67 :: 		PIE1.SSPIE = 1;                                  //Habilita la interrupcion por SPI
	BSF        PIE1+0, 3
;EsclavoSensor.c,69 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoSensor.c,71 :: 		}
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

;EsclavoSensor.c,80 :: 		void interrupt(){
;EsclavoSensor.c,83 :: 		if (PIR1.SSPIF){
	BTFSS      PIR1+0, 3
	GOTO       L_interrupt1
;EsclavoSensor.c,85 :: 		PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF        PIR1+0, 3
;EsclavoSensor.c,86 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,87 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,89 :: 		buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
	MOVF       SSPBUF+0, 0
	MOVWF      _buffer+0
;EsclavoSensor.c,92 :: 		if (buffer==0xA0){                                //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
;EsclavoSensor.c,93 :: 		banId = 1;                                     //Activa la bandera de escritura de Id
	MOVLW      1
	MOVWF      _banId+0
;EsclavoSensor.c,94 :: 		SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,95 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt3:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt3
;EsclavoSensor.c,96 :: 		}
L_interrupt2:
;EsclavoSensor.c,97 :: 		if ((banId==1)&&(buffer!=0xA5)){                  //Envia los bytes de informacion de este esclavo: [IdEsclavo, regEsclavo, funcEsclavo]
	MOVF       _banId+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt6
	MOVF       _buffer+0, 0
	XORLW      165
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt6
L__interrupt33:
;EsclavoSensor.c,98 :: 		if (buffer==0xA1){
	MOVF       _buffer+0, 0
	XORLW      161
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
;EsclavoSensor.c,99 :: 		SSPBUF = idEsclavo;
	MOVLW      9
	MOVWF      SSPBUF+0
;EsclavoSensor.c,100 :: 		}
L_interrupt7:
;EsclavoSensor.c,101 :: 		if (buffer==0xA2){
	MOVF       _buffer+0, 0
	XORLW      162
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt8
;EsclavoSensor.c,102 :: 		SSPBUF = funcEsclavo;
	MOVLW      1
	MOVWF      SSPBUF+0
;EsclavoSensor.c,103 :: 		}
L_interrupt8:
;EsclavoSensor.c,104 :: 		if (buffer==0xA3){
	MOVF       _buffer+0, 0
	XORLW      163
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;EsclavoSensor.c,105 :: 		SSPBUF = regLectura;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,106 :: 		}
L_interrupt9:
;EsclavoSensor.c,107 :: 		if (buffer==0xA4){
	MOVF       _buffer+0, 0
	XORLW      164
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;EsclavoSensor.c,108 :: 		SSPBUF = regEscritura;
	MOVLW      3
	MOVWF      SSPBUF+0
;EsclavoSensor.c,109 :: 		}
L_interrupt10:
;EsclavoSensor.c,110 :: 		}
L_interrupt6:
;EsclavoSensor.c,111 :: 		if (buffer==0xA5){                                //Si detecta el delimitador de final de trama:
	MOVF       _buffer+0, 0
	XORLW      165
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;EsclavoSensor.c,112 :: 		banId = 0;                                     //Limpia la bandera de escritura de Id
	CLRF       _banId+0
;EsclavoSensor.c,113 :: 		SSPBUF = 0xB0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      176
	MOVWF      SSPBUF+0
;EsclavoSensor.c,114 :: 		}
L_interrupt11:
;EsclavoSensor.c,117 :: 		if (buffer==0xB0){                                //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      176
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;EsclavoSensor.c,118 :: 		banMed = 1;
	MOVLW      1
	MOVWF      _banMed+0
;EsclavoSensor.c,119 :: 		SSPBUF = 0xB0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      176
	MOVWF      SSPBUF+0
;EsclavoSensor.c,120 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt13:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt13
;EsclavoSensor.c,121 :: 		}
L_interrupt12:
;EsclavoSensor.c,122 :: 		if ((banMed==1)&&(buffer!=0xB0)){
	MOVF       _banMed+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt16
	MOVF       _buffer+0, 0
	XORLW      176
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt16
L__interrupt32:
;EsclavoSensor.c,123 :: 		registro = buffer;
	MOVF       _buffer+0, 0
	MOVWF      _registro+0
;EsclavoSensor.c,128 :: 		switch (registro){
	GOTO       L_interrupt17
;EsclavoSensor.c,129 :: 		case 0:
L_interrupt19:
;EsclavoSensor.c,130 :: 		numBytesSPI = 0x02;                //Si solicita leer el registro #1 establece que el numero de bytes que va a responder sera 3 (ejemplo), uno de direccion y dos de datos
	MOVLW      2
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,131 :: 		SSPBUF = numBytesSPI;              //Escribe la variable numBytesSPI en el buffer para enviarle al Maestro el numero de bytes que le va a responder
	MOVLW      2
	MOVWF      SSPBUF+0
;EsclavoSensor.c,132 :: 		break;
	GOTO       L_interrupt18
;EsclavoSensor.c,133 :: 		case 1:
L_interrupt20:
;EsclavoSensor.c,134 :: 		numBytesSPI = 0x02;
	MOVLW      2
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,135 :: 		SSPBUF = numBytesSPI;
	MOVLW      2
	MOVWF      SSPBUF+0
;EsclavoSensor.c,136 :: 		break;
	GOTO       L_interrupt18
;EsclavoSensor.c,137 :: 		case 2:
L_interrupt21:
;EsclavoSensor.c,138 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,139 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,140 :: 		break;
	GOTO       L_interrupt18
;EsclavoSensor.c,141 :: 		case 3:
L_interrupt22:
;EsclavoSensor.c,142 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,143 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,144 :: 		break;
	GOTO       L_interrupt18
;EsclavoSensor.c,145 :: 		default:
L_interrupt23:
;EsclavoSensor.c,146 :: 		SSPBUF = 0x01;                     //Si solicita leer un registro inexixtente devuelve una longitud de un solo byte para mandar el mensaje de error
	MOVLW      1
	MOVWF      SSPBUF+0
;EsclavoSensor.c,147 :: 		}
	GOTO       L_interrupt18
L_interrupt17:
	MOVF       _registro+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt19
	MOVF       _registro+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt20
	MOVF       _registro+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt21
	MOVF       _registro+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt22
	GOTO       L_interrupt23
L_interrupt18:
;EsclavoSensor.c,148 :: 		}
L_interrupt16:
;EsclavoSensor.c,149 :: 		if (buffer==0xB1){                                //Si detecta el delimitador de final de trama:
	MOVF       _buffer+0, 0
	XORLW      177
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt24
;EsclavoSensor.c,150 :: 		banPet = 1;                                    //Activa la bandera de peticion
	MOVLW      1
	MOVWF      _banPet+0
;EsclavoSensor.c,151 :: 		banMed = 0;                                    //Limpia la bandera de medicion
	CLRF       _banMed+0
;EsclavoSensor.c,152 :: 		banResp = 0;                                   //Limpia la bandera de peticion. **Esto parece no ser necesario pero quiero asegurarme de que no entre al siguiente if sin antes pasar por el bucle
	CLRF       _banResp+0
;EsclavoSensor.c,153 :: 		SSPBUF = 0xC0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      192
	MOVWF      SSPBUF+0
;EsclavoSensor.c,154 :: 		}
L_interrupt24:
;EsclavoSensor.c,157 :: 		if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
	MOVF       _banResp+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt25
;EsclavoSensor.c,158 :: 		if (i<numBytesSPI){
	MOVF       _numBytesSPI+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt26
;EsclavoSensor.c,159 :: 		SSPBUF = resSPI[i];
	MOVF       _i+0, 0
	ADDLW      _resSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoSensor.c,160 :: 		i++;
	INCF       _i+0, 1
;EsclavoSensor.c,161 :: 		}
L_interrupt26:
;EsclavoSensor.c,162 :: 		}
L_interrupt25:
;EsclavoSensor.c,165 :: 		}
L_interrupt1:
;EsclavoSensor.c,167 :: 		}
L_end_interrupt:
L__interrupt36:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoSensor.c,170 :: 		void main() {
;EsclavoSensor.c,172 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EsclavoSensor.c,173 :: 		ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,174 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,175 :: 		i = 0;
	CLRF       _i+0
;EsclavoSensor.c,176 :: 		x = 0;
	CLRF       _x+0
;EsclavoSensor.c,177 :: 		banPet = 0;
	CLRF       _banPet+0
;EsclavoSensor.c,178 :: 		banResp = 0;
	CLRF       _banResp+0
;EsclavoSensor.c,179 :: 		banSPI = 0;
	CLRF       _banSPI+0
;EsclavoSensor.c,180 :: 		banMed = 0;
	CLRF       _banMed+0
;EsclavoSensor.c,181 :: 		banId = 0;
	CLRF       _banId+0
;EsclavoSensor.c,184 :: 		SSPBUF = 0xA0;                                   //Carga un valor inicial en el buffer
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,187 :: 		while(1){
L_main27:
;EsclavoSensor.c,189 :: 		if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
	MOVF       _banPet+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main29
;EsclavoSensor.c,191 :: 		Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main30:
	DECFSZ     R13+0, 1
	GOTO       L_main30
	DECFSZ     R12+0, 1
	GOTO       L_main30
	DECFSZ     R11+0, 1
	GOTO       L_main30
	NOP
	NOP
;EsclavoSensor.c,192 :: 		resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
	MOVLW      131
	MOVWF      _resSPI+0
;EsclavoSensor.c,193 :: 		resSPI[1] = 0x58;
	MOVLW      88
	MOVWF      _resSPI+1
;EsclavoSensor.c,194 :: 		resSPI[2] = 0x8F;
	MOVLW      143
	MOVWF      _resSPI+2
;EsclavoSensor.c,195 :: 		resSPI[3] = 0x5C;
	MOVLW      92
	MOVWF      _resSPI+3
;EsclavoSensor.c,196 :: 		i=0;
	CLRF       _i+0
;EsclavoSensor.c,198 :: 		ECINT = 0;                               //Genera un pulso en bajo para producir una interrupcion externa en el Master
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,199 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_main31:
	DECFSZ     R13+0, 1
	GOTO       L_main31
	DECFSZ     R12+0, 1
	GOTO       L_main31
	NOP
	NOP
;EsclavoSensor.c,200 :: 		ECINT = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,201 :: 		banPet = 0;                              //Limpia la bandera de peticion SPI
	CLRF       _banPet+0
;EsclavoSensor.c,202 :: 		banResp = 1;                             //Activa la bandera de respuesta SPI
	MOVLW      1
	MOVWF      _banResp+0
;EsclavoSensor.c,204 :: 		}
L_main29:
;EsclavoSensor.c,206 :: 		}
	GOTO       L_main27
;EsclavoSensor.c,208 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
