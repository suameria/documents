# Laravel環境構築

## 前提

```text
vagrantでの構築
```

## ディストリビューション

- CentOS `7.9`

## ミドルウェア

- Apache `2.4.6`

- PHP `8.1.8`

- MySQL `5.7.38`

## セットアップ

- ルートユーザーに変更

```sh
sudo -i
```

- 更新、開発ツールインストール、日本時間設定

```sh
yum update -y
yum groupinstall -y "Development tools"
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

- リポジトリインストール(EPEL, remi, ius)

```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum install -y https://repo.ius.io/ius-release-el7.rpm
```

- 必要ツールインストール

```sh
# wget、vimのインストール
yum install -y wget vim


# cURLのインストール
http://www.city-fan.org/ftp/contrib/yum-repo/
上記リポジトリサイトから該当のrpmのURLを探しリポジトリを追加する

rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/city-fan.org-release-2-2.rhel7.noarch.rpm
yum install -y libcurl libcurl-devel --enablerepo=city-fan.org

ex)
https://qiita.com/CloudRemix/items/5ca567af70c2c8a8a871


# gitのインストール
最新バージョンを確認し、インストール
yum list --enablerepo=ius | grep git

コンフリクトエラーが起きるので古いバージョンのgitを先に削除
yum remove git

2022/05/17時点
yum install -y --enablerepo=ius git236

git config --global user.name "Hiroshi Arai"
git config --global user.email "suameria@gmail.com"
git config --global init.defaultBranch master

ex)
https://git-scm.com/download/linux
https://ius.io/
https://qiita.com/wnoguchi/items/f7358a227dfe2640cce3


# node.jsのインストール
CentOS7 向けの nodejs18 の構成が壊れているらしいので16系をひとまず入れる
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs
nodejsを入れたらnode.jsのパッケージ管理ツールであるnpmも同時にインストールされる

バージョン確認
node -v
npm -v

ex)
https://itneko.com/amazon-linux2-nodejs18/
https://github.com/nodesource/distributions/blob/master/README.md
https://computingforgeeks.com/how-to-install-nodejs-on-centos-fedora/

```

- firewalld

```sh
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld

ポートの開放(恒久的設定反映)
firewall-cmd --zone=public --add-port=8000/tcp --permanent
firewall-cmd --zone=public --add-port=8001/tcp --permanent
firewall-cmd --zone=public --add-port=1025/tcp --permanent
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=25/tcp --permanent
firewall-cmd --zone=public --add-port=8025/tcp --permanent
firewall-cmd --zone=public --add-port=41146/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --add-port=6001/tcp --permanent

firewall-cmd --reload

firewall-cmd --list-all

ポート開放確認+α
yum install -y nmap
nmap ${ip_address}

ex)
https://eng-entrance.com/linux-centos-port
```

- Apacheインストール

```sh
yum install -y httpd
systemctl enable httpd
systemctl start httpd
systemctl status httpd

httpd -v

自己証明書作成

確認
yum list installed | grep openssl
yum list installed | grep mod_ssl

インストール
yum install -y openssl
yum install -y mod_ssl

秘密鍵作成
openssl genrsa 2048 > /etc/httpd/ssl.d/${your_domain}.key

公開鍵作成
openssl req -new -key /etc/httpd/ssl.d/${your_domain}.key -subj "/C=JP/ST=Some-State/O=Some-Org/CN=${your_domain}" > /etc/httpd/ssl.d/${your_domain}.pem

デジタル証明書(crt)作成
openssl x509 -in /etc/httpd/ssl.d/${your_domain}.pem -days 3650 -req -signkey /etc/httpd/ssl.d/${your_domain}.key > /etc/httpd/ssl.d/${your_domain}.crt

上記証明書を${some}.confファイルに記載
httpd -t
systemctl restart httpd

[大切！]
ホスト側にcrtファイルを持ってきてキーチェーンに登録
```

- PHP及びモジュールインストール

```sh
yum install -y yum-utils && \
    yum-config-manager --disable 'remi-php*' && \
    yum-config-manager --enable remi-php81 && \
    yum install -y \
    php \
    php-bcmath \
    php-devel \
    php-gd \
    php-intl \
    php-mbstring \
    php-mysqlnd \
    php-opcache \
    php-pdo \
    php-pecl-zip \
    php-xml

