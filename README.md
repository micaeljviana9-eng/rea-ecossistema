# REA Ecossistema

Repositório de pesquisa e ferramentas para **engenharia reversa de ISOs do Windows**, inspeção de instaladores, sistemas de arquivos, boot/UEFI, executáveis PE, drivers e análise forense.

## Comece por aqui
- [Guia de análise de ISO do Windows](bundle/projects/iso-reverse-engineering/README.md)
- [Catálogo geral do bundle](bundle/CATALOG.md)
- [Importador de fontes pelo Termux](scripts/import-source-archives-termux.sh)
- [Snapshots de fontes fixados por commit](https://github.com/micaeljviana9-eng/rea-ecossistema/releases/tag/source-archives-2026-10-14)

## Organização
- `bundle/original/rea/` — projeto REA original preservado.
- `bundle/projects/iso-reverse-engineering/` — ferramentas para ISO, WIM/ESD, instaladores, boot/UEFI e binários Windows.
- `bundle/projects/iso-reverse-engineering/source-files/` — snapshots importados, extraídos em diretórios normais.
- `.github/workflows/` — automações.
- `scripts/` — manutenção e importação.

## Estado das fontes
Algumas ferramentas já estão como arquivos reais; outras têm snapshots disponíveis na release. O importador do Termux baixa e extrai os snapshots, registra o commit upstream e permite retomar a execução. As pastas importadas não mantêm o histórico Git original.

## Fluxo sugerido
1. Registrar o SHA-256 e preservar a ISO original.
2. Listar o conteúdo sem executar binários.
3. Examinar `boot.wim`, `install.wim` ou `install.esd`.
4. Inspecionar CAB/MSI, PE/DLL, drivers, manifests e catálogos.
5. Comparar arquivos e documentar evidências com hashes.
6. Testar mudanças apenas em cópia descartável e VM isolada.

## Limites e licenças
Código-fonte presente não significa ferramenta compilada ou pronta para executar. Algumas ferramentas exigem Windows ADK/DISM, SDKs ou ambiente Linux/Windows de desktop. Preserve `LICENSE`, `COPYING` e `NOTICE` de cada projeto e confira as condições de redistribuição.
