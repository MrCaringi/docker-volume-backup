#!/bin/bash
set -e

if [ -z "$CRON_SCHEDULE" ]; then
    echo "ERROR: CRON_SCHEDULE is required (e.g. '0 2 * * *')"
    exit 1
fi

if [ ! -f /config/config.json ]; then
    echo "ERROR: /config/config.json not found — mount it at /config/config.json"
    exit 1
fi

echo "docker-volume-backup v${APP_VERSION} starting"
echo "Schedule: ${CRON_SCHEDULE}"
echo ""

echo "${CRON_SCHEDULE} /bin/bash /usr/local/bin/container-backups.sh /config/config.json" > /etc/crontab

exec supercronic /etc/crontab