#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Gemini GUI Dialog Engine v2.5 (Anti-HTML & JQ Secured)
# =================================================================

# Memastikan komponen utama terpasang di Termux
if ! command -v dialog &> /dev/null || ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    clear
    echo "Memasang komponen GUI Dialog, Curl, dan JQ..."
    pkg update -y && pkg install dialog curl jq -y
fi

TARGET_DIR="$HOME/Termux"
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

RESP_FILE="$TARGET_DIR/.gemini_resp.txt"
DATA_FILE="$TARGET_DIR/.gemini_data.json"

while true; do
    # 1. Kotak Input GUI Dialog
    PERTANYAAN=$(dialog --backtitle "KAPTEN NEMO AI" \
                        --title " GEMINI AI NATIVE GUI v2.5 " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "$RESP_FILE" "$DATA_FILE"
        exit 0
    fi

    # ⚠️ PENTING: BUAT API KEY BARU DI GOOGLE AI STUDIO DAN MASUKKAN DI SINI
    API_KEY="MASUKKAN_API_KEY_BARU_ANDA_DISINI"

    # 2. Proses Pengiriman Request & Animasi Loading Gauge
    (
        echo 20
        # Menggunakan JQ untuk menyusun objek JSON agar aman dari karakter enter/petik ganda
        jq -n --arg msg "$PERTANYAAN" '{"contents": [{"parts": [{"text": $msg}]}]}' > "$DATA_FILE"
        
        echo 60
        # Menggunakan Endpoint Model v2.5 Terbaru yang Stabil dan Aktif
        curl -s -X POST "https://googleapis.com" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Google Gemini AI..." 8 55 0

    # 3. Penyaringan dan Ekstraksi Proteksi HTML
    if [ -s "$RESP_FILE" ]; then
        
        # Deteksi apakah server membalas dengan Dokumen HTML (Error server)
        if grep -q -E "HTML|html|DOCTYPE" "$RESP_FILE"; then
            JAWABAN="GOOGLE AUTH ERROR (HTML Detected)!\n\nKemungkinan Besar:\n1. API Key lama Anda sudah diblokir/hangus oleh Google karena bocor.\n2. Koneksi internet Anda diblokir oleh provider.\n\nSolusi:\nSilakan buat API Key BARU di Google AI Studio lalu pasang kembali."
        else
            # Jika respon berupa JSON valid, urai menggunakan JQ secara akurat
            JAWABAN=$(jq -r '.candidates[0].content.parts[0].text' "$RESP_FILE" 2>/dev/null)
            
            # Jika JQ mengembalikan nilai kosong atau null, cek struktur pesan error JSON
            if [ "$JAWABAN" == "null" ] || [ -z "$JAWABAN" ]; then
                ERR_MSG=$(jq -r '.error.message' "$RESP_FILE" 2>/dev/null)
                ERR_STATUS=$(jq -r '.error.status' "$RESP_FILE" 2>/dev/null)
                
                if [ "$ERR_MSG" != "null" ] && [ ! -z "$ERR_MSG" ]; then
                    JAWABAN="GOOGLE API ERROR!\nStatus: $ERR_STATUS\nPesan: $ERR_MSG"
                else
                    JAWABAN="RESPON ERROR TIDAK DIKETAHUI:\n$(cat "$RESP_FILE" | head -c 300)"
                fi
            fi
        fi
    else
        JAWABAN="Error: Jaringan terputus. Tidak ada data yang diterima dari server Google."
    fi

    # 4. Menampilkan Hasil Jawaban atau Info Solusi ke Layar GUI
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN / DEBUG INFO " \
           --msgbox "$JAWABAN" 22 72
done
