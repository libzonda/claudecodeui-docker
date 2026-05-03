# claudecodeui-docker

English | [简体中文](README_zh-CN.md)

Docker image packaging for [`siteboon/claudecodeui`](https://github.com/siteboon/claudecodeui).

This repository builds from the latest upstream release source tarball, runs a smoke test, then publishes versioned tags plus `latest`.

## Published images

Two registries are published:

- `ghcr.io/libzonda/claudecodeui-docker:latest`
- `ghcr.io/libzonda/claudecodeui-docker:<upstream-release-tag>`
- `docker.io/libzonda/claudecodeui-docker:latest`
- `docker.io/libzonda/claudecodeui-docker:<upstream-release-tag>`

For most users, Docker Hub is the simplest pull target:

- `docker.io/libzonda/claudecodeui-docker:latest`

## Environment variables

Important runtime variables:

- `SERVER_PORT` — backend/UI port, default `3001`
- `HOST` — bind address, default `0.0.0.0`
- `DATABASE_PATH` — auth database path inside container, default `/root/.cloudcli/auth.db`

Optional provider CLI bootstrap variables:

- `INSTALL_CLAUDE=true` — install Claude Code CLI at container startup
- `INSTALL_CODEX=true` — install OpenAI Codex CLI at container startup
- `INSTALL_CURSOR=true` — install Cursor CLI at container startup using the official installer
- `INSTALL_GEMINI=true` — install Gemini CLI at container startup
- `AUTO_UPDATE_CLI=true` — force reinstall/update enabled CLIs on every startup
- `CLAUDE_VERSION` — Claude version/channel, default `latest`
- `CODEX_VERSION` — Codex npm version, default `latest`
- `CURSOR_VERSION` — reserved for Cursor; currently installs latest
- `GEMINI_VERSION` — Gemini npm version, default `latest`
- `BOOTSTRAP_STATE_DIR` — install state directory, default `/var/lib/claudecodeui-bootstrap`

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

If you want to access project files from the UI, mount your workspace too:

- `-v /path/to/your/project:/workspace/project`

## Docker CLI

Using Docker Hub:

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

Using GHCR:

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -e HOST=0.0.0.0 \
  -e SERVER_PORT=3001 \
  -e DATABASE_PATH=/root/.cloudcli/auth.db \
  -e INSTALL_CLAUDE=true \
  -e INSTALL_GEMINI=true \
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v claudecodeui-gemini:/root/.gemini \
  -v /path/to/your/project:/workspace/project \
  ghcr.io/libzonda/claudecodeui-docker:latest
```

Then open `http://localhost:3001`.

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
      INSTALL_GEMINI: "false"
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

Start it with:

```bash
docker compose up -d
```

## GitHub Actions behavior

The workflow:

- checks upstream latest release every 2 hours
- builds from the upstream release source tarball
- skips the image build only if the release tag already exists in both GHCR and Docker Hub
- publishes both `<release-tag>` and `latest` to GHCR and Docker Hub when a new release appears
- syncs this repository `README.md` to Docker Hub

## Required repository secrets

To publish to Docker Hub and update the Docker Hub description, configure:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

`DOCKERHUB_TOKEN` should be a Docker Hub access token, not your account password.
