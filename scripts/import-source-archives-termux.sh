#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Compatibility wrapper: redirect legacy invocations to the recursive importer.
URL="https://raw.githubusercontent.com/micaeljviana9-eng/rea-ecossistema/main/scripts/import-source-repositories-termux.sh"
DEST="$HOME/rea-source-import/import-source-repositories-termux.sh"
mkdir -p "$(dirname "$DEST")"

command -v curl >/dev/null 2>&1 || { pkg update -y; pkg install -y curl; }
curl --fail --location --retry 5 --retry-all-errors "$URL" --output "$DEST"
exec bash "$DEST" "$@"
