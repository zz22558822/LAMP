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
echo "正在設定 MySQL..."
#echo "請用戶自行設定: 更改MySQL密碼、規則等..."
#echo "◆ sudo mysql_secure_installation"
#echo "◆ sudo mysql -u root -p"
#echo "◆ ALTER USER 'root'@'localhost' IDENTIFIED BY '要更改的密碼';"
#echo ""

# MySQL密碼安全性規則
sudo mysql_secure_installation <<EOF
Y
0
Y
Y
Y
Y
EOF

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

# 重啟Apache服務
echo "重啟Apache服務..."
sudo systemctl restart apache2

echo ""
echo "所有 LAMP 設定完成."