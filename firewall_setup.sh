#!/bin/bash
#remember to change what you need open/closed
#need to be sudo when running
echo “Cleaning up”
if [[ -f /etc/network/if-pre-up.d/iptables ]]; then rm /etc/network/if-pre-up.d/iptables; fi
if [[ -f /etc/network/if-post-down.d/iptables ]]; then rm /etc/network/if-post-down.d/iptables; fi

echo "Flushing initial tables"
iptables -F
if [[ ! -d /etc/iptables/ ]]; then mkdir /etc/iptables; fi

echo "Setting up outbound rules"
printf "Outbound rules: "
read outports
for p in $outports
do
if [[ ${p:$((${#p}-1)):1} == 'u' ]]; then
iptables -A OUTPUT -p udp --${p:0:1}port ${p:1$((${#p}-2))} -j ACCEPT
else
iptables -A OUTPUT -p tcp --${p:0:1}port ${p:1:$((${#p}-2))} -j ACCEPT
fi
done

echo "Setting up inbound rules"
printf "Inbound rules: "
read inports
for p in $inports
do
if [[ ${p:$((${#p}-1)):1} == 'u' ]]; then
iptables -A INPUT -p udp --${p:0:1}port ${p:1:$((${#p}-2))} -j ACCEPT
else
iptables -A INPUT -p tcp --${p:0:1}port ${p:1:$((${#p}-2))} -j ACCEPT
fi
done

#iptables -A OUTPUT -p tcp --dport http -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

echo "setting up input rules"
iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 1/sec -j LOG --log-prefix "IPTables packet DROP: " --log-level 7
iptables -A LOGGING -j DROP
iptables -A OUTPUT -j DROP
echo "Saving iptables"
iptables-save > /etc/iptables/iptables.rules
iptables-restore < /etc/iptables/iptables.rules
printf "#!/bin/bash\n/sbin/iptables-restore < /etc/iptables/iptables.rules\n" >> /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables
printf "#!/bin/bash\niptables -F \n" >> /etc/network/if-post-down.d/iptables
chmod +x /etc/network/if-post-down.d/iptables

sysctl net.ipv4.tcp_syncookies=1

