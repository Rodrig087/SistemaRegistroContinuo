import os 
import psutil
import time

path = "/home/rsa/TMP/consumo.txt"

#from ina219 import INA219

# Return CPU temperature as a character string                                      
def getCPUtemperature():
    res = os.popen('vcgencmd measure_temp').readline()
    return(res.replace("temp=","").replace("'C\n",""))

# Return RAM information (unit=kb) in a list                                        
# Index 0: total RAM                                                                
# Index 1: used RAM                                                                 
# Index 2: free RAM                                                                 
def getRAMinfo():
    p = os.popen('free')
    i = 0
    while 1:
        i = i + 1
        line = p.readline()
        if i==2:
            return(line.split()[1:4])

# Return % of CPU used by user as a character string                                
def getCPUuse():
    return(str(os.popen("top -n1 | awk '/Cpu\(s\):/ {print $2}'").readline().strip(\
)))

#Configuracion del sensor de corriente INA219
# ina = INA219(shunt_ohms=0.1, max_expected_amps = 0.6, address=0x40)
# ina.configure(voltage_range=ina.RANGE_16V, gain=ina.GAIN_AUTO, bus_adc=ina.ADC_128SAMP, shunt_adc=ina.ADC_128SAMP)

#Metodo para anadir una linea de texto al archivo
def anadirLinea(posicion,texto):
	contenido=file(path).read().splitlines()
	contenido.insert(posicion,texto)
	f=file(path, "w")
	f.writelines("\n".join(contenido))
#anadirLinea(0,"Fecha-Hora     CPU_Temp['C]     CPU_Uso[%]     RAM_Uso[MB]     Voltaje[V]     Corriente[mA]     Potencia[W]")

#Metodso para verificar si existe el archivo de texto
if os.path.isfile(path)==False:
	f=open(path, "w")
	#f.write("Fecha-Hora CPU_Temp['C] CPU_Uso[%] RAM_Uso[MB] Voltaje[V] Corriente[mA] Potencia[W]\r\n")
	f.write("Fecha-Hora CPU_Temp['C] CPU_Uso[%] RAM_Uso[MB]\r\n")
	f.close()

#print "      Fecha-Hora            CPU_Temp['C]      CPU_Uso[%]      RAM_Uso[MB]      Voltaje[V]      Corriente[mA]      Potencia[W]\r\n"

try:
	
	while(1):
		
		#Obtiene el tiempo del sistema
		segundos = time.time()
		tiempo = time.localtime(segundos)
		
		if tiempo.tm_sec==0 and tiempo.tm_min%20==0:
		
			fecha = str(tiempo.tm_year)+"/"+str('%02d' %(tiempo.tm_mon))+"/"+str('%02d' %(tiempo.tm_mday))
			hora = str('%02d' %(tiempo.tm_hour))+":"+str('%02d' %(tiempo.tm_min))+":"+str('%02d' %(tiempo.tm_sec))
			
			CPU_temp = getCPUtemperature()
			CPU_usage = str('%04.1f' %(psutil.cpu_percent(interval=None, percpu=False)))
			RAM_stats = getRAMinfo()
			RAM_used = str('%06.1f' %(round(int(RAM_stats[1]) / 1000,1)))
			
			# v = ina.voltage()
			# i = ina.current()
			# p = v*(i/1000)
			# voltaje = str('%05.2f' %(v))
			# corriente = str('%06.2f' %(i))
			# potencia = str('%05.2f' %(p)) 
		
			#print fecha+"-"+hora+"            "+CPU_temp+"            "+CPU_usage+"            "+RAM_used+"            "+voltaje+"            "+corriente+"            "+potencia+"\r\n"
			#dato = fecha+"-"+hora+" "+CPU_temp+" "+CPU_usage+" "+RAM_used+" "+voltaje+" "+corriente+" "+potencia+"\r\n"
			dato = fecha+"-"+hora+" "+CPU_temp+" "+CPU_usage+" "+RAM_used+"\r\n"
			f=open(path, "a+")
			f.write(dato)
			f.close()
			
			
			time.sleep(2)

except KeyboardInterrupt:
	
	print ("\nCtrl-C presionado.  Saliendo del programa...")
		
		
		
