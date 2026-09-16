# docker-volume-backup

<p align="center">
  <img src="https://raw.githubusercontent.com/MrCaringi/docker-volume-backup/main/assets/logo.png" width="350" alt="docker-volume-backup logo">
</p>

Backs up Docker volumes and `docker-compose.yml` files as `.tar.gz` archives, organized by stack. Runs as a Docker container with a configurable cron schedule — no host dependencies, no sudo required.

![Docker Pulls](https://img.shields.io/docker/pulls/mrcaringi/docker-volume-backup)
![Docker Image Size](https://img.shields.io/docker/image-size/mrcaringi/docker-volume-backup/latest)

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Volumes](#volumes)
  - [config.json](#configjson)
- [How it Works](#how-it-works)
- [Usage](#usage)
  - [Viewing Logs](#viewing-logs)
  - [Running a Backup Manually](#running-a-backup-manually)
  - [Backup Folder Structure](#backup-folder-structure)
  - [Telegram Notifications](#telegram-notifications)
- [Recovery](#recovery)
- [Changelog](#changelog)

---

## Features

- Backs up Docker volumes **by stack** (not by individual container)
- **Stops the entire stack** with `docker compose down` before backup, restarts with `docker compose up -d` after
- Compresses backups as `.tar.gz` archives **preserving file ownership** (UIDs/GIDs)
- Rotates old backups per volume, configurable with `maxBackups`
- Backs up the **entire folder containing the compose file**, not just the file itself
- Supports per-volume delay before backup (`preBackupSleep`) — useful for database flushes
- Logs backup size per volume and total per stack
- Sends Telegram notifications (messages + log file), with optional thread support
- Multi-arch image: `linux/amd64` and `linux/arm64` (Raspberry Pi, Oracle Ampere, x86)

---

## Quick Start

```yaml
# docker-compose.yml
services:
  container-backups:
    image: mrcaringi/docker-volume-backup:latest
    container_name: container-backups
    hostname: myserver          # shown in Telegram notifications
    restart: always
    environment:
      CRON_SCHEDULE: "0 2 * * *"
      TZ: "Europe/Madrid"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./config.json:/config/config.json:ro
      - /path/to/backups:/backup
      # Mount stack directories at the same path used in config.json
      - /home/user/docker/stacks:/home/user/docker/stacks:ro
```

```bash
docker compose up -d
docker compose logs -f
```

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `CRON_SCHEDULE` | Yes | `0 2 * * *` | Cron expression for backup schedule |
| `TZ` | No | `UTC` | Timezone for log timestamps and backup filenames (e.g. `America/Monterrey`, `Europe/Madrid`) |

> Verify your cron expression at [crontab.guru](https://crontab.guru/)

### Volumes

| Container path | Description | Required |
|---|---|---|
| `/var/run/docker.sock` | Docker socket — needed to stop/start stacks | Yes |
| `/config/config.json` | Your configuration file | Yes |
| `/backup` | Backup destination directory | Yes |
| `<stack paths>` | Directories containing your stacks' compose files and volumes | Yes |

> **Path mapping:** `docker compose -f <path>` is resolved from inside the container, not from the Docker daemon. Paths in `config.json` must be accessible inside the container. Mount your stack directories at the same path as they appear in `config.json`.
>
> Example: if `config.json` references `/home/user/stacks/myapp/docker-compose.yml`, add this to your volumes:
> ```yaml
> - /home/user/stacks:/home/user/stacks:ro
> ```

### config.json

```json
{
    "config": {
        "BackupDestination": "/backup"
    },
    "telegram": {
        "ChatID": "your-chat-id",
        "APIkey": "your-telegram-bot-api-key",
        "MessageThreadID": "123"
    },
    "stacks": [
        {
            "name": "stack1",
            "composeFile": "/home/user/stacks/stack1/docker-compose.yml",
            "volumes": [
                {
                    "path": "/home/user/stacks/stack1/data",
                    "maxBackups": 5,
                    "preBackupSleep": 10
                },
                {
                    "path": "/home/user/stacks/stack1/config",
                    "maxBackups": 3
                }
            ]
        }
    ]
}
```

| Parameter | Type | Description |
|---|---|---|
| `config.BackupDestination` | path | Maps to `/backup` inside the container |
| `telegram.ChatID` | number | Telegram chat/group ID (use `@getmyid_bot`) |
| `telegram.APIkey` | string | Telegram bot API key |
| `telegram.MessageThreadID` | number | *(Optional)* Thread ID for group topics |
| `stacks[].name` | string | Stack name — used as subfolder in the backup destination |
| `stacks[].composeFile` | path | Path to the compose file *(as seen inside the container)* |
| `stacks[].volumes[].path` | path | Volume directory to back up *(as seen inside the container)* |
| `stacks[].volumes[].maxBackups` | number | How many backups to keep per volume |
| `stacks[].volumes[].preBackupSleep` | number (sec) | *(Optional)* Wait before backup — useful for DB flushes |

---

## How it Works

For each stack defined in `config.json`:

1. Stop the stack: `docker compose -f <composeFile> down`
2. For each volume (optionally waiting `preBackupSleep` seconds):
   - Compress the volume directory as `<volume-name>_<timestamp>.tar.gz`
3. Compress the folder containing the compose file as `compose_dir_<timestamp>.tar.gz`
4. Rotate old backups according to `maxBackups`
5. Log the backup size per volume and total for the stack
6. Start the stack: `docker compose -f <composeFile> up -d`
7. Send Telegram notification with result and log file

Errors are counted and reported in the final Telegram notification. If a stack fails to stop, it is skipped and the process continues with the next stack.

---

## Usage

### Viewing Logs

```bash
docker logs -f container-backups
```

![Docker Logs](https://raw.githubusercontent.com/MrCaringi/docker-volume-backup/main/assets/docker-logs.jpg)

### Running a Backup Manually


To trigger a backup immediately without waiting for the cron schedule:

```bash
docker exec container-backups /usr/local/bin/container-backups.sh /config/config.json
```

### Backup Folder Structure

![folder structure](https://github.com/MrCaringi/assets/blob/main/images/scripts/container-backups/terminal-folder-structure.jpg)

### Telegram Notifications

![telegram notification](https://github.com/MrCaringi/assets/blob/main/images/scripts/container-backups/telegram-messages.jpg)

---

## Recovery

### 1. Inspect the backup

```bash
tar -tvf stack1_volume1_250902-1900.tar.gz
```

### 2. Stop the stack

```bash
docker compose -f /path/to/compose.yml down
```

### 3. Extract the backup

Root is required to restore original file ownership:

```bash
sudo tar -xzpf /path/to/backup/stack1/volume1/volume1_250902-1900.tar.gz \
  --same-owner \
  -C /destination/path
```

### 4. Start the stack

```bash
docker compose -f /path/to/compose.yml up -d
```

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
