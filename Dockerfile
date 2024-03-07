FROM ubuntu:20.04

# Installation des dépendances et de l'environnement
RUN apt update -y && \
    apt install -y ansible net-tools nano openssh-client python3-venv curl

# Copie des playbooks
COPY apache_installation.yml /etc/ansible
COPY rsyslog_client_installation.yml /etc/ansible
COPY rsyslog_server_installation.yml /etc/ansible
COPY ftp_installation.yml /etc/ansible
COPY ftp_configuration /etc/ansible
COPY apache2_installation.yml /etc/ansible


# Configuration de l'environnement de travail
WORKDIR /etc/ansible

#Exécution de la commande décommentant la ligne dans ansible.cfg
#Cela va nous permettre de travailler avec le fichier host dans l'environnement de travail défini précédemment
RUN sed -i 's/#inventory      = \/etc\/ansible\/hosts/inventory      = \/etc\/ansible\/hosts/' /etc/ansible/ansible.cfg

#Génère la clé publique SSH
RUN mkdir /root/.ssh
WORKDIR /root/.ssh
RUN ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa

#On configure un fichier host
RUN rm /etc/ansible/hosts
RUN touch /etc/ansible/hosts
RUN echo "[honeypot]" >> /etc/ansible/hosts
RUN echo "172.17.0.3" >> /etc/ansible/hosts
RUN echo "[rsyslog]" >> /etc/ansible/hosts
RUN echo "172.17.0.4" >> /etc/ansible/hosts

#On redéfinit notre espace de travail car nous étions dans /root/.ssh précédemment
WORKDIR /etc/ansible

# Commande lancée au démarrage pour garder le conteneur actif
CMD [ "sleep", "infinity" ]
