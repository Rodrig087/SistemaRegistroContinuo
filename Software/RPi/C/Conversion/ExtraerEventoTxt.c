//Autor: Milton Muñoz
//Fecha: 24/03/2021
//Version OS: Raspbian OS
//Compilar: gcc ExtraerEvento.c -o extraerevento
//gcc ExtraerEventoTxt.c -o /home/pi/Ejecutables/extraerevento

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
double aceleracion, acelX, acelY, acelZ;
unsigned short tiempoSPI;
unsigned short tramaSize;
char rutaEntrada[35];
char rutaSalidaInfo[30];
char rutaSalidaX[30];
char rutaSalidaY[30];
char rutaSalidaZ[30];
char ext1[8];
char ext2[8];
char ext3[8];
char nombreArchivo[16];
char nombreArchivoEvento[16];
char nombreRed[8];
char nombreEstacion[8];
char ejeX[3];
char ejeY[3];
char ejeZ[3];

unsigned int duracionEvento;
unsigned int horaEvento;
unsigned int tiempoInicio;
unsigned int tiempoEvento;
unsigned int tiempoTranscurrido;
unsigned int fechaEventoTrama;
unsigned int horaEventoTrama;
unsigned int tiempoEventoTrama;
int tiempo;

unsigned short banExtraer;
unsigned char opcionExtraer;

double offLong, offTran, offVert;

FILE *lf;
FILE *fileInfo;
FILE *fileX;
FILE *fileY;
FILE *fileZ;


//Declaracion de funciones
void RecuperarVector();


int main(int argc, char *argv[]) {
  
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Ingreso de datos
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	strcpy(nombreArchivo, argv[1]);
	horaEvento = atoi(argv[2]);
	duracionEvento = atoi(argv[3]);	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  i = 0;
  x = 0;
  j = 0;
  k = 0;
  
  factorDiezmado = 1;
  banGuardar = 0;
  periodoMuestreo = 4;
  
  axisValue = 0;
  aceleracion = 0.0;
  acelX = 0.0;
  acelY = 0.0;
  acelZ = 0.0;
  contMuestras = 0;
  tramaSize = 16+(NUM_MUESTRAS*10);			//16+(249*10) = 2506
  
  //Constantes offset:
offLong = 0;
offTran = 0;
offVert = 0;

  banExtraer = 0;
     
  RecuperarVector();
 
  return 0;
  
 }
 


