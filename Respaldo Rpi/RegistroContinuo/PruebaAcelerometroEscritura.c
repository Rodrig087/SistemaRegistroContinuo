#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P1 0
#define P2 2
#define NUM_MUESTRAS 199
#define TIEMPO_SPI 200

//Declaracion de variables
unsigned short i;
unsigned short buffer;
unsigned short banLinea;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tramaInSPI[20];
unsigned short tiempoSPI;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevaLinea();
void NuevaMuestra();
void GuardarMuestra(unsigned short linea, unsigned char* trama, unsigned short tramaSize);


int main(void) {

  ConfiguracionPrincipal();
  
  i = 0;
  contMuestras = 0;
  banLinea = 0;
  numBytes = 0;
  
  while(1){

  }

  bcm2835_spi_end();
  bcm2835_close();
  return 0;
  
 }


int ConfiguracionPrincipal(){

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
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//7.8125MHz
    bcm2835_spi_set_speed_hz(1000000);											
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);

}


void NuevaLinea(){

    //bcm2835_init();
    //bcm2835_spi_begin();

    bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

    for (i=0;i<11;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tramaInSPI[i] = buffer;
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	GuardarMuestra(1,tramaInSPI,11);

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
	bcm2835_delayMicroseconds(TIEMPO_SPI);                                       

	for (i=0;i<numBytes;i++){
		buffer = bcm2835_spi_transfer(0x00);
		tramaInSPI[i] = buffer;
		bcm2835_delayMicroseconds(TIEMPO_SPI);
	}

	bcm2835_spi_transfer(0xB1);                                                //Envia el delimitador de final de trama
	bcm2835_delayMicroseconds(TIEMPO_SPI);

	if (numBytes==11){
		GuardarMuestra(0,tramaInSPI,11);
	} else {
		GuardarMuestra(0,tramaInSPI,16);
	}
	
	if (contMuestras==NUM_MUESTRAS) {
		//bcm2835_spi_end();
        //bcm2835_close();
		banLinea = 0;
	}

	contMuestras++;

    }

}


void GuardarMuestra(unsigned short linea, unsigned char* trama, unsigned short tramaSize) {
    FILE *fp;
    fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.txt", "ab");
    if (fp){
		if (linea==1){
			fprintf(fp, "\n");
		}
        for (i=1;i<tramaSize;i++){
			if (i==1){
			    fprintf(fp, " %d ", trama[i]);						
			} else {
				fprintf(fp, "%d", trama[i]);
			}
        }
        fclose (fp);
    }
}

