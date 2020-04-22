#!/usr/bin/env bash

docker-compose up -d db_wiki
waitForHealthy db_wiki

execSQL db_wiki postgres postgres "
  CREATE DATABASE wiki;
";

execSQL db_wiki postgres postgres "
  CREATE ROLE wiki;
  ALTER USER wiki WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  ALTER DATABASE wiki OWNER TO wiki;
  GRANT ALL PRIVILEGES ON DATABASE wiki TO wiki;
";
