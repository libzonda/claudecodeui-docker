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
- `INSTALL_CLAUDE=true` — install Claude Code CLI at container startup
- `INSTALL_CODEX=true` — install OpenAI Codex CLI at container startup
- `INSTALL_CURSOR=true` — install Cursor CLI at container startup
- `INSTALL_GEMINI=true` — install Gemini CLI at container startup
- `AUTO_UPDATE_CLI=true` — force reinstall/update enabled CLIs on every startup

## Volume mounts

Important persistent paths:

- `/root/.cloudcli` — stores `auth.db`
- `/root/.claude` — Claude Code sessions, settings, credentials, MCP config
- `/root/.codex` — Codex auth and session data
- `/root/.gemini` — Gemini auth and config

Recommended mounts:

- `-v claudecodeui-cloudcli:/root/.cloudcli`
- `-v claudecodeui-claude:/root/.claude`
- `-v claudecodeui-codex:/root/.codex`
- `-v claudecodeui-gemini:/root/.gemini`
- `-v /path/to/your/project:/workspace/project`

## Docker CLI

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -e HOST=0.0.0.0 \
  -e SERVER_PORT=3001 \
  -e DATABASE_PATH=/root/.cloudcli/auth.db \
  -e INSTALL_CLAUDE=true \
  -e INSTALL_CODEX=true \
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v claudecodeui-codex:/root/.codex \
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
      INSTALL_CLAUDE: "true"
      INSTALL_CODEX: "true"
      AUTO_UPDATE_CLI: "false"
    volumes:
      - claudecodeui-cloudcli:/root/.cloudcli
      - claudecodeui-claude:/root/.claude
      - claudecodeui-codex:/root/.codex
      - claudecodeui-gemini:/root/.gemini
      - /path/to/your/project:/workspace/project
    restart: unless-stopped

volumes:
  claudecodeui-cloudcli:
  claudecodeui-claude:
  claudecodeui-codex:
  claudecodeui-gemini:
```

Start with:

```bash
docker compose up -d
```
