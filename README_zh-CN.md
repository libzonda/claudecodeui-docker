# claudecodeui-docker

[English](README.md) | 简体中文

这是一个为 [`siteboon/claudecodeui`](https://github.com/siteboon/claudecodeui) 构建 Docker 镜像的包装仓库。

它会基于上游最新 release 的源码包构建镜像，执行一次 smoke test，然后发布带版本号和 `latest` 的镜像。

## 镜像地址

当前会同时发布到两个仓库：

- `ghcr.io/libzonda/claudecodeui-docker:latest`
- `ghcr.io/libzonda/claudecodeui-docker:<上游-release-tag>`
- `docker.io/libzonda/claudecodeui-docker:latest`
- `docker.io/libzonda/claudecodeui-docker:<上游-release-tag>`

对大多数用户来说，直接使用 Docker Hub 更方便：

- `docker.io/libzonda/claudecodeui-docker:latest`

## 环境变量

运行时重点变量：

- `SERVER_PORT`：Web UI / 后端端口，默认 `3001`
- `HOST`：监听地址，默认 `0.0.0.0`
- `DATABASE_PATH`：容器内认证数据库路径，默认 `/root/.cloudcli/auth.db`

可选的 provider CLI 自举变量：

- `INSTALL_CLAUDE=true`：容器启动时安装 Claude Code CLI
- `INSTALL_CODEX=true`：容器启动时安装 OpenAI Codex CLI
- `INSTALL_CURSOR=true`：容器启动时使用官方安装方式安装 Cursor CLI
- `INSTALL_GEMINI=true`：容器启动时安装 Gemini CLI
- `AUTO_UPDATE_CLI=true`：每次启动都强制更新已启用的 CLI
- `CLAUDE_VERSION`：Claude 版本或 channel，默认 `latest`
- `CODEX_VERSION`：Codex npm 版本，默认 `latest`
- `CURSOR_VERSION`：为 Cursor 预留，当前仍安装最新版本
- `GEMINI_VERSION`：Gemini npm 版本，默认 `latest`
- `BOOTSTRAP_STATE_DIR`：安装状态目录，默认 `/var/lib/claudecodeui-bootstrap`

## 目录挂载

建议重点持久化这些目录：

- `/root/.cloudcli`：保存 `auth.db`
- `/root/.claude`：保存 Claude Code 的会话、配置、凭据、MCP 配置
- `/root/.codex`：保存 Codex 认证与会话数据
- `/root/.gemini`：保存 Gemini 认证与配置

推荐挂载：

- `-v claudecodeui-cloudcli:/root/.cloudcli`
- `-v claudecodeui-claude:/root/.claude`
- `-v claudecodeui-codex:/root/.codex`
- `-v claudecodeui-gemini:/root/.gemini`

如果希望在 UI 中访问你的项目目录，也建议挂载工作区：

- `-v /path/to/your/project:/workspace/project`

## Docker 命令行方式

使用 Docker Hub：

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

使用 GHCR：

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

启动后访问：`http://localhost:3001`

## Docker Compose 方式

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

启动命令：

```bash
docker compose up -d
```

## GitHub Actions 行为

当前 workflow 会：

- 每 2 小时检查一次上游最新 release
- 使用上游 release 的源码包构建镜像
- 只有当同版本标签已经同时存在于 GHCR 和 Docker Hub 时，才跳过构建
- 当发现新 release 时，同时向 GHCR 和 Docker Hub 发布 `<release-tag>` 与 `latest`
- 将仓库根目录下的 `README.md` 同步到 Docker Hub 说明页

## 仓库 Secrets

如需推送 Docker Hub 并同步 Docker Hub README，需要配置：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

`DOCKERHUB_TOKEN` 建议使用 Docker Hub Access Token，不要直接使用账号密码。
