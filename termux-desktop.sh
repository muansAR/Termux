#!/bin/bash

# Array berisi paket/pustaka yang dibutuhkan untuk kustomisasi ini
REQUIRED_PKGS=("neofetch" "ncurses-utils" "curl")
MISSING_PKGS=()

echo "========== MENGECEK PUSTAKA SISTEM =========="

# 1. Loop untuk memeriksa pustaka yang belum terinstal
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" &> /dev/null; then
        echo "[-] Pustaka '$pkg' belum terinstal."
        MISSING_PKGS+=("$pkg")
    else
        echo "[+] Pustaka '$pkg' sudah siap."
    fi
done

# 2. Jika ada pustaka yang hilang, lakukan instalasi otomatis
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "---------------------------------------------"
    echo "Memperbarui repositori dan menginstal pustaka yang hilang: ${MISSING_PKGS[*]}..."
    echo "---------------------------------------------"
    
    # Menjalankan pembaruan senyap agar proses bersih dan otomatis berjalan
    pkg update -y && pkg install "${MISSING_PKGS[@]}" -y
    
    if [ $? -eq 0 ]; then
        echo "[✓] Semua pustaka berhasil diinstal!"
    else
        echo "[X] Terjadi kesalahan saat menginstal pustaka. Coba cek koneksi internet Anda."
        exit 1
    fi
fi

echo "========== MENERAPKAN KUSTOMISASI =========="

# 3. Tulis konfigurasi ke file .bashrc
cat << 'EOF' > ~/.bashrc
# Kustomisasi Prompt Berwarna (Hijau & Biru)
PS1='\e[1;32mtermux@android:\e[1;34m\w\$ \e[0m'

# Menampilkan Neofetch (Logo Arch + Info Penting)
neofetch --ascii_distro arch --disable gpu resolution de wm wm_theme theme icons terminal_font disk
EOF

# 4. Terapkan perubahan ke sesi aktif saat ini
source ~/.bashrc
echo "[✓] Selesai! Tampilan Termux Anda kini otomatis diperbarui."
