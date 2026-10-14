#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO_URL="https://github.com/micaeljviana9-eng/rea-ecossistema.git"
RELEASE_BASE="https://github.com/micaeljviana9-eng/rea-ecossistema/releases/download/source-archives-2026-10-14"
INDEX_URL="$RELEASE_BASE/SOURCE-ARCHIVE-INDEX.tsv"
TARGET="bundle/projects/iso-reverse-engineering/source-files"
WORK="${TMPDIR:-$HOME/tmp}/rea-source-import"
BRANCH="main"

if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
  echo "Instalando ferramentas necessárias..."
  pkg update -y
  pkg install -y git curl tar
fi

mkdir -p "$(dirname "$WORK")"
mkdir -p "$WORK"

if [ ! -d "$WORK/rea-ecossistema/.git" ]; then
  echo "Clonando o repositório..."
  git clone "$REPO_URL" "$WORK/rea-ecossistema"
fi

cd "$WORK/rea-ecossistema"
git switch "$BRANCH"
mkdir -p "$TARGET"

if [ -z "$(git config user.name || true)" ]; then
  read -r -p "Seu nome para os commits do Git: " GIT_NAME
  git config user.name "$GIT_NAME"
fi
if [ -z "$(git config user.email || true)" ]; then
  read -r -p "Seu e-mail do GitHub: " GIT_EMAIL
  git config user.email "$GIT_EMAIL"
fi

curl --fail --location --retry 5 "$INDEX_URL" --output "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

while IFS="$(printf '\t')" read -r name upstream sha; do
  [ -n "$name" ] || continue
  archive="$WORK/$name-$sha.tar.gz"
  dest="$TARGET/$name"
  marker="$dest/.source-import-complete"

  if [ -f "$marker" ]; then
    echo "Já importado; pulando: $name"
    continue
  fi

  echo
  echo "===== Importando $name ($upstream @ $sha) ====="
  curl --fail --location --retry 5 --retry-all-errors --connect-timeout 30 \
    "$RELEASE_BASE/$name-$sha.tar.gz" --output "$archive"

  rm -rf "$dest"
  mkdir -p "$dest"
  if ! tar -xzf "$archive" --strip-components=1 -C "$dest"; then
    echo "Falha ao extrair $name. Mantive os commits anteriores; pode executar novamente."
    exit 1
  fi
  printf 'upstream=%s\ncommit=%s\narchive=%s\n' "$upstream" "$sha" "$name-$sha.tar.gz" > "$marker"

  git add -f "$dest"
  if git diff --cached --quiet; then
    echo "Nenhuma alteração Git para $name."
  else
    git commit -m "Import source snapshot: $name ($sha)"
    echo "Enviando $name ao GitHub..."
    git push origin "$BRANCH"
  fi

  rm -f "$archive"
  echo "Concluído: $name"
done < "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

echo
echo "Importação concluída. Pastas em: $TARGET"
echo "Repositório local: $WORK/rea-ecossistema"
