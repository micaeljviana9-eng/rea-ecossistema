#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO_URL="https://github.com/micaeljviana9-eng/rea-ecossistema.git"
RELEASE_BASE="https://github.com/micaeljviana9-eng/rea-ecossistema/releases/download/source-archives-2026-10-14"
INDEX_URL="$RELEASE_BASE/SOURCE-ARCHIVE-INDEX.tsv"
BRANCH="main"
WORK="$HOME/rea-source-import"
CLONE="$WORK/rea-ecossistema"
ROOT="bundle/projects/iso-reverse-engineering"
STATUS="$ROOT/SOURCE_IMPORT_STATUS.tsv"

arg1=""
arg2=""
[ "$#" -ge 1 ] && arg1="$1"
[ "$#" -ge 2 ] && arg2="$2"
MAX_PER_RUN=3
case "$arg1" in
  "") ;;
  --all) MAX_PER_RUN=0 ;;
  --limit)
    if [[ ! "$arg2" =~ ^[1-9][0-9]*$ ]]; then
      echo "Uso: $0 [--all | --limit N]"
      exit 2
    fi
    MAX_PER_RUN="$arg2"
    ;;
  -h|--help)
    echo "Uso: $0 [--all | --limit N]"
    echo "Padrão: importa até 3 projetos por execução e permite retomar depois."
    exit 0
    ;;
  *)
    echo "Argumento desconhecido: $arg1"
    echo "Uso: $0 [--all | --limit N]"
    exit 2
    ;;
esac

need_install=0
for cmd in git curl gh rsync python find sha256sum; do
  if ! command -v "$cmd" >/dev/null 2>&1; then need_install=1; fi
done
if [ "$need_install" -eq 1 ]; then
  pkg update -y
  pkg install -y git curl tar gh rsync findutils coreutils python
fi

mkdir -p "$WORK" "$WORK/upstream" "$WORK/export"
if ! gh auth status >/dev/null 2>&1; then
  echo "Autentique no GitHub quando solicitado. Não compartilhe token no chat."
  gh auth login
fi
gh auth setup-git

if [ ! -d "$CLONE/.git" ]; then
  if [ -e "$CLONE" ]; then
    mv "$CLONE" "$WORK/rea-ecossistema-backup-$(date +%Y%m%d-%H%M%S)"
  fi
  git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$CLONE"
fi

cd "$CLONE"
git switch "$BRANCH"
git sparse-checkout init --cone
git sparse-checkout set scripts bundle/projects/iso-reverse-engineering
if [ -z "$(git status --porcelain)" ]; then
  git pull --rebase origin "$BRANCH"
else
  echo "Há alterações locais de uma tentativa anterior; vou preservá-las e continuar."
fi
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
if [ ! -s "$STATUS" ]; then
  printf 'name\tupstream\tcommit\tdestination\tregular_files\tnested_submodules\n' > "$STATUS"
elif ! head -n 1 "$STATUS" | grep -q '^name[[:space:]]'; then
  tmp_status="$STATUS.tmp"
  { printf 'name\tupstream\tcommit\tdestination\tregular_files\tnested_submodules\n'; cat "$STATUS"; } > "$tmp_status"
  mv "$tmp_status" "$STATUS"
fi

curl --fail --location --retry 5 --retry-all-errors --connect-timeout 30 \
  "$INDEX_URL" --output "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

is_imported() {
  awk -F '\t' -v n="$1" '$1 == n { found=1 } END { exit !found }' "$STATUS"
}

remove_root_gitmodule_entry() {
  local module_path="$1"
  if [ -f .gitmodules ]; then
    python - "$module_path" <<'PY'
from pathlib import Path
import re
import sys
wanted = sys.argv[1]
p = Path(".gitmodules")
text = p.read_text(encoding="utf-8")
blocks = re.split(r"(?=^\[submodule )", text, flags=re.MULTILINE)
kept = []
for block in blocks:
    match = re.search(r"^\s*path\s*=\s*(.*?)\s*$", block, flags=re.MULTILINE)
    if match and match.group(1).strip() == wanted:
        continue
    kept.append(block)
updated = "".join(kept).strip()
if updated:
    p.write_text(updated + "\n", encoding="utf-8")
else:
    p.unlink(missing_ok=True)
PY
    git add -A -- .gitmodules 2>/dev/null || true
  fi
}

IMPORTED_THIS_RUN=0

