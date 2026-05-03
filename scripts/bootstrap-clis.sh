#!/bin/sh
set -eu

INSTALL_CLAUDE="${INSTALL_CLAUDE:-false}"
INSTALL_CODEX="${INSTALL_CODEX:-false}"
INSTALL_CURSOR="${INSTALL_CURSOR:-false}"
INSTALL_GEMINI="${INSTALL_GEMINI:-false}"
AUTO_UPDATE_CLI="${AUTO_UPDATE_CLI:-false}"

CLAUDE_VERSION="${CLAUDE_VERSION:-latest}"
CODEX_VERSION="${CODEX_VERSION:-latest}"
CURSOR_VERSION="${CURSOR_VERSION:-latest}"
GEMINI_VERSION="${GEMINI_VERSION:-latest}"

export PATH="/root/.local/bin:/root/bin:$PATH"
export HTTP_PROXY="${HTTP_PROXY:-}"
export HTTPS_PROXY="${HTTPS_PROXY:-}"
export NO_PROXY="${NO_PROXY:-}"
export http_proxy="${http_proxy:-}"
export https_proxy="${https_proxy:-}"
export no_proxy="${no_proxy:-}"

log() {
  printf '%s\n' "[bootstrap-clis] $*"
}

is_true() {
  case "$1" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

version_suffix() {
  version="$1"
  package_name="$2"
  if [ -z "$version" ] || [ "$version" = "latest" ]; then
    printf '%s' "$package_name"
  else
    printf '%s@%s' "$package_name" "$version"
  fi
}

should_run() {
  if is_true "$AUTO_UPDATE_CLI"; then
    return 0
  fi

  return 1
}

install_codex() {
  package_spec=$(version_suffix "$CODEX_VERSION" "@openai/codex")
  if command -v codex >/dev/null 2>&1 && ! should_run codex "$CODEX_VERSION"; then
    log "codex already installed, skipping"
    return
  fi
  log "installing codex via npm: $package_spec"
  npm install -g "$package_spec"
}

install_gemini() {
  package_spec=$(version_suffix "$GEMINI_VERSION" "@google/gemini-cli")
  if command -v gemini >/dev/null 2>&1 && ! should_run gemini "$GEMINI_VERSION"; then
    log "gemini already installed, skipping"
    return
  fi
  log "installing gemini via npm: $package_spec"
  npm install -g "$package_spec"
}

install_claude() {
  if command -v claude >/dev/null 2>&1 && ! should_run claude "$CLAUDE_VERSION"; then
    log "claude already installed, skipping"
    return
  fi

  if ! command -v bash >/dev/null 2>&1; then
    log "bash is required to install claude"
    exit 1
  fi

  log "installing claude via official native installer"
  if [ "$CLAUDE_VERSION" = "latest" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
  else
    curl -fsSL https://claude.ai/install.sh | bash -s "$CLAUDE_VERSION"
  fi
}

install_cursor() {
  if command -v cursor-agent >/dev/null 2>&1 && ! should_run cursor "$CURSOR_VERSION"; then
    log "cursor-agent already installed, skipping"
    return
  fi

  if [ "$CURSOR_VERSION" != "latest" ]; then
    log "warning: Cursor version pinning is not implemented; installing latest"
  fi

  log "installing Cursor via official installer"
  curl -fsSL https://cursor.com/install | bash

  if command -v agent >/dev/null 2>&1 && ! command -v cursor-agent >/dev/null 2>&1; then
    ln -sf "$(command -v agent)" /usr/local/bin/cursor-agent
  fi
}

if is_true "$INSTALL_CLAUDE"; then
  install_claude
fi

if is_true "$INSTALL_CODEX"; then
  install_codex
fi

if is_true "$INSTALL_CURSOR"; then
  install_cursor
fi

if is_true "$INSTALL_GEMINI"; then
  install_gemini
fi

exec "$@"
