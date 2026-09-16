FROM docker:cli

ARG VERSION=dev
ENV APP_VERSION=${VERSION}
ARG REPO_URL=https://github.com/MrCaringi/docker-volume-backup

RUN apk add --no-cache bash jq curl

COPY container-backups.sh /usr/local/bin/container-backups.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/container-backups.sh /entrypoint.sh

ENV CRON_SCHEDULE="0 2 * * *"

LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.source="${REPO_URL}"

ENTRYPOINT ["/entrypoint.sh"]