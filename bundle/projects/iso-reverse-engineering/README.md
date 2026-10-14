# Engenharia reversa de ISO do Windows

Este diretório reúne ferramentas e fontes para estudar uma ISO do Windows de forma organizada. Nem tudo aqui abre uma ISO diretamente: algumas ferramentas extraem arquivos, outras analisam WIM/ESD, boot/UEFI, executáveis PE, drivers ou o comportamento do sistema instalado.

## Fluxo recomendado

1. **Inventariar e verificar a ISO** — calcular hashes, registrar tamanho e versão, comparar com uma imagem confiável.
2. **Listar e extrair o conteúdo** — explorar a estrutura ISO/UDF, localizar `boot.wim`, `install.wim` ou `install.esd`, `setup.exe`, catálogos e scripts.
3. **Inspecionar WIM/ESD e pacotes** — listar imagens/índices, montar ou extrair o conteúdo e comparar versões.
4. **Analisar executáveis e drivers** — identificar formato/arquitetura, imports, strings, metadados, recursos, assinatura e comportamento estático.
5. **Estudar boot e firmware** — examinar EFI/BCD, carregadores e componentes UEFI quando estiverem presentes.
6. **Comparar e documentar** — hashes, diffs entre versões, inventário de arquivos e dependências.

## Ferramentas já presentes como fontes reais

O inventário inicial deste projeto contém:

- **Arquivos/formatos/extração:** `7zip`, `libarchive`, `pycdlib`, `squashfs-tools`, `wimlib`, `msitools`, `innoextract`, `unshield`, `binwalk`, `unblob`, `unblob-native`.
- **Comparação/forense:** `diffoscope`, `sleuthkit`.
- **Firmware/UEFI:** `UEFITool`, `fiano`, `uefi-firmware-parser`, `edk2-platforms`.
- **Formatos estruturados:** `kaitai-struct-formats`.

Esse inventário é baseado na organização feita anteriormente; confira a árvore atual do GitHub para o estado exato de cada diretório.

## Fontes adicionais previstas para importação

O lançamento [source-archives-2026-10-14](https://github.com/micaeljviana9-eng/rea-ecossistema/releases/tag/source-archives-2026-10-14) guarda snapshots de código-fonte identificados por commit upstream. O script de importação do Termux tenta colocá-los como arquivos reais neste diretório e remove os gitlinks correspondentes:

### Análise de PE, executáveis, regras e metadados
- `detect-it-easy`, `pe-bear`, `pe-parse`, `pe-tree`, `pefile`, `lief`
- `capa`, `capa-rules`, `flare-floss`, `syft`, `winbindex`

### Desmontagem, decompilação e depuração
- `ghidra`, `radare2`, `rizin`, `cutter`, `x64dbg`, `imhex`, `ilspy`, `snowman`

### Windows, drivers, firmware e hardware
- `edk2`, `chipsec`, `phnt`, `windows-driver-samples`, `reactos`, `wine`

### Instrumentação, emulação e análise dinâmica
- `frida`, `dynamorio`, `qiling`, `speakeasy`, `dissect`, `volatility3`

### Ambiente e dependências auxiliares
- `flare-vm`, `libguestfs`, `push_artifacts`, `bats-core`

Algumas destas são ferramentas auxiliares ou ambientes de análise, não analisadores de ISO por si só. Por exemplo, FLARE-VM prepara um ambiente de análise no Windows; Volatility3 analisa memória; ILSpy foca assemblies .NET; ReactOS e Wine são referências/implementações de compatibilidade de APIs.

## O que ainda não significa “pronto”

- O código-fonte não equivale a binários compilados.
- Nem todos os projetos compilam em Android/Termux; muitos exigem Windows ou Linux x86-64, SDKs e dependências pesadas.
- O Windows ADK/DISM, ferramentas oficiais de assinatura e algumas ferramentas proprietárias podem ser complementos úteis, mas não são código incluído automaticamente aqui.
- O importador identifica arquivos individuais acima de 95 MiB antes do envio; projetos assim ficam pendentes para tratamento separado. O GitHub rejeita arquivos individuais acima de 100 MiB no Git comum.
- Antes de executar ferramentas, leia o README e a licença de cada projeto. Analise conteúdo suspeito em ambiente isolado.

## Progresso da importação

O script cria `SOURCE_IMPORT_STATUS.tsv` com o nome, o repositório upstream e o commit de cada snapshot enviado. Se o arquivo ainda não existir, a importação pode não ter sido executada ou ainda não ter concluído nenhum projeto.
