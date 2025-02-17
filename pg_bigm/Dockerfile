FROM postgres:15 AS pg_bigm

RUN apt update
RUN apt install -y git make gcc postgresql-server-dev-15

RUN git clone -b REL1_2_STABLE --depth 1 https://github.com/pgbigm/pg_bigm.git
RUN cd pg_bigm && make USE_PGXS=1 && make USE_PGXS=1 install


FROM postgres:15

COPY --from=pg_bigm /usr/share/postgresql/15/extension/* /usr/share/postgresql/15/extension/
COPY --from=pg_bigm /usr/lib/postgresql/15/lib/* /usr/lib/postgresql/15/lib

RUN echo shared_preload_libraries='pg_bigm' >> /etc/postgresql/postgresql.conf
