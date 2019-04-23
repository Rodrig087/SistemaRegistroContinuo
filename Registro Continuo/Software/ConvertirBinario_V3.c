#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 199
#define TIEMPO_SPI 100

//Declaracion de variables
unsigned short i,k;
signed short j;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short numBytes;
unsigned int contMuestras;
unsigned int numCiclos;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[15+(NUM_MUESTRAS*10)];
unsigned short axisData[3];
unsigned int axisValue;
double aceleracion;
unsigned short tiempoSPI;
unsigned short tramaSize;
char entrada[30];
char salida[30];
char ext1[8];
char ext2[8];
char nombreArchivo[16];
FILE *lf;
FILE *ef;

//Declaracion de funciones
void RecuperarVector();


int main(void) {
  
  i = 0;
  x = 0;
  j = 0;
  
  axisValue = 0;
  aceleracion = 0.0;  
  contMuestras = 0;
  tramaSize = 15+(NUM_MUESTRAS*10);
     
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {
	
	//Pide como parametros el numero de lineas que se desea convertir y el nombre del archivo binario (sin extencion)
	printf("Ingrese el tiempo de muestreo (min):\n");
	scanf("%d", &numCiclos);
	printf("Ingrese el nombre del archivo:\n");
	scanf("%s", nombreArchivo);

	//Asigna espacio en la memoria para el nombre completo de la ruta
	char *entrada = malloc(strlen(nombreArchivo)+5+13);
	char *salida = malloc(strlen(nombreArchivo)+5+13);
	
	//Asigna el nombre de la ruta y la extencion a los array de caracteres
	strcpy(entrada, "./Resultados/");
	strcpy(salida, "./Resultados/");
	strcpy(ext1, ".dat");
	strcpy(ext2, ".txt");
	
	//Realiza la concatenacion de array de caracteres
	strcat(entrada, nombreArchivo);
	strcat(entrada, ext1);
	strcat(salida, nombreArchivo);
	strcat(salida, ext2);
	
	//Abre el archivo binario de entrada y crea el archivo de texto de salida
	lf = fopen (entrada, "rb");
	ef = fopen (salida, "wb");
	
	free(entrada);
	free(salida);
	
	
	fread(tramaDatos, sizeof(char), tramaSize, lf);					 //Tengo que leer una vez antes del bucle para que el puntero avance 2000 elementos para asi saltarme los ceros
	while (contMuestras<(numCiclos*60)){
		fread(tramaDatos, sizeof(char), tramaSize, lf);				 //Leo la cantidad establecida en la variable tramaSize del contenido del archivo lf y lo guardo en el vector tramaDatos 
		for (i=0;i<tramaSize-5;i++){								 //Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
			if ((i%10==0)){
				fprintf(ef, "\n%0.3d ", contMuestras);				 //Muestra el contador de muestras local
				fprintf(ef, "%0.3d", tramaDatos[0]);				 //Muestra el contador de muestras del dsPIC
				if ((i==0)||(i%200==0)){							 //Corrige el numero de la primera muestra
					fprintf(ef, " %0.3d ", 0);	
				} else {
					fprintf(ef, " %0.3d ", tramaDatos[i]);
				}
				j = 0;
			} else {
				if (j<2){
					axisData[j] = tramaDatos[i];
				} else {
					axisData[2] = tramaDatos[i];
					axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF);
					// Apply two complement
					if (axisValue >= 0x80000) {
						axisValue = ~axisValue + 1;
					}
					aceleracion = axisValue * (9.8/pow(2,18));
					fprintf(ef, "%2.8f", aceleracion);
					fprintf(ef, " ");
					j = -1;
				}
				j++;				
			}
						
	    }
		contMuestras++;
    }
	
	fclose (ef);
	fclose (lf);
}



//Compilar:
//gcc ConvertirBinario_V3.c -o convertirV3
