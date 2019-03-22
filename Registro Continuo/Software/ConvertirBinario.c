#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 199
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
unsigned char tramaDatos[15+(NUM_MUESTRAS*10)];
unsigned short tiempoSPI;
unsigned short tramaSize;
FILE *lf;
FILE *ef;

//Declaracion de funciones
void RecuperarVector(unsigned int numCiclos);


int main(void) {

  piHiPri (99);
  
  i = 0;
  x = 0;
  contMuestras = 0;
  tramaSize = 15+(NUM_MUESTRAS*10);
  
  printf("Ingrese el numero de muestras:\n");
  scanf("%d", &numCiclos);
  
  RecuperarVector(numCiclos);
 
  return 0;
  
 }


void RecuperarVector(unsigned int numCiclos) {
	
	lf = fopen ("/home/pi/Documents/RegistroContinuo/Software/Resultados/output.dat", "rb");
	ef = fopen ("/home/pi/Documents/RegistroContinuo/Software/Resultados/lectura.txt", "wb");
	while (contMuestras<numCiclos){
		fread(tramaDatos, sizeof(char), tramaSize, lf);
		fprintf(ef, "\n");
		for (i=0;i<tramaSize;i++){
			if ((i==0)||(i==1)||(i%10==0)){
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

