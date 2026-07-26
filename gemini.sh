#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Ultra-Lightweight Gemini GUI Dialog for Termux (FIXED)
# =================================================================

# Memastikan pustaka dialog visual dan curl terpasang
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog dan Curl..."
    pkg update -y && pkg install dialog curl -y
fi

# Lokasi file penyimpanan sementara untuk respon
RESP_FILE="$HOME/.gemini_resp.txt"

while true; do
    # 1. Membuat Kotak Input GUI di Termux
    PERTANYAAN=$(dialog --backtitle "KAPTEN NEMO AI" \
                        --title " GEMINI AI NATIVE GUI " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    # Keluar jika tombol 'Cancel' atau 'ESC' ditekan, atau input kosong
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "$RESP_FILE"
        exit 0
    fi

    # 2. Proses Request dengan Animasi Loading Gauge Visual
    (
        echo 30
        # Masukkan API Key Gemini Anda di bawah ini
        API_KEY="GANTI_DENGAN_API_KEY_ANDA"
        
        echo 60
        # Baris curl yang sudah diperbaiki menjadi satu baris utuh tanpa pemisah yang merusak token
        curl -s -X POST "https://googleapis.com" -H "Content-Type: application/json" -d "{\"contents\": [{\"parts\":[{\"text\": \"$PERTANYAAN\"}]}]}" | grep -o '"text": "[^"]*' | grep -o '[^"]*$' > "$RESP_FILE"
        
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Membaca Hasil Jawaban
    if [ -s "$RESP_FILE" ]; then
        JAWABAN=$(cat "$RESP_FILE")
    else
        JAWABAN="Error: Gagal mendapatkan respon dari server. Periksa koneksi internet atau validitas API Key Anda."
    fi

    # 4. Menampilkan Jawaban dalam Kotak Pesan Visual GUI yang Rapi
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN GEMINI AI " \
           --msgbox "$JAWABAN" 22 72
done
