#!/bin/bash
cd /var/www/saleschamp
git pull
npm update
pm2 reload app
