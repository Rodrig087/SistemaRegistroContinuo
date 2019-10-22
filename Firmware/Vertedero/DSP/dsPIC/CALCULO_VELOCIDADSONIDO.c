
float ObtenerTemperatura(){
      
      float temperatura_Float, temperatura_Frac;
      unsigned int temperatura, temperatura_int;
      
      Ow_Reset(&PORTA, 0);                                                       //Onewire reset signal
      Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
      Ow_Write(&PORTA, 0, 0x44);                                                 //Issue command CONVERT_T
      Delay_us(100);

      Ow_Reset(&PORTA, 0);
      Ow_Write(&PORTA, 0, 0xCC);                                                 //Issue command SKIP_ROM
      Ow_Write(&PORTA, 0, 0xBE);                                                 //Issue command READ_SCRATCHPAD
      Delay_us(100);

      temperatura =  Ow_Read(&PORTA, 0);
      temperatura = (Ow_Read(&PORTA, 0) << 8) + temperatura;

      if (temperatura & 0x8000) {
         temperatura = 0;                                                        //Si la temperatura es negativa la establece como cero.
      }

      temperatura_int = temperatura >> 4;                                        //Extrae la parte entera de la respuesta del sensor
      temperatura_Frac = ((temperatura & 0x000F) * 625) / 10000.;                //Extrae la parte decimal de la respuesta del sensor
      temperatura_Float = temperatura_Int + temperatura_Frac;                    //Expresa la temperatura en punto flotante

      return  temperatura_Float;

}

float CalcularVelocidadSonido(){

     float temperatura_Float, vSonido;
     temperatura_Float = ObtenerTemperatura();
     vSonido = 331.45 * sqrt(1+(temperatura_Float/273));
     return vSonido;
     
}