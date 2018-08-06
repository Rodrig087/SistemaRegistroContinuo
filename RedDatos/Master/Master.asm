
_interrupt:

;Master.c,35 :: 		void interrupt(void){
;Master.c,36 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Master.c,38 :: 		Dato = UART1_Read();
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Master.c,40 :: 		if ((Dato==Hdr)&&(ir==0)){                   //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
L__interrupt33:
;Master.c,41 :: 		BanT = 1;                                 //Activa una bandera de trama
	MOVLW       1
	MOVWF       _BanT+0 
;Master.c,42 :: 		Rspt[ir] = Dato;                          //Almacena el Dato en la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,43 :: 		}
L_interrupt3:
;Master.c,44 :: 		if ((Dato!=Hdr)&&(ir==0)){                   //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOVF        _Dato+0, 0 
	XORLW       58
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt6
L__interrupt32:
;Master.c,45 :: 		ir=-1;                                    //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ir+0 
;Master.c,46 :: 		}
L_interrupt6:
;Master.c,47 :: 		if ((BanT==1)&&(ir!=0)){
	MOVF        _BanT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt9
L__interrupt31:
;Master.c,48 :: 		Rspt[ir] = Dato;                          //Almacena el resto de datos en la trama de respuesta si la bandera de trama esta activada
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,49 :: 		}
L_interrupt9:
;Master.c,51 :: 		ir++;                                        //Aumenta el subindice una unidad
	INCF        _ir+0, 1 
;Master.c,52 :: 		if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _ir+0, 0 
	XORLW       9
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt10
;Master.c,53 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanP+0 
;Master.c,54 :: 		ir=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	CLRF        _ir+0 
;Master.c,55 :: 		}
L_interrupt10:
;Master.c,57 :: 		PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,58 :: 		}
L_interrupt0:
;Master.c,59 :: 		}
L_end_interrupt:
L__interrupt35:
	RETFIE      1
; end of _interrupt

_ModbusRTU_CRC16:

;Master.c,62 :: 		unsigned int ModbusRTU_CRC16(unsigned char* ptucBuffer, unsigned int uiLen)
;Master.c,66 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       255
	MOVWF       R3 
	MOVLW       255
	MOVWF       R4 
L_ModbusRTU_CRC1611:
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__ModbusRTU_CRC1637
	MOVLW       0
	XORWF       FARG_ModbusRTU_CRC16_uiLen+0, 0 
L__ModbusRTU_CRC1637:
	BTFSC       STATUS+0, 2 
	GOTO        L_ModbusRTU_CRC1612
;Master.c,68 :: 		uiCRCResult ^=*ptucBuffer ++;
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+0, FSR2
	MOVFF       FARG_ModbusRTU_CRC16_ptucBuffer+1, FSR2H
	MOVF        POSTINC2+0, 0 
	XORWF       R3, 1 
	MOVLW       0
	XORWF       R4, 1 
	INFSNZ      FARG_ModbusRTU_CRC16_ptucBuffer+0, 1 
	INCF        FARG_ModbusRTU_CRC16_ptucBuffer+1, 1 
;Master.c,69 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	CLRF        R2 
L_ModbusRTU_CRC1614:
	MOVLW       8
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ModbusRTU_CRC1615
;Master.c,71 :: 		if(uiCRCResult & 0x0001)
	BTFSS       R3, 0 
	GOTO        L_ModbusRTU_CRC1617
;Master.c,72 :: 		uiCRCResult =( uiCRCResult >>1)^PolModbus;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
	MOVLW       1
	XORWF       R3, 1 
	MOVLW       160
	XORWF       R4, 1 
	GOTO        L_ModbusRTU_CRC1618
L_ModbusRTU_CRC1617:
;Master.c,74 :: 		uiCRCResult >>=1;
	RRCF        R4, 1 
	RRCF        R3, 1 
	BCF         R4, 7 
L_ModbusRTU_CRC1618:
;Master.c,69 :: 		for(ucCounter =0; ucCounter <8; ucCounter ++)
	INCF        R2, 1 
;Master.c,75 :: 		}
	GOTO        L_ModbusRTU_CRC1614
L_ModbusRTU_CRC1615:
;Master.c,66 :: 		for(uiCRCResult=0xFFFF; uiLen!=0; uiLen --)
	MOVLW       1
	SUBWF       FARG_ModbusRTU_CRC16_uiLen+0, 1 
	MOVLW       0
	SUBWFB      FARG_ModbusRTU_CRC16_uiLen+1, 1 
;Master.c,76 :: 		}
	GOTO        L_ModbusRTU_CRC1611
L_ModbusRTU_CRC1612:
;Master.c,77 :: 		return uiCRCResult;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
;Master.c,78 :: 		}
L_end_ModbusRTU_CRC16:
	RETURN      0
; end of _ModbusRTU_CRC16

_Configuracion:

