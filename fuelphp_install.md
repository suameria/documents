# FuelPHPインストールガイド（ローカル開発環境）

## 構成
- Nginx
- PHP
- MySQL

## Vagrant

- CentOSのboxをダウンロードし、Vagrantfileを作成

```
vagrant box add fuelphp_centos7 https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.2/vagrant-centos-7.2.box

mkdir fuelphp_centos7

cd fuelphp_centos7

vagrant init fuelphp_centos7
```

> 下記コードはsshをどのローカルのディレクトリからできるようにするが任意である

```
vagrant ssh-config --host fuelphp_centos7 >> ~/.ssh/config
ssh fuelphp_centos7
```

- Vagrantfileの編集

```
vi Vagrantfile

    # remove commentout
    config.vm.network "private_network", ip: "192.168.33.10"

    # パーミッション関連
    config.vm.synced_folder '.', '/vagrant', mount_options: ["dmode=777","fmode=777"]

```

- vagrantの起動

```
vagrant up
```

- vagrant up時で下記エラーが出たらvbguestをインストールする

```
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o dmode=777,fmode=777,uid=1000,gid=1000 vagrant /vagrant

The error output from the command was:

/sbin/mount.vboxsf: mounting failed with the error: No such device
```

```
vagrant plugin install vagrant-vbguest
```

- vagrantに接続

```
vagrant ssh

これからインストール作業をしていくのでrootユーザーになっておく
sudo -i
```

## リポジトリの設定

- epelパッケージのインストール

```
yum -y install epel-release.noarch
vi /etc/yum.repos.d/epel.repo

    [epel]の部分のenable=1を、enable=0 に書き換える

    [epel]
    name=Extra Packages for Enterprise Linux 7 - $basearch
    #baseurl=http://download.fedoraproject.org/pub/epel/7/$basearch
    metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
    failovermethod=priority
    enabled=0
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
```

- remiのインストール

```
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
vi /etc/yum.repos.d/remi.repo

    [remi]の部分のenable=1を、enable=0 に書き換える

    [remi]
    name=Remi's RPM repository for Enterprise Linux 7 - $basearch
    #baseurl=http://rpms.remirepo.net/enterprise/7/remi/$basearch/
    #mirrorlist=https://rpms.remirepo.net/enterprise/7/remi/httpsmirror
    mirrorlist=http://cdn.remirepo.net/enterprise/7/remi/mirror
    enabled=0
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
```

- puppetのインストール

```
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
```

## 日本語化

```
localectl set-locale LANG=ja_JP.UTF-8
source /etc/locale.conf
```

## 日本時間の設定

```
date または timedatectl
sudo timedatectl set-timezone Asia/Tokyo
date または timedatectl
```

## シンボリックリンク作成

```
mkdir /var/www
ln -s /vagrant/project /var/www/project
```

## SELINUXを無効

```
getenforce
vi /etc/selinux/config
    SELINUX=disabled
```

## Gitやその他コマンドのインストール

```
yum -y install git vim zip unzip
git --version
```

## OSのUPDATE

```
yum -y update
```

## firewalld

```
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload
```

## Nginxのインストール

```
1. 手動でリポジトリ設定
sudo vi /etc/yum.repos.d/nginx.repo
    [nginx]
    name=nginx repo
    baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
    gpgcheck=0
    enabled=1

2. 自動でリポジトリ設定
yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

yum -y install --enablerepo=nginx nginx
cd /etc/nginx/conf.d
cp -api default.conf default.conf.bak
mv default.conf fuelphp.local.conf

vi fuelphp.local.conf

    server {
        server_name fuelphp.local;

        # これらのファイルに Nginx が書き込めることを確認する
        access_log /var/log/nginx/fuelphp.local/access.log;
        error_log /var/log/nginx/fuelphp.local/error.log;
        root /var/www/project/fuelphp.local/public;

        location / {
            index index.php;
            try_files $uri $uri/ /index.php$is_args$args;
        }

        location ~ \.php$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_pass unix:/var/run/php-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param FUEL_ENV "DEVELOPMENT";
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }

nginx -t
systemctl start nginx
systemctl status nginx
systemctl enable nginx
```

## MySQLのインストール
- 既存のmariadb, mysqlを削除してきれいにしておく

```
yum -y remove mariadb*
yum -y remove mysql* 
rm -rf /var/lib/mysql/
```

- mysql 5.7 インストール

```
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

- rootのパスワード変更

```
mysql> SET GLOBAL validate_password_length=4;
mysql> SET GLOBAL validate_password_policy=LOW;
mysql> SHOW VARIABLES LIKE 'validate_password%';
mysql> set password for root@localhost=password('root');
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
```

- DBとvagrantユーザー作成しておく

```
mysql> CREATE DATABASE fuel_test;
mysql> CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost';
```

## PHPのインストール

- libmcryptのインストール mcryptのインストールに必要なので先にインストール

```
yum --enablerepo=epel install libmcrypt -y
```

- PHPのインストール

```
yum -y install --enablerepo=epel,remi,remi-php72 php
php -ｖ
```

- PHPモジュールのインストール

```
yum -y install --enablerepo=remi,remi-php72 php-mysqlnd
yum -y install --enablerepo=remi,remi-php72 php-mbstring
yum -y install --enablerepo=remi,remi-php72 php-gd
yum -y install --enablerepo=remi,remi-php72 php-xml
yum -y install --enablerepo=remi,remi-php72 php-xmlrpc
yum -y install --enablerepo=remi,remi-php72 php-pecl-mcrypt
yum -y install --enablerepo=remi,remi-php72 php-fpm
yum -y install --enablerepo=remi,remi-php72 php-opcache
yum -y install --enablerepo=remi,remi-php72 php-apcu
yum -y install --enablerepo=remi,remi-php72 php-zip
yum -y install --enablerepo=remi,remi-php72 php-pear
yum -y install --enablerepo=remi,remi-php72 php-devel
yum -y install --enablerepo=remi,remi-php72 php-pdo
```

- php.iniの設定

```
vim /etc/php.ini

    display_errors = On
    error_log = "/var/log/php_errors.log"
    date.timezone = "Asia/Tokyo"
    mbstring.language = Japanese
    mbstring.internal_encoding = UTF-8
```

## Composerのインストール

```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

rootユーザーになっていたらcomposerコマンドは使えないので一旦exitして下記コマンドで確認
composer
```

## PHP-FPMの設定

```
vi /etc/php-fpm.d/www.conf
    user = nginx
    group = nginx
    listen = /var/run/php-fpm.sock
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0666

systemctl status php-fpm
systemctl start php-fpm
systemctl status php-fpm
systemctl enable php-fpm

systemctl restart nginx
```

## FuelPHPのインストール

- rootユーザーの場合exitしておくこと

- oilコマンドを使えるように

```
curl https://get.fuelphp.com/oil | sh
```

- fuelphpのダウンロード

```
cd /var/www/project/fuelphp.local
composer create-project fuel/fuel --prefer-dist .
```

- パーミッション変更

```
vagrantの箇所でパーミッション関連の設定を行ったので下記は必要ないがvagrantを使用しない場合は必須
chmod 777 /var/www/project/fuelphp.local/fuel/app/logs
```
