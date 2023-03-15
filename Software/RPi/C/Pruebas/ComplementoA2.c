//Autor: Milton Muñoz
//Fecha: 17/06/2019
//Compilar: gcc ComplementoA2.c -o complento
//Programa para probar el algoritmo de complento A2

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

unsigned short axisData[3];
int axisValue;
int xComp1;
int xComp2;
int xComp3;
int xComp4;
double aceleracion1;
double aceleracion2;
double aceleracion3;
double aceleracion4;

int main(void) {
	
	//012193113 000023016 064066112
	//248249145 252249208 062170080
	//254 206 225
	
	axisData[0] = 254;
	axisData[1] = 206;
	axisData[2] = 225;
	
	axisValue = 0;
	xComp1 = 0;
	xComp2 = 0;
	xComp3 = 0;
	xComp4 = 0;
	aceleracion1 = 0.0;
	aceleracion2 = 0.0;
	aceleracion3 = 0.0;
	aceleracion4 = 0.0;
	
	axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF);
	
	//Calculo del complento A2
	if (axisValue >= 0x80000) {
		//Primer metodo:
		xComp1 = ((~axisValue) + 1);				 
		//Segundo metodo:
		//Este es el que sirve
		xComp2 = axisValue & 0x7FFFF;					//Se descarta el bit 20 que es el que indica el signo
		xComp2 = -1*(((~xComp2)+1)& 0x7FFFF);			//Se calcula el complemento A2, se realiza un AND con 19 bits LSB llenos de unos, y se saca el negativo del numero que salga
		//Tercer metodo:
		xComp3 = axisValue & 0x7FFFF;
		xComp3 = xComp3 & 0xFFFFFFFF;
		//Cuarto metodo:
		xComp4 = axisValue;
	} else {
		xComp1 = axisValue;
		xComp2 = axisValue;
		xComp3 = axisValue;
		xComp4 = axisValue;
	}
	
	aceleracion1 = xComp1 * (9.8/pow(2,18));
	aceleracion2 = xComp2 * (9.8/pow(2,18));
	aceleracion3 = xComp3 * (9.8/pow(2,18));
	aceleracion4 = xComp4 * (9.8/pow(2,18));
	
	printf("%i\n", xComp1);
	printf("%i\n", xComp2);
	printf("%i\n", xComp3);
	printf("%i\n", xComp4);
	printf("\n");
	printf("%2.8f\n", aceleracion1);
	printf("%2.8f\n", aceleracion2);	
	printf("%2.8f\n", aceleracion3);
	printf("%2.8f\n", aceleracion4);
	
}