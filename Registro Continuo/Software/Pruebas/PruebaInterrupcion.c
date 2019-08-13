//Compilar:
//gcc PruebaInterrupcion.c -o Eventos -lbcm2835 -lpthread

#include <stdio.h>
#include <stdlib.h>
#include <bcm2835.h>
#include <pthread.h>
#include <time.h>
#include <string.h>


//Declaracion de constantes
#define P2 2
#define P1 RPI_BPLUS_GPIO_J8_11


//Declaracion de funciones
int ConfiguracionPrincipal();

int main(void) {

  printf("Iniciando...\n");
  ConfiguracionPrincipal();

  while(1){
	  
	  if (bcm2835_gpio_eds(P1)){
            bcm2835_gpio_set_eds(P1);
            printf("evento detectado\n");
	  }

  }
  
  bcm2835_close();
  return 0;

 }
 
 
 int ConfiguracionPrincipal(){

    //Configuracion libreria bcm2835:
	if (!bcm2835_init()){
		printf("bcm2835_init fallo. Ejecuto el programa como root?\n");
		return 1;
	} else {
		//Configuracion evento externo
		bcm2835_gpio_fsel(P1, BCM2835_GPIO_FSEL_INPT);
		bcm2835_gpio_ren(P1);
		printf("Configuracion completa\n");
	}
	
	
	
	
	
}





