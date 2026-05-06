# syntax=docker/dockerfile:1.7

FROM node:24-bookworm AS terminal-plugin-build
WORKDIR /tmp/web-terminal

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.npm \
    git clone --depth 1 https://github.com/cloudcli-ai/cloudcli-plugin-terminal.git /tmp/web-terminal \
    && npm install --include=dev \
    && npm run build \
    && npm prune --omit=dev

FROM node:24-bookworm-slim AS runtime
WORKDIR /app

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    SERVER_PORT=3001 \
    AUTO_UPDATE_CLOUDCLI=false \
    AUTO_UPDATE_CLI=false \
    npm_config_update_notifier=false \
    npm_config_fund=false \
    npm_config_audit=false

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git openssh-client bash \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @cloudcli-ai/cloudcli \
    && npm install -g task-master-ai

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @openai/codex \
    && npm install -g @google/gemini-cli

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN curl -fsSL https://cursor.com/install | bash \
    && if command -v agent >/dev/null 2>&1 && ! command -v cursor-agent >/dev/null 2>&1; then ln -sf "$(command -v agent)" /usr/local/bin/cursor-agent; fi

RUN mkdir -p /root/.claude-code-ui/plugins/web-terminal

COPY --from=terminal-plugin-build /tmp/web-terminal/manifest.json /root/.claude-code-ui/plugins/web-terminal/
COPY --from=terminal-plugin-build /tmp/web-terminal/icon.svg /root/.claude-code-ui/plugins/web-terminal/
COPY --from=terminal-plugin-build /tmp/web-terminal/dist /root/.claude-code-ui/plugins/web-terminal/dist
COPY --from=terminal-plugin-build /tmp/web-terminal/node_modules /root/.claude-code-ui/plugins/web-terminal/node_modules

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cloudcli", "start"]
