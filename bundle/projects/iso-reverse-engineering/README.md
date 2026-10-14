# Engenharia reversa de ISO do Windows

Este diretório reúne fontes de ferramentas para analisar uma ISO do Windows e o conteúdo que existe dentro dela. Nem todas as ferramentas abrem a ISO: algumas ajudam com WIM/ESD, instaladores MSI/CAB, executáveis PE, drivers, boot/UEFI, sistemas de arquivos ou análise forense depois da extração.

## Fluxo de análise sugerido

1. **Preservar e identificar a imagem:** registre a versão, tamanho e SHA-256 da ISO; trabalhe numa cópia e não altere o original.
2. **Listar a ISO:** use 7-Zip e bibliotecas/formatos como pycdlib ou libarchive para entender a estrutura e localizar `boot.wim`, `install.wim`, `install.esd`, `setup.exe`, catálogos e pastas EFI.
3. **Examinar as imagens do Windows:** use wimlib para listar índices, consultar metadados e extrair ou comparar o conteúdo de WIM/ESD quando suportado.
4. **Examinar pacotes e executáveis:** msitools para MSI; Detect-It-Easy para identificar formatos; pefile, pe-parse, PE-Bear e LIEF para estruturas PE; capa e FLOSS para indícios de capacidades e strings.
5. **Decompilar e comparar:** Ghidra, Rizin/radare2, Cutter, x64dbg e ILSpy podem ajudar com código nativo, depuração ou assemblies .NET; diffoscope ajuda a comparar árvores/arquivos.
6. **Investigar inicialização e firmware quando necessário:** examine arquivos EFI/BCD e componentes UEFI; UEFITool, fiano, uefi-firmware-parser e EDK II são mais especializados em firmware do que em extração de ISO comum.
7. **Documentar os resultados:** mantenha hashes, caminhos, versões, logs, commits das ferramentas e diferenças observadas.

Consulte o [mapa das ferramentas](TOOL-MAP.md) para distinguir ferramentas centrais, complementares e de uso indireto.

## Conteúdo inicial já presente como arquivos reais

O inventário existente inclui ferramentas de arquivo/formato e extração (`7zip`, `libarchive`, `pycdlib`, `squashfs-tools`, `wimlib`, `msitools`, `innoextract`, `unshield`, `binwalk`, `unblob`, `unblob-native`, `kaitai-struct-formats`), comparação/forense (`diffoscope`, `sleuthkit`) e firmware/UEFI (`UEFITool`, `fiano`, `uefi-firmware-parser`, `edk2-platforms`). Consulte a árvore atual para o estado exato de cada fonte.

## Fontes adicionais a materializar

A release [source-archives-2026-10-14](https://github.com/micaeljviana9-eng/rea-ecossistema/releases/tag/source-archives-2026-10-14) contém snapshots fixados por commit upstream. Os caminhos previstos incluem ferramentas PE, motores de engenharia reversa, análise dinâmica, firmware, drivers e fontes de compatibilidade do Windows. O manifesto em [REPOSITORY_MANIFEST.md](REPOSITORY_MANIFEST.md) registra as origens e SHAs.

O importador atualizado é [scripts/import-source-repositories-termux.sh](https://github.com/micaeljviana9-eng/rea-ecossistema/blob/main/scripts/import-source-repositories-termux.sh). Ele baixa cada upstream no commit fixado, tenta inicializar recursivamente os submódulos internos, converte o gitlink para arquivos regulares e faz commit/push em lotes retomáveis. Não guarda os `.tar.gz` na árvore final.

## Executar pelo Termux

No Android, execute:

```bash
pkg update -y
pkg install -y curl
mkdir -p ~/rea-source-import
curl -fL --retry 5 \
  "https://raw.githubusercontent.com/micaeljviana9-eng/rea-ecossistema/main/scripts/import-source-repositories-termux.sh" \
  -o ~/rea-source-import/import-source-repositories-termux.sh
bash ~/rea-source-import/import-source-repositories-termux.sh
```

Por padrão, importa até **3 projetos por execução**, para reduzir o risco de sobrecarregar o celular. Rode o comando novamente para continuar. Para tentar todos os restantes na mesma execução, use:

```bash
bash ~/rea-source-import/import-source-repositories-termux.sh --all
```

Na primeira execução, o script pode instalar dependências e solicitar `gh auth login`. Faça a autenticação diretamente no Termux e nunca cole tokens no chat. Prefira Wi-Fi e confira se há espaço livre suficiente, já que alguns projetos e submódulos são grandes.

O status fica em `SOURCE_IMPORT_STATUS.tsv`. Arquivos individuais acima de 95 MiB ficam pendentes para revisão porque o GitHub bloqueia blobs maiores que 100 MiB no Git comum. Se um submódulo falhar, o script para naquele projeto e mantém a pasta temporária para diagnóstico; os commits enviados anteriormente permanecem no GitHub.

## Limites técnicos

- Código-fonte não equivale a binários compilados ou ferramentas prontas para executar.
- Várias ferramentas exigem Windows/Linux de desktop, compiladores, SDKs, drivers ou dependências que não funcionam no Termux.
- ReactOS, Wine, CHIPSEC, Volatility3 e FLARE-VM são recursos para tarefas específicas/indiretas; não substituem um extrator de ISO.
- Preserve e confira `LICENSE`, `COPYING` e `NOTICE` de cada projeto antes de redistribuir ou modificar.
- Analise conteúdo desconhecido em VM isolada e mantenha hashes e logs para permitir auditoria.
