#! /bin/bash
IPT=/bin/iptables
INT=enp0s8 #Interfaz hacia red interna
EXT=enp0s3 #Interfaz hacia internet
SER=       #Interfaz hacia red de servidores

echo 1 > /proc/sys/net/ipv4/ip_forward

#DEFAULT RULES

$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT 
$IPT -P FORWARD ACCEPT

#Reset former rules to avoid conflicts
$IPT -F
$IPT -X
$IPT -F -t nat
$IPT -F -t mangle

#Accept loopback established and/or related connections
$IPT -A INPUT -i lo -j ACCEPT
#$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#$IPT -A INPUT -p tcp --dport ssh -i $INT -j ACCEPT
#$IPT -A INPUT -j DROP

#$IPT -A FORWARD -s 192.168.1.0/24 -i $INT -j ACCEPT
#$IPT -A FORWARD -j DROP

#$IPT -t nat -A POSTROUTING -j MASQUERADE
