#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>High Availability Demo: Kashish Omar</h1><p>Server ID: $(hostname)</p>" > /var/www/html/index.html
systemctl start nginx
systemctl enable nginx