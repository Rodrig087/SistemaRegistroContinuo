//Compilar:
//gcc PAE_V9.c -o muestrearV9 -lbcm2835 -lwiringPi -lpthread

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <pthread.h>
#include <time.h>
#include <string.h>


//Declaracion de constantes
#define P2 2
#define P1 0
#define NUM_MUESTRAS 199
#define NUM_ELEMENTOS 2506
#define TIEMPO_SPI 10
#define NUM_CICLOS 5


//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short banFile;
unsigned short banNewFile;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[NUM_ELEMENTOS];
unsigned char tramaLarga[NUM_ELEMENTOS*NUM_CICLOS];
unsigned char trama[NUM_ELEMENTOS];
unsigned short tiempoSPI;

unsigned char menu;

FILE *fp;
char path[30];
char ext[8];
char nombreArchivo[16];
unsigned int timeNewFile[2] = {23, 59};											//Variable para configurar la hora a la que se desea generar un archivo nuevo	
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
pthread_t h1;


//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevoCiclo();
void *thGrabarVector(void * arg);
void GuardarVector(unsigned char* tramaD, unsigned int contador);
void CrearArchivo();
void IniciarMuestreo();
void DetenerMuestreo();
void ObtenerTiempoGPS();
void MostrarTiempoGPS();

int main(void) {

  printf("Iniciando...\n");
  i = 0;
  x = 0;
  contMuestras = 0;
  banLinea = 0;
  banInicio = 0;
  banFile = 0;
  banNewFile = 0;
  numBytes = 0;
  contCiclos = 0;
  contador = 0;  

  ConfiguracionPrincipal();
  
  printf("Menu: \n");
  printf("     i => Iniciar muestreo \n");
  printf("     d => Detener muestreo \n");
  printf("     h => Obtener hora del GPS \n");
  printf("     s => Salir del programa \n");
  
  while(1){
	  
	menu = getchar();
	
	switch(menu){
		case 'i':
			IniciarMuestreo();
			break;
		case 'd':
			DetenerMuestreo();
			break;
		case 'h':
			ObtenerTiempoGPS();
			//MostrarTiempoGPS();
			break;
		case 's':
			DetenerMuestreo();
			printf("Adios\n");
			bcm2835_spi_end();
			bcm2835_close();
			exit(0);
			break;
		
	}
	
  }
  
  
 
  return 0;

 }


int ConfiguracionPrincipal(){
	
	//Reinicia el modulo SPI
	system("sudo rmmod  spi_bcm2835");
	bcm2835_delayMicroseconds(500);
	system("sudo modprobe spi_bcm2835");

    //Configuracion libreria bcm2835:
	if (!bcm2835_init()){
		printf("bcm2835_init fallo. Ejecuto el programa como root?\n");
		return 1;
    }
    if (!bcm2835_spi_begin()){
		printf("bcm2835_spi_begin fallo. Ejecuto el programa como root?\n");
		return 1;
    }

    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//Clock divider RPi 2		
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);					//Clock divider RPi 3
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
	
	//Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
	wiringPiISR (P1, INT_EDGE_RISING, NuevoCiclo);
	wiringPiISR (P2, INT_EDGE_RISING, MostrarTiempoGPS);
	
	printf("Configuracion completa\n");
	
}


void IniciarMuestreo(){
	printf("Iniciando el muestreo...\n");
	bcm2835_spi_transfer(0xA0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xA0);	
	banNewFile=0;							//Limpia esta bandera para crear un archivo nuevo cada vez que se inicia el muestreo
}

void DetenerMuestreo(){
	printf("Deteniendo el muestreo...\n");
	bcm2835_spi_transfer(0xAF);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xAF);	
}

void ObtenerTiempoGPS(){
	printf("Obteniendo hora del GPS...\n");
	bcm2835_spi_transfer(0xC0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xC0);		
}

void MostrarTiempoGPS(){
	printf("Hora GPS:\n");	
	for (i=0;i<8;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaDatos[i] = buffer;													//Guarda la hora y fecha devuelta por el dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
    bcm2835_spi_transfer(0xC1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	for (i=1;i<7;i++){
		if (i<3){
			printf("%0.2d:",tramaDatos[i]);
		} else {
			if (i<6){
				printf("%0.2d/",tramaDatos[i]);
			} else {
				printf("%0.2d\n",tramaDatos[i]);	
			}
		} 		
	} 
}


void NuevoCiclo(){
	
	printf("Nuevo ciclo\n");
	CrearArchivo();
	contCiclos++;
	
	if (contCiclos==NUM_CICLOS){
		contCiclos = 0;
		pthread_create (&h1, NULL, thGrabarVector, (void*)tramaLarga);   		//Crea un hilo h1 para guardar el vector tramaDatos en el archivo binario
		pthread_join (h1, NULL);
	}

	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

    for (i=0;i<2506;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaDatos[i] = buffer;													//Guarda el delimitador de inicio de trama, el numero de muestra y los 9 bytes de datos
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	GuardarVector(tramaDatos, contCiclos);

    banLinea = 1;
	banInicio = 0;
    contMuestras = 1;
	
	//contador++;

}


void CrearArchivo(){
	
	//Obtiene la hora y la fecha del sistema 
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);
	
	//Cambia el estado de la bandera faltando un minuto para que se cumpla la hora fijada para la creacion de un archivo nuevo
	if ((tm->tm_hour==timeNewFile[0])&&(tm->tm_min==timeNewFile[1]-1)){
		banNewFile = 2;	
	}
	
	//Verifica si llego la hora/minuto que se configuro para cambiar el estado de la bandera de nuevo archivo y asi permitir la creacion de un nuevo archivo binario
	if ((tm->tm_hour==timeNewFile[0])&&(tm->tm_min==timeNewFile[1])&&(banNewFile==2)){
		fclose (fp);
		banNewFile = 0;
		printf("Archivo creado\n");
	}
	
	//Verifica que la bandera de nuevo archivo sea igual a cero
	//Si al invocar a esta funcion encuentra que ya existe un archivo con el nombre de la fecha actual, lo abrira y seguira escribiendo a continuacion (esto debido al comando "ab" en la funcion fopen)
	//Si al invocar a esta funcion no encuentra ningun archivo con el nombre de la fecha actual creara un archivo con ese nombre. 
	if (banNewFile==0){
		
		//Establece la fecha y hora actual como nombre que tendra el archivo binario 
		strftime(nombreArchivo, 20, "%Y%m%d%H%M", tm);
		//printf ("Se creo el archivo: %s.dat\n", nombreArchivo);
		
		//Asigna espacio en la memoria para el nombre completo de la ruta
		char *path = malloc(strlen(nombreArchivo)+5+13);
		
		//Asigna el nombre de la ruta y la extencion a los array de caracteres
		strcpy(ext, ".dat");
		strcpy(path, "./Resultados/");
		
		//Realiza la concatenacion de array de caracteres
		strcat(path, nombreArchivo);
		strcat(path, ext);
		
		//Abre o crea el archivo binario
		fp = fopen (path, "ab+");	
		
		//Cambia el valor de la bandera de nuevo archivo para que ignore esta funcion en la siguientes muestras y libera la memoria reservada para el nombre de la ruta 
		banNewFile = 1;	
		free(path);	
		printf("   Archivo abierto\n");	
	}
 
}


//Esta funcion sirve para almacenar las tramas de 1 segundo en una sola trama larga de x segundos
void GuardarVector(unsigned char* tramaD, unsigned int contador){
	
	for (i=0; i<NUM_ELEMENTOS; i++){
		x = (contador*NUM_ELEMENTOS)+i;
		tramaLarga[x] = tramaD[i]; 
	}
	printf("   Datos recibidos\n");
}


//Esta funcion sirve para guardar la trama larga de x segundos en el archivo binario
void *thGrabarVector(void *arg) {
	
	char *trama = (char*)arg;													//Se realiza un casting, se convierte la variable arg de puntero tipo void a puntero tipo char
	unsigned int outFwrite;
	
	if (fp!=NULL){
		do{
		outFwrite = fwrite(trama, sizeof(char), (NUM_ELEMENTOS*NUM_CICLOS), fp);	
		} while (outFwrite!=(NUM_ELEMENTOS*NUM_CICLOS));
		fflush(fp);
		banFile = 1;
	} else {
		banFile = 0;
	}
	printf("      Datos guardados\n");	
	return NULL;
}



//Compilar:
//gcc PAE_V7.c -o muestrear -lbcm2835 -lwiringPi -lpthread
