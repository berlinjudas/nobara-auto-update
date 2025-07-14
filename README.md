# Nobara Linux Auto Update Script

Ein automatisches Update-Script für Nobara Linux, das sowohl System-Pakete über `nobara-sync` als auch Flatpak-Anwendungen (System und User) aktualisiert und eine Desktop-Benachrichtigung sendet.

## Features

- 🔄 Automatische Updates von Nobara System-Paketen über `nobara-sync`
- 📦 Automatische Updates von System- und User-Flatpaks
- 📝 Detaillierte Logging-Funktionalität
- 🔔 Desktop-Benachrichtigungen nach dem Update
- ⚡ Wird automatisch beim Systemstart ausgeführt
- 🛡️ Läuft sicher als root mit korrekter User-Erkennung

## Installation

### 1. Script herunterladen

```bash
# Klonen Sie das Repository
git clone https://github.com/IHR_USERNAME/nobara-auto-update.git
cd nobara-auto-update

# Oder laden Sie das Script direkt herunter
wget https://raw.githubusercontent.com/IHR_USERNAME/nobara-auto-update/main/nobara-update-with-flatpak.sh
```

### 2. Script installieren

```bash
# Script ausführbar machen
chmod +x nobara-update-with-flatpak.sh

# Script nach /usr/local/bin kopieren
sudo cp nobara-update-with-flatpak.sh /usr/local/bin/

# Berechtigung setzen
sudo chmod +x /usr/local/bin/nobara-update-with-flatpak.sh
```

### 3. Systemd Service erstellen

Erstellen Sie einen systemd Service, der beim Systemstart ausgeführt wird:

```bash
sudo nano /etc/systemd/system/nobara-auto-update.service
```

Fügen Sie folgenden Inhalt ein:

```ini
[Unit]
Description=Nobara Auto Update on Boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nobara-update-with-flatpak.sh
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 4. Service aktivieren

```bash
# Systemd neu laden
sudo systemctl daemon-reload

# Service aktivieren (wird automatisch beim Systemstart ausgeführt)
sudo systemctl enable nobara-auto-update.service

# Status überprüfen
sudo systemctl status nobara-auto-update.service
```

## Manueller Test

Sie können das Script manuell testen:

```bash
# Als root ausführen
sudo /usr/local/bin/nobara-update-with-flatpak.sh

# Log-Datei anzeigen (der Pfad wird am Ende des Scripts ausgegeben)
cat /tmp/nobara-update-YYYYMMDD-HHMMSS.log
```

## Logs anzeigen

```bash
# Service-Logs anzeigen
sudo journalctl -u nobara-auto-update.service

# Nächste Ausführung nach Neustart überprüfen
sudo systemctl status nobara-auto-update.service
```

## Deinstallation

```bash
# Service stoppen und deaktivieren
sudo systemctl disable nobara-auto-update.service

# Service-Datei entfernen
sudo rm /etc/systemd/system/nobara-auto-update.service

# Script entfernen
sudo rm /usr/local/bin/nobara-update-with-flatpak.sh

# Systemd neu laden
sudo systemctl daemon-reload
```