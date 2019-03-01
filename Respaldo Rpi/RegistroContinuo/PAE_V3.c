#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 199
#define TIEMPO_SPI 100

//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banLinea;
unsigned short banInicio;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tramaInSPI[20];
unsigned char tramaDatos[15+(NUM_MUESTRAS*10)];
unsigned short tiempoSPI;
FILE *fp;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevaLinea();
void NuevaMuestra();
void GrabarVector(unsigned char* trama, unsigned short tramaSize);


int main(void) {

  ConfiguracionPrincipal();
  
  piHiPri (99);
  
  i = 0;
  x = 0;
  contMuestras = 0;
  banLinea = 0;
  banInicio = 0;
  numBytes = 0;
  
  while(1){

  }

  bcm2835_spi_end();
  bcm2835_close();
  fclose (fp);
  
  return 0;
  
 }


int ConfiguracionPrincipal(){
	
	fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.dat", "wb");
		
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
    bcm2835_spi_set_speed_hz(3000000);											
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
	
}


void NuevaLinea(){
	
	if (banInicio==1){
		GrabarVector(tramaDatos,(15+(NUM_MUESTRAS*10)));                      //Guarda la muestra en cada inicio de linea
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

}


void NuevaMuestra(){

    if (banLinea==1){

		if (contMuestras<NUM_MUESTRAS){
			numBytes = 11;
		}

		if (contMuestras==NUM_MUESTRAS) {
			numBytes = 16;		
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
		}
				
		if (contMuestras==NUM_MUESTRAS) {
			banInicio = 1;
			banLinea = 0;
		}
	
		contMuestras++;

    }

}


void GrabarVector(unsigned char* trama, unsigned short tramaSize) {
	
	if (fp){
		//fwrite(vec, sizeof(int), TAM, arch);
		fwrite(trama, sizeof(char), tramaSize, fp);       
    }
	
}

