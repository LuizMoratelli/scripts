#!/bin/bash
apache2_enable_ssl() {
    mkdir -p /etc/apache2/certificates-enabled/
    a2enmod ssl
}

apache2_enable_macro() {
    a2enmod macro
    # Create 000-macro-vhost.conf
    # Create 001-sites.conf
    # a2dissite 000-default.conf
    # a2ensite 001-sites.conf
}

apache2_configure_public() {
    mv /var/www/html /var/www/public_html
}

apache2_php() {
    apt-get install -y libapache2-mod-php7.2
}

install_apache2() {
    apt-get install -y apache2
    
    apache2_enable_macro
    apache2_enable_ssl
    apache2_php

    chown -R www-data. /etc/apache2
    systemctl restart apache2
}

install_mysql() {
    apt-get install -y mysql-server
} 

setup()  {
    apt -y update
    install_apache2
    install_mysql
}

setup