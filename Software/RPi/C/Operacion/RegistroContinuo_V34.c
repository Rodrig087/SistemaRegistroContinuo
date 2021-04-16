//Compilar:
//gcc /home/pi/Programas/RegistroContinuo_V34.c -o /home/pi/Ejecutables/acelerografo -lbcm2835 -lwiringPi -lm 


#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <bcm2835.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
// Para operaciones en la deteccion de eventos
#include <math.h>
#include <stdbool.h>


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

// Define los parametros del metodo STA/LTA en segundos multiplicado por la frecuencia de muestreo
#define fSample 250
#define n_STA 125           // 0.5 segundos * fSample
#define n_LTA 12500         // 50 segundos *fSample
#define valTrigger 4
#define valDetrigger 2
// Tiempos en segundos para agregar antes y despues de la deteccion de un evento
#define timePreEvent 2
#define timePostEvent 2
#define ventanaEvento 30
// Se considera un tiempo extra entre eventos, de esta forma si ocurren dos eventos cercanos
// se envia uno solo
#define timeEntreEventos 60

// Define los parametros del filtro FIR
// Maximo numero de datos de entrada en una llamada a la funcion
// Permite filtrar al mismo tiempo hasta este numero de muestras
#define MAX_INPUT_LEN 80
// Maxima longitud del filtro, maximo numero de coeficientes que permite
#define MAX_FLT_LEN 64
// Dimension para almacenar las muestras de entrada
#define BUFFER_LEN (MAX_FLT_LEN - 1 + MAX_INPUT_LEN)
// Vector para almacenar las muestras de entrada
double vectorMuestras[BUFFER_LEN];
// Coeficientes para un filtro FIR pasa alto de frecuencia 1Hz con ventana Kaiser de orden 63 que da 64 coeficientes, beta = 5
// La frecuencia de muestreo es 250 Hz y se utilizo la herramienta fdatool Matlab (Se llama con filterDesigner)
#define FILTER_LEN 64
double coeficientes[FILTER_LEN] = {
  -0.0002607120740672,-0.0003948152676513,-0.0005637464517517,-0.0007728729580176,
  -0.001028015561932,-0.001335475734722, -0.00170207452642, -0.00213520803273,
  -0.002642925970776,-0.003234042043891,-0.003918287787646,-0.004706525881195,
  -0.005611045142428,-0.006645968660266,-0.007827820476902, -0.00917631779097,
   -0.01071548972453, -0.01247527892566, -0.01449387435105, -0.01682118197898,
   -0.01952412263954, -0.02269497075544, -0.02646496949405, -0.03102756147795,
   -0.03668020238467,  -0.0439047613983, -0.05353560928689, -0.06715178559783,
   -0.08814138938659,  -0.1253204018087,  -0.2110265970226,  -0.6363397139696,
     0.6363397139696,   0.2110265970226,   0.1253204018087,  0.08814138938659,
    0.06715178559783,  0.05353560928689,   0.0439047613983,  0.03668020238467,
    0.03102756147795,  0.02646496949405,  0.02269497075544,  0.01952412263954,
    0.01682118197898,  0.01449387435105,  0.01247527892566,  0.01071548972453,
    0.00917631779097, 0.007827820476902, 0.006645968660266, 0.005611045142428,
   0.004706525881195, 0.003918287787646, 0.003234042043891, 0.002642925970776,
    0.00213520803273,  0.00170207452642, 0.001335475734722, 0.001028015561932,
  0.0007728729580176,0.0005637464517517,0.0003948152676513,0.0002607120740672
};
// Variable con la ruta y el nombre del archivo temporal para guardar la informacion de cada evento detectado
// Se guarda solo la fecha long, la hora en segundos del inicio del evento y su duracion
// Con cada evento nuevo se sobreescribe la informacion, antes se debe leer en el programa de Python
static char* fileNameEventoDetectado = "/home/pi/TMP/EventosDetectados.tmp";


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

//Metodos para la comunicacion con el dsPIC
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
void SetRelojLocal(unsigned char* tramaTiempo);

