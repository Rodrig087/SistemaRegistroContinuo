//Compilar:
//gcc ComprobarRegistro_V2.c -o comprobarregistro 


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 249
#define TIEMPO_SPI 100

//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short numBytes;
unsigned short contMuestras;
unsigned int numCiclos;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[16+(NUM_MUESTRAS*10)];
unsigned short tiempoSPI;
unsigned short tramaSize;
char entrada[30];
char salida[30];
char ext1[8];
char ext2[8];
char nombreArchivo[16];
FILE *lf;
FILE *ef;

unsigned short xData[3];
unsigned short yData[3];
unsigned short zData[3];

int xValue;
int yValue;
int zValue;
double xAceleracion;
double yAceleracion;
double zAceleracion;


//Declaracion de funciones
void RecuperarVector();


int main(void) {
  
  i = 0;
  x = 0;
  contMuestras = 0;
  tramaSize = 16+(NUM_MUESTRAS*10);
     
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {

	lf = fopen ("/home/pi/Programas/RegistroContinuo/TMP/Temporal.tmp", "rb"); 
	fread(tramaDatos, sizeof(char), tramaSize, lf);
		
	printf("| ");
	printf("%0.2d:", tramaDatos[tramaSize-3]);			//hh
	printf("%0.2d:", tramaDatos[tramaSize-2]);			//mm
	printf("%0.2d ", tramaDatos[tramaSize-1]);			//ss
	printf("%0.2d/", tramaDatos[tramaSize-6]);			//aa
	printf("%0.2d/", tramaDatos[tramaSize-5]);			//mm
	printf("%0.2d ", tramaDatos[tramaSize-4]);			//dd
	printf("| ");
	
	for (x=0;x<3;x++){
		xData[x] = tramaDatos[x+1];	
		yData[x] = tramaDatos[x+4];	
		zData[x] = tramaDatos[x+7];	
	}
	
	//Calculo aceleracion eje x:
	xValue = ((xData[0]<<12)&0xFF000)+((xData[1]<<4)&0xFF0)+((xData[2]>>4)&0xF);
	// Apply two complement
	if (xValue >= 0x80000) {
		xValue = xValue & 0x7FFFF;		 //Se descarta el bit 20 que indica el signo (1=negativo)
		xValue = -1*(((~xValue)+1)& 0x7FFFF);
	}
	xAceleracion = xValue * (9.8/pow(2,18));
	
	//Calculo aceleracion eje y:
	yValue = ((yData[0]<<12)&0xFF000)+((yData[1]<<4)&0xFF0)+((yData[2]>>4)&0xF);
	// Apply two complement
	if (yValue >= 0x80000) {
		yValue = yValue & 0x7FFFF;		 //Se descarta el bit 20 que indica el signo (1=negativo)
		yValue = -1*(((~yValue)+1)& 0x7FFFF);
	}
	yAceleracion = yValue * (9.8/pow(2,18));
	
	//Calculo aceleracion eje z:
	zValue = ((zData[0]<<12)&0xFF000)+((zData[1]<<4)&0xFF0)+((zData[2]>>4)&0xF);
	// Apply two complement
	if (zValue >= 0x80000) {
		zValue = zValue & 0x7FFFF;		 //Se descarta el bit 20 que indica el signo (1=negativo)
		zValue = -1*(((~zValue)+1)& 0x7FFFF);
	}
	zAceleracion = zValue * (9.8/pow(2,18));	

	printf("X: ");
	printf("%2.8f ", xAceleracion);
	printf("Y: ");
	printf("%2.8f ", yAceleracion);
	printf("Z: ");
	printf("%2.8f ", zAceleracion); 
	printf("|\n");
	
	fclose (lf);
}



