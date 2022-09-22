// Compilar:
// gcc /home/rsa/Programas/IniciarGPS.c -o /home/rsa/Ejecutables/gps_init -lbcm2835 -lwiringPi -lm

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

// Declaracion de constantes
#define P2 2
#define P1 0
#define MCLR 28 // Pin 38 
#define TEST 26 // Pin 32

#define TIEMPO_SPI 10
#define FreqSPI 2000000

//Declaracion de variables:
unsigned short buffer;

// Metodos para la comunicacion con el dsPIC
int ConfiguracionPrincipal();
void IniciarGPS();

//**************************************************************************************************************************************
int main(void)
{

    //printf("\n\nIniciando...\n");

    ConfiguracionPrincipal();
    sleep(1);   
    IniciarGPS();

    /*
    // Genera un pulso para resetear el dsPIC:
    digitalWrite(MCLR, HIGH);
    delay(100);
    digitalWrite(MCLR, LOW);
    delay(100);
    digitalWrite(MCLR, HIGH);
    */
 
    //Cierra el SPI:
    bcm2835_spi_end();
    bcm2835_close();

    return 0;
}
//**************************************************************************************************************************************

//**************************************************************************************************************************************
int ConfiguracionPrincipal()
{

    // Reinicia el modulo SPI
    system("sudo rmmod  spi_bcm2835");
    //bcm2835_delayMicroseconds(500);
    system("sudo modprobe spi_bcm2835");

    // Configuracion libreria bcm2835:
    if (!bcm2835_init())
    {
        printf("bcm2835_init fallo. Ejecuto el programa como root?\n");
        return 1;
    }
    if (!bcm2835_spi_begin())
    {
        printf("bcm2835_spi_begin fallo. Ejecuto el programa como root?\n");
        return 1;
    }

    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
    // bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//Clock divider RPi 2
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); // Clock divider RPi 3
    bcm2835_spi_set_speed_hz(FreqSPI);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);

    // Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(MCLR, OUTPUT);
    pinMode(TEST, OUTPUT);
   
    // Enciende el pin TEST
    digitalWrite(TEST, HIGH);

    printf("\n****************************************\n");
    printf("Configuracion completa\n");
    printf("****************************************\n");
}
//**************************************************************************************************************************************

//**************************************************************************************************************************************
// Comunicacion RPi-dsPIC:

// C:0xA2	F:0xF2
void IniciarGPS()
{
    printf("Iniciando el GPS...\n");
    printf("****************************************\n");
    bcm2835_spi_transfer(0xA2);
    bcm2835_delayMicroseconds(TIEMPO_SPI);
    //bcm2835_spi_transfer(0xF2);
    buffer = bcm2835_spi_transfer(0xF2);

    sleep(3);

    //Comprueba si respondio el dsPIC:
    if (buffer==0x47)
    {
        printf("Se ha iniciado el GPS\n");
        digitalWrite(TEST, LOW);
    }
    else
    {
        printf("El dsPIC no responde\n");
    }
    printf("****************************************\n\n");
}

//**************************************************************************************************************************************
