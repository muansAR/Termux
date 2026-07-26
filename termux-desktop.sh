#!/bin/bash
# ... (kode disederhanakan, pastikan memperbaiki spasi di atas)
REQUIRED_PKGS=("neofetch" "ncurses-utils" "curl")
MISSING_PKGS=()
# ... (loop pemeriksaan paket)
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    pkg update -y && pkg install "${MISSING_PKGS[@]}" -y
fi
# ... (penulisan .bashrc)
cat <<EOF > ~/.bashrc
PS1='\e[1;32mtermux@android:\e[1;34m\w\$ \e[0m'
neofetch --ascii_distro arch ...
EOF
source ~/.bashrc