// Metodos para detectar automaticamente los eventos sismicos:
void DetectarEvento(unsigned char* tramaD);
float ObtenerValorAceleracion(char byte1, char byte2, char byte3);
float calcular_STA_recursivo (float numRecibido);
float calcular_LTA_recursivo (float numRecibido);
float calcularRelacion_LTA_STA (float valSTA, float valLTA);
char calcularIsEvento(float resul_STA_LTA);
void firFloatInit (void);
float calcular_Salida_Filtro (double *coeficientes, double valEntrada, int filterLength);
void ExtraerEvento(char* nombreArchivoRegistro, unsigned int tiempoEvento, unsigned int duracionEvento);

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
	//ObtenerTiempoGPS();
	//ObtenerTiempoRTC();
	EnviarTiempoLocal();
	sleep(5);
	
	// Llama al metodo para inicializar el filtro FIR
	firFloatInit();
    
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
		//printf("Recupero 0xB1\n");
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
	
	// Llama al metodo para determinar si existe o no un evento sismico:
    DetectarEvento(tramaDatos);
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
	
	SetRelojLocal(tiempoPIC);
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
		//char *path = malloc(strlen(nombreArchivo)+5+27);
				
		//Asigna el nombre de la ruta y la extencion a los array de caracteres
		strcpy(ext, ".dat");
		strcpy(path, "/home/pi/Resultados/");
		//strcpy(path, "/media/PenDrive/Resultados/");
				
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
		fTramaTmp = fopen ("/home/pi/TMP/tramafile.tmp", "wb");
				
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
		//system("python /home/pi/Programas/RegistroContinuo/V3/BinarioToMiniSeed_V12.py");
		} while (outFwrite!=NUM_ELEMENTOS);
		fflush(fp);
	}
	
}


void SetRelojLocal(unsigned char* tramaTiempo){
	
	char datePIC[22];	
	//Configura el reloj interno de la RPi con la hora recuperada del PIC:
	strcpy(comando, "sudo date --set ");	//strcpy( <variable_destino>, <cadena_fuente> )
	//Ejemplo: '2019-09-13 17:45:00':
	datePIC[0] = 0x27;						//'
	datePIC[1] = '2';
	datePIC[2] = '0';
	datePIC[3] = (tramaTiempo[0]/10)+48;		//dd
	datePIC[4] = (tramaTiempo[0]%10)+48;
	datePIC[5] = '-';	
	datePIC[6] = (tramaTiempo[1]/10)+48;		//MM
	datePIC[7] = (tramaTiempo[1]%10)+48;
	datePIC[8] = '-';
	datePIC[9] = (tramaTiempo[2]/10)+48;		//aa: (19/10)+48 = 49 = '1'
	datePIC[10] = (tramaTiempo[2]%10)+48;		//    (19%10)+48 = 57 = '9'
	datePIC[11] = ' ';
	datePIC[12] = (tramaTiempo[3]/10)+48;		//hh
	datePIC[13] = (tramaTiempo[3]%10)+48;
	datePIC[14] = ':';
	datePIC[15] = (tramaTiempo[4]/10)+48;		//mm
	datePIC[16] = (tramaTiempo[4]%10)+48;
	datePIC[17] = ':';
	datePIC[18] = (tramaTiempo[5]/10)+48;		//ss
	datePIC[19] = (tramaTiempo[5]%10)+48;
	datePIC[20] = 0x27;
	datePIC[21] = '\0';
	
	strcat(comando, datePIC);
	
	system(comando);
	system("date");
	
}


