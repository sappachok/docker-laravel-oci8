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