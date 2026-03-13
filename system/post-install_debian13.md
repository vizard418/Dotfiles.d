## Post-Instalacion Debian 13 (Trixie)

---

### Pre-requisitos

* **Instalacion de sudo**

```bash
su -
apt install sudo
usermod -aG sudo {USER}
```

* **Edit apt sources-list**

```bash
sudo apt edit-sources

# Ensure /etc/apt/sources.list has: main contrib non-free non-free-firmware

sudo apt update && sudo apt upgrade -y
```

* **Btrfs Snapshots (Timeshift)**

```bash
# Layout for Timeshift compatibility
df -Th

sudo mount /dev/sdaN /mnt
sudo mv /mnt/@rootfs /mnt/@

# update subvolume reference in fstab
sudo vim.tiny /etc/fstab

# change:
# subvol=@rootfs  ->  subvol=@

sudo update-grub
```

---

### Start with UI

* **Install X11 and I3 Window Manager**

```bash
sudo apt install xserver-xorg i3

# compositor for transparency and effects
sudo apt install picom

# install session manager (lightdm)
sudo apt install lightdm lightdm-gtk-greeter-settings

# edit lightdm configuration to display the user list in the greeter
sudo vim.tiny /usr/share/lightdm/lightdm.conf.d/01_debian.conf

# ensure the following setting is present or modified
# greeter-hide-users=false
# this allows the login screen to show available users

# reboot the system to start the graphical login manager
systemctl reboot
```

* **Install Sway Window Manager (Wayland)**
```bash
sudo apt install sway swaybg swaylock swayidle waybar
sudo apt install mako-notifier
sudo apt install fuzzel

# install session manager (greetd tuigreet)
sudo apt install greetd tuigreet

# greetd config
sudo vim.tiny /etc/greetd/config.toml

[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd sway"
user = "greeter"

# if need enable
sudo systemctl enable greetd
```

### Install a Terminal Emulator

* **Install xfce4-terminal**

```bash
# after logging into the graphical session (i3), a terminal emulator is required
# to continue the post-installation steps

sudo apt install xfce4-terminal

# launch the terminal from the i3 application launcher
# default shortcut: Mod+d
```

---

### Hardware, Multimedia and Connectivity

* **Firmware**

```bash
sudo apt install firmware-linux firmware-linux-nonfree firmware-iwlwifi firmware-realtek
```

* **Graphics (Vulkan / Mesa)**

```bash
sudo apt install mesa-vulkan-drivers libvulkan1 vulkan-tools
```

* **Multimedia Codecs**

```bash
sudo apt install libavcodec-extra ffmpeg ffmpegthumbnailer x264 x265
sudo apt install gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad
```

* **DVD Playback Support (Optional)**

```bash
sudo apt install libdvdnav4 libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg
```

* **Input Devices**

```bash
sudo apt install xserver-xorg-input-libinput
sudo apt install libinput-tools
sudo apt install brightnessctl
sudo apt install wireplumber
```

* **Synaptics Touchpad Driver (Optional)**

```bash
sudo apt install xserver-xorg-input-synaptics
```

* **Bluetooth Stack**

```bash
sudo apt install bluetooth
sudo apt install bluez bluez-cups bluez-tools
sudo apt install btscanner
sudo apt install python3-bluez
```

* **Android Platform Tools**

```bash
sudo apt install adb fastboot
```

---

### File Management, Filesystems and Portals

* **XDG Portal Support**

```bash
sudo apt install xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

* **External Filesystem Support**

```bash
sudo apt install exfat-fuse ntfs-3g ntfs-3g-dev
```

* **Archive and Compression Tools**

```bash
sudo apt install rar unrar zip unzip xarchiver
```

* **File Explorer (Thunar)**

```bash
sudo apt install thunar thunar-volman thunar-archive-plugin gvfs gvfs-backends
```

* **Fonts and Icons**

```bash
sudo apt install fonts-font-awesome fonts-noto-color-emoji fonts-dejavu fonts-inter
sudo apt install ttf-mscorefonts-installer
fc-cache -fv
```

---

### Applications

* **Essential Applications**

```bash
sudo apt install xfce4-terminal # terminal emulator for graphical sessions
sudo apt install vim-gtk3 # vim editor with clipboard support
sudo apt install neovim # text editor based on vim
sudo apt install mousepad # lightweight graphical text editor
sudo apt install firefox-esr # web browser
sudo apt install vlc # multimedia player
sudo apt install gammastep # screen color temperature control
sudo apt install pavucontrol # pulseaudio volume control GUI
sudo apt install brightnessctl # brightness control utility
sudo apt install playerctl # media player control from CLI
sudo apt install network-manager # network manager service
sudo apt install network-manager-gnome # nm-applet system tray
sudo apt install dex # autostart .desktop files in i3 sessions
sudo apt install lxpolkit # polkit authentication agent
sudo apt install gparted # graphical partition editor
sudo apt install timeshift # system snapshot and restore tool
sudo apt install gufw # graphical firewall manager
sudo apt install bleachbit # system cleaner
sudo apt install curl # command line data transfer tool
sudo apt install git # distributed version control
sudo apt install build-essential # compiler and development tools
sudo apt install python3-pip # python package manager
sudo apt install python3-virtualenv # python virtual environments
sudo apt install tree # directory tree viewer
sudo apt install ncal # calendar utility
sudo apt install net-tools # legacy networking utilities
sudo apt install fastfetch # system information display
sudo apt install lm-sensors # hardware monitoring
sudo apt install xmessage # simple X11 message dialog
sudo apt install x11-xserver-utils # provides xset and related utilities
sudo apt install xkb-data # keyboard layout definitions
sudo apt install wireplumber # pipewire session manager
sudo apt install pipewire # modern audio server
sudo apt install pipewire-audio # pipewire audio compatibility layer
sudo apt install zatura # CLI based pdf reader
```

* **Extra Utils**
```bash
sudo apt install weston
sudo apt install wayland-protocols
```

* **Security and Specialized Tools**

```bash
sudo apt install tor # anonymous network routing
sudo apt install proxychains # force apps through proxy
sudo apt install firejail # application sandboxing
sudo apt install nmap # network scanner
sudo apt install sqlmap # automated SQL injection testing
sudo apt install john # password cracking tool
sudo apt install hashcat # advanced password recovery
sudo apt install hydra # network login cracker
sudo apt install aircrack-ng # wireless security auditing
sudo apt install hcxtools # WPA/WPA2 capture conversion tools
sudo apt install whatweb # website fingerprinting
sudo apt install libimage-exiftool-perl # metadata analysis
sudo apt install dmitry # host information gathering
sudo apt install theharvester # OSINT email/subdomain discovery
sudo apt install dnsrecon # DNS enumeration tool
sudo apt install netcat-openbsd # TCP/UDP networking tool
sudo apt install foremost # file recovery tool
sudo apt install scalpel # filesystem carving tool
sudo apt install binwalk # firmware analysis and extraction
sudo apt install volatility # memory forensics framework
sudo apt install testdisk # partition recovery utility
sudo apt install wireshark # network protocol analyzer
```

## 8. Virtualization (KVM/QEMU)

```bash
sudo apt install -y qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virt-manager
sudo apt install spice-vdagent qemu-guest-agent
sudo apt install bridge-utils
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo systemctl enable --now libvirtd
```

## Install Flatpak
```bash
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
