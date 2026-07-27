#!/bin/bash
GREEN='\e[1;32m'; BLUE='\e[1;34m'; CYAN='\e[1;36m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; RESET='\e[0m'
clear
echo -e "${CYAN}=====================================================${RESET}"
echo -e "${CYAN}         NETWORK SCANNER BY KAPTEN NEMO             ${RESET}"
echo -e "${CYAN}=====================================================${RESET}"

check_and_install() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}[+] Menginstal '$2'...${RESET}"
        pkg update -y && pkg install "$2" -y || exit 1
    fi
}

check_and_install "curl" "curl"; check_and_install "nmap" "nmap"
check_and_install "ping" "inetutils"; check_and_install "jq" "jq"
check_and_install "ip" "iproute2"

echo -e "${BLUE}[*] Memeriksa Koneksi Internet...${RESET}"
ping -c 1 8.8.8.8 &> /dev/null || { echo -e "${RED}[X] Terputus!${RESET}"; exit 1; }
echo -e "${GREEN}[✓] Terhubung${RESET}\n"

echo -e "${BLUE}[*] Melacak Informasi Provider...${RESET}"
IP_INFO=$(curl -s --max-time 10 https://ipwho.is/)
if [ -n "$IP_INFO" ] && echo "$IP_INFO" | jq -e '.success' &> /dev/null; then
    echo -e "${GREEN}    • IP Publik : ${RESET}$(echo "$IP_INFO" | jq -r '.ip')"
    echo -e "${GREEN}    • Provider  : ${RESET}$(echo "$IP_INFO" | jq -r '.connection.isp')"
    echo -e "${GREEN}    • Lokasi    : ${RESET}$(echo "$IP_INFO" | jq -r '.city'), $(echo "$IP_INFO" | jq -r '.country')"
fi

echo -e "\n${BLUE}[*] Menghitung Jaringan Lokal...${RESET}"
IP_ADMIN=$(ip route 2>/dev/null | grep -E 'default|via' | awk '{print $3}' | head -n 1)
[ -z "$IP_ADMIN" ] && IP_ADMIN=$(getprop dhcp.wlan0.gateway 2>/dev/null)

MY_LOCAL_IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
[ -z "$MY_LOCAL_IP" ] && MY_LOCAL_IP=$(ip route 2>/dev/null | grep -v default | grep -E 'src [0-9]+\.' | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -n 1)

SUBNET=$(ip route 2>/dev/null | grep -v default | grep -E 'dev wlan|src' | awk '{print $1}' | grep '/' | head -n 1)
[ -z "$SUBNET" ] && [ -n "$MY_LOCAL_IP" ] && SUBNET="$(echo $MY_LOCAL_IP | cut -d. -f1-3).0/24"

# Deteksi SSID Aktif
WIFI_SSID=$(dumpsys netstats 2>/dev/null | grep -E "SSID:|iface=wlan" | head -n 1 | grep -o '"[^"]*"' | sed 's/"//g')
[ -z "$WIFI_SSID" ] && WIFI_SSID="Terhubung (Wi-Fi)"

if [ -n "$SUBNET" ]; then
    echo -e "${GREEN}    • Nama Wi-Fi : ${RESET}$WIFI_SSID"
    echo -e "${GREEN}    • IP Device  : ${RESET}$MY_LOCAL_IP"
    echo -e "${YELLOW}    • IP Admin   : ${RESET}${IP_ADMIN:-Tidak Terdeteksi}"

    # Menampilkan Log Riwayat Wi-Fi Terpisah dan Rapi
    echo -e "\n${BLUE}[*] Membaca Log Wi-Fi Tersimpan (Android 7)...${RESET}"
    if su -c "test -f /data/misc/wifi/wpa_supplicant.conf" &>/dev/null; then
        echo -e "${YELLOW}    -------------------------------------------------${RESET}"
        su -c "cat /data/misc/wifi/wpa_supplicant.conf" | awk '
        /network=\{/ { ssid=""; psk="[Tidak ada password / Open]"; }
        /ssid=/ { 
            ssid=$0; 
            gsub(/^[ \t]*ssid=/, "", ssid); 
            gsub(/"/, "", ssid); 
        }
        /psk=/ { 
            psk=$0; 
            gsub(/^[ \t]*psk=/, "", psk); 
            gsub(/"/, "", psk); 
        }
        /\}/ { 
            if (ssid != "") {
                print "    • SSID     : " ssid;
                print "      PASSWORD : " psk;
                print "    -------------------------------------------------";
            }
        }'
    else
        echo -e "${RED}    [X] Gagal membaca log. Perangkat belum di-root atau izin su ditolak.${RESET}"
    fi

    echo -e "\n${BLUE}[*] Memindai Perangkat di ($SUBNET)...${RESET}\n"

    # Scan dengan nmap dan reverse DNS lookup
    nmap -sn -R "$SUBNET" 2>/dev/null | awk '
    /Nmap scan report for/ {
        ip_with_hostname = $0;
        sub(/.*Nmap scan report for /, "", ip_with_hostname);
        
        # Cek apakah ada hostname dalam kurung
        if (ip_with_hostname ~ /\(.*\)/) {
            # Format: hostname (IP)
            hostname = ip_with_hostname;
            sub(/ \(.*/, "", hostname);
            ip = ip_with_hostname;
            gsub(/.*\(/, "", ip);
            gsub(/\)/, "", ip);
        } else {
            # Hanya IP tanpa hostname
            ip = ip_with_hostname;
            hostname = "Unknown";
        }
        current_ip = ip;
        current_hostname = hostname;
        print "    [+] IP: " ip "\n        ↳ Nama Device: " hostname;
    }
    /MAC Address:/ {
        mac_info = $0;
        sub(/.*MAC Address: /, "", mac_info);
        print "        ↳ MAC & Brand: " mac_info "\n"
    }' &

    # Jika nmap hostname tidak bekerja, gunakan fallback dengan nbtscan
    if command -v nbtscan &> /dev/null; then
        sleep 2
        echo -e "${BLUE}[*] Mencoba NBT Scan untuk nama device tambahan...${RESET}\n"
        nbtscan -r "$SUBNET" 2>/dev/null | grep -v "Sendto failed" | tail -n +5 | while read line; do
            if [ -n "$line" ]; then
                name=$(echo "$line" | awk '{print $2}' | grep -v "^$")
                if [ -n "$name" ] && [ "$name" != "<UNKNOWN>" ]; then
                    echo "        [+] Nama Alternatif Terdeteksi: $name"
                fi
            fi
        done
    fi
    
    wait

fi

