# REA Ecossistema

Repositório de pesquisa e ferramentas para **engenharia reversa de ISOs do Windows**, inspeção de instaladores, sistemas de arquivos, boot/UEFI, executáveis PE, drivers e análise forense.

## Comece por aqui

- [Catálogo da engenharia reversa de ISO do Windows](bundle/projects/iso-reverse-engineering/README.md)
- [Catálogo geral do bundle](bundle/CATALOG.md)
- [Importador de fontes pelo Termux](scripts/import-source-archives-termux.sh)
- [Pacotes de fontes arquivados por commit](https://github.com/micaeljviana9-eng/rea-ecossistema/releases/tag/source-archives-2026-10-14)

## Organização

- `bundle/original/rea/`: projeto REA original preservado.
- `bundle/projects/iso-reverse-engineering/`: ferramentas e fontes relacionadas à análise de ISOs, WIM/ESD, instaladores, boot e binários Windows.
- `.github/workflows/`: automações do repositório.
- `scripts/`: scripts de manutenção e importação.

## Estado das fontes

Algumas ferramentas já estão no repositório como arquivos reais; outras ainda estão registradas como submódulos ou disponíveis como arquivos de lançamento. O importador do Termux substitui os gitlinks dos projetos importáveis por arquivos reais, registra o commit upstream e permite retomar a execução.

**Importante:** o catálogo distingue ferramentas que analisam diretamente uma ISO de ferramentas complementares. Ter o código-fonte dentro do repositório não significa que o programa já esteja compilado ou pronto para executar. Muitos projetos exigem Linux/Windows de desktop, SDKs e dependências específicas.

## Uso responsável

Use essas ferramentas para analisar imagens, instaladores e sistemas que você possui ou tem autorização para examinar. Confira a licença de cada projeto upstream antes de redistribuir ou modificar seus arquivos.
