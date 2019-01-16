
_ConfiguracionPrincipal:

;EsclavoSensor.c,72 :: 		void ConfiguracionPrincipal(){
;EsclavoSensor.c,74 :: 		ADCON1 = 0x07;
	MOVLW      7
	MOVWF      ADCON1+0
;EsclavoSensor.c,76 :: 		TRISA0_bit = 1;
	BSF        TRISA0_bit+0, BitPos(TRISA0_bit+0)
;EsclavoSensor.c,77 :: 		TRISA1_bit = 1;
	BSF        TRISA1_bit+0, BitPos(TRISA1_bit+0)
;EsclavoSensor.c,78 :: 		TRISB0_bit = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;EsclavoSensor.c,79 :: 		TRISB3_bit = 0;
	BCF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;EsclavoSensor.c,80 :: 		TRISC1_bit = 0;
	BCF        TRISC1_bit+0, BitPos(TRISC1_bit+0)
;EsclavoSensor.c,81 :: 		TRISC2_bit = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;EsclavoSensor.c,83 :: 		INTCON.GIE = 1;                                    //Habilita las interrupciones globales
	BSF        INTCON+0, 7
;EsclavoSensor.c,84 :: 		INTCON.PEIE = 1;                                   //Habilita las interrupciones perifericas
	BSF        INTCON+0, 6
;EsclavoSensor.c,87 :: 		UART1_Init(19200);
	MOVLW      25
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;EsclavoSensor.c,88 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;EsclavoSensor.c,91 :: 		INTCON.INTE = 1;                                   //Habilita la interrupcion externa
	BSF        INTCON+0, 4
;EsclavoSensor.c,92 :: 		INTCON.INTF = 0;                                   //Limpia la bandera de interrupcion externa
	BCF        INTCON+0, 1
;EsclavoSensor.c,93 :: 		OPTION_REG.INTEDG = 1;                             //Activa la interrupcion en el flanco de subida
	BSF        OPTION_REG+0, 6
;EsclavoSensor.c,95 :: 		Delay_ms(100);                                     //Espera hasta que se estabilicen los cambios
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
;EsclavoSensor.c,97 :: 		}
L_end_ConfiguracionPrincipal:
	RETURN
; end of _ConfiguracionPrincipal

_IdentificarEsclavo:

