//Compilar:
//gcc ComprobarRegistro.c -o comprobarregistro 


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

	lf = fopen ("./TMP/Temporal.tmp", "rb");
	ef = fopen ("./TMP/Temporal.txt", "wb"); 
	
	fread(tramaDatos, sizeof(char), tramaSize, lf);
	
	fprintf(ef, "\n");
	for (i=0;i<tramaSize;i++){
		if ((i==0)||(i%10==0)){
			fprintf(ef, " %0.3d ", tramaDatos[i]);	
		} else {
			fprintf(ef, "%0.3d", tramaDatos[i]);
		}
	}
	
	fclose (ef);
	fclose (lf); 
	
	printf("%0.2d:", tramaDatos[tramaSize-3]);			//hh
	printf("%0.2d:", tramaDatos[tramaSize-2]);			//mm
	printf("%0.2d ", tramaDatos[tramaSize-1]);			//ss
	printf("%0.2d/", tramaDatos[tramaSize-6]);			//aa
	printf("%0.2d/", tramaDatos[tramaSize-5]);			//mm
	printf("%0.2d\n", tramaDatos[tramaSize-4]);			//dd
	
}



