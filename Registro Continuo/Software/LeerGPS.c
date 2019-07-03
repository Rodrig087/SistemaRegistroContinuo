//Compilar:
//gcc LeerGPS.c -o leergps -lbcm2835 -lwiringPi -lpthread


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
#define NUM_ELEMENTOS 2505
#define TIEMPO_SPI 5
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
void RecuperarHoraGPS();
void Iniciar();


int main(void) {
	
	piHiPri (99);
	
	ConfiguracionPrincipal();
	Iniciar();

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
	
    //Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
    wiringPiISR (P1, INT_EDGE_RISING, &RecuperarHoraGPS);

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
	
}


void RecuperarHoraGPS(){
	
	printf("Hola\n");
	
	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

    for (i=0;i<6;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaInSPI[i] = buffer;													//Guarda el delimitador de inicio de trama, el numero de muestra y los 9 bytes de datos
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xBF);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	/*tramaInSPI[0] = 12;                                                            //Hora
    tramaInSPI[1] = 12;                                                            //Minuto
    tramaInSPI[2] = 0;                                                             //Segundo
    tramaInSPI[3] = 1;                                                             //Dia
    tramaInSPI[4] = 1;                                                             //Mes
    tramaInSPI[5] = 19;                                                            //Año*/
	
	for (i=0;i<6;i++){
		printf("%d\n",tramaInSPI[i]);
	}
}


void Iniciar(){
	
	bcm2835_spi_transfer(0xA0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	
}
