/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.c
 * Author: ivan.palacios
 *
 * Created on 6 de febrero de 2019, 15:54
 */

#include <bcm2835.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


//Declaracion de variables

unsigned char tramaSPI[15];                                                     //Vector para almacenar la peticion proveniente de la Rpi
unsigned short cont;

void ConfiguracionPrincipal(){

    //configuracion del puerto SPI
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);                    //o
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);                                 //
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); 
    bcm2835_spi_set_speed_hz(2000000);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                      
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);      
   
}


//Funcion para probar el puerto SPI
void ProbarSPI(){
    
    unsigned short x;
    unsigned short send_data;
    unsigned short read_data;
    
    tramaSPI[0] = 0x00;
    tramaSPI[1] = 0x01;
    tramaSPI[2] = 0x02;
    tramaSPI[3] = 0x03;
    tramaSPI[4] = 0x04;
    tramaSPI[5] = 0x05;
    tramaSPI[6] = 0x06;
    tramaSPI[7] = 0x07;
    tramaSPI[8] = 0x08;
    tramaSPI[9] = 0x09;
     
    bcm2835_spi_transfer(0xB0);
    bcm2835_delayMicroseconds(100);                                             //Delay 100 useg	
    
    for (x=0;x<10;x++){
        send_data = tramaSPI[x];                                                //Llena el buffer de salida con cada valor de la tramaSPI
        uint8_t read_data = bcm2835_spi_transfer(send_data);
        bcm2835_delayMicroseconds(100);	
    }
     bcm2835_spi_transfer(0xB1);
     bcm2835_delayMicroseconds(100);	
     
}


void main(void){
    
    //Si falla al inicializar indica que el programa debe correr en modo root
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
    
    ConfiguracionPrincipal();
    cont=0;
    
    while (cont<5){
        
        ProbarSPI();
        bcm2835_delay(1000);
    }
    
    bcm2835_spi_end();
    bcm2835_close();
    return 0;
    
}