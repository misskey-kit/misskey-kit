FROM public.ecr.aws/docker/library/docker:latest AS docker

FROM public.ecr.aws/ubuntu/ubuntu:latest

RUN apt update \
    && apt install -y busybox entr ca-certificates \
    && mkdir -p /var/spool/cron/crontabs

COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker /usr/local/bin/docker-compose /usr/local/bin/docker-compose
COPY --from=docker /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
