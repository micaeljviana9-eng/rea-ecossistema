# Ambiente de engenharia reversa

## Objetivo

Preparar um ambiente para estudar imagens ISO do Windows, formatos de
instalação, executáveis PE, bibliotecas DLL, programas .NET e firmware.

## Instalação inicial no Windows 11

Execute `scripts/setup-windows.ps1` no PowerShell do Windows.
O script utiliza o Windows Package Manager (winget).

O script instala ou tenta instalar:
- Git: controle de versão e obtenção de código-fonte.
- Python: automação e scripts de análise.
- 7-Zip: inspeção e extração de arquivos e imagens.
- Java JDK 21: ambiente Java necessário para algumas ferramentas.

## Ferramentas de análise

- Ghidra: análise estática e descompilação de executáveis compatíveis.
- ILSpy: análise de assemblies .NET.
- PE-bear e Detect It Easy: inspeção de executáveis PE.
- wimlib: trabalho com imagens WIM e formatos relacionados, conforme
  suporte da versão e do ambiente.
- x64dbg: depuração dinâmica de programas Windows.
- Wireshark: análise de tráfego de rede.
- UEFITool: inspeção de imagens de firmware UEFI.

Essas ferramentas não são instaladas pelo script inicial. Devem ser
obtidas de fontes oficiais e configuradas conforme o ambiente.

## Limitações

Uma ISO do Windows normalmente contém binários, recursos, drivers,
metadados e componentes de instalação; não contém o código-fonte
completo do sistema operacional.

Engenharia reversa pode ajudar a entender formatos, comportamentos e
interfaces, mas não garante recuperar o código-fonte original.

## Segurança e autorização

Analise somente arquivos que você tenha autorização para examinar.
Use máquinas virtuais e amostras isoladas quando investigar executáveis
desconhecidos. Não execute amostras suspeitas no sistema principal.
