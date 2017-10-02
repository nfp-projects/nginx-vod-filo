FROM alpine:3.6

RUN apk add --no-cache curl supervisor build-base openssl openssl-dev zlib-dev \
                      linux-headers pcre-dev ffmpeg ffmpeg-dev ca-certificates \
                      openssl pcre zlib libxml2 libxml2-dev

# This is the commit that makes nginx-upstream-dynamic-servers compatible with
# nginx 1.12.1, once there's a release of the module, we can start using a
# version number.
ENV DYN_UPSTREAM_VERSION=29e05c5de4d9e7042f66b99d22bef878fd761219 \
    NGINX_VERSION=1.12.1 \
    VOD_MODULE_VERSION=1.20 \
    PHP_VERSION=7.1.10 \
    SOURCE_FOLDER=/src/

###############################
# NGINX                       #
###############################
RUN mkdir /src \
          /src/nginx \
          /src/nginx-vod-module \
          /src/nginx-upstream-dynamic-servers && \
    cd /src/nginx && \
    curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C ${SOURCE_FOLDER}nginx --strip 1 -xz && \
    curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C ${SOURCE_FOLDER}nginx-vod-module --strip 1 -xz && \
    curl -sL https://github.com/GUI/nginx-upstream-dynamic-servers/archive/${DYN_UPSTREAM_VERSION}.tar.gz | tar -C ${SOURCE_FOLDER}nginx-upstream-dynamic-servers --strip 1 -xz && \
    ./configure --prefix=/usr/local/nginx \
      --add-module=../nginx-vod-module \
      --add-module=../nginx-upstream-dynamic-servers \
      --with-http_ssl_module \
      --with-ipv6 \
      --with-file-aio \
      --with-threads \
      --with-cc-opt="-O3" && \
    make && \
    make install && \
    rm -rf /src \
           /usr/local/nginx/html \
           /usr/local/nginx/conf/*.default

###############################
# PHP                         #
###############################
RUN mkdir /src \
          /src/php && \
    cd /src/php && \
    curl -sL http://uk1.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror | tar -C ${SOURCE_FOLDER}php --strip 1 -xz && \
    ./configure --enable-fpm && \
    make && \
    make install && \
    cp php.ini-production /usr/local/php/php.ini && \
    cp sapi/fpm/php-fpm /usr/local/bin && \
    rm -rf /src


###############################
# SERVER                      #
###############################
WORKDIR /
COPY conf/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY conf/fastcgi_params /usr/local/nginx/conf/fastcgi_params
COPY conf/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY conf/supervisord.conf /etc/supervisord.conf
COPY www/ /www

ENTRYPOINT ["supervisord", "--configuration", "/etc/supervisord.conf"]
# ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
# CMD ["-g", "daemon off;"]
