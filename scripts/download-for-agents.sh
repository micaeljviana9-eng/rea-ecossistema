#!/usr/bin/env bash
set -Eeuo pipefail
DESTINATION="${1:-$(pwd)/rea-ecossistema}"
INCLUDE_RELEASE_ARCHIVES="${INCLUDE_RELEASE_ARCHIVES:-0}"
REPO_URL="https://github.com/micaeljviana9-eng/rea-ecossistema.git"
BRANCH="main"

for cmd in git curl python3; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Falta dependência: $cmd" >&2; exit 1; }
done
git lfs version >/dev/null 2>&1 || { echo "Instale Git LFS e execute novamente." >&2; exit 1; }

if [[ ! -d "$DESTINATION/.git" ]]; then
  git clone --branch "$BRANCH" --recurse-submodules "$REPO_URL" "$DESTINATION"
else
  origin="$(git -C "$DESTINATION" remote get-url origin)"
  [[ "$origin" == "$REPO_URL" ]] || { echo "Destino já é outro repositório: $origin" >&2; exit 1; }
  git -C "$DESTINATION" fetch --prune origin
  git -C "$DESTINATION" switch "$BRANCH"
  git -C "$DESTINATION" pull --ff-only origin "$BRANCH"
fi

git -C "$DESTINATION" lfs install --local
git -C "$DESTINATION" lfs pull origin "$BRANCH"
git -C "$DESTINATION" submodule sync --recursive
git -C "$DESTINATION" submodule update --init --recursive

if [[ "$INCLUDE_RELEASE_ARCHIVES" == "1" ]]; then
  archive_dir="$DESTINATION/_downloads/source-archives"
  mkdir -p "$archive_dir"
  api="https://api.github.com/repos/micaeljviana9-eng/rea-ecossistema/releases/tags/source-archives-2026-10-14"
  python3 - "$api" "$archive_dir" <<'PY'
import json, pathlib, subprocess, sys, urllib.request
api, out = sys.argv[1], pathlib.Path(sys.argv[2])
with urllib.request.urlopen(api) as response:
    release = json.load(response)
for asset in release["assets"]:
    target = out / asset["name"]
    if not target.exists():
        print("Baixando", asset["name"])
        subprocess.run(["curl", "-fL", "--retry", "5", asset["browser_download_url"], "-o", str(target)], check=True)
PY
  if [[ -f "$archive_dir/SHA256SUMS.txt" ]]; then
    (cd "$archive_dir" && sha256sum -c SHA256SUMS.txt)
  fi
fi

echo "Download concluído: $DESTINATION"
echo "Branch: $BRANCH | Git LFS: sincronizado | Submódulos: inicializados"
