#!/bin/bash

#############################################################
#
# Author : Krishna Pavan
# Date: 12/04/2026
# Description: Install Java Jenkins and some usefull tools on Ubuntu
# Version : 1.0
#
#############################################################

set -e

echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing Java..."
sudo apt install openjdk-21-jdk -y

echo "Now Jenkins is being installed..."

# Add Jenkins key and repo
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update

# Install Jenkins
sudo apt install jenkins -y

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Installation of Jenkins is completed successfully"

echo "Installing some usefoll tools for good debuging"

sudo apt install tree net-tools -y
