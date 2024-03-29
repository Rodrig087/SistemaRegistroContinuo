//Autor: Milton Muñoz
//Fecha: 17/06/2019
//Compilar: gcc Comprobar_FIFOFULL.c -o comprobar
//Descripcion: Esta es la cuarta version del programa de intepretacion de datos del archivo binario. Esta version se encarga de generar 3 archivos correspondientes a lo 3 ejes con un factor de diezmado fijado de antemano para facilitar su graficacion.



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
unsigned short i, k;
signed short j;
unsigned short contEje;
unsigned int x;
unsigned short banGuardar;
unsigned int contMuestras;
unsigned int numCiclos;
unsigned int tiempoInicial;
unsigned int factorDiezmado;
unsigned long periodoMuestreo;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[16+(NUM_MUESTRAS*10)];
unsigned short axisData[3];
int axisValue;
double aceleracion;
unsigned short tiempoSPI;
unsigned short tramaSize;
char rutaEntrada[30];
char rutaSalidaX[30];
char rutaSalidaY[30];
char rutaSalidaZ[30];
char ext1[8];
char ext2[8];
char nombreArchivo[16];
char nombreRed[8];
char nombreEstacion[8];
char ejeX[2];
char ejeY[2];
char ejeZ[2];

FILE *lf;
FILE *fileX;
FILE *fileY;
FILE *fileZ;


//Declaracion de funciones
void RecuperarVector();


int main(void) {
  
  i = 0;
  x = 0;
  j = 0;
  k = 0;
  
  factorDiezmado = 1;
  banGuardar = 0;
  periodoMuestreo = 4;
  
  axisValue = 0;
  aceleracion = 0.0;  
  contMuestras = 0;
  tramaSize = 16+(NUM_MUESTRAS*10);			//16+(249*10) = 2506
     
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Creacion de archivos de texto
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Pide como parametros el numero de lineas que se desea convertir y el nombre del archivo binario (sin extencion)
	printf("Ingrese el nombre del archivo:\n");
	scanf("%s", nombreArchivo);
	printf("Ingrese el tiempo de inicio del muestreo (min):\n");
	scanf("%d", &tiempoInicial);
	printf("Ingrese el tiempo de muestreo (min):\n");
	scanf("%d", &numCiclos);
	printf("Ingrese el factor de diezmado:\n");
	scanf("%d", &factorDiezmado);

	//Asigna espacio en la memoria para el nombre completo de la ruta
	char *rutaEntrada = malloc(strlen(nombreArchivo)+5+13);
	char *rutaSalidaX = malloc(strlen(nombreArchivo)+5+13+12);
	char *rutaSalidaY = malloc(strlen(nombreArchivo)+5+13+12);
	char *rutaSalidaZ = malloc(strlen(nombreArchivo)+5+13+12);
	
	//Asignacion del nombre de la ruta y la extencion a los array de caracteres
	strcpy(rutaEntrada, "./Resultados/");
	strcpy(rutaSalidaX, "./Resultados/");
		
	strcpy(nombreRed, "RSA");
	strcpy(nombreEstacion, "EST1");
	strcpy(ejeX, "N");
	
	strcpy(ext1, ".dat");
	strcpy(ext2, ".txt");
	
	//Realiza la concatenacion de array de caracteres
	strcat(rutaEntrada, nombreArchivo);
	strcat(rutaEntrada, ext1);
	
	strcat(rutaSalidaX, nombreRed);
	strcat(rutaSalidaX, nombreEstacion);
	strcat(rutaSalidaX, ejeX);
	strcat(rutaSalidaX, nombreArchivo);
	strcat(rutaSalidaX, ext2);
	
	//Abre el archivo binario de entrada y crea el archivo de texto de salida
	lf = fopen (rutaEntrada, "rb");
	fileX = fopen (rutaSalidaX, "wb");
	
	free(rutaEntrada);
	free(rutaSalidaX);
	free(rutaSalidaY);
	free(rutaSalidaZ);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Escritura de datos en los archivos de texto
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	//fread(tramaDatos, sizeof(char), tramaSize, lf);					//Se salta la linea de ceros
	for (x=0;x<(tiempoInicial*60);x++){
		fread(tramaDatos, sizeof(char), tramaSize, lf);				//Se salta el numero de minutos que indique la variable tiempoInicial
	}
	
	while (contMuestras<(numCiclos*60)){
		fread(tramaDatos, sizeof(char), tramaSize, lf);				 //Leo la cantidad establecida en la variable tramaSize del contenido del archivo lf y lo guardo en el vector tramaDatos 
		for (i=0;i<tramaSize-5;i++){								 //Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
			if ((i%(10*factorDiezmado)==0)){						 //Indica el inicio de un nuevo set de muestras
				banGuardar = 1;									 	 //Cambia el estado de la bandera para permitir guardar la muestra 
				j = 0;
				contEje = 0;
			} else {
				if (banGuardar==1){
					if (j<2){
						axisData[j] = tramaDatos[i];				 //axisData guarda la informacion de los 3 bytes correspondientes a un eje
					} else {
						axisData[2] = tramaDatos[i];				 //Termina de llenar el vector axisData
						//axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF);
						axisValue = ((axisData[2])&0xF);			//Obtengo los ultimos 4 bits del dato del ejex
						
						aceleracion = axisValue;
						
						if (contEje==0){
							fprintf(fileX, "%0.3d ", tramaDatos[0]); //Escribe el numero de muestra
							fprintf(fileX, "%2.2f\n", aceleracion);	 //Escribe en el archivo fileX los datos del eje x
							
						}
						if (contEje==1){
							/* fprintf(fileY, "%0.3d ", tramaDatos[0]);
							fprintf(fileY, "%2.8f ", aceleracion);	 //Escribe en el archivo fileY los datos del eje y
							
							fprintf(fileY, "%0.2d:", tramaDatos[tramaSize-6]);
							fprintf(fileY, "%0.2d:", tramaDatos[tramaSize-5]);
							fprintf(fileY, "%0.2d ", tramaDatos[tramaSize-4]);
							fprintf(fileY, "%0.2d/", tramaDatos[tramaSize-3]);
							fprintf(fileY, "%0.2d/", tramaDatos[tramaSize-2]);
							fprintf(fileY, "%0.2d\n", tramaDatos[tramaSize-1]); */
						
						}
						if (contEje==2){
							/* fprintf(fileZ, "%0.3d ", tramaDatos[0]);
							fprintf(fileZ, "%2.8f ", aceleracion);	 //Escribe en el archivo fileZ los datos del eje z					
							
							fprintf(fileZ, "%0.2d:", tramaDatos[tramaSize-3]);
							fprintf(fileZ, "%0.2d:", tramaDatos[tramaSize-2]);
							fprintf(fileZ, "%0.2d ", tramaDatos[tramaSize-1]);
							fprintf(fileZ, "%0.2d/", tramaDatos[tramaSize-6]);
							fprintf(fileZ, "%0.2d/", tramaDatos[tramaSize-5]);
							fprintf(fileZ, "%0.2d\n", tramaDatos[tramaSize-4]); */
							
							banGuardar = 0;							 //Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar
						}	
						
						j = -1;
						contEje++;
					}
					j++;	
				}
			}
						
	    }
		contMuestras++;
    }
	
	fclose (lf);
	fclose (fileX);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

