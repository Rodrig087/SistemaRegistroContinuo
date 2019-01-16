
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
;EsclavoSensor.c,67 :: 		PIE1.SSPIE = 1;                                    //Habilita la interrupcion por SPI
	BSF        PIE1+0, 3
;EsclavoSensor.c,69 :: 		UART1_Init(19200);
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoSensor.c,71 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoSensor.c,73 :: 		}
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

;EsclavoSensor.c,82 :: 		void interrupt(){
;EsclavoSensor.c,85 :: 		if (PIR1.SSPIF){
	BTFSS      PIR1+0, 3
	GOTO       L_interrupt1
;EsclavoSensor.c,87 :: 		PIR1.SSPIF = 0;                                   //Limpia la bandera de interrupcion por SPI
	BCF        PIR1+0, 3
;EsclavoSensor.c,88 :: 		AUX = 1;
	BSF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,89 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,91 :: 		buffer =  SSPBUF;                                 //Guarda el contenido del bufeer (lectura)
	MOVF       SSPBUF+0, 0
	MOVWF      _buffer+0
;EsclavoSensor.c,94 :: 		if ((buffer==0xA0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de solicitud de informacion y si la bandera de escritura esta desactivada
	MOVF       _buffer+0, 0
	XORLW      160
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
	MOVF       _banEsc+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
L__interrupt58:
;EsclavoSensor.c,95 :: 		banId = 1;                                     //Activa la bandera de escritura de Id
	MOVLW      1
	MOVWF      _banId+0
;EsclavoSensor.c,96 :: 		SSPBUF = 0xA0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,97 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt5:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt5
;EsclavoSensor.c,98 :: 		}
L_interrupt4:
;EsclavoSensor.c,99 :: 		if ((banId==1)&&(buffer!=0xA5)){     //Envia los bytes de informacion de este esclavo: [IdEsclavo, regEsclavo, funcEsclavo]
	MOVF       _banId+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt8
	MOVF       _buffer+0, 0
	XORLW      165
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt8
L__interrupt57:
;EsclavoSensor.c,100 :: 		if (buffer==0xA1){
	MOVF       _buffer+0, 0
	XORLW      161
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;EsclavoSensor.c,101 :: 		SSPBUF = idEsclavo;
	MOVLW      9
	MOVWF      SSPBUF+0
;EsclavoSensor.c,102 :: 		}
L_interrupt9:
;EsclavoSensor.c,103 :: 		if (buffer==0xA2){
	MOVF       _buffer+0, 0
	XORLW      162
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;EsclavoSensor.c,104 :: 		SSPBUF = funcEsclavo;
	MOVLW      1
	MOVWF      SSPBUF+0
;EsclavoSensor.c,105 :: 		}
L_interrupt10:
;EsclavoSensor.c,106 :: 		if (buffer==0xA3){
	MOVF       _buffer+0, 0
	XORLW      163
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;EsclavoSensor.c,107 :: 		SSPBUF = regLectura;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,108 :: 		}
L_interrupt11:
;EsclavoSensor.c,109 :: 		if (buffer==0xA4){
	MOVF       _buffer+0, 0
	XORLW      164
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;EsclavoSensor.c,110 :: 		SSPBUF = regEscritura;
	MOVLW      3
	MOVWF      SSPBUF+0
;EsclavoSensor.c,111 :: 		}
L_interrupt12:
;EsclavoSensor.c,112 :: 		}
L_interrupt8:
;EsclavoSensor.c,113 :: 		if ((banId==1)&&(buffer==0xA5)){                  //Si detecta el delimitador de final de trama:
	MOVF       _banId+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
	MOVF       _buffer+0, 0
	XORLW      165
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
L__interrupt56:
;EsclavoSensor.c,114 :: 		banId = 0;                                     //Limpia la bandera de escritura de Id
	CLRF       _banId+0
;EsclavoSensor.c,115 :: 		SSPBUF = 0xB0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      176
	MOVWF      SSPBUF+0
;EsclavoSensor.c,116 :: 		}
L_interrupt15:
;EsclavoSensor.c,119 :: 		if ((buffer==0xB0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de datos
	MOVF       _buffer+0, 0
	XORLW      176
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt18
	MOVF       _banEsc+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt18
L__interrupt55:
;EsclavoSensor.c,120 :: 		banLec = 1;                                    //Activa la bandera de lectura
	MOVLW      1
	MOVWF      _banLec+0
;EsclavoSensor.c,121 :: 		SSPBUF = 0xB0;                                 //Guarda en el buffer un valor de cabecera (puede ser cuaquier valor, igual el Maaestro ignora este byte)
	MOVLW      176
	MOVWF      SSPBUF+0
;EsclavoSensor.c,122 :: 		Delay_us(50);
	MOVLW      33
	MOVWF      R13+0
L_interrupt19:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt19
;EsclavoSensor.c,123 :: 		}
L_interrupt18:
;EsclavoSensor.c,124 :: 		if ((banLec==1)&&(buffer!=0xB0)){
	MOVF       _banLec+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt22
	MOVF       _buffer+0, 0
	XORLW      176
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt22
L__interrupt54:
;EsclavoSensor.c,125 :: 		registro = buffer;
	MOVF       _buffer+0, 0
	MOVWF      _registro+0
;EsclavoSensor.c,130 :: 		switch (registro){
	GOTO       L_interrupt23
;EsclavoSensor.c,131 :: 		case 0:
L_interrupt25:
;EsclavoSensor.c,132 :: 		numBytesSPI = 0x02;                //Si solicita leer el registro #1 establece que el numero de bytes que va a responder sera 3 (ejemplo), uno de direccion y dos de datos
	MOVLW      2
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,133 :: 		SSPBUF = numBytesSPI;              //Escribe la variable numBytesSPI en el buffer para enviarle al Maestro el numero de bytes que le va a responder
	MOVLW      2
	MOVWF      SSPBUF+0
;EsclavoSensor.c,134 :: 		break;
	GOTO       L_interrupt24
;EsclavoSensor.c,135 :: 		case 1:
L_interrupt26:
;EsclavoSensor.c,136 :: 		numBytesSPI = 0x02;
	MOVLW      2
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,137 :: 		SSPBUF = numBytesSPI;
	MOVLW      2
	MOVWF      SSPBUF+0
;EsclavoSensor.c,138 :: 		break;
	GOTO       L_interrupt24
;EsclavoSensor.c,139 :: 		case 2:
L_interrupt27:
;EsclavoSensor.c,140 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,141 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,142 :: 		break;
	GOTO       L_interrupt24
;EsclavoSensor.c,143 :: 		case 3:
L_interrupt28:
;EsclavoSensor.c,144 :: 		numBytesSPI = 0x04;
	MOVLW      4
	MOVWF      _numBytesSPI+0
;EsclavoSensor.c,145 :: 		SSPBUF = numBytesSPI;
	MOVLW      4
	MOVWF      SSPBUF+0
;EsclavoSensor.c,146 :: 		break;
	GOTO       L_interrupt24
;EsclavoSensor.c,147 :: 		default:
L_interrupt29:
;EsclavoSensor.c,148 :: 		SSPBUF = 0x01;                     //Si solicita leer un registro inexixtente devuelve una longitud de un solo byte para mandar el mensaje de error
	MOVLW      1
	MOVWF      SSPBUF+0
;EsclavoSensor.c,149 :: 		}
	GOTO       L_interrupt24
L_interrupt23:
	MOVF       _registro+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt25
	MOVF       _registro+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt26
	MOVF       _registro+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt27
	MOVF       _registro+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt28
	GOTO       L_interrupt29
L_interrupt24:
;EsclavoSensor.c,150 :: 		}
L_interrupt22:
;EsclavoSensor.c,151 :: 		if ((banLec==1)&&(buffer==0xB1)){                 //Si detecta el delimitador de final de trama:
	MOVF       _banLec+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt32
	MOVF       _buffer+0, 0
	XORLW      177
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt32
L__interrupt53:
;EsclavoSensor.c,152 :: 		banPet = 1;                                    //Activa la bandera de peticion
	MOVLW      1
	MOVWF      _banPet+0
;EsclavoSensor.c,153 :: 		banLec = 0;                                    //Limpia la bandera de medicion
	CLRF       _banLec+0
;EsclavoSensor.c,154 :: 		banResp = 0;                                   //Limpia la bandera de peticion. **Esto parece no ser necesario pero quiero asegurarme de que no entre al siguiente if sin antes pasar por el bucle
	CLRF       _banResp+0
;EsclavoSensor.c,155 :: 		SSPBUF = 0xC0;                                 //Escribe el buffer el primer valor que se va a embiar cuando se embie la trama de respuesta
	MOVLW      192
	MOVWF      SSPBUF+0
;EsclavoSensor.c,156 :: 		}
L_interrupt32:
;EsclavoSensor.c,159 :: 		if (banResp==1){                                  //Verifica que la bandera de respuesta este activa
	MOVF       _banResp+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt33
;EsclavoSensor.c,160 :: 		if (i<numBytesSPI){
	MOVF       _numBytesSPI+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt34
;EsclavoSensor.c,161 :: 		SSPBUF = resSPI[i];
	MOVF       _i+0, 0
	ADDLW      _resSPI+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      SSPBUF+0
;EsclavoSensor.c,162 :: 		i++;
	INCF       _i+0, 1
;EsclavoSensor.c,163 :: 		}
L_interrupt34:
;EsclavoSensor.c,164 :: 		}
L_interrupt33:
;EsclavoSensor.c,167 :: 		if ((buffer==0xD0)&&(banEsc==0)){                 //Verifica si el primer byte es la cabecera de datos y si la bandera de escritura esta desactivada
	MOVF       _buffer+0, 0
	XORLW      208
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt37
	MOVF       _banEsc+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt37
L__interrupt52:
;EsclavoSensor.c,168 :: 		banEsc = 1;                                    //Activa la bandera de escritura de Id
	MOVLW      1
	MOVWF      _banEsc+0
;EsclavoSensor.c,169 :: 		j=0;
	CLRF       _j+0
;EsclavoSensor.c,170 :: 		}
L_interrupt37:
;EsclavoSensor.c,171 :: 		if ((banEsc==1)&&(buffer!=0xD0)){
	MOVF       _banEsc+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt40
	MOVF       _buffer+0, 0
	XORLW      208
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt40
L__interrupt51:
;EsclavoSensor.c,172 :: 		datosEscritura[j] = buffer;                    //Guarda en el vector el registro que se quiere escribir y los datos correspondientes
	MOVF       _j+0, 0
	ADDLW      _datosEscritura+0
	MOVWF      FSR
	MOVF       _buffer+0, 0
	MOVWF      INDF+0
;EsclavoSensor.c,173 :: 		if (j>1){
	MOVF       _j+0, 0
	SUBLW      1
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt41
;EsclavoSensor.c,174 :: 		regEsc = datosEscritura[1];                 //Guarda en la variable el valor del registro que se quiere escribir
	MOVF       _datosEscritura+1, 0
	MOVWF      _regEsc+0
;EsclavoSensor.c,175 :: 		numDatosEsc = datosEscritura[1];            //Si el subindice es mayor a 1 guarda en la variable numDatosEsc el valor del numero de datos que se desea escribir en el registro
	MOVF       _datosEscritura+1, 0
	MOVWF      _numDatosEsc+0
;EsclavoSensor.c,176 :: 		if ((j-1)==numDatosEsc){
	MOVLW      1
	SUBWF      _j+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	BTFSS      STATUS+0, 0
	DECF       R1+1, 1
	MOVLW      0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt62
	MOVF       _datosEscritura+1, 0
	XORWF      R1+0, 0
L__interrupt62:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt42
;EsclavoSensor.c,177 :: 		banEsc = 0;
	CLRF       _banEsc+0
;EsclavoSensor.c,178 :: 		numDatosEsc = 0;
	CLRF       _numDatosEsc+0
;EsclavoSensor.c,179 :: 		for (x=0;x<6;x++){
	CLRF       _x+0
L_interrupt43:
	MOVLW      6
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt44
;EsclavoSensor.c,180 :: 		UART1_Write(datosEscritura[x]);
	MOVF       _x+0, 0
	ADDLW      _datosEscritura+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoSensor.c,179 :: 		for (x=0;x<6;x++){
	INCF       _x+0, 1
;EsclavoSensor.c,181 :: 		}
	GOTO       L_interrupt43
L_interrupt44:
;EsclavoSensor.c,182 :: 		}
L_interrupt42:
;EsclavoSensor.c,183 :: 		}
L_interrupt41:
;EsclavoSensor.c,184 :: 		j++;
	INCF       _j+0, 1
;EsclavoSensor.c,185 :: 		}
L_interrupt40:
;EsclavoSensor.c,187 :: 		}
L_interrupt1:
;EsclavoSensor.c,189 :: 		}
L_end_interrupt:
L__interrupt61:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoSensor.c,192 :: 		void main() {
;EsclavoSensor.c,194 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EsclavoSensor.c,195 :: 		ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,196 :: 		AUX = 0;
	BCF        RB3_bit+0, BitPos(RB3_bit+0)
;EsclavoSensor.c,197 :: 		i = 0;
	CLRF       _i+0
;EsclavoSensor.c,198 :: 		x = 0;
	CLRF       _x+0
;EsclavoSensor.c,199 :: 		banPet = 0;
	CLRF       _banPet+0
;EsclavoSensor.c,200 :: 		banResp = 0;
	CLRF       _banResp+0
;EsclavoSensor.c,201 :: 		banSPI = 0;
	CLRF       _banSPI+0
;EsclavoSensor.c,202 :: 		banLec = 0;
	CLRF       _banLec+0
;EsclavoSensor.c,203 :: 		banId = 0;
	CLRF       _banId+0
;EsclavoSensor.c,204 :: 		banEsc = 0;
	CLRF       _banEsc+0
;EsclavoSensor.c,207 :: 		SSPBUF = 0xA0;                                   //Carga un valor inicial en el buffer
	MOVLW      160
	MOVWF      SSPBUF+0
;EsclavoSensor.c,208 :: 		numDatosEsc = 0;
	CLRF       _numDatosEsc+0
;EsclavoSensor.c,209 :: 		regEsc = 0;
	CLRF       _regEsc+0
;EsclavoSensor.c,211 :: 		while(1){
L_main46:
;EsclavoSensor.c,213 :: 		if (banPet==1){                             //Verifica si se ha recibido una solicitud de medicion
	MOVF       _banPet+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main48
;EsclavoSensor.c,215 :: 		Delay_ms(1000);                          //Simula un tiempo de procesamiento de la peticion
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_main49:
	DECFSZ     R13+0, 1
	GOTO       L_main49
	DECFSZ     R12+0, 1
	GOTO       L_main49
	DECFSZ     R11+0, 1
	GOTO       L_main49
	NOP
	NOP
;EsclavoSensor.c,216 :: 		resSPI[0] = 0x83;                        //Llena el vector de respuesta con un valor de ejemplo (float 27.07)
	MOVLW      131
	MOVWF      _resSPI+0
;EsclavoSensor.c,217 :: 		resSPI[1] = 0x58;
	MOVLW      88
	MOVWF      _resSPI+1
;EsclavoSensor.c,218 :: 		resSPI[2] = 0x8F;
	MOVLW      143
	MOVWF      _resSPI+2
;EsclavoSensor.c,219 :: 		resSPI[3] = 0x5C;
	MOVLW      92
	MOVWF      _resSPI+3
;EsclavoSensor.c,220 :: 		i=0;
	CLRF       _i+0
;EsclavoSensor.c,222 :: 		ECINT = 0;                               //Genera un pulso en bajo para producir una interrupcion externa en el Master
	BCF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,223 :: 		Delay_ms(1);
	MOVLW      3
	MOVWF      R12+0
	MOVLW      151
	MOVWF      R13+0
L_main50:
	DECFSZ     R13+0, 1
	GOTO       L_main50
	DECFSZ     R12+0, 1
	GOTO       L_main50
	NOP
	NOP
;EsclavoSensor.c,224 :: 		ECINT = 1;
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,225 :: 		banPet = 0;                              //Limpia la bandera de peticion SPI
	CLRF       _banPet+0
;EsclavoSensor.c,226 :: 		banResp = 1;                             //Activa la bandera de respuesta SPI
	MOVLW      1
	MOVWF      _banResp+0
;EsclavoSensor.c,228 :: 		}
L_main48:
;EsclavoSensor.c,230 :: 		}
	GOTO       L_main46
;EsclavoSensor.c,232 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