;EsclavoSensor.c,103 :: 		void IdentificarEsclavo(){
;EsclavoSensor.c,104 :: 		resRS485[0] = HDR;
	MOVLW      170
	MOVWF      _resRS485+0
;EsclavoSensor.c,105 :: 		resRS485[1] = idEsclavo;
	MOVF       _idEsclavo+0, 0
	MOVWF      _resRS485+1
;EsclavoSensor.c,106 :: 		resRS485[2] = funcEsclavo;
	MOVLW      1
	MOVWF      _resRS485+2
;EsclavoSensor.c,107 :: 		resRS485[3] = regLectura;
	MOVLW      4
	MOVWF      _resRS485+3
;EsclavoSensor.c,108 :: 		resRS485[4] = regEscritura;
	MOVLW      3
	MOVWF      _resRS485+4
;EsclavoSensor.c,109 :: 		resRS485[5] = END;
	MOVLW      255
	MOVWF      _resRS485+5
;EsclavoSensor.c,110 :: 		RE_DE = 1;                                         //Establece el Max485 en modo escritura
	BSF        RC1_bit+0, BitPos(RC1_bit+0)
;EsclavoSensor.c,111 :: 		for (x=0;x<6;x++){
	CLRF       _x+0
L_IdentificarEsclavo1:
	MOVLW      6
	SUBWF      _x+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_IdentificarEsclavo2
;EsclavoSensor.c,112 :: 		UART1_Write(resRS485[x]);
	MOVF       _x+0, 0
	ADDLW      _resRS485+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoSensor.c,113 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_IdentificarEsclavo4:
	CALL       _UART1_Tx_Idle+0
	MOVF       R0+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_IdentificarEsclavo5
	GOTO       L_IdentificarEsclavo4
L_IdentificarEsclavo5:
;EsclavoSensor.c,111 :: 		for (x=0;x<6;x++){
	INCF       _x+0, 1
;EsclavoSensor.c,114 :: 		}
	GOTO       L_IdentificarEsclavo1
L_IdentificarEsclavo2:
;EsclavoSensor.c,115 :: 		RE_DE = 0;                                         //Establece el Max485 en modo lectura
	BCF        RC1_bit+0, BitPos(RC1_bit+0)
;EsclavoSensor.c,116 :: 		}
L_end_IdentificarEsclavo:
	RETURN
; end of _IdentificarEsclavo

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;EsclavoSensor.c,121 :: 		void interrupt(){
;EsclavoSensor.c,124 :: 		if (PIR1.RCIF==1){
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt6
;EsclavoSensor.c,126 :: 		byteTrama = UART1_Read();                       //Lee el byte de la trama de peticion
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _byteTrama+0
;EsclavoSensor.c,128 :: 		if (banTI==0){
	MOVF       _banTI+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt7
;EsclavoSensor.c,129 :: 		if (bytetrama==0xB0){
	MOVF       _byteTrama+0, 0
	XORLW      176
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt8
;EsclavoSensor.c,130 :: 		banTI = 1;                                //Activa la bandera de inicio de trama
	MOVLW      1
	MOVWF      _banTI+0
;EsclavoSensor.c,131 :: 		i1 = 0;
	CLRF       _i1+0
;EsclavoSensor.c,132 :: 		}
L_interrupt8:
;EsclavoSensor.c,133 :: 		}
L_interrupt7:
;EsclavoSensor.c,135 :: 		if (banTI==1){
	MOVF       _banTI+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;EsclavoSensor.c,136 :: 		if (byteTrama!=0xB1){                        //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF       _byteTrama+0, 0
	XORLW      177
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
;EsclavoSensor.c,137 :: 		pduSolicitud[i1] = byteTrama;             //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _pduSolicitud+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoSensor.c,138 :: 		i1++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF       _i1+0, 1
;EsclavoSensor.c,139 :: 		banTF = 0;                                //Limpia la bandera de final de trama
	CLRF       _banTF+0
;EsclavoSensor.c,140 :: 		} else {
	GOTO       L_interrupt11
L_interrupt10:
;EsclavoSensor.c,141 :: 		pduSolicitud[i1] = byteTrama;               //Almacena el dato en la trama de respuesta
	MOVF       _i1+0, 0
	ADDLW      _pduSolicitud+0
	MOVWF      FSR
	MOVF       _byteTrama+0, 0
	MOVWF      INDF+0
;EsclavoSensor.c,142 :: 		banTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW      1
	MOVWF      _banTF+0
;EsclavoSensor.c,143 :: 		T2CON.TMR2ON = 1;                         //Enciende el Timer2
	BSF        T2CON+0, 2
;EsclavoSensor.c,144 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;EsclavoSensor.c,145 :: 		}
L_interrupt11:
;EsclavoSensor.c,146 :: 		if (banTF==1){                               //Verifica que se cumpla la condicion de final de trama
	MOVF       _banTF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;EsclavoSensor.c,147 :: 		banTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF       _banTI+0
;EsclavoSensor.c,148 :: 		banTC = 1;                                //Activa la bandera de trama completa
	MOVLW      1
	MOVWF      _banTC+0
;EsclavoSensor.c,149 :: 		PIR1.TMR2IF = 0;                          //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCF        PIR1+0, 1
;EsclavoSensor.c,150 :: 		T2CON.TMR2ON = 0;                         //Apaga el Timer2
	BCF        T2CON+0, 2
;EsclavoSensor.c,151 :: 		}
L_interrupt12:
;EsclavoSensor.c,152 :: 		}
L_interrupt9:
;EsclavoSensor.c,155 :: 		if (banTC==1){                                  //Verifica que se haya completado de llenar la trama de peticion
	MOVF       _banTC+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;EsclavoSensor.c,156 :: 		pduIdEsclavo = pduSolicitud[1];
	MOVF       _pduSolicitud+1, 0
	MOVWF      _pduIdEsclavo+0
;EsclavoSensor.c,157 :: 		if (pduIdEsclavo==idEsclavo){
	MOVF       _pduSolicitud+1, 0
	XORWF      _idEsclavo+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;EsclavoSensor.c,158 :: 		pduFuncion = pduSolicitud[2];
	MOVF       _pduSolicitud+2, 0
	MOVWF      _pduFuncion+0
;EsclavoSensor.c,159 :: 		pduRegistro = pduSolicitud[3];
	MOVF       _pduSolicitud+3, 0
	MOVWF      _pduRegistro+0
;EsclavoSensor.c,160 :: 		pduNumDatos = pduSolicitud[4];
	MOVF       _pduSolicitud+4, 0
	MOVWF      _pduNumDatos+0
;EsclavoSensor.c,162 :: 		UART1_Write(0xAA);
	MOVLW      170
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;EsclavoSensor.c,165 :: 		}
L_interrupt14:
;EsclavoSensor.c,167 :: 		banTI = 0;                                   //Limpia la bandera de inicio de trama
	CLRF       _banTI+0
;EsclavoSensor.c,168 :: 		banTC = 0;                                   //Limpia la bandera de trama completa
	CLRF       _banTC+0
;EsclavoSensor.c,169 :: 		i1 = 0;                                      //Limpia el subindice de trama
	CLRF       _i1+0
;EsclavoSensor.c,170 :: 		}
L_interrupt13:
;EsclavoSensor.c,172 :: 		PIR1.RCIF=0;
	BCF        PIR1+0, 5
;EsclavoSensor.c,174 :: 		}
L_interrupt6:
;EsclavoSensor.c,176 :: 		}
L_end_interrupt:
L__interrupt18:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;EsclavoSensor.c,179 :: 		void main() {
;EsclavoSensor.c,181 :: 		ConfiguracionPrincipal();
	CALL       _ConfiguracionPrincipal+0
;EsclavoSensor.c,183 :: 		idEsclavo = 0x09;
	MOVLW      9
	MOVWF      _idEsclavo+0
;EsclavoSensor.c,185 :: 		ECINT = 1;                                       //Se inicializa el pin ECINT en alto para evitar que envie un pulso al iniciar (probablemente ocacionado por el CCP)
	BSF        RC2_bit+0, BitPos(RC2_bit+0)
;EsclavoSensor.c,187 :: 		i1 = 0;
	CLRF       _i1+0
;EsclavoSensor.c,188 :: 		x = 0;
	CLRF       _x+0
;EsclavoSensor.c,194 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
