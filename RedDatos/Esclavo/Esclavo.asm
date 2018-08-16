
_interrupt:

;Esclavo.c,49 :: 		void interrupt(void){
;Esclavo.c,51 :: 		if(PIR1.RC1IF==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Esclavo.c,53 :: 		Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Esclavo.c,58 :: 		if (Dato==Hdr){
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Esclavo.c,59 :: 		BanTI = 1;
	MOVLW       1
	MOVWF       _BanTI+0 
;Esclavo.c,60 :: 		it = 0;
	CLRF        _it+0 
;Esclavo.c,62 :: 		T1CON.TMR1ON = 1;                            //Enciende el Timer1
	BSF         T1CON+0, 0 
;Esclavo.c,63 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Esclavo.c,64 :: 		TMR1H = 0x3C;                                //Se vuelve a cargar el valor del preload correspondiente a los 50ms, porque
	MOVLW       60
	MOVWF       TMR1H+0 
;Esclavo.c,65 :: 		TMR1L = 0xB0;                                //al parecer este valor se pierde cada vez que entra a la interrupcion
	MOVLW       176
	MOVWF       TMR1L+0 
;Esclavo.c,66 :: 		}
L_interrupt1:
;Esclavo.c,68 :: 		if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _BanTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;Esclavo.c,70 :: 		if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
	MOVF        _BanTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _Dato+0, 0 
	XORLW       10
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt35:
;Esclavo.c,71 :: 		PSize = it+1;                             //Establece la longitud total de la trama de peticion
	MOVF        _it+0, 0 
	ADDLW       1
	MOVWF       _Psize+0 
;Esclavo.c,72 :: 		BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _BanTI+0 
;Esclavo.c,73 :: 		BanTC = 1;                                //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _BanTC+0 
;Esclavo.c,75 :: 		T1CON.TMR1ON = 0;                         //Apaga el Timer1
	BCF         T1CON+0, 0 
;Esclavo.c,76 :: 		TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Esclavo.c,77 :: 		}
L_interrupt5:
;Esclavo.c,79 :: 		if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _Dato+0, 0 
	XORLW       13
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
;Esclavo.c,80 :: 		Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,81 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Esclavo.c,82 :: 		BanTF = 0;                                //Limpia la bandera de final de trama
	CLRF        _BanTF+0 
;Esclavo.c,83 :: 		} else {
	GOTO        L_interrupt7
L_interrupt6:
;Esclavo.c,84 :: 		Ptcn[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,85 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Esclavo.c,86 :: 		BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _BanTF+0 
;Esclavo.c,87 :: 		}
L_interrupt7:
;Esclavo.c,89 :: 		}
L_interrupt2:
;Esclavo.c,91 :: 		PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Esclavo.c,92 :: 		}
L_interrupt0:
;Esclavo.c,98 :: 		if (TMR1IF_bit==1){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt8
;Esclavo.c,100 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Esclavo.c,101 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF         T1CON+0, 0 
;Esclavo.c,102 :: 		BanTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF        _BanTI+0 
;Esclavo.c,103 :: 		it = 0;                                         //Limpia el subindice de trama
	CLRF        _it+0 
;Esclavo.c,104 :: 		BanTC = 0;                                      //Limpia la bandera de trama completa(Por si acaso)
	CLRF        _BanTC+0 
;Esclavo.c,106 :: 		}
L_interrupt8:
;Esclavo.c,108 :: 		}
L_end_interrupt:
L__interrupt37:
	RETFIE      1
; end of _interrupt

_ModbusRTU_CRC16:

;Esclavo.c,113 :: 		unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen){
;Esclavo.c,117 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_ModbusRTU_CRC169:
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__ModbusRTU_CRC1639
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+0, 0 
L__ModbusRTU_CRC1639:
	BTFSC       STATUS+0, 2 
	GOTO        L_ModbusRTU_CRC1610
;Esclavo.c,119 :: 		uiCRCResult ^=*ptucBuffer ++;
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+0, FSR2
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_ModbusRTU_CRC16_ptucBuffer+0, 1 
	INCF        FARG_ModbusRTU_CRC16_ptucBuffer+1, 1 
;Esclavo.c,120 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	CLRF        R2 
L_ModbusRTU_CRC1612:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ModbusRTU_CRC1613
;Esclavo.c,122 :: 		if(uiCRCResult & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_ModbusRTU_CRC1615
;Esclavo.c,123 :: 		uiCRCResult =( uiCRCResult >>1)^PolModbus;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_ModbusRTU_CRC1616
L_ModbusRTU_CRC1615:
;Esclavo.c,125 :: 		uiCRCResult >>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_ModbusRTU_CRC1616:
;Esclavo.c,120 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	INCF        R2, 1 
;Esclavo.c,126 :: 		}
	GOTO        L_ModbusRTU_CRC1612
L_ModbusRTU_CRC1613:
;Esclavo.c,117 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       1
	SUBWF       FARG_ModbusRTU_CRC16_uiLen+0, 1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
;Esclavo.c,127 :: 		}
	GOTO        L_ModbusRTU_CRC169
