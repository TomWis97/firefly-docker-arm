FROM armv7/armhf-ubuntu_core

ARG FIREFLY_VERSION=4.3.3
ARG FIREFLY_HOME=/opt/firefly
#ARG COMPOSER_VERSION=1.0.2

ENV FIREFLY_CONFIG_APP_ENV=production \
    FIREFLY_CONFIG_APP_DEBUG=false \
    FIREFLY_CONFIG_APP_FORCE_SSL=false \
    FIREFLY_CONFIG_APP_FORCE_ROOT= \
    FIREFLY_CONFIG_APP_KEY=3QXPjxPBx29zaWK3NhhUc39kjUtbJAGa \
    FIREFLY_CONFIG_APP_LOG_LEVEL=warning \
    FIREFLY_CONFIG_APP_URL=http://localhost \
    FIREFLY_CONFIG_DB_CONNECTION=mysql \
    FIREFLY_CONFIG_DB_HOST=127.0.0.1 \
    FIREFLY_CONFIG_DB_PORT=3306 \
    FIREFLY_CONFIG_DB_DATABASE=firefly \
    FIREFLY_CONFIG_DB_USERNAME=root \
    FIREFLY_CONFIG_DB_PASSWORD=6GDpdggUSU4D2mSf \
    FIREFLY_CONFIG_COOKIE_PATH="/" \
    FIREFLY_CONFIG_COOKIE_DOMAIN= \
    FIREFLY_CONFIG_COOKIE_SECURE=false \
    FIREFLY_CONFIG_MAIL_DRIVER=smtp \
    FIREFLY_CONFIG_MAIL_HOST= \
    FIREFLY_CONFIG_MAIL_PORT= \
    FIREFLY_CONFIG_MAIL_FROM= \
    FIREFLY_CONFIG_MAIL_USERNAME= \
    FIREFLY_CONFIG_MAIL_PASSWORD= \
    FIREFLY_CONFIG_MAIL_ENCRYPTION= \
    FIREFLY_CONFIG_SEND_REGISTRATION_MAIL=true \
    FIREFLY_CONFIG_MUST_CONFIRM_ACCOUNT=false \
    FIREFLY_CONFIG_SHOW_INCOMPLETE_TRANSLATIONS=false \
    FIREFLY_CONFIG_ANALYTICS_ID= \
    FIREFLY_CONFIG_SITE_OWNER= 

# Install php; v7 is default by ubuntu 16.04
RUN apt-get update && \
    apt-get -y install \
    apt-utils \
    wget \
    git \
    zip \
    unzip \
    vim \
    nginx \
    mysql-client \
    postgresql-client \
    supervisor \
    php \
    php-cli \
    php-common \
    php-fpm \
    php-mysql \
    php-pgsql \
    php-curl \
    php-gd \
    php-imap \
    php-intl \
    php-json \
    php-mcrypt \
    php-readline \
    php-tidy \
    php-zip \
    php-bcmath \
    php-xml \
    php-mbstring \
    php-bz2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install mysql-server
# Yes, this is a hardcoded root password for MySQL server. Yay for bad-practices.
RUN bash -c """debconf-set-selections <<< 'mysql-server mysql-server/root_password password 6GDpdggUSU4D2mSf' && \
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 6GDpdggUSU4D2mSf'"""
#TODO: Move curl to package list above.
RUN apt-get update && \
    apt-get -y install \
    mysql-server \
    curl && \
    apt-get clean && \
    rm -rf /var/log/apt/lists/* /tmp/* /var/tmp/*
RUN /etc/init.d/mysql start && \
    echo 'CREATE DATABASE firefly' | mysql --user=root --password=6GDpdggUSU4D2mSf

# Install composer
#RUN wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar -O /usr/local/bin/composer && \
#    chmod +x /usr/local/bin/composer && \
#    composer selfupdate
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install firefly
RUN git clone --branch "${FIREFLY_VERSION}" https://github.com/JC5/firefly-iii.git --depth 1 "${FIREFLY_HOME}" && \
    cd "${FIREFLY_HOME}" && \
    composer install --no-scripts --no-dev
RUN chown -R www-data "${FIREFLY_HOME}"

# Add configuration
ADD config/firefly/env "/var/firefly/env"
ADD config/nginx/firefly /etc/nginx/sites-available/default
ADD config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Creating volume and moving data around.
VOLUME /data
VOLUME /var/lib/mysql
VOLUME /opt/firefly/storage
#RUN mv /var/lib/mysql /data/ && \
#    ln -s /data/mysql /var/lib/mysql && \
#    mv /opt/firefly/storage /data/ && \
#    ln -s /data/storage /opt/firefly/storage

# Define docker entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/bin/bash","--","/docker-entrypoint.sh"]

# Bootstrap
WORKDIR ${FIREFLY_HOME}
EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]
