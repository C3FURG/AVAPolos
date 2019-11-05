FROM ubuntu:latest

COPY scripts/backup.sh /opt/
COPY scripts/main.sh /opt/

RUN chmod u+x /opt/main.sh
RUN chmod u+x /opt/backup.sh

CMD ["/bin/bash", "/opt/main.sh"]
