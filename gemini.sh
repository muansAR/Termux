#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Ultra-Lightweight Gemini GUI Dialog for Termux (API Loaded)
# =================================================================

# Memastikan pustaka dialog visual dan curl terpasang di Termux
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog dan Curl..."
    pkg update -y && pkg install dialog curl -y
fi

# Lokasi file penyimpanan sementara untuk respon data JSON dan teks
RESP_FILE="$HOME/.gemini_resp.txt"
DATA_FILE="$HOME/.gemini_data.json"

while true; do
    # 1. Membuat Kotak Input GUI Dialog di Termux
    PERTANYAAN=$(dialog --backtitle "KAPTEN NEMO AI" \
                        --title " GEMINI AI NATIVE GUI " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    # Keluar jika tombol 'Cancel' atau 'ESC' ditekan, atau jika input kosong
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "$RESP_FILE" "$DATA_FILE"
        exit 0
    fi

    # API Key resmi milik Anda yang sudah dikunci ke dalam sistem
    API_KEY="AQ.Ab8RN6IkBXGan1Bk23RRpU1GBSgMjvMgLrUke1E-5yFgucE7QA"

    # 2. Proses Pengiriman Request dengan Animasi Loading Gauge Visual
    (
        echo 10
        # Memformat input pertanyaan ke dalam file data JSON eksternal agar aman dari karakter aneh
        cat <<EOT > "$DATA_FILE"
{
  "contents": [{
    "parts":[{
      "text": "$PERTANYAAN"
    }]
  }]
}
EOT
        echo 50
        # Mengirimkan payload data ke server Google Gemini 1.5 Flash yang super cepat
        curl -s -X POST "https://googleapis.com" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Membaca dan Menyaring Hasil Jawaban Menggunakan Metode Ekstraksi Aman
    if [ -s "$RESP_FILE" ]; then
        # Mengambil teks jawaban utama di dalam struktur tag JSON
        JAWABAN=$(sed -n 's/.*"text": "\([^"]*\)".*/\1/p' "$RESP_FILE")
        
        # Filter cadangan jika format JSON server bertingkat atau memiliki baris baru
        if [ -z "$JAWABAN" ]; then
            JAWABAN=$(grep -o '"text": "[^"]*' "$RESP_FILE" | head -n 1 | cut -d'"' -f4)
        fi
        
        # Jika respon teks tetap kosong atau server menolak request
        if [ -z "$JAWABAN" ]; then
            JAWABAN="Sistem mendeteksi error dari Google AI Studio. Pastikan kuota gratisan API Anda tidak habis atau format teks aman."
        fi
    else
        JAWABAN="Error: Tidak ada data yang diterima dari server. Periksa koneksi internet HP Anda."
    fi

    # 4. Menampilkan Hasil Jawaban dalam Kotak Pesan Visual GUI yang Rapi dan Bisa Di-scroll
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN GEMINI AI " \
           --msgbox "$JAWABAN" 22 72
done
