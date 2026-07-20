FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SOEDER_ROOT=/opt/soederlang

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 gnucobol jq nodejs npm make ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/soederlang
COPY . .

RUN make -C cobol all \
    && chmod +x cobol/bin/soeder-v2 cobol/cgi/soeder-api \
    && npm --prefix frontend install \
    && npm --prefix frontend run build \
    && rm -rf /var/www/html/* \
    && cp -r frontend/dist/* /var/www/html/ \
    && cp cobol/cgi/soeder-api /usr/lib/cgi-bin/soeder-api \
    && chmod +x /usr/lib/cgi-bin/soeder-api \
    && cp deploy/apache-soeder.conf /etc/apache2/conf-available/soeder.conf \
    && a2enconf soeder \
    && a2enmod cgid

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
