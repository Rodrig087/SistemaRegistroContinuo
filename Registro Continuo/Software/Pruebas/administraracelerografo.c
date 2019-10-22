//Compilar:
//gcc administraracelerografo.c -o adm_acelerografo -lbcm2835 -lwiringPi -lpthread

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <unistd.h>


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
char comando[40];
char dateGPS[22];
//unsigned int timeNewFile[2] = {17, 30};											//Variable para configurar la hora a la que se desea generar un archivo nuevo	
unsigned int timeNewFile[2] = {0, 0};	
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
pthread_t h1;

int operador;
unsigned short tgps;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevoCiclo();
void GuardarVector(unsigned char* tramaD);
void CrearArchivo();
void IniciarMuestreo();
void DetenerMuestreo();
void ConfigurarGPS();
void ObtenerTiempoGPS();
void MostrarTiempoGPS();


int main(int argc, char *argv[]) {

  i = 0;
  x = 0;
  contMuestras = 0;
  banFile = 0;
  banNewFile = 0;
  numBytes = 0;
  contCiclos = 0;
  contador = 0;
  tgps = 0;
  
  ConfiguracionPrincipal();
  operador = atoi(argv[1]);  
    
  if (operador==1){
	DetenerMuestreo();	
  } else if (operador==2){
	DetenerMuestreo(); 
	bcm2835_delayMicroseconds(500);
	IniciarMuestreo(); 
  } else if (operador==3){
	DetenerMuestreo();
	bcm2835_delayMicroseconds(500);
	ObtenerTiempoGPS();
	while (tgps==0){} 
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
	wiringPiISR (P2, INT_EDGE_RISING, MostrarTiempoGPS);
	
	//printf("Configuracion completa\n");
	
}

void IniciarMuestreo(){
	printf("Iniciando el muestreo...\n");
	bcm2835_spi_transfer(0xA0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xA0);	
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
							
	printf("%0.2d:",tiempoGPS[4]);		//hh
	printf("%0.2d:",tiempoGPS[5]);		//mm
	printf("%0.2d ",tiempoGPS[6]);		//ss
	printf("%0.2d/",tiempoGPS[1]);		//dd
	printf("%0.2d/",tiempoGPS[2]);		//MM
	printf("%0.2d\n",tiempoGPS[3]);		//aa
	
	//Configura el reloj interno de la RPi con la hora recuperada del GPS:
	strcpy(comando, "sudo date --set ");	//strcpy( <variable_destino>, <cadena_fuente> )
	//'2019-09-13 17:45:00':
	dateGPS[0] = 0x27;						//'
	dateGPS[1] = '2';
	dateGPS[2] = '0';
	dateGPS[3] = (tiempoGPS[3]/10)+48;		//aa: (19/10)+48 = 49 = '1'
	dateGPS[4] = (tiempoGPS[3]%10)+48;		//    (19%10)+48 = 57 = '9'
	dateGPS[5] = '-';	
	dateGPS[6] = (tiempoGPS[2]/10)+48;		//MM
	dateGPS[7] = (tiempoGPS[2]%10)+48;
	dateGPS[8] = '-';
	dateGPS[9] = (tiempoGPS[1]/10)+48;		//dd
	dateGPS[10] = (tiempoGPS[1]%10)+48;
	dateGPS[11] = ' ';
	dateGPS[12] = (tiempoGPS[4]/10)+48;		//hh
	dateGPS[13] = (tiempoGPS[4]%10)+48;
	dateGPS[14] = ':';
	dateGPS[15] = (tiempoGPS[5]/10)+48;		//mm
	dateGPS[16] = (tiempoGPS[5]%10)+48;
	dateGPS[17] = ':';
	dateGPS[18] = (tiempoGPS[6]/10)+48;		//ss
	dateGPS[19] = (tiempoGPS[6]%10)+48;
	dateGPS[20] = 0x27;
	dateGPS[21] = '\0';
	
	strcat(comando, dateGPS);
	system(comando);
	///system("date");
	printf("Hora del sistema actualizada");
	
	tgps = 1;
		
}