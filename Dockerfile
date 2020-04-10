FROM centos:centos7

ENV nginxversion="1.12.2-1" \
    os="centos" \
    osversion="7" \
    elversion="7_4"

RUN yum install -y wget openssl sed &&\
    yum -y autoremove &&\
    yum clean all &&\
    wget http://nginx.org/packages/$os/$osversion/x86_64/RPMS/nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    rpm -iv nginx-$nginxversion.el$elversion.ngx.x86_64.rpm &&\
    sed -i '1i\
    daemon off;\
    ' /etc/nginx/nginx.conf

# Install PHP
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm

## Install PHP 7.4 
RUN yum --enablerepo=remi-php74 install php -y

RUN yum --enablerepo=remi-php74 -y install php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt \
    php-mbstring php-curl php-xml php-pear php-bcmath php-json


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"



VOLUME ["/data", "/etc/nginx/conf.d", "/var/log/nginx"]

COPY default.conf /etc/nginx/conf.d/default.conf
COPY . /data

EXPOSE 8083 80 443

CMD ["/usr/sbin/nginx"]
