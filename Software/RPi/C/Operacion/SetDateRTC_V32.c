//Compilar:
//gcc SetDateRTC_V32.c -o /home/pi/Ejecutables/setdatertc -lbcm2835 -lwiringPi 
//gcc SetDateRTC_V32.c -o setdatertc -lbcm2835 -lwiringPi 

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>
#include <string.h>
#include <unistd.h>


//Declaracion de constantes
#define P2 2
#define P1 0
#define MCLR 28																	//Pin 38 GPIO						
#define TEST 26 
#define NUM_MUESTRAS 199
#define NUM_ELEMENTOS 2506
#define TIEMPO_SPI 10
#define NUM_CICLOS 1
#define FreqSPI 2000000


//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banFile;
unsigned short banNewFile;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tiempoPIC[8];
unsigned char tiempoLocal[8];
unsigned char tramaDatos[NUM_ELEMENTOS];

FILE *fp;
FILE *ftmp;
FILE *fTramaTmp;
char path[30];
char ext[8];
char nombreArchivo[16];
char comando[40];
char dateGPS[22];
unsigned int timeNewFile[2] = {0, 0};											//Variable para configurar la hora a la que se desea generar un archivo nuevo (hh, mm)		
unsigned short confGPS[2] = {0, 1};							                    //Parametros que se pasan para configurar el GPS (conf, NMA) cuando conf=1 realiza la configuracion del GPS y se realiza una sola vez la primera vez que es utilizado 
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
short fuenteTiempoPic;

//Declaracion de funciones
int ConfiguracionPrincipal();
void ObtenerOperacion();														//C:0xA0    F:0xF0																//C:0xA3	F:0xF3
void EnviarTiempoLocal();														//C:0xA4	F:0xF4
void ObtenerTiempoPIC();														//C:0xA5	F:0xF5


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
	EnviarTiempoLocal();
	sleep(5);
	
    
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
	//bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//Clock divider RPi 2
	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);					//Clock divider RPi 3		
    bcm2835_spi_set_speed_hz(FreqSPI);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
		
	//Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
	pinMode(MCLR, OUTPUT);
	pinMode(TEST, OUTPUT);
	wiringPiISR (P1, INT_EDGE_RISING, ObtenerOperacion);
		
	printf("Configuracion completa\n");
	
}

void ObtenerOperacion(){
	
	bcm2835_spi_transfer(0xA0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	buffer = bcm2835_spi_transfer(0x00);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF0);	

	//Aqui se selecciona el tipo de operacion que se va a ejecutar 
	if (buffer==0xB2){
		printf("Recupero 0xB2\n");
		ObtenerTiempoPIC(); 
	}
	
}

void EnviarTiempoLocal(){
	
	//Obtiene la hora y la fecha del sistema:
	printf("Hora local: ");
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);
	tiempoLocal[0] = tm->tm_mday;												//Dia del mes (0-31)
	tiempoLocal[1] = tm->tm_mon+1;												//Mes desde Enero (0-11)
	tiempoLocal[2] = tm->tm_year-100;											//Anio (contado desde 1900)
	tiempoLocal[3] = tm->tm_hour;												//Hora
	tiempoLocal[4] = tm->tm_min;												//Minuto
	tiempoLocal[5] = tm->tm_sec;												//Segundo 
	for (i=0;i<6;i++){
		printf("%0.2d ",tiempoLocal[i]);	
	}
	printf("\n");	

	bcm2835_spi_transfer(0xA4);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI); 
	for (i=0;i<6;i++){
        bcm2835_spi_transfer(tiempoLocal[i]);							//Envia los 6 datos de la trama tiempoLocal al dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
	bcm2835_spi_transfer(0xF4);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

}

void ObtenerTiempoPIC(){
	
	printf("Hora dsPIC: ");	
	bcm2835_spi_transfer(0xA5);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	fuenteTiempoPic = bcm2835_spi_transfer(0x00);								//Recibe el byte que indica la fuente de tiempo del PIC
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	for (i=0;i<6;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tiempoPIC[i] = buffer;													//Guarda la hora y fecha devuelta por el dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

	bcm2835_spi_transfer(0xF5);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	if (fuenteTiempoPic==0){
		printf("RTC ");
	} 
	if (fuenteTiempoPic==1){
		printf("GPS ");
	}
	
	printf("%0.2d:",tiempoPIC[3]);		//hh
	printf("%0.2d:",tiempoPIC[4]);		//mm
	printf("%0.2d ",tiempoPIC[5]);		//ss
	printf("%0.2d/",tiempoPIC[0]);		//dd
	printf("%0.2d/",tiempoPIC[1]);		//MM
	printf("%0.2d\n",tiempoPIC[2]);		//aa
		
}















