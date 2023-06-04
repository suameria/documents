# CentOS 7.9 構築

## Apacche+PHP構築

- イメージ取得

```sh
docker pull centos:centos7.9.2009
```

- コンテナ起動

```sh
docker run --platform=linux/amd64 -it --name 7.9-v1.0.0 centos:centos7.9.2009 bash
```

- 作業開始

```sh
yum update -y
yum groupinstall -y "Development tools"
exit
```

```sh
docker commit -m="installed Development tools" {container_id} centos:7.9-v1.0.0

docker run -it --name 7.9-v1.0.1 centos:7.9-v1.0.0 bash
```

## remiを使用する為、依存関係のリポジトリであるEPELをインストールする

```text
https://rpms.remirepo.net/
CentOS７のバージョンを使用しているので下記のremiのURLからインストールする
詳細は下記URLでOS及びPHPの欲しいバージョンを選択すると手順が記載される
https://rpms.remirepo.net/wizard/
```

```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
exit
```

```sh
docker commit -m="installed epel, remi" {container_id} centos:7.9-v1.0.1

docker run -it --name 7.9-v1.0.2 centos:7.9-v1.0.1 bash
```

```sh
yum install -y httpd
yum clean all
```

```sh
docker commit -m="installed apache(httpd)" {container_id} centos:7.9-v1.0.2

docker run -it --name 7.9-v1.0.3 centos:7.9-v1.0.2 bash
```

```text
上記と重複するが下記サイトでPHPをインストールしていく
https://rpms.remirepo.net/wizard/
```

```sh
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable remi-php81
yum install -y php php-{bcmath,devel,gd,mbstring,mysqlnd,opcache,pdo,xml}
```

```sh
docker commit -m="installed PHP" {container_id} centos:7.9-v1.0.2

docker run -it --name 7.9-v1.0.3 centos:7.9-v1.0.2 bash
```

```sh
Dockerfileができたら

docker build -t centos/apache:1.0 .
キャッシュを使用しない場合は下記コマンド
docker build --no-cache -t centos/apache:1.0 .

docker run -itd --name apache01 -p 80:80 {image_id}
```

```sh
php.iniのファイルが欲しいのでdocker cpを使い
コンテナからホストにコピーする
ホスト側でコピーしておきたい場所まで移動しておいて下記コマンドを行う
docker cp {container_id}:/etc/php.ini php.ini
```

## MySQL 構築

- イメージ取得

```sh
docker pull centos:centos7.9.2009
```

- コンテナ起動

```sh
docker run -it --name 7.9-mysql-5.7-1.0.0 centos:centos7.9.2009 bash
```

- 作業開始

```sh
yum update -y
yum groupinstall -y "Development tools"
ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
yum clean all
exit
```

```sh
docker commit -m="installed Development tools" {container_id} centos:7.9-mysql-5.7-1.0.0

docker run -it --name 7.9-v1.0.1 centos:7.9-mysql-5.7-1.0.0 bash
```

