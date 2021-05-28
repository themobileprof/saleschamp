#!/bin/bash

# Setup Updates
apt-get update -y

# Install Curl for the next action 
apt install curl git nginx -y

# Configure Git
git config --global user.name "saleschamp"
git config --global user.email samuelanyaele@gmail.com
git config --global pull.rebase false

# Download and run nvm installer
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Load NVM
. ~/.nvm/nvm.sh


# Install LTS Version of Node
nvm install node

mkdir ~/sites
cd ~/sites

# Clone the SalesChamp repo
git clone https://github.com/themobileprof/saleschamp.git ~/sites/saleschamp

# Install PM
npm install pm2@latest -g


# Run The NodeJS App in the background
pm2 start ~/sites/saleschamp/app.js
pm2 save

# Setup Nginx and SSH to allow on firewall
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 5000/tcp
ufw allow ssh


# Configure Nginx
cat <<EOF > /etc/nginx/sites-available/saleschamp
server {
	listen 80 default_server;

	location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable website
ln -s /etc/nginx/sites-available/saleschamp /etc/nginx/sites-enabled/


# Restart Nginx
systemctl restart nginx

