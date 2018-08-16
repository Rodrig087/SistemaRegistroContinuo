
_interrupt:

;Master.c,41 :: 		void interrupt(void){
;Master.c,43 :: 		if(PIR1.RC1IF==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Master.c,45 :: 		Dato = UART1_Read();                            //Recibe el byte por el Uart1 y lo almacena en la variable Dato
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Master.c,50 :: 		if (Dato==Hdr){
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Master.c,51 :: 		BanTI = 1;                                   //Activa la bandera de inicio de trama
	MOVLW       1
	MOVWF       _BanTI+0 
;Master.c,52 :: 		it = 0;                                      //Limpia el subindice de trama
	CLRF        _it+0 
;Master.c,53 :: 		T1CON.TMR1ON = 1;                            //Enciende el Timer1
	BSF         T1CON+0, 0 
;Master.c,54 :: 		TMR1IF_bit = 0;                              //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Master.c,55 :: 		TMR1H = 0x3C;                                //Se vuelve a cargar el valor del preload correspondiente a los 50ms, porque
	MOVLW       60
	MOVWF       TMR1H+0 
;Master.c,56 :: 		TMR1L = 0xB0;                                //al parecer este valor se pierde cada vez que entra a la interrupcion
	MOVLW       176
	MOVWF       TMR1L+0 
;Master.c,57 :: 		}
L_interrupt1:
;Master.c,59 :: 		if (BanTI==1){                                  //Verifica que la bandera de inicio de trama este activa
	MOVF        _BanTI+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;Master.c,61 :: 		if ((BanTF==1)&&(Dato==End2)){               //Verifica que se cumpla la condicion de final de trama
	MOVF        _BanTF+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
	MOVF        _Dato+0, 0 
	XORLW       10
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt5
L__interrupt41:
;Master.c,62 :: 		rSize = it+1;                             //Establece la longitud total de la trama de respuesta
	MOVF        _it+0, 0 
	ADDLW       1
	MOVWF       _rsize+0 
;Master.c,63 :: 		BanTI = 0;                                //Limpia la bandera de inicio de trama para no permitir que se almacene mas datos en la trama de respuesta
	CLRF        _BanTI+0 
;Master.c,64 :: 		BanTC = 1;                                //Activa la bandera de trama completa
	MOVLW       1
	MOVWF       _BanTC+0 
;Master.c,65 :: 		T1CON.TMR1ON = 0;                         //Apaga el Timer1
	BCF         T1CON+0, 0 
;Master.c,66 :: 		TMR1IF_bit = 0;                           //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Master.c,67 :: 		}
L_interrupt5:
;Master.c,69 :: 		if (Dato!=End1){                             //Verifica que el dato recibido sea diferente del primer byte del delimitador de final de trama
	MOVF        _Dato+0, 0 
	XORLW       13
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
;Master.c,70 :: 		Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,71 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Master.c,72 :: 		BanTF = 0;                                //Limpia la bandera de final de trama
	CLRF        _BanTF+0 
;Master.c,73 :: 		} else {
	GOTO        L_interrupt7
L_interrupt6:
;Master.c,74 :: 		Rspt[it] = Dato;                          //Almacena el dato en la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _it+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,75 :: 		it++;                                     //Aumenta el subindice en una unidad para permitir almacenar el siguiente dato del mensaje
	INCF        _it+0, 1 
;Master.c,76 :: 		BanTF = 1;                                //Si el dato recibido es el primer byte de final de trama activa la bandera
	MOVLW       1
	MOVWF       _BanTF+0 
;Master.c,77 :: 		}
L_interrupt7:
;Master.c,79 :: 		}
L_interrupt2:
;Master.c,81 :: 		PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,82 :: 		}
L_interrupt0:
;Master.c,88 :: 		if (TMR1IF_bit==1){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_interrupt8
;Master.c,89 :: 		TMR1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Master.c,90 :: 		T1CON.TMR1ON = 0;                               //Apaga el Timer1
	BCF         T1CON+0, 0 
;Master.c,92 :: 		RC4_bit = ~RC4_bit;                             //Conmuta el valor de la salida RC4 para indicar que entro a la interrupcion
	BTG         RC4_bit+0, BitPos(RC4_bit+0) 
;Master.c,94 :: 		BanTI = 0;                                      //Limpia la bandera de inicio de trama
	CLRF        _BanTI+0 
;Master.c,95 :: 		it = 0;                                         //Limpia el subindice de trama
	CLRF        _it+0 
;Master.c,97 :: 		}
L_interrupt8:
;Master.c,98 :: 		}
L_end_interrupt:
L__interrupt44:
	RETFIE      1
; end of _interrupt

_ModbusRTU_CRC16:

;Master.c,103 :: 		unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen){
;Master.c,108 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_ModbusRTU_CRC169:
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__ModbusRTU_CRC1646
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+0, 0 
L__ModbusRTU_CRC1646:
	BTFSC       STATUS+0, 2 
	GOTO        L_ModbusRTU_CRC1610
;Master.c,110 :: 		uiCRCResult ^= *ptucBuffer ++;
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+0, FSR2
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_ModbusRTU_CRC16_ptucBuffer+0, 1 
	INCF        FARG_ModbusRTU_CRC16_ptucBuffer+1, 1 
;Master.c,111 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	CLRF        R2 
L_ModbusRTU_CRC1612:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ModbusRTU_CRC1613
;Master.c,113 :: 		if(uiCRCResult & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_ModbusRTU_CRC1615
;Master.c,114 :: 		uiCRCResult =(uiCRCResult>>1)^PolModbus;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_ModbusRTU_CRC1616
L_ModbusRTU_CRC1615:
;Master.c,116 :: 		uiCRCResult >>= 1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_ModbusRTU_CRC1616:
;Master.c,111 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	INCF        R2, 1 
;Master.c,117 :: 		}
	GOTO        L_ModbusRTU_CRC1612
L_ModbusRTU_CRC1613:
;Master.c,108 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       1
	SUBWF       FARG_ModbusRTU_CRC16_uiLen+0, 1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
;Master.c,118 :: 		}
	GOTO        L_ModbusRTU_CRC169
