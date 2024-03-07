# Deploying a docker honeypot with Ansible
Automate the deployment of a docker with an Apache site, an SSH and FTP service running on it serving as a honeypot, a RSYSLOG docker that receives logs from this container and, using a script, create iptables flow rules to block these IPs on the RSYSLOG server to protect it.
