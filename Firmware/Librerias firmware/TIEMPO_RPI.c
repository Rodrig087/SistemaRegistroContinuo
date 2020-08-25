//Libreria para el manejo del tiempo del RPI

/////////////////////////////////////////// Definicion de funciones ///////////////////////////////////////////
unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi);
unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi);

///////////////////////////////////////////        Funciones        ///////////////////////////////////////////

//Funcion para transformar la fecha de la trama de tiempo de la Rpi
unsigned long RecuperarFechaRPI(unsigned short *tramaTiempoRpi){

     unsigned long fechaRPi;

     fechaRPi = ((long)tramaTiempoRpi[0]*10000)+((long)tramaTiempoRpi[1]*100)+((long)tramaTiempoRpi[2]);      //10000*dd + 100*mm + aa

     return fechaRPi;

}

//Funcion para transformar la fecha de la trama de tiempo de la Rpi
unsigned long RecuperarHoraRPI(unsigned short *tramaTiempoRpi){

     unsigned long horaRPi;

     horaRPi = ((long)tramaTiempoRpi[3]*3600)+((long)tramaTiempoRpi[4]*60)+((long)tramaTiempoRpi[5]);      //Calcula el segundo actual = hh*3600 + mm*60 + ss      
   
     return horaRPi;

}
