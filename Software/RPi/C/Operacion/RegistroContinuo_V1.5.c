//Compilar:
//gcc RegistroContinuo_V1.5.c -o /home/pi/Ejecutables/acelerografo -lbcm2835 -lwiringPi 

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
unsigned char tiempoGPS[8];
unsigned char tiempoLocal[8];
unsigned char tramaDatos[NUM_ELEMENTOS];

FILE *fp;
FILE *ftmp;
char path[30];
char ext[8];
char nombreArchivo[16];
char comando[40];
char dateGPS[22];
unsigned int timeNewFile[2] = {0, 0};											//Variable para configurar la hora a la que se desea generar un archivo nuevo (hh, mm)		
unsigned short banNewFile;

unsigned short contCiclos;
unsigned short contador;
pthread_t h1;

//Declaracion de funciones
int ConfiguracionPrincipal();
void NuevoCiclo();																//C:0xA3	F:0xF3
void GuardarVector(unsigned char* tramaD);
void CrearArchivo();
void IniciarMuestreo();															//C:0xA1	F:0xF1
void DetenerMuestreo();															//C:0xA2	F:0xF2
void ConfigurarGPS();
void ObtenerTiempoGPS();														//C:0xA5	F:0xF5
void ObtenerTiempoPIC();														//C:0xA6	F:0xF6
void EnviarTiempoLocal();														//C:0xA4	F:0xF4
void ObtenerTiempoRTC();										 				//C:0xA8	F:0xF8

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
  sleep(5);
  
  EnviarTiempoLocal();
  //ObtenerTiempoRTC();
  CrearArchivo();
    
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
	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);					//Clock divider RPi 2
	//bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_128);					//Clock divider RPi 3		
    bcm2835_spi_set_speed_hz(FreqSPI);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);
		
	//Configuracion libreria WiringPi:
    wiringPiSetup();
    pinMode(P1, INPUT);
    pinMode(P2, INPUT);
	pinMode(MCLR, OUTPUT);
	wiringPiISR (P1, INT_EDGE_RISING, NuevoCiclo);
	wiringPiISR (P2, INT_EDGE_RISING, ObtenerTiempoPIC);
	
	//Genera un pulso para resetear el dsPIC:
	digitalWrite (MCLR, HIGH);
	delay (100) ;
	digitalWrite (MCLR,  LOW); 
	delay (100) ;
	digitalWrite (MCLR, HIGH);
	
	printf("Configuracion completa\n");
	
}


void IniciarMuestreo(){
	printf("Iniciando el muestreo...\n");
	bcm2835_spi_transfer(0xA0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xA0);	
}


void DetenerMuestreo(){
	printf("Deteniendo el muestreo...\n");
	bcm2835_spi_transfer(0xAF);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xAF);	
}


void ConfigurarGPS(){
	printf("Configurando el GPS...\n");
	bcm2835_spi_transfer(0xC2);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xC2);		
}


void ObtenerTiempoGPS(){
	printf("Obteniendo hora del GPS...\n");
	bcm2835_spi_transfer(0xC0);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xC0);		
}

void ObtenerTiempoRTC(){
	printf("Obteniendo hora del RTC...\n");
	bcm2835_spi_transfer(0xA8);
	bcm2835_delayMicroseconds(TIEMPO_SPI);
	bcm2835_spi_transfer(0xF8);		
}


void ObtenerTiempoPIC(){
	printf("Hora dsPIC: ");	
	for (i=0;i<6;i++){
        buffer = bcm2835_spi_transfer(0x00);
        tiempoGPS[i] = buffer;													//Guarda la hora y fecha devuelta por el dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
    bcm2835_spi_transfer(0xC1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
							
	printf("%0.2d:",tiempoGPS[3]);		//hh
	printf("%0.2d:",tiempoGPS[4]);		//mm
	printf("%0.2d ",tiempoGPS[5]);		//ss
	printf("%0.2d/",tiempoGPS[0]);		//dd
	printf("%0.2d/",tiempoGPS[1]);		//MM
	printf("%0.2d\n",tiempoGPS[2]);		//aa
	
	//Configura el reloj interno de la RPi con la hora recuperada del GPS:
	strcpy(comando, "sudo date --set ");	//strcpy( <variable_destino>, <cadena_fuente> )
	//'2019-09-13 17:45:00':
	dateGPS[0] = 0x27;						//'
	dateGPS[1] = '2';
	dateGPS[2] = '0';
	dateGPS[3] = (tiempoGPS[2]/10)+48;		//aa: (19/10)+48 = 49 = '1'
	dateGPS[4] = (tiempoGPS[2]%10)+48;		//    (19%10)+48 = 57 = '9'
	dateGPS[5] = '-';	
	dateGPS[6] = (tiempoGPS[1]/10)+48;		//MM
	dateGPS[7] = (tiempoGPS[1]%10)+48;
	dateGPS[8] = '-';
	dateGPS[9] = (tiempoGPS[0]/10)+48;		//dd
	dateGPS[10] = (tiempoGPS[0]%10)+48;
	dateGPS[11] = ' ';
	dateGPS[12] = (tiempoGPS[3]/10)+48;		//hh
	dateGPS[13] = (tiempoGPS[3]%10)+48;
	dateGPS[14] = ':';
	dateGPS[15] = (tiempoGPS[4]/10)+48;		//mm
	dateGPS[16] = (tiempoGPS[4]%10)+48;
	dateGPS[17] = ':';
	dateGPS[18] = (tiempoGPS[5]/10)+48;		//ss
	dateGPS[19] = (tiempoGPS[5]%10)+48;
	dateGPS[20] = 0x27;
	dateGPS[21] = '\0';
	
	strcat(comando, dateGPS);
	
	system(comando);
	system("date");
	
	IniciarMuestreo();
	
}

void EnviarTiempoLocal(){
	
	//Obtiene la hora y la fecha del sistema:
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
	
	bcm2835_spi_transfer(0xC3);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI); 
		
	for (i=0;i<6;i++){
        buffer = bcm2835_spi_transfer(tiempoLocal[i]);							//Envia los 6 datos de la trama tiempoLocal al dsPIC
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }
	
	bcm2835_spi_transfer(0xC4);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);
	
}


void NuevoCiclo(){
	
	//printf("Nuevo ciclo\n");
	bcm2835_spi_transfer(0xB0);                                                 //Envia el delimitador de inicio de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);                                      

	for (i=0;i<2506;i++){
        buffer = bcm2835_spi_transfer(0x00);									//Envia 2506 dummy bytes para recuperar los datos de la trama enviada desde el dsPIC
        tramaDatos[i] = buffer;													//Guarda los datos en el vector tramaDatos 
        bcm2835_delayMicroseconds(TIEMPO_SPI);
    }

    bcm2835_spi_transfer(0xB1);                                                 //Envia el delimitador de final de trama
    bcm2835_delayMicroseconds(TIEMPO_SPI);

	GuardarVector(tramaDatos);													//Guarda la el vector tramaDatos en el archivo binario
	CrearArchivo();																//Crea un archivo nuevo si se cumplen las condiciones
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
	//if ((tm->tm_min==(timeNewFile[1]-1))||(tm->tm_min==59)){
		//if (tm->tm_hour==timeNewFile[0]){
			banNewFile = 2;	
		//}
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

		//Crea el archivo temporal
		ftmp = fopen ("/home/pi/TMP/namefile.tmp", "wb");
		fwrite(nombreArchivo, sizeof(char), 12, ftmp);
		fclose (ftmp);
		
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
		} while (outFwrite!=NUM_ELEMENTOS);
		fflush(fp);
	}
	
}




