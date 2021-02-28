FROM php:fpm
LABEL maintainer "Sappachok Singhasuwan <suppachok_sin@nstru.ac.th>"

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libxml2-dev \
        libonig-dev \
        zip \
        curl \
        libmemcached-dev \
        build-essential \
        libaio1 \
        libzip-dev \
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

#RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"'
RUN LD_LIBRARY_PATH=/usr/local/instantclient/ php

RUN sh -c echo '/usr/local/instantclient' > /etc/ld.so.conf.d/oracle-instantclient

RUN echo 'export ORACLE_HOME=/usr/local/instantclient' >> /root/.bashrc
RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN echo "LD_LIBRARY_PATH=\"/usr/local/instantclient\"" >> /etc/environment \
    && echo "ORACLE_HOME=\"/usr/local/instantclient\"" >> /etc/environment

RUN ldconfig
ENV LD_LIBRARY_PATH /usr/local/instantclient

RUN pecl channel-update pecl.php.net

RUN pecl install --onlyreqdeps --nobuild oci8-2.2.0 \
        && cd "$(pecl config-get temp_dir)/oci8" \
        && phpize \
        && ./configure --with-oci8=instantclient,/usr/local/instantclient \
        && make && make install \
        && docker-php-ext-enable oci8

# install & enable pdo-oci

RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,12.2 \
        && docker-php-ext-install pdo_oci

RUN docker-php-ext-enable opcache

# install & enable memcached

# RUN pecl install memcached-3.1.5 && docker-php-ext-enable memcached

# copy dev php.ini

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN pecl install xdebug

RUN rm -rf /var/lib/apt/lists/*

RUN php -v

RUN ldconfig -v

#RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20200930/oci8.so
RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so

RUN ls /usr/local/instantclient
RUN php --ri oci8
#RUN reboot

#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install composer

RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

WORKDIR /var/www

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
#COPY . /var/www

# Copy existing application directory permissions
#COPY --chown=www:www . /var/www
RUN chown -R www:www /var/www

# Change current user to www
USER www

EXPOSE 9000
EXPOSE 8000

CMD ["php-fpm"]