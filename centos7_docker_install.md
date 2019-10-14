# Laradock

- VirtualBox
- Vagrant
- CentOS 7.5
- Docker
- Laravel
- Apache
- PHP-FPM
- MySQL
- Redis
- DynamoDB

## Prerequisites

- [VirtualBox (Virtual Machine)](https://www.virtualbox.org/)

- [Vagrant (declarative configuration file )](https://www.vagrantup.com/)

### Laradock Install

`workspce/code/`

```text
git clone https://github.com/LaraDock/laradock.git
```

---

### Vagrantfile

`workspce/code/laradock/`

`vi Vagrantfile`

```text
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  config.vm.synced_folder "..", "/vagrant"
  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = "512"
    vb.name = "centos-7.5-laradock"
  end
  config.vm.provision "shell", inline: <<-SHELL
    yum -y update
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    base=https://github.com/docker/machine/releases/download/v0.16.0
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
    install /tmp/docker-machine /usr/local/bin/docker-machine
    usermod -aG docker vagrant
    systemctl start docker
    systemctl enable docker
    localectl set-locale LANG=ja_JP.UTF-8
    timedatectl set-timezone Asia/Tokyo
  SHELL
end
```

---

### Directory

`workspce/code/`

```text
.
├── project1
├── project2
├── {something}
└── laradock
    ├── {something}
    └── Vagrantfile
```

---

### vagrant up

`vagrant plugin install vagrant-vbguest`

`vagrant up`

`vagrant ssh`

---

### .bashrc

`vi .bashrc`

```text
alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd .. ; ll'
alias c='clear'
alias laradock='cd /vagrant/laradock'

# Docker Command
alias dce='docker-compose exec'
alias dup='docker-compose up -d'
alias dps='docker-compose ps'
alias stop='cd /vagrant/laradock ; docker-compose stop'
alias run='cd /vagrant/laradock ; docker-compose up -d workspace apache2 php-fpm mysql dynamodb redis mailhog'
alias workspace='cd /vagrant/laradock ; docker-compose exec --user=laradock workspace bash'
alias apache2='cd /vagrant/laradock ; docker-compose exec apache2 bash'
alias mysql='cd /vagrant/laradock ; docker-compose exec mysql bash'
```

---

### Docker

`docker --version`

`docker-compose --version`

`docker-machine --version`

---

### ADD DynamoDB local

```bash
cd laradoc
mkdir dynamodb
vi docker-compose.yml
```

```docker-compose.yml
### DynamoDB ################################################
    dynamodb:
      image: instructure/dynamo-local-admin
      volumes:
          - ./dynamodb:/var/lib/dynamodb
      ports:
          - "8000:8000"
      networks:
        - backend
```

### Preparation

```bash
cd ../../
cp env-example .env
cp apache2/sites/default.apache.conf apache2/sites/lara.test.conf
vi apache2/sites/lara.test.conf
```

```text
<VirtualHost *:80>
  ServerName lara.test
  DocumentRoot /var/www/lara.test/public/
  Options Indexes FollowSymLinks

  <Directory "/var/www/lara.test/public/">
    AllowOverride All
    <IfVersion < 2.4>
      Allow from all
    </IfVersion>
    <IfVersion >= 2.4>
      Require all granted
    </IfVersion>
  </Directory>

</VirtualHost>
```

```bash
vi .env
```

```text
PHP_VERSION=7.3
MYSQL_VERSION=5.7
```

### docker up

`/vagrant/laradock`

- Apache2 (Web Server)
- PHP-FPM (Fast CGI)
- MySQL (Database)
- Redis (KVS Cache)
- DynamoDB (KVS)
- MailHog (Mail Server)
- workspce

```text
docker-compose up -d apache2 php-fpm mysql redis dynamodb mailhog workspace
```

---

### Install Laravel

```text
docker-compose exec --user=laradock workspace bash
```

`/path/to/your/project`

```text
composer create-project --prefer-dist laravel/laravel . "5.7.*"
```

---

#### .env

```text
...
DB_HOST=mysql
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root
...
REDIS_HOST=redis
...
MAIL_HOST=mailhog
MAIL_PORT=1025
...
```

---

#### Permission

```text
chmod -R 755 storage
chmod -R 755 bootstrap/cache
```

---

#### hosts

```text
192.168.33.10 laravel.test
```

---

#### config/app.php

```text
'timezone' => 'Asia/Tokyo',
...
'locale' => 'ja',
```

---

#### ide_helper

```text
composer require --dev barryvdh/laravel-ide-helper
php artisan ide-helper:generate
```

---

#### laravel-enum

[https://github.com/BenSampo/laravel-enum](https://github.com/BenSampo/laravel-enum)

---

#### laravel-dynamodb

[https://github.com/baopham/laravel-dynamodb](https://github.com/baopham/laravel-dynamodb)

```text
DYNAMODB_CONNECTION=local
DYNAMODB_REGION=eu-west-1
DYNAMODB_KEY=local
DYNAMODB_SECRET=local
DYNAMODB_DEBUG=true
DYNAMODB_LOCAL_ENDPOINT=http://dynamodb:8000
```

---

#### AWS SDK

[https://packagist.org/packages/aws/aws-sdk-php-laravel](https://packagist.org/packages/aws/aws-sdk-php-laravel)

```text
composer require aws/aws-sdk-php-laravel
```

```text
AWS_ACCESS_KEY_ID=local
AWS_SECRET_ACCESS_KEY=local
AWS_REGION=eu-west-1
```

---

