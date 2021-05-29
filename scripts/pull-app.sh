#!/bin/bash
cd /var/www/html
rm -rf saleschamp

git clone https://github.com/themobileprof/saleschamp saleschamp
cd saleschamp
npm install
