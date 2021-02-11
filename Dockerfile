FROM php:7.4-fpm

MAINTAINER support@cyber-duck.co.uk

ENV COMPOSER_MEMORY_LIMIT='-1'

RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends \
        libmemcached-dev \
        libzip-dev \
        libz-dev \
        libzip-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        openssh-server \
        libmagickwand-dev \
        git \
        cron \
        nano \
        libxml2-dev \
        libreadline-dev \
        libgmp-dev \
        zip \
        curl \
        unzip \
        libaio1 \
        mariadb-client

# Install soap extention
RUN docker-php-ext-install soap

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
RUN docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

# Install the PHP intl extention
RUN docker-php-ext-install intl

# Install the PHP gmp extention
RUN docker-php-ext-install gmp

#####################################
# PHPRedis:
#####################################
RUN pecl install redis && docker-php-ext-enable redis

#####################################
# Imagick:
#####################################

RUN pecl install imagick && \
    docker-php-ext-enable imagick

#####################################
# GD:
#####################################

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

#####################################
# xDebug:
#####################################

# Install the xdebug extension
RUN pecl install xdebug

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
# Source the bash
RUN . ~/.bashrc

#####################################
# Laravel Schedule Cron Job:
#####################################

RUN echo "* * * * * www-data /usr/local/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1"  >> /etc/cron.d/laravel-scheduler
RUN chmod 0644 /etc/cron.d/laravel-scheduler

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

ADD ./laravel.ini /usr/local/etc/php/conf.d

#####################################
# Aliases:
#####################################
# docker-compose exec php-fpm dep --> locally installed Deployer binaries
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/vendor/bin/dep "$@"' > /usr/bin/dep
RUN chmod +x /usr/bin/dep
# docker-compose exec php-fpm art --> php artisan
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan "$@"' > /usr/bin/art
RUN chmod +x /usr/bin/art
# docker-compose exec php-fpm migrate --> php artisan migrate
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate "$@"' > /usr/bin/migrate
RUN chmod +x /usr/bin/migrate
# docker-compose exec php-fpm fresh --> php artisan migrate:fresh --seed
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate:fresh --seed' > /usr/bin/fresh
RUN chmod +x /usr/bin/fresh
# docker-compose exec php-fpm t --> run the tests for the project and generate testdox
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/var/www/vendor/bin/phpunit -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report.txt "$@"' > /usr/bin/t
RUN chmod +x /usr/bin/t
# docker-compose exec php-fpm d --> run the Laravel Dusk browser tests for the project
RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/bin/bash\n/usr/local/bin/php /var/www/artisan dusk -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report-dusk.txt "$@"' > /usr/bin/d
RUN chmod +x /usr/bin/d

RUN rm -r /var/lib/apt/lists/*

# Oracle instantclient
ADD ./instantclient/12.2.0.1.0/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/
ADD ./instantclient/12.2.0.1.0/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/
ADD ./instantclient/12.2.0.1.0/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_2 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/lib* /usr/lib
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN echo 'instantclient,/usr/local/instantclient/' | pecl install oci8
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 \
    && docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu \
    && pecl install sqlsrv-4.1.6.1 \
    && pecl install pdo_sqlsrv-4.1.6.1 \
    && pecl install redis \
    && pecl install memcached

RUN docker-php-ext-install \
            iconv \
            mbstring \
            intl \
            mcrypt \
            gd \
            pgsql \
            mysqli \
            pdo_pgsql \
            pdo_mysql \
            pdo_oci \
            pdo_dblib \
            soap \
            sockets \
            zip \
            pcntl \
            ftp

RUN docker-php-ext-enable \
            oci8 \
            sqlsrv \
            pdo_sqlsrv \
            redis \
            memcached \
            opcache

RUN php -v

# End Install Oracle

RUN usermod -u 1000 www-data

WORKDIR /var/www

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s /usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000
CMD ["php-fpm"]
