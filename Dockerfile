FROM php:cli-alpine

LABEL maintainer="elitonluiz1989@gmail.com"
LABEL version="1.0.1"

RUN apk update; \
    apk upgrade;

# install extensions
# intl, zip, soap
RUN apk add --update --no-cache \
    curl \
    wget \
    bash \
    libzip-dev \
    libc-dev \
    icu-dev \
    libxml2-dev \
    && docker-php-ext-install intl zip

# mysqli, pdo, pdo_mysql, pdo_pgsql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# mcrypt, gd, iconv
RUN apk add --update --no-cache \
    freetype \
    freetype-dev \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

# xdebug
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps \
    && rm -rf /tmp/*

# Adding composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

# Adding option of wait other container
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/bin/wait-for-it
RUN chmod +x /usr/bin/wait-for-it

RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000

#CMD ["php-fpm", "-F", "-R"]
CMD [ "tail", "-f", "/dev/null" ]