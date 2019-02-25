#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P1 0
#define P2 2
#define NUM_MUESTRAS 199

//Declaracion de variables
unsigned short i = 0;
unsigned short x = 0;
unsigned short buffer = 0;
unsigned short banLinea = 0;
unsigned short numBytes = 0;
volatile unsigned short contMuestras;
unsigned char tramaInSPI1[20];
unsigned char tramaInSPI2[20];
unsigned short tiempoSPI = 50;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevaLinea();
void NuevaMuestra();


int main(void) {

  ConfiguracionPrincipal();

  while(1){

  }

  bcm2835_spi_end();
  bcm2835_close();
  return 0;
 }


int ConfiguracionPrincipal(){

    //Configuracion libreria WiringPi
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
    wiringPiISR (P1, INT_EDGE_RISING, &NuevaLinea);
    wiringPiISR (P2, INT_EDGE_RISING, &NuevaMuestra);

    //Configuracion libreria bcm2835
//    bcm2835_init();
//    bcm2835_spi_begin();

    if (!bcm2835_init())
    {
      printf("bcm2835_init failed. Are you running as root??\n");
      return 1;
    }

    if (!bcm2835_spi_begin())
    {
      printf("bcm2835_spi_begin failed. Are you running as root??\n");
      return 1;
    }

    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);

}


void NuevaLinea(){

    bcm2835_init();
    bcm2835_spi_begin();

    bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(tiempoSPI);                                       //Delay 100 useg

    for (i=0;i<11;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaInSPI1[i] = buffer;
        bcm2835_delayMicroseconds(tiempoSPI);
    }

    bcm2835_spi_transfer(0xB1);                                                //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(tiempoSPI);

    printf("************\n");
    for (i=1;i<11;i++){							       //Descarta el primer byte (0xFF)
        printf( "%d\n", tramaInSPI1[i]);
    }
    printf("******\n");

    banLinea = 1;
    contMuestras = 1;

}


void NuevaMuestra(){

    if (banLinea==1){

	if (contMuestras<NUM_MUESTRAS){
		numBytes = 11;
	}

	if (contMuestras==NUM_MUESTRAS) {
		numBytes = 16;
	}

	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
	bcm2835_delayMicroseconds(tiempoSPI);                                       //Delay 100 useg

	for (x=0;x<numBytes;x++){
		buffer = bcm2835_spi_transfer(0x00);
		tramaInSPI2[x] = buffer;
		bcm2835_delayMicroseconds(tiempoSPI);
	}

	bcm2835_spi_transfer(0xB1);                                                //Envia el delimitador de final de trama
	bcm2835_delayMicroseconds(tiempoSPI);

	printf("******\n");
	for (x=1;x<numBytes;x++){
		printf( "%d\n", tramaInSPI2[x]);
	}
	printf("******\n");

	if (contMuestras==NUM_MUESTRAS) {
		bcm2835_spi_end();
          	bcm2835_close();
		banLinea = 0;
	}

	contMuestras++;

    }

}
