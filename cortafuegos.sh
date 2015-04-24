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
$IPT -F -t raw
$IPT -X

####
#$IPT -t raw -A PREROUTING -i enp0s8 -j NOTRACK

#$IPT -A FORWARD -p tcp -m tcp -s 192.168.1.0/24 --dport 80 -j TARPIT

$IPT -A FORWARD -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH


$IPT -A FORWARD -p tcp -i enp0s8 --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH -j DROP
$IPT -A FORWARD -p tcp -i enp0s9 --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH -j DROP


$IPT -A FORWARD -s 192.168.1.0/24 -j ACCEPT
$IPT -A FORWARD -s 192.168.2.0/24 -j ACCEPT
$IPT -A FORWARD -i enp0s3 -j ACCEPT

$IPT -A FORWARD -j LOG
$IPT -A FORWARD -j DROP

### INPUT ###

$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

##BLOQUEAR SPOOFING
$IPT -A INPUT -i enp0s3 -s 192.168.0.0/16 -j DROP



$IPT -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH -j LOG

$IPT -A INPUT -p tcp -i enp0s8 --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH -j DROP

#$IPT -A INPUT -p tcp -i enp0s9 --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH -j DROP

$IPT -A INPUT -p tcp -i enp0s8 --dport 22 -m state --state NEW -j ACCEPT

#RAW
###ICMP
$IPT -t raw -A PREROUTING -p icmp -i enp0s3 -j DROP
$IPT -t raw -A PREROUTING -p icmp -m u32 ! --u32 "4&0x3FFF=0" -j DROP
$IPT -t raw -A PREROUTING -p icmp -m length --length 1492:65535 -j DROP
$IPT -t raw -A PREROUTING -p icmp -i enp0s8 -j ACCEPT
$IPT -t raw -A PREROUTING -p icmp -i enp0s9 -j ACCEPT

###BLOCK TCP ATTACKS### SYN-FIN # SYN-RST # X-Mas # nmap FIN # NULLflags
$IPT -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
$IPT -t raw -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
$IPT -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
$IPT -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -j DROP
$IPT -t raw -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP




###LIMIT SSH

#$IPT -A INPUT -p tcp --dport ssh -s 0.0.0.0/0 -m connlimit --connlimit-upto 1 -j ACCEPT
#$IPT -A INPUT -p tcp --dport ssh -s 0.0.0.0/0 -m connlimit --connlimit-above 1 -j DROP

$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT -j DROP
$IPT -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

echo 1 > /proc/sys/net/ipv4/ip_forward
