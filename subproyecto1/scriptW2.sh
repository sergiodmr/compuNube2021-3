#!/bin/bash
sudo apt-get update
sudo apt-get install lxd -y
echo "acceder al grupo"
newgrp lxd
lxd init --auto
echo "creando contenedor Web 2"
lxc launch ubuntu:18.04 contWeb2
sleep 5
echo "Instalando apache"
lxc exec contWeb2 sudo apt update && apt upgrade
sleep 5
lxc exec contWeb2 sudo -- apt-get install apache2 -y
sleep5
lxc exec contWeb2 systemctl enable apache2
echo "copiando index"
lxc  file push index2.html contWeb2/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb2 myport80 proxy listen=tcp:192.168.100.20:5080 connect=tcp:127.0.0.1:80
sleep 2
echo "reiniciando apache en contenedor web 1"
lxc exec contWeb2 -- systemctl restart apache2
# creacion de backup del contenedor web 3  backup del contenedor 1
echo "creando contenedor web 3 backup "
lxc launch ubuntu:18.04 contWeb3
sleep 5
echo "Instalando apache"
lxc exec contWeb3 sudo apt update && apt upgrade
sleep 5
lxc exec contWeb3 sudo -- apt-get install apache2 -y
sleep5
lxc exec contWeb3 systemctl enable apache2
echo "copiando index"
lxc file push index1b.html contWeb3/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb3 myport80 proxy listen=tcp:192.168.100.20:5081 connect=tcp:127.0.0.1:80
echo "reiniciando apache en contenedor web 2 backup"
lxc exec contWeb3 -- systemctl restart apache2


