#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Ultra-Lightweight Gemini GUI Dialog for Termux (FIXED PIPE)
# =================================================================

# Memastikan pustaka dialog visual dan curl terpasang
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog dan Curl..."
    pkg update -y && pkg install dialog curl -y
fi

# Lokasi file penyimpanan sementara untuk respon
RESP_FILE="$HOME/.gemini_resp.txt"
DATA_FILE="$HOME/.gemini_data.json"

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
        rm -f "$RESP_FILE" "$DATA_FILE"
        exit 0
    fi

    # Masukkan API Key Gemini Anda di bawah ini
    API_KEY="GANTI_DENGAN_API_KEY_ANDA"

    # 2. Menampilkan Animasi Loading Sembari Mengirim Data (Tanpa Pipe Konflik)
    (
        echo 10
        # Format payload JSON ke file terpisah agar aman dari karakter aneh/spasi
        cat <<EOF > "$DATA_FILE"
{
  "contents": [{
    "parts":[{
      "text": "$PERTANYAAN"
    }]
  }]
}
EOF
        echo 50
        # Eksekusi CURL murni tanpa pipe langsung di dalam subshell loading
        curl -s -X POST "https://googleapis.com" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Membaca dan Menyaring Hasil Jawaban Menggunakan SED (Lebih Stabil dari Grep)
    if [ -s "$RESP_FILE" ]; then
        # Menggunakan sed untuk mengambil teks di dalam tag "text": "..." secara akurat
        JAWABAN=$(sed -n 's/.*"text": "\([^"]*\)".*/\1/p' "$RESP_FILE")
        
        # Jika sed menghasilkan teks kosong karena format JSON bertingkat, bersihkan format baris baru
        if [ -z "$JAWABAN" ]; then
            JAWABAN=$(grep -o '"text": "[^"]*' "$RESP_FILE" | head -n 1 | cut -d'"' -f4)
        fi
        
        # Jika tetap kosong atau server mengembalikan error info
        if [ -z "$JAWABAN" ]; then
            JAWABAN="Sistem mendeteksi error dari Google AI Studio. Pastikan API Key Anda aktif dan kuota gratisan tidak habis."
        fi
    else
        JAWABAN="Error: Tidak ada data dari server. Periksa koneksi internet HP Anda."
    fi

    # 4. Menampilkan Jawaban dalam Kotak Pesan Visual GUI yang Rapi
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN GEMINI AI " \
           --msgbox "$JAWABAN" 22 72
done
