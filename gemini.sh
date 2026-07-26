#!/bin/bash
<<<<<<< HEAD

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Ultra-Lightweight Gemini GUI Dialog for Termux Folder
# =================================================================

# Memastikan komponen utama terpasang di Termux
=======
>>>>>>> 3bd1a3e (baca)
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog dan Curl..."
    pkg update -y && pkg install dialog curl -y
fi

<<<<<<< HEAD
# Alokasi folder khusus di ~/Termux
TARGET_DIR="$HOME/Termux"
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

# Lokasi file log sementara di dalam folder Termux
RESP_FILE="$TARGET_DIR/.gemini_resp.txt"
DATA_FILE="$TARGET_DIR/.gemini_data.json"

while true; do
    # 1. Membuat Kotak Input GUI Dialog
    PERTANYAAN=$(dialog --backtitle "KAPTEN NEMO AI" \
                        --title " GEMINI AI NATIVE GUI " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    # Keluar jika tombol 'Cancel', 'ESC', atau input kosong
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
=======
# Mengunci file log sementara di dalam folder aktif yang sama
RESP_FILE="\$HOME/Termux/.gemini_resp.txt"
DATA_FILE="\$HOME/Termux/.gemini_data.json"

while true; do
    PERTANYAAN=\$(dialog --backtitle "KAPTEN NEMO AI" --title " GEMINI AI NATIVE GUI " --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 3>&1 1>&2 2>&3)
    if [ \$? -ne 0 ] || [ -z "\$PERTANYAAN" ]; then
>>>>>>> 3bd1a3e (baca)
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "\$RESP_FILE" "\$DATA_FILE"
        exit 0
    fi
<<<<<<< HEAD

    # API Key resmi milik Anda
    API_KEY="AQ.Ab8RN6IkBXGan1Bk23RRpU1GBSgMjvMgLrUke1E-5yFgucE7QA"

    # 2. Proses Pengiriman Request & Animasi Loading Gauge
    (
        echo 10
        # Format payload data JSON menggunakan printf agar aman dari karakter enter/petik
        printf '{"contents":[{"parts":[{"text": "%s"}]}]}' "$PERTANYAAN" > "$DATA_FILE"
        
        echo 50
        curl -s -X POST "https://googleapis.com" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Ekstraksi Respon dan Penanganan Debug Error (Mencegah Loop)
    if [ -s "$RESP_FILE" ]; then
        # Mengambil teks jawaban sukses dari JSON
        JAWABAN=$(grep -o '"text": "[^"]*' "$RESP_FILE" | head -n 1 | cut -d'"' -f4)
        
        # Jika fomat teks kosong, periksa pesan error spesifik dari Google
        if [ -z "$JAWABAN" ]; then
            ERR_MSG=$(grep -o '"message": "[^"]*' "$RESP_FILE" | head -n 1 | cut -d'"' -f4)
            ERR_STATUS=$(grep -o '"status": "[^"]*' "$RESP_FILE" | head -n 1 | cut -d'"' -f4)
            
            if [ ! -z "$ERR_MSG" ]; then
                JAWABAN="GOOGLE API ERROR!\nStatus: $ERR_STATUS\nPesan: $ERR_MSG\n\nSolusi: Silakan periksa kembali validitas API Key Anda di Google AI Studio."
            else
                # Jika format error tidak terduga, tampilkan cuplikan teks mentah server
                JAWABAN="RESPON ERROR UNKNOWN:\n$(cat "$RESP_FILE" | head -c 300)"
=======
    API_KEY="AQ.Ab8RN6IkBXGan1Bk23RRpU1GBSgMjvMgLrUke1E-5yFgucE7QA"
    (
        echo 10
        printf '{"contents":[{"parts":[{"text": "%s"}]}]}' "\$PERTANYAAN" > "\$DATA_FILE"
        echo 50
        curl -s -X POST "https://googleapis.com\$API_KEY" -H "Content-Type: application/json" -d @"\$DATA_FILE" > "\$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0
    if [ -s "\$RESP_FILE" ]; then
        JAWABAN=\$(grep -o '"text": "[^"]*' "\$RESP_FILE" | head -n 1 | cut -d'"' -f4)
        if [ -z "\$JAWABAN" ]; then
            ERR_MSG=\$(grep -o '"message": "[^"]*' "\$RESP_FILE" | head -n 1 | cut -d'"' -f4)
            ERR_STATUS=\$(grep -o '"status": "[^"]*' "\$RESP_FILE" | head -n 1 | cut -d'"' -f4)
            if [ ! -z "\$ERR_MSG" ]; then
                JAWABAN="GOOGLE API ERROR!\nStatus: \$ERR_STATUS\nPesan: \$ERR_MSG\n\nSolusi: Silakan buat API Key BARU di Google AI Studio."
            else
                JAWABAN="RESPON ERROR UNKNOWN:\n\$(cat "\$RESP_FILE" | head -c 300)"
>>>>>>> 3bd1a3e (baca)
            fi
        fi
    else
        JAWABAN="Error: Tidak ada data yang diterima dari server. Periksa koneksi internet HP Anda."
    fi
<<<<<<< HEAD

    # 4. Menampilkan Hasil Jawaban atau Pesan Debug di Layar GUI
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN / DEBUG INFO " \
           --msgbox "$JAWABAN" 22 72
=======
    dialog --backtitle "KAPTEN NEMO AI" --title " JAWABAN / DEBUG INFO " --msgbox "\$JAWABAN" 22 72
>>>>>>> 3bd1a3e (baca)
done
