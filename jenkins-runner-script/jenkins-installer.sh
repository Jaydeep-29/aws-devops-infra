#!/bin/bash
set -e  # Exit on error

# Update system
sudo apt-get update && sudo apt upgrade -y

# Install required packages
sudo apt-get install -y python3 python3-pip python3-venv git ufw unzip curl

# Allow SSH access BEFORE enabling firewall
sudo ufw allow 22/tcp

# install java
sudo apt update
sudo apt-get install -y openjdk-21-jdk


# --------------------
# Install Jenkins
# --------------------
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
yes | sudo apt-get install jenkins
sleep 10  # Give Jenkins time to start

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# --------------------
# Install Terraform
# --------------------
echo "Installing Terraform 1.10.5..."
wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip
unzip terraform_1.10.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.10.5_linux_amd64.zip  # Clean up


wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# --------------------
# Deploy Django App
# --------------------
sudo -u ubuntu bash <<EOF

# Navigate to home directory
cd /home/ubuntu

# Clone the Django project
git clone https://github.com/Jaydeep-29/python-django-crud.git || true
cd python-django-crud

# Set up a Python virtual environment
python3 -m venv env
source env/bin/activate

# Upgrade pip and install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Apply database migrations
python3 manage.py migrate

# Start Django app on port 8000
nohup python3 manage.py runserver 0.0.0.0:8000 &

EOF

# --------------------
# Enable Firewall (Last Step)
# --------------------
sudo ufw allow 8080  # Jenkins
sudo ufw allow 8000  # Django
sudo ufw --force enable  # Enable firewall

