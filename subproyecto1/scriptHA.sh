#!/bin/bash
sudo apt-get install lxd -y
sleep 5
echo "acceder al grupo"
newgrp lxd
lxd init --auto
echo "iniciar HAProxy"
lxc launch ubuntu:18.04 haproxy
sleep 5
echo "actualizando e instalando HA"
lxc exec haproxy sudo apt update && apt upgrade -y
sleep 5
lxc exec haproxy sudo apt install haproxy -y
sleep 5
lxc exec haproxy systemctl enable haproxy 

echo -e "-- Configuring HAProxy\n"
lxc exec haproxy sudo tee /etc/haproxy/haproxy.cfg <<EOF

backend web-backend
    balance roundrobin 
    stats enable 
    stats auth admin:admin
    stats uri /haproxy?stats
    server contWeb1 192.168.100.10:5080 check
    server contWeb2 192.168.100.20:5080 check
    server contWeb3 192.168.100.10:5081 check 
    server contWeb4 192.168.100.20:5081 check
frontend http
    bind *:80
    default_backend web-backend
EOF

echo " Validar HAProxy"

lxc exec haproxy systemctl start haproxy
echo "redireccionando puertos"
lxc config device add haproxy myport80 proxy listen=tcp:192.168.100.30:1080 connect=tcp:127.0.0.1:80
sleep 5




