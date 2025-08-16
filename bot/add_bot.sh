#!/bin/bash
clear

# ================= Colors =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELL='\033[0;33m'
BLUE='\033[1;36m'
NC='\033[0m'
GRENBO='\033[92;1m'

# ================= Header =================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\033[1;97;101m       INSTALL & MANAGE BOT TELEGRAM       \033[0m"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ================= Buat Folder Bot =================
mkdir -p /etc/bot

# ================= Simpan Skrip add_bot.sh =================
cat << 'EOF' > /etc/bot/add_bot.sh
#!/bin/bash
clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELL='\033[0;33m'
BLUE='\033[1;36m'
NC='\033[0m'
GRENBO='\033[92;1m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\033[1;97;101m          MANAGE BOT TELEGRAM          \033[0m"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "${GRENBO}1) Add Bot & Pilih Target Notifikasi${NC}"
echo -e "${GRENBO}2) Hapus Bot Lama${NC}"
echo -e "${GRENBO}3) Cek Bot Aktif (On/Off)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

read -rp "[*] Pilih Menu (1-3): " MENU

mkdir -p /etc/bot
touch /etc/bot/.bot.db

case "$MENU" in
1)
    read -rp "[*] Masukkan Bot Token: " BOT_TOKEN
    echo -e "${YELL}Pilih Target Notifikasi:${NC}"
    echo "1) User pribadi"
    echo "2) Grup Telegram"
    read -rp "[*] Pilih Target (1/2): " TARGET

    if [ "$TARGET" = "1" ]; then
        read -rp "[*] Masukkan ID Telegram User: " CHAT_ID
    elif [ "$TARGET" = "2" ]; then
        read -rp "[*] Masukkan chat_id Grup (misal: -1001234567890): " CHAT_ID
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"
        exit 1
    fi

    sed -i "/${BOT_TOKEN}/d" /etc/bot/.bot.db
    echo "#bot# ${BOT_TOKEN} ${CHAT_ID}" >> /etc/bot/.bot.db
    echo -e "${GREEN}Sukses add bot!${NC}"
    ;;

2)
    echo "[*] Daftar Bot yang Ada:"
    grep "#bot#" /etc/bot/.bot.db || echo "Belum ada bot yang tersimpan."
    read -rp "[*] Masukkan Bot Token yang ingin dihapus: " BOT_DEL
    sed -i "/${BOT_DEL}/d" /etc/bot/.bot.db
    echo -e "${GREEN}Bot berhasil dihapus!${NC}"
    ;;

3)
    echo "[*] Daftar Bot dan Status:"
    while read -r line; do
        BOT=$(echo "$line" | awk '{print $2}')
        CHAT=$(echo "$line" | awk '{print $3}')
        STATUS=$(curl -s -X GET "https://api.telegram.org/bot${BOT}/getMe" | grep -o '"ok":true')
        if [ "$STATUS" = '"ok":true' ]; then
            echo -e "Bot: $BOT | Chat ID: $CHAT | Status: ${GREEN}ON${NC}"
        else
            echo -e "Bot: $BOT | Chat ID: $CHAT | Status: ${RED}OFF${NC}"
        fi
    done < /etc/bot/.bot.db
    ;;

*)
    echo -e "${RED}Pilihan tidak valid!${NC}"
    exit 1
    ;;
esac
EOF

# ================= Beri Permission =================
chmod +x /etc/bot/add_bot.sh

# ================= Selesai =================
echo -e "${GREEN}Install selesai!${NC}"
echo -e "Jalankan skrip dengan: /etc/bot/add_bot.sh"