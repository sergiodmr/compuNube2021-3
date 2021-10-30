#!/bin/bash
sudo apt-get update
sudo apt-get install lxd -y
echo "acceder al grupo"
newgrp lxd
lxd init --auto
echo "creando contenedor Web 1"
lxc launch ubuntu:18.04 contWeb1
sleep 5
echo "Instalando apache"
lxc exec contWeb1 sudo apt update && apt upgrade
sleep 5
lxc exec contWeb1 sudo -- apt-get install apache2 -y
sleep5
lxc exec contWeb1 systemctl enable apache2
echo "copiando index"
lxc  file push index1.html contWeb1/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb1 myport80 proxy listen=tcp:192.168.100.10:5080 connect=tcp:127.0.0.1:80
sleep 2
echo "reiniciando apache en contenedor web 1"
lxc exec contWeb1 -- systemctl restart apache2
# creacion de backup del contenedor web 4 backup del contenedor 2
echo "creando contenedor web 4 backup "
lxc launch ubuntu:18.04 contWeb4
sleep 5
echo "Instalando apache"
lxc exec contWeb4 sudo apt update && apt upgrade
sleep 5
lxc exec contWeb4 sudo -- apt-get install apache2 -y
sleep5
lxc exec contWeb4 systemctl enable apache2
echo "copiando index"
lxc file push index2b.html contWeb4/var/www/html/index.html
echo "redireccionando puertos"
lxc config device add contWeb4 myport80 proxy listen=tcp:192.168.100.10:5081 connect=tcp:127.0.0.1:80
echo "reiniciando apache en contenedor web 2 backup"
lxc exec contWeb4 -- systemctl restart apache2
