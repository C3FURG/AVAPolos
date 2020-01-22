FROM alpine:3.8

MAINTAINER Rafael Souza <rsouza19796@gmail.com>

RUN apk add python3 bash dcron curl wget rsync ca-certificates && rm -rf /var/cache/apk/*

RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d

RUN pip3 install noipy

COPY root /
RUN chmod +x /start.sh
RUN chmod +x /cmd.sh

ENTRYPOINT ["/start.sh"]
CMD ["/cmd.sh"]