// *********************************************************************************************
// Metodo para determinar si existe o no un evento sismico
// Utiliza el algoritmo STA/LTA recursivo
// *********************************************************************************************
void DetectarEvento(unsigned char* tramaD) {
    // Variables para guardar los datos de evento detectado en el archivo temporal
    static FILE *obj_fp;
//    static char* fileNameEventoDetectado = "EventoDetectado.tmp";
    // Variable para bucle
    unsigned int indiceVector;
    // Variables para obtener el tiempo en funcion de los datos recibidos
    char anio, mes, dia, horas, minutos, segundos;
    unsigned long horaLong, fechaLong;
    static unsigned long fechaLongAnt = 0, fechaActual = 0;
    static bool isPrimeraFecha = true;
    // Variables para obtener la aceleracion de los tres canales
    // aunque actualmente se esta usando solo uno para la deteccion
    double valAceleracionX, valAceleracionY, valAceleracionZ;
    // Variables para almacenar los resultados del metodo de deteccion STA/LTA
    double resul_STA, resul_LTA, resul_STA_LTA;
    // Variables para determinar el inicio y fin de un evento detectado
    // Tambien se almacena el ultimo evento y su duracion, porque en el caso de que
    // se detecte dos eventos cercanos, la idea es hacerlo uno solo, en funcion del
    // tiempo entre eventos definido al inicio del programa
    char valEvento;
    static bool isEvento = false, enviarEvt = false;
    static unsigned long tiempoInitEvtAct, tiempoInitEvtAnt, tiempoFinEvtAct, tiempoFinEvtAnt;
    static unsigned long fechaInitEvtAct, fechaInitEvtAnt;
    static unsigned int duracionEvtAct, duracionEvtAnt, tiempoPreEvento;
    // Variable para almacenar el dato filtrado
    double resul_filtro;

    // Para obtener el tiempo de inicio y fin
//    struct timespec now;
//    unsigned long msecInicial, msecFinal, diff;

    // Primero obtiene el tiempo actual que esta en los ultimos 6 bytes del vector
    anio = tramaD[NUM_ELEMENTOS - 6];
    mes = tramaD[NUM_ELEMENTOS - 5];
    dia = tramaD[NUM_ELEMENTOS - 4];
    fechaLong = 10000*anio + 100*mes + dia;
    // Si es la primera vez, actualiza todas las fechas
    if (isPrimeraFecha == true) {
        isPrimeraFecha = false;
        fechaActual = fechaLong;
        fechaLongAnt = fechaLong;
    // Desde la segunda entrada solo analiza si hay cambio de fecha
    // Es necesario tener almacenada la fecha de un dia anterior, por
    // si acaso un evento con el tiempo de pre event comience en el dia
    // anterior
    } else {
        // Si hubo cambio de fecha, actualiza primero la fecha anterior
        // y luego la fecha actual
        if (fechaActual != fechaLong) {
            fechaLongAnt = fechaActual;
            fechaActual = fechaLong;
        }
    }

//    printf ("Anio %d Mes %d Dia %d \n", anio, mes, dia);
    horas = tramaD[NUM_ELEMENTOS - 3];
    minutos = tramaD[NUM_ELEMENTOS - 2];
    segundos = tramaD[NUM_ELEMENTOS - 1];
    horaLong = 3600*horas + 60*minutos + segundos;
//    printf ("Horas %d Minutos %d Segundos %d \n", horas, minutos, segundos);

    // Obtiene el tiempo de inicio en ms
//    clock_gettime( CLOCK_REALTIME, &now );
    // Si se quisiera los segundos sec = (int)now.tv_sec;
//    msecInicial = (int)now.tv_nsec / 1000000;
//    printf ("Tiempo Inicio %lu \n", msecInicial);

	// Recorre todo el vector, quitando los 6 bytes del tiempo
	indiceVector = 0;
	while (indiceVector < (NUM_ELEMENTOS - 6)) {
        // Cada 10 bytes se tiene el inicio de un muestreo
        // Por lo tanto, el primer byte es un indicador de nuevo muestreo
        if (indiceVector%10 == 0) {
            // Llama al metodo para obtener la aceleracion con los valores del eje X
//            printf ("Indice %lu Trama %d Byte1 %d Byte2 %d Byte3 %d \n", indiceVector, tramaD[indiceVector], tramaD[indiceVector + 1], tramaD[indiceVector + 2], tramaD[indiceVector + 3]);
            valAceleracionX = ObtenerValorAceleracion(tramaD[indiceVector + 1], tramaD[indiceVector + 2], tramaD[indiceVector + 3]);
//            printf ("Aceleracion X %0.8f \n", valAceleracionX);

//            printf ("Indice %lu Trama %d Byte1 %d Byte2 %d Byte3 %d \n", indiceVector, tramaD[indiceVector], tramaD[indiceVector + 4], tramaD[indiceVector + 5], tramaD[indiceVector + 6]);
            valAceleracionY = ObtenerValorAceleracion(tramaD[indiceVector + 4], tramaD[indiceVector + 5], tramaD[indiceVector + 6]);
//            printf ("Aceleracion Y %0.8f \n", valAceleracionY);

//            printf ("Indice %lu Trama %d Byte1 %d Byte2 %d Byte3 %d \n", indiceVector, tramaD[indiceVector], tramaD[indiceVector + 7], tramaD[indiceVector + 8], tramaD[indiceVector + 9]);
            valAceleracionZ = ObtenerValorAceleracion(tramaD[indiceVector + 7], tramaD[indiceVector + 8], tramaD[indiceVector + 9]);
//            printf ("Aceleracion Z %0.8f \n", valAceleracionZ);

            // Llama al metodo para realizar el filtrado
            // El valor filtrado se almacena en el vector resul_filtro
            resul_filtro = calcular_Salida_Filtro(coeficientes, valAceleracionY, FILTER_LEN);
//            resul_filtro = valAceleracionY;

            // Envia el numero actual para el calculo del valor STA
            resul_STA = calcular_STA_recursivo(resul_filtro);
            // Envia el numero actual para el calculo del valor LTA
            resul_LTA = calcular_LTA_recursivo(resul_filtro);
            // Calcula la relacion entre los dos valores y si es o no evento
            resul_STA_LTA = calcularRelacion_LTA_STA(resul_STA, resul_LTA);
            valEvento = calcularIsEvento(resul_STA_LTA);

            // Si esta activa la bandera de enviar evento, analiza si ya se cumplio el tiempo extra
            // y que no hayan nuevos eventos y guarda la informacion en el archivo temporal
            if (enviarEvt == true && horaLong >= (tiempoFinEvtAnt + timeEntreEventos) && valEvento == 0) {
                enviarEvt = false;
                // Abre el archivo temporal, borra la informacion actual y escribe los nuevos
                // datos del evento detectado
                obj_fp = fopen(fileNameEventoDetectado, "a");
                // Guarda en el archivo de texto, la fecha y la hora de inicio del veneto, ademas su duracion
                // En las variables de evento anterior se encuentra toda la informacion (aunque creo que da
                // igual usar las de evento actual en este punto)
                fprintf (obj_fp, "%lu\t%lu\t%lu\n", fechaInitEvtAnt, tiempoInitEvtAnt, duracionEvtAnt);
                // Cierra el archivo temporal
                fclose(obj_fp);

                printf ("Enviado solicitud Evt Inicio %lu %lu Duracion %lu HoraActual %lu \n", fechaInitEvtAnt, tiempoInitEvtAnt, duracionEvtAnt, horaLong);
            
				//Extrae el evento:
				//ExtraerEvento(nombreArchivo, tiempoInitEvtAnt, duracionEvtAnt);
			
			}

            // Si aun no se han detectado eventos y el dato es 1, significa el comienzo de un evento
            if (isEvento == false && valEvento == 1) {
                // Coloca la bandera de evento en True, de aqui se desactiva cuando valEvento es 0
                isEvento = true;
                // Actualiza el tiempo inicial del evento, si no hay eventos pendientes por enviar
                // es directamente el tiempo actual
                if (enviarEvt == false) {
                    tiempoInitEvtAct = horaLong;
                    fechaInitEvtAct = fechaLong;
                // Caso contrario es el tiempo de inicio del ultimo evento
                } else {
                    tiempoInitEvtAct = tiempoInitEvtAnt;
                    fechaInitEvtAct = fechaInitEvtAnt;
                }

                printf ("Hora actual %lu Fecha actual %lu Inicio evento detectado %lu %lu \n", horaLong, fechaLong, fechaInitEvtAct, tiempoInitEvtAct);
            }
            // Si hay un evento actualmente y valEvento es 0, significa fin del evento
            if (isEvento == true && valEvento == 0) {
                isEvento = false;
                // Actualiza el tiempo final del evento
                printf ("Fin deteccion de evento %lu \n", horaLong);
                tiempoFinEvtAct = horaLong;

                // Ademas se analiza la ventana de tiempo de eventos (aproximadamente 20 segundos)
                // Esto es para agregar un tiempo antes y despues de la deteccion automatica y asi
                // asegurar toda la infomacion
                // Primero calcula la duracion del evento, lo logico es que el tiempo final sea mayor
                // que el tiempo inicial, pero si es lo contrario significa que hubo un evento justo en
                // el cambio de dia
                if (tiempoFinEvtAct >= tiempoInitEvtAct) {
                    duracionEvtAct = tiempoFinEvtAct - tiempoInitEvtAct;
                // Si el tiempo inicial es mayor que el final, significa que comenzo en el dia anterior
                // por lo que se suma los 86400 (24*3600) al tiempo final
                } else {
                    duracionEvtAct = 86400 + tiempoFinEvtAct - tiempoInitEvtAct;
                }
                // Con la duracion del evento, se obtiene cuantos segundos hay que restar al tiempo de
                // inicio, esto es para agregar un tiempo de pre evento
                // Si la ventana de 20 segundos es mayor que el evento (que es lo mas logico), resta y divide
                // para dos para sacar el tiempo de pre evento
                if (ventanaEvento >= duracionEvtAct) {
                    tiempoPreEvento = (unsigned long) ((ventanaEvento - duracionEvtAct)/2);
                // Caso contrario, agrega el tiempo por defecto de pre evento
                } else {
                    tiempoPreEvento = timePreEvent;
                }
                // Finalmente resta al tiempo de inicio
                // Si el tiempo de inicio es mayor que el de pre evento solo realiza la resta
                if (tiempoInitEvtAct >= tiempoPreEvento) {
                    tiempoInitEvtAct = tiempoInitEvtAct - tiempoPreEvento;
                // Caso contrario significa que con la resta se tiene el tiempo del dia anterior
                // Entonces antes se suma los 86400 (3600*24)
                } else {
                    tiempoInitEvtAct = 86400 + tiempoInitEvtAct - tiempoPreEvento;
                    // En este caso tambien hay que actualizar la fecha long a la anterior
                    fechaInitEvtAct = fechaLongAnt;
                }
                // Algo similar para el tiempo fin de evento
                if ((tiempoFinEvtAct + tiempoPreEvento) >= 86400) {
                    tiempoFinEvtAct = tiempoFinEvtAct + tiempoPreEvento - 86400;
                } else {
                    tiempoFinEvtAct = tiempoFinEvtAct + tiempoPreEvento;
                }

                printf ("Tiempo Inicio Evento procesado %lu %lu y fin %lu \n", fechaInitEvtAct, tiempoInitEvtAct, tiempoFinEvtAct);


                // Activa la bandera para enviar el evento
                enviarEvt = true;
                // Ademas actualiza los tiempos al evento anterior
                tiempoInitEvtAnt = tiempoInitEvtAct;
                tiempoFinEvtAnt = tiempoFinEvtAct;
                fechaInitEvtAnt = fechaInitEvtAct;
                // Tambien la duracion del evento
                if (tiempoFinEvtAnt >= tiempoInitEvtAnt) {
                    duracionEvtAnt = tiempoFinEvtAnt - tiempoInitEvtAnt;
                } else {
                    duracionEvtAnt = 86400 + tiempoFinEvtAnt - tiempoInitEvtAnt;
                }
            }

//            printf ("Valor STA %f LTA %f STA/LTA %f \n", resul_STA, resul_LTA, resul_STA_LTA);
            // Aumenta en 10 el indiceVector dado que se utilizaron los 9 bytes de los datos y 1 del indicador
            indiceVector += 10;
        }
//        printf("%d \n", tramaD[indiceVector]);
	}

    // Obtiene el tiempo final, luego de realizar todas las operaciones
//    clock_gettime( CLOCK_REALTIME, &now );
    // Si se quisiera los segundos sec = (int)now.tv_sec;
//    msecFinal = (int)now.tv_nsec / 1000000;
//    printf ("Tiempo Final (ms) %lu \n", msecFinal);
//    diff = msecFinal - msecInicial;
//    printf("Tiempo Total Operaciones (ms) %lu \n", diff);
}
// *********************************************************************************************
// ************************** Fin Metodo DetectarEvento ****************************************
// *********************************************************************************************



