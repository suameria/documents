FROM centos:centos7.9.2009

LABEL maintainer="hiroshi.arai"
LABEL version="1.0"
LABEL description="Apacheサーバー"

# 更新、開発ツールインストール、日本時間設定
RUN set -ex && \
    yum update -y && \
    yum groupinstall -y "Development tools" && \
    ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    yum clean all

# リポジトリインストール(EPEL, remi)
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum clean all

# Apacheインストール
RUN yum install -y httpd && \
    rm -f /etc/httpd/conf.d/README && \
    rm -f /etc/httpd/conf.d/autoindex.conf && \
    rm -f /etc/httpd/conf.d/welcome.conf && \
    mkdir /etc/httpd/sites.d && \
    mkdir /etc/httpd/ssl.d && \
    yum clean all

# PHP及びモジュールインストール
RUN yum install -y yum-utils && \
    yum-config-manager --disable 'remi-php*' && \
    yum-config-manager --enable remi-php81 && \
    yum install -y \
    php \
    php-bcmath \
    php-devel \
    php-gd \
    php-mbstring \
    php-mysqlnd \
    php-opcache \
    php-pdo \
    php-xml \
#    php-{bcmath,devel,gd,mbstring,mysqlnd,opcache,pdo,xml} && \
    yum clean all

# composerインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# VirtualHosts設定
COPY ./apache/config/2.4.6/conf/httpd.conf /etc/httpd/conf/httpd.conf
COPY ./apache/config/2.4.6/sites.d/ /etc/httpd/sites.d/

# php.ini設定
COPY ./php/config/8.1.3/php.ini /etc/php.ini

RUN chown -R apache. /var/www

WORKDIR /var/www

# ポート
EXPOSE 80

# Apache起動
# 起動コマンドは /usr/lib/systemd/system/httpd.service に記載してある
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
