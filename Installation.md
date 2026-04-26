AceOS Installer Guide
What is an Immutable System?

An immutable Linux system is a system where core parts of the operating system cannot be modified during normal use. Important directories like /usr are read-only or controlled by special tools.

Examples include:

Bazzite
Fedora Silverblue

On these systems:

You cannot freely install or remove system packages
Changes require special tools such as rpm-ostree
Standard install scripts often fail

This installer is designed for standard (mutable) Linux systems and will not work correctly on immutable ones.

Supported Systems
Arch Linux
Debian / Ubuntu
Fedora

Not supported:

Immutable systems (Bazzite, Silverblue, etc.)

If you run it on an unsupported system, it will display:

Hi, you're on an unsupported distro  
Your system is not compatible, sorry!
1. Download the repository
Option A — Clone with Git
git clone https://github.com/AlMonDdevV/AceOS-hijack-tool.git
cd AceOS-hijack-tool
Option B — Download ZIP
Go to: https://github.com/AlMonDdevV/AceOS-hijack-tool
Click Code → Download ZIP
Extract the ZIP file
Open a terminal inside the extracted folder
2. Required files

Make sure the folder contains:

install.sh
ascii-art-text.png

If the PNG file is missing, boot image setup will be skipped.

3. Make the script executable

Run:

chmod +x install.sh
4. Run the installer
./install.sh
5. Installer behavior

The script will:

Detect your system

Only Arch, Debian, and Fedora are supported.

Ask about your desktop environment
Keep current desktop environment? (y/n)
y → keeps your current desktop
n → installs Cinnamon
Show compatibility warning

Example:

WARNING!
Some apps from GNOME may not be fully supported on Cinnamon.

Then:

Remove these packages? (y/n)
Install required packages
Fastfetch (system information tool)
Apply AceOS branding
Sets hostname to AceOS
Applies custom Fastfetch ASCII logo
Adds system-wide Fastfetch config
Install boot assets

Copies:

ascii-art-text.png

to:

/usr/share/aceos/
Apply GRUB branding

Updates GRUB to display:

AceOS
6. Reboot

After installation, reboot the system:

reboot
Troubleshooting
Script will not run

Make sure you use:

./install.sh

Run:

chmod +x install.sh
Fastfetch still shows default logo

Run:

fastfetch --config /etc/fastfetch/config.jsonc
Cinnamon did not install

Install manually:

Arch
sudo pacman -S cinnamon
Debian
sudo apt install cinnamon-desktop-environment
Fedora
sudo dnf groupinstall "Cinnamon Desktop"
GRUB not updated

Run manually:

Arch
sudo grub-mkconfig -o /boot/grub/grub.cfg
Debian
sudo update-grub
Fedora
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Notes
This script does not create a full Linux distribution
It applies branding and installs packages
It does not modify the kernel or core system
Repository

https://github.com/AlMonDdevV/AceOS-hijack-tool

You can extend this project by editing install.sh to support more systems or add more features.
