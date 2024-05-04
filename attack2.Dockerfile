FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y openssh-client

#Copie du script SSH et on le rend exécutable
COPY ssh.sh /
RUN chmod +x ssh.sh 
RUN sed -i -e 's/\r$//' ssh.sh
# Script lancé au démarrage pour effectuer une connexion SSH vers le Honeypot puis rester actif
CMD ./ssh.sh
