//Compilar:
//gcc PAE_V10.c -o muestrearV10 -lbcm2835 -lwiringPi -lpthread

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
#define NUM_CICLOS 1


//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banFile;
unsigned short banNewFile;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tiempoGPS[8];
unsigned char tramaDatos[NUM_ELEMENTOS];

FILE *fp;
char path[30];
char ext[8];
char nombreArchivo[16];
//unsigned int timeNewFile[2] = {17, 1};											//Variable para configurar la hora a la que se desea generar un archivo nuevo	
unsigned int timeNewFile[2] = {0, 0};	
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
pthread_t h1;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevoCiclo();
void GuardarVector(unsigned char* tramaD);
void CrearArchivo();
void IniciarMuestreo();
void DetenerMuestreo();
void ObtenerTiempoGPS();
void MostrarTiempoGPS();

int main(void) {

  printf("Iniciando...\n");
  
  //Inicializa las variables:
  i = 0;
  x = 0;
  contMuestras = 0;
  banFile = 0;
  banNewFile = 0;
  numBytes = 0;
  contCiclos = 0;
  contador = 0;  

  ConfiguracionPrincipal();
  CrearArchivo();	
  DetenerMuestreo();
  ObtenerTiempoGPS();
   
  
  while(1){	
  }
  
  bcm2835_spi_end();
  bcm2835_close();
 
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
	//banNewFile=0;							//Limpia esta bandera para crear un archivo nuevo cada vez que se inicia el muestreo
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
	printf("Hora GPS: ");	
	for (i=0;i<8;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tiempoGPS[i] = buffer;													//Guarda la hora y fecha devuelta por el dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
    bcm2835_spi_transfer(0xC1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
							
	printf("%0.2d:",tiempoGPS[4]);
	printf("%0.2d:",tiempoGPS[5]);
	printf("%0.2d ",tiempoGPS[6]);
	printf("%0.2d/",tiempoGPS[1]);
	printf("%0.2d/",tiempoGPS[2]);
	printf("%0.2d\n",tiempoGPS[3]);
		
	IniciarMuestreo();
	
}

void NuevoCiclo(){
	
	//printf("Nuevo ciclo\n");
	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

	for (i=0;i<2506;i++){
        buffer = bcm2835_spi_transfer(0x00);									//Envia 2506 dummy bytes para recuperar los datos de la trama enviada desde el dsPIC
        tramaDatos[i] = buffer;													//Guarda los datos en el vector tramaDatos 
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	GuardarVector(tramaDatos);													//Guarda la el vector tramaDatos en el archivo binario
	CrearArchivo();																//Crea un archivo nuevo si se cumplen las condiciones
}


void CrearArchivo(){
	
	//printf("   Entro\n");	
	
	//Obtiene la hora y la fecha del sistema:
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);
	//Cambia el estado de la bandera faltando un minuto para que se cumpla la hora fijada para la creacion de un archivo nuevo:
	if ((tm->tm_hour==23)&&((tm->tm_min==59))){
    //if ((tm->tm_hour==timeNewFile[0])&&((tm->tm_min==timeNewFile[1]-1))){
		banNewFile = 2;	
	}
	//Verifica si llego la hora/minuto que se configuro para cambiar el estado de la bandera de nuevo archivo y asi permitir la creacion de un nuevo archivo binario
	if ((banNewFile==2)&&(tm->tm_hour==timeNewFile[0])&&(tm->tm_min==timeNewFile[1])){
		fclose (fp);
		DetenerMuestreo();
		ObtenerTiempoGPS();
		banNewFile = 0;
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


//Esta funcion sirve para guardar en el archivo binario las tramas de 1 segundo recibidas
void GuardarVector(unsigned char* tramaD){
	
	unsigned int outFwrite;
	
	if (fp!=NULL){
		do{
		outFwrite = fwrite(tramaD, sizeof(char), NUM_ELEMENTOS, fp);	
		} while (outFwrite!=NUM_ELEMENTOS);
		fflush(fp);
	}
	
}




