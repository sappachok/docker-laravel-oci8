FROM php:fpm
LABEL maintainer "Sappachok Singhasuwan <suppachok_sin@nstru.ac.th>"

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
ADD ./instantclient/18.5.0.0.0/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_18_5 /usr/local/instantclient
#RUN ln -s /usr/local/instantclient_18_5/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
#RUN ln -s /usr/local/instantclient_18_5/libocci.so.12.1 /usr/local/instantclient/libocci.so
RUN ln -s /usr/local/instantclient_18_5/sqlplus /usr/bin/sqlplus

RUN sh -c echo '/usr/local/instantclient_18_5' > /etc/ld.so.conf.d/oracle-instantclient

RUN ldconfig

#RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"'
RUN LD_LIBRARY_PATH=/usr/local/instantclient_18_5/ php

RUN sh -c echo '/usr/local/instantclient_18_5' > /etc/ld.so.conf.d/oracle-instantclient

RUN echo 'export ORACLE_HOME=/opt/oracle' >> /root/.bashrc
RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN pecl channel-update pecl.php.net

RUN echo 'instantclient,/usr/local/instantclient_18_5' | pecl install oci8
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient
RUN docker-php-ext-install pdo_oci

RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
    docker-php-ext-install oci8

RUN docker-php-ext-enable oci8

RUN pecl install xdebug

RUN rm -rf /var/lib/apt/lists/*

RUN php -v

RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20200930/oci8.so
# RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so

RUN ldconfig -v
RUN php --ri oci8
#RUN reboot

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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