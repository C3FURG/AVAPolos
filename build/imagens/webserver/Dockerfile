FROM alpine:3.8

MAINTAINER Rafael Souza <rsouza19796@gmail.com>

#Chave pública do repositório de pacotes php.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN apk --update add ca-certificates
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
#https://github.com/codecasts/php-alpine
RUN echo "@php https://dl.bintray.com/php-alpine/v3.8/php-7.2" >> /etc/apk/repositories

#Adicionando pacotes básicos
RUN apk update && apk add apache2 openntpd tzdata ca-certificates shadow file

# Setup apache and php
RUN apk --no-cache add \
	php7-apache2@php \
	php7@php \
	php7-phar@php \
	php7-json@php \
	php7-iconv@php \
  php7-openssl@php \
	php7-ftp@php \
	php7-xdebug@php \
	php7-mcrypt@php \
	php7-mbstring@php \
	php7-soap@php \
	php7-gmp@php \
	php7-dom@php \
	php7-pdo@php \
	php7-zip@php \
  php7-zlib@php \
	php7-mysqli@php \
	php7-sqlite3@php \
	php7-pdo_pgsql@php \
	php7-bcmath@php \
	php7-gd@php \
	php7-pdo_mysql@php \
	php7-pdo_sqlite@php \
	php7-gettext@php \
	php7-xmlreader@php \
	php7-xmlwriter@php \
	php7-tokenizer@php \
	php7-xmlrpc@php \
	php7-bz2@php \
	php7-pdo_dblib@php \
	php7-curl@php \
	php7-ctype@php \
	php7-session@php \
	php7-redis@php \
	php7-exif@php \
	php7-ssh2@php\
	php7-fileinfo@php \
	php7-pgsql@php \
	php7-intl@php \
	php7-simplexml@php

RUN apk --no-cache add \
	php7-pdo_odbc@php \
	php7-odbc@php

RUN cp /usr/bin/php7 /usr/bin/php

# Add apache to run and configure
RUN mkdir -p /run/apache2 \
    && sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/public\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/app/public#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/app/public\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

COPY root /
RUN chmod +x /start.sh

EXPOSE 80
ENTRYPOINT ["/start.sh"]
