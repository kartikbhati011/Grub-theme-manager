#!/bin/bash

# ==========================================
# Interactive GRUB Theme Installer
# Supports:
# Fedora
# Debian-based
# Arch-based
# ==========================================

# ===== ROOT CHECK =====
if [[ $EUID -ne 0 ]]; then
    echo "Please run with sudo"
    echo "Example: sudo ./install.sh"
    exit 1
fi

# ===== THEMES LIST =====
themes=(
"Ashveil"
"BigSur"
"bsol"
"Cyberpunk"
"CyberRe"
"dedsec"
"fallout-grub"
"grub-of-tsushima"
"kawaii-grub"
"Mechanics_grub"
"minegrub"
"redbluepill"
"Sekiro"
"terminator"
"whitesur"
"Yotsuba"
"blur-grub2"
"CartoonGirl"
"crt-amber"
"CyberpunkGRUB"
"Doraemon"
"fedora"
"hp"
"hp-victus"
"Inoue-Takina"
"Kobo-Kanaeru"
"Monika-Version"
"pentract"
"poly-dark-master"
"poly-light-master"
"SAO"
"SekiroShadow"
"Tela"
"Vimix"
"Xenlism-Fedora"
)

# ===== SHOW MENU =====
echo "=================================="
echo "       GRUB THEME MANAGER"
echo "=================================="
echo ""

for i in "${!themes[@]}"; do
    echo "$((i+1)). ${themes[$i]}"
done

echo ""
read -p "Enter theme number (1-35): " choice

# ===== VALIDATION =====
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid input!"
    exit 1
fi

if (( choice < 1 || choice > 35 )); then
    echo "Please enter number between 1-35"
    exit 1
fi

# ===== SELECT THEME =====
THEME_NAME="${themes[$((choice-1))]}"

echo ""
echo "[+] Selected Theme: $THEME_NAME"

SOURCE_DIR="./$THEME_NAME"
DEST_DIR="/usr/share/grub/themes/$THEME_NAME"
GRUB_THEME_LINE="GRUB_THEME=\"/usr/share/grub/themes/$THEME_NAME/theme.txt\""

# ===== CHECK THEME EXISTS =====
if [[ -d "$DEST_DIR" ]]; then
    echo "[+] Theme already exists in system"
else
    echo "[+] Copying theme to system..."

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Error: Theme folder '$THEME_NAME' not found in current directory!"
        exit 1
    fi

    mkdir -p /usr/share/grub/themes
    cp -r "$SOURCE_DIR" /usr/share/grub/themes/
fi

# ===== BACKUP GRUB CONFIG =====
echo "[+] Creating backup..."
cp /etc/default/grub /etc/default/grub.backup

# ===== REMOVE OLD GRUB_THEME =====
echo "[+] Updating grub config..."

sed -i '/^GRUB_THEME=/d' /etc/default/grub

# ===== ADD NEW THEME =====
echo "$GRUB_THEME_LINE" >> /etc/default/grub

# ===== UPDATE GRUB =====
echo "[+] Regenerating GRUB config..."

if grep -qi "fedora" /etc/os-release; then

    echo "[+] Fedora detected"
    grub2-mkconfig -o /boot/grub2/grub.cfg

elif grep -qiE "debian|ubuntu|zorin|mint|pop" /etc/os-release; then

    echo "[+] Debian-based distro detected"
    update-grub

elif grep -qiE "arch|manjaro|cachy|garuda" /etc/os-release; then

    echo "[+] Arch-based distro detected"
    grub-mkconfig -o /boot/grub/grub.cfg

else
    echo "[!] Unsupported distro"
    echo "Please update GRUB manually."
    exit 1
fi

echo ""
echo "=================================="
echo "[✓] Theme Installed Successfully!"
echo "Theme: $THEME_NAME"
echo "=================================="
echo ""
echo "Reboot your system to see changes."
