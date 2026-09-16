# Changelog

## [1.0.0] - 2026-09-16

### Added
- First public version

## [0.2.2] - 2026-09-16

### Added
- `TZ` environment variable support for log timestamps and backup filenames (requires tzdata — now included in the image)
- Version displayed in container logs on startup (`docker-volume-backup vX.Y.Z starting`)

### Changed
- Replaced supercronic with Alpine's built-in busybox crond — removes external binary dependency and fixes ARM64 compatibility issue
- Cron job output now routed to container stdout (visible via `docker logs`)

### Fixed
- Container failing to start on ARM64 (Raspberry Pi, Oracle Ampere) due to supercronic fork/exec error

---

## [0.1.1] - 2026-09-16

### Added
- Initial Docker containerization of container-backups.sh
- Multi-arch image: linux/amd64 and linux/arm64
- Internal cron scheduling via CRON_SCHEDULE environment variable
- tar `-p` flag to preserve file ownership and permissions in archives