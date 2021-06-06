# Laradock

- VirtualBox
- Vagrant
- Git For Windows
- CentOS 7.5
- Docker
- Laravel
- Nginx
- PHP-FPM
- MySQL
- Redis
- MailHog
- DynamoDB

----

## Prerequisites

```text
Please install the following
```

`Virtual Machine`

- [VirtualBox](https://www.virtualbox.org/)

`declarative configuration file`

- [Vagrant](https://www.vagrantup.com/)

`CLI(GitBash)`

- [Git For Windows]([https://gitforwindows.org/)

```text
Please use GitBash(command line tool) for the following

* Work on your local pc = you should use GitBash

* Work on Linux = vagrant ssh(you are in linux(CentOS))

* Work on MySQL container = you are in Linux(Ubuntu))

* Work on MySQL Application = your are in MySQL Application
```

---

### Laradock Install

`Work on your local pc`

```text
* create workspace and code directory.

[command] mkdir -p ~/workspace/code/mamo

* Please move your local pc

[command] cd ~/workspace/code

* Laradock install

[command] git clone https://github.com/LaraDock/laradock.git laradockch
```

---

### MamosearchCorporations Install

`Work on your local pc`

```text
[command] cd ~/workspace/code/mamo

[command] mkdir mamocorp
```

---

### Vagrantfile Settings

`Work on your local pc`

```text
[command] cd ~/workspace/code/laradockch

* Please create Vagratntfile and copy the fllowing content and paste that

[command] vi Vagrantfile
```

```text
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.network "private_network", ip: "192.168.33.100"
  config.vm.synced_folder "..", "/vagrant"
  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.memory = "2048"
    vb.name = "centos-7.5-laradockch"
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
  SHELL
end
```

---

### Edit docker-compose.yml for adding to DynamoDB local

`Work on your local pc`

```text
[command] cd ~/workspace/code/laradockch

[command] mkdir dynamodb

* Please edit docker-compose.yml and copy the fllowing content and paste that at the bottom

[command] vi docker-compose.yml
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

### Edit .env for php and mysql version

`Work on your local pc`

```text
[command] cd ~/workspace/code/laradockch

[command] cp env-example .env

[command] vi .env
```

```text
PHP_VERSION=7.3

MYSQL_VERSION=5.7
```

---

### Edit mamocorp.test.conf for Nginx

`Work on your local pc`

```text
[command] cd ~/workspace/code/laradockch/nginx/ssl

* Please copy&paste the following that

[command] vi default.crt
```

```text
-----BEGIN CERTIFICATE-----
MIIC6TCCAdECFF5aKXYxPVlMuUBbWPVBYVOGdmZmMA0GCSqGSIb3DQEBCwUAMDEx
EDAOBgNVBAMMB2RlZmF1bHQxEDAOBgNVBAoMB2RlZmF1bHQxCzAJBgNVBAYTAlVL
MB4XDTE5MDYyOTE3MzEyM1oXDTIwMDYyODE3MzEyM1owMTEQMA4GA1UEAwwHZGVm
YXVsdDEQMA4GA1UECgwHZGVmYXVsdDELMAkGA1UEBhMCVUswggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQCsjUz1h4LAFQhJMMWNeccG52Q3UE2Ab7bo7sco
FzJ1ZcI3crriHCN958ggpTg+qERLWyjbjzu/A5t9lL1pwpissScivv9+FVGhfipE
puUP05Kp7ZgSFCud2RQBfQz68Ao/SDar/2cRGDP/HIYcKzCdlKu1B+Enbi2cwd6F
wZQKyB82K5hEVGIuRMKjqP85OSCzE24PQmsnm9zeyEucmDYk5cxQZvY36SHIX0Eq
u5X/Hhi8lcywYYRitwsTzvo2PBb3MAhXbLkDZCaWku1ztgRoFCHu3LOvbDS49tjH
0QGEhJ1+z6ePoxz1itAPc4nbn/cu7ySwRxfVgJYkR656NfrzAgMBAAEwDQYJKoZI
hvcNAQELBQADggEBAIK1epNWWRFV63/miorPxAo/h0LCa6K0DO4AZR6GtBwilKOZ
WLEDBs3UwQaRi5g6vTdJ8znQy2Wq6BEYJTh5u7IfVKl2EPjcTQCB4al03646mB/F
CN+l3of+6FcQ//31QNge8a+Yf2en1gt2Qkejadhv3+JXDhm2nP8W6Fy/sqdEaq/j
bltwvcMf5/gOuNsAJDLex/G/TN/fprwyrWtGElQoDRSM/8jtAcUd0w++7hDkTTt6
TmMJPeQoLlhXXByUTwKR1nU2ymEey5u57n2z7dDbjNwXQs4fqYgtBdeHe+9du0MJ
BecYOyFvil2/a+IbrlNCs/ox7R4zREMJj2qFVZY=
-----END CERTIFICATE-----
```

```
* Please copy&paste the following that

[command] vi default.csr
```

```text
-----BEGIN CERTIFICATE REQUEST-----
MIICdjCCAV4CAQAwMTEQMA4GA1UEAwwHZGVmYXVsdDEQMA4GA1UECgwHZGVmYXVs
dDELMAkGA1UEBhMCVUswggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCs
jUz1h4LAFQhJMMWNeccG52Q3UE2Ab7bo7scoFzJ1ZcI3crriHCN958ggpTg+qERL
Wyjbjzu/A5t9lL1pwpissScivv9+FVGhfipEpuUP05Kp7ZgSFCud2RQBfQz68Ao/
SDar/2cRGDP/HIYcKzCdlKu1B+Enbi2cwd6FwZQKyB82K5hEVGIuRMKjqP85OSCz
E24PQmsnm9zeyEucmDYk5cxQZvY36SHIX0Equ5X/Hhi8lcywYYRitwsTzvo2PBb3
MAhXbLkDZCaWku1ztgRoFCHu3LOvbDS49tjH0QGEhJ1+z6ePoxz1itAPc4nbn/cu
7ySwRxfVgJYkR656NfrzAgMBAAGgADANBgkqhkiG9w0BAQsFAAOCAQEAdejNzwG/
t/IwQ4PJnMurqaoZxvLEN3hKJoe1txK+JQWKhWbF8lA9c3FErexbds9p3bqVRP4h
bm+2seItSaG1d/VT8E6hHU1kHqfmvnPq0SOxBRZN+BsULx6BPaVgnJMeVjF/w6Hl
BPi0IFZcrU6lsiGopvZVyoWrfdvuchYr6zoXFZV6pbuHqLuAWPENObZR+gC+k6TC
BNoaV3rcJB4InFAYGL9cs2fxhb5FlIarrfSXWBIuWSyArCNa9svR9R5RJ00lO6HZ
PbCcBnKO7ZSP/g8fBoX+uP3hT1xyeAxP+xU97WRSAe2dGOLnt7dfqwhEHrSQ62jm
SBTNcnP3yGbE4A==
-----END CERTIFICATE REQUEST-----
```

```text
* Please copy&paste the following that

[command] vi default.key
```

```text
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEArI1M9YeCwBUISTDFjXnHBudkN1BNgG+26O7HKBcydWXCN3K6
4hwjfefIIKU4PqhES1so2487vwObfZS9acKYrLEnIr7/fhVRoX4qRKblD9OSqe2Y
EhQrndkUAX0M+vAKP0g2q/9nERgz/xyGHCswnZSrtQfhJ24tnMHehcGUCsgfNiuY
RFRiLkTCo6j/OTkgsxNuD0JrJ5vc3shLnJg2JOXMUGb2N+khyF9BKruV/x4YvJXM
sGGEYrcLE876NjwW9zAIV2y5A2QmlpLtc7YEaBQh7tyzr2w0uPbYx9EBhISdfs+n
j6Mc9YrQD3OJ25/3Lu8ksEcX1YCWJEeuejX68wIDAQABAoIBAHDh96jgv/7dQ5Bu
Ia9OLZAsrHkrRahybRyxqQRnOJFowsf3fJ8TfXyOt3Pz4nnLJvKNbotEhveNapmb
Rtb7gVnogwvOG+LmG4MkwI4tCMlzxgz47HVXULlxHA9lOaqogmun2GxpJ4odZVbN
2EZxUtqkOjiyMO/Uum5EvkiOvUTXV6yVOoTYvQkP2UmdNb4PzaUORBU4AV0iQ0KM
3O/CzmWLt7wJLjImKFsXIhjzhnRyAm2C5N3IkbGbA2qL1s6OvgS2lB465a3mZ3/F
dmQdRotTXlIfm9xA2+NIYY4jbOxTYjaqtrm04lwIr4uHqVdvcnZnT7WaSNLrUlxI
cdACKYECgYEA2sfSZy9K7jD46x/jzBuOj8jIomlYjX56I/82IfyyjZ+VhVfWiSas
s6f08+1S97u88B5e6UmpDnRGFKzr9nXaXs+6Va1s+J/4HeyB3/idsg7wAXQzWwHY
rMnfN9yfK4JnMKPZYZVxJDE+P8xeBDN6vdGBXwcZbbpLGXsNAJ3YUFMCgYEAyegp
vV0x2n0R7uNsKghK+Oy0eaI8IW+9qHXP59gxbdwVT+Sgp189J9c2yfYX7gw0cVXl
3BnFFiHDfMN9P8Hsx7fAQjOi1/Hy7AbEMXPcM6150Ad1LxjPlhimFE+Vv4LV6doD
V2wKUvJy0/7gU83y7+MMgQx84ox9VYqhC44G1uECgYAErUrhK9ClQOTBWgArp9cn
Wbp4Rlo/RBnmVRlaJqXGg0fV/ue2LN56RLfm0wb4BspmM7ABurJjfbbV0FCHB0Pw
zO4F0NxIgFr0gM7R8+WjHdChp1NFucdhAjvEXPIGIxaDoq0N+fzeMjNLd9n2qwcP
sb/bQTKY9ueOFuRTRAyQwwKBgQCebwEhyNlv2yiRTf/4U52RCxzrPTT1/9rRL/E+
ulS/Ii3PDVZLP96bPrONcwCAGS+lp4PBXK9cmI3vfu7vctq8NSI2UJJ95St7riuR
qpqmKoAlj1SS6mMqIplf4rtdFeuJnzt0BCFtyTX1yFB7MmZper67HPN6SkenMisB
CCexwQKBgHs6UUGD2ANK8J1pbvoIzQirtb+QJ/bl9Ta+yyboMaZbMY/nXBtct0EW
2cY+kb8CJSRFItwtqOStQY6PPTZbfQHEVZu/6lIyW9Xq0hQOfEDIV1ZtrnlC2Exl
YfDnf6XslYzz2xH045kg/X0aVYaFYSwHT4U//v/FzGfDMio19mzL
-----END RSA PRIVATE KEY-----
```

```text
[command] cd ~/workspace/code/laradockch/nginx/sites

[command] cp laravel.conf.example mamocorp.test.conf

[command] vi mamocorp.test.conf
```

```test
# For https
listen 443 ssl;
listen [::]:443 ssl ipv6only=on;
ssl_certificate /etc/nginx/ssl/default.crt;
ssl_certificate_key /etc/nginx/ssl/default.key;

server_name mamocorp.test
root /var/www/mamo/mamocorp/public

error_log /var/log/nginx/mamocorp.test_error.log;
access_log /var/log/nginx/mamocorp.test_access.log;
```

---

#### Edit your hosts file

`Work on your local pc`

```text
* Please edit hosts file at the bottom

- For Mac
[command] vi C:\Windows\System32\drivers\etc\hosts

- For Windows
[command] vi /etc/hosts

```

```text
192.168.33.100 mamocorp.test mamodynamodb.test
```

---

### vagrant up

`Work on your local pc`

```text
[command] cd ~/workspace/code/laradockch

[command] vagrant up
```

```text
Vagrant was unable to mount VirtualBox shared folders. This is usually
because the filesystem "vboxsf" is not available. This filesystem is
made available via the VirtualBox Guest Additions and kernel module.
Please verify that these guest additions are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant

The error output from the command was:

/sbin/mount.vboxsf: mounting failed with the error: No such device
```

```text
* If you get above the error message, you should input the command

[command] vagrant plugin install vagrant-vbguest

* You should also input the command

[command] vagrant up

[command] vagrant halt

[command] vagrant up
```

```text
* Your command line on display is the following the message "running (virtualbox)"

[command] vagrant status

Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

```text
* you enter linux(CentOS)

[command] vagrant ssh
```

---

### .bashrc

`Work on Linux`

```text
* Please edit the .bashrc and add the following contents at the bottom(copy&paste)

[command] vi ~/.bashrc
```

```text
# User specific aliases and functions

alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd .. ; ll'
alias c='clear'
alias laradock='cd /vagrant/laradockch'

# Docker Command
alias dce='docker-compose exec'
alias dup='docker-compose up -d'
alias dps='docker-compose ps'
alias stop='cd /vagrant/laradockch ; docker-compose stop'
alias run='cd /vagrant/laradockch ; docker-compose up -d workspace nginx php-fpm mysql dynamodb redis mailhog'
alias workspace='cd /vagrant/laradockch ; docker-compose exec workspace bash'
alias nginx='cd /vagrant/laradockch ; docker-compose exec nginx bash'
alias mysql='cd /vagrant/laradockch ; docker-compose exec mysql bash'
alias phpfpm='cd /vagrant/laradockch ; docker-compose exec php-fpm bash'
alias dynamodb='cd /vagrant/laradockch ; docker-compose exec dynamodb bash'
```

```text
* When you edit the above the .bashrc, Please input the following command.

[command] source ~/.bashrc
```

---

### Docker

`Work on Linux`

```text
* Please confirm docker version

[command] docker --version

[command] docker-compose --version

[command] docker-machine --version
```

---


### docker-compose up

- Nginx (Web Server)
- PHP-FPM (Fast CGI)
- MySQL (Database)
- Redis (KVS Cache)
- DynamoDB (KVS)
- MailHog (Mail Server)
- workspace

`Work on Linux`

```text
* run = cd /vagrant/laradockch ; docker-compose up -d workspace nginx php-fpm mysql dynamodb redis mailhog (.bashrc alias)
* Please input the following command

[command] run
```

---

### Create Database

`Work on Linux`

```text
* Please input the following command

[command] mysql
```

`Work on MySQL container`

```text
[command] mysql -u root -proot
```

`Work on MySQL Application`

```text
* Please input the following mysql command

[command] > create database mamocorp;
[command] > create database mamocorp_testing;

* Please confirm creating the above that databases

[command] > show databases;

* When you confirm that, input the following command

[command] > exit
```

`Work on MySQL container`

```text
* Please input the following command

[command] exit
```

---

#### Laravel Settings

`Work on Linux`

```text
* Please input the following command

[command] workspace
```

`Work on workspace container`

```text
* Please input the following command

[command] su laradock

[command] cd /var/www/mamo/mamocorp

[command] composer create-project --prefer-dist laravel/laravel . "6.*"
```

### Confirmation access

- [https://mamocorp.test/](https://mamocorp.test/)

- [http://mamodynamodb.test:8000/](http://mamodynamodb.test:8000/)

```text
You should confirm the above local web site.
```