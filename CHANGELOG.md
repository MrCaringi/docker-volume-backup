# Changelog

## [0.1.0] - 2026-09-16

### Added
- Initial Docker containerization of container-backups.sh
- Multi-arch image: linux/amd64 and linux/arm64
- Internal cron scheduling via supercronic + CRON_SCHEDULE env var
- tar -p flag to preserve file ownership in archives