# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=24
ARG CLAUDECODEUI_SOURCE_URL=https://github.com/siteboon/claudecodeui/archive/refs/heads/main.tar.gz

FROM node:${NODE_VERSION}-bookworm AS source
ARG CLAUDECODEUI_SOURCE_URL
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL "$CLAUDECODEUI_SOURCE_URL" | tar -xz --strip-components=1 -C /app

FROM node:${NODE_VERSION}-bookworm AS build
WORKDIR /app
ENV HUSKY=0
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY --from=source /app/ ./
RUN npm ci
RUN npm run build

FROM node:${NODE_VERSION}-bookworm AS prod-deps
WORKDIR /app
ENV HUSKY=0
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY --from=source /app/ ./
RUN npm ci --omit=dev --ignore-scripts
RUN npm rebuild bcrypt better-sqlite3 node-pty

FROM node:${NODE_VERSION}-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    SERVER_PORT=3001 \
    npm_config_update_notifier=false \
    npm_config_fund=false \
    npm_config_audit=false
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git openssh-client bash \
    && rm -rf /var/lib/apt/lists/*
COPY --from=prod-deps /app/package*.json ./
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/dist-server ./dist-server
COPY --from=build /app/public ./public
COPY --from=build /app/index.html ./index.html
COPY scripts/bootstrap-clis.sh /usr/local/bin/bootstrap-clis.sh
RUN chmod +x /usr/local/bin/bootstrap-clis.sh
EXPOSE 3001
ENTRYPOINT ["/usr/local/bin/bootstrap-clis.sh"]
CMD ["npm", "run", "server"]
