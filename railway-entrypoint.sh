#!/usr/bin/env bash
# Railway mounts volumes root-owned, but the OpenSearch image runs as uid 1000.
# Take ownership of the data directory as root, then hand the process back to the
# unprivileged opensearch user, which OpenSearch requires (it refuses to run as root).
set -euo pipefail

DATA_DIR="${OPENSEARCH_DATA_DIR:-/usr/share/opensearch/data}"

if [ ! -d "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR"
fi
chown -R opensearch:opensearch "$DATA_DIR" || true
chown -R opensearch:opensearch /usr/share/opensearch/logs 2>/dev/null || true

# Refuse to boot rather than come up unauthenticated: the security plugin's demo
# bootstrap silently produces an open cluster when this is unset on some paths.
if [ -z "${OPENSEARCH_INITIAL_ADMIN_PASSWORD:-}" ]; then
  echo "FATAL: OPENSEARCH_INITIAL_ADMIN_PASSWORD is not set. Refusing to start an unauthenticated OpenSearch cluster on a public URL." >&2
  exit 1
fi

exec chroot --userspec=opensearch:opensearch --skip-chdir / \
  /usr/share/opensearch/opensearch-docker-entrypoint.sh "$@"