// *********************************************************************************************
// Metodo para obtener el valor de la aceleracion para los 3 ejes a partir de sus 3 bytes
// *********************************************************************************************
float ObtenerValorAceleracion(char byte1, char byte2, char byte3) {
    signed long axisValue;
//    signed long valNegado;
    float aceleracion;

//    printf ("Byte 1 %d Byte 2 %d Byte 3 %d \n", byte1, byte2, byte3);

    // Obtiene el valor de aceleraciion del eje correspondiente
    axisValue = ((byte1 << 12) & 0xFF000) + ((byte2 << 4) & 0xFF0) + ((byte3 >> 4) & 0xF);
//    printf ("ValAxes %lu \n", axisValue);
    // Aplica el complemento a 2
    if (axisValue >= 0x80000) {
        // Se descarta el bit 20 que indica el signo (1 = negativo)
//        printf ("Signo negativo %lu ", axisValue);
        axisValue = axisValue & 0x7FFFF;
//        printf ("paso1 %li ", axisValue);
//        valNegado = (~axisValue) + 1;
//        printf ("negado %li ", valNegado);
        axisValue = (signed long) (-1*(((~axisValue) + 1) & 0x7FFFF));
//        printf ("nuevo %li \n", axisValue);

//        aceleracion = (double) ((signed long) (axisValue) * (980/pow(2,18)));
//        printf ("Aceleracion X %0.8f \n", aceleracion);

//        aceleracion = axisValue * (980/pow(2,18));
//        printf ("Aceleracion X %0.8f \n", aceleracion);
    }
//    printf ("ValAxes %lu \n", axisValue);

    // Calcula la aceleracion en gales (float)
    aceleracion = (double) (axisValue * (980/pow(2,18)));
//    printf ("Aceleracion X %0.8f \n", aceleracion);

    // Devuelve el valor calculado
    return aceleracion;
}
// *********************************************************************************************
// ********************** Fin Metodo ObtenerValorAceleracion ***********************************
// *********************************************************************************************



// *********************************************************************************************
// Metodo para iniciar el filtro FIR
// Consiste en iniciar en 0 el vectorMuestras
// *********************************************************************************************
void firFloatInit (void) {
    memset(vectorMuestras, 0, sizeof(vectorMuestras));
}
// *********************************************************************************************
// *************************** Fin Metodo firFloatInit *****************************************
// *********************************************************************************************



// *********************************************************************************************
// Metodo que permite aplicar un filtro FIR para un solo dato de entrada, devuelve el valor filtrado
// *********************************************************************************************
float calcular_Salida_Filtro (double *coeficientes, double valEntrada, int filterLength) {
    // Variable para acumular la suma de las multiplicaciones de las entradas por los coeficientes (convolucion)
    double valFiltrado;
    // Puntero para los coeficientes
    double *ptrCoeficientes;
    // Puntero para los datos de entrada
    double *ptrInput;
    int indiceFor;

    // Copia las muestras de entrada en el vector de datos, en la posicion final en funcion del # de coeficientes
    // memcpy(&vectorMuestras[filterLength - 1], dataInput, longitudInput*sizeof(double));
    vectorMuestras[filterLength - 1] = valEntrada;
//    printf ("Muestra 63 %f \n", vectorMuestras[filterLength - 1]);

    // Aplica el filtro al dato de entrada
    ptrCoeficientes = coeficientes;
    ptrInput = &vectorMuestras[filterLength - 1];
    valFiltrado = 0;
    for (indiceFor = 0; indiceFor < filterLength; indiceFor ++) {
        valFiltrado += (*ptrCoeficientes ++)*(*ptrInput --);
//        printf ("Filtro %f Muestra %f Multi %f Res %f ", datoFiltro, datoMuestra, multiplicacion, valFiltrado);
    }

    // Desplaza las muestras de entrada al inicio para utilizarlas en el siguiente calculo
    memmove(&vectorMuestras[0], &vectorMuestras[1], (filterLength - 1)*sizeof(double));

    return valFiltrado;
}
// *********************************************************************************************
// *********************** Fin Metodo calcular_Salida_Filtro ***********************************
// *********************************************************************************************



// *********************************************************************************************
// Metodo que permite calcular el valor de STA recursivo, depende del valor calculado en la iteracion
// anterior y una constante que depende del numero de muestras del STA (n_STA)
// Solo necesita como parametro la nueva muestra en tipo float y declarar al inicio el numero
// de muestras sobre las que se desea hacer el calculo. Ejemplo: #define n_STA = 5
// *********************************************************************************************
float calcular_STA_recursivo (float numRecibido) {
    // Se almacena el valor anterior de STA porque se requiere en la siguiente iteracion
    static float valSTA_ant = 0;
    // Variable que cuenta las muestras computadas, esto es porque mientras no se llegue a n_LTA muestras
    // Se debe retornar el valor de 0. Aun no se pueden considerar validos los datos
    static unsigned long contadorMuestras = 0;
    // Variable para elevar al cuadrado el numero recibido
    float numCuad_STA;
    // Variable que devuelve el valor calculado de STA
    float valSTA;

    // Primero eleva al cuadrado el numero
    numCuad_STA = pow(numRecibido, 2);

    // Aplica la fórmula del cálculo STA recursivo
    valSTA = valSTA_ant + (double)((numCuad_STA - valSTA_ant)/n_STA);
    // Guarda este valor calculado para la proxima iteracion
    valSTA_ant = valSTA;

//    printf ("Val STA %f \n", valSTA);

    // Solo si ya se llego al numero n_LTA (OJO LTA) devuelve el valor
    // EL aumento del contador se hace solo hasta llegar al numero n_LTA
    // Porque de no seguiria aumentando el contador de forma indeterminada
    if ((contadorMuestras + 1) >= n_LTA) {
        return valSTA;
    // Caso contrario aumenta en 1 el contador y devuelve 0
    } else {
        contadorMuestras ++;
        return 0;
    }
}
// *********************************************************************************************
// ********************** Fin Metodo calcular_STA_recursivo ************************************
// *********************************************************************************************