php -v
```

- MySQLインストール

```sh
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm

yum repolist enabled | grep "mysql.*-community.*"
yum info mysql-community-server
yum repolist all | grep mysql

yum-config-manager --disable mysql80-community
yum-config-manager --enable mysql57-community

yum repolist enabled | grep "mysql.*-community.*"
yum info mysql-community-server
yum repolist all | grep mysql

yum install -y mysql-community-server
mysqld --initialize-insecure
chown -R mysql. /var/lib/mysql

systemctl enable mysqld
systemctl start mysqld
systemctl status mysqld

mysql -e "set password for 'root'@'localhost' = PASSWORD('root')"
mysql -u root -proot -e "create user 'vagrant'@'%' identified by 'vagrant'"
mysql -u root -proot -e "grant all privileges on *.* to 'vagrant'@'%'"
mysql -u root -proot -e "flush privileges"

mysqld --version
```

- 設定ファイル転送

```sh
パスワードは`vagrant`

httpd.confを転送
scp ./apache/httpd.conf root@192.168.56.10:/etc/httpd/conf/httpd.conf

my.cnfを転送
scp ./mysql/my.cnf root@192.168.56.10:/etc/my.cnf

php.iniをvagrantに転送
scp ./php/php.ini root@192.168.56.10:/etc/php.ini

rm -f /etc/httpd/conf.d/README
rm -f /etc/httpd/conf.d/welcome.conf
rm -f /etc/httpd/conf.d/autoindex.conf
rm -rf /var/www/cgi-bin
rm -rf /var/www/html
```

- 設定ファイル反映

```sh
sudo -i
systemctl restart httpd
systemctl restart mysqld
```

- redisインストール

```sh
yum -y install redis --enablerepo=remi
systemctl enable redis
systemctl start redis

ex)
https://colabmix.co.jp/tech-blog/centos7-redis-install/
```

- aws-cliインストール

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

コマンドが違うのでパスを通すため移動
mv /usr/local/bin/aws /usr/local/sbin/

上記ダウンロード及び解凍した不要ファイルやディレクトリを削除
rm -rf aws awscliv2.zip


[root@localhost ~]# aws configure
AWS Access Key ID [None]: access_key
AWS Secret Access Key [None]: secret_key
Default region name [None]:
Default output format [None]:

アクセス確認
ゲスト側
aws dynamodb list-tables --endpoint-url http://localhost:8000
ホスト側
aws dynamodb list-tables --endpoint-url http://192.168.56.10:8000

ex)
https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html
```

- Minioインストール(AWS S3 互換)

```sh
サーバインストール
curl https://dl.minio.io/server/minio/release/linux-amd64/minio -o /usr/local/sbin/minio
chmod +x /usr/local/sbin/minio
useradd -s /sbin/nologin minio-user

minio.serviceを転送
scp ./etc/systemd/system/minio.service root@192.168.56.10:/etc/systemd/system/minio.service

保存先ディレクトリの作成
mkdir -p /var/lib/minio
chown minio-user:minio-user /var/lib/minio

minio設定ファイル転送
scp ./etc/default/minio root@192.168.56.10:/etc/default/minio

systemctl daemon-reload
systemctl enable minio
systemctl start minio
systemctl status minio

簡易Web確認
Username,Passwordは上記設定したACCESS_KEYとSECRET_KEY
http://192.168.56.10:9000

テスト用バケット作成してみる
(上記コンソールに入ってバケットを作成したほうが簡単)
aws --endpoint-url http://localhost:9000 s3 mb s3://miniotest

バケット一覧取得
aws --endpoint-url http://localhost:9000 s3 ls

ex)
https://zenn.dev/murachi/articles/2a5bde36ff1f1cc21c79
```

- dynamodb-localインストール

