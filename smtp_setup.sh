#!/bin/bash


install() {
	apt update
	apt install postfix mailutils sendmail -y
  systemctl status postfix
	exit 0
}


uninstall() {
	systemctl stop postfix
	apt purge -y postfix mailutils
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
    if ! systemctl status postfix >/dev/null 2>&1; then
      install
    else
      echo "Script execution cancelled: postfix is already installed!"
      exit 1
    fi
  elif [ "$action" = "uninstall" ]; then
    if systemctl status postfix >/dev/null 2>&1; then
      uninstall
    else
      echo "Script execution cancelled: postfix cannot be uninstalled, it was not installed in the first place!"
      exit 1
    fi
  fi
fi
echo "Script execution cancelled: expects one argument, 'install' or 'uninstall'."
exit 1