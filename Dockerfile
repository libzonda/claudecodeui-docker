# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=22
ARG CLAUDECODEUI_SOURCE_URL=https://github.com/siteboon/claudecodeui/archive/refs/heads/main.tar.gz

FROM node:${NODE_VERSION}-bookworm AS build
ARG CLAUDECODEUI_SOURCE_URL
WORKDIR /app
ENV HUSKY=0
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates python3 make g++ pkg-config tar \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL "$CLAUDECODEUI_SOURCE_URL" | tar -xz --strip-components=1 -C /app
RUN npm install
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
