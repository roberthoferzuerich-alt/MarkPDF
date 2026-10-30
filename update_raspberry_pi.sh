#!/bin/bash
# ==============================================================================
# MarkPDF (pdf_writer) Updater für Raspberry Pi 5 (Pironman)
# Lädt die frisch via GitHub Actions kompilierte WebApp herunter.
# ==============================================================================

set -e

WEB_DIR="/var/www/pdf_writer"
REPO_URL="https://github.com/roberthoferzuerich-alt/MarkPDF.git"
BRANCH="web-release"

echo "=========================================================="
echo "  MarkPDF Updater (Raspberry Pi 5)                        "
echo "=========================================================="

# 1. Prüfen, ob Verzeichnis bereits existiert und ein Git-Repository ist
if [ ! -d "$WEB_DIR/.git" ]; then
    echo "[1/3] Erstinstallation: Klone Branch '$BRANCH' nach $WEB_DIR..."
    sudo rm -rf "$WEB_DIR"
    sudo git clone -b "$BRANCH" "$REPO_URL" "$WEB_DIR"
else
    echo "[1/3] Aktualisierung: Ziehe neueste Version von GitHub..."
    cd "$WEB_DIR"
    sudo git fetch origin "$BRANCH"
    sudo git reset --hard "origin/$BRANCH"
fi

# 2. Berechtigungen für Nginx (www-data) sicherstellen
echo "[2/3] Setze Dateiberechtigungen für Nginx..."
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

# 3. Nginx neu laden (falls Konfiguration geändert wurde)
if command -v systemctl >/dev/null 2>&1; then
    echo "[3/3] Nginx neu laden..."
    sudo systemctl reload nginx || true
fi

IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "deine-pi-ip")
echo ""
echo "=========================================================="
echo "  Update erfolgreich abgeschlossen!"
echo "  App im Browser aufrufen:"
echo "  -> http://$IP_ADDR:8048/"
echo "  -> http://pironman.local:8048/ (falls mDNS aktiv)"
echo "=========================================================="
