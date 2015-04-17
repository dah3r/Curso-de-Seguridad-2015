IPT=/usr/bin/iptables
#Red externa
EXT=enp0s3 #En este caso es la subred 10.0.2.0
#Red interna
LAN=enp0s8 #En este caso es la subred 192.168.1.0
#Rango de ips locales (LAN)
IPRANGE=192.168.1.0/24

#DEFAULT RULES
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT 
$IPT -P FORWARD ACCEPT

#Reset former rules to avoid conflicts
$IPT -F
$IPT -F -t nat
$IPT -X

#Esto es para que una vez que la conexion este establecida no vuelva a estar chequeando los paquetes

$IPT -A FORWARD -s 192.168.1.0/24 -j ACCEPT
$IPT -A FORWARD -s 192.168.2.0/24 -j ACCEPT
$IPT -A FORWARD -i enp0s3 -j ACCEPT
#$IPT -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
#$IPT -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT

$IPT -A FORWARD -j LOG

$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -j DROP
$IPT -A FORWARD -j DROP
$IPT -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

echo 1 > /proc/sys/net/ipv4/ip_forward
