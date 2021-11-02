#!/bin/bash
echo "Actualizando librerias"
echo "instalando lxd"
sudo apt update && sudo apt upgrade -y
sudo snap install lxd
#echo "Instalando lxd"
#sudo apt-get install lxd -y
sleep 5
echo "acceder al grupo"
newgrp lxd

echo "leyendo certificado"
certificado=$(cat "/vagrant/cluster.txt")

echo "Creando cluster de contWeb1"
cat <<EOF | sudo lxd init --preseed
config:
  core.https_address: 192.168.100.120:8443
networks:
- config:
    ipv4.address: 10.162.123.1/24
    ipv4.nat: "true"
    ipv6.address: fd42:aa3:a513:1898::1/64
    ipv6.nat: "true"
  description: ""
  managed: true
  name: lxdbr0
  type: bridge
- config:
    bridge.mode: fan
    fan.underlay_subnet: 192.168.100.0/24
  description: ""
  managed: true
  name: lxdfan0
  type: bridge
storage_pools:
- config:
    source: ""
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
cluster:
  server_name: machine2
  enabled: true
  member_config: []
  cluster_address: 192.168.100.130:8443
  cluster_certificate: "$certificado"
  server_address: ""
  cluster_password: admin
EOF
sleep 5
echo "creando contenedor Web 2"
sudo lxc launch ubuntu:18.04 contWeb2 --target machine2 < /dev/null
sleep 5
echo "Instalando apache"
lxc exec contWeb2 -- sudo apt update && sudo apt upgrade -y
sleep 5
lxc exec contWeb2 -- sudo apt install apache2 -y
sleep 5
lxc exec contWeb2 -- sudo systemctl enable apache2
echo "copiando index"
lxc file push index2.html contWeb2/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb2 myport80 proxy listen=tcp:192.168.100.120:8080 connect=tcp:127.0.0.1:80
sleep 2
echo "reiniciando apache en contenedor web 1"
lxc exec contWeb2 -- sudo systemctl restart apache2
# creacion de backup del contenedor web 3  backup del contenedor 1
echo "creando contenedor web 3 backup "
sudo lxc launch ubuntu:18.04 contWeb3 --target machine2 < /dev/null
sleep 5
echo "Actualizando contenedor"
lxc exec contWeb3 -- sudo apt update && sudo apt upgrade -y
sleep 5
echo "Instalando apache"
lxc exec contWeb3 -- sudo apt install apache2 -y
sleep 5
lxc exec contWeb3 -- sudo systemctl enable apache2
echo "copiando index"
lxc file push index1b.html contWeb3/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb3 myport80 proxy listen=tcp:192.168.100.120:8081 connect=tcp:127.0.0.1:80
echo "reiniciando apache en contenedor web 2 backup"
lxc exec contWeb3 -- sudo systemctl restart apache2