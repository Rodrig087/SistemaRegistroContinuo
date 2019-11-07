import os,sys,errno,pipes


#def Prueba():
    print ("creating pipe and connecting...")
    p = pipes.Template()
    fifo = "/tmp/myfifo"
    f = p.open(fifo,'r')
    try:
        algo = f.read()
    finally:
        f.close()
    print (algo)