FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y net-tools nano openssh-server

#Ajout du directory .ssh, copie de la clé pub, ajustement du fichier de conf ssh et restart du service ssh
RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Commande d'entrée pour garder le conteneur actif et démarrer SSH
CMD service ssh restart && sleep infinity
