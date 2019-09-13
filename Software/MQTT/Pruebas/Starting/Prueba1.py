import paho.mqtt.client as mqtt

broker_url = "m11.cloudmqtt.com"
broker_port = 10164

username = "cuxhjixd"
password = "tFroIaJunMc6"

client = mqtt.Client()
client.username_pw_set(username, password)
client.connect(broker_url,broker_port)

client.publish(topic="TestingTopic", payload="Hola RSA_PC 2", qos=1, retain=False)

client.loop_forever()