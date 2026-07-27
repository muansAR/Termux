#!/bin/bash

echo "[+] Mendeteksi IP Router secara otomatis..."

# Membaca IP Gateway/Router dari sistem Android (Termux)
ROUTER_IP=$(ip route show | grep default | awk '{print $3}')

# Validasi jika IP tidak ditemukan
if [ -z "$ROUTER_IP" ]; then
    echo "[❌] Gagal mendeteksi IP Router. Pastikan Anda sudah terhubung ke Wi-Fi!"
    exit 1
fi

echo "[✔] Router ditemukan di IP: $ROUTER_IP"
echo "----------------------------------------"

# Meminta input akun
read -p "Masukkan Username Router: " USERNAME
read -sp "Masukkan Password Router: " PASSWORD
echo -e "\n"

echo "[+] Mencoba mengekstrak fitur & status router..."

# Eksekusi masuk menggunakan sshpass dan menembakkan perintah umum
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USERNAME@$ROUTER_IP" << 'EOF'
  echo -e "\n====================================="
  echo "      INFORMASI SISTEM ROUTER        "
  echo "====================================="
  uname -a || /system resource print 2>/dev/null
  
  echo -e "\n====================================="
  echo "     STATUS ANTARMUKA / INTERFACE    "
  echo "====================================="
  ifconfig || /interface print 2>/dev/null
  
  echo -e "\n====================================="
  echo "    DAFTAR PERANGKAT TERHUBUNG       "
  echo "====================================="
  cat /proc/net/arp || /ip dhcp-server lease print 2>/dev/null
EOF

if [ $? -ne 0 ]; then
    echo -e "\n[❌] Gagal mengambil fitur. Kemungkinan salah password atau port SSH router ditutup."
fi
