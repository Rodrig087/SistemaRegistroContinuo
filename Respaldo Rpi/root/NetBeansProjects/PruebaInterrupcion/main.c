/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.c
 * Author: ivan.palacios
 *
 * Created on 12 de febrero de 2019, 9:09
 */

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>

// Use GPIO Pin 17, which is Pin 0 for wiringPi library
#define PIN_Interrupcion 2                                                      
#define PIN_Salida RPI_GPIO_P1_11

volatile int contador = 0;
void interrupcionExterna();
void blink();

int main(void) {
 
  //Configuracion WiringPi
  wiringPiSetup();
  pinMode(PIN_Interrupcion, INPUT);
  wiringPiISR (PIN_Interrupcion, INT_EDGE_RISING, &blink);
  
  //Configuracion bcm2835
  bcm2835_init();
  bcm2835_gpio_fsel(PIN_Salida, BCM2835_GPIO_FSEL_OUTP);
  
  while(1){
  
  }
 
  bcm2835_close();
  return 0;
}

void interrupcionExterna(void) {
   contador++;
}

void blink(){ 
    bcm2835_gpio_write(PIN_Salida, HIGH);
    bcm2835_delay(100);
    bcm2835_gpio_write(PIN_Salida, LOW);
    bcm2835_delay(100);
}