FROM php:fpm
LABEL maintainer "Stefano Azzolini <stefano.azzolini@caffeina.com>"

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

RUN sh -c echo '/usr/local/instantclient_12_2' > /etc/ld.so.conf.d/oracle-instantclient

RUN ldconfig

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"'

RUN pecl channel-update pecl.php.net

RUN echo 'instantclient,/usr/local/instantclient_12_2' | pecl install oci8

RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
    docker-php-ext-install oci8

RUN pecl install xdebug

RUN rm -rf /var/lib/apt/lists/*

RUN php -v

RUN LD_LIBRARY_PATH=/usr/local/instantclient_12_2/ php

#RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so

RUN ldconfig -v

#RUN reboot

WORKDIR /home/www

CMD ["php-fpm"]

EXPOSE 9000