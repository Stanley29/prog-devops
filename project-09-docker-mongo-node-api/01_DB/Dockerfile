FROM mongo:7

COPY setup-db.sh /docker-entrypoint-initdb.d/
COPY seed-data.js /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/setup-db.sh

EXPOSE 27017
