#line 1 "C:/Users/Ivan/Desktop/Milton Muñoz/Proyectos/Git/Instrumentacion Presa/InstrumentacionPCh/Firmware/Vertedero/DSP/dsPIC/CALCULO_VELOCIDADSONIDO.c"

float CalcularVelocidadSonido(){
 float temperatura_Float, VSnd, temperatura_Frac;
 unsigned int temperatura, temperatura_int;

 Ow_Reset(&PORTA, 0);
 Ow_Write(&PORTA, 0, 0xCC);
 Ow_Write(&PORTA, 0, 0x44);
 Delay_us(100);

 Ow_Reset(&PORTA, 0);
 Ow_Write(&PORTA, 0, 0xCC);
 Ow_Write(&PORTA, 0, 0xBE);
 Delay_us(100);

 temperatura = Ow_Read(&PORTA, 0);
 temperatura = (Ow_Read(&PORTA, 0) << 8) + temperatura;

 if (temperatura & 0x8000) {
 temperatura = 0;
 }

 temperatura_int = temperatura >> 4;
 temperatura_Frac = ((temperatura & 0x000F) * 625) / 10000.;
 temperatura_Float = temperatura_Int + temperatura_Frac;

 VSnd = 331.45 * sqrt(1+(temperatura_Float/273));

 return VSnd;

}