L_ModbusRTU_CRC1610:
;Master.c,119 :: 		return uiCRCResult;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Master.c,121 :: 		}
L_end_ModbusRTU_CRC16:
	RETURN      0
; end of _ModbusRTU_CRC16

_enviarTrama:

;Master.c,130 :: 		void enviarTrama(unsigned short dataSize, unsigned short fcn){
;Master.c,132 :: 		unsigned short pSize = dataSize + 7;                //Longitud de la trama de respuesta
	MOVLW       7
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       enviarTrama_pSize_L0+0 
;Master.c,135 :: 		PDU[0] = Add;                                       //Rellena el campo de direccion con la direccion del dispositivo esclavo
	MOVF        _Add+0, 0 
	MOVWF       _PDU+0 
;Master.c,136 :: 		PDU[1] = fcn;                                       //Rellena el campo de funcion con la funcion que se requerira al esclavo
	MOVF        FARG_enviarTrama_fcn+0, 0 
	MOVWF       _PDU+1 
;Master.c,138 :: 		PDU[2] = 0xAA;                                     //Rellena el campo de datos con los valores 0xAAFF
	MOVLW       170
	MOVWF       _PDU+2 
;Master.c,139 :: 		PDU[3] = 0xAA;
	MOVLW       170
	MOVWF       _PDU+3 
;Master.c,142 :: 		Ptcn[0] = Hdr;                                     //Se rellena el primer byte de la trama de peticion con el delimitador de inicio de trama
	MOVLW       58
	MOVWF       _Ptcn+0 
;Master.c,143 :: 		for (i=0;i<=(dataSize+1);i++){                     //Rellena la trama de Respuesta con el PDU
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
	GOTO        L__enviarTrama48
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__enviarTrama48:
	BTFSS       STATUS+0, 0 
	GOTO        L_enviarTrama18
;Master.c,144 :: 		Ptcn[i+1] = PDU[i];
	MOVF        _i+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
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
;Master.c,143 :: 		for (i=0;i<=(dataSize+1);i++){                     //Rellena la trama de Respuesta con el PDU
	INCF        _i+0, 1 
;Master.c,145 :: 		}
	GOTO        L_enviarTrama17
L_enviarTrama18:
;Master.c,146 :: 		CRC16 = ModbusRTU_CRC16(PDU, dataSize+2);          //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
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
;Master.c,147 :: 		Ptcn[dataSize+3] = *(ptrCRC16+1);                  //Rellena el campo CRC_MSB de la trama de respuesta
	MOVLW       3
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
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
;Master.c,148 :: 		Ptcn[dataSize+4] = *ptrCRC16;                      //Rellena el campo CRC_LSB de la trama de respuesta
	MOVLW       4
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVFF       _ptrCRC16+0, FSR0
	MOVFF       _ptrCRC16+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,149 :: 		Ptcn[dataSize+5] = End1;                           //Se rellena el penultimo byte de la trama de repuesta con el primer byte del delimitador de final de trama
	MOVLW       5
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       13
	MOVWF       POSTINC1+0 
;Master.c,150 :: 		Ptcn[dataSize+6] = End2;                           //Se rellena el ultimo byte de la trama de repuesta con el segundo byte del delimitador de final de trama
	MOVLW       6
	ADDWF       FARG_enviarTrama_dataSize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _Ptcn+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVLW       10
	MOVWF       POSTINC1+0 
;Master.c,153 :: 		RC5_bit = 1;                                       //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,154 :: 		for (i=0;i<pSize;i++){
	CLRF        _i+0 
L_enviarTrama20:
	MOVF        enviarTrama_pSize_L0+0, 0 
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_enviarTrama21
;Master.c,155 :: 		UART1_Write(Ptcn[i]);                          //Envia la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _i+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Master.c,154 :: 		for (i=0;i<pSize;i++){
	INCF        _i+0, 1 
;Master.c,156 :: 		}
	GOTO        L_enviarTrama20
L_enviarTrama21:
;Master.c,157 :: 		while(UART1_Tx_Idle()==0);
L_enviarTrama23:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_enviarTrama24
	GOTO        L_enviarTrama23
L_enviarTrama24:
;Master.c,158 :: 		RC5_bit = 0;                                       //Establece el Max485 en modo de lectura
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,160 :: 		}
L_end_enviarTrama:
	RETURN      0
