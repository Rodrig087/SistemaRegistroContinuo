#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>

int main(void) {
    FILE *fp;
    fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.txt", "ab");
	if (fp){
		fclose (fp);		
	}
	if (bcm2835_spi_begin()){
		bcm2835_spi_end();
    }
	if (bcm2835_init()){
		bcm2835_close();
    }

}
