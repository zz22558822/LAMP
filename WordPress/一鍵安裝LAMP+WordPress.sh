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

# LAMP 完成
echo "基礎 LAMP 建置完成."




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

sudo mysql_secure_installation <<EOF

Y
0
Y
Y
Y
Y

EOF

# 更改MySQL密碼
echo "更改MySQL密碼..."
expect -c '
spawn sudo mysql -u root -p
expect "Enter password:"
send "\r"
expect "mysql>"
send "ALTER USER 'root'@'localhost' IDENTIFIED BY '\''your_root_password'\'';\r"
expect "mysql>"
send "FLUSH PRIVILEGES;\r"
expect "mysql>"
send "exit;\r"
'

sudo systemctl start mysql

# 設定wordpress資料庫
echo "設定wordpress資料庫..."
expect -c '
spawn sudo mysql -u root -p
expect "Enter password:"
send "\r"
expect "mysql>"
send "CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_unicode_ci;\r"
expect "mysql>"
send "GRANT ALL PRIVILEGES ON *.* TO '\''phpmyadmin'\''@'\''localhost'\'' WITH GRANT OPTION;\r"
expect "mysql>"
send "FLUSH PRIVILEGES;\r"
expect "mysql>"
send "exit;\r"
'

# 安裝wordpress
echo "安裝wordpress..."
sudo wget -P 下載/ https://tw.wordpress.org/latest-zh_TW.tar.gz
sudo tar -zxvf 下載/latest-zh_TW.tar.gz -C /var/www/
sudo sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/wordpress/' /etc/apache2/sites-available/000-default.conf

# 重啟Apache服務
echo "重啟Apache服務..."
sudo systemctl restart apache2

echo "安裝wordpress完成."
