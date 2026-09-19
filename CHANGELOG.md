# Changelog

## [1.2.0] - 2026-09-19

### Added
- Startup log now displays the container hostname (`Host: <hostname>`) — set via `hostname:` in `docker-compose.yml` to identify which server the backup is running on.


## [1.1.0] - 2026-09-16

### Added
- Startup log now shows the number of stacks defined in `config.json`
  (`Stacks: N`) so you can confirm the correct config is mounted at a
  glance, without opening the file.

## [1.0.1] - 2026-09-16

### Added
- ASCII art banner displayed on container startup
- Timezone name (`$TZ`) and local container time shown in startup log — makes it easy to verify timezone configuration
- Logo (`assets/logo.png`) for Docker Hub and GitHub
- GitHub issue templates: Bug Report and Feature Request

### Changed
- README reorganized with Table of Contents and improved structure

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