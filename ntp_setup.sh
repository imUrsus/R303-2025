#!/bin/bash


install() {
	if ! systemctl status systemd-timesyncd >/dev/null 2>&1; then
		apt update
		apt install systemd-timesyncd -y
	fi

	cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=10.10.0.254
EOF

	systemctl restart systemd-timesyncd
	systemctl status systemd-timesyncd
	timedatectl status
	exit 0
}


uninstall() {
	systemctl stop systemd-timesyncd
	rm /etc/systemd/timesyncd.conf
	touch /etc/systemd/timesyncd.conf
	timedatectl status
	exit 0
}


if [ $EUID -ne 0 ]; then
   echo "Script execution cancelled: root privileges required."
   exit 1
fi
if [ $# -eq 1 ]; then
	action=$1
	if [ "$action" = "install" ]; then
		if [ ! -s /etc/systemd/timesyncd.conf ]; then
			install
		else
			echo "Script execution cancelled: ntp is already installed!"
			exit 1
		fi
	elif [ "$action" = "uninstall" ]; then
		if [ -s /etc/systemd/timesyncd.conf ]; then
			uninstall
		else
			echo "Script execution cancelled: ntp cannot be uninstalled, it was not installed in the first place!"
			exit 1
		fi
	fi
fi
echo "Script execution cancelled: expects one argument, 'install' or 'uninstall'."
exit 1