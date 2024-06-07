#!/bin/bash

# SSL 證書的有效期限
read -p "請輸入 SSL 證書的有效天數 (默認為 36499): " days
# 如果用戶未輸入，或者輸入錯誤，則使用默認值 36499
if [[ ! "$days" =~ ^[1-9][0-9]*$ ]]; then
    echo "無效的天數，將使用默認值 36499 天。"
    days=36499
elif ((days < 1 || days > 36500)); then
    echo "天數必須在 1 到 36500 之間，使用默認值 36499 天。"
    days=36499
fi
echo ""

# 獲取本地 IP 地址
ip_address=$(hostname -I | awk '{print $1}')


# 啟用 mod_ssl 模組
sudo a2enmod ssl

# 重啟 Apache
sudo systemctl restart apache2

# 生成私鑰 (Key)
# sudo openssl req -x509 -nodes -days 36499 -newkey rsa:2048 -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt -subj "/C=TW/ST=Taiwan/O=SSL Self-signed/CN=192.168.1.1"
sudo openssl req -x509 -nodes -days "$days" -newkey rsa:2048 -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt -subj "/C=TW/ST=Taiwan/O=SSL Self-signed/CN=$ip_address"
echo ""

# Apache 配置文件路徑
CONF_FILE="/etc/apache2/sites-available/000-default.conf"

# 判斷 Apache 443 port 設定是否存在
if grep -q "<VirtualHost \*:443>" "$CONF_FILE"; then
    # 如果已經存在，詢問用戶是否要覆蓋
    read -n 1 -p "Apache 443 port 設定已存在，是否要覆蓋(默認y)? (y/n): " overwrite
    echo ""
    if [[ ! "$overwrite" =~ ^[Yy]$ ]] && [[ -n "$overwrite" ]]; then
        echo "維持現有 Apache 443 port 設定。"
		echo ""
        exit 0
    else
        # 刪除舊的 Apache 443 port 設定
        sudo sed -i '/<VirtualHost \*:443>/,/<\/VirtualHost>/d' "$CONF_FILE"
        echo "已刪除舊的 Apache 443 port 設定。"
		echo ""
    fi
fi


# 新增 Apache 443 port 設定
cat << EOF | sudo tee -a "$CONF_FILE" > /dev/null

<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/wordpress

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
echo "新增 Apache 443 port 設定..."
echo ""

# 重啟 Apache
sudo systemctl restart apache2

echo "Apache SSL 自簽設定完成。"
