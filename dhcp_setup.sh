#!/bin/bash


install() {
  apt update
  apt install kea-dhcp4-server -y

  cat > /etc/kea/kea-dhcp4.conf <<EOF
{
  "Dhcp4": {
    "interfaces-config": {
      "interfaces": [ "ens192" ]
    },
    "subnet4": [
      {
        "subnet": "10.10.11.0/16",
        "pools": [
          { "pool": "10.10.11.2 - 10.10.11.241" }
        ],
        "option-data": [
          {
            "name": "routers",
            "data": "10.10.0.254"
          },
          {
            "name": "domain-name-servers",
            "data": "10.10.11.1"
          }
        ],
        "reservations": [
          {
            "hw-address": "00:0c:29:0a:6f:c3", # à changer
            "ip-address": "10.10.11.2",
            "hostname": "serveur-MAIL-FI2B11"
          },
          {
            "hw-address": "00:0c:29:0a:6f:c3", # à changer
            "ip-address": "10.10.11.3",
            "hostname": "W11-FI2B11"
          },
          {
            "hw-address": "00:0c:29:0a:6f:c3", # à changer
            "ip-address": "10.10.11.4",
            "hostname": "client-debian-FI2B11"
          },
          {
            "hw-address": "00:0c:29:0a:6f:c3", # à changer
            "ip-address": "10.10.11.5",
            "hostname": "serveur-splunk-FI2B11"
          },
        ],
        "valid-lifetime": 30,
        "max-valid-lifetime": 30
      }
    ]
  }
}
EOF

  systemctl restart kea-dhcp4-server
  systemctl status kea-dhcp4-server
  exit 0
}


uninstall() {
  systemctl stop kea-dhcp4-server
  apt purge -y kea-dhcp4-server
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
    if ! systemctl status kea-dhcp4-server >/dev/null 2>&1; then
      install
    else
      echo "Script execution cancelled: kea-dhcp4-server is already installed!"
      exit 1
    fi
  elif [ "$action" = "uninstall" ]; then
    if systemctl status kea-dhcp4-server >/dev/null 2>&1; then
      uninstall
    else
      echo "Script execution cancelled: kea-dhcp4-server cannot be uninstalled, it was not installed in the first place!"
      exit 1
    fi
  fi
fi
echo "Script execution cancelled: expects one argument, 'install' or 'uninstall'."
exit 1