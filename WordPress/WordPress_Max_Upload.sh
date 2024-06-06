#!/bin/bash

# 獲取當前 PHP 版本
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')

# PHP 配置文件路徑
PHP_INI_FILE="/etc/php/$PHP_VERSION/apache2/php.ini"

# 設置默認上傳文件大小上限
DEFAULT_UPLOAD_SIZE="50M"

# 提示用戶輸入上傳文件大小上限
read -p "請輸入最大上傳文件大小（以MB為單位，默認值為 $DEFAULT_UPLOAD_SIZE）: " UPLOAD_SIZE

# 檢查用戶輸入是否為空
if [ -z "$UPLOAD_SIZE" ]; then
    UPLOAD_SIZE="$DEFAULT_UPLOAD_SIZE"
fi

# 檢查用戶輸入是否為數字
if ! [[ "$UPLOAD_SIZE" =~ ^[0-9]+$ ]]; then
    echo "無效的輸入。使用默認上傳大小：$DEFAULT_UPLOAD_SIZE"
    UPLOAD_SIZE="$DEFAULT_UPLOAD_SIZE"
fi

# 更新 PHP 配置文件
if [ -f "$PHP_INI_FILE" ]; then
    sudo sed -i "s/^upload_max_filesize = .*/upload_max_filesize = ${UPLOAD_SIZE}M/" "$PHP_INI_FILE"
    sudo sed -i "s/^post_max_size = .*/post_max_size = ${UPLOAD_SIZE}M/" "$PHP_INI_FILE"
    echo "已更新 PHP 設定檔案: $PHP_INI_FILE"
else
    echo "找不到 PHP 設定檔案: $PHP_INI_FILE"
fi

# 重啟 Apache 伺服器
sudo service apache2 restart
echo "已重新啟動 Apache 伺服器"

echo "上傳限制已更新為 ${UPLOAD_SIZE}MB"
echo ""
