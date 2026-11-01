# Changelog

## [2.0.0] - 2026-11-01

### BREAKING CHANGES
- The `telegram` block in `config.json` was restructured: `telegram.ChatID` and `telegram.MessageThreadID` are replaced by `telegram.SuccessNotification.{enabled,ChatID,MessageThreadID}` and `telegram.ErrorNotification.{ChatID,MessageThreadID}`. `telegram.APIkey` stays at the top level. Configs written for v1.x will not work — see the README's "Migrating from v1.x to v2.0.0" section. The script detects the old/incomplete schema on every run and aborts without touching any stack (logged only, no Telegram alert, since the broken telegram config is what failed to validate).

### Added
- Success and error backup notifications can now be routed to different Telegram chats/threads.
- `telegram.SuccessNotification.enabled` suppresses the "all OK" message and its attached log file entirely, so Telegram only gets noisy when something actually needs attention. Error notifications are always sent regardless of this setting, by design.

### Fixed
- Per-stack stop/start failure messages during a run now actually include the failure detail in the Telegram message body (previously `send_telegram_message` was called with only one argument, so the detail text was silently dropped).


## [1.3.0] - 2026-11-01

### Fixed
- Config reload: documented volume mount changed from a single-file bind mount (`config.json:/config/config.json`) to a directory bind mount (`./config:/config`). Docker's single-file bind mounts track the original inode; if the host-side `config.json` was replaced via rename (editors doing atomic saves, `mv`, `scp`, sync tools), the container kept serving the old, deleted inode's content until restarted — even though `container-backups.sh` already re-read the file on every cron run. Mounting the directory removes this class of bug entirely. Existing deployments must move their `config.json` into a `config/` folder and update their `docker-compose.yml` accordingly.

### Added
- `container-backups.sh` now validates `config.json` at the start of every run; if it's missing or not valid JSON, it logs the error (visible via `docker logs`) and exits without stopping any stack. Note: a Telegram alert can't be sent in this specific case, since the bot credentials are also read from the same `config.json` that failed to parse.
- `container-backups.sh` now logs the detected stack count and names at the start of every run (previously this was only logged once, at container startup, by `entrypoint.sh`), confirming which config was actually used for that run.


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