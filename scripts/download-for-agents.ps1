[CmdletBinding()]
param(
    [string]$Destination = (Join-Path (Get-Location) "rea-ecossistema"),
    [switch]$IncludeReleaseArchives
)
$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/micaeljviana9-eng/rea-ecossistema.git"
$Branch = "main"

foreach ($cmd in @("git")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { throw "Instale Git for Windows antes de continuar." }
}
try { git lfs version | Out-Null } catch { throw "Git LFS não está instalado. Instale Git LFS e execute novamente." }

$Parent = Split-Path -Parent $Destination
if ($Parent) { New-Item -ItemType Directory -Force -Path $Parent | Out-Null }

if (-not (Test-Path (Join-Path $Destination ".git"))) {
    git clone --branch $Branch --recurse-submodules $RepoUrl $Destination
    if ($LASTEXITCODE -ne 0) { throw "Falha ao clonar o repositório." }
} else {
    $origin = git -C $Destination remote get-url origin
    if ($origin -ne $RepoUrl) { throw "A pasta de destino já é outro repositório: $origin" }
    git -C $Destination fetch --prune origin
    if ($LASTEXITCODE -ne 0) { throw "Falha ao atualizar refs do Git." }
    git -C $Destination switch $Branch
    if ($LASTEXITCODE -ne 0) { throw "Falha ao selecionar a branch $Branch." }
    git -C $Destination pull --ff-only origin $Branch
    if ($LASTEXITCODE -ne 0) { throw "Há alterações locais ou conflito; preserve-as e resolva antes de atualizar." }
}
git -C $Destination lfs install --local
if ($LASTEXITCODE -ne 0) { throw "Falha ao configurar Git LFS." }
git -C $Destination lfs pull origin $Branch
if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar objetos Git LFS. O checkout pode conter ponteiros incompletos." }
git -C $Destination submodule sync --recursive
git -C $Destination submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { throw "Falha ao inicializar submódulos." }

if ($IncludeReleaseArchives) {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/micaeljviana9-eng/rea-ecossistema/releases/tags/source-archives-2026-10-14"
    $archiveDir = Join-Path $Destination "_downloads/source-archives"
    New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null
    foreach ($asset in $release.assets) {
        $target = Join-Path $archiveDir $asset.name
        if (-not (Test-Path $target)) {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $target
        }
    }
    $sums = Join-Path $archiveDir "SHA256SUMS.txt"
    if (Test-Path $sums) {
        foreach ($line in Get-Content $sums) {
            if ($line -match '^([0-9a-fA-F]{64})\s+\*?(.+)$') {
                $file = Join-Path $archiveDir $Matches[2].Trim()
                if (Test-Path $file) {
                    $actual = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLowerInvariant()
                    if ($actual -ne $Matches[1].ToLowerInvariant()) { throw "Hash SHA-256 divergente: $file" }
                }
            }
        }
    }
}
Write-Host "Download concluído: $Destination"
Write-Host "Branch: $Branch | Git LFS: sincronizado | Submódulos: inicializados"
