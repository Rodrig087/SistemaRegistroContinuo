//Compilar:
//gcc ControladorRegistro_V1.c -o /home/pi/Ejecutables/controlregistro 


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <unistd.h>

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

FILE *tmpf;
FILE *lf;

char path[30];
char ext[8];
unsigned char nombreArchivo[13];

unsigned int segInicio;
unsigned int segActual;
unsigned int segTranscurridos;

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
  
  segInicio = 0;
  segActual = 0;
  segTranscurridos = 0;
         
  RecuperarVector();
 
  return 0;
  
 }


void RecuperarVector() {

	//Abre el archivo temporal en modo lectura
	tmpf = fopen ("/home/pi/TMP/namefile.tmp", "rb"); 
	fread(nombreArchivo, sizeof(char), 12, tmpf);									//Recupera el nombre del archivo en forma de 12 caracteres
	
	
		
	//Asigna espacio en la memoria para el nombre completo de la ruta:
	char *path = malloc(strlen(nombreArchivo)+5+27);		
	//Asigna el nombre de la ruta y la extencion a los array de caracteres:
	strcpy(ext, ".dat");
	strcpy(path, "/media/PenDrive/Resultados/");
	//Realiza la concatenacion de array de caracteres:
	strcat(path, nombreArchivo);
	strcat(path, ext);		
	//Abre el archivo binario en modo lectura:
	lf = fopen (path, "rb");
	
	//Recupera la primera trama de datos para obtener el tiempo de inicio:
	fread(tramaDatos, sizeof(char), tramaSize, lf);									
	segInicio = (tramaDatos[tramaSize-3]*3600)+(tramaDatos[tramaSize-2]*60)+(tramaDatos[tramaSize-1]);
		
	//Recupera la hora actual:
	//Obtiene la hora y la fecha del sistema:
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);	
	segActual = ((tm->tm_hour)*3600)+((tm->tm_min)*60)+(tm->tm_sec);
	
	//Calcula el tiempo transcurrido desde que inicio el muestreo:
	segTranscurridos = segActual - segInicio;
				
	//Se salta el numero de segundos que indique la variable segTranscurridos
	for (x=0;x<(segTranscurridos);x++){
		fread(tramaDatos, sizeof(char), tramaSize, lf);								
	}
	
	//Verifica si el minuto del tiempo local es diferente del minuto del tiempo de la trama recuperada:
	if ((tm->tm_min)==(tramaDatos[tramaSize-2])){
		printf("Trama OK\n");
	} else {
		//Reinicia el software de registro continuo:
		system("registrocontinuo stop");
		sleep(1);
		system("registrocontinuo start");											
	}
	
	fclose (tmpf);
	fclose (lf);
	
}

//if (((tm->tm_hour)!=(tramaDatos[tramaSize-3]))&&((tm->tm_min)!=(tramaDatos[tramaSize-2]))){


