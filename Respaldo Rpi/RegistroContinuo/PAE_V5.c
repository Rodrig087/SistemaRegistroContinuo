#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <pthread.h>


//Declaracion de constantes
#define P2 2
#define P1 0
#define NUM_MUESTRAS 199
#define NUM_ELEMENTOS 2005
#define TIEMPO_SPI 100
#define NUM_CICLOS 5


//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short banFile;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[NUM_ELEMENTOS];
unsigned char tramaLarga[NUM_ELEMENTOS*NUM_CICLOS];
unsigned char trama[NUM_ELEMENTOS];
unsigned short tiempoSPI;
FILE *fp;
unsigned short contCiclos;
unsigned short contador;
pthread_t h1;


//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevaLinea();
void NuevaMuestra();
void *thGrabarVector(void * arg);
void GuardarVector(unsigned char* tramaD, unsigned int contador);


int main(void) {

  piHiPri (99);
  i = 0;
  x = 0;
  contMuestras = 0;
  banLinea = 0;
  banInicio = 0;
  banFile = 0;
  numBytes = 0;
  contCiclos = 0;
  contador = 0;
 
  ConfiguracionPrincipal();
 
  while(1){

  }

  bcm2835_spi_end();
  bcm2835_close();
  fclose (fp);

  return 0;
 
 }


int ConfiguracionPrincipal(){
	
	fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.dat", "ab");
	
	//Cierra todo si algo esta abierto
	if (bcm2835_spi_begin()){
		bcm2835_spi_end();
    }
	if (bcm2835_init()){
		bcm2835_close();
    }
	
    //Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
    wiringPiISR (P1, INT_EDGE_RISING, &NuevaLinea);
    wiringPiISR (P2, INT_EDGE_RISING, &NuevaMuestra);

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
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
	
}


void NuevaLinea(){
	
	contCiclos++;
	if (contCiclos==NUM_CICLOS){
		contCiclos = 0;
		pthread_create (&h1, NULL, thGrabarVector, (void*)tramaLarga);   	//Crea un hilo h1 para guardar el vector tramaDatos en el archivo binario
		pthread_join (h1, NULL);
	}

	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

    for (i=0;i<11;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaInSPI[i] = buffer;													//Guarda el delimitador de inicio de trama, el numero de muestra y los 9 bytes de datos
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	for (i=0;i<10;i++){
		tramaDatos[i] = tramaInSPI[i+1];		
	}

    banLinea = 1;
	banInicio = 0;
    contMuestras = 1;
	
	contador++;

}


void NuevaMuestra(){

    if (banLinea==1){

		if (contMuestras<NUM_MUESTRAS){
			numBytes = 11;
		} else {
			numBytes = 16;	
			banInicio = 1;
		    banLinea = 0;			
		}

		bcm2835_spi_transfer(0xB0);                                             //Envia el delimitador de inicio de trama
		bcm2835_delayMicroseconds(TIEMPO_SPI);                                       

		for (i=0;i<numBytes;i++){
			buffer = bcm2835_spi_transfer(0x00);
			tramaInSPI[i] = buffer;
			bcm2835_delayMicroseconds(TIEMPO_SPI);
		}

		bcm2835_spi_transfer(0xB1);                                             //Envia el delimitador de final de trama
		bcm2835_delayMicroseconds(TIEMPO_SPI);

		if (numBytes==11){														//Guardo 10 muestras
		   for (i=1;i<11;i++){
		       x = (contMuestras*10)+i-1;
			   tramaDatos[x] = tramaInSPI[i];		
		   }				
		} else {																//Guardo 15 muestras
		   for (i=1;i<16;i++){
		       x = (contMuestras*10)+i-1;
			   tramaDatos[x] = tramaInSPI[i];
		   }
		   tramaDatos[1] = contador;
		   GuardarVector(tramaDatos, contCiclos);
		}

		contMuestras++;

    }
	
}


void GuardarVector(unsigned char* tramaD, unsigned int contador){
	
	for (i=0; i<NUM_ELEMENTOS; i++){
		x = (contador*NUM_ELEMENTOS)+i;
		tramaLarga[x] = tramaD[i]; 
	}
	
}


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
		
	return NULL;
	
}

