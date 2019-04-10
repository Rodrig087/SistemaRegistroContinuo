#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
  contMuestras = 0;
  tramaSize = 15+(NUM_MUESTRAS*10);
     
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {
	
	//Pide como parametros el numero de lineas que se desea convertir y el nombre del archivo binario (sin extencion)
	printf("Ingrese el numero de muestras:\n");
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
	//lf = fopen (entrada, "rb");
	ef = fopen (salida, "wb");
	
	free(entrada);
	free(salida);

	lf = fopen ("/home/pi/Documents/RegistroContinuo/Software/Resultados/201904091734.dat", "rb");
	//ef = fopen ("/home/pi/Documents/RegistroContinuo/Software/Resultados/lectura.txt", "wb");
	
	while (contMuestras<numCiclos){
		fread(tramaDatos, sizeof(char), tramaSize, lf);
		fprintf(ef, "\n");
		for (i=0;i<tramaSize;i++){
			if ((i==0)||(i%10==0)){
				fprintf(ef, " %0.3d ", tramaDatos[i]);	
			} else {
				fprintf(ef, "%0.3d", tramaDatos[i]);
			}
	    }
		
		contMuestras++;
    }
	fclose (ef);
	fclose (lf);
}



//Compilar:
//gcc ConvertirBinario_V2.c -o convertir 
