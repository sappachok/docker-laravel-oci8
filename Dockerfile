#FROM php:7.4.14-fpm-buster
FROM php:7.4.14-fpm

# install necessary packages

#RUN apt-get install software-properties-common
#RUN add-apt-repository ppa:ondrej/php

RUN set -x \
        && apt-get update \
        && apt-get install libaio1 mc unzip zlib1g-dev libmemcached-dev --no-install-recommends --no-install-suggests -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# install oracle instant client

# Oracle instantclient
ADD ./instantclient/18.5.0.0.0/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_18_5 /usr/local/instantclient
#RUN ln -s /usr/local/instantclient_18_5/libclntsh.so.18.5 /usr/local/instantclient/libclntsh.so
#RUN ln -s /usr/local/instantclient_18_5/libocci.so.18.5 /usr/local/instantclient/libocci.so
RUN ln -s /usr/local/instantclient_18_5/sqlplus /usr/bin/sqlplus

RUN sh -c echo '/usr/local/instantclient_18_5' > /etc/ld.so.conf.d/oracle-instantclient

RUN ldconfig

## put your tnsnames.ora if you have it
# COPY instantclient/tnsnames.ora /usr/local/instantclient_18_5/network/admin/tnsnames.ora

## put your oracle.conf with full path to instant client
# COPY instantclient/oracle.conf /etc/ld.so.conf.d/oracle.conf
RUN ldconfig


# enable opcache

RUN docker-php-ext-enable opcache

# install & enable xdebug

RUN pecl install xdebug-3.0.2 && docker-php-ext-enable xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# install & enable oci8

RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient_18_5"'
RUN LD_LIBRARY_PATH=/usr/local/instantclient_18_5/ php

RUN pecl channel-update pecl.php.net

#RUN pecl install --onlyreqdeps --nobuild oci8-2.2.0 \
#        && cd "$(pecl config-get temp_dir)/oci8" \
#        && phpize \
#        && ./configure --with-oci8=instantclient,/usr/local/instantclient_18_5 \
#        && make && make install \
#        && docker-php-ext-enable oci8

RUN echo 'instantclient,/usr/local/instantclient_18_5' | pecl install oci8-2.2.0
RUN docker-php-ext-enable oci8

# install & enable pdo-oci

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient_18_5,18.5 \
        && docker-php-ext-install pdo_oci

#RUN service php7.4-fpm restart
#RUN restart php7.4-fpm 
#RUN systemctl reload php7.4-fpm.service

#RUN service php7.4-fpm restart
#RUN /etc/init.d/php-fpm restart

RUN cat /etc/os-release

RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so

# install & enable memcached

RUN pecl install memcached-3.1.5 && docker-php-ext-enable memcached

# copy dev php.ini

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# install composer

RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

# Copy our configs to the image.
COPY ./config/custom.ini /usr/local/etc/php/conf.d
COPY ./config/pool.d/custom.conf /usr/local/etc/php/conf.d

RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so

RUN reboot

WORKDIR /home/www

CMD ["php-fpm"]

EXPOSE 9000