#!/bin/bash
# /usr/local/bin/nobara-update-with-flatpak.sh

LOG_FILE="/tmp/nobara-update-$(date +%Y%m%d-%H%M%S).log"
NOTIFICATION_FILE="/tmp/nobara-update-notification.txt"

# Finde den echten Benutzer (nicht root)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    # Fallback: Ermittle den ersten normalen Benutzer (nicht root)
    REAL_USER=$(awk -F: '$3 >= 1000 && $3 < 65534 && $1 != "nobody" {print $1; exit}' /etc/passwd)
    if [ -z "$REAL_USER" ]; then
        echo "Error: Konnte keinen gültigen Benutzer ermitteln" >> "$LOG_FILE"
        exit 1
    fi
fi

# Finde das Home-Verzeichnis des Benutzers
USER_HOME=$(eval echo ~$REAL_USER)

echo "Starting Nobara and Flatpak updates..." > "$LOG_FILE"
echo "Real user: $REAL_USER, Home: $USER_HOME" >> "$LOG_FILE"

# Zähle verfügbare Updates vor dem Update
AVAILABLE_SYSTEM_FLATPAKS=$(flatpak remote-ls --updates --system 2>/dev/null | wc -l)
# User-Flatpaks ohne sudo prüfen
AVAILABLE_USER_FLATPAKS=$(runuser -l "$REAL_USER" -c 'flatpak remote-ls --updates --user 2>/dev/null | wc -l')
echo "Available System Flatpak updates: $AVAILABLE_SYSTEM_FLATPAKS" >> "$LOG_FILE"
echo "Available User Flatpak updates: $AVAILABLE_USER_FLATPAKS" >> "$LOG_FILE"

# Führe nobara-sync aus
echo "Running nobara-sync..." >> "$LOG_FILE"
export DISPLAY=
export XAUTHORITY=
/usr/bin/nobara-sync cli >> "$LOG_FILE" 2>&1

# Führe Flatpak Updates aus (System und User)
echo "Updating System Flatpaks..." >> "$LOG_FILE"
flatpak update -y --noninteractive --system >> "$LOG_FILE" 2>&1

echo "Updating User Flatpaks..." >> "$LOG_FILE"
# User-Flatpaks mit runuser statt sudo aktualisieren
runuser -l "$REAL_USER" -c 'flatpak update -y --noninteractive --user' >> "$LOG_FILE" 2>&1

# Sammle Informationen für die Benachrichtigung
SYSTEM_UPDATES=$(grep -i "upgraded\|installed\|updated" "$LOG_FILE" | grep -v flatpak | wc -l)

# Bessere Erkennung der aktualisierten Flatpaks
SYSTEM_FLATPAK_UPDATED=$(grep -A 20 "Updating System Flatpaks" "$LOG_FILE" | grep -E "Updated|Installing" | grep -o "[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*" | sort | uniq)
USER_FLATPAK_UPDATED=$(grep -A 20 "Updating User Flatpaks" "$LOG_FILE" | grep -E "Updated|Installing" | grep -o "[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*\.[a-zA-Z0-9._-]*" | sort | uniq)

SYSTEM_FLATPAK_COUNT=$(echo "$SYSTEM_FLATPAK_UPDATED" | grep -v "^$" | wc -l)
USER_FLATPAK_COUNT=$(echo "$USER_FLATPAK_UPDATED" | grep -v "^$" | wc -l)
TOTAL_FLATPAK_COUNT=$((SYSTEM_FLATPAK_COUNT + USER_FLATPAK_COUNT))

# Erstelle Benachrichtigungstext
if [ "$SYSTEM_UPDATES" -gt 0 ] || [ "$TOTAL_FLATPAK_COUNT" -gt 0 ]; then
    echo "Nobara Update abgeschlossen!" > "$NOTIFICATION_FILE"
    echo "📦 System-Pakete: $SYSTEM_UPDATES aktualisiert" >> "$NOTIFICATION_FILE"
    echo "📱 Flatpaks: $TOTAL_FLATPAK_COUNT aktualisiert ($SYSTEM_FLATPAK_COUNT System, $USER_FLATPAK_COUNT User)" >> "$NOTIFICATION_FILE"
    
    if [ "$SYSTEM_FLATPAK_COUNT" -gt 0 ]; then
        echo "" >> "$NOTIFICATION_FILE"
        echo "System Flatpaks:" >> "$NOTIFICATION_FILE"
        echo "$SYSTEM_FLATPAK_UPDATED" | sed 's/.*\.\([^.]*\)$/• \1/' >> "$NOTIFICATION_FILE"
    fi
    
    if [ "$USER_FLATPAK_COUNT" -gt 0 ]; then
        echo "" >> "$NOTIFICATION_FILE"
        echo "User Flatpaks:" >> "$NOTIFICATION_FILE"
        echo "$USER_FLATPAK_UPDATED" | sed 's/.*\.\([^.]*\)$/• \1/' >> "$NOTIFICATION_FILE"
    fi
else
    echo "Keine Updates verfügbar" > "$NOTIFICATION_FILE"
fi

# Sende Benachrichtigung
NOTIFICATION_TEXT=$(cat "$NOTIFICATION_FILE")
sleep 5
systemd-run --machine="$REAL_USER@.host" --user --setenv=DISPLAY=:0 \
    notify-send "Nobara Update ✅" "$NOTIFICATION_TEXT" \
    --icon=software-update-available --expire-time=20000

# Logge Ergebnis
logger "Nobara sync and Flatpak updates completed - System: $SYSTEM_UPDATES, System Flatpaks: $SYSTEM_FLATPAK_COUNT, User Flatpaks: $USER_FLATPAK_COUNT"

# Cleanup
rm -f "$NOTIFICATION_FILE"
# Behalte Log-Datei für Debugging
echo "Update completed. Log saved to: $LOG_FILE"