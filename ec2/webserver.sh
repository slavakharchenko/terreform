#!/bin/bash
#yum update -y
#yum install -y httpd.x86_64
#systemctl start httpd.service
#systemctl enable httpd.service
#echo "Hello World from $(hostname -f)" > /var/www/html/index.html

sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Test AWS</h1>" | sudo tee /var/www/html/index.html