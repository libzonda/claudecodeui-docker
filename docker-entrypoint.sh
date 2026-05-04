#!/bin/sh
set -eu

AUTO_UPDATE_CLOUDCLI="${AUTO_UPDATE_CLOUDCLI:-false}"
AUTO_UPDATE_CLI="${AUTO_UPDATE_CLI:-false}"
NPM_REGISTRY="${NPM_REGISTRY:-}"

export PATH="/root/.local/bin:/root/bin:$PATH"
export HTTP_PROXY="${HTTP_PROXY:-}"
export HTTPS_PROXY="${HTTPS_PROXY:-}"
export NO_PROXY="${NO_PROXY:-}"
export http_proxy="${http_proxy:-}"
export https_proxy="${https_proxy:-}"
export no_proxy="${no_proxy:-}"

if [ -n "$NPM_REGISTRY" ]; then
  export NPM_CONFIG_REGISTRY="$NPM_REGISTRY"
  export npm_config_registry="$NPM_REGISTRY"
fi

log() {
  printf '%s\n' "[docker-entrypoint] $*"
}

is_true() {
  case "$1" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

if is_true "$AUTO_UPDATE_CLOUDCLI"; then
  log "updating cloudcli via npm"
  npm update -g @cloudcli-ai/cloudcli || npm install -g @cloudcli-ai/cloudcli
fi

if is_true "$AUTO_UPDATE_CLI"; then
  log "updating codex via npm"
  npm update -g @openai/codex || npm install -g @openai/codex

  log "updating gemini via npm"
  npm update -g @google/gemini-cli || npm install -g @google/gemini-cli

  log "updating claude via official native installer"
  curl -fsSL https://claude.ai/install.sh | bash

  log "updating cursor via official installer"
  curl -fsSL https://cursor.com/install | bash
  if command -v agent >/dev/null 2>&1 && ! command -v cursor-agent >/dev/null 2>&1; then
    ln -sf "$(command -v agent)" /usr/local/bin/cursor-agent
  fi
fi

exec "$@"
