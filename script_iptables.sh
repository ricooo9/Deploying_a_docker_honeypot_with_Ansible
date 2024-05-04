#!/bin/bash

LOG_FILE="/var/log/clients/172.17.0.3/syslog.log"
MARKDOWN_FILE="/var/www/html/index.html"
EXCLUDED_IP="172.17.0.2"

# Tableau pour stocker les adresses IP déjà rencontrées
declare -A ip_addresses

# Variables pour les statistiques des protocoles
total_http=0
total_ssh=0
total_ftp=0

# Fonction pour mettre à jour les statistiques et ajouter les informations sur les adresses IP
maj_stats() {
    total=$((total_http + total_ssh + total_ftp))
    pourcent_http=$((total_http * 100 / total))
    pourcent_ssh=$((total_ssh * 100 / total))
    pourcent_ftp=$((total_ftp * 100 / total))

    # Écrire les statistiques dans le fichier Markdown
    echo "<center> <h1> Statistiques generales </h1> </center>" > "$MARKDOWN_FILE"
    echo "<u><h3> Pourcentage des attaques par protocole </h3></u>" >> "$MARKDOWN_FILE"
    echo "<li>HTTP : $pourcent_http%" >> "$MARKDOWN_FILE"
    echo "<li>SSH : $pourcent_ssh%" >> "$MARKDOWN_FILE"
    echo "<li>FTP : $pourcent_ftp%" >> "$MARKDOWN_FILE"

    # Écrire les informations sur les adresses IP dans le fichier Markdown
    echo "<br>" >> "$MARKDOWN_FILE"
    echo "<u><h3> Details par IP </h3></u>" >> "$MARKDOWN_FILE"
    echo "<ul>" >> "$MARKDOWN_FILE"
    #On parcourt notre tableau d'IP
    for key in "${!ip_addresses[@]}"; do
        #On récupère seulement le protocole
        protocol="${key%,*}"
        #On récupère seulement l'IP
        ip_address="${key#*,}"
        echo "<li>IP : $ip_address, Protocole utilise : $protocol</li>" >> "$MARKDOWN_FILE"
    done
    echo "</ul>" >> "$MARKDOWN_FILE"
}

# Attente de la création du fichier de log au cas où aucun attaquant n'aurait requêté notre Honeypot
echo "Waiting for the log file to be created..."
while [ ! -f "$LOG_FILE" ]; do
    sleep 1
done

# Règle pour enregistrer les tentatives de connexion
iptables -A INPUT -p tcp --syn -j LOG --log-prefix "Honeypot Connection: " --log-ip-options --log-tcp-options
#Détail de la commande un peu longue :
# -p tcp -> On filtre sur les paquets TCP
# --syn -> On filtre les iniatialisations de connexion TCP
# -j LOG -> On journalise les paquets
# --log-prefix -> On précise un petit message histoire de comprendre quand on regarde nos IPtables pourquoi cette IP a été ajoutée
# --log-ip-options -> On inclut les options d'IP dans les logs
# --log-tcp-options -> On inclut les options TCP dans les logs


# Surveillance du fichier de journal en temps réel et ajout des adresses IP à la liste de bannissement
tail -n 0 -F "$LOG_FILE" | while read -r line; do
    # Extraire le protocole et l'adresse IP de la ligne du journal
    protocol="Unknown"
    ip_address=""

    if echo "$line" | grep -q "sshd"; then
        protocol="SSH"
        ip_address=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -n 1)
        #On récupère la dernière IP (car certains logs génèrent plusieurs fois la même ligne ce qui fausserait nos stats)
        #Cette récupération se fait grâce à une regex qui cherche un motif particulier (Une IP)
        if [ -n "$ip_address" ] && [ -z "${ip_addresses[$protocol,$ip_address]}" ]; then
            ((total_ssh++))
            ip_addresses[$protocol,$ip_address]="seen"
        fi
        #Plusieurs opérations sont effectuées : si l'IP n'est pas vide et qu'elle est bien composée du combo IP-Protocole
        #Si c'est le cas on incrémente notre compteur SSH et on indique dans notre tableau que cette IP a été vue, pour pas la recompter une prochaine fois
    elif echo "$line" | grep -q "apache-access"; then
        protocol="HTTP"
        ip_address=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n 1)
        if [ -n "$ip_address" ] && [ -z "${ip_addresses[$protocol,$ip_address]}" ]; then
            ((total_http++))
            ip_addresses[$protocol,$ip_address]="seen"
        fi
    elif echo "$line" | grep -q "vsftpd"; then
        protocol="FTP"
        ip_address=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n 1)
        if [ -n "$ip_address" ] && [ -z "${ip_addresses[$protocol,$ip_address]}" ]; then
            ((total_ftp++))
            ip_addresses[$protocol,$ip_address]="seen"
        fi
    fi

    # Vérifie si l'adresse IP est vide (mal parsée)
    if [ -n "$ip_address" ]; then
        # Vérifie si l'adresse n'est pas celle exclue (du conteneur master)
        if [ "$ip_address" = "$EXCLUDED_IP" ]; then
            continue
        fi
        #Ajoute l'adresse IP au fichier Markdown
        echo "<li>IP : $ip_address, Protocole utilisé : $protocol</li>" >> "$MARKDOWN_FILE"

        # Ajoute l'adresse IP à la liste de blocage iptables si elle n'est pas déjà présente et que ce n'est pas celle du master, ce serait embêtant sinon !
        if ! iptables -L INPUT -n | grep -q "$ip_address"; then
            echo "Banning IP: $ip_address"
            iptables -A INPUT -s "$ip_address" -j DROP
        fi

        # Mettre à jour les statistiques
        maj_stats
    fi
done
