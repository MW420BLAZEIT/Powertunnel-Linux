#!/bin/bash

# Checks of root or not
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
fi

# Main Script starts
mkdir ~/pt
cd /etc/systemd/system
cat > pt.service <<EOL
[Unit]
Description=My Webapp Java REST Service
Wants=network-online.target
After=network-online.target

[Service]
User=root

WorkingDirectory=~/pt
#path to executable. executable is a bash script which calls jar file
ExecStart=/bin/sh "~/pt/call.sh"
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target


EOL

cd ~/pt
wget https://github.com/krlvm/PowerTunnel/releases/download/v1.14/PowerTunnel.jar
cat > call.sh <<EOL
ip=$(hostname -I | awk '{print $1}')
java -jar PowerTunnel.jar -console -ip $ip
EOL
sudo systemctl daemon-reload
sudo systemctl start pt.service
sudo systemctl status pt.service
sudo systemctl enable pt.service