; end of _enviarTrama

_Configuracion:

;Master.c,164 :: 		void Configuracion(){
;Master.c,166 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Master.c,167 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Master.c,168 :: 		ANSELC = 0;                                       //Configura el PORTC como digital
	CLRF        ANSELC+0 
;Master.c,170 :: 		TRISA = 1;                                        //Configura el puerto A como entrada
	MOVLW       1
	MOVWF       TRISA+0 
;Master.c,171 :: 		TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
	BSF         TRISC0_bit+0, BitPos(TRISC0_bit+0) 
;Master.c,172 :: 		TRISC1_bit = 1;                                   //Configura el pin C1 como entrada
	BSF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;Master.c,173 :: 		TRISC2_bit = 1;                                   //Configura el pin C2 como entrada
	BSF         TRISC2_bit+0, BitPos(TRISC2_bit+0) 
;Master.c,174 :: 		TRISC3_bit = 0;                                   //Configura el pin C3 como salida
	BCF         TRISC3_bit+0, BitPos(TRISC3_bit+0) 
;Master.c,175 :: 		TRISC4_bit = 0;                                   //Configura el pin C4 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Master.c,176 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Master.c,178 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Master.c,179 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Master.c,182 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Master.c,183 :: 		PIR1.RC1IF = 0;                                   //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,184 :: 		UART1_Init(19200);                                //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       103
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Master.c,187 :: 		T1CON = 0x21;                                     //Establece el prescalador en 1:2, enciende el TMR1
	MOVLW       33
	MOVWF       T1CON+0 
;Master.c,188 :: 		TMR1IE_bit = 1;                                   //Habilita la interrupcion por desbordamiento del TMR1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;Master.c,189 :: 		TMR1IF_bit = 0;                                   //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;Master.c,190 :: 		TMR1H = 0x3C;                                     //Preload = 15536, Time = 100ms
	MOVLW       60
	MOVWF       TMR1H+0 
;Master.c,191 :: 		TMR1L = 0xB0;
	MOVLW       176
	MOVWF       TMR1L+0 
;Master.c,194 :: 		RCON.IPEN = 1;                                    //Habilita el nivel de prioridad en las interrupciones
	BSF         RCON+0, 7 
;Master.c,195 :: 		IPR1.RC1IP = 0;                                   //EUSART1 Receive Interrupt Priority bit = Low priority
	BCF         IPR1+0, 5 
;Master.c,196 :: 		IPR1.TMR1IP = 1;                                  //TMR1 Overflow Interrupt Priority bit = High priority
	BSF         IPR1+0, 0 
;Master.c,198 :: 		Delay_ms(10);                                     //Espera para que el modulo UART se estabilice
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
;Master.c,201 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Master.c,203 :: 		void main() {
;Master.c,205 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Master.c,207 :: 		BanTI = 0;                                                     //Inicializa las banderas de trama
	CLRF        _BanTI+0 
;Master.c,208 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Master.c,209 :: 		BanTF = 0;
	CLRF        _BanTF+0 
;Master.c,211 :: 		Bb = 0;                                                        //Inicializa la bandera del boton, es solo para el ejemplo del dispositivo maestro
	CLRF        _Bb+0 
;Master.c,213 :: 		RC5_bit = 0;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,214 :: 		RC3_bit = 0;                                                   //Establece el Max485 en modo de lectura;
	BCF         RC3_bit+0, BitPos(RC3_bit+0) 
;Master.c,215 :: 		RC4_bit = 0;                                                   //Inicializa un indicador. No tiene relevancia para la ejecucion del programa
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Master.c,217 :: 		ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
	MOVLW       _CRC16+0
	MOVWF       _ptrCRC16+0 
	MOVLW       hi_addr(_CRC16+0)
	MOVWF       _ptrCRC16+1 
;Master.c,218 :: 		ptrCRCPDU = &CRCPDU;                                           //Asociacion del puntero CRCPDU
	MOVLW       _CRCPDU+0
	MOVWF       _ptrCRCPDU+0 
	MOVLW       hi_addr(_CRCPDU+0)
	MOVWF       _ptrCRCPDU+1 
;Master.c,220 :: 		while (1){
L_main26:
;Master.c,223 :: 		if ((RC2_bit==0)&&(Bb==0)){
	BTFSC       RC2_bit+0, BitPos(RC2_bit+0) 
	GOTO        L_main30
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main30
L__main42:
;Master.c,224 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;Master.c,225 :: 		Add = (PORTA&0x3F)+((PORTC&0x03)<<6);                //Carga el valor del dipswitch como direccion del esclavo a quien se realiza la peticion
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
L__main51:
	BZ          L__main52
	RLCF        R0, 1 
	BCF         R0, 0 
	ADDLW       255
	GOTO        L__main51
L__main52:
	MOVF        R0, 0 
	ADDWF       _Add+0, 1 
;Master.c,226 :: 		enviarTrama(2,3);                                    //Envia la trama de peticion con 2 bytes de pyload y solicitando la funcion 3
	MOVLW       2
	MOVWF       FARG_enviarTrama_dataSize+0 
	MOVLW       3
	MOVWF       FARG_enviarTrama_fcn+0 
	CALL        _enviarTrama+0, 0
;Master.c,228 :: 		} else if (RC2_bit==1){
	GOTO        L_main31
L_main30:
	BTFSS       RC2_bit+0, BitPos(RC2_bit+0) 
	GOTO        L_main32
;Master.c,229 :: 		Bb = 0;                                              //Esta rutina sirve para evitar rebotes en el boton
	CLRF        _Bb+0 
;Master.c,230 :: 		}
L_main32:
L_main31:
;Master.c,232 :: 		if (BanTC==1){                                          //Verifica que la bandera de trama completa este activa
	MOVF        _BanTC+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main33
;Master.c,234 :: 		if (Rspt[1]==Add){                                   //Verifica que el campo de direccion de la trama de respuesta concuerde con la direccion del esclavo solicitado
	MOVF        _Rspt+1, 0 
	XORWF       _Add+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_main34
;Master.c,236 :: 		for (i=0;i<=(Rsize-5);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	CLRF        _i+0 
L_main35:
	MOVLW       5
	SUBWF       _rsize+0, 0 
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
	GOTO        L__main53
	MOVF        _i+0, 0 
	SUBWF       R1, 0 
L__main53:
	BTFSS       STATUS+0, 0 
	GOTO        L_main36
;Master.c,237 :: 		PDU[i] = Rspt[i+1];
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
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,236 :: 		for (i=0;i<=(Rsize-5);i++){                       //Rellena la trama de PDU con los datos de interes de la trama de respuesta, es decir, obviando los ultimos 2 bytes de CRC y los 2 de End
	INCF        _i+0, 1 
;Master.c,238 :: 		}
	GOTO        L_main35
L_main36:
;Master.c,240 :: 		CRC16 = ModbusRTU_CRC16(PDU, Rsize-5);            //Calcula el CRC de la trama PDU y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       5
	SUBWF       _rsize+0, 0 
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	CLRF        FARG_ModbusRTU_CRC16_uiLen+1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Master.c,241 :: 		*ptrCRCPDU = Rspt[Rsize-3];                       //Asigna el elemento CRC_LSB de la trama de respuesta al LSB de la variable CRCPDU
	MOVLW       3
	SUBWF       _rsize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVFF       _ptrCRCPDU+0, FSR1
	MOVFF       _ptrCRCPDU+1, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,242 :: 		*(ptrCRCPDU+1) = Rspt[Rsize-4];                   //Asigna el elemento CRC_MSB de la trama de respuesta al MSB de la variable CRCPDU
	MOVLW       1
	ADDWF       _ptrCRCPDU+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrCRCPDU+1, 0 
	MOVWF       FSR1H 
	MOVLW       4
	SUBWF       _rsize+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _Rspt+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,244 :: 		if (CRC16==CRCPDU) {                              //Verifica si el CRC calculado sea igual al CRC obtenido de la trama de peticion
	MOVF        _CRC16+1, 0 
	XORWF       _CRCPDU+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main54
	MOVF        _CRCPDU+0, 0 
	XORWF       _CRC16+0, 0 
L__main54:
	BTFSS       STATUS+0, 2 
	GOTO        L_main38
;Master.c,248 :: 		RC3_bit = 1;
	BSF         RC3_bit+0, BitPos(RC3_bit+0) 
;Master.c,249 :: 		Delay_ms(100);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_main39:
	DECFSZ      R13, 1, 1
	BRA         L_main39
	DECFSZ      R12, 1, 1
	BRA         L_main39
	DECFSZ      R11, 1, 1
	BRA         L_main39
	NOP
;Master.c,250 :: 		RC3_bit = 0;
	BCF         RC3_bit+0, BitPos(RC3_bit+0) 
;Master.c,251 :: 		}
L_main38:
;Master.c,253 :: 		}
L_main34:
;Master.c,255 :: 		BanTC = 0;
	CLRF        _BanTC+0 
;Master.c,257 :: 		}
L_main33:
;Master.c,259 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main40:
	DECFSZ      R13, 1, 1
	BRA         L_main40
	DECFSZ      R12, 1, 1
	BRA         L_main40
	NOP
;Master.c,261 :: 		}
	GOTO        L_main26
;Master.c,262 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
