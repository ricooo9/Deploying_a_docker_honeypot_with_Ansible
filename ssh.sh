#!/bin/bash

# Boucle infinie pour maintenir la connexion SSH active
while true; do
    ssh -o StrictHostKeyChecking=no root@172.17.0.3
    # Attente de 1 heure avant de réessayer la connexion SSH (utile pour garder le conteneur ouvert)
    sleep 3600
done
