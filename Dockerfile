# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=22
ARG CLAUDECODEUI_REPO=https://github.com/siteboon/claudecodeui.git
ARG CLAUDECODEUI_REF=main

FROM node:${NODE_VERSION}-bookworm AS source
ARG CLAUDECODEUI_REPO
ARG CLAUDECODEUI_REF
WORKDIR /src
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "${CLAUDECODEUI_REF}" "${CLAUDECODEUI_REPO}" app

FROM node:${NODE_VERSION}-bookworm AS build
WORKDIR /app
ENV HUSKY=0
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY --from=source /src/app/package*.json ./
RUN npm ci
COPY --from=source /src/app/ ./
RUN npm run build && npm prune --omit=dev

FROM node:${NODE_VERSION}-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    SERVER_PORT=3001
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash git ca-certificates openssh-client \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/dist-server ./dist-server
COPY --from=build /app/public ./public
COPY --from=build /app/index.html ./index.html
EXPOSE 3001
CMD ["npm", "run", "server"]
