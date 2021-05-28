#!/bin/bash

# Setup Updates
sudo apt update -y

# Install Curl for the next action 
sudo apt install curl git nginx -y

# Setup Nginx and SSH to allow on firewall
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sudo ufw allow 5000/tcp
sudo ufw allow ssh


# Configure Nginx
sudo cat <<EOF > /etc/nginx/sites-available/default
server {
	listen 80 default_server;

	location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF


# Restart Nginx
sudo systemctl restart nginx

# Download and run Nodejs LTS installer
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM
npm install pm2@latest -g
pm2 startup


# Go to the www directory
cd /var/www/html

# Clone the SalesChamp repo
git clone https://github.com/themobileprof/saleschamp.git /var/www/html/saleschamp


# Create a PM2 Group
groupadd pm2

# Change www directorygroup owner to group pm2
chgrp -R pm2 /var/www/html/saleschamp

# Add "ubuntu" to pm2 group
usermod -aG pm2 ubuntu

# Create an Alias
echo "alias pm2='env HOME=/var/www pm2'" > /etc/profile.d/00-pm2.sh





# Go to the saleschamp directory
cd /var/www/html/saleschamp

# Run The NodeJS App in the background
pm2 start app.js
pm2 save

