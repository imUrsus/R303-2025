#!/bin/bash


install() {
	apt update
	apt install -y bind9
	cwd=$(pwd)
	cd /etc/bind

	cat > named.conf.options <<EOF
options {
	directory "/var/cache/bind";
	forward first;
	forwarders {
	    10.10.0.1;
	};
	dnssec-validation auto;
	listen-on-v6 { any; };
};
EOF

	cat > named.conf.local <<EOF
include "/etc/bind/zones.rfc1918";
zone "b11.lan" {
type master;
file "/etc/bind/db.b11.lan";
allow-transfer {10.10.12.1;};
};
zone "b10.lan" {
type slave;
file "/etc/bind/db.b10.lan";
masters {10.10.10.1;};
};
EOF

	install_serial="$(date +%Y%m%d)01"
	cat > db.b11.lan <<EOF
\$TTL 3h
@ IN SOA ns.b11.lan. admin.b11.lan. (
$install_serial
6H
1H
5D
1D )
@ IN NS ns.b11.lan.
@ IN MX 10 mail.b11.lan.
ns A 10.10.11.1
mail A 10.10.11.2
serveur-FI2B11 A 10.10.11.1
serveur-MAIL-FI2B11 A 10.10.11.2
W11-FI2B11 A 10.10.11.3
client-debian-FI2B11 A 10.10.11.4
serveur-splunk-FI2B11 A 10.10.11.5
www.site11 CNAME ns.b11.lan.
EOF

	named-checkconf named.conf
	named-checkzone b11.lan db.b11.lan
	systemctl status bind9
	cd "$cwd"
	exit 0
}


uninstall() {
	systemctl stop bind9
	rm /etc/bind/db.b11.lan
	apt purge -y bind9
	apt autoremove --purge -y
	apt autoclean
	apt clean
	exit 0
}


if [ $EUID -ne 0 ]; then
   echo "Script execution cancelled: root privileges required."
   exit 1
fi
if [ $# -eq 1 ]; then
	action=$1
	if [ "$action" = "install" ]; then
		if ! systemctl status bind9 >/dev/null 2>&1; then
			install
		else
			echo "Script execution cancelled: bind9 is already installed!"
			exit 1
		fi
	elif [ "$action" = "uninstall" ]; then
		if systemctl status bind9 >/dev/null 2>&1; then
			uninstall
		else
			echo "Script execution cancelled: bind9 cannot be uninstalled, it was not installed in the first place!"
			exit 1
		fi
	fi
fi
echo "Script execution cancelled: expects one argument, 'install' or 'uninstall'."
exit 1