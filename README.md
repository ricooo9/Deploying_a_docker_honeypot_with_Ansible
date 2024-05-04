# Deploying a docker honeypot with Ansible
Automate the deployment of a docker with an Apache site, an SSH and FTP service running on it serving as a honeypot, a RSYSLOG docker that receives logs from this container and, using a script, create iptables flow rules to block these IPs on the RSYSLOG server to protect it.

Automate the deployment of attacking machines that will attempt to access the honeypot via various services and trigger the security mechanisms. 
Monitor and analyze access attempts to continually improve the security system by feeding a database of malicious IPs.
Generate an HTML page to display statistics on the number of IPs blocked, the services impacted...

## Specifications

1. **Automatic deployment of the container with Apache and all other services:** The Dockerfile and playbooks must enable automatic deployment of the container with a running Apache site, SSH and FTP. This container will act as a honeypot, designed to attract and list malicious IPs. If we apply this configuration in real life, malicious IPs will very often be automatic scanners running on the Internet, looking for vulnerable protocol versions to exploit later.
2. **RSYSLOG container deployment automation:** Another docker needs to be deployed automatically to receive logs from the Apache site and its other services. Using playbooks and scripts, this container should be able to create real-time flow rules to block malicious IPs. In this way, our honeypot acts as a "bulwark", preventing anything that affects the honeypot from affecting our syslog.
3. **Automatic deployment of attack containers:** The script must also enable automatic deployment of attack containers designed to attempt to access the honeypot site and its services in order to trigger its security mechanisms.
4. **Monitoring and analysis of access attempts:** The RSYSLOG system must continuously monitor access attempts to the honeypot and analyze this data to improve the security system. The information gathered should be used to generate statistics on a web page, which it will display.

**Security integration:** Iptables will add a layer of security by blocking IPs collected in my RSYSLOG collection well.

**Technology watch integration:** Thanks to the markdown file and the continuous operation of SYSLOG, we'll be able to track attacks live and see which IPs have been blocked and what protocol was used.

## Infrastructure required :

On my job I'll be working mainly with 3 types of files: Dockerfile to create images and then launch containers based on these images, playbook in YAML format to automate the configuration of my containers and finally scripts to perform other configuration tasks such as creating flow rules.

# User documentation

## First step :

You need to download the main folder containing all the files, then go to its root.

Then launch Docker, open a cmd in the downloaded folder and copy and paste these commands.

```powershell
git clone https://github.com/ricooo9/Deploying_a_docker_honeypot_with_Ansible.git
cd .\Deploying_a_docker_honeypot_with_Ansible\
docker build -t image_ansible -f Dockerfile .
docker container run -d --name ansible image_ansible
docker cp ansible:/root/.ssh/id_rsa.pub authorized_keys
docker build -t image_infra -f infra.Dockerfile .
docker build -t image_rsyslog -f rsyslog.Dockerfile .
docker build -t image_attaquant1 -f attack1.Dockerfile .
docker build -t image_attaquant2 -f attack2.Dockerfile .
docker build -t image_attaquant3 -f attack3.Dockerfile .
docker container run -d --name honeypot image_infra
docker container run --cap-add=NET_ADMIN -d -p 80:80 --name rsyslog image_rsyslog
docker exec -it ansible /bin/bash
```

## Second step :

Then, once inside the container, type these commands. For the first 2 commands, you'll need to type "yes" for the first SSH connection to the container :

```powershell
ansible-playbook apache_installation.yml
ansible-playbook apache2_installation.yml
ansible-playbook ftp_installation.yml
ansible-playbook rsyslog_server_installation.yml
ansible-playbook rsyslog_client_installation.yml
exit

./deploiement.ps1
```

Once these commands had been typed, the containers were created and the attackers launched their attacks. This means that the syslog server should have updated its Apache page with information about these attacks :

Adress : http://localhost:80