L_ModbusRTU_CRC1610:
;Esclavo.c,128 :: 		return uiCRCResult;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Esclavo.c,130 :: 		}
L_end_ModbusRTU_CRC16:
	RETURN      0
; end of _ModbusRTU_CRC16

_enviarTrama:

;Esclavo.c,139 :: 		void enviarTrama(unsigned short dataSize){
;Esclavo.c,141 :: 		unsigned short rSize = dataSize + 7;                //Longitud de la trama de respuesta
	MOVLW       7
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       enviarTrama_rSize_L0+0 
;Esclavo.c,144 :: 		PDU[0] = Add;                                       //Rellena el campo de direccion con la direccion del dispositivo esclavo
	MOVF        _Add+0, 0 
	MOVWF       _PDU+0 
;Esclavo.c,145 :: 		PDU[1] = Ptcn[2];                                   //Rellena el campo de funcion con la funcion requerida en la trama de peticion
	MOVF        _Ptcn+2, 0 
	MOVWF       _PDU+1 
;Esclavo.c,147 :: 		PDU[2] = 0xEE;                                     //Rellena el campo de datos con los valores 0xAAFF
	MOVLW       238
	MOVWF       _PDU+2 
;Esclavo.c,148 :: 		PDU[3] = 0xEE;
	MOVLW       238
	MOVWF       _PDU+3 
;Esclavo.c,151 :: 		Rspt[0] = Hdr;                                     //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOVLW       58
	MOVWF       _Rspt+0 
;Esclavo.c,152 :: 		for (i=0;i<=(dataSize+1);i++){                     //Rellena la trama de Respuesta con el PDU
	CLRF        _i+0 
L_enviarTrama17:
	MOVF        FARG_enviarTrama_dataSize+0, 0 
	ADDLW       1
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	ADDWFC      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__enviarTrama41
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__enviarTrama41:
	BTFSS       STATUS+0, 0 
	GOTO        L_enviarTrama18
;Esclavo.c,153 :: 		Rspt[i+1] = PDU[i];
	MOVF        _i+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       _PDU+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,152 :: 		for (i=0;i<=(dataSize+1);i++){                     //Rellena la trama de Respuesta con el PDU
	INCF        _i+0, 1 
;Esclavo.c,154 :: 		}
	GOTO        L_enviarTrama17
L_enviarTrama18:
;Esclavo.c,155 :: 		CRC16 = ModbusRTU_CRC16(PDU, dataSize+2);          //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       2
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	ADDWFC      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Esclavo.c,156 :: 		Rspt[dataSize+3] = *(ptrCRC16+1);                  //Rellena el campo CRC_MSB de la trama de respuesta
	MOVLW       3
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       1
	ADDWF       _ptrCRC16+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _ptrCRC16+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,157 :: 		Rspt[dataSize+4] = *ptrCRC16;                      //Rellena el campo CRC_LSB de la trama de respuesta
	MOVLW       4
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVFF       _ptrCRC16+0, FSR0
	MOVFF       _ptrCRC16+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,158 :: 		Rspt[dataSize+5] = End1;                           //Se rellena el penultimo byte de la trama de repuesta con el primer byte del delimitador de final de trama
	MOVLW       5
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       13
	MOVWF       POSTINC1+0 
;Esclavo.c,159 :: 		Rspt[dataSize+6] = End2;                           //Se rellena el ultimo byte de la trama de repuesta con el segundo byte del delimitador de final de trama
	MOVLW       6
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       10
	MOVWF       POSTINC1+0 
;Esclavo.c,162 :: 		RC5_bit = 1;                                       //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,163 :: 		for (i=0;i<rSize;i++){
	CLRF        _i+0 
L_enviarTrama20:
	MOVF        enviarTrama_rSize_L0+0, 0 
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_enviarTrama21
;Esclavo.c,164 :: 		UART1_Write(Rspt[i]);                          //Envia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Esclavo.c,163 :: 		for (i=0;i<rSize;i++){
	INCF        _i+0, 1 
;Esclavo.c,165 :: 		}
	GOTO        L_enviarTrama20
L_enviarTrama21:
;Esclavo.c,166 :: 		while(UART1_Tx_Idle()==0);
L_enviarTrama23:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_enviarTrama24
	GOTO        L_enviarTrama23
L_enviarTrama24:
;Esclavo.c,167 :: 		RC5_bit = 0;                                       //Establece el Max485 en modo de lectura
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,169 :: 		}
L_end_enviarTrama:
	RETURN      0
; end of _enviarTrama

_Configuracion:

;Esclavo.c,173 :: 		void Configuracion(){
;Esclavo.c,175 :: 		ANSELA = 0;                                       //Configura PORTA como digital
	CLRF        ANSELA+0 
;Esclavo.c,176 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Esclavo.c,177 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Esclavo.c,179 :: 		TRISA = 1;                                        //Configura el puerto A como entrada
	MOVLW       1
	MOVWF       TRISA+0 
;Esclavo.c,180 :: 		TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
	BSF         TRISC0_bit+0, BitPos(TRISC0_bit+0) 
;Esclavo.c,181 :: 		TRISC1_bit = 1;                                   //Configura el pin C1 como entrada
	BSF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;Esclavo.c,182 :: 		TRISC4_bit = 0;                                   //Configura el pin C4 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Esclavo.c,183 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Esclavo.c,185 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Esclavo.c,186 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Esclavo.c,189 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Esclavo.c,190 :: 		PIR1.RC1IF = 0;                                   //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Esclavo.c,191 :: 		UART1_Init(19200);                                //Inicializa el UART1 a 19200 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Esclavo.c,194 :: 		T1CON = 0x11;                                     //Establece el prescalador en 1:2, enciende el TMR1
	MOVLW       17
	MOVWF       T1CON+0 
;Esclavo.c,195 :: 		TMR1IE_bit = 1;                                   //Habilita la interrupcion por desbordamiento del TMR1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;Esclavo.c,196 :: 		TMR1IF_bit = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Esclavo.c,197 :: 		TMR1H = 0x3C;                                     //Preload = 15536, Time = 50ms
	MOVLW       60
	MOVWF       TMR1H+0 
;Esclavo.c,198 :: 		TMR1L = 0xB0;
	MOVLW       176
	MOVWF       TMR1L+0 
;Esclavo.c,201 :: 		RCON.IPEN = 1;                                    //Habilita el nivel de prioridad en las interrupciones
	BSF         RCON+0, 7 
;Esclavo.c,202 :: 		IPR1.RC1IP = 0;                                   //Nivel de prioridad de USART1 = Baja prioridad
	BCF         IPR1+0, 5 
;Esclavo.c,203 :: 		IPR1.TMR1IP = 1;                                  //Nivel de prioridad de TMR1 = Alta prioridad
	BSF         IPR1+0, 0 
;Esclavo.c,205 :: 		Delay_ms(10);                                     //Espera para que el modulo UART se estabilice
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_Configuracion25:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion25
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion25
	NOP
;Esclavo.c,207 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Esclavo.c,210 :: 		void main() {
;Esclavo.c,212 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Esclavo.c,214 :: 		BanTI = 0;                                               //Inicializa las banderas de trama
	CLRF        _BanTI+0 
;Esclavo.c,215 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Esclavo.c,216 :: 		BanTF = 0;
	CLRF        _BanTF+0 
;Esclavo.c,218 :: 		RC5_bit = 0;                                             //Inicializa el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,219 :: 		RC4_bit = 0;
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Esclavo.c,221 :: 		CRC16 = 0;                                               //Inicializa los valores del CRC obtenido y calculado con valores diferentes
	CLRF        _CRC16+0 
	CLRF        _CRC16+1 
;Esclavo.c,222 :: 		CRCPDU = 1;
	MOVLW       1
	MOVWF       _CRCPDU+0 
	MOVLW       0
	MOVWF       _CRCPDU+1 
;Esclavo.c,224 :: 		ptrCRC16 = &CRC16;                                       //Asociacion del puntero CRC16
	MOVLW       _CRC16+0
	MOVWF       _ptrCRC16+0 
	MOVLW       hi_addr(_CRC16+0)
	MOVWF       _ptrCRC16+1 
;Esclavo.c,225 :: 		ptrCRCPDU = &CRCPDU;                                     //Asociacion del puntero CRCPDU
	MOVLW       _CRCPDU+0
	MOVWF       _ptrCRCPDU+0 
	MOVLW       hi_addr(_CRCPDU+0)
	MOVWF       _ptrCRCPDU+1 
;Esclavo.c,227 :: 		Add = (PORTA&0x3F)+((PORTC&0x03)<<6);                    //Carga el valor del dipswitch como direccion del esclavo a quien se realiza la peticion
	MOVLW       63
	ANDWF       PORTA+0, 0 
	MOVWF       _Add+0 
	MOVLW       3
	ANDWF       PORTC+0, 0 
	MOVWF       R2 
	MOVLW       6
	MOVWF       R1 
	MOVF        R2, 0 
	MOVWF       R0 
	MOVF        R1, 0 
L__main44:
	BZ          L__main45
	RLCF        R0, 1 
	BCF         R0, 0 
	ADDLW       255
	GOTO        L__main44
L__main45:
	MOVF        R0, 0 
	ADDWF       _Add+0, 1 
;Esclavo.c,229 :: 		while (1){
L_main26:
;Esclavo.c,231 :: 		if (BanTC==1){                                     //Verifica si se realizo una peticion comprobando el estado de la bandera de trama completa
	MOVF        _BanTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main28
;Esclavo.c,233 :: 		if (Ptcn[1]==Add){                              //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado
	MOVF        _Ptcn+1, 0 
	XORWF       _Add+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_main29
;Esclavo.c,235 :: 		for (i=0;i<=(Psize-5);i++){                 //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        _i+0 
L_main30:
	MOVLW       5
	SUBWF       _Psize+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	SUBWFB      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main46
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main46:
	BTFSS       STATUS+0, 0 
	GOTO        L_main31
;Esclavo.c,236 :: 		PDU[i] = Ptcn[i+1];
	MOVLW       _PDU+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FSR1H 
	MOVF        _i+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _i+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,235 :: 		for (i=0;i<=(Psize-5);i++){                 //Rellena la trama de PDU con los datos de interes de la trama de peticion, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        _i+0, 1 
;Esclavo.c,237 :: 		}
	GOTO        L_main30
L_main31:
;Esclavo.c,239 :: 		CRC16 = ModbusRTU_CRC16(PDU, Psize-5);      //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       5
	SUBWF       _Psize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Esclavo.c,240 :: 		*ptrCRCPDU = Ptcn[Psize-3];                 //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW       3
	SUBWF       _Psize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVFF       _ptrCRCPDU+0, FSR1
	MOVFF       _ptrCRCPDU+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,241 :: 		*(ptrCRCPDU+1) = Ptcn[Psize-4];             //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW       1
	ADDWF       _ptrCRCPDU+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrCRCPDU+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	SUBWF       _Psize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,243 :: 		if (CRC16==CRCPDU) {                        //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        _CRC16+1, 0 
	XORWF       _CRCPDU+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVF        _CRCPDU+0, 0 
	XORWF       _CRC16+0, 0 
L__main47:
	BTFSS       STATUS+0, 2 
	GOTO        L_main33
;Esclavo.c,247 :: 		enviarTrama(2);                          //Se envia una trama de respuesta con 2 bytes de payload
	MOVLW       2
	MOVWF       FARG_enviarTrama_dataSize+0 
	CALL        _enviarTrama+0, 0
;Esclavo.c,249 :: 		}
L_main33:
;Esclavo.c,250 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Esclavo.c,251 :: 		}
L_main29:
;Esclavo.c,253 :: 		BanTC = 0;                                      //Limpia la bandera de trama completa
	CLRF        _BanTC+0 
;Esclavo.c,255 :: 		}
L_main28:
;Esclavo.c,257 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main34:
	DECFSZ      R13, 1, 1
	BRA         L_main34
	DECFSZ      R12, 1, 1
	BRA         L_main34
	NOP
;Esclavo.c,260 :: 		}
	GOTO        L_main26
;Esclavo.c,262 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
