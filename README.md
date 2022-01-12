# PHP-FPM Docker image for Laravel

Docker image for a php-fpm container crafted to run Laravel based applications.


## Connect database with following setting:

```yml
hostname: localhost
port: 49161
sid: xe
username: system
password: oracle
```

## Password for SYS & SYSTEM

    oracle

## Login by SSH

```yml
ssh root@localhost -p 49160
password: admin
```

## Laravel ENV

```yml
DB_CONNECTION=oracle
DB_HOST=oracledb
DB_PORT=1521
DB_DATABASE=xe
DB_USERNAME=LARAVEL
DB_PASSWORD=password
```

## Install Laravel Admin

```yml
php artisan admin:install
```

## Admin Login

```yml
username: admin
password: admin
```