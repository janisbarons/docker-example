FROM php:7.2-fpm

ENV WEB_DIRECTORY=/usr/share/www
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install --allow-unauthenticated -y -q \
    build-essential \
    mysql-client \
    pkg-config \
    ruby2.3-dev \
    libpng-dev libxml2-dev libtidy-dev libjpeg62-turbo-dev libfreetype6-dev libssl-dev libcurl4-openssl-dev libbz2-dev libmemcached-dev \
    automake make autoconf \
    libmagickwand-dev libmagickcore-dev \
    jpegoptim optipng pngquant gifsicle \
    git locales vim zip unzip jq gettext wget curl iputils-ping

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl soap ctype xml tidy bz2
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

RUN curl https://pecl.php.net/get/imagick-3.4.3.tgz | tar xvz \
    && cd imagick-3.4.3 && phpize && ./configure && make && make install \
    && echo extension=imagick.so >> /usr/local/etc/php/conf.d/imagick.ini

RUN pecl install timecop-beta \
    && echo extension=timecop.so >> /usr/local/etc/php/conf.d/timecop.ini

RUN pecl install memcached \
    && echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini
    
## Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer global require hirak/prestissimo --no-plugins --no-scripts --quiet

## Create user
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

RUN apt-get update && apt-get install -y gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y -q nodejs
