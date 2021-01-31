FROM php:7.4.1-apache

USER root

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
        libpng-dev \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
        libonig-dev \
        zip \
        curl \
        unzip \
        libaio1 \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-source delete

COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Oracle instantclient
ADD ./instantclient/12.2.0.1.0/instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/
ADD ./instantclient/12.2.0.1.0/instantclient-sdk-linux.x64-12.2.0.1.0.zip /tmp/
ADD ./instantclient/12.2.0.1.0/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_2 /usr/local/instantclient
RUN ln -s /usr/local/instantclient_12_2/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient_12_2/libocci.so.12.1 /usr/local/instantclient/libocci.so
RUN ln -s /usr/local/instantclient_12_2/sqlplus /usr/bin/sqlplus

RUN echo '/usr/local/instantclient_12_2' > /etc/ld.so.conf.d/oracle-instantclient

RUN ldconfig

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"'

RUN pecl channel-update pecl.php.net

RUN echo 'instantclient,/usr/local/instantclient_12_2' | pecl install oci8-2.2.0
RUN echo "extension=oci8.so" > /usr/local/etc/php/conf.d/php-oci8.ini

RUN apt-get install nano -y

RUN echo "export LD_LIBRARY_PATH=/usr/local/instantclient_12_2" >> /etc/apache2/envvars
RUN echo "export ORACLE_HOME=/usr/local/instantclient_12_2" >> /etc/apache2/envvars
RUN echo "LD_LIBRARY_PATH=/usr/local/instantclient_12_2:\$LD_LIBRARY_PATH" >> /etc/environment

RUN echo "<?php echo phpinfo(); ?>" > /var/www/html/phpinfo.php
RUN echo "<?php echo 'Client Version: ' . oci_client_version(); ?>" > /var/www/html/ocitest.php

RUN echo "service apache2 restart"

# RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so
# RUN php -m | grep 'oci8'

RUN echo "curl http://localhost/phpinfo.php"
RUN echo "curl http://localhost/ocitest.php"

# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80
EXPOSE 9000