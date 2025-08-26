#!/bin/bash

# ===== Colors =====
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
END="\e[0m"

clear
echo -e "${YELLOW}===== INSTALL TELEGRAM VPS BOT =====${END}"

# ===== MINTA TOKEN & ADMIN ID =====
read -p "Masukkan token bot Telegram: " BOT_TOKEN
read -p "Masukkan Telegram Admin ID: " ADMIN_ID

# ===== UPDATE & INSTALL DEPENDENCY =====
echo -e "${GREEN}Update sistem dan install Node.js...${END}"
apt update -y && apt upgrade -y
apt install -y curl wget build-essential

# Install Node.js 20 jika belum ada
if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# Cek Node.js
echo -e "${GREEN}Node.js version: $(node -v)${END}"

# ===== BUAT FOLDER BOT =====
BOT_DIR="/root/vps-bot"
mkdir -p $BOT_DIR
cd $BOT_DIR

# ===== INIT NPM =====
npm init -y

# ===== INSTALL PACKAGE =====
npm install node-telegram-bot-api

# ===== BUAT FILE BOT.JS =====
cat > bot.js <<EOL
const { exec } = require("child_process");
const TelegramBot = require("node-telegram-bot-api");

const token = "${BOT_TOKEN}";
const bot = new TelegramBot(token, { polling: true });
const ADMIN_ID = ${ADMIN_ID};

function runCommand(cmd, callback) {
    exec(cmd, (error, stdout, stderr) => {
        if (error) return callback(\`Error: \${error.message}\`);
        if (stderr) return callback(\`Stderr: \${stderr}\`);
        callback(stdout);
    });
}

function sendMenu(chatId) {
    const options = {
        reply_markup: {
            inline_keyboard: [
                [{ text: "➤ Tambah User", callback_data: "add_user" }],
                [{ text: "➤ Tambah Trial", callback_data: "add_trial" }],
                [{ text: "➤ Tambah Host", callback_data: "add_host" }],
                [{ text: "➤ Reset Host", callback_data: "reset_host" }],
                [{ text: "➤ Host Aktif", callback_data: "view_host" }],
                [{ text: "❌ Keluar", callback_data: "exit" }],
            ],
        },
    };
    bot.sendMessage(chatId, "🌐 PANEL MANAJEMEN VPS 🌐\nPilih menu:", options);
}

bot.onText(/\/start/, (msg) => {
    if (msg.from.id != ADMIN_ID) return;
    sendMenu(msg.chat.id);
});

bot.on("callback_query", (callbackQuery) => {
    const msg = callbackQuery.message;
    const data = callbackQuery.data;
    if (msg.from.id != ADMIN_ID) return;

    switch (data) {
        case "add_user":
            bot.sendMessage(msg.chat.id, "Masukkan username:").then(() => {
                bot.once("message", (usernameMsg) => {
                    const username = usernameMsg.text;
                    bot.sendMessage(msg.chat.id, "Masukkan password:").then(() => {
                        bot.once("message", (passwordMsg) => {
                            const password = passwordMsg.text;
                            bot.sendMessage(msg.chat.id, "Masukkan masa berlaku (hari):").then(() => {
                                bot.once("message", (expireMsg) => {
                                    const expire = expireMsg.text;
                                    const cmd = \`bash -c 'useradd -M -N -s /bin/bash \${username} && echo "\${username}:\${password}" | chpasswd && chage -E $(date -d "+\${expire} days" +%Y-%m-%d) \${username}'\`;
                                    runCommand(cmd, (output) => {
                                        bot.sendMessage(msg.chat.id, \`User \${username} berhasil dibuat!\n\${output}\`);
                                        sendMenu(msg.chat.id);
                                    });
                                });
                            });
                        });
                    });
                });
            });
            break;

        case "add_trial":
            const cmdTrial = \`bash -c 'username="trial$(openssl rand -hex 3)"; password=$(openssl rand -base64 12); useradd -M -N -s /bin/bash $username && echo "$username:$password" | chpasswd; chage -E $(date -d "+1 hour" +%Y-%m-%d) $username; echo "userdel -r $username 2>/dev/null" | at now + 1 hour; echo "$username $password"'\`;
            runCommand(cmdTrial, (output) => {
                bot.sendMessage(msg.chat.id, \`Trial user berhasil dibuat:\n\${output}\`);
                sendMenu(msg.chat.id);
            });
            break;

        case "add_host":
            bot.sendMessage(msg.chat.id, "Masukkan IP/Host baru:").then(() => {
                bot.once("message", (hostMsg) => {
                    const host = hostMsg.text;
                    const cmd = \`echo "\${host}" > /root/udp/host.conf\`;
                    runCommand(cmd, () => {
                        bot.sendMessage(msg.chat.id, \`Host berhasil disimpan: \${host}\`);
                        sendMenu(msg.chat.id);
                    });
                });
            });
            break;

        case "reset_host":
            runCommand("rm -f /root/udp/host.conf", () => {
                bot.sendMessage(msg.chat.id, "Host berhasil direset!");
                sendMenu(msg.chat.id);
            });
            break;

        case "view_host":
            const cmdView = \`bash -c '[[ -s /root/udp/host.conf ]] && cat /root/udp/host.conf || wget -4 -qO- https://ipecho.net/plain'\`;
            runCommand(cmdView, (output) => {
                bot.sendMessage(msg.chat.id, "Host/IP aktif: " + output);
                sendMenu(msg.chat.id);
            });
            break;

        case "exit":
            bot.sendMessage(msg.chat.id, "Terima kasih! 👋");
            break;
    }

    bot.answerCallbackQuery(callbackQuery.id);
});
EOL

# ===== BUAT SYSTEMD SERVICE =====
SERVICE_FILE="/etc/systemd/system/vpsbot.service"
cat > $SERVICE_FILE <<EOL
[Unit]
Description=VPS Management Telegram Bot
After=network.target

[Service]
ExecStart=/usr/bin/node $BOT_DIR/bot.js
Restart=always
User=root
Environment=NODE_ENV=production
WorkingDirectory=$BOT_DIR

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd
systemctl daemon-reload
systemctl enable vpsbot
systemctl start vpsbot

echo -e "${GREEN}===== INSTALL SELESAI! =====${END}"
echo -e "Bot sudah berjalan dan akan otomatis jalan saat VPS restart."
echo -e "Gunakan /start di Telegram untuk membuka menu."