#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 199
#define NUM_CICLOS 100
#define TIEMPO_SPI 100

//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[15+(NUM_MUESTRAS*10)];
unsigned short tiempoSPI;
unsigned short tramaSize;
FILE *lf;
FILE *ef;

//Declaracion de funciones
void RecuperarVector();


int main(void) {

  piHiPri (99);
  
  i = 0;
  x = 0;
  contMuestras = 0;
  tramaSize = 15+(NUM_MUESTRAS*10);
  
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {
	
	lf = fopen ("/home/pi/Ejemplos/EjemploSPI/output.dat", "rb");
	ef = fopen ("/home/pi/Ejemplos/EjemploSPI/lectura.txt", "ab");
	while (contMuestras<NUM_CICLOS){
		fread(tramaDatos, sizeof(char), tramaSize, lf);
		fprintf(ef, "\n");
		for (i=0;i<tramaSize;i++){
			if ((i==0)||(i%10==0)){
				fprintf(ef, " %0.3d ", tramaDatos[i]);				
			} else {
				fprintf(ef, "%d", tramaDatos[i]);
			}
	    }
		
		contMuestras++;
    }
	fclose (ef);
	fclose (lf);
}

