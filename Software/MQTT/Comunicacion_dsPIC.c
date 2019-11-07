//Compilar:
//gcc Comunicacion_dsPIC.c -o muestrear -lbcm2835 -lwiringPi -lpthread

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
unsigned char tramaInSPI[20];
unsigned char tramaDatos[NUM_ELEMENTOS];
unsigned char tramaLarga[NUM_ELEMENTOS*NUM_CICLOS];
unsigned char trama[NUM_ELEMENTOS];
unsigned short tiempoSPI;

FILE *fp;
char path[30];
char ext[8];
char nombreArchivo[16];
unsigned int timeNewFile[2] = {23, 59};											//Variable para configurar la hora a la que se desea generar un archivo nuevo	
unsigned short banNewFile;

pthread_t h1;
									


//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevoCiclo();
void *thGrabarVector(void * arg);
void GuardarVector(unsigned char* tramaD, unsigned int contador);
void CrearArchivo();


int main(void) {

  printf("Iniciando...\n");
  piHiPri (99);
  i = 0;
  x = 0;
  banLinea = 0;
  banInicio = 0;
  banFile = 0;
  banNewFile = 0;
  numBytes = 0;
  
  ConfiguracionPrincipal();

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
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);					//Clock divider RPi 3
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
	
	//Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
    wiringPiISR (P1, INT_EDGE_RISING, &NuevoCiclo);
	
	printf("Configuracion completa\n");
	
}


void NuevoCiclo(){
	
	printf("Nuevo ciclo\n");
	CrearArchivo();

	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

    for (i=0;i<2506;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaDatos[i] = buffer;													//Guarda la trama con los datos correspondientes a 1 segundo de muestreo
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	//Aqui debo enviarle el vector tramaDatos al script de Python para que lo guarde y lo envie por MQTT
	//GuardarVector(tramaDatos, contCiclos);

    banLinea = 1;
	banInicio = 0;
   
}