void RecuperarVector() {
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Abre el archivo binario
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Asigna espacio en la memoria para el nombre completo de la ruta:
	char *rutaEntrada = (char*)malloc(strlen(nombreArchivo)+5+23);
	//Asignacion del nombre de la ruta y la extencion a los array de caracteres:
	strcpy(rutaEntrada, "/home/pi/Resultados/");
	strcpy(ext1, ".dat");
	strcat(rutaEntrada, nombreArchivo);
	strcat(rutaEntrada, ext1);
	//Abre el archivo binario de entrada y crea el archivo de texto de salida:
	lf = fopen (rutaEntrada, "rb");	
	free(rutaEntrada);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Obtiene y calcula los tiempos de inicio del muestreo 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	fread(tramaDatos, sizeof(char), tramaSize, lf);	
	tiempoInicio = (tramaDatos[tramaSize-3]*3600)+(tramaDatos[tramaSize-2]*60)+(tramaDatos[tramaSize-1]);
	//tiempoEvento = ((horaEvento/10000)*3600)+(((horaEvento%10000)/100)*60)+(horaEvento%100);
	tiempoEvento = horaEvento;
	tiempoTranscurrido = tiempoEvento - tiempoInicio;
	printf("%d:",tiempoEvento);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Comprueba el estado de la trama de datos para continuar con el proceso
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Se salta el numero de segundos que indique la variable tiempoTranscurrido:
	for (x=0;x<(tiempoTranscurrido);x++){
		fread(tramaDatos, sizeof(char), tramaSize, lf);								
	}
	//Calcula la fecha de la trama recuperada en formato aammdd:
	fechaEventoTrama = ((int)tramaDatos[tramaSize-6]*10000)+((int)tramaDatos[tramaSize-5]*100)+((int)tramaDatos[tramaSize-4]);
	//Calcula la hora de la trama recuperada en formato hhmmss:
	horaEventoTrama = ((int)tramaDatos[tramaSize-3]*10000)+((int)tramaDatos[tramaSize-2]*100)+((int)tramaDatos[tramaSize-1]);
	//Calcula el tiempo de la trama recuperada en formato segundos:
	tiempoEventoTrama = ((int)tramaDatos[tramaSize-3]*3600)+((int)tramaDatos[tramaSize-2]*60)+((int)tramaDatos[tramaSize-1]);
	//Verifica si el minuto del tiempo local es diferente del minuto del tiempo de la trama recuperada:
	if ((tiempoEventoTrama)==(tiempoEvento)){
		printf("\nTrama OK\n");
		banExtraer = 1;
	} else {
		printf("\nError: El tiempo de la trama no concuerda\n");
		//Imprime la hora y fecha recuperada de la trama de datos
		printf("| ");
		printf("%0.2d:", tramaDatos[tramaSize-3]);			//hh
		printf("%0.2d:", tramaDatos[tramaSize-2]);			//mm
		printf("%0.2d ", tramaDatos[tramaSize-1]);			//ss
		printf("%0.2d/", tramaDatos[tramaSize-6]);			//aa
		printf("%0.2d/", tramaDatos[tramaSize-5]);			//mm
		printf("%0.2d ", tramaDatos[tramaSize-4]);			//dd
		printf("|\n");	
		banExtraer = 1; 
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Inicia el proceso de extraccion y almacenamieto del evento 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	if (banExtraer==1){
		
		printf("\nExtrayendo...\n");
		
		//Crea una carpeta con el nombre de la fecha del evento
		
		//Asigna espacio en la memoria para el nombre completo de la ruta:
		char *rutaSalidaInfo = (char*)malloc(strlen(nombreArchivo)+19+6);
		char *rutaSalidaX = (char*)malloc(strlen(nombreArchivo)+19+3+5);

		//Asignacion del nombre de la ruta y la extencion a los array de caracteres:
		strcpy(rutaSalidaInfo, "/home/pi/Eventos/");
		strcpy(rutaSalidaX, "/home/pi/Eventos/");
	
		strcpy(ext2, ".txt");
		strcpy(ext3, ".INFO");
	
		//Realiza la concatenacion de array de caracteres:
		strcat(rutaSalidaInfo, nombreArchivo);
		strcat(rutaSalidaInfo, ext3);
		
		strcat(rutaSalidaX, nombreArchivo);
		strcat(rutaSalidaX, ext2);
		
		//Abre el archivo binario de entrada y crea el archivo de texto de salida:
		fileInfo = fopen (rutaSalidaInfo, "wb");
		fileX = fopen (rutaSalidaX, "wb");
		free(rutaSalidaInfo);
		free(rutaSalidaX);

		//Escritura de datos en el archivo de informacion:
		fprintf(fileInfo, "Fecha(aammdd),Tiempo(hhmmss),Tiempo(segundos),Duracion(segundos),Periodo(ms)\n");
		fprintf(fileInfo, "%d,%d,%d,%d,%d\n", fechaEventoTrama, horaEventoTrama, tiempoEventoTrama, duracionEvento, periodoMuestreo);
		fclose (fileInfo);
					
		//Escritura de datos en los archivo de aceleracion:
		while (contMuestras<duracionEvento){											//Se almacena el numero de muestras que indique la variable duracionEvento
			fread(tramaDatos, sizeof(char), tramaSize, lf);				 				//Leo la cantidad establecida en la variable tramaSize del contenido del archivo lf y lo guardo en el vector tramaDatos 
			for (i=0;i<tramaSize-5;i++){								 				//Recorro las 2005 muestras del vector tramaDatos, omitiendo los 5 ultimos que corresponden a la fecha y hora del modulo gps
				if ((i%(10)==0)){						 								//Indica el inicio de un nuevo set de muestras
					banGuardar = 1;									 	 				//Cambia el estado de la bandera para permitir guardar la muestra 
					j = 0;
					contEje = 0;
				} else {
					if (banGuardar==1){
						if (j<2){
							axisData[j] = tramaDatos[i];				 				//axisData guarda la informacion de los 3 bytes correspondientes a un eje
						} else {
							axisData[2] = tramaDatos[i];				 				//Termina de llenar el vector axisData
							axisValue = ((axisData[0]<<12)&0xFF000)+((axisData[1]<<4)&0xFF0)+((axisData[2]>>4)&0xF);
							// Apply two complement:
							if (axisValue >= 0x80000) {
								axisValue = axisValue & 0x7FFFF;		 				//Se descarta el bit 20 que indica el signo (1=negativo)
								axisValue = -1*(((~axisValue)+1)& 0x7FFFF);
							}
							aceleracion = axisValue * (9.8/pow(2,18))*100;				//Aceleracion en gals (cm/seg2)
							tiempo = (tramaDatos[tramaSize-3]*3600)+(tramaDatos[tramaSize-2]*60)+(tramaDatos[tramaSize-1]);
							
							if (contEje==0){
								acelX = aceleracion;									//Guarda el valor de la aceleracion del eje x del nodo						
							}
							if (contEje==1){
								acelY = aceleracion;									//Guarda el valor de la aceleracion del eje y del nodo							
							}
							if (contEje==2){
								acelZ = aceleracion;									//Guarda el valor de la aceleracion del eje z del nodo											
								
								fprintf(fileX, "%2.5f\t%2.5f\t%2.5f\n", (acelX-offLong), (acelY-offTran), (acelZ-offVert));
																
								banGuardar = 0;							 				//Despues de terminar de guardar todas la muestras limpia la bandera banGuardar
							
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
		
		fclose (fileX);
				
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Final 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	fclose (lf);
	printf("\nTerminado\n");
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

