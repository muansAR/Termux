#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Network Analyzer & Auto-Dependency Installer
# =================================================================

# Konstanta Warna
GREEN='\e[1;32m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
RESET='\e[0m'

clear
echo -e "${CYAN}=====================================================${RESET}"
echo -e "${CYAN}          NETWORK SCANNER BY KAPTEN NEMO             ${RESET}"
echo -e "${CYAN}=====================================================${RESET}"

# Fungsi Pengaman: Deteksi Error & Langsung Pasang Library yang Hilang
check_and_install() {
    local cmd_name=$1
    local pkg_name=$2
    
    if ! command -v "$cmd_name" &> /dev/null; then
        echo -e "${RED}[!] Error: Library atau perintah '$cmd_name' belum terpasang!${RESET}"
        echo -e "${YELLOW}[+] Mengambil tindakan: Menginstal '$pkg_name' otomatis sekarang...${RESET}"
        
        # Eksekusi instalasi langsung saat error terdeteksi
        pkg update -y && pkg install "$pkg_name" -y
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}[X] Fatal Error: Gagal memasang '$pkg_name'. Periksa koneksi internet.${RESET}"
            exit 1
        fi
        echo -e "${GREEN}[✓] Sukses: Perintah '$cmd_name' sekarang siap digunakan.${RESET}\n"
    fi
}

# Jalankan proteksi library sebelum masuk ke fitur utama
check_and_install "curl" "curl"
check_and_install "nmap" "nmap"
check_and_install "ping" "iputils"

# 1. Cek Koneksi Internet Atas
echo -e "${BLUE}[*] Memeriksa Jalur Koneksi Internet...${RESET}"
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}[✓] Status: Terhubung ke Internet${RESET}"
else
    echo -e "${RED}[X] Status: Koneksi terputus! Sambungkan internet lalu coba lagi.${RESET}"
    exit 1
fi

# 2. Ambil Data Provider dan IP Publik
echo -e "\n${BLUE}[*] Melacak Informasi Provider...${RESET}"
IP_INFO=$(curl -s --max-time 10 https://ipapi.co)

if [ ! -z "$IP_INFO" ] && [[ "$IP_INFO" == *"ip"* ]]; then
    PUBLIC_IP=$(echo "$IP_INFO" | grep -o '"ip": "[^"]*' | grep -o '[^"]*$')
    PROVIDER=$(echo "$IP_INFO" | grep -o '"org": "[^"]*' | grep -o '[^"]*$')
    CITY=$(echo "$IP_INFO" | grep -o '"city": "[^"]*' | grep -o '[^ My]*$')
    COUNTRY=$(echo "$IP_INFO" | grep -o '"country_name": "[^"]*' | grep -o '[^"]*$')
    
    echo -e "${GREEN}    • IP Publik : ${RESET}$PUBLIC_IP"
    echo -e "${GREEN}    • Provider  : ${RESET}$PROVIDER"
    echo -e "${GREEN}    • Lokasi    : ${RESET}$CITY, $COUNTRY"
else
    echo -e "${RED}    [X] Timeout: Gagal menarik data provider.${RESET}"
fi

# 3. Analisis Jaringan Lokal & IP Admin Router
echo -e "\n${BLUE}[*] Menghitung Struktur Jaringan Lokal (LAN)...${RESET}"

IP_ADMIN=$(ip route | grep default | awk '{print $3}')
SUBNET=$(ip route | grep -v default | grep src | awk '{print $1}' | head -n 1)
MY_LOCAL_IP=$(ip route | grep -v default | grep src | awk '{print $7}' | head -n 1)

if [ -z "$IP_ADMIN" ] || [ -z "$SUBNET" ]; then
    echo -e "${RED}    [X] Error: Anda tidak terhubung ke jaringan Wi-Fi lokal.${RESET}"
else
    echo -e "${GREEN}    • IP Device Anda   : ${RESET}$MY_LOCAL_IP"
    echo -e "${YELLOW}    • IP Admin (Router): ${RESET}$IP_ADMIN"
    
    # 4. Pindai Perangkat yang Satu Koneksi
    echo -e "\n${BLUE}[*] Memindai Semua Perangkat di Jaringan ($SUBNET)...${RESET}"
    echo -e "${YELLOW}    Proses pemindaian sedang berjalan, mohon tunggu...${RESET}\n"
    
    nmap -sn "$SUBNET" | grep -E "Nmap scan report for|MAC Address" | sed "s/Nmap scan report for /  [+] IP Terdeteksi: /g" | sed "s/MAC Address: /      ↳ MAC & Brand: /g"
fi

echo -e "\n${CYAN}=====================================================${RESET}"
echo -e "${CYAN}    Copyright (c) 2026 Kapten Nemo. Selesai.          ${RESET}"
echo -e "${CYAN}=====================================================${RESET}"
