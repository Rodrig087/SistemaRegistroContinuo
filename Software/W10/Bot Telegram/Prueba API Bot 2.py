import telebot 
import time

# instanciamos el bot de Telegram
bot = telebot.TeleBot('6208005709:AAGfEH4BmxypLKtCsnnAE_FkDuyPuixaV-I')

# responde al comando /start
@bot.message_handler(commands=["start", "ayuda", "help"])
def cmd_start(message):
    bot.reply_to(message, "Hola mundo")
    
#responde a los mensajes de texto que no son comandos
@bot.message_handler(content_types=["text"])
def bot_mensajes_texto(message):
    """Gestiona los mensajes recibidos"""
    if message.text.startswith("/"):
        bot.send_message(message.chat.id, "Comando no disponible")
    else:
        mensajeRespuesta = bot.send_message(message.chat.id, "Mensaje recibido")
        time.sleep(3)
        bot.delete_message(message.chat.id, mensajeRespuesta.message_id)
        bot.delete_message(message.chat.id, message.message_id)
    
if __name__=='__main__':
    print('Iniciando el bot')
    bot.infinity_polling()
    print('Fin')