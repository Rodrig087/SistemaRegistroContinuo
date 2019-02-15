/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.c
 * Author: ivan.palacios
 *
 * Created on 15 de febrero de 2019, 9:16
 */

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>


//Declaracion de constantes
#define PIN_Interrupcion 2

//Declaracion de variables
volatile int contador = 0;
unsigned int numBytes = 2400;
unsigned char tramaOutSPI[10];
unsigned char tramaInSPI[2400];

//Declaracion de funciones
void ConfiguracionPrincipal();
void LeerSPI();

int main(void) {

  ConfiguracionPrincipal();

  while(1){

  }

  //bcm2835_spi_end();
  bcm2835_close();
  return 0;
 }

void ConfiguracionPrincipal(){

    //Configuracion libreria WiringPi
    wiringPiSetup();
    pinMode(PIN_Interrupcion, INPUT);
    wiringPiISR (PIN_Interrupcion, INT_EDGE_RISING, &LeerSPI);

    //Configuracion libreria bcm2835
    bcm2835_init();
    //bcm2835_spi_begin();
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);                    
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);                                 
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);

}

void LeerSPI() {

    unsigned int x;
    unsigned short read_data;
    
    bcm2835_spi_begin();

    bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(100);                                             //Delay 100 useg
    
    FILE *fp;
    fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.txt", "ab");
    
    if (fp){
        fprintf(fp, "\n");
        for (x=0;x<numBytes;x++){
            read_data = bcm2835_spi_transfer(0x00);
            bcm2835_delayMicroseconds(100);
            tramaInSPI[x] = read_data;
            fprintf(fp, "%d ", read_data);
        }
        fclose (fp);
    }

    bcm2835_spi_transfer(0xB1);                                                //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(100);

    contador++;
    printf("******\n");
    printf( "%d\n", contador);
    
    bcm2835_spi_end();
    //bcm2835_close();

}