;Master.c,81 :: 		void Configuracion(){
;Master.c,83 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Master.c,84 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Master.c,85 :: 		ANSELC = 0;                                       //Configura el PORTC como digital
	CLRF        ANSELC+0 
;Master.c,87 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Master.c,88 :: 		TRISA0_bit = 1;
	BSF         TRISA0_bit+0, BitPos(TRISA0_bit+0) 
;Master.c,89 :: 		TRISA1_bit = 0;
	BCF         TRISA1_bit+0, BitPos(TRISA1_bit+0) 
;Master.c,91 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Master.c,92 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Master.c,93 :: 		INTCON.RBIF = 0;
	BCF         INTCON+0, 0 
;Master.c,95 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Master.c,96 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,98 :: 		UART1_Init(57600);                                 //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       34
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Master.c,99 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_Configuracion19:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion19
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion19
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion19
	NOP
;Master.c,101 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Master.c,103 :: 		void main() {
;Master.c,105 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Master.c,106 :: 		RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,108 :: 		ptrCRC16 = &CRC16;                                             //Asociacion del puntero CRC16
	MOVLW       _CRC16+0
	MOVWF       _ptrCRC16+0 
	MOVLW       hi_addr(_CRC16+0)
	MOVWF       _ptrCRC16+1 
;Master.c,111 :: 		PDU[0]=Add;
	MOVLW       1
	MOVWF       _PDU+0 
;Master.c,112 :: 		PDU[1]=Fcn;
	MOVLW       2
	MOVWF       _PDU+1 
;Master.c,113 :: 		PDU[2]=0x03;
	MOVLW       3
	MOVWF       _PDU+2 
;Master.c,114 :: 		PDU[3]=0x04;
	MOVLW       4
	MOVWF       _PDU+3 
;Master.c,120 :: 		Ptcn[0]=Hdr;
	MOVLW       58
	MOVWF       _Ptcn+0 
;Master.c,121 :: 		Ptcn[Psize-2]=End1;
	MOVLW       13
	MOVWF       _Ptcn+7 
;Master.c,122 :: 		Ptcn[Psize-1]=End2;
	MOVLW       10
	MOVWF       _Ptcn+8 
;Master.c,125 :: 		while (1){
L_main20:
;Master.c,127 :: 		CRC16 = ModbusRTU_CRC16(PDU, PDUSize);               //Calcula el CRC de la trama de peticion y la almacena en la variable CRC16
	MOVLW       _PDU+0
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+0 
	MOVLW       hi_addr(_PDU+0)
	MOVWF       FARG_ModbusRTU_CRC16_ptucBuffer+1 
	MOVLW       4
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+0 
	MOVLW       0
	MOVWF       FARG_ModbusRTU_CRC16_uiLen+1 
	CALL        _ModbusRTU_CRC16+0, 0
	MOVF        R0, 0 
	MOVWF       _CRC16+0 
	MOVF        R1, 0 
	MOVWF       _CRC16+1 
;Master.c,128 :: 		Ptcn[6] = *ptrCRC16;                                 //Asigna el MSB de CRC al espacio 6 de la trama de peticion
	MOVFF       _ptrCRC16+0, FSR0
	MOVFF       _ptrCRC16+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _Ptcn+6 
;Master.c,129 :: 		Ptcn[5] = *(ptrCRC16+1);                             //Asigna el LSB del CRC al espacio 5 de la trama de peticion
	MOVLW       1
	ADDWF       _ptrCRC16+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _ptrCRC16+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _Ptcn+5 
;Master.c,131 :: 		for (ip=1;ip<=4;ip++){                               //Rellena la trama de peticion con los datos de la trama PDU
	MOVLW       1
	MOVWF       _ip+0 
L_main22:
	MOVLW       128
	XORLW       4
	MOVWF       R0 
	MOVLW       128
	XORWF       _ip+0, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_main23
;Master.c,132 :: 		Ptcn[ip] = PDU[ip-1];
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ip+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	DECF        _ip+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	MOVWF       R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _PDU+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_PDU+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,131 :: 		for (ip=1;ip<=4;ip++){                               //Rellena la trama de peticion con los datos de la trama PDU
	INCF        _ip+0, 1 
;Master.c,133 :: 		}
	GOTO        L_main22
L_main23:
;Master.c,135 :: 		for (ip=0;ip<Psize;ip++){
	CLRF        _ip+0 
L_main25:
	MOVLW       128
	XORWF       _ip+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       9
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main26
;Master.c,136 :: 		UART1_WRITE(Ptcn[ip]);                           //Manda por Uart la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _ip+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Master.c,135 :: 		for (ip=0;ip<Psize;ip++){
	INCF        _ip+0, 1 
;Master.c,137 :: 		}
	GOTO        L_main25
L_main26:
;Master.c,138 :: 		while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_main28:
	CALL        _UART_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main29
	GOTO        L_main28
L_main29:
;Master.c,140 :: 		Delay_ms(20);
	MOVLW       52
	MOVWF       R12, 0
	MOVLW       241
	MOVWF       R13, 0
L_main30:
	DECFSZ      R13, 1, 1
	BRA         L_main30
	DECFSZ      R12, 1, 1
	BRA         L_main30
	NOP
	NOP
;Master.c,142 :: 		}
	GOTO        L_main20
;Master.c,143 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
