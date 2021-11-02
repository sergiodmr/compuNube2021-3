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

echo "creando Cluster"
cat <<EOF | lxd init --preseed
config:
  core.https_address: 192.168.100.130:8443
  core.trust_password: admin
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 192.168.100.0/24
  description: ""
  managed: false
  name: lxdfan0
  type: ""
storage_pools:
- config: {}
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
cluster:
  server_name: servidorHA
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
EOF

echo "creando certificado"
sed ':a;N;$!ba;s/\n/\n\n/g' /var/lib/lxd/cluster.crt > /vagrant/cluster.txt
sleep 2
echo "creacion contenedor"

#lxd init --auto
echo "iniciar HAProxy"
lxc launch ubuntu:18.04 haproxy --target servidorHA < /dev/null
sleep 5
echo "actualizando e instalando HA"
lxc exec haproxy -- sudo apt update && sudo apt upgrade -y
sleep 5
lxc exec haproxy -- sudo apt install -y haproxy
sleep 5
lxc exec haproxy -- sudo systemctl enable haproxy 
sleep 2
echo "Copiando haproxy.cfg"
lxc file push /vagrant/haproxy.cfg haproxy/etc/haproxy/haproxy.cfg 
sleep 2
echo "Copiando pagina error"
lxc file push /vagrant/503.http haproxy/etc/haproxy/errors/503.http
sleep 2
echo " Validar HAProxy"
lxc exec haproxy -- sudo systemctl restart haproxy
sleep 2
echo "redireccionando puertos"
lxc config device add haproxy http proxy listen=tcp:192.168.100.130:8080 connect=tcp:127.0.0.1:80
#lxc config device add haproxy http proxy listen=tcp:192.168.100.11:8080 connect=tcp:127.0.0.1:80
sleep 5




