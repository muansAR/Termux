#!/bin/bash
<<<<<<< HEAD

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Gemini GUI Dialog Engine with JQ Parser (Anti-Error)
# =================================================================

# Memastikan komponen utama terpasang di Termux
=======
>>>>>>> 6ccdc7b (up)
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog, Curl, dan JQ..."
    pkg update -y && pkg install dialog curl jq -y
fi
<<<<<<< HEAD

TARGET_DIR="$HOME/Termux"
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

RESP_FILE="$TARGET_DIR/.gemini_resp.txt"
DATA_FILE="$TARGET_DIR/.gemini_data.json"

while true; do
    # 1. Kotak Input GUI Dialog
    PERTANYAAN=$(dialog --backtitle "KAPTEN NEMO AI" \
                        --title " GEMINI AI NATIVE GUI " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
=======
TARGET_DIR="\$HOME/Termux"
if [ ! -d "\$TARGET_DIR" ]; then mkdir -p "\$TARGET_DIR"; fi
RESP_FILE="\$TARGET_DIR/.gemini_resp.txt"
DATA_FILE="\$TARGET_DIR/.gemini_data.json"
while true; do
    PERTANYAAN=\$(dialog --backtitle "KAPTEN NEMO AI" --title " GEMINI AI NATIVE GUI " --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 3>&1 1>&2 2>&3)
    if [ \$? -ne 0 ] || [ -z "\$PERTANYAAN" ]; then
>>>>>>> 6ccdc7b (up)
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "\$RESP_FILE" "\$DATA_FILE"
        exit 0
    fi
<<<<<<< HEAD

=======
>>>>>>> 6ccdc7b (up)
    API_KEY="AQ.Ab8RN6IkBXGan1Bk23RRpU1GBSgMjvMgLrUke1E-5yFgucE7QA"
    (
        echo 20
<<<<<<< HEAD
        # Menggunakan JQ untuk menyusun JSON agar 100% aman dari karakter enter/petik ganda
        jq -n --arg msg "$PERTANYAAN" '{"contents": [{"parts": [{"text": $msg}]}]}' > "$DATA_FILE"
        
        echo 60
        curl -s -X POST "https://googleapis.com" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Ekstraksi Menggunakan JQ (Mutlak Akurat)
    if [ -s "$RESP_FILE" ]; then
        # Coba ambil jawaban sukses menggunakan query path JQ
        JAWABAN=$(jq -r '.candidates[0].content.parts[0].text' "$RESP_FILE" 2>/dev/null)
        
        # Jika teks jawaban kosong atau bernilai null, periksa blok error dari Google
        if [ "$JAWABAN" == "null" ] || [ -z "$JAWABAN" ]; then
            ERR_MSG=$(jq -r '.error.message' "$RESP_FILE" 2>/dev/null)
            ERR_STATUS=$(jq -r '.error.status' "$RESP_FILE" 2>/dev/null)
            
            if [ "$ERR_MSG" != "null" ] && [ ! -z "$ERR_MSG" ]; then
                JAWABAN="GOOGLE API ERROR!\nStatus: $ERR_STATUS\nPesan: $ERR_MSG\n\nSolusi: Periksa validitas API Key Anda di Google AI Studio."
            else
                # Jika JQ pun gagal, tampilkan seluruh isi file JSON mentah di dalam kotak pesan
                JAWABAN="RAW SERVER RESPONSE:\n$(cat "$RESP_FILE")"
=======
        jq -n --arg msg "\$PERTANYAAN" '{"contents": [{"parts": [{"text": \$msg}]}]}' > "\$DATA_FILE"
        echo 60
        curl -s -X POST "https://googleapis.com\$API_KEY" -H "Content-Type: application/json" -d @"\$DATA_FILE" > "\$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0
    if [ -s "\$RESP_FILE" ]; then
        JAWABAN=\$(jq -r '.candidates[0].content.parts[0].text' "\$RESP_FILE" 2>/dev/null)
        if [ "\$JAWABAN" == "null" ] || [ -z "\$JAWABAN" ]; then
            ERR_MSG=\$(jq -r '.error.message' "\$RESP_FILE" 2>/dev/null)
            ERR_STATUS=\$(jq -r '.error.status' "\$RESP_FILE" 2>/dev/null)
            if [ "\$ERR_MSG" != "null" ] && [ ! -z "\$ERR_MSG" ]; then
                JAWABAN="GOOGLE API ERROR!\nStatus: \$ERR_STATUS\nPesan: \$ERR_MSG\n\nSolusi: Periksa kembali validitas API Key Anda di Google AI Studio."
            else
                JAWABAN="RAW SERVER RESPONSE:\n\$(cat "\$RESP_FILE")"
>>>>>>> 6ccdc7b (up)
            fi
        fi
    else
        JAWABAN="Error: Tidak ada data yang diterima dari server. Periksa koneksi internet HP Anda."
    fi
<<<<<<< HEAD

    # 4. Menampilkan Hasil Jawaban dalam Kotak Pesan Visual GUI yang Rapi
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN / DEBUG INFO " \
           --msgbox "$JAWABAN" 22 72
=======
    dialog --backtitle "KAPTEN NEMO AI" --title " JAWABAN / DEBUG INFO " --msgbox "\$JAWABAN" 22 72
>>>>>>> 6ccdc7b (up)
done
