#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Dynamic Shell Script Menu Selector
# =================================================================

# Warna ANSI untuk estetika menu
GREEN='\e[1;32m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
RESET='\e[0m'

# Mendapatkan nama file skrip ini sendiri agar tidak ikut masuk ke dalam menu
SCRIPT_NAME=$(basename "$0")

# Mengumpulkan semua file .sh di folder saat ini ke dalam sebuah Array (Kecuali skrip ini)
SCRIPTS=()
for file in *.sh; do
    # Pastikan file ada dan bukan skrip ini sendiri
    if [ -f "$file" ] && [ "$file" != "$SCRIPT_NAME" ]; then
        SCRIPTS+=("$file")
    fi
done

clear
echo -e "${CYAN}=====================================================${RESET}"
echo -e "${CYAN}             KAPTEN NEMO SCRIPT LAUNCHER             ${RESET}"
echo -e "${CYAN}=====================================================${RESET}"

# Cek apakah ada skrip .sh lain di folder tersebut
TOTAL_SCRIPTS=${#SCRIPTS[@]}
if [ "$TOTAL_SCRIPTS" -eq 0 ]; then
    echo -e "${RED}[X] Tidak ditemukan file .sh lain di folder ini!${RESET}"
    echo -e "${CYAN}=====================================================${RESET}"
    exit 1
fi

# Tampilkan daftar file .sh sebagai menu otomatis berbasis angka
echo -e "${BLUE}[*] Silakan pilih skrip yang ingin Anda jalankan:${RESET}\n"
for i in "${!SCRIPTS[@]}"; do
    # Indeks array dimulai dari 0, tambahkan 1 agar menu dimulai dari angka 1
    echo -e "  ${GREEN}$((i+1)).${RESET} ${SCRIPTS[$i]}"
done
echo -e "  ${RED}0.${RESET} Keluar"

echo -e "\n${CYAN}=====================================================${RESET}"

# Minta input pilihan dari pengguna
while true; do
    read -p "Masukkan pilihan angka Anda (0-$TOTAL_SCRIPTS): " CHOICE
    
    # Validasi input: pastikan hanya berupa angka
    if [[ ! "$CHOICE" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}[!] Input salah! Masukkan berupa angka.${RESET}"
        continue
    fi
    
    # Opsi keluar
    if [ "$CHOICE" -eq 0 ]; then
        echo -e "${YELLOW}Keluar dari program. Terima kasih!${RESET}"
        exit 0
    fi
    
    # Validasi range angka pilihan
    if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$TOTAL_SCRIPTS" ]; then
        # Ambil nama file berdasarkan indeks array (dikurangi 1 karena indeks mulai dari 0)
        SELECTED_SCRIPT="${SCRIPTS[$((CHOICE-1))]}"
        
        echo -e "\n${GREEN}[✓] Menjalankan: $SELECTED_SCRIPT...${RESET}"
        echo -e "${BLUE}-----------------------------------------------------${RESET}\n"
        
        # Berikan izin eksekusi otomatis jika belum diatur, lalu jalankan skripnya
        chmod +x "$SELECTED_SCRIPT"
        ./"$SELECTED_SCRIPT"
        
        echo -e "\n${BLUE}-----------------------------------------------------${RESET}"
        echo -e "${GREEN}[✓] Eksekusi $SELECTED_SCRIPT selesai.${RESET}"
        break
    else
        echo -e "${RED}[!] Angka di luar jangkauan menu. Silakan coba lagi.${RESET}"
    fi
done
