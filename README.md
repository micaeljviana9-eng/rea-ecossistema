# REA Ecossistema

Coleção de projetos e ferramentas para engenharia reversa, análise de executáveis, firmware, instaladores e imagens de disco — com foco em estudar uma ISO do Windows de forma reproduzível.

## Comece por aqui

- [Guia de análise de uma ISO do Windows](bundle/projects/iso-reverse-engineering/README.md)
- [Mapa das ferramentas: o que serve para cada etapa](bundle/projects/iso-reverse-engineering/TOOL-MAP.md)
- [Manifesto de fontes e commits fixados](bundle/projects/iso-reverse-engineering/REPOSITORY_MANIFEST.md)
- [Fontes já importadas antes deste lote](bundle/projects/iso-reverse-engineering/SOURCES.md) e [inventário das importações anteriores](bundle/projects/iso-reverse-engineering/IMPORTED_SOURCES.md)
- [Catálogo do restante ecossistema](bundle/CATALOG.md)
- [Importador de fontes pelo Termux](scripts/import-source-repositories-termux.sh)
- [Snapshots fixados na release](https://github.com/micaeljviana9-eng/rea-ecossistema/releases/tag/source-archives-2026-10-14)

## Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| `bundle/original/rea/` | Snapshot do projeto REA original e seus arquivos de documentação |
| `bundle/projects/` | Ferramentas, integrações e projetos de análise organizados por finalidade |
| `bundle/projects/iso-reverse-engineering/` | Ferramentas de ISO, WIM/ESD, instaladores, PE/EXE/DLL, boot, UEFI e forense |
| `bundle/reports/` | Relatórios do trabalho de pesquisa |
| `.github/workflows/` | Automatizações do GitHub Actions |
| `scripts/` | Scripts de importação e manutenção |

As ferramentas são mantidas em subpastas separadas para preservar seus próprios arquivos de licença e documentação. As cópias importadas preservam o código e os avisos de licença, mas não o histórico Git original de cada upstream.

## Qual é o núcleo para ISO do Windows?

Comece por **7-Zip, pycdlib/libarchive e wimlib** para inspecionar a imagem e seus arquivos; depois use ferramentas de instaladores e executáveis, como **msitools, Detect-It-Easy, pefile/LIEF, capa/FLOSS e Ghidra**. Veja [o fluxo completo e o papel de cada projeto](bundle/projects/iso-reverse-engineering/TOOL-MAP.md).

Nem toda ferramenta listada abre uma ISO diretamente. Algumas só ajudam depois que você extrai o conteúdo: por exemplo, decompiladores, depuradores, análise de memória, firmware/UEFI ou ambientes de laboratório.

## Importar as fontes restantes pelo Termux

No Android com Termux, copie e execute:

```bash
pkg update -y
pkg install -y curl
mkdir -p ~/rea-source-import
curl -fL --retry 5 \
  "https://raw.githubusercontent.com/micaeljviana9-eng/rea-ecossistema/main/scripts/import-source-repositories-termux.sh" \
  -o ~/rea-source-import/import-source-repositories-termux.sh
bash ~/rea-source-import/import-source-repositories-termux.sh
```

O importador começa com lotes de até 3 projetos para reduzir a chance de sobrecarregar o celular. Execute os mesmos comandos novamente para continuar do ponto registrado. Depois de confirmar que está funcionando e há espaço suficiente, pode passar `--all` ao script para tentar todo o restante de uma vez.

O script transforma os gitlinks correspondentes em arquivos reais, tenta materializar os submódulos internos e envia cada projeto em um commit separado. Não armazena os arquivos compactados na árvore do repositório. O progresso fica em `bundle/projects/iso-reverse-engineering/SOURCE_IMPORT_STATUS.tsv`.

## Limites e cuidados

- Libere espaço no aparelho e prefira Wi-Fi estável; algumas fontes são grandes, e os submódulos podem aumentar bastante o download.
- O GitHub bloqueia arquivos individuais com mais de 100 MiB no Git comum. O importador sinaliza arquivos grandes em vez de enviá-los silenciosamente.
- Código-fonte não significa que o programa já esteja compilado nem que rode no Android/Termux. Algumas ferramentas exigem Windows ou Linux de desktop, SDKs, drivers e dependências próprias.
- Preserve e leia os arquivos `LICENSE`, `COPYING` e `NOTICE` de cada projeto antes de redistribuir ou modificar.
- Para examinar ISOs, mantenha a imagem original intacta, registre hashes e teste alterações em uma cópia isolada.
