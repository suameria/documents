## 構成

- Apache

- PHP

- MySQL


## Vagrantfile内容

```text
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.6"
  config.vm.network "private_network", ip: "192.168.33.11"
  config.vm.synced_folder "./source", "/var/www/html/mamosearch/eccube", create:true, owner:'apache', group:'apache', :mount_options => ['dmode=775', 'fmode=775']
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.name = "centos-7.6-mamosearcheccube"
  end
  config.vm.provision "shell", inline: <<-SHELL
    localectl set-locale LANG=ja_JP.UTF-8
    timedatectl set-timezone Asia/Tokyo
    yum install -y yum-utils device-mapper-persistent-data lvm2
    # EPELリポジトリインストール
    yum install -y epel-release
    # REMIリポジトリインストール
    yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    # yum更新
    yum -y update
    # ファイアウォール設定
    systemctl start firewalld.service
    systemctl enable firewalld.service
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=443/tcp --permanent
    firewall-cmd --reload
    # Apacheインストール
    yum -y install httpd openssl mod_ssl
    systemctl start httpd
    systemctl enable httpd
    # PHPインストール
    yum -y install --enablerepo=epel,remi,remi-php73 php php-gd php-mcrypt php-mysqlnd php-mbstring php-gd php-xml php-xmlrpc php-pecl-mcrypt php-fpm php-opcache php-apcu php-zip php-pear php-devel php-pdo php-intl
    # MySQLインストール
    yum -y remove mariadb*
    yum -y remove mysql*
    rm -rf /var/lib/mysql/
    yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
    yum -y install mysql-community-server
    systemctl start mysqld
    systemctl enable mysqld
  SHELL
end
```

## bashrc

```text
alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd .. ; ll'
alias c='clear'
```

## 参考サイト

```text
https://www.rem-system.com/centos-httpd-php73/
https://www.suzu6.net/posts/152-centos7-php-73/
https://server-setting.info/blog/lamp-eccube-centos.html
```
## SELINUX無効

```
getenforce
vi /etc/selinux/config
    SELINUX=disabled
```

## 日本語化

```
localectl set-locale LANG=ja_JP.UTF-8
source /etc/locale.conf
```

## 日本時間

```
timedatectl set-timezone Asia/Tokyo
timedatectl
```

## EPELリポジトリ

```text
yum install -y epel-release
```

## REMIリポジトリ

```text
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
```

## yum更新

```text
yum -y update
```

## ファイアウォール

```
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all
```

## Apacheバージョン確認及び設定

```text
yum -y install httpd openssl mod_ssl
systemctl start httpd
systemctl enable httpd
httpd --version

vi /etc/httpd/conf/httpd.conf

ServerName www.example.com:80
変更
ServerName mamosearcheccube.test:80

<Directory "/var/www">
変更
<Directory "/var/www/html/mamosearch/eccube">

DocumentRoot "/var/www/html"
変更
DocumentRoot "/var/www/html/mamosearch/eccube"


下記は2つディレティブがあるので2つとも変更しておく
<Directory "/var/www/html">
変更
<Directory "/var/www/html/mamosearch/eccube">

AllowOverride None
変更
AllowOverride All

systemctl restart httpd
```

## PHP

```text
yum -y install --enablerepo=epel,remi,remi-php73 php php-gd php-mcrypt php-mysqlnd php-mbstring php-gd php-xml php-xmlrpc php-pecl-mcrypt php-fpm php-opcache php-apcu php-zip php-pear php-devel php-pdo php-intl

php -v
php -m
```


## MySQLバージョン確認及び設定

```
yum -y remove mariadb*
yum -y remove mysql*
rm -rf /var/lib/mysql/
yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld
systemctl enable mysqld
mysqld --version
```

- 初期パスワードを確認

```
cat /var/log/mysqld.log | grep 'password is generated'
mysql -u root -p
Enter password: <初期パスワード> メモしておく
```

- セキュリティ設定

```
mysql_secure_installation
Enter password for user root: 初期パスワード
New password: # DbPass1! 少ないと怒られるので仮のPASS 後に簡単なPASSに変更する
Re-enter new password:

すべてyで答える
```

- ログイン確認

```
$ mysql -uroot -p
Enter password: 仮の新rootパス
```

- rootのパスワード変更及びDB作成

```
mysql> SET GLOBAL validate_password_length=4;
mysql> SET GLOBAL validate_password_policy=LOW;
mysql> SHOW VARIABLES LIKE 'validate_password%';
mysql> set password for root@localhost=password('root');
mysql> CREATE DATABASE ec;
```

- my.cnfの設定

```
vi /etc/my.cnf
 
[mysqld]
default-storage-engine=InnoDB
innodb_file_per_table

character-set-server = utf8
collation-server = utf8_general_ci

[mysql]
default-character-set = utf8 

[client]
default-character-set = utf8


systemctl restart mysqld
```

## Composerのインストール

```
https://getcomposer.org/download/

mv composer.phar /usr/local/bin/composer

rootユーザーになっていたらcomposerコマンドは使えないので一旦exitして下記コマンドで確認
composer
```