```sh
リポジトリの追加
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm

確認
[root@619ed4874e17 /]# yum repolist enabled | grep "mysql.*-community.*"
mysql-connectors-community/x86_64       MySQL Connectors Community          230
mysql-tools-community/x86_64            MySQL Tools Community               138
mysql80-community/x86_64                MySQL 8.0 Community Server          321

[root@619ed4874e17 /]# yum info mysql-community-server
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
Available Packages
Name        : mysql-community-server
Arch        : x86_64
Version     : 8.0.28
Release     : 1.el7
Size        : 451 M
Repo        : mysql80-community/x86_64
Summary     : A very fast and reliable SQL database server

[root@619ed4874e17 /]# yum repolist all | grep mysql
mysql-cluster-7.5-community/x86_64  MySQL Cluster 7.5 Community   disabled
mysql-cluster-7.5-community-source  MySQL Cluster 7.5 Community - disabled
mysql-cluster-7.6-community/x86_64  MySQL Cluster 7.6 Community   disabled
mysql-cluster-7.6-community-source  MySQL Cluster 7.6 Community - disabled
mysql-cluster-8.0-community/x86_64  MySQL Cluster 8.0 Community   disabled
mysql-cluster-8.0-community-source  MySQL Cluster 8.0 Community - disabled
mysql-connectors-community/x86_64   MySQL Connectors Community    enabled:   230
mysql-connectors-community-source   MySQL Connectors Community -  disabled
mysql-tools-community/x86_64        MySQL Tools Community         enabled:   138
mysql-tools-community-source        MySQL Tools Community - Sourc disabled
mysql-tools-preview/x86_64          MySQL Tools Preview           disabled
mysql-tools-preview-source          MySQL Tools Preview - Source  disabled
mysql57-community/x86_64            MySQL 5.7 Community Server    disabled
mysql57-community-source            MySQL 5.7 Community Server -  disabled
mysql80-community/x86_64            MySQL 8.0 Community Server    enabled:   321
mysql80-community-source            MySQL 8.0 Community Server -  disabled

8.0のバージョンがenabledになっている
このままだと8.0がインストールされてしまうので
8.0をdisabledにして5.7の方をenabledにし5.7をインストールできるようにする

yum-config-manager --disable mysql80-community
yum-config-manager --enable mysql57-community

確認
[root@619ed4874e17 /]# yum repolist enabled | grep "mysql.*-community.*"
mysql-connectors-community/x86_64       MySQL Connectors Community          230
mysql-tools-community/x86_64            MySQL Tools Community               138
mysql57-community/x86_64                MySQL 5.7 Community Server          564

[root@619ed4874e17 /]# yum info mysql-community-server
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
Available Packages
Name        : mysql-community-server
Arch        : x86_64
Version     : 5.7.37
Release     : 1.el7
Size        : 174 M
Repo        : mysql57-community/x86_64
Summary     : A very fast and reliable SQL database server

[root@619ed4874e17 /]# yum repolist all | grep mysql
mysql-cluster-7.5-community/x86_64  MySQL Cluster 7.5 Community   disabled
mysql-cluster-7.5-community-source  MySQL Cluster 7.5 Community - disabled
mysql-cluster-7.6-community/x86_64  MySQL Cluster 7.6 Community   disabled
mysql-cluster-7.6-community-source  MySQL Cluster 7.6 Community - disabled
mysql-cluster-8.0-community/x86_64  MySQL Cluster 8.0 Community   disabled
mysql-cluster-8.0-community-source  MySQL Cluster 8.0 Community - disabled
mysql-connectors-community/x86_64   MySQL Connectors Community    enabled:   230
mysql-connectors-community-source   MySQL Connectors Community -  disabled
mysql-tools-community/x86_64        MySQL Tools Community         enabled:   138
mysql-tools-community-source        MySQL Tools Community - Sourc disabled
mysql-tools-preview/x86_64          MySQL Tools Preview           disabled
mysql-tools-preview-source          MySQL Tools Preview - Source  disabled
mysql57-community/x86_64            MySQL 5.7 Community Server    enabled:   564
mysql57-community-source            MySQL 5.7 Community Server -  disabled
mysql80-community/x86_64            MySQL 8.0 Community Server    disabled
mysql80-community-source            MySQL 8.0 Community Server -  disabled

MySQLのインストール
yum install -y mysql-community-server

バージョンの確認
[root@619ed4874e17 /]# mysqld --version
mysqld  Ver 5.7.37 for Linux on x86_64 (MySQL Community Server (GPL))

yum clean all
```

```sh
docker commit -m="installed MySQL5.6" {container_id} centos:7.9-mysql-5.7-1.0.1

docker run -it -p 3306:3306 --name 7.9-v1.0.2 centos:7.9-mysql-5.7-1.0.1 bash

my.cnfがあるところまでcd(ホストからコンテナへファイルをコピー)
docker cp my.cnf {container_id}:/etc/my.cnf
```

```sh
MySQL初期設定(初期パスワードは空)
mysqld --initialize-insecure


MySQL起動
/usr/sbin/mysqld --daemonize

起動確認
ps aux | grep mysqld

rootのパスワードを空パスワードから更新
mysql -e "set password for 'root'@'localhost' = PASSWORD('root')"

ameriaユーザーとameriaのパスワード作成
mysql -u root -proot -e "create user 'ameria'@'%' identified by 'ameria'"

ameriaユーザーはどのDBとTABLEをいじれる権限を持つようにする
mysql -u root -proot -e "grant all privileges on *.* to 'ameria'@'%'"

反映
mysql -u root -proot -e "flush privileges"

```

```sh
Dockerfileができたら

docker build -t centos/mysql:1.0 .
キャッシュを使用しない場合は下記コマンド
docker build --no-cache -t centos/mysql:1.0 .

docker run -itd --name mysql01 -p 3306:3306 {image_id} /usr/sbin/mysqld
```

```text
composer create-project laravel/laravel:^8.0 example-app
```
