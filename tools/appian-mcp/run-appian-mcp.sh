#!/usr/bin/env bash
# Launcher for the Appian Dev MCP server (STDIO transport).
#
# Downloads the server bundle from the Appian site on first run, installs its
# dependencies with uv and then execs the MCP server. All diagnostics go to
# stderr so stdout stays reserved for the MCP JSON-RPC stream.
#
# Required environment:
#   LCP_URL            Appian site, e.g. https://mapfrespain-test.appiancloud.com
#   USERNAME/PASSWORD  Appian credentials (basic auth). Fall back to
#                      APPIAN_USERNAME / APPIAN_PASSWORD if unset.
# Optional:
#   APPIAN_MCP_HOME    Install dir (default: ~/appian-dev-mcp-server)
#   LCP_TOOL_MODE      full (default) | readonly
set -euo pipefail

log() { echo "[appian-mcp] $*" >&2; }

export LCP_URL="${LCP_URL:-https://mapfrespain-test.appiancloud.com}"
export USERNAME="${USERNAME:-${APPIAN_USERNAME:-}}"
export PASSWORD="${PASSWORD:-${APPIAN_PASSWORD:-}}"
export LCP_AUTH_METHOD="${LCP_AUTH_METHOD:-basic}"
export LCP_TOOL_MODE="${LCP_TOOL_MODE:-full}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
HOME_DIR="${APPIAN_MCP_HOME:-$HOME/appian-dev-mcp-server}"

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
  log "ERROR: USERNAME/PASSWORD (or APPIAN_USERNAME/APPIAN_PASSWORD) must be set"
  exit 1
fi

export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  log "installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh >&2
fi

if [[ ! -f "$HOME_DIR/pyproject.toml" ]]; then
  log "downloading server bundle from $LCP_URL"
  mkdir -p "$HOME_DIR"
  tmp="$(mktemp)"
  curl -sSf -u "$USERNAME:$PASSWORD" -o "$tmp" \
    "$LCP_URL/suite/plugins/servlet/stateless/dev-mcp-bundle"
  tar -xzf "$tmp" -C "$HOME_DIR"
  rm -f "$tmp"
fi

if [[ ! -d "$HOME_DIR/.venv" ]]; then
  log "installing dependencies (uv sync)"
  (cd "$HOME_DIR" && uv python install 3.13 >&2 && uv sync >&2)
fi

exec uv run --directory "$HOME_DIR" python -m lcp_mcp_server
