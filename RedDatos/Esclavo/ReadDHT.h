void StartSignal(){
     TRISB4_bit = 0;                                     //Configure RD0 as output
     RB4_bit = 0;                                        //RD0 sends 0 to the sensor
     delay_ms(18);
     RB4_bit = 1;                                        //RD0 sends 1 to the sensor
     delay_us(30);
     TRISB4_bit = 1;                                     //Configure RD0 as input
}

void CheckResponse(){
     Check = 0;
     delay_us(40);
     if (RB4_bit == 0){
        delay_us(80);
        if (RB4_bit == 1){
           Check = 1;
           delay_us(40);
        }
     }
}

char ReadData(){
     char i, j;
     for(j = 0; j < 8; j++){
           while(!RB4_bit);                              //Espera hasta RB4 pase a alto
           delay_us(30);
           if(RB4_bit == 0){
                i&= ~(1<<(7 - j));                       //Clear bit (7-b)
           }else {
                i|= (1 << (7 - j));                      //Set bit (7-b)
                while(RB4_bit);                          //Espera hasta RB4 pase a bajo
           }
     }
     return i;
}

void Calcular(){

     StartSignal();
     CheckResponse();
     if(Check == 1){
              RH_byte1 = ReadData();
              RH_byte2 = ReadData();
              T_byte1 = ReadData();
              T_byte2 = ReadData();
              Sum = ReadData();
              if(Sum == ((RH_byte1+RH_byte2+T_byte1+T_byte2) & 0XFF)){
                     ITemp = T_byte1;
                     ITemp = (ITemp << 8) | T_byte2;
                     IHmd = RH_byte1;
                     IHmd = (IHmd << 8) | RH_byte2;
                     ITemp = ITemp/10;
                     IHmd = IHmd/10;

                     if (ITemp > 0X8000){                //Temperatura negativa
                        ITemp = 0;
                        IHmd = 0;
                     }

               } else {
                 ITemp = 100;
                 IHmd = 100;
               }
     } else {
        ITemp = 200;
        IHmd = 200;
     }

     chTemp = (unsigned char *) & ITemp;                 //Asocia el valor calculado de Temperatura al puntero chTemp
     chHmd = (unsigned char *) & IHmd;                   //Asocia el valor calculado de Temperatura al puntero chTemp

}