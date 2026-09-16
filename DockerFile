FROM docker:cli

ARG VERSION=dev
ARG REPO_URL=https://github.com/MrCaringi/docker-volume-backup

ENV SUPERCRONIC_VERSION=0.2.33

RUN apk add --no-cache bash jq curl && \
    case "$(uname -m)" in \
      x86_64)  arch=amd64 ;; \
      aarch64) arch=arm64 ;; \
      *) echo "Unsupported: $(uname -m)" && exit 1 ;; \
    esac && \
    curl -fsSL \
      "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${arch}" \
      -o /usr/local/bin/supercronic && \
    chmod +x /usr/local/bin/supercronic

COPY container-backups.sh /usr/local/bin/container-backups.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/container-backups.sh /entrypoint.sh

ENV CRON_SCHEDULE="0 2 * * *"

LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.source="${REPO_URL}"

ENTRYPOINT ["/entrypoint.sh"]