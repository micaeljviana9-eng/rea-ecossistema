# Instruções para agentes — REA Ecossistema

Este repositório é o bundle completo de fontes e documentação do REA Ecossistema. Antes de analisar ou usar qualquer ferramenta, obtenha uma cópia local completa.

## Download recomendado

### Windows (PowerShell)
```powershell
git lfs install
powershell -ExecutionPolicy Bypass -File .\scripts\download-for-agents.ps1 -Destination .\rea-ecossistema
```

Para baixar também os snapshots compactados publicados na release (aprox. 547 MB):
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\download-for-agents.ps1 -Destination .\rea-ecossistema -IncludeReleaseArchives
```

### Linux/macOS
```bash
git lfs install
bash scripts/download-for-agents.sh ./rea-ecossistema
```

Para incluir os arquivos compactados da release:
```bash
INCLUDE_RELEASE_ARCHIVES=1 bash scripts/download-for-agents.sh ./rea-ecossistema
```

Os scripts clonam/atualizam a branch `main`, baixam objetos Git LFS e inicializam submódulos. O modo de release baixa os assets da tag `source-archives-2026-10-14` para `_downloads/source-archives` e confere os hashes SHA-256.

## Regras para agentes

1. Trabalhe sobre a cópia local; não trate o README como prova de que uma ferramenta já está compilada ou instalada.
2. Preserve `LICENSE`, `COPYING`, `NOTICE` e os avisos de cada projeto importado.
3. Respeite os commits fixados em `bundle/projects/iso-reverse-engineering/REPOSITORY_MANIFEST.md` e o inventário real em `SOURCE_IMPORT_STATUS.tsv`.
4. Não execute binários, instaladores, scripts de origem desconhecida ou amostras suspeitas no host. Use VM/laboratório isolado e mantenha hashes e logs.
5. Não substitua snapshots por versões upstream mais recentes sem registrar a mudança e atualizar o manifesto.
6. Se Git LFS falhar, não considere os arquivos de ponteiro de 128 bytes como os arquivos originais; corrija a recuperação LFS antes de prosseguir.

## Conteúdo e limites

- O checkout da branch `main` contém as fontes materializadas no bundle; a release guarda snapshots compactados adicionais e redundantes/auxiliares.
- Os arquivos ZIP rastreados por LFS precisam do Git LFS para serem recuperados corretamente.
- A release de snapshots tem 38 assets, aproximadamente 547 MB no total.
- Código-fonte não equivale a executáveis prontos. Dependências, SDKs, compiladores, drivers e requisitos de plataforma variam por projeto.
