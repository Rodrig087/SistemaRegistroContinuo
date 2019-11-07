//Compilar: gcc Parent.c -o PrincipalPipes


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

int main(int argc, char **argv, char **envp) {
    pid_t childpid;
    int status;
    int test;
    int fd_a[2], fd_b[2];
    char *numbers = "3,5,7\n";

    test = 0;

    pipe(fd_a); //Create pipe
    pipe(fd_b);
    childpid = fork();

    if (childpid==(-1) ) {
        perror( "fork" );
        return -1;
    } else if (childpid==0) {
        //in child
        char *argument = "./Child.py";
        char fd0[20], fd1[20];
        snprintf(fd0, 20, "%d", fd_a[0]);
        snprintf(fd1, 20, "%d", fd_b[1]);
        close(fd_a[1]);
        close(fd_b[0]);
        char *python[] = {argument, fd0, fd1, NULL};
        execvp(argument, python);
    }
    close(fd_a[0]);
    close(fd_b[1]);

    //in parent
    write(fd_a[1], numbers, sizeof(numbers));
    close(fd_a[1]);

    waitpid(-1, &status, 0); //Wait for childprocess to finish
    char buffer[1024];

    while (read(fd_b[0], buffer, sizeof(buffer)) != 0) {} //Read pipe to buffer

    if (test < 0) { //If failed print error message or success message
        printf("Error: %s\n", buffer);
    } else {
        printf("%s\n", buffer);
    }

    return 0;
}