// *********************************************************************************************
// Metodo que permite calcular el valor de LTA recursivo, depende del valor calculado en la iteracion
// anterior y una constante que depende del numero de muestras del LTA (n_LTA)
// Solo necesita como parametro la nueva muestra en tipo float y declarar al inicio el numero
// de muestras sobre las que se desea hacer el calculo. Ejemplo: #define n_LTA = 5
// *********************************************************************************************
float calcular_LTA_recursivo (float numRecibido) {
    // Se almacena el valor anterior de STA porque se requiere en la siguiente iteracion
    static float valLTA_ant = 0;
    // Variable que cuenta las muestras computadas, esto es porque mientras no se llegue a n_LTA muestras
    // Se debe retornar el valor de 0. Aun no se pueden considerar validos los datos
    static unsigned long contadorMuestras = 0;
    // Variable para elevar al cuadrado el numero recibido
    float numCuad_LTA;
    // Variable que devuelve el valor calculado de STA
    float valLTA;

    // Primero eleva al cuadrado el numero
    numCuad_LTA = pow(numRecibido, 2);

    // Aplica la fórmula del cálculo STA recursivo
    valLTA = valLTA_ant + (double)((numCuad_LTA - valLTA_ant)/n_LTA);
    // Guarda este valor calculado para la proxima iteracion
    valLTA_ant = valLTA;

//    printf ("Val LTA %f \n", valLTA);

    // Solo si ya se llego al numero n_LTA (OJO LTA) devuelve el valor
    // EL aumento del contador se hace solo hasta llegar al numero n_LTA
    // Porque de no seguiria aumentando el contador de forma indeterminada
    if ((contadorMuestras + 1) >= n_LTA) {
        return valLTA;
    // Caso contrario aumenta en 1 el contador y devuelve 0
    } else {
        contadorMuestras ++;
        return 0;
    }
}
// *********************************************************************************************
// ********************** Fin Metodo calcular_STA_recursivo ************************************
// *********************************************************************************************