while IFS=$'\t' read -r name upstream sha; do
  [ -n "$name" ] || continue
  case "$name" in (*[!a-zA-Z0-9._-]*) echo "Nome inválido no índice: $name"; exit 1 ;; esac
  [[ "$sha" =~ ^[0-9a-f]{40}$ ]] || { echo "SHA inválido para $name: $sha"; exit 1; }

  # O snapshot antigo de yegord/snowman estava vazio; este fork contém o código-fonte.
  if [ "$name" = "snowman" ] && [ "$upstream" = "yegord/snowman" ]; then
    upstream="KarlVogel/snowman"
    sha="5a2a7d972434f0afd6c313e4443424d257b39b88"
  fi

  case "$name" in
    push_artifacts) dest="$ROOT/kaitai-struct-formats/.github/push_artifacts" ;;
    bats-core)      dest="$ROOT/msitools/subprojects/bats-core" ;;
    *)              dest="$ROOT/$name" ;;
  esac

  if is_imported "$name"; then
    type_now="$(git cat-file -t "HEAD:$dest" 2>/dev/null || true)"
    if [ "$type_now" = "tree" ]; then
      echo "Já enviado; pulando: $name"
      continue
    fi
    echo "O status de $name existe, mas o destino não é uma árvore de arquivos; vou tentar novamente."
  fi

  echo
  echo "========== $name — $upstream @ $sha =========="
  source_clone="$WORK/upstream/$name"
  stage="$WORK/export/$name"
  rm -rf "$source_clone" "$stage"
  mkdir -p "$WORK/upstream" "$WORK/export"

  if ! git clone --filter=blob:none --no-checkout --depth 1 --no-tags \
       "https://github.com/$upstream.git" "$source_clone"; then
    echo "ERRO: não consegui clonar $upstream. Os projetos já enviados continuam preservados."
    exit 1
  fi
  current_sha="$(git -C "$source_clone" rev-parse HEAD)"
  if [ "$current_sha" != "$sha" ]; then
    if ! git -C "$source_clone" fetch --depth=1 origin "$sha"; then
      echo "ERRO: não consegui buscar o commit fixado $sha em $upstream."
      exit 1
    fi
  fi
  git -C "$source_clone" checkout --detach "$sha"
  actual_sha="$(git -C "$source_clone" rev-parse HEAD)"
  [ "$actual_sha" = "$sha" ] || { echo "SHA divergente em $name"; exit 1; }

  # Reescreve URLs SSH comuns do GitHub para HTTPS, sem exigir chave SSH no Termux.
  git -C "$source_clone" config --local --add url."https://github.com/".insteadOf "git@github.com:" || true
  git -C "$source_clone" config --local --add url."https://github.com/".insteadOf "ssh://git@github.com/" || true
  git -C "$source_clone" config --local --add url."https://github.com/".insteadOf "git://github.com/" || true

  nested_count=0
  if [ -f "$source_clone/.gitmodules" ]; then
    git -C "$source_clone" submodule sync --recursive || true
    if ! git -C "$source_clone" submodule update --init --recursive --depth 1 --jobs 2; then
      echo "ERRO: um submódulo interno de $name não pôde ser baixado."
      echo "Pasta temporária para diagnóstico: $source_clone"
      exit 1
    fi
    nested_count="$(git -C "$source_clone" submodule status --recursive 2>/dev/null | wc -l | tr -d ' ')"
  fi

  mkdir -p "$stage"
  rsync -a --exclude='.git' "$source_clone/" "$stage/"
  file_count="$(find "$stage" -type f | wc -l | tr -d ' ')"
  if [ "$file_count" -lt 2 ]; then
    echo "ERRO: $name veio quase vazio; não vou substituir o gitlink por uma pasta vazia."
    exit 1
  fi

  # O GitHub rejeita arquivos individuais acima de 100 MiB; estes ficam pendentes.
  large_list="$WORK/large-files-$name.txt"
  find "$stage" -type f -size +95M -print > "$large_list" || true
  if [ -s "$large_list" ]; then
    echo "PENDENTE: $name contém arquivos acima de 95 MiB."
    cat "$large_list"
    echo "A exportação ficou em $stage; não alterei o destino do projeto."
    rm -rf "$source_clone"
    continue
  fi

  dest_abs="$CLONE/$dest"
  type_now="$(git cat-file -t "HEAD:$dest" 2>/dev/null || true)"
  if [ "$type_now" = "commit" ] || git ls-files --stage -- "$dest" | grep -q '^160000 '; then
    git rm --cached -f --ignore-unmatch -- "$dest" || true
    rm -rf "$dest_abs"
  elif [ -e "$dest_abs" ]; then
    echo "PENDENTE: o destino já contém arquivos normais, não um gitlink:"
    echo "  $dest"
    echo "Preservei os arquivos existentes; revise esse projeto manualmente."
    rm -rf "$source_clone"
    continue
  fi

  mkdir -p "$dest_abs"
  rsync -a --exclude='.git' "$stage/" "$dest_abs/"
  remove_root_gitmodule_entry "$dest"

  file_count="$(find "$dest_abs" -type f | wc -l | tr -d ' ')"
  tmp_status="$STATUS.tmp"
  awk -F '\t' -v n="$name" 'NR == 1 || $1 != n' "$STATUS" > "$tmp_status"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$upstream" "$sha" "$dest" "$file_count" "$nested_count" >> "$tmp_status"
  mv "$tmp_status" "$STATUS"

  git add -f -- "$dest" "$STATUS"
  git add -A -- .gitmodules 2>/dev/null || true
  if ! git diff --cached --quiet; then
    git commit -m "Import source files: $name ($sha)"
    echo "Enviando $name ao GitHub..."
    git push origin "$BRANCH"
  fi

  rm -rf "$source_clone" "$stage" "$large_list"
  echo "OK: $name — $file_count arquivos; submódulos internos materializados: $nested_count"
  IMPORTED_THIS_RUN=$((IMPORTED_THIS_RUN + 1))

  if [ "$MAX_PER_RUN" -gt 0 ] && [ "$IMPORTED_THIS_RUN" -ge "$MAX_PER_RUN" ]; then
    echo "Limite desta execução atingido ($MAX_PER_RUN projetos)."
    break
  fi
done < "$WORK/SOURCE-ARCHIVE-INDEX.tsv"

TOTAL="$(awk 'NF {n++} END {print n+0}' "$WORK/SOURCE-ARCHIVE-INDEX.tsv")"
DONE="$(awk -F '\t' '$1 != "name" && NF >= 3 {seen[$1]=1} END {for (x in seen) n++; print n+0}' "$STATUS")"
PENDING=$((TOTAL - DONE))

if [ "$PENDING" -eq 0 ]; then
  python - <<'PY'
from pathlib import Path
import re
p = Path("bundle/projects/iso-reverse-engineering/REPOSITORY_MANIFEST.md")
if p.exists():
    s = p.read_text(encoding="utf-8")
    start = s.find("The 33 tool/engine paths in the table below are Git submodules")
    end = s.find("\n\nLarge sources", start) if start >= 0 else -1
    if start >= 0 and end > start:
        note = "The table records pinned upstream commits. The Termux importer expands each pinned commit into regular source files and recursively materializes upstream submodules where available. Upstream .git metadata and Git history are not copied. SOURCE_IMPORT_STATUS.tsv records the source snapshots actually imported."
        s = s[:start] + note + s[end:]
    s = s.replace("| Git submodule |", "| Source snapshot (expanded) |")
    s = s.replace("| Archived mirror |", "| Source snapshot (expanded from archived mirror) |")
    s = re.sub(r"These two dependencies were declared by source-tree .*", "These two dependencies were declared by source-tree .gitmodules files and are expanded by the Termux importer into ordinary files at their nested destinations. Their original source .gitmodules files are preserved as upstream metadata.", s)
    q = chr(96)
    old = "| " + q + "snowman" + q + " | [" + q + "yegord/snowman" + q + "](https://github.com/yegord/snowman) | " + q + "master" + q + " | " + q + "8c26cb1979822f7afe9504c72c9f022e2418fd6e" + q + " | Git submodule |"
    new = "| " + q + "snowman" + q + " | [" + q + "KarlVogel/snowman" + q + "](https://github.com/KarlVogel/snowman) | " + q + "master" + q + " | " + q + "5a2a7d972434f0afd6c313e4443424d257b39b88" + q + " | Source snapshot (expanded from archived mirror) |"
    s = s.replace(old, new)
    p.write_text(s, encoding="utf-8")
PY
  git add -f "$ROOT/REPOSITORY_MANIFEST.md"
  if ! git diff --cached --quiet; then
    git commit -m "Document expanded source snapshot inventory"
    git push origin "$BRANCH"
  fi
fi

echo
echo "========== RESUMO =========="
echo "Importados nesta execução: $IMPORTED_THIS_RUN"
echo "Concluídos registrados: $DONE de $TOTAL"
echo "Pendentes: $PENDING"
echo "Fontes: $ROOT"
echo "Status: $STATUS"
echo "Área local: $CLONE"
if [ "$PENDING" -gt 0 ]; then
  echo "Execute novamente para continuar. Use '$0 --all' para tentar todos numa execução."
else
  echo "Todos os snapshots do índice foram importados."
fi
