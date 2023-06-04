FROM centos:centos7.9.2009

LABEL maintainer="hiroshi.arai"
LABEL version="1.0"
LABEL description="MySQLサーバー"

# 更新、開発ツールインストール
RUN set -ex && \
    yum update -y && \
    yum groupinstall -y "Development tools" && \
    yum clean all

# リポジトリインストール
RUN yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm && \
    yum-config-manager --disable mysql80-community && \
    yum-config-manager --enable mysql57-community && \
    yum install -y mysql-community-server && \
    yum clean all

COPY ./config/5.7.37/my.cnf /etc/my.cnf

# 初期設定
RUN mysqld --initialize-insecure && \
    /usr/sbin/mysqld --daemonize && \
    mysql -e "set password for 'root'@'localhost' = PASSWORD('root')" && \
    mysql -u root -proot -e "create user 'ameria'@'%' identified by 'ameria'" && \
    mysql -u root -proot -e "grant all privileges on *.* to 'ameria'@'%'" && \
    mysql -u root -proot -e "flush privileges"

# ポート
EXPOSE 3306