// *********************************************************************************************
// Metodo que permite calcular la relacion entre los dos valores STA y LTA, en caso de que alguno
// de ellos sea 0, devuelve 0
// *********************************************************************************************
float calcularRelacion_LTA_STA (float valSTA, float valLTA) {
    float sta_lta = 0;

    // Solo si ambos valores son distinto de 0, calcula la relacion
    // Si alguno es 0 significa que aun no se ha completado el numero de datos para el calculo
    if (valSTA != 0 && valLTA != 0) {
        sta_lta = valSTA/valLTA;
    }

    return sta_lta;
}
// *********************************************************************************************
// *************************** Fin Metodo calcularRelacion_LTA_STA *****************************
// *********************************************************************************************


// *********************************************************************************************
// Metodo que determina si hay o no evento en funcion del resultado de la relacion STA/LTA y los
// valores de trigger y detrigger. Cuando STA/LTA es >= trigger comienza el evento y termina
// cuando STA/LTA es menor que detrigger
// *********************************************************************************************
char calcularIsEvento(float resul_STA_LTA) {
    // Al inicio del programa no hay evento
    static char isEvento = 0;

    // Si no hay evento, analiza cuando supera el trigger al valor STA/LTA
    if (isEvento == 0) {
        // Si supera significa comienzo del evento
        if (resul_STA_LTA >= valTrigger) {
            isEvento = 1;
        }
    // Caso contrario, si hay evento, solo termina cuando STA/LTA es menor que detrigger
    } else {
        if (resul_STA_LTA < valDetrigger) {
            isEvento = 0;
        }
    }

    return isEvento;
}
// *********************************************************************************************
// ******************************** Fin Metodo ExtraerEvento **********************************
// *********************************************************************************************


// *********************************************************************************************
// Metodo para extraer el evento registrado por el metodo STA/LTA.
// Utiliza como parametros de entrada el nombre del archivo de registro continuo, el tiempo del evento y su duracion
// Invoca al programa ExtraerEventoBin.C, podria funcionar si se adapta este programa para que funcione como libreria,
// pero en ese caso es necesario que se ejecute dentro de un hilo para evitar que interfiera con el desarrollo del programa.
// *********************************************************************************************
void ExtraerEvento(char* nombreArchivoRegistro, unsigned int tiempoEvento, unsigned int duracionEvento){

	char parametroExtraerEvento[50];
	char nombreArchivoRegistroStr[16];
	char tiempoEventoStr[7];
	char duracionEventoStr[5];
	
	strcpy(nombreArchivoRegistroStr, nombreArchivoRegistro);
	sprintf(tiempoEventoStr, " %d ", tiempoEvento); 
	sprintf(duracionEventoStr, "%d", duracionEvento); 
	
	strcpy(parametroExtraerEvento, "/home/pi/Ejecutables/extraerevento ");
	strcat(parametroExtraerEvento, nombreArchivoRegistroStr);
	strcat(parametroExtraerEvento, tiempoEventoStr);
	strcat(parametroExtraerEvento, duracionEventoStr);
	
	system(parametroExtraerEvento);	
	
}
// *********************************************************************************************
// ******************************** Fin Metodo ExtraerEvento **********************************
// *********************************************************************************************
