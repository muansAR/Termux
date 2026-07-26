#!/bin/bash

# =================================================================
# Copyright (c) 2026 Kapten Nemo. All rights reserved.
# Script: Free Gemini GUI Dialog via Public Reverse Proxy (No Key)
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
                        --title " GEMINI FREE GUI (NO API KEY) " \
                        --inputbox "Masukkan pertanyaan Anda di bawah ini:" 12 65 \
                        3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ] || [ -z "$PERTANYAAN" ]; then
        clear
        echo "Aplikasi GUI Gemini ditutup. Terima kasih!"
        rm -f "$RESP_FILE" "$DATA_FILE"
        exit 0
    fi

<<<<<<< HEAD
    # 2. Proses Pengiriman ke Server Proxy Publik Bebas Kunci
=======
    # ⚠️ PENTING: BUAT API KEY BARU DI GOOGLE AI STUDIO DAN MASUKKAN DI SINI
    API_KEY="AQ.Ab8RN6IMstmupi2qCeWFymCcfv1kYLHVN2X35OaehYGwpOZNkw"

    # 2. Proses Pengiriman Request & Animasi Loading Gauge
>>>>>>> ed2d409 (y)
    (
        echo 20
        # Menyusun objek JSON standar menggunakan JQ
        jq -n --arg msg "$PERTANYAAN" '{"contents": [{"parts": [{"text": $msg}]}]}' > "$DATA_FILE"
        
        echo 60
        # MENEMBAK PROXY JEMBATAN GRATIS (Menggunakan endpoint publik tanpa membawa parameter ?key=)
        curl -s -X POST "https://workers.dev" \
             -H "Content-Type: application/json" \
             -d @"$DATA_FILE" > "$RESP_FILE"
        echo 100
    ) | dialog --backtitle "KAPTEN NEMO AI" --title " Sedang Memproses... " --gauge "\nMenghubungi server Jembatan Proxy AI..." 8 55 0

    # 3. Ekstraksi Respon Menggunakan JQ
    if [ -s "$RESP_FILE" ]; then
        # Membaca teks balasan sukses
        JAWABAN=$(jq -r '.candidates[0].content.parts[0].text' "$RESP_FILE" 2>/dev/null)
        
        # Jika respon berupa null (format lama proxy berbeda)
        if [ "$JAWABAN" == "null" ] || [ -z "$JAWABAN" ]; then
            JAWABAN=$(jq -r '.candidates.content.parts.text' "$RESP_FILE" 2>/dev/null)
        fi

        # Jika server proxy sedang penuh / down
        if [ "$JAWABAN" == "null" ] || [ -z "$JAWABAN" ]; then
            PROXY_ERR=$(jq -r '.error.message' "$RESP_FILE" 2>/dev/null)
            JAWABAN="PROXY TRAFFIC FULL!\n\nPesan: $PROXY_ERR\n\nSolusi: Server proxy gratisan sedang padat. Silakan tunggu beberapa menit lalu coba kirim pertanyaan kembali."
        fi
    else
        JAWABAN="Error: Tidak ada respon dari Jembatan Proxy. Periksa koneksi internet HP Anda."
    fi

    # 4. Tampilkan Jawaban Akhir ke Layar GUI
    dialog --backtitle "KAPTEN NEMO AI" \
           --title " JAWABAN GEMINI FREE " \
           --msgbox "$JAWABAN" 22 72
done
