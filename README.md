# Nobara Linux Auto Update Script

An automatic update script for Nobara Linux that updates both system packages via `nobara-sync` and Flatpak applications (System and User) and sends desktop notifications.

## Features

- 🔄 Automatic updates of Nobara system packages via `nobara-sync`
- 📦 Automatic updates of System and User Flatpaks
- 📝 Detailed logging functionality
- 🔔 Desktop notifications after updates
- ⚡ Runs automatically on system startup
- 🛡️ Runs safely as root with correct user detection

## Installation

### 1. Download script

```bash
# Clone the repository
git clone https://github.com/berlinjudas/nobara-auto-update.git
cd nobara-auto-update

# Or download the script directly
wget https://raw.githubusercontent.com/berlinjudas/nobara-auto-update/main/nobara-update-with-flatpak.sh
```

### 2. Install script

```bash
# Make script executable
chmod +x nobara-update-with-flatpak.sh

# Copy script to /usr/local/bin
sudo cp nobara-update-with-flatpak.sh /usr/local/bin/

# Set permissions
sudo chmod +x /usr/local/bin/nobara-update-with-flatpak.sh
```

### 3. Create systemd service

Create a systemd service that runs on system startup:

```bash
sudo nano /etc/systemd/system/nobara-auto-update.service
```

Add the following content:

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

### 4. Enable service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (will run automatically on system startup)
sudo systemctl enable nobara-auto-update.service

# Check status
sudo systemctl status nobara-auto-update.service
```

## Manual testing

You can test the script manually:

```bash
# Run as root
sudo /usr/local/bin/nobara-update-with-flatpak.sh

# View log file (path is displayed at the end of the script)
cat /tmp/nobara-update-YYYYMMDD-HHMMSS.log
```

## View logs

```bash
# Show service logs
sudo journalctl -u nobara-auto-update.service

# Check next execution after reboot
sudo systemctl status nobara-auto-update.service
```

## Troubleshooting

### Script doesn't run

1. Check permissions:
   ```bash
   ls -la /usr/local/bin/nobara-update-with-flatpak.sh
   ```

2. Test service execution:
   ```bash
   sudo systemctl start nobara-auto-update.service
   sudo journalctl -u nobara-auto-update.service -f
   ```

### No notifications

1. Check if the correct user is detected:
   ```bash
   sudo /usr/local/bin/nobara-update-with-flatpak.sh
   # Look for "Real user:" in the log file
   ```

2. Test notification manually:
   ```bash
   notify-send "Test" "This is a test"
   ```

## License

MIT License - See LICENSE file for details.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.