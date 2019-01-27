FROM alpine:3.6

RUN apk add --no-cache supervisor openssl \
                      ffmpeg ca-certificates \
                      openssl pcre zlib libxml2

# This is the commit that makes nginx-upstream-dynamic-servers compatible with
# nginx 1.12.1, once there's a release of the module, we can start using a
# version number.
# ENV DYN_UPSTREAM_VERSION=29e05c5de4d9e7042f66b99d22bef878fd761219 \
ENV NGINX_VERSION=1.12.1 \
    VOD_MODULE_VERSION=1.20 \
    LUA_VERSION=0.10.13 \
    SOURCE_FOLDER=/src/ \
    LUAJIT_VERSION=2.0.5

###############################
# NGINX                       #
###############################
RUN mkdir /src  \
          /src/nginx \
          /src/nginx-vod-module \
          /src/lua-nginx-module \
          /src/luajit2 && \
    apk add --virtual build-dependencies \
            --no-cache curl build-base ffmpeg-dev linux-headers \
                      zlib-dev pcre-dev binutils && \
    echo "Downloading nginx https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C ${SOURCE_FOLDER}nginx --strip 1 -xz && \
    echo "Downloading nginx-vod-module https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz" && \
    curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C ${SOURCE_FOLDER}nginx-vod-module --strip 1 -xz && \
    echo "Downloading lua-nginx-module https://github.com/openresty/lua-nginx-module/archive/v$LUA_VERSION.tar.gz" && \
    curl -sL https://github.com/openresty/lua-nginx-module/archive/v$LUA_VERSION.tar.gz | tar -C ${SOURCE_FOLDER}lua-nginx-module --strip 1 -xz && \
    echo "Downloading LuaJIT http://luajit.org/download/LuaJIT-$LUAJIT_VERSION.tar.gz" && \
    curl -sL http://luajit.org/download/LuaJIT-$LUAJIT_VERSION.tar.gz | tar -C ${SOURCE_FOLDER}luajit2 --strip 1 -xz && \
    cd ${SOURCE_FOLDER}luajit2 && \
    make && \
    make install && \
    cd /src/nginx && \
    ./configure --prefix=/usr/local/nginx \
                --with-ld-opt="-Wl,-rpath,/usr/local/luajit-2.0.5/lib" \
                --add-module=../nginx-vod-module \
                --add-module=../lua-nginx-module \
                --with-ipv6 \
                --with-file-aio \
                --with-threads \
                --with-cc-opt="-O3" && \
    make && \
    make install && \
    strip /usr/local/nginx/sbin/nginx* && \
#   strip /usr/lib/nginx/modules/*.so && \
    apk del build-dependencies && \
    rm -rf /src \
           /usr/local/nginx/html \
           /usr/local/nginx/conf/*.default


###############################
# SERVER                      #
###############################
WORKDIR /
COPY conf/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY conf/supervisord.conf /etc/supervisord.conf
COPY www/ /www

ENTRYPOINT ["supervisord", "--configuration", "/etc/supervisord.conf"]
# ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
# CMD ["-g", "daemon off;"]
