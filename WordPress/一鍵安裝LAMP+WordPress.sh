#!/bin/bash

# 更新系統並升級
echo "更新系統並升級..."
sudo apt update && sudo apt upgrade -y

# 安裝 expect
sudo apt install -y expect

# 安裝Apache, MySQL, PHP和模組
echo "安裝Apache, MySQL, PHP和模組..."
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# 新增PHP詳細資訊
echo "新增PHP詳細資訊..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# 安裝phpMyAdmin
echo "安裝phpMyAdmin..."
sudo apt install -y phpmyadmin

# 設定phpMyAdmin
echo "設定phpMyAdmin..."
sudo phpenmod mbstring
sudo systemctl restart apache2

# 設置phpMyAdmin的默認路徑
echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf
sudo systemctl reload apache2

# 設定MySQL
echo "設定MySQL..."
expect -c '
spawn sudo mysql -u root -p
expect "Enter password:"
send "\r"
expect "mysql>"
send "USE mysql;\r"
expect "mysql>"
send "UPDATE user SET plugin='\''mysql_native_password'\'' WHERE User='\''root'\'';\r"
expect "mysql>"
send "GRANT ALL PRIVILEGES ON *.* TO '\''phpmyadmin'\''@'\''localhost'\'' WITH GRANT OPTION;\r"
expect "mysql>"
send "FLUSH PRIVILEGES;\r"
expect "mysql>"
send "exit;\r"
'


# LAMP 完成
echo ""
echo "基礎 LAMP 建置完成."

# MySQL密碼安全性規則
sudo mysql_secure_installation <<EOF
Y
0
Y
Y
Y
Y
EOF


# 設定wordpress資料庫
echo "設定wordpress資料庫..."
expect -c '
spawn sudo mysql -u root -p
expect "Enter password:"
send "\r"
expect "mysql>"
send "CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_unicode_ci;\r"
expect "mysql>"
send "FLUSH PRIVILEGES;\r"
expect "mysql>"
send "exit;\r"
'


# 使用者輸入要建立的密碼
echo ""
echo "----------------------------------"
read -p "請建立 MySQL root密碼: " rootpassword
echo "----------------------------------"
echo ""

# 更改MySQL密碼
echo "更改MySQL密碼..."
expect -c "
spawn sudo mysql -u root -p
expect \"Enter password:\"
send \"\r\"
expect \"mysql>\"
send \"ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootpassword';\r\"
expect \"mysql>\"
send \"FLUSH PRIVILEGES;\r\"
expect \"mysql>\"
send \"exit;\r\"
send \"\r\"
"
# 重啟 MySQL
sudo systemctl start mysql


# 安裝wordpress
echo "安裝wordpress..."
sudo wget -P 下載/ https://tw.wordpress.org/latest-zh_TW.tar.gz
sudo tar -zxvf 下載/latest-zh_TW.tar.gz -C /var/www/
sudo sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/wordpress/' /etc/apache2/sites-available/000-default.conf

# 重啟Apache服務
echo "重啟Apache服務..."
sudo systemctl restart apache2



# WordPress 寫入資料權限問題
# 設置文件和目錄的所有者和權限
sudo chown -R www-data:www-data /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress/wp-includes/
sudo chown -R www-data:www-data /var/www/wordpress/wp-content/
sudo find /var/www/wordpress -type d -exec chmod 755 {} \;
sudo find /var/www/wordpress -type f -exec chmod 644 {} \;
sudo chmod 640 /var/www/wordpress/wp-config.php
sudo chmod 755 /var/www/wordpress/wp-content
sudo mkdir -p /var/www/wordpress/wp-content/upgrade
sudo mkdir -p /var/www/wordpress/wp-content/uploads
sudo chown -R www-data:www-data /var/www/wordpress/wp-content/upgrade/
sudo chown -R www-data:www-data /var/www/wordpress/wp-content/uploads/
sudo chmod -R 775 /var/www/wordpress/wp-content/upgrade
sudo chmod -R 775 /var/www/wordpress/wp-content/uploads
# 固定連結用的權限
#sudo chmod 644 /var/www/wordpress/.htaccess
sudo chown -R www-data:www-data /var/www/wordpress
sudo chmod -R 755 /var/www/wordpress


echo "安裝wordpress完成."
echo ""
echo "開啟 WordPress 後台初始化頁面"
sudo firefox http://localhost
echo ""
echo "建議用戶還須設定"
echo "1. 中文URL 404問題"
echo "2. 固定連結去掉index.php"
echo "3. 若內往網路 需設定變動IP 適應DHCP"
echo "4. 改變上傳檔案限制"

