#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO_URL="https://github.com/micaeljviana9-eng/rea-ecossistema.git"
RELEASE_BASE="https://github.com/micaeljviana9-eng/rea-ecossistema/releases/download/source-archives-2026-10-14"
INDEX_URL="$RELEASE_BASE/SOURCE-ARCHIVE-INDEX.tsv"
ROOT="bundle/projects/iso-reverse-engineering"
STATUS="$ROOT/SOURCE_IMPORT_STATUS.tsv"
WORK="$HOME/rea-source-import"
CLONE="$WORK/rea-ecossistema"
ARCHIVES="$WORK/archives"
BRANCH="main"

need_pkg() {
  command -v "$1" >/dev/null 2>&1
}
if ! need_pkg git || ! need_pkg curl || ! need_pkg tar || ! need_pkg gh || ! need_pkg python; then
  pkg update -y
  pkg install -y git curl tar gh findutils grep coreutils python
fi

mkdir -p "$WORK" "$ARCHIVES"
if [ ! -d "$CLONE/.git" ]; then
  git clone "$REPO_URL" "$CLONE"
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Autentique no GitHub quando solicitado. Não envie tokens para ninguém."
  gh auth login
fi
gh auth setup-git

cd "$CLONE"
git switch "$BRANCH"
git fetch origin
git pull --rebase origin "$BRANCH"
git push origin "$BRANCH"

if [ -z "$(git config user.name || true)" ]; then
  read -r -p "Nome para os commits Git: " GIT_NAME
  git config user.name "$GIT_NAME"
fi
if [ -z "$(git config user.email || true)" ]; then
  read -r -p "E-mail para os commits Git: " GIT_EMAIL
  git config user.email "$GIT_EMAIL"
fi

mkdir -p "$ROOT"
touch "$STATUS"
curl --fail --location --retry 5 --retry-all-errors --connect-timeout 30 \
  "$INDEX_URL" --output "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

is_imported() {
  awk -F '\t' -v n="$1" '$1 == n { found=1 } END { exit !found }' "$STATUS"
}

while IFS=$'\t' read -r name upstream sha; do
  [ -n "${name:-}" ] || continue

  if is_imported "$name"; then
    echo "Já enviado; pulando: $name"
    continue
  fi

  case "$name" in
    push_artifacts) dest="$ROOT/kaitai-struct-formats/.github/push_artifacts" ;;
    bats-core) dest="$ROOT/msitools/subprojects/bats-core" ;;
    *) dest="$ROOT/$name" ;;
  esac

  archive="$ARCHIVES/$name-$sha.tar.gz"
  stage="$WORK/extracted-$name"
  ready="$WORK/extracted-$name.ok"

  echo
  echo "========== $name — $upstream @ $sha =========="

  if [ ! -s "$archive" ] && [ ! -f "$ready" ]; then
    curl --fail --location --retry 5 --retry-all-errors --connect-timeout 30 --max-time 1800 \
      "$RELEASE_BASE/$name-$sha.tar.gz" --output "$archive"
  fi

  if [ ! -f "$ready" ] || [ ! -d "$stage" ]; then
    rm -rf "$stage"
    mkdir -p "$stage"
    if ! tar -xzf "$archive" --strip-components=1 -C "$stage"; then
      echo "ERRO: não consegui extrair $name. Parei para não corromper a importação."
      exit 1
    fi
    touch "$ready"
  fi

  # GitHub rejects individual files over 100 MiB. Flag these before changing Git.
  large_list="$WORK/large-files-$name.txt"
  find "$stage" -type f -size +95M -print > "$large_list" || true
  if [ -s "$large_list" ]; then
    echo "PENDENTE: $name contém arquivos grandes demais para enviar com Git comum."
    echo "Arquivos encontrados:"
    cat "$large_list"
    echo "A cópia extraída ficou no aparelho em: $stage"
    echo "Vou continuar com os outros projetos; este será tratado depois com Git LFS/alternativa."
    continue
  fi

  # Remove the submodule pointer (gitlink) before replacing it with real source files.
  if git ls-files --stage -- "$dest" | grep -q '^160000 '; then
    git rm -f -- "$dest"
  else
    rm -rf "$dest"
  fi

  # Remove the matching .gitmodules stanza too, so the repository no longer
  # advertises a submodule after its real files have been imported.
  if [ -f .gitmodules ]; then
    python - "$dest" <<'PY'
import pathlib, re, sys
path = sys.argv[1]
p = pathlib.Path(".gitmodules")
text = p.read_text(encoding="utf-8") if p.exists() else ""
blocks = re.split(r"(?=^\[submodule )", text, flags=re.MULTILINE)
kept = []
for block in blocks:
    match = re.search(r"^\s*path\s*=\s*(.*?)\s*$", block, flags=re.MULTILINE)
    if match and match.group(1) == path:
        continue
    kept.append(block)
new_text = "".join(kept).strip()
p.write_text((new_text + "\n") if new_text else "", encoding="utf-8")
PY
  fi

  mkdir -p "$(dirname "$dest")"
  mv "$stage" "$dest"
  rm -f "$ready"

  printf '%s\t%s\t%s\n' "$name" "$upstream" "$sha" >> "$STATUS"
  git add -f -- "$dest" "$STATUS"
  git add -f -- .gitmodules 2>/dev/null || true

  if git diff --cached --quiet; then
    echo "Sem alterações para registrar: $name"
  else
    git commit -m "Import source files: $name ($sha)"
    echo "Enviando $name ao GitHub..."
    git push origin "$BRANCH"
  fi

  rm -f "$archive" "$large_list"
  echo "OK: $name"
done < "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

echo
echo "Importação executada. Confira os projetos pendentes acima."
echo "Fontes: $ROOT"
echo "Status: $STATUS"
echo "Área de trabalho local: $CLONE"
