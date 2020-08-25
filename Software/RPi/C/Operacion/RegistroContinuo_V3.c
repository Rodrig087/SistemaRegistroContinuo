//Compilar:
//gcc RegistroContinuo_V3.c -o /home/pi/Ejecutables/SaludEstructural/acelerografo -lbcm2835 -lwiringPi 
//gcc RegistroContinuo_V3.c -o saludmaster -lbcm2835 -lwiringPi 

#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>
#include <string.h>
#include <unistd.h>


//Declaracion de constantes
#define P2 2
#define P1 0
#define MCLR 28																	//Pin 38 GPIO						
#define TEST 26 
#define NUM_MUESTRAS 199
#define NUM_ELEMENTOS 2506
#define TIEMPO_SPI 10
#define NUM_CICLOS 1
#define FreqSPI 2000000


//Declaracion de variables
unsigned short i;
unsigned int x;
unsigned short buffer;
unsigned short banFile;
unsigned short banNewFile;
unsigned short numBytes;
unsigned short contMuestras;
unsigned char tiempoPIC[8];
unsigned char tiempoLocal[8];
unsigned char tramaDatos[NUM_ELEMENTOS];

FILE *fp;
FILE *ftmp;
FILE *fTramaTmp;
char path[30];
char ext[8];
char nombreArchivo[16];
char comando[40];
char dateGPS[22];
unsigned int timeNewFile[2] = {0, 0};											//Variable para configurar la hora a la que se desea generar un archivo nuevo (hh, mm)		
unsigned short confGPS[2] = {0, 1};							                    //Parametros que se pasan para configurar el GPS (conf, NMA) cuando conf=1 realiza la configuracion del GPS y se realiza una sola vez la primera vez que es utilizado 
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
short fuenteTiempoPic;

//Declaracion de funciones
int ConfiguracionPrincipal();
void GuardarVector(unsigned char* tramaD);
void CrearArchivo();
void ObtenerOperacion();														//C:0xA0    F:0xF0
void IniciarMuestreo();															//C:0xA1	F:0xF1
void DetenerMuestreo();															//C:0xA2	F:0xF2
void NuevoCiclo();																//C:0xA3	F:0xF3
void EnviarTiempoLocal();														//C:0xA4	F:0xF4
void ObtenerTiempoPIC();														//C:0xA5	F:0xF5
void ObtenerTiempoGPS();														//C:0xA6	F:0xF6
void ObtenerTiempoRTC();										 				//C:0xA7	F:0xF7


int main(void) {

	printf("Iniciando...\n");
  
	//Inicializa las variables:
	i = 0;
	x = 0;
	contMuestras = 0;
	banFile = 0;
	banNewFile = 0;
	numBytes = 0;
	contCiclos = 0;
	contador = 0;  
  
	ConfiguracionPrincipal(); 
	sleep(1);
	ObtenerTiempoRTC();
	sleep(5);
	
    
	while(1){	
	}
  
	bcm2835_spi_end();
	bcm2835_close();
 
	return 0;

}


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

    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE3);
	//bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//Clock divider RPi 2
	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);					//Clock divider RPi 3		
    bcm2835_spi_set_speed_hz(FreqSPI);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
		
	//Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
	pinMode(MCLR, OUTPUT);
	pinMode(TEST, OUTPUT);
	wiringPiISR (P1, INT_EDGE_RISING, ObtenerOperacion);
	
	//Enciende el pin TEST
	digitalWrite (TEST, HIGH);
	
	//Genera un pulso para resetear el dsPIC:
	digitalWrite (MCLR, HIGH);
	delay (100) ;
	digitalWrite (MCLR,  LOW); 
	delay (100) ;
	digitalWrite (MCLR, HIGH);
	
	printf("Configuracion completa\n");
	
}

void ObtenerOperacion(){
	
	bcm2835_spi_transfer(0xA0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	buffer = bcm2835_spi_transfer(0x00);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF0);	

	//Aqui se selecciona el tipo de operacion que se va a ejecutar 
	if (buffer==0xB1){
		printf("Recupero 0xB1\n");
		NuevoCiclo(); 
	} 
	if (buffer==0xB2){
		printf("Recupero 0xB2\n");
		ObtenerTiempoPIC(); 
	}
	
}


void IniciarMuestreo(){
	printf("Iniciando el muestreo...\n");
	bcm2835_spi_transfer(0xA1);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF1);	
}


void DetenerMuestreo(){
	printf("Deteniendo el muestreo...\n");
	bcm2835_spi_transfer(0xA2);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF2);	
}


void NuevoCiclo(){
	
	//printf("Nuevo ciclo\n");
	bcm2835_spi_transfer(0xA3);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

	for (i=0;i<2506;i++){
        buffer = bcm2835_spi_transfer(0x00);									//Envia 2506 dummy bytes para recuperar los datos de la trama enviada desde el dsPIC
        tramaDatos[i] = buffer;													//Guarda los datos en el vector tramaDatos 
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xF3);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	GuardarVector(tramaDatos);													//Guarda la el vector tramaDatos en el archivo binario
	CrearArchivo();																//Crea un archivo nuevo si se cumplen las condiciones
}


