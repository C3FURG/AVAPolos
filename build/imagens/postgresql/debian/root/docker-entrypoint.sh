#!/usr/bin/env bash
set -e

source /etc/environment

bash mod_ids.sh

if [ "$1" = 'postgres' ]; then
	chown -R postgres "$PGDATA"

	chmod g+s /run/postgresql
	chown -R postgres:postgres /run/postgresql

	if [ -z "$(ls -A "$PGDATA")" ]; then
		initdb

		sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

		# check password first so we can ouptut the warning before postgres
		# messes it up
		if [ "$POSTGRES_PASSWORD" ]; then
			pass="PASSWORD '$POSTGRES_PASSWORD'"
			authMethod=md5
		else
			# The - option suppresses leading tabs but *not* spaces. :)
			cat >&2 <<-'EOWARN'
				****************************************************
				WARNING: No password has been set for the database.
				         This will allow anyone with access to the
				         Postgres port to access your database. In
				         Docker's default configuration, this is
				         effectively any other container on the same
				         system.
				         Use "-e POSTGRES_PASSWORD=password" to set
				         it in "docker run".
				****************************************************
			EOWARN

			pass=
			authMethod=trust
		fi

		: ${POSTGRES_USER:=postgres}
		: ${POSTGRES_DB:=$POSTGRES_USER}

		if [ "$POSTGRES_DB" != 'postgres' ]; then
			psql -U postgres -c "CREATE DATABASE $POSTGRES_DB;"
		fi

		if [ "$POSTGRES_USER" = 'postgres' ]; then
			op='ALTER'
		else
			op='CREATE'
		fi

		psql -U postgres -c "$op USER $POSTGRES_USER WITH SUPERUSER $pass;"

		{ echo;
      echo "host all all 0.0.0.0/0 $authMethod";
      echo "host replication all 0.0.0.0/0 trust";
    } >> "$PGDATA"/pg_hba.conf

		{ echo;
      echo "shared_preload_libraries = 'bdr'";
      echo "client_encoding = utf8";
      echo "wal_level = 'logical'";
      echo "track_commit_timestamp = on";
      echo "max_wal_senders = 10";
      echo "max_replication_slots = 10";
      echo "max_worker_processes = 10";
      echo "port = $POSTGRES_PORT";
    } >> "$PGDATA"/postgresql.conf

		if [ -d /docker-entrypoint-initdb.d ]; then
			for f in /docker-entrypoint-initdb.d/*.sh; do
				[ -f "$f" ] && . "$f"
			done
		fi
	fi

	exec "$@"
fi

exec "$@"
