FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y net-tools nano openssh-server iptables

#Ajout du directory .ssh, copie de la clé pub, ajustement du fichier de conf ssh et restart du service ssh
RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#Copie du script qui va ajouter les règles de flux
#On le rend également exécutable
COPY script_iptables.sh /
RUN chmod +x script_iptables.sh

#Exposition du port 80 de sorte à visualiser le site Web depuis la machine hôte
EXPOSE 80

# Commande lancée au démarrage pour garder le conteneur actif, lancer le service SSH et lancer le script Iptables
CMD service ssh restart && ./script_iptables.sh & sleep infinity