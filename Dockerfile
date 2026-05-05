# syntax=docker/dockerfile:1.7

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

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git openssh-client bash \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @cloudcli-ai/cloudcli \
    && npm install -g task-master-ai \
    && npm install -g @openai/codex \
    && npm install -g @google/gemini-cli \
    && curl -fsSL https://claude.ai/install.sh | bash \
    && curl -fsSL https://cursor.com/install | bash \
    && if command -v agent >/dev/null 2>&1 && ! command -v cursor-agent >/dev/null 2>&1; then ln -sf "$(command -v agent)" /usr/local/bin/cursor-agent; fi

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cloudcli", "start"]
