#!/bin/bash
clear

# ================= Colors =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELL='\033[0;33m'
BLUE='\033[1;36m'
NC='\e[0m'
GRENBO="\e[92;1m"

# ================= Header =================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\e[1;97;101m          ADD BOT & CREATE AKUN          \e[0m"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GRENBO}Tutorial Buat Bot dan ID Telegram${NC}"
echo -e "${GRENBO}[*] Buat Bot di @BotFather${NC}"
echo -e "${GRENBO}[*] Cek ID Telegram User/Grup: @MissRose_bot, /info${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ================= Input Bot =================
read -rp "[*] Masukkan Bot Token : " -e BOT_TOKEN

echo -e "${YELL}Pilih Target Notifikasi:${NC}"
echo "1) User pribadi"
echo "2) Grup Telegram"
read -rp "[*] Pilih (1/2) : " TARGET

if [[ "$TARGET" == "1" ]]; then
    read -rp "[*] Masukkan ID Telegram User : " -e CHAT_ID
elif [[ "$TARGET" == "2" ]]; then
    read -rp "[*] Masukkan chat_id Grup (misal: -1001234567890) : " -e CHAT_ID
else
    echo -e "${RED}Pilihan tidak valid!${NC}"
    exit 1
fi

# ================= Simpan Database Bot =================
mkdir -p /etc/bot
touch /etc/bot/.bot.db

# Hapus bot lama kalau ada
DATADB=$(grep -w "${BOT_TOKEN}" /etc/bot/.bot.db | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
    sed -i "/${BOT_TOKEN}/d" /etc/bot/.bot.db
fi

# Tambahkan bot baru
echo "#bot# ${BOT_TOKEN} ${CHAT_ID}" >> /etc/bot/.bot.db

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\e[1;97;101m      SUKSES ADD BOT NOTIFIKASI        \e[0m"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Bot Token     : $BOT_TOKEN"
echo "Chat ID       : $CHAT_ID"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"