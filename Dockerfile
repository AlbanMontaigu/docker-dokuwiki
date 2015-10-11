# ================================================================================================================
#
# Dokuwiki with NGINX and PHP-FPM
#
# @see https://github.com/AlbanMontaigu/docker-nginx-php/blob/master/Dockerfile
# @see https://github.com/docker-library/wordpress/blob/master/fpm/Dockerfile
# @see https://github.com/istepanov/docker-dokuwiki/blob/master/Dockerfile
# @see https://github.com/AlbanMontaigu/docker-wordpress
# ================================================================================================================

# Base is a nginx install with php
FROM amontaigu/nginx-php-plus:5.6.14

# Maintainer
MAINTAINER alban.montaigu@gmail.com

# Dokuwiki env variables
ENV DOKUWIKI_VERSION="2015-08-10a"

# System update & install the PHP extensions we need
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd

# Get Dokuwiki and install it
RUN mkdir -p --mode=777 /var/backup/dokuwiki \
    && mkdir -p --mode=777 /usr/src/dokuwiki \
    && curl -o dokuwiki.tgz -SL http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz \
    && tar -xzf dokuwiki.tgz --strip-components=1 -C /usr/src/dokuwiki \
    && rm dokuwiki.tgz \
    && chown -R nginx:nginx /usr/src/dokuwiki

# NGINX tuning for DOKUWIKI
COPY ./nginx/conf/sites-enabled/default.conf /etc/nginx/sites-enabled/default.conf

# Entrypoint to enable live customization
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Volume for dokuwiki backup
VOLUME /var/backup/dokuwiki

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
