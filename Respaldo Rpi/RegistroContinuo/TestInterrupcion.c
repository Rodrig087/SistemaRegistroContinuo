//#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>


//Declaracion de constantes
#define P2 0
#define P1 2
#define NUM_MUESTRAS 199
#define TIEMPO_SPI 200

//Declaracion de variables
unsigned short i;
unsigned short buffer;
unsigned short banLinea;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char datos[15];                                //Vector para almacenar los datos de payload
unsigned short tiempoSPI;
FILE *fp;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevaLinea();
void NuevaMuestra();
void GuardarMuestra(unsigned short linea, unsigned char* trama, unsigned short tramaSize);


int main(void) {

  ConfiguracionPrincipal();
  
  piHiPri (99);
  
  datos[0] = 66;
  datos[1] = 11;
  datos[2] = 12;
  datos[3] = 13;
  datos[4] = 21;
  datos[5] = 22;
  datos[6] = 23;
  datos[7] = 31;
  datos[8] = 32;
  datos[9] = 33;
  
  datos[10] = 19;                                  //Año
  datos[11] = 49;                                  //Dia
  datos[12] = 9;                                   //Hora
  datos[13] = 30;                                  //Minuto
  datos[14] = 0;                                   //Segundo
  
  i = 0;
  contMuestras = 0;
  banLinea = 0;
  numBytes = 0;
  
  while(1){

  }
 
  return 0;
  
 }


int ConfiguracionPrincipal(){
	
	//Configuracion gestor de archivos
    fp = fopen ("/home/pi/Ejemplos/EjemploSPI/output.txt", "ab");
	
	
    //Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
    wiringPiISR (P1, INT_EDGE_RISING, &NuevaLinea);
    wiringPiISR (P2, INT_EDGE_RISING, &NuevaMuestra);
	
}


void NuevaLinea(){
                                 
	GuardarMuestra(1,datos,10);

    banLinea = 1;
    contMuestras = 1;

}


void NuevaMuestra(){

    if (banLinea==1){

		if (contMuestras<NUM_MUESTRAS){
			numBytes = 10;
		}

		if (contMuestras==NUM_MUESTRAS) {
			numBytes = 15;
		}

		if (numBytes==10){
			GuardarMuestra(0,datos,10);
		} else {
			GuardarMuestra(0,datos,15);
		}
	
		if (contMuestras==NUM_MUESTRAS) {
			banLinea = 0;
		}

		contMuestras++;

    }

}


void GuardarMuestra(unsigned short linea, unsigned char* trama, unsigned short tramaSize) {
    
    if (fp){
		if (linea==1){
			fprintf(fp, "\n");
		}
        for (i=0;i<tramaSize;i++){
			if (i==0){
			    fprintf(fp, " %d ", trama[i]);						
			} else {
				fprintf(fp, "%d", trama[i]);
			}
        }
    }
}