void EnviarTiempoLocal(){
	
	//Obtiene la hora y la fecha del sistema:
	printf("Hora local: ");
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);
	tiempoLocal[0] = tm->tm_mday;												//Dia del mes (0-31)
	tiempoLocal[1] = tm->tm_mon+1;												//Mes desde Enero (0-11)
	tiempoLocal[2] = tm->tm_year-100;											//Anio (contado desde 1900)
	tiempoLocal[3] = tm->tm_hour;												//Hora
	tiempoLocal[4] = tm->tm_min;												//Minuto
	tiempoLocal[5] = tm->tm_sec;												//Segundo 
	for (i=0;i<6;i++){
		printf("%0.2d ",tiempoLocal[i]);	
	}
	printf("\n");	

	bcm2835_spi_transfer(0xA4);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI); 
	for (i=0;i<6;i++){
        bcm2835_spi_transfer(tiempoLocal[i]);							//Envia los 6 datos de la trama tiempoLocal al dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
	bcm2835_spi_transfer(0xF4);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

}


void ObtenerTiempoPIC(){
	
	printf("Hora dsPIC: ");	
	bcm2835_spi_transfer(0xA5);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	fuenteTiempoPic = bcm2835_spi_transfer(0x00);								//Recibe el byte que indica la fuente de tiempo del PIC
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	for (i=0;i<6;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tiempoPIC[i] = buffer;													//Guarda la hora y fecha devuelta por el dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

	bcm2835_spi_transfer(0xF5);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
	if (fuenteTiempoPic==0){
		printf("RTC ");
	} 
	if (fuenteTiempoPic==1){
		printf("GPS ");
	}
	
	printf("%0.2d:",tiempoPIC[3]);		//hh
	printf("%0.2d:",tiempoPIC[4]);		//mm
	printf("%0.2d ",tiempoPIC[5]);		//ss
	printf("%0.2d/",tiempoPIC[0]);		//dd
	printf("%0.2d/",tiempoPIC[1]);		//MM
	printf("%0.2d\n",tiempoPIC[2]);		//aa
	
	IniciarMuestreo();
	
}


void ObtenerTiempoGPS(){ 
	printf("Obteniendo hora del GPS...\n");
	bcm2835_spi_transfer(0xA6);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF6);
}


void ObtenerTiempoRTC(){
	printf("Obteniendo hora del RTC...\n");
	bcm2835_spi_transfer(0xA7);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF7);		
}


void CrearArchivo(){
	
	//printf("Crear archivo\n");	
	
	//Obtiene la hora y la fecha del sistema:
	time_t t;
	struct tm *tm;
	t=time(NULL);
	tm=localtime(&t);
	//Cambia el estado de la bandera faltando un minuto para que se cumpla la hora fijada para la creacion de un archivo nuevo:
	if ((tm->tm_hour==23)&&((tm->tm_min==59))){
		banNewFile = 2;	
	}
	//Verifica si llego la hora/minuto que se configuro para cambiar el estado de la bandera de nuevo archivo y asi permitir la creacion de un nuevo archivo binario
	if ((banNewFile==2)&&(tm->tm_hour==timeNewFile[0])&&(tm->tm_min==timeNewFile[1])){
		fclose (fp);
		DetenerMuestreo();
		EnviarTiempoLocal();
		banNewFile = 0;
	}
		
	//Verifica que la bandera de nuevo archivo sea igual a cero
	//Si al invocar a esta funcion encuentra que ya existe un archivo con el nombre de la fecha actual, lo abrira y seguira escribiendo a continuacion (esto debido al comando "ab" en la funcion fopen)
	//Si al invocar a esta funcion no encuentra ningun archivo con el nombre de la fecha actual creara un archivo con ese nombre. 
	if (banNewFile==0){
		//Establece la fecha y hora actual como nombre que tendra el archivo binario 
		strftime(nombreArchivo, 20, "%Y%m%d%H%M", tm);
		
		//Asigna espacio en la memoria para el nombre completo de la ruta
		char *path = malloc(strlen(nombreArchivo)+5+20);
				
		//Asigna el nombre de la ruta y la extencion a los array de caracteres
		strcpy(ext, ".dat");
		strcpy(path, "/home/pi/Resultados/");
				
		//Realiza la concatenacion de array de caracteres
		strcat(path, nombreArchivo);
		strcat(path, ext);
		
		//Abre o crea el archivo binario
		fp = fopen (path, "ab+");

		//Crea el archivo temporal para almacenar el nombre del archivo
		ftmp = fopen ("/home/pi/TMP/namefile.tmp", "wb");
		fwrite(nombreArchivo, sizeof(char), 12, ftmp);
		fclose (ftmp);
		
		//Crea el archivo temporal para almacenar el nombre del archivo
		//fTramaTmp = fopen ("/home/pi/TMP/tramafile.tmp", "wb");
				
		//Cambia el valor de la bandera de nuevo archivo para que ignore esta funcion en la siguientes muestras y libera la memoria reservada para el nombre de la ruta 
		banNewFile = 1;	
		free(path);	
		printf("Archivo abierto\n");	
	}

}


//Esta funcion sirve para guardar en el archivo binario las tramas de 1 segundo recibidas
void GuardarVector(unsigned char* tramaD){
	
	unsigned int outFwrite;
	
	if (fp!=NULL){
		do{
		//Guarda la trama en el archivo binario:
		outFwrite = fwrite(tramaD, sizeof(char), NUM_ELEMENTOS, fp);
		//Guarda la trama en el archivo temporal:
		fTramaTmp = fopen ("/home/pi/TMP/tramafile.tmp", "wb");
		fwrite(tramaD, sizeof(char), NUM_ELEMENTOS, fTramaTmp);
		fclose (fTramaTmp);
		//Ejecuta el script de python:
		system("python /home/pi/Programas/RegistroContinuo/V3/BinarioToMiniSeed_V12.py");
		} while (outFwrite!=NUM_ELEMENTOS);
		fflush(fp);
	}
	
}




