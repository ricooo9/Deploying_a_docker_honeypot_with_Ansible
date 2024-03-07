FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y curl 

# Commande d'entrée pour garder le conteneur actif et joindre la page Web du Honeypot
CMD curl 172.17.0.3 && sleep infinity