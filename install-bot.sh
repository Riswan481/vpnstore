#!/bin/bash

# ===== COLORS =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# ===== CONFIG =====
BOT_NAME="vpn-bot"
BOT_DIR="/opt/$BOT_NAME"
ZIP_URL="https://github.com/Riswan481/vpnstore/archive/refs/heads/main.zip"
INDEX_FILE="$BOT_DIR/index.js"

echo -e "${CYAN}${BOLD}🌐 Memulai instalasi bot dari GitHub...${RESET}"

# Hentikan & hapus bot lama dari PM2
if pm2 list | grep -q "$BOT_NAME"; then
    echo -e "${YELLOW}🛑 Hentikan bot lama di PM2...${RESET}"
    pm2 stop "$BOT_NAME"
    pm2 delete "$BOT_NAME"
fi

# Hapus folder bot lama
echo -e "${YELLOW}🗑 Hapus folder bot lama (jika ada)...${RESET}"
rm -rf "$BOT_DIR"
mkdir -p "$BOT_DIR"

# Download ZIP repo
echo -e "${CYAN}📥 Download repo dari GitHub via curl...${RESET}"
curl -L "$ZIP_URL" -o "/tmp/$BOT_NAME.zip"

# Extract ZIP ke folder bot
echo -e "${CYAN}📂 Extract bot ke folder $BOT_DIR...${RESET}"
unzip -o "/tmp/$BOT_NAME.zip" -d /opt
# ZIP biasanya bikin folder vpnstore-main
mv /opt/vpnstore-main/* "$BOT_DIR"

# ===== INPUT BOT TOKEN & OWNER ID =====
read -p "Masukkan BOT TOKEN: " BOT_TOKEN
read -p "Masukkan OWNER CHAT ID: " OWNER_ID

# ===== UPDATE index.js =====
if [ -f "$INDEX_FILE" ]; then
    echo -e "${CYAN}✏️ Update index.js dengan BOT_TOKEN & OWNER_ID...${RESET}"

    # Ganti atau tambahkan baris BOT_TOKEN
    if grep -q "const BOT_TOKEN" "$INDEX_FILE"; then
        sed -i "s|const BOT_TOKEN = .*;|const BOT_TOKEN = '$BOT_TOKEN';|" "$INDEX_FILE"
    else
        sed -i "1i const BOT_TOKEN = '$BOT_TOKEN';" "$INDEX_FILE"
    fi

    # Ganti atau tambahkan baris OWNER_ID
    if grep -q "const OWNER_ID" "$INDEX_FILE"; then
        sed -i "s|const OWNER_ID = .*;|const OWNER_ID = $OWNER_ID;|" "$INDEX_FILE"
    else
        sed -i "2i const OWNER_ID = $OWNER_ID;" "$INDEX_FILE"
    fi

    echo -e "${GREEN}✅ index.js berhasil diperbarui!${RESET}"
else
    echo -e "${RED}❌ index.js tidak ditemukan di $BOT_DIR${RESET}"
    exit 1
fi

# ===== INSTALL DEPENDENCIES =====
echo -e "${CYAN}⚙️ Install dependencies...${RESET}"
cd "$BOT_DIR" || exit
npm install

# Install PM2 global jika belum ada
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}🌐 Install PM2 global...${RESET}"
    npm install -g pm2
fi

# ===== RUN BOT DENGAN PM2 =====
echo -e "${GREEN}🚀 Jalankan bot dengan PM2...${RESET}"
pm2 start index.js --name "$BOT_NAME" || pm2 restart "$BOT_NAME"

echo -e "${CYAN}💾 Simpan konfigurasi PM2...${RESET}"
pm2 save

echo -e "${BLUE}🔄 Set supaya auto start saat VPS reboot...${RESET}"
pm2 startup -u $(whoami) --hp $HOME

echo -e "${GREEN}${BOLD}✅ Bot berhasil di-install & dijalankan!${RESET}"