![LAMP server cover](https://github.com/zz22558822/LAMP/blob/main/img/LAMP%20server.png)
# LAMP server 一鍵安裝
## LAMP server install script

---

## 介紹
這是一個簡易的 LAMP（Linux、Apache、MySQL、PHP）一鍵安裝腳本，可快速在你的 Linux 系統上設置 LAMP 環境。

---

## 使用環境
- **L** : Ubuntu 24.04 LTS (建議)
- **A** : Apache 2.4.58
- **M** : MySQL 8.0.36 + phpMyAdmin 5.2.1
- **P** : PHP 8.3.6

---

## 使用教學
1. 下載安裝腳本:
    ```sh
    sudo wget https://github.com/zz22558822/LAMP/releases/download/upload/install_LAMP.sh
    ```

2. 執行腳本:
    ```sh
    sudo chmod +x install_LAMP.sh && sudo bash ./install_LAMP.sh
    ```

3. 使用空白鍵選擇『apache2』，Tab切換到『確定』:

    ![選擇 Apache2](https://github.com/zz22558822/LAMP/blob/main/img/phpMyAdmin1.png)
   
4. 選擇『是』:

    ![選擇 是](https://github.com/zz22558822/LAMP/blob/main/img/phpMyAdmin2.png)

5. 輸入你的密碼:

    ![輸入密碼](https://github.com/zz22558822/LAMP/blob/main/img/phpMyAdmin3.png)

6. 再次確認你的密碼:

    ![確認密碼](https://github.com/zz22558822/LAMP/blob/main/img/phpMyAdmin4.png)

7. 安裝完成後，請用戶自行更改 MySQL 密碼、規則等：
    - 設定 MySQL 安全性:
      ```sh
      sudo mysql_secure_installation
      ```
    - 登入 MySQL（密碼空白）:
      ```sh
      sudo mysql -u root -p
      ```
    - 修改 root 密碼:
      ```sql
      ALTER USER 'root'@'localhost' IDENTIFIED BY '你的新密碼';
      ```

**注意：** 在執行腳本前，請確保你的系統已經具有相應的權限，並謹慎對待任何需要輸入密碼的操作。


---
# LAMP + WordPress install script

## 使用教學
1. 下載安裝腳本:
    ```sh
    https://github.com/zz22558822/LAMP/releases/download/upload/install_LAMP+WordPress.sh
    ```

2. 執行腳本:
    ```sh
    sudo chmod +x install_LAMP+WordPress.sh && sudo bash ./install_LAMP+WordPress.sh
    ```
3. ~ 6.均與上方相同

7. 輸入要設定的 MySQL root 密碼:
