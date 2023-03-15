//Compilar:
//gcc RPiPulso.c -o rpipulso -lbcm2835 -lwiringPi 

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>


//Declaracion de constantes
#define LEDTEST 29 																//Pin 40 GPIO	

//Declaracion de variables
int segundo;
int milisegundo;

//Declaracion de funciones
int ConfiguracionPrincipal();

//**************************************************************************************************************************************
//************************************************************** Principal *************************************************************
//**************************************************************************************************************************************
int main() {
		
	//Configuracion principal:
	ConfiguracionPrincipal();
	
	segundo = 0;
	
	//digitalWrite (LEDTEST, HIGH);
	
	//while(1){
		
		/*digitalWrite (LEDTEST, HIGH);
		delay(100);
		digitalWrite (LEDTEST,  LOW); 
		delay(100);*/
		
		struct timeval te; 
		gettimeofday(&te, NULL); // get current time
		
		segundo	= te.tv_sec;
		milisegundo = te.tv_usec;
		
		printf("%d\n",segundo);
		printf("%d\n",milisegundo);
		
		//if ((segundo==0)){
			
			/* digitalWrite (LEDTEST, HIGH);
			delay(100);
			digitalWrite (LEDTEST,  LOW); */
			//printf("\nPulso");
		//}
		
	//}
	
}
//**************************************************************************************************************************************


//**************************************************************************************************************************************
//************************************************************** Funciones *************************************************************
//**************************************************************************************************************************************

//**************************************************************************************************************************************
//Configuracion:
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
	
	//Configuracion libreria WiringPi:
    wiringPiSetup();
	pinMode(LEDTEST, OUTPUT);
			
	//printf("Configuracion completa\n");
	
}
//**************************************************************************************************************************************