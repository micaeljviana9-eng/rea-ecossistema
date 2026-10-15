$ErrorActionPreference = "Continue"

Write-Host "=== Preparação do ambiente de engenharia reversa ===" -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: winget não encontrado. Atualize o App Installer pela Microsoft Store."
    exit 1
}

$packages = @(
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "Python.Python.3.13"; Name = "Python" },
    @{ Id = "7zip.7zip"; Name = "7-Zip" },
    @{ Id = "Microsoft.OpenJDK.21"; Name = "Java JDK 21" }
)

foreach ($package in $packages) {
    Write-Host "`n=== Instalando $($package.Name) ===" -ForegroundColor Yellow

    winget install --id $package.Id `
        --exact `
        --source winget `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "A instalação de $($package.Name) falhou ou precisa de atenção."
    }
}

Write-Host "`nVerifique as instalações abrindo um novo terminal."
Write-Host "Este script não instala Ghidra, ILSpy ou wimlib."
Write-Host "Consulte docs/engenharia-reversa.md para as próximas etapas."
