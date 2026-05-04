# claudecodeui-docker

English | [简体中文](README_zh-CN.md)

Docker image packaging for [`siteboon/claudecodeui`](https://github.com/siteboon/claudecodeui).

This repository installs `@cloudcli-ai/cloudcli` globally from npm and preinstalls all supported provider CLIs into the image at build time. At runtime it can optionally update CloudCLI and the provider CLIs, then starts CloudCLI through `docker-entrypoint.sh`. It publishes versioned tags plus `latest`.

## Published images

Two registries are published:

- `ghcr.io/libzonda/claudecodeui-docker:latest`
- `ghcr.io/libzonda/claudecodeui-docker:<upstream-release-tag>`
- `docker.io/libzonda/claudecodeui-docker:latest`
- `docker.io/libzonda/claudecodeui-docker:<upstream-release-tag>`

For most users, Docker Hub is the simplest pull target:

- `docker.io/libzonda/claudecodeui-docker:latest`

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

If you want to access project files from the UI, mount your workspace too:

- `-v /path/to/your/project:/workspace/project`

## Build

```bash
docker build -t claudecodeui:latest .
```

## Docker CLI

Using Docker Hub:

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -e HOST=0.0.0.0 \
  -e SERVER_PORT=3001 \
  -e DATABASE_PATH=/root/.cloudcli/auth.db \
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v claudecodeui-codex:/root/.codex \
  -v claudecodeui-gemini:/root/.gemini \
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
  -v claudecodeui-cloudcli:/root/.cloudcli \
  -v claudecodeui-claude:/root/.claude \
  -v claudecodeui-codex:/root/.codex \
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
