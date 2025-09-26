#!/bin/bash


install() {
   apt update
   apt install apache2 -y
   mkdir /var/www/site11
   echo "<h1>Bienvenue sur site11.</h1>" > /var/www/site11/index.html

   cat > /etc/apache2/sites-available/site11.conf <<EOF
<VirtualHost *:80>
   ServerName www.site11.b11.lan
   DocumentRoot /var/www/site11
</VirtualHost>
EOF

   a2ensite site11.conf
   systemctl restart apache2
   systemctl status apache2
   exit 0
}


uninstall() {
   systemctl stop apache2
   rm -rF /var/www/site11
   apt purge -y apache2
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
    if ! systemctl status apache2 >/dev/null 2>&1; then
      install
    else
      echo "Script execution cancelled: apache2 is already installed!"
      exit 1
    fi
  elif [ "$action" = "uninstall" ]; then
    if systemctl status apache2 >/dev/null 2>&1; then
      uninstall
    else
      echo "Script execution cancelled: apache2 cannot be uninstalled, it was not installed in the first place!"
      exit 1
    fi
  fi
fi
echo "Script execution cancelled: expects one argument, 'install' or 'uninstall'."
exit 1