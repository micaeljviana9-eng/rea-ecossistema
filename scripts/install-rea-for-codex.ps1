[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $HOME 'REA\rea-ecossistema'),
    [switch]$IncludeReleaseArchives
)
$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/micaeljviana9-eng/rea-ecossistema.git'
$SkillName = 'rea-ecossistema'
$SkillSource = Join-Path $PSScriptRoot '..\.agents\skills\rea-ecossistema'
$Downloader = Join-Path $PSScriptRoot 'download-for-agents.ps1'

if (-not (Test-Path $Downloader)) { throw "Downloader não encontrado: $Downloader" }
if (-not (Test-Path (Join-Path $SkillSource 'SKILL.md'))) { throw "Skill não encontrada: $SkillSource" }

$downloadArgs = @{ Destination = $Destination }
if ($IncludeReleaseArchives) { $downloadArgs.IncludeReleaseArchives = $true }
& $Downloader @downloadArgs
if ($LASTEXITCODE -ne 0) { throw 'Falha no download do REA.' }

$RepoRoot = (Resolve-Path $Destination).Path
$SkillTarget = Join-Path $HOME ".agents\skills\$SkillName"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $SkillTarget) | Out-Null
if (Test-Path $SkillTarget) {
    $backup = "$SkillTarget.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Move-Item -LiteralPath $SkillTarget -Destination $backup
    Write-Host "Skill anterior preservada em: $backup"
}
Copy-Item -LiteralPath $SkillSource -Destination $SkillTarget -Recurse

[Environment]::SetEnvironmentVariable('REA_HOME', $RepoRoot, 'User')
$env:REA_HOME = $RepoRoot

Write-Host ''
Write-Host 'Instalação do REA para agentes concluída.' -ForegroundColor Green
Write-Host "REA_HOME: $RepoRoot"
Write-Host "Skill global: $SkillTarget\SKILL.md"
Write-Host 'A skill fica disponível para Codex e outros agentes que leem ~/.agents/skills.'
Write-Host 'Reinicie o Codex se a skill não aparecer imediatamente.'
Write-Host 'Os arquivos compactados da release só são baixados quando -IncludeReleaseArchives é informado.'