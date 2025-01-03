FROM postgres:15 AS pg_bigm

RUN apt update
RUN apt install -y curl alien

RUN curl https://github.com/pgbigm/pg_bigm/releases/download/v1.2-20240606/pg_bigm-1.2.20240606-1.pg15.el9.x86_64.rpm -L -o pg_bigm-1.2.20240606-1.pg15.el9.x86_64.rpm
RUN alien -i pg_bigm-1.2.20240606-1.pg15.el9.x86_64.rpm


FROM postgres:15

COPY --from=pg_bigm /usr/pgsql-15/share/extension/* /usr/share/postgresql/15/extension/
COPY --from=pg_bigm /usr/pgsql-15/lib/* /usr/lib/postgresql/15/lib

RUN echo shared_preload_libraries='pg_bigm' >> /var/lib/postgresql/data/postgresql.conf
