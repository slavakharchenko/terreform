#!/bin/bash
sudo yum update -y
sudo yum install -y httpd.x86_64
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo chown -R $USER:$USER /var/www
sudo echo "<h2 style='color: red;'> Launch template -> Autoscaling group -> Application load balancer from $(hostname -f)</h2>" > /var/www/html/index.html
