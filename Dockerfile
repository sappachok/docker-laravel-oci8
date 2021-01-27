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
ADD ./instantclient/18.5.0.0.0/instantclient-basiclite-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /tmp/
ADD ./instantclient/18.5.0.0.0/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/

ENV LD_LIBRARY_PATH /usr/local/instantclient_18_5/

RUN ln -s /usr/local/instantclient_18_5 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

ENV LD_LIBRARY_PATH /usr/local/instantclient/
RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc
RUN echo 'umask 002' >> /root/.bashrc

RUN apt-get install build-essential libaio1
RUN pecl channel-update pecl.php.net

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.2.0
RUN echo "extension=oci8.so" > /usr/local/etc/php/conf.d/php-oci8.ini

RUN docker-php-ext-enable oci8 \
       && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient \
       && docker-php-ext-install pdo_oci 

RUN ldd /usr/local/lib/php/extensions/no-debug-non-zts-20190902/oci8.so
RUN php -m | grep 'oci8'

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80
EXPOSE 9000