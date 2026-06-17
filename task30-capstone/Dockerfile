# ==========================================
# STAGE 1: The Git Builder (CI/CD Phase)
# ==========================================
FROM alpine:3.19 AS builder
RUN apk add --no-cache git
WORKDIR /build
RUN git clone --depth 1 https://github.com/wordpress/wordpress.git .
RUN rm -rf .git

# ==========================================
# STAGE 2: Secure Production Runtime
# ==========================================
FROM php:8.2-fpm-alpine
LABEL maintainer="SRE Capstone Engineer"

RUN apk add --no-cache fcgi freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli opcache \
    && rm -rf /var/cache/apk/*

RUN echo "ping.path = /ping" >> /usr/local/etc/php-fpm.d/zz-docker.conf
WORKDIR /var/www/html
COPY --from=builder --chown=www-data:www-data /build /var/www/html
USER www-data

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

EXPOSE 9000
CMD ["php-fpm"]
