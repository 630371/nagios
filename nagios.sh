#!/bin/bash

# Update the package list
sudo yum update -y

# Install prerequisites
sudo yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip

# Create a user and group for Nagios
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios

# Download and install Nagios Core
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar -zxvf nagios-4.4.6.tar.gz
cd nagios-4.4.6
./configure --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode
sudo make install-webconf

# Set up Apache for Nagios
sudo usermod -G nagcmd apache
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Install Nagios Plugins
cd /tmp
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -zxvf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
sudo make install

# Start and enable Nagios and Apache
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start nagios
sudo systemctl enable nagios

# Open necessary ports in the firewall
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Print Nagios access information
echo "Nagios installation is complete."
echo "You can access the Nagios web interface at http://your-ec2-instance-public-ip/nagios"
echo "Login with username: nagiosadmin and the password you set during installation."

# End of script
