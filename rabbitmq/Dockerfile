# Gunakan image resmi sebagai basis
FROM rabbitmq:3-management

# Langkah 2/4: Update package list dan instal wget
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# BARIS INI YANG DIUBAH: Mengganti tag download menjadi '/download/v3.13.0/'
RUN wget https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v3.13.0/rabbitmq_delayed_message_exchange-3.13.0.ez -P /opt/rabbitmq/plugins/

# Aktifkan plugin secara permanen dalam image
RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange
