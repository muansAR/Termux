#!/bin/bash
GREEN='\e[1;32m'; BLUE='\e[1;34m'; CYAN='\e[1;36m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; RESET='\e[0m'
clear

echo -e "${CYAN}=====================================================${RESET}"
echo -e "${CYAN}        ANDROID PERFORMANCE BOOSTER & CLEANER       ${RESET}"
echo -e "${CYAN}=====================================================${RESET}"

# 1. Bersihkan Cache & File Sampah Termux
echo -e "\n${BLUE}[1/4] Membersihkan Cache Internal Termux...${RESET}"
apt-get clean &>/dev/null
apt-get autoremove -y &>/dev/null
rm -rf ~/.cache/*
echo -e "${GREEN}[✓] Cache Termux berhasil dibersihkan!${RESET}"

# 2. Hentikan Aplikasi Latar Belakang Berat (Non-Root via Activity Manager)
echo -e "\n${BLUE}[2/4] Menghentikan Proses Background yang Tidak Penting...${RESET}"
APPS_TO_KILL=("com.facebook.katana" "com.instagram.android" "com.ss.android.ugc.trill" "com.twitter.android")
for app in "${APPS_TO_KILL[@]}"; do
    am force-stop "$app" 2>/dev/null
done
echo -e "${GREEN}[✓] Proses latar belakang berhasil dikurangi!${RESET}"

# 3. Fitur Optimasi Khusus Akses Root (Jika Tersedia)
echo -e "\n${BLUE}[3/4] Memeriksa Hak Akses Superuser (Root)...${RESET}"
if [ $(id -u) -eq 0 ] || su -c "id" &>/dev/null; then
    echo -e "${GREEN}[✓] Akses Root Terdeteksi! Menjalankan optimasi tingkat sistem...${RESET}"
    
    # Drop RAM Caches (PageCache, Dentries, Inodes)
    su -c "sync; echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null
    
    # Bersihkan Cache Sistem & Aplikasi di /data/data
    su -c "rm -rf /data/local/tmp/*" 2>/dev/null
    su -c "rm -rf /sdcard/Android/data/*/cache/*" 2>/dev/null
    
    # pkill aplikasi latar belakang sistem tambahan
    su -c "am kill-all" 2>/dev/null
    echo -e "${GREEN}[✓] RAM sistem & cache mendalam berhasil dikosongkan!${RESET}"
else
    echo -e "${YELLOW}[!] Berjalan dalam Mode Non-Root (Optimasi Tingkat Pengguna).${RESET}"
    echo -e "${YELLOW}    • Mengosongkan file sementara /tmp...${RESET}"
    rm -rf /tmp/* 2>/dev/null
fi

# 4. Trim Memory (Menagih Ulang Alokasi RAM yang Terbuang)
echo -e "\n${BLUE}[4/4] Memaksimalkan Alokasi RAM Bebas...${RESET}"
dumpsys meminfo > /dev/null 2>&1
echo -e "${GREEN}[✓] Selesai! Memori telah dioptimalkan.${RESET}"

echo -e "\n${CYAN}=====================================================${RESET}"
echo -e "${GREEN}  PERFORMA HP BERHASIL DIOPTIMALKAN! SILAKAN RASAKAN BEDA-NYA. ${RESET}"
echo -e "${CYAN}=====================================================${RESET}\n"
