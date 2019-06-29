# Docker setting (Laradoc installation guide)

## Preparation

https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac

## Middleware

- PHP
- Nginx
- MySQL
- Redis
- beanstalkd
- DynamoDB(*1)

## Reference

http://laradock.io/#B

B) Setup for Multiple Projects:

## SETUP

```bash
mkdir docker
cd docker
mkdir {laradock.test}
git clone https://github.com/LaraDock/laradock.git
cd laradock/nginx/sites
cp laravel.conf.example laradock.test.conf
vi laradock.test.conf
```

```laradock.test.conf
server_name laradock.test
root /var/www/laradock.test/public
error_log /var/log/nginx/laradock.test_error.log;
access_log /var/log/nginx/laradock.test_access.log;
```

```bash
cd ../../
cp env-example .env
docker-compose up -d nginx php-fpm mysql redis beanstalkd workspace
docker-compose exec --user=laradock workspace bash
cd laradock.test
composer create-project laravel/laravel --prefer-dist .
vi .env
```

```.env
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=default
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DATABASE=0

QUEUE_HOST=beanstalkd
QUEUE_DEFAULT=default
QUEUE_RETRY_AFTER=90
```

```bash
chmod 777 storage
chmod 777 ./bootstrap/cache/
```

```bash
sudo vi /etc/hosts
```

```hosts
127.0.0.1 laradock.test
```

## ADD DynamoDB local

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

```bash
docker-compose up -d dynamodb
or
docker-compose up -d nginx php-fpm mysql redis beanstalkd dynamodb workspace
```

```bash
brew install awscli
```

```bash
aws configure
AWS Access Key ID [None]: local
AWS Secret Access Key [None]: local
Default region name [None]: eu-west-1
Default output format [None]:
```

```bash
aws dynamodb list-tables --endpoint-url http://localhost:8000
```