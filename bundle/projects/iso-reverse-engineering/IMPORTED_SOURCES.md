# Fontes importadas para análise de ISOs

Importação gerada em: 2026-10-14 20:58 UTC
Repositório de destino: https://github.com/micaeljviana9-eng/rea-ecossistema

Cada projeto abaixo é um snapshot extraído do Git sem o diretório interno .
O commit SHA registrado permite identificar exatamente a versão importada. Isso não
significa que dependências de build ou submódulos estejam incluídos; verifique os
arquivos README, LICENSE, COPYING e .gitmodules de cada projeto.

## sleuthkit
- URL: https://github.com/sleuthkit/sleuthkit.git
- Ref selecionada: branch:develop-4.1x
- Commit SHA importado: e08bdd2f9b74b319981144c03ee492e9287b9e0f
- Arquivos regulares extraídos: 958
- Tamanho aproximado: 19778 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## unblob
- URL: https://github.com/onekey-sec/unblob.git
- Ref selecionada: tag:26.6.4
- Commit SHA importado: 1fcc7a0a584a70a96c31f5a276c20944d199a089
- Arquivos regulares extraídos: 2873
- Tamanho aproximado: 283867 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## unblob-native
- URL: https://github.com/onekey-sec/unblob-native.git
- Ref selecionada: tag:v0.1.6
- Commit SHA importado: addfb0670baa94d143ecd12de2355266c6f9c636
- Arquivos regulares extraídos: 30
- Tamanho aproximado: 204 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## diffoscope
- URL: https://salsa.debian.org/reproducible-builds/diffoscope.git
- Ref selecionada: tag:333
- Commit SHA importado: 216806e4b4db7c7108f3bf72833845ac0931c087
- Arquivos regulares extraídos: 702
- Tamanho aproximado: 11450 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## squashfs-tools
- URL: https://github.com/plougher/squashfs-tools.git
- Ref selecionada: tag:4.7.5
- Commit SHA importado: 1fdc2fe01d681438a04e2a137a9f51d829ba3358
- Arquivos regulares extraídos: 140
- Tamanho aproximado: 2142 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## msitools
- URL: https://gitlab.gnome.org/GNOME/msitools.git
- Ref selecionada: tag:v0.106
- Commit SHA importado: a0110182dc4fbbc00b77bca2828e9e6481c72f5e
- Arquivos regulares extraídos: 262
- Tamanho aproximado: 3191 KiB
- Gitlinks/submódulos declarados na árvore upstream: 1
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## innoextract
- URL: https://github.com/dscharrer/innoextract.git
- Ref selecionada: tag:1.9
- Commit SHA importado: f5f2b02a117c4bca35a71ff6660dea20dc860216
- Arquivos regulares extraídos: 141
- Tamanho aproximado: 1199 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## unshield
- URL: https://github.com/twogood/unshield.git
- Ref selecionada: tag:1.6.2
- Commit SHA importado: 51de441ba6893f11026d4671ccef9e8e2a4634fa
- Arquivos regulares extraídos: 37
- Tamanho aproximado: 292 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## uefi-firmware-parser
- URL: https://github.com/theopolis/uefi-firmware-parser.git
- Ref selecionada: tag:v1.16
- Commit SHA importado: e202e576cefd1fefb3f510237bbd0aea8aedca07
- Arquivos regulares extraídos: 69
- Tamanho aproximado: 1011 KiB
- Gitlinks/submódulos declarados na árvore upstream: 0
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## kaitai-struct-formats
- URL: https://github.com/kaitai-io/kaitai_struct_formats.git
- Ref selecionada: branch:master
- Commit SHA importado: 6739687e6af86bb1326953dc6cef7f8e716c10ec
- Arquivos regulares extraídos: 224
- Tamanho aproximado: 2326 KiB
- Gitlinks/submódulos declarados na árvore upstream: 1
- Nota: revisar licença, dependências, arquivos de instrução e submódulos antes de usar.

## Candidatos não importados automaticamente
- `libguestfs`: instalar por pacote em um ambiente Linux adequado; pesado para Termux.
- `syft`: preferir release/binário oficial e registrar a versão.
- `dissect`: não importado; requer decisão explícita sobre AGPL-3.0.
- `xorriso` e `libcdio`: preferir pacote ou tarball oficial; validar assinatura/hash antes de guardar a fonte.
- Ferramentas de sistema como `e2fsprogs`, `mtools`, `qemu-img`, `cpio`, GRUB e Syslinux devem ser registradas como dependências de ambiente, não clonadas às cegas.
