#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_BUF 1024

int main(){
    int fd;
    char *myfifo = "/tmp/myfifo";
    char *menu;
	printf("Iniciando...\n");
    // create FIFO pipe
    mkfifo(myfifo, 0666);

    while(1){
		// open the pipe for writing, and send a message to the client
        printf("Abriendo pipe...\n");
		fd = open(myfifo, O_WRONLY);
            //fd = open(myfifo, O_NONBLOCK);
            //fd = open(myfifo, O_RDONLY);
        menu = "conectado a servidor con PIPE Escribe 'exit' para desconexión\n";
        write(fd, menu, 1000);
        close(fd);
        sleep(10);
    }

    // remove the pipe
        unlink(myfifo);

        return 0;
}