```sh
npm install -g dynamodb-admin

下記配下にシンボリックリンクで置かれている
/bin/dynamodb-admin -> ../lib/node_modules/dynamodb-admin/bin/dynamodb-admin.js
できればMailHog, DynamoDB Localと同じディレクトリの/usr/local/sbin/配下に統一しておきたいので
シンボリックリンクを変更する

unlink /bin/dynamodb-admin
ln -s /lib/node_modules/dynamodb-admin/bin/dynamodb-admin.js /usr/local/sbin/dynamodb-admin

dynamodb-admin.serviceを転送
scp ./etc/systemd/system/dynamodb-admin.service root@192.168.56.10:/etc/systemd/system/dynamodb-admin.service

systemctl daemon-reload
systemctl enable dynamodb-admin
systemctl start dynamodb-admin
systemctl status dynamodb-admin

ex)
https://qiita.com/gzock/items/e0225fd71917c234acce
https://github.com/aaronshaf/dynamodb-admin
https://qiita.com/pugiemonn/items/e5fb508df690a323ee14
```

- MailHog導入

```sh
下記URLから最新のバージョンを探す
https://github.com/mailhog/MailHog/blob/master/docs/RELEASES.md

wget https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64

実行できるように+xに権限を変更
chmod +x MailHog_linux_amd64

コマンドとして利用するため移動しかつmailhogの名前に変更
mv MailHog_linux_amd64 /usr/local/sbin/mailhog

mailhog.serviceを転送
scp ./etc/systemd/system/mailhog.service root@192.168.56.10:/etc/systemd/system/mailhog.service

systemctl daemon-reload
systemctl enable mailhog
systemctl start mailhog
systemctl status mailhog

ex)
https://github.com/mailhog/MailHog
https://gist.github.com/Caffe1neAdd1ct/ea28bb49baaea86c203407629b442681
https://kinsta.com/blog/mailhog/
https://github.com/geerlingguy/ansible-role-mailhog/blob/master/templates/mailhog.init.j2
```

- DynamoDB Localインストール

```sh
wget https://s3.ap-northeast-1.amazonaws.com/dynamodb-local-tokyo/dynamodb_local_latest.tar.gz
mkdir /usr/local/sbin/dynamodb
tar xzvf dynamodb_local_latest.tar.gz -C /usr/local/sbin/dynamodb
rm -f dynamodb_local_latest.tar.gz
yum install -y java

dynamodb.serviceを転送
scp ./etc/systemd/system/dynamodb.service root@192.168.56.10:/etc/systemd/system/dynamodb.service

systemctl daemon-reload
systemctl enable dynamodb
systemctl start dynamodb
systemctl status dynamodb

ex)
https://qiita.com/tnnsst35/items/7a3a1d0238de5732b222
```

- Seleniumインストール

```sh
キャプチャなどで日本語が文字化けしないようにフォントをインストール
yum install -y ipa-*-fonts

chromeのリポジトリ情報を登録
scp ./etc/yum.repos.d/google-chrome.repo root@192.168.56.10:/etc/yum.repos.d/google-chrome.repo
yum install -y google-chrome-stable
google-chrome -version

上記でバージョンを確認してcromedriverも同じバージョンに合わせること！
wget https://chromedriver.storage.googleapis.com/104.0.5112.79/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/local/sbin/
rm -f chromedriver_linux64.zip
chromedriver --version

yum install -y python3
python3 -V
pip3 -V
pip3 install selenium
pip3 show selenium


ex)
https://www.ukkari-san.net/centos7-%e3%81%a7seleniumchromedriverphp%e3%82%92%e5%8b%95%e3%81%8b%e3%81%99/
https://blog.denet.co.jp/centos7-python-selenium/
https://shojinblog.com/cakephp-selenium/
```

- Websocketサーバー

```sh

下記サイトを参考にする

ex)
https://github.com/tlaverdure/laravel-echo-server

```

- Composerインストール

```sh
ハッシュ値が変わるので最新のものを下記からインストール
https://getcomposer.org/
公式ページでグローバルにcomposerコマンドを実行できるように下記のようになっている
sudo mv composer.phar /usr/local/bin/composer
しかし、このままだとcomposerと入力してもコマンドが見つからないとなって使用できない
echo $PATH でパスを確認してみるとわかるのでそこに移動させること
CentOS7.9の場合
[root@localhost ~]# echo $PATH
/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
となっているので
sudo mv composer.phar /usr/local/sbin/composer
これで使用できる
```

- Laravel導入

```sh
composer create-project laravel/laravel:^9.0 /var/www/{project_name}

vi /etc/httpd/conf.d/vhost-{project_name}.conf

systemctl restart httpd
```
