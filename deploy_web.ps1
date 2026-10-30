<#
.SYNOPSIS
  Automatisches Build- und Bereitstellungsskript für pdf_writer als WebApp.
.DESCRIPTION
  Kompiliert die Flutter-App als Release-Web-Bundle und kopiert sie wahlweise
  nach Laragon (lokal) oder per SSH/SCP auf den Raspberry Pi 5 (Pironman).
.EXAMPLE
  .\deploy_web.ps1 -Target Laragon
  .\deploy_web.ps1 -Target RaspberryPi -PiHost "192.168.1.50" -PiUser "pi"
  .\deploy_web.ps1 -Target Both -PiHost "pironman.local"
#>

param(
    [ValidateSet("Laragon", "RaspberryPi", "Both", "BuildOnly")]
    [string]$Target = "Laragon",

    [string]$BaseHref = "/",

    [string]$LaragonPath = "C:\laragon\www\pdf_writer",

    [string]$PiHost = "pironman.local",
    [string]$PiUser = "pi",
    [string]$PiRemotePath = "/var/www/pdf_writer"
)

$ErrorActionPreference = "Stop"
$ProjectPath = $PSScriptRoot

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MarkPDF / pdf_writer - Web-Deployment Manager          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Ziel:      $Target" -ForegroundColor Yellow
Write-Host "Base-Href: $BaseHref" -ForegroundColor Yellow

# 1. Flutter Web Release Build
Write-Host "`n[1/3] Kompiliere Flutter Web (Release)..." -ForegroundColor Green
Set-Location -Path $ProjectPath
flutter build web --release --base-href $BaseHref

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter Web Build fehlgeschlagen!"
    exit $LASTEXITCODE
}

$BuildDir = Join-Path $ProjectPath "build\web"
if (-not (Test-Path $BuildDir)) {
    Write-Error "Build-Verzeichnis $BuildDir nicht gefunden!"
    exit 1
}

# 2. Deployment zu Laragon
if ($Target -eq "Laragon" -or $Target -eq "Both") {
    Write-Host "`n[2/3] Bereitstellung auf Laragon ($LaragonPath)..." -ForegroundColor Green
    
    if (-not (Test-Path $LaragonPath)) {
        New-Item -ItemType Directory -Path $LaragonPath -Force | Out-Null
    }

    Copy-Item -Path "$BuildDir\*" -Destination $LaragonPath -Recurse -Force

    # .htaccess für Apache SPA Routing erzeugen falls nötig
    $htaccessContent = @"
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase $BaseHref
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . ${BaseHref}index.html [L]
</IfModule>
"@
    Set-Content -Path (Join-Path $LaragonPath ".htaccess") -Value $htaccessContent -Encoding utf8

    Write-Host "  -> Erfolgreich nach Laragon kopiert!" -ForegroundColor Cyan
    Write-Host "  -> Lokal erreichbar unter: http://localhost$BaseHref" -ForegroundColor White
}

# 3. Deployment zu Raspberry Pi 5
if ($Target -eq "RaspberryPi" -or $Target -eq "Both") {
    Write-Host "`n[3/3] Bereitstellung auf Raspberry Pi 5 ($PiUser@${PiHost}:$PiRemotePath)..." -ForegroundColor Green

    Write-Host "  Erstelle Remote-Verzeichnis auf dem Pi..." -ForegroundColor Gray
    ssh "$PiUser@$PiHost" "sudo mkdir -p $PiRemotePath && sudo chown -R ${PiUser}:${PiUser} $PiRemotePath"

    Write-Host "  Kopiere Web-Dateien via SCP..." -ForegroundColor Gray
    scp -r "$BuildDir\*" "$PiUser@${PiHost}:$PiRemotePath/"

    Write-Host "  Setze Berechtigungen für www-data..." -ForegroundColor Gray
    ssh "$PiUser@$PiHost" "sudo chown -R www-data:www-data $PiRemotePath && sudo chmod -R 755 $PiRemotePath"

    Write-Host "  -> Erfolgreich auf Raspberry Pi 5 übertragen!" -ForegroundColor Cyan
    Write-Host "  -> Erreichbar unter: http://${PiHost}$BaseHref (oder Server-IP)" -ForegroundColor White
}

Write-Host "`nDeployment erfolgreich abgeschlossen!" -ForegroundColor Green
