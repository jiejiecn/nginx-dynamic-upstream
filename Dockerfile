FROM centos:centos8

ADD nginx-1.25.1.tar.gz /tmp
ADD nginx-upsync-module-2.1.2.tar.gz /tmp
ADD nginx_upstream_check.tar.gz /tmp

WORKDIR /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y tar patch make wget gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel

WORKDIR /tmp/nginx-1.25.1
RUN patch -p1 < /tmp/nginx_upstream_check_module/check_1.20.1+.patch && \
./configure  \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--user=www-data --group=www-data \
--with-http_ssl_module --with-http_gunzip_module --with-http_gzip_static_module --without-http_rewrite_module \
--add-module=/tmp/nginx-upsync-module-2.1.2 \
--add-module=/tmp/nginx_upstream_check_module && \
make && make install

ADD nginx.conf /etc/nginx/nginx.conf
ADD conf.d/app.conf /etc/nginx/conf.d
ADD conf.d/linode.conf /etc/nginx/conf.d


EXPOSE 80/tcp
EXPOSE 443/tcp



