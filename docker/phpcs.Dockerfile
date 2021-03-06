FROM php:7.2-alpine

RUN mkdir /src \
  && mkdir /tool

RUN apk update \
  && apk add zip libzip-dev \
  && docker-php-ext-install zip \
  && rm -rf /var/cache/apk/*

COPY composer.json /tool

# Get composer, install PHP tools and remove composer.
RUN cd /tool \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php --install-dir /tool \
  && php /tool/composer.phar install \
  # make phpcs quack like a system binary
  && ln -s /tool/vendor/bin/phpcs /usr/bin/phpcs \
  && ln -s /tool/vendor/bin/phpcbf /usr/bin/phpcbf \
  # Add coding standards to phpcs
  && vendor/bin/phpcs --config-set installed_paths /tool/vendor/cakephp/cakephp-codesniffer \
  # cleanup
  && rm /tool/composer.phar /tool/composer-setup.php /tool/composer.json /tool/composer.lock

WORKDIR /src
