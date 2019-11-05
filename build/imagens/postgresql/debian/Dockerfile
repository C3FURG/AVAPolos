FROM debian:stretch

RUN mkdir /docker-entrypoint-initdb.d

ENV PG_MAJOR=9.4 \
    PG_VERSION=9.4.22 \
		PGDATA=/var/lib/postgresql/data \
		POSTGRES_USER=postgres \
		POSTGRES_PASSWORD=password \
		POSTGRES_DB=postgres \
		POSTGRES_PORT=5432 \
		LANG='en_US.UTF-8' \
		LANGUAGE='en_US.UTF-8' \
		DEBIAN_FRONTEND=noninteractive

RUN apt-get update

#Generate the locale.
RUN apt-get install -y --no-install-recommends locales \
	&& locale-gen en_US.UTF-8

#Install utilities and dependencies.
RUN apt-get install -y --no-install-recommends gnupg apt-transport-https ca-certificates curl lsb-release apt-utils

#Install BDR.
RUN sh -c 'echo "deb https://apt.2ndquadrant.com/ $(lsb_release -cs)-2ndquadrant main" > /etc/apt/sources.list.d/2ndquadrant.list' \
	&& curl https://apt.2ndquadrant.com/site/keys/9904CD4BD6BAF0C3.asc | apt-key add - \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends postgresql-bdr-9.4-bdr-plugin

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME /var/lib/postgresql/data

COPY root /

RUN chmod u+x docker-entrypoint.sh mod_ids.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN echo "/usr/lib/postgresql/9.4/bin/:$PATH" >> /etc/environment

EXPOSE 5432
CMD ["postgres"]
