//Autor: Milton Muñoz
//Fecha: 28/11/2019
//Version OS: Windows 10
//Compilar W10: cmd /C cd $(CURRENT_DIRECTORY) & g++ -o $(NAME_PART).exe $(FILE_NAME) & pause 
//Compilar y ejecutar W10: cmd /C cd $(CURRENT_DIRECTORY) & g++ -o $(NAME_PART).exe $(FILE_NAME) & cmd /C start $(CURRENT_DIRECTORY)\$(NAME_PART).exe & pause
//Descripcion: 


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <conio.h>

#include <windows.h>

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
char rutaEntrada[35];
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

unsigned int fechaEvento;
unsigned int horaEvento;
unsigned int tiempoInicio;
unsigned int tiempoEvento;
unsigned int tiempoTranscurrido;
unsigned int tiempoEventoTrama;
int tiempo;

unsigned short banExtraer;
unsigned char opcionExtraer;

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
  
  banExtraer = 0;
     
  RecuperarVector();
 
  return 0;
  
 }
 


void RecuperarVector() {
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Ingreso de datos
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Pide como parametros el nombre del archivo binario (sin extencion) y la hora del evento (UTC):
	printf("Ingrese el nombre del archivo:\n");
	scanf("%s", nombreArchivo);
	printf("Ingrese la fecha del evento (aaaammdd):\n");
	scanf("%d", &fechaEvento);
	printf("Ingrese la hora del evento (hhmmss):\n");
	scanf("%d", &horaEvento);
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Abre el archivo binario
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Asigna espacio en la memoria para el nombre completo de la ruta:
	char *rutaEntrada = (char*)malloc(strlen(nombreArchivo)+5+17);
	//Asignacion del nombre de la ruta y la extencion a los array de caracteres:
	strcpy(rutaEntrada, "./Datos Binarios/");
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
	tiempoEvento = ((horaEvento/10000)*3600)+(((horaEvento%10000)/100)*60)+(horaEvento%100);
	tiempoTranscurrido = tiempoEvento - tiempoInicio - 120;
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Comrpueba el estado de la trama de datos para continuar con el proceso
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Se salta el numero de segundos que indique la variable tiempoTranscurrido:
	for (x=0;x<(tiempoTranscurrido);x++){
		fread(tramaDatos, sizeof(char), tramaSize, lf);								
	}
	//Calcula el tiempo en segundos de la trama recuperada:
	tiempoEventoTrama = ((int)tramaDatos[tramaSize-3]*3600)+((int)tramaDatos[tramaSize-2]*60)+((int)tramaDatos[tramaSize-1]);	
	//Verifica si el minuto del tiempo local es diferente del minuto del tiempo de la trama recuperada:
	if ((tiempoEventoTrama)==(tiempoEvento-120)){
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
		printf("Desea continuar? (s/n)\n");
		opcionExtraer=getch();
		//scanf("%c", &opcionExtraer);
		if (opcionExtraer=='s'){
			banExtraer = 1;	
		} 
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Inicia el proceso de extraccion y almacenamieto del evento 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	if (banExtraer==1){
		
		printf("\nExtrayendo...\n");
		
		//Crea una carpeta con el nombre de la fecha del evento
		
		
		//Asigna espacio en la memoria para el nombre completo de la ruta:
		char *rutaSalidaX = (char*)malloc(strlen(nombreArchivo)+5+13+12);
		char *rutaSalidaY = (char*)malloc(strlen(nombreArchivo)+5+13+12);
		char *rutaSalidaZ = (char*)malloc(strlen(nombreArchivo)+5+13+12);
	
		//Asignacion del nombre de la ruta y la extencion a los array de caracteres:
		strcpy(rutaSalidaX, "./Resultados/");
		strcpy(rutaSalidaY, "./Resultados/");
		strcpy(rutaSalidaZ, "./Resultados/");
		strcpy(nombreRed, "RSA");
		strcpy(nombreEstacion, "EST1");
		strcpy(ejeX, "N");
		strcpy(ejeY, "E");
		strcpy(ejeZ, "Z");
		strcpy(ext2, ".txt");
	
		//Realiza la concatenacion de array de caracteres:			
		strcat(rutaSalidaX, nombreRed);
		strcat(rutaSalidaX, nombreEstacion);
		strcat(rutaSalidaX, ejeX);
		strcat(rutaSalidaX, nombreArchivo);
		strcat(rutaSalidaX, ext2);
		
		strcat(rutaSalidaY, nombreRed);
		strcat(rutaSalidaY, nombreEstacion);
		strcat(rutaSalidaY, ejeY);
		strcat(rutaSalidaY, nombreArchivo);
		strcat(rutaSalidaY, ext2);
		
		strcat(rutaSalidaZ, nombreRed);
		strcat(rutaSalidaZ, nombreEstacion);
		strcat(rutaSalidaZ, ejeZ);
		strcat(rutaSalidaZ, nombreArchivo);
		strcat(rutaSalidaZ, ext2);
	
		//Abre el archivo binario de entrada y crea el archivo de texto de salida:
		fileX = fopen (rutaSalidaX, "wb");
		fileY = fopen (rutaSalidaY, "wb");
		fileZ = fopen (rutaSalidaZ, "wb");
		free(rutaSalidaX);
		free(rutaSalidaY);
		free(rutaSalidaZ);
		
		//Escritura de datos en los archivos de texto:
		fprintf(fileX, "Eje: Norte\n");
		fprintf(fileX, "Periodo de muestreo (ms): %d\n", (periodoMuestreo));
		fprintf(fileX, "Tiempo de inicio: ");
		fprintf(fileX, "%0.2d:", tramaDatos[tramaSize-3]);
		fprintf(fileX, "%0.2d:", tramaDatos[tramaSize-2]);
		fprintf(fileX, "%0.2d ", tramaDatos[tramaSize-1]);
		fprintf(fileX, "%0.2d/", tramaDatos[tramaSize-6]);
		fprintf(fileX, "%0.2d/", tramaDatos[tramaSize-5]);
		fprintf(fileX, "%0.2d\n", tramaDatos[tramaSize-4]);
		fprintf(fileX, "Duracion (seg): 300\n");
		fprintf(fileX, "\n");
		
		fprintf(fileY, "Eje: Este\n");
		fprintf(fileY, "Periodo de muestreo (ms): %d\n", (periodoMuestreo));
		fprintf(fileY, "Tiempo de inicio: ");
		fprintf(fileY, "%0.2d:", tramaDatos[tramaSize-3]);
		fprintf(fileY, "%0.2d:", tramaDatos[tramaSize-2]);
		fprintf(fileY, "%0.2d ", tramaDatos[tramaSize-1]);
		fprintf(fileY, "%0.2d/", tramaDatos[tramaSize-6]);
		fprintf(fileY, "%0.2d/", tramaDatos[tramaSize-5]);
		fprintf(fileY, "%0.2d\n", tramaDatos[tramaSize-4]);	
		fprintf(fileY, "Duracion (seg): 300\n");		
		fprintf(fileY, "\n");
		
		fprintf(fileZ, "Eje: Z\n");
		fprintf(fileZ, "Periodo de muestreo (ms): %d\n", (periodoMuestreo));
		fprintf(fileZ, "Tiempo de inicio: ");
		fprintf(fileZ, "%0.2d:", tramaDatos[tramaSize-3]);
		fprintf(fileZ, "%0.2d:", tramaDatos[tramaSize-2]);
		fprintf(fileZ, "%0.2d ", tramaDatos[tramaSize-1]);
		fprintf(fileZ, "%0.2d/", tramaDatos[tramaSize-6]);
		fprintf(fileZ, "%0.2d/", tramaDatos[tramaSize-5]);
		fprintf(fileZ, "%0.2d\n", tramaDatos[tramaSize-4]);	
		fprintf(fileZ, "Duracion (seg): 300\n");		
		fprintf(fileZ, "\n");
		
		while (contMuestras<300){														//Se almacena el equivalente a 5 minutos de muestras (300 segundos)
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
								fprintf(fileX, "%2.8f\n", aceleracion);	 				//Escribe en el archivo fileX los datos del eje x							
							}
							if (contEje==1){
								fprintf(fileY, "%2.8f\n", aceleracion);	 				//Escribe en el archivo fileY los datos del eje y							
							}
							if (contEje==2){
								fprintf(fileZ, "%2.8f\n", aceleracion);	 				//Escribe en el archivo fileZ los datos del eje z													
								banGuardar = 0;							 				//Despues de que termina de guardar la muestra del eje Z limpia la bandera banGuardar
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
		fclose (fileY);
		fclose (fileZ);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Final 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	fclose (lf);
	printf("\nTerminado\n");
	printf("Pulse cualquier tecla para continuar...");
	getch();
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

