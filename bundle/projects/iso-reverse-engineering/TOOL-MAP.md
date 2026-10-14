# Mapa de ferramentas para engenharia reversa de ISO do Windows

Este mapa explica **para que serve cada ferramenta no fluxo**. A presença de uma fonte no repositório não significa que ela seja necessária para abrir uma ISO, que esteja compilada ou que funcione no Android.

Legenda de prioridade:
- **Núcleo** — diretamente útil para listar/extrair imagens ou começar a inspecionar o conteúdo.
- **Complementar** — útil para arquivos específicos encontrados dentro da ISO.
- **Indireta/especializada** — útil só em cenários determinados, como firmware, memória, drivers, ambiente de laboratório ou compatibilidade.

## 1. Abrir a ISO e extrair seus arquivos

| Projeto | Prioridade | Utilidade prática | Observação |
|---|---|---|---|
| `7zip` | Núcleo | Lista e extrai muitos formatos de arquivo e imagens; bom para reconhecimento inicial da ISO. | Nem todo formato/atributo de ISO é exposto da mesma forma em todas as versões. |
| `pycdlib` | Núcleo | Biblioteca Python para listar, ler e criar imagens ISO 9660 programaticamente. | É biblioteca, não interface gráfica pronta. |
| `libarchive` | Núcleo | Biblioteca e utilitários para leitura de vários formatos de arquivo. | É componente reutilizável por outros programas. |
| `wimlib` | Núcleo | Trabalha com imagens WIM; essencial para investigar `install.wim`, índices/edições, metadados e extração quando compatível. | Imagens ESD podem usar compressão/recursos que dependem da versão/configuração. |
| `diffoscope` | Complementar | Compara arquivos, diretórios e artefatos complexos entre versões de ISOs ou atualizações. | Excelente depois de extrair duas versões para árvores separadas. |
| `kaitai-struct-formats` | Complementar | Definições de formatos binários que ajudam a interpretar estruturas de arquivos. | Coleção de definições; não é um extrator universal de ISO. |
| `binwalk` | Complementar | Detecta assinaturas e possíveis conteúdos embutidos em blobs/imagens. | Mais orientado a firmware e dados binários; resultados podem conter falsos positivos. |
| `unblob`, `unblob-native` | Complementar | Detectam e extraem diversos formatos/carregamentos aninhados de blobs. | Úteis em componentes empacotados; não substituem o tratamento adequado de WIM/ESD. |
| `squashfs-tools` | Especializada | Lê/cria imagens SquashFS. | Não é o formato comum do Windows `install.wim`; útil se uma imagem contiver SquashFS. |
| `sleuthkit` | Complementar | Análise forense de sistemas de arquivos e imagens de disco. | Mais indicado para volumes/imagens de disco do que para desmontar arquivos ISO diretamente. |
| `libguestfs` | Indireta | Ferramentas para inspecionar sistemas de arquivos e discos de máquinas virtuais. | Mais natural em ambiente Linux; dependências pesadas para celular. |

### O que procurar na ISO

- `boot.wim`: ambiente de instalação/recuperação e componentes de inicialização.
- `install.wim` ou `install.esd`: imagens das edições do Windows.
- `setup.exe`, `setuphost.exe`, DLLs e pastas de suporte: executáveis e lógica do instalador.
- `sources/$OEM$`, scripts, arquivos XML/manifestos e catálogos: possíveis personalizações, automatizações e metadados.
- `efi/`, arquivos BCD e carregadores: caminho de inicialização, especialmente em modo UEFI.

## 2. Instaladores e formatos de pacotes

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `msitools` | Complementar | Inspeciona e manipula pacotes Windows Installer MSI e arquivos relacionados. |
| `innoextract` | Complementar | Extrai instaladores criados com Inno Setup. |
| `unshield` | Complementar | Extrai determinados pacotes CAB baseados em InstallShield. |
| `7zip` | Núcleo | Também pode reconhecer diversos arquivos compactados encontrados dentro da ISO. |

Essas ferramentas são para pacotes que você encontra dentro da imagem ou em instaladores auxiliares; não significam que o instalador completo do Windows possa ser reconstruído automaticamente.

## 3. Executáveis PE, DLLs, drivers e metadados

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `detect-it-easy` | Núcleo após extração | Identifica formatos, arquiteturas, empacotadores e características de binários. |
| `pefile` | Complementar | Biblioteca Python para analisar cabeçalhos e estruturas PE. |
| `pe-parse` | Complementar | Biblioteca para analisar executáveis no formato PE. |
| `pe-tree` | Complementar | Apresenta a estrutura de um executável PE em árvore, para facilitar inspeção. |
| `pe-bear` | Complementar | Interface gráfica para analisar estruturas, seções e metadados PE. |
| `lief` | Complementar | Biblioteca para examinar e modificar formatos executáveis, incluindo PE. |
| `capa` + `capa-rules` | Complementar | Infere capacidades presentes em executáveis usando regras e características estáticas. |
| `flare-floss` | Complementar | Recupera e classifica strings de executáveis, incluindo strings ofuscadas em casos suportados. |
| `syft` | Indireta | Gera inventários/SBOM de pacotes e sistemas de arquivos compatíveis; ajuda a identificar componentes e dependências. |
| `winbindex` | Indireta | Índice público de binários Windows; ajuda em pesquisas de versão, símbolos/metadados e comparação de arquivos conhecidos. |

## 4. Desmontagem, decompilação, edição hexadecimal e depuração

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `ghidra` | Complementar | Engenharia reversa estática, desmontagem e decompilação de executáveis compatíveis. |
| `radare2` | Complementar | Análise binária e desmontagem por CLI/script. |
| `rizin` | Complementar | Framework de análise binária derivado do radare2. |
| `cutter` | Complementar | Interface gráfica para trabalhar com Rizin. |
| `x64dbg` | Complementar | Depurador dinâmico para programas Windows x86/x64; precisa de ambiente Windows. |
| `ilspy` | Complementar | Decompila assemblies .NET; útil para componentes gerenciados encontrados na imagem. |
| `snowman` | Complementar | Decompilador de código nativo, dependendo de arquitetura e suporte do projeto. |
| `imhex` | Complementar | Editor hexadecimal e ambiente para examinar estruturas binárias. |

Esses projetos são mais úteis **depois de extrair um executável, DLL, driver ou biblioteca**. Não são extratores de ISO.

## 5. Análise dinâmica, emulação e instrumentação

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `frida` | Especializada | Instrumenta processos durante a execução; o repositório depende de outros componentes internos. |
| `dynamorio` | Especializada | Instrumentação dinâmica de programas em ambientes/plataformas suportados. |
| `qiling` | Especializada | Emula programas e interfaces de sistema para estudar comportamento em um ambiente controlado. |
| `speakeasy` | Especializada | Emula partes de APIs Windows para análise dinâmica de determinados binários, sem substituir uma VM real em todos os casos. |
| `flare-vm` | Ambiente | Scripts para preparar uma estação Windows de análise. Não é um parser de ISO; leia os scripts antes de executar. |

Use a análise dinâmica em uma VM descartável, sem credenciais pessoais, e com snapshots para poder reverter o ambiente.

## 6. Boot, UEFI, firmware e drivers

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `UEFITool` | Especializada | Navega e analisa volumes/estruturas em imagens de firmware UEFI. |
| `fiano` | Especializada | Bibliotecas e ferramentas para leitura/manipulação de firmware UEFI. |
| `uefi-firmware-parser` | Especializada | Faz parsing de estruturas de firmware UEFI. |
| `edk2` | Referência/compilação | Código do TianoCore EDK II e da pilha de desenvolvimento UEFI. Não é necessário para simplesmente abrir uma ISO. |
| `edk2-platforms` | Referência/compilação | Plataformas e componentes adicionais para EDK II. |
| `chipsec` | Especializada | Avalia certas configurações e componentes de segurança de plataforma/firmware; algumas funções exigem hardware, drivers e privilégios. |
| `phnt` | Referência | Headers/documentação não oficial para interfaces internas do Windows/NT. Ajuda a interpretar APIs e estruturas, não a extrair imagens. |
| `windows-driver-samples` | Referência | Exemplos oficiais de drivers Windows para estudar padrões e APIs. |
| `reactos` | Referência | Implementação compatível/alternativa a APIs Windows, útil para comparar comportamentos; não é analisador de ISO. |
| `wine` | Referência/compatibilidade | Camada de compatibilidade para executar aplicações Windows em sistemas suportados; não substitui o Windows nem extrai ISO. |

## 7. Forense e análise indireta

| Projeto | Prioridade | Utilidade prática |
|---|---|---|
| `dissect` | Especializada | Ecossistema Python de bibliotecas para investigação forense e artefatos de sistemas; o repositório agregador pode depender de pacotes separados. |
| `volatility3` | Indireta | Analisa dumps de memória. Só é útil se a investigação incluir memória capturada, não para extrair uma ISO por si só. |
| `sleuthkit` | Complementar | Análise de sistemas de arquivos e evidências de disco. |
| `libguestfs` | Indireta | Inspeciona volumes/sistemas de arquivos de discos virtuais em ambiente compatível. |

## 8. Ordem recomendada para começar

1. **7-Zip + pycdlib/libarchive** — inventariar e extrair a ISO.
2. **wimlib** — listar/examinar as imagens WIM/ESD encontradas.
3. **msitools / innoextract / unshield** — examinar instaladores e pacotes específicos encontrados.
4. **Detect-It-Easy + pefile/LIEF** — identificar e entender EXEs, DLLs e drivers.
5. **capa + FLOSS + Ghidra/ILSpy** — procurar capacidades, strings e lógica do código.
6. **diffoscope** — comparar resultados entre versões da ISO.
7. **UEFITool/fiano** — investigar firmware quando a pergunta de análise envolver UEFI/firmware.

## Estado das fontes e limites

- [REPOSITORY_MANIFEST.md](REPOSITORY_MANIFEST.md) registra upstreams e commits fixados.
- [SOURCES.md](SOURCES.md) e [IMPORTED_SOURCES.md](IMPORTED_SOURCES.md) documentam importações feitas anteriormente.
- O importador escreve [SOURCE_IMPORT_STATUS.tsv](SOURCE_IMPORT_STATUS.tsv) com os projetos materializados, o commit e a contagem de arquivos.
- Código-fonte não significa binário compilado, ambiente instalado nem suporte ao Termux. Algumas ferramentas exigem Windows/Linux de desktop, drivers, SDKs ou dependências grandes.
- Cada projeto mantém seu próprio licenciamento. Preserve e confira os arquivos `LICENSE`, `COPYING` e `NOTICE`.
