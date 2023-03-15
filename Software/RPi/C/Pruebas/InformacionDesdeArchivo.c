//gcc /home/pi/Programas/Pruebas/Archivos.c -o /home/pi/Programas/Pruebas/pruebaarchivos

//path: /home/rsa/Resultados/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char idEstacion[10] char pathRegistro[60];
char pathEventos[60];
char pathTMP[60];
char extBin[5];
char extTxt[5];
char extTmp[5];
char nombreArchivo[100];

FILE *ficheroInformacion;

unsigned short longitud1, longitud2, longitud3, longitud4, longitud5;

int main(void)
{

	//Abre el fichero de datos de configuracion:
	ficheroInformacion = fopen("Informacion.txt", "rt");
	//Recupera el contenido del archivo en la variable arg1 hasta que encuentra el carácter de fin de línea (\n):
	fgets(idEstacion, 10, ficheroInformacion);
	fgets(pathRegistro, 60, ficheroInformacion);
	fgets(pathEventos, 60, ficheroInformacion);
	fgets(pathTMP, 60, ficheroInformacion);
	//Cierra el fichero de informacion:
	fclose(ficheroInformacion);

	//Elimina el caracter de fin de linea (\n):
	strtok(idEstacion, "\n");
	strtok(pathRegistro, "\n");
	strtok(pathEventos, "\n");
	strtok(pathTMP, "\n");
	//Elimina el caracter de retorno de carro (\r):
	strtok(idEstacion, "\r");
	strtok(pathRegistro, "\r");
	strtok(pathEventos, "\r");
	strtok(pathTMP, "\r");

	//Asigna el texto correspondiente a los array de carateres:
	strcpy(extBin, ".bin");
	strcpy(extTxt, ".txt");
	strcpy(extTmp, ".tmp");

	//Realiza la concatenacion de arrays:
	strcat(nombreArchivo, pathRegistro);
	strcat(nombreArchivo, idEstacion);
	strcat(nombreArchivo, extBin);

	longitud1 = strlen(idEstacion);
	longitud2 = strlen(pathRegistro);
	longitud3 = strlen(pathEventos);
	longitud4 = strlen(pathTMP);
	longitud5 = strlen(nombreArchivo);

	printf("%d\n", longitud1);
	printf("%d\n", longitud2);
	printf("%d\n", longitud3);
	printf("%d\n", longitud4);
	printf("%d\n", longitud5);

	puts(idEstacion);
	puts(pathRegistro);
	puts(pathEventos);
	puts(pathTMP);
	puts(nombreArchivo);

	//free(nombreArchivo);
}
