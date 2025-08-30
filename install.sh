#!/bin/bash

# Update & install tools
apt update -y
apt upgrade -y
apt install lolcat figlet neofetch screenfetch unzip -y

# Siapkan folder UDP
cd
rm -rf /root/udp
mkdir -p /root/udp

# Set timezone GMT+5:30 (Sri Lanka)
echo "Changing timezone to GMT+5:30 (Sri Lanka)"
ln -fs /usr/share/zoneinfo/Asia/Colombo /etc/localtime

# Install udp-custom
echo "Downloading udp-custom..."
wget "https://github.com/Riswan481/vpnstore/raw/main/udp-custom-linux-amd64" -O /root/udp/udp-custom
chmod +x /root/udp/udp-custom

# Download default config
echo "Downloading default config..."
wget "https://raw.githubusercontent.com/Riswan481/vpnstore/main/config.json" -O /root/udp/config.json
chmod 644 /root/udp/config.json

# Buat systemd service
if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team (modified by sslablk)

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team (modified by sslablk)

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
fi

# Install menu dan script tambahan
echo "Installing additional scripts..."
cd $HOME
mkdir -p /etc/Sslablk
cd /etc/Sslablk
wget https://github.com/Riswan481/vpnstore/raw/main/system.zip
unzip system.zip
cd /etc/Sslablk/system

# Pindahkan menu
mv menu /usr/local/bin
chmod +x /usr/local/bin/menu

# Set executable untuk script lain
chmod +x ChangeUser.sh Adduser.sh DelUser.sh Userlist.sh RemoveScript.sh torrent.sh

# Bersihkan file zip
cd /etc/Sslablk
rm system.zip

# Start & enable service
echo "Starting UDP service..."
systemctl daemon-reload
systemctl enable --now udp-custom

# Setup menu agar tampil otomatis saat login root
echo "Setting up menu auto-run..."
if ! grep -q "/usr/local/bin/menu" /root/.bashrc; then
    echo "/usr/local/bin/menu" >> /root/.bashrc
fi

# Selesai tanpa reboot
echo "Installation complete. Launching menu..."
menu