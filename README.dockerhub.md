# claudecodeui-docker

Docker image packaging for [`siteboon/claudecodeui`](https://github.com/siteboon/claudecodeui).

This image installs `@cloudcli-ai/cloudcli` globally from npm and preinstalls all supported provider CLIs at build time. At runtime it can optionally update CloudCLI and provider CLIs, then launches CloudCLI through `docker-entrypoint.sh`. It is published with both a version tag and `latest`.

## Image

- `docker.io/libzonda/claudecodeui-docker:latest`
- `docker.io/libzonda/claudecodeui-docker:<upstream-release-tag>`

## Configuration

Important runtime variables:

- `SERVER_PORT` — backend/UI port, default `3001`
- `HOST` — bind address, default `0.0.0.0`
- `DATABASE_PATH` — auth database path inside container, default `/root/.cloudcli/auth.db`
- `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` — proxy settings passed through to provider CLIs at runtime

Runtime update variables:

- `AUTO_UPDATE_CLOUDCLI=true` — update `@cloudcli-ai/cloudcli` on container startup; default `false`
- `AUTO_UPDATE_CLI=true` — update provider CLIs on container startup; default `false`
- `NPM_REGISTRY` — npm mirror/registry URL used only during runtime updates for CloudCLI, Codex, and Gemini

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

## Build

```bash
docker build -t claudecodeui:latest .
```

## Docker CLI

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -e HOST=0.0.0.0 \
  -e SERVER_PORT=3001 \
  -e DATABASE_PATH=/root/.cloudcli/auth.db \
  -e AUTO_UPDATE_CLOUDCLI=false \
  -e AUTO_UPDATE_CLI=false \
  -e NPM_REGISTRY=https://registry.npmmirror.com \
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v claudecodeui-codex:/root/.codex \
  -v claudecodeui-gemini:/root/.gemini \
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
