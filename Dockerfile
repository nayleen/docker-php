ARG PHP_VERSION="8.4"

FROM php:${PHP_VERSION}-zts AS php

# export ENV variables
ENV \
  COMPOSER_HOME=/app/var/composer \
  COMPOSER_NO_INTERACTION=1 \
  COMPOSER_PROCESS_TIMEOUT=0 \
  PHP_INI_MEMORY_LIMIT=256M \
  PHP_INI_SCAN_DIR=":/app/etc/php/conf.d" \
  PHP_INI_TEMPLATE_FILE=production \
  TZ=UTC \
  XDEBUG_MODE=off

# add rootfs overlay
COPY --link rootfs /

# install additional software
ADD --link --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/sbin/install-php-extensions

# system setup
RUN install-packages \
    ca-certificates \
    curl \
    lsb-release \
    sudo \
    unzip \
    wget \
    zip \
# create app user
  && useradd \
    --groups sudo \
    --no-create-home \
    --shell /bin/bash \
    --uid 1000 \
    app \
# create world-writable phpstorm coverage directory in the expected location
  && mkdir -p /opt/phpstorm-coverage \
  && chmod a+rw /opt/phpstorm-coverage \
# cleanup
  && rm -rf \
    /tmp/* \
    /usr/local/bin/docker-php-entrypoint \
    /var/lib/apt/lists/* \
    /var/cache/* \
    /var/log/* \
    /var/tmp/*

# php setup
RUN \
# install additional extensions
  install-php-extensions \
    @composer \
    bcmath \
    curl \
    ev \
    event \
    igbinary \
    msgpack \
    opcache \
    opentelemetry \
    parallel \
    pcntl \
    protobuf \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    uuid \
    uv \
    xdebug \
    zip \
    zstd \
# run composer self-update
  && composer self-update \
# move php.ini template files to /app/etc/php
  && mv /usr/local/etc/php/php.ini-development /app/etc/php/php.ini-development \
  && mv /usr/local/etc/php/php.ini-production /app/etc/php/php.ini-production \
# symlink /app/etc/php/php.ini (copied into the container or symlinked during init) back to its scan location
  && ln -sf /app/etc/php/php.ini /usr/local/etc/php/php.ini \
# set app folder permissions
  && chown -R app:app /app \
# cleanup
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/* \
    /var/log/* \
    /var/tmp/*

WORKDIR /app/src

USER app

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php", "-a"]
