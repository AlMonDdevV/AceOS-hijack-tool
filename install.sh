#!/bin/bash
set -e

echo "======================================"
echo "         AceOS Installer             "
echo "======================================"

# =========================
# OS DETECTION (ROBUST)
# =========================
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect operating system."
    exit 1
fi

DISTRO="unsupported_distro_name"
SUBDISTRO="unknown"

# Arch family
if echo "$ID" | grep -qi "arch"; then
    DISTRO="arch"

# Debian family
elif echo "$ID_LIKE" | grep -qi "debian"; then
    DISTRO="debian"

# Fedora family (includes Bazzite, Nobara, Kinoite, etc.)
elif echo "$ID_LIKE" | grep -qi "fedora" || echo "$ID" | grep -qi "fedora"; then
    DISTRO="fedora"

    # Sub-distro detection
    if echo "$ID" | grep -qi "bazzite"; then
        SUBDISTRO="bazzite"
    elif echo "$ID" | grep -qi "nobara"; then
        SUBDISTRO="nobara"
    elif echo "$ID" | grep -qi "kinoite"; then
        SUBDISTRO="kinoite"
    else
        SUBDISTRO="generic-fedora"
    fi
fi

# =========================
# UNSUPPORTED CHECK
# =========================
if [ "$DISTRO" = "unsupported_distro_name" ]; then
    echo ""
    echo "======================================"
    echo " Hi, you're on an unsupported distro"
    echo " Your system is not compatible, sorry!"
    echo "======================================"
    echo ""
    exit 1
fi

echo "[*] Detected: $DISTRO ($SUBDISTRO)"

# =========================
# CINNAMON CHOICE
# =========================
read -p "Keep current desktop environment? (y/n): " KEEP_DE
INSTALL_CINNAMON=false
[[ "$KEEP_DE" =~ ^[Nn]$ ]] && INSTALL_CINNAMON=true

# =========================
# FASTFETCH INSTALL
# =========================
echo "[*] Installing Fastfetch..."

case $DISTRO in
    arch)
        sudo pacman -Syu --noconfirm fastfetch
        ;;
    debian)
        sudo apt update && sudo apt install -y fastfetch
        ;;
    fedora)
        sudo dnf install -y fastfetch
        ;;
esac

# =========================
# CINNAMON WARNING SYSTEM
# =========================
CURRENT_DE="$XDG_CURRENT_DESKTOP"

echo ""
echo "WARNING!"
echo "Some apps from $CURRENT_DE may not be fully supported on Cinnamon."
echo ""

UNSUPPORTED_PKGS=""

case "$CURRENT_DE" in
    *GNOME*)
        UNSUPPORTED_PKGS="gnome-shell gnome-software nautilus"
        ;;
    *KDE*)
        UNSUPPORTED_PKGS="plasma-desktop dolphin kdeconnect"
        ;;
    *XFCE*)
        UNSUPPORTED_PKGS="xfce4-panel xfce4-session thunar"
        ;;
    *)
        UNSUPPORTED_PKGS="unknown-packages"
        ;;
esac

echo "Potential packages affected:"
echo "$UNSUPPORTED_PKGS"
echo ""

read -p "Remove these packages? (y/n): " REMOVE_PKGS

if [[ "$REMOVE_PKGS" =~ ^[Yy]$ ]]; then
    case $DISTRO in
        arch)
            sudo pacman -Rns $UNSUPPORTED_PKGS || true
            ;;
        debian)
            sudo apt remove -y $UNSUPPORTED_PKGS || true
            ;;
        fedora)
            sudo dnf remove -y $UNSUPPORTED_PKGS || true
            ;;
    esac
fi

# =========================
# CINNAMON INSTALL
# =========================
if [ "$INSTALL_CINNAMON" = true ]; then
    echo "[*] Installing Cinnamon..."

    case $DISTRO in
        arch)
            sudo pacman -S --noconfirm cinnamon || true
            ;;
        debian)
            sudo apt install -y cinnamon-desktop-environment
            ;;
        fedora)
            sudo dnf groupinstall -y "Cinnamon Desktop"
            ;;
    esac
else
    echo "[*] Keeping current desktop."
fi

# =========================
# HOSTNAME
# =========================
echo "[*] Setting hostname → AceOS"
sudo hostnamectl set-hostname AceOS

# =========================
# FASTFETCH BRANDING
# =========================
sudo mkdir -p /etc/fastfetch

sudo tee /etc/fastfetch/aceos.ascii > /dev/null << 'EOF'
░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓████████▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
░▒▓████████▓▒░▒▓█▓▒░      ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓████████▓▒░▒▓██████▓▒░░▒▓███████▓▒░  
EOF

sudo tee /etc/fastfetch/config.jsonc > /dev/null << 'EOF'
{
  "logo": {
    "type": "file",
    "source": "/etc/fastfetch/aceos.ascii"
  },
  "modules": [
    "title",
    "os",
    "host",
    "kernel",
    "uptime",
    "cpu",
    "gpu",
    "memory",
    "disk",
    "de",
    "wm"
  ]
}
EOF

echo "alias fastfetch='fastfetch --config /etc/fastfetch/config.jsonc'" | sudo tee /etc/profile.d/aceos.sh > /dev/null

# =========================
# BOOT IMAGE FOLDER
# =========================
echo "[*] Creating boot image folder..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOT_DIR="/usr/share/aceos"

sudo mkdir -p "$BOOT_DIR"

if [ -f "$SCRIPT_DIR/ascii-art-text.png" ]; then
    sudo cp "$SCRIPT_DIR/ascii-art-text.png" "$BOOT_DIR/"
fi

# =========================
# GRUB BRANDING
# =========================
echo "[*] Applying GRUB branding..."

sudo sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="AceOS"/' /etc/default/grub || true

case $DISTRO in
    arch)
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    debian)
        sudo update-grub
        ;;
    fedora)
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        ;;
esac

# =========================
echo "======================================"
echo " AceOS installation complete"
echo "System: $DISTRO ($SUBDISTRO)"
echo "Hostname: AceOS"
echo "======================================"
echo "Reboot recommended"
