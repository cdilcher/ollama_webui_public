#!/usr/bin/env bash

# user needs to be root
if [ $(id -u) -ne 0 ];  then
  echo "Please run as root"
  exit
fi

echo "##################################################"
echo "# Starting up setup                              #"
echo "##################################################"
echo ""


# ensure that docker is installed
echo "#########################################################"
echo "# Ensuring that docker and docker compose are available #"
echo "#########################################################"
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release smartmontools apparmor gcc
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
cp ./daemon.json /etc/docker/daemon.json

# install NVIDIA container toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation
echo "#########################################################"
echo "# Installing NVIDIA CUDA Drivers                        #"
echo "#########################################################"
sudo add-apt-repository -y ppa:graphics-drivers
sudo apt update
sudo apt install -y nvidia-driver-560

# install NVIDIA container toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation
echo "#########################################################"
echo "# Installing NVIDIA Container Toolkit                   #"
echo "#########################################################"
AR
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

echo "#########################################################"
echo "# Configuring Docker to use Nvidia driver               #"
echo "#########################################################"
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "#########################################################"
echo "# Pull required images                                  #"
echo "#########################################################"
sudo docker pull ollama/ollama:latest
sudo docker pull ghcr.io/open-webui/open-webui:latest
sudo docker pull jonasal/nginx-certbot:5.4.0
sudo docker pull python:3.12-alpine

# start up
echo "##################################################"
echo "# Starting up the server cluster service         #"
echo "##################################################"
mkdir -p ./nginx/nginx_secrets/
mkdir -p ./ollama/.ollama/
mkdir -p ./ollama/models/
mkdir -p ./open-webui/
chmod +x ./model.sh

# wait to startup
#

# preload models
sudo ./model.sh "llama3.2" #8B parameters
sudo ./model.sh "nomic-embed-text"


echo "##################################################"
echo "# Setup Complete!                                #"
echo "# Please reboot server to enable NVidia drivers  #"
echo "##################################################"
echo ""
