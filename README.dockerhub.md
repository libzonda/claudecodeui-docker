# claudecodeui-docker

Docker image packaging for [`siteboon/claudecodeui`](https://github.com/siteboon/claudecodeui).

This image is built from the latest upstream release source tarball, smoke-tested, and published with both a version tag and `latest`.

## Image

- `docker.io/libzonda/claudecodeui-docker:latest`
- `docker.io/libzonda/claudecodeui-docker:<upstream-release-tag>`

## Environment variables

Important runtime variables:

- `SERVER_PORT` — backend/UI port, default `3001`
- `HOST` — bind address, default `0.0.0.0`
- `DATABASE_PATH` — auth database path inside container, default `/root/.cloudcli/auth.db`

## Volume mounts

Important persistent paths:

- `/root/.cloudcli` — stores `auth.db`
- `/root/.claude` — Claude Code sessions, settings, credentials, MCP config

Recommended mounts:

- `-v claudecodeui-cloudcli:/root/.cloudcli`
- `-v claudecodeui-claude:/root/.claude`
- `-v /path/to/your/project:/workspace/project`

## Docker CLI

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -e HOST=0.0.0.0 \
  -e SERVER_PORT=3001 \
  -e DATABASE_PATH=/root/.cloudcli/auth.db \
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v /path/to/your/project:/workspace/project \
  docker.io/libzonda/claudecodeui-docker:latest
```

Open `http://localhost:3001` after startup.

## Docker Compose

```yaml
services:
  claudecodeui:
    image: docker.io/libzonda/claudecodeui-docker:latest
    container_name: claudecodeui
    ports:
      - "3001:3001"
    environment:
      HOST: 0.0.0.0
      SERVER_PORT: 3001
      DATABASE_PATH: /root/.cloudcli/auth.db
    volumes:
      - claudecodeui-cloudcli:/root/.cloudcli
      - claudecodeui-claude:/root/.claude
      - /path/to/your/project:/workspace/project
    restart: unless-stopped

volumes:
  claudecodeui-cloudcli:
  claudecodeui-claude:
```

Start with:

```bash
docker compose up -d
```
