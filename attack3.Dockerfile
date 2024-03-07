FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y ftp

# On va stocker ces commandes dans un fichier puis l'appeler au démarrage pour faire une requête FTP
# C'est un peu du bricolage mais ça nous permet d'avoir une requête FTP entière tout en gardant le conteneur ouvert
RUN echo "open 172.17.0.3" > /tmp/commandes_ftp
RUN echo "user test 1234" >> /tmp/commandes_ftp
RUN echo "ls" >> /tmp/commandes_ftp
RUN echo "bye" >> /tmp/commandes_ftp

# Commande lancée au démarrage pour garder le conteneur actif tout en lançant une requête ftp
CMD ftp -n < /tmp/commandes_ftp && tail -f /dev/null


