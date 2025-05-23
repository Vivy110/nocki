#!/bin/bash

# ========= Definisi Warna =========
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# ========= Path Proyek =========
NCK_DIR="$HOME/nockchain"

# ========= Banner dan Kredit =========
function show_banner() {
  clear
  echo -e "${BOLD}${BLUE}"
  echo "               ╔═╗╔═╦╗─╔╦═══╦═══╦═══╦═══╗"
  echo "               ╚╗╚╝╔╣║─║║╔══╣╔═╗║╔═╗║╔═╗║"
  echo "               ─╚╗╔╝║║─║║╚══╣║─╚╣║─║║║─║║"
  echo "               ─╔╝╚╗║║─║║╔══╣║╔═╣╚═╝║║─║║"
  echo "               ╔╝╔╗╚╣╚═╝║╚══╣╚╩═║╔═╗║╚═╝║"
  echo "               ╚═╝╚═╩═══╩═══╩═══╩╝─╚╩═══╝"
  echo -e "${RESET}"
  echo "               Ikuti saluran TG: t.me/xuegaoz"
  echo "               GitHub saya: github.com/Gzgod"
  echo "               Twitter saya: @Xuegaogx"
  echo "-----------------------------------------------"
  echo ""
}

# ========= Tunggu input untuk lanjut =========
function pause_and_return() {
  echo ""
  read -n1 -r -p "Tekan sembarang tombol untuk kembali ke menu utama..." key
  main_menu
}

# ========= Instal Dependensi Sistem =========
function install_dependencies() {
  if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}[-] Script ini hanya untuk Debian/Ubuntu (apt). Silakan instal dependensi manual!${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Memperbarui sistem dan instal dependensi..."
  apt-get update && apt-get upgrade -y && apt install -y sudo
  sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
  echo -e "${GREEN}[+] Dependensi berhasil diinstal.${RESET}"
  pause_and_return
}

# ========= Instal Rust =========
function install_rust() {
  if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}[!] Rust sudah terpasang, dilewati.${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Menginstal Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env" || { echo -e "${RED}[-] Gagal mengatur environment Rust!${RESET}"; pause_and_return; return; }
  rustup default stable
  echo -e "${GREEN}[+] Rust berhasil diinstal.${RESET}"
  pause_and_return
}

# ========= Setup Repository =========
function setup_repository() {
  echo -e "[*] Memeriksa repositori nockchain..."
  if [ -d "$NCK_DIR" ]; then
    echo -e "${YELLOW}[?] Direktori nockchain sudah ada. Hapus dan clone ulang? (y/n)${RESET}"
    read -r confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
      rm -rf "$NCK_DIR" "$HOME/.nockapp"
      git clone https://github.com/zorp-corp/nockchain "$NCK_DIR"
    else
      cd "$NCK_DIR" && git pull
    fi
  else
    git clone https://github.com/zorp-corp/nockchain "$NCK_DIR"
  fi
  if [ $? -ne 0 ]; then
    echo -e "${RED}[-] Gagal clone repositori! Periksa jaringan atau izin!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  if [ -f ".env" ]; then
    cp .env .env.bak
    echo -e "[*] File .env telah dicadangkan ke .env.bak"
  fi
  if [ -f ".env_example" ]; then
    cp .env_example .env
    echo -e "${GREEN}[+] File environment .env berhasil dibuat.${RESET}"
  else
    echo -e "${RED}[-] File .env_example tidak ditemukan!${RESET}"
  fi
  echo -e "${GREEN}[+] Setup repositori selesai.${RESET}"
  pause_and_return
}

# ========= Kompilasi Proyek =========
function build_and_configure() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada! Jalankan opsi 3 dulu.${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengompilasi komponen inti..."
  make install-hoonc || { echo -e "${RED}[-] Gagal menjalankan make install-hoonc!${RESET}"; pause_and_return; return; }
  if command -v hoonc &> /dev/null; then
    echo -e "[*] hoonc terpasang, command tersedia: hoonc"
  else
    echo -e "${YELLOW}[!] Peringatan: Command hoonc tidak tersedia!${RESET}"
  fi
  make build || { echo -e "${RED}[-] Gagal menjalankan make build!${RESET}"; pause_and_return; return; }
  make install-nockchain-wallet || { echo -e "${RED}[-] Gagal install wallet!${RESET}"; pause_and_return; return; }
  make install-nockchain || { echo -e "${RED}[-] Gagal install nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengatur environment variable..."
  RC_FILE="$HOME/.bashrc"
  [[ "$SHELL" == *"zsh"* ]] && RC_FILE="$HOME/.zshrc"
  if ! grep -q "$NCK_DIR/target/release" "$RC_FILE"; then
    echo "export PATH=\"\$PATH:$NCK_DIR/target/release\"" >> "$RC_FILE"
    source "$RC_FILE" || echo -e "${YELLOW}[!] Jalankan 'source $RC_FILE' atau buka terminal baru.${RESET}"
  else
    source "$RC_FILE" || echo -e "${YELLOW}[!] Jalankan 'source $RC_FILE' atau buka terminal baru.${RESET}"
  fi
  echo -e "${GREEN}[+] Kompilasi dan konfigurasi selesai.${RESET}"
  pause_and_return
}

# ========= Generate Wallet =========
function generate_wallet() {
  if [ ! -d "$NCK_DIR" ] || [ ! -f "$NCK_DIR/target/release/nockchain-wallet" ]; then
    echo -e "${RED}[-] Wallet tidak ditemukan! Jalankan opsi 3 & 4 dulu.${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Membuat keypair wallet..."
  read -p "[?] Buat wallet baru? [Y/n]: " create_wallet
  create_wallet=${create_wallet:-y}
  if [[ ! "$create_wallet" =~ ^[Yy]$ ]]; then
    echo -e "[*] Pembuatan wallet dibatalkan."
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Command nockchain-wallet tidak tersedia!${RESET}"
    pause_and_return
    return
  fi
  nockchain-wallet keygen > wallet_keys.txt 2>&1 || { echo -e "${RED}[-] Gagal generate wallet!${RESET}"; pause_and_return; return; }
  echo -e "${GREEN}[+] Key wallet disimpan di $NCK_DIR/wallet_keys.txt${RESET}"
  PUBLIC_KEY=$(grep -i "public key" wallet_keys.txt | awk '{print $NF}' | tail -1)
  if [ -n "$PUBLIC_KEY" ]; then
    echo -e "${YELLOW}Kunci Publik:${RESET}\n$PUBLIC_KEY"
    echo -e "${YELLOW}[!] Gunakan opsi 6 untuk set mining pubkey atau edit manual di .env:${RESET}"
    echo -e "MINING_PUBKEY=$PUBLIC_KEY"
  else
    echo -e "${RED}[-] Gagal ekstrak public key!${RESET}"
  fi
  echo -e "${GREEN}[+] Wallet berhasil dibuat.${RESET}"
  pause_and_return
}

# ========= Atur Mining Pubkey =========
function configure_mining_key() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada! Jalankan opsi 3 dulu.${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengatur MINING_PUBKEY..."
  read -p "[?] Masukkan MINING_PUBKEY (dapatkan dari opsi 5): " public_key
  if [ -z "$public_key" ]; then
    echo -e "${RED}[-] MINING_PUBKEY tidak valid!${RESET}"
    pause_and_return
    return
  fi
  if [ ! -f ".env" ]; then
    echo -e "${RED}[-] File .env tidak ada! Jalankan opsi 3 dulu.${RESET}"
    pause_and_return
    return
  fi
  if ! grep -q "^MINING_PUBKEY=" .env; then
    echo "MINING_PUBKEY=$public_key" >> .env
  else
    sed -i "s|^MINING_PUBKEY=.*|MINING_PUBKEY=$public_key|" .env || {
      echo -e "${RED}[-] Gagal update .env!${RESET}"
      pause_and_return
      return
    }
  fi
  if grep -q "^MINING_PUBKEY=$public_key$" .env; then
    echo -e "${GREEN}[+] MINING_PUBKEY berhasil diupdate!${RESET}"
  else
    echo -e "${RED}[-] Gagal update .env!${RESET}"
  fi
  echo -e "${GREEN}[+] Mining pubkey terkonfigurasi.${RESET}"
  pause_and_return
}

# ========= Mulai Node Miner =========
function start_miner_node() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada! Jalankan opsi 3 dulu.${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  echo -e "[*] Memverifikasi command nockchain..."
  if ! command -v nockchain &> /dev/null; then
    echo -e "${RED}[-] Command nockchain tidak tersedia! Pastikan opsi 4 berhasil.${RESET}"
    echo -e "${YELLOW}[!] Pastikan PATH menyertakan $NCK_DIR/target/release${RESET}"
    pause_and_return
    return
  fi

  echo -e "[*] Memverifikasi command screen dan tee..."
  if ! command -v screen &> /dev/null; then
    echo -e "${RED}[-] Screen tidak terpasang! Jalankan opsi 1.${RESET}"
    pause_and_return
    return
  fi
  if ! command -v tee &> /dev/null; then
    echo -e "${RED}[-] Tee tidak terpasang! Jalankan opsi 1.${RESET}"
    pause_and_return
    return
  fi

  if [ -f ".env" ]; then
    public_key=$(grep "^MINING_PUBKEY=" .env | cut -d'=' -f2)
    if [ -z "$public_key" ]; then
      echo -e "${YELLOW}[!] MINING_PUBKEY tidak ada di .env, masukkan manual.${RESET}"
      read -p "[?] Masukkan MINING_PUBKEY: " public_key
      if [ -z "$public_key" ]; then
        echo -e "${RED}[-] MINING_PUBKEY harus diisi!${RESET}"
        pause_and_return
        return
      fi
    else
      echo -e "[*] Menggunakan MINING_PUBKEY dari .env: $public_key"
    fi
  else
    echo -e "${YELLOW}[!] File .env tidak ada, masukkan manual.${RESET}"
    read -p "[?] Masukkan MINING_PUBKEY: " public_key
    if [ -z "$public_key" ]; then
      echo -e "${RED}[-] MINING_PUBKEY harus diisi!${RESET}"
      pause_and_return
      return
    fi
  fi

  if [ -d ".data.nockchain" ]; then
    echo -e "${YELLOW}[?] Direktori data ditemukan. Hapus untuk inisialisasi ulang? (y/n)${RESET}"
    read -r confirm_clean
    if [[ "$confirm_clean" == "y" || "$confirm_clean" == "Y" ]]; then
      echo -e "[*] Membersihkan direktori data..."
      mv .data.nockchain .data.nockchain.bak-$(date +%F-%H%M%S) 2>/dev/null
      echo -e "${GREEN}[+] Data lama telah di-backup.${RESET}"
    fi
  fi

  LEADER_PORT=3005
  FOLLOWER_PORT=3006
  PORTS_TO_CHECK=("$LEADER_PORT" "$FOLLOWER_PORT")
  PORTS_OCCUPIED=false
  declare -A PID_PORT_MAP

  echo -e "[*] Memeriksa port $LEADER_PORT dan $FOLLOWER_PORT..."
  if command -v lsof &> /dev/null; then
    for PORT in "${PORTS_TO_CHECK[@]}"; do
      PIDS=$(lsof -i :$PORT -t | sort -u)
      if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}[!] Port $PORT sedang digunakan.${RESET}"
        for PID in $PIDS; do
          echo -e "${YELLOW}[!] PID $PID menggunakan port $PORT${RESET}"
          PID_PORT_MAP[$PID]+="$PORT "
          PORTS_OCCUPIED=true
        done
      fi
    done
  elif command -v netstat &> /dev/null; then
    for PORT in "${PORTS_TO_CHECK[@]}"; do
      PIDS=$(netstat -tulnp 2>/dev/null | grep ":$PORT " | awk '{print $7}' | cut -d'/' -f1 | sort -u)
      if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}[!] Port $PORT sedang digunakan.${RESET}"
        for PID in $PIDS; do
          echo -e "${YELLOW}[!] PID $PID menggunakan port $PORT${RESET}"
          PID_PORT_MAP[$PID]+="$PORT "
          PORTS_OCCUPIED=true
        done
      fi
    done
  else
    echo -e "${RED}[-] Tidak bisa memeriksa port!${RESET}"
    pause_and_return
    return
  fi

# Menangani port yang digunakan
  if [ "$PORTS_OCCUPIED" = true ]; then
    echo -e "${YELLOW}[?] Ditemukan port yang sedang digunakan, apakah ingin menghentikan proses yang menggunakannya untuk membebaskan port? (y/n)${RESET}"
    read -r confirm_kill
    if [[ "$confirm_kill" == "y" || "$confirm_kill" == "Y" ]]; then
      for PID in "${!PID_PORT_MAP[@]}"; do
        PORTS=${PID_PORT_MAP[$PID]}
        echo -e "[*] Menghentikan proses (PID: $PID) yang menggunakan port $PORTS..."
        if ! ps -p "$PID" -o user= | grep -q "^$USER$"; then
          echo -e "${YELLOW}[!] Proses PID $PID dimiliki oleh pengguna lain, mencoba menggunakan sudo untuk menghentikannya...${RESET}"
          sudo kill -9 "$PID" 2>/dev/null
        else
          kill -9 "$PID" 2>/dev/null
        fi
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}[+] Berhasil menghentikan PID $PID, port $PORTS seharusnya sudah bebas.${RESET}"
        else
          echo -e "${RED}[-] Gagal menghentikan PID $PID, silakan periksa secara manual!${RESET}"
          pause_and_return
          return
        fi
      done
      echo -e "[*] Memverifikasi apakah port sudah dibebaskan..."
      for PORT in "${PORTS_TO_CHECK[@]}"; do
        if command -v lsof &> /dev/null && lsof -i :$PORT -t >/dev/null 2>&1; then
          echo -e "${RED}[-] Port $PORT masih digunakan, silakan periksa secara manual!${RESET}"
          pause_and_return
          return
        elif command -v netstat &> /dev/null && netstat -tuln | grep -q ":$PORT "; then
          echo -e "${RED}[-] Port $PORT masih digunakan, silakan periksa secara manual!${RESET}"
          pause_and_return
          return
        fi
      done
    else
      echo -e "${RED}[-] Pengguna membatalkan penghentian proses, tidak dapat memulai node Miner!${RESET}"
      pause_and_return
      return
    fi
  else
    echo -e "${GREEN}[+] Port $LEADER_PORT dan $FOLLOWER_PORT tidak digunakan.${RESET}"
  fi

  # Membersihkan sesi screen miner yang ada
  echo -e "[*] Membersihkan sesi screen miner yang ada..."
  screen -ls | grep -q "miner" && screen -X -S miner quit

  # Memulai node Miner, menggunakan public key dan parameter peer
  echo -e "[*] Memulai node Miner..."
  NOCKCHAIN_CMD="RUST_LOG=trace ./target/release/nockchain --mining-pubkey \"$public_key\" --mine --peer /ip4/95.216.102.60/udp/3006/quic-v1 --peer /ip4/65.108.123.225/udp/3006/quic-v1 --peer /ip4/65.109.156.108/udp/3006/quic-v1 --peer /ip4/65.21.67.175/udp/3006/quic-v1 --peer /ip4/65.109.156.172/udp/3006/quic-v1 --peer /ip4/34.174.22.166/udp/3006/quic-v1 --peer /ip4/34.95.155.151/udp/30000/quic-v1 --peer /ip4/34.18.98.38/udp/30000/quic-v1"

  echo -e "${GREEN}[+] Node nockchain dijalankan dalam sesi screen bernama 'miner', log juga disimpan di $NCK_DIR/miner.log${RESET}"
  echo -e "${YELLOW}[!] Gunakan 'screen -r miner' untuk melihat output real-time, Ctrl+A lalu D untuk keluar dari screen (node tetap berjalan)${RESET}"
  screen -dmS miner -L -Logfile "$NCK_DIR/screen_miner.log" bash -c "source $HOME/.bashrc; $NOCKCHAIN_CMD 2>&1 | tee -a miner.log; echo 'nockchain telah keluar, lihat log: $NCK_DIR/miner.log'; sleep 30"

  # Menunggu waktu cukup agar sesi screen terinisialisasi
  sleep 5

  # Memeriksa apakah sesi screen berjalan
  if screen -ls | grep -q "miner"; then
    echo -e "${GREEN}[+] Node Miner berjalan dalam sesi screen 'miner', gunakan 'screen -r miner' untuk melihat${RESET}"
    echo -e "${GREEN}[+] Semua langkah telah berhasil diselesaikan!${RESET}"
    echo -e "Direktori saat ini: $(pwd)"
    echo -e "MINING_PUBKEY disetel ke: $public_key"
    echo -e "Port Leader: $LEADER_PORT"
    echo -e "Port Follower: $FOLLOWER_PORT"
    if [ -f "wallet_keys.txt" ]; then
      echo -e "Kunci dompet telah dibuat dan disimpan di $NCK_DIR/wallet_keys.txt, harap simpan dengan aman!"
    fi
    if [ -f "miner.log" ] && [ -s "miner.log" ]; then
      echo -e "${YELLOW}[!] Isi file miner.log:${RESET}"
      tail -n 10 miner.log
    else
      echo -e "${YELLOW}[!] File miner.log belum dibuat atau masih kosong, silakan cek nanti atau gunakan 'screen -r miner' untuk melihat output real-time${RESET}"
    fi
    if [ -f "$NCK_DIR/screen_miner.log" ] && [ -s "$NCK_DIR/screen_miner.log" ]; then
      echo -e "${YELLOW}[!] Isi file screen_miner.log (10 baris terakhir):${RESET}"
      tail -n 10 "$NCK_DIR/screen_miner.log"
    else
      echo -e "${YELLOW}[!] File screen_miner.log belum dibuat atau masih kosong, mungkin karena masalah output screen${RESET}"
    fi
  else
    echo -e "${RED}[-] Gagal memulai node Miner! Silakan periksa $NCK_DIR/miner.log dan $NCK_DIR/screen_miner.log${RESET}"
    echo -e "${YELLOW}[!] 10 baris terakhir dari miner.log:${RESET}"
    tail -n 10 "$NCK_DIR/miner.log" 2>/dev/null || echo -e "${YELLOW}[!] File miner.log tidak ditemukan${RESET}"
    echo -e "${YELLOW}[!] 10 baris terakhir dari screen_miner.log:${RESET}"
    tail -n 10 "$NCK_DIR/screen_miner.log" 2>/dev/null || echo -e "${YELLOW}[!] File screen_miner.log tidak ditemukan${RESET}"
  fi
  pause_and_return
}
backup_keys() {
  clear
  echo -e "${CYAN}### Mencadangkan Kunci Wallet ###${RESET}"
  if [ -f "$NCK_DIR/wallet_keys.txt" ]; then
    cp "$NCK_DIR/wallet_keys.txt" "$NCK_DIR/wallet_keys_backup.txt"
    echo -e "${GREEN}[+] Kunci wallet telah dicadangkan ke wallet_keys_backup.txt${RESET}"
  else
    echo -e "${RED}[-] Tidak ditemukan wallet_keys.txt untuk dicadangkan!${RESET}"
  fi
  pause_and_return
}

view_logs() {
  clear
  echo -e "${CYAN}### Melihat Log ###${RESET}"
  echo -e "${YELLOW}[?] File log mana yang ingin kamu lihat?${RESET}"
  echo -e "1. miner.log"
  echo -e "2. screen_miner.log"
  echo -e "0. Kembali ke menu utama"
  read -rp "Masukkan pilihan: " log_choice
  case $log_choice in
    1)
      echo -e "${YELLOW}[!] Menampilkan 30 baris terakhir dari miner.log${RESET}"
      tail -n 30 "$NCK_DIR/miner.log"
      ;;
    2)
      echo -e "${YELLOW}[!] Menampilkan 30 baris terakhir dari screen_miner.log${RESET}"
      tail -n 30 "$NCK_DIR/screen_miner.log"
      ;;
    0)
      return
      ;;
    *)
      echo -e "${RED}[-] Pilihan tidak valid!${RESET}"
      ;;
  esac
  pause_and_return
}

check_balance() {
  clear
  echo -e "${CYAN}### Memeriksa Saldo Wallet ###${RESET}"
  if [ -f "$NCK_DIR/wallet_keys.txt" ]; then
    wallet_address=$(grep "Wallet address:" "$NCK_DIR/wallet_keys.txt" | awk '{print $3}')
    echo -e "[*] Mengambil saldo untuk alamat: $wallet_address"
    curl -s "https://api.nockchain.net/balance?address=$wallet_address"
    echo ""
  else
    echo -e "${RED}[-] Tidak ditemukan wallet_keys.txt, harap jalankan mining terlebih dahulu!${RESET}"
  fi
  pause_and_return
}

main_menu() {
  while true; do
    clear
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${MAGENTA}     Selamat Datang di Nockchain CLI     ${RESET}"
    echo -e "${BLUE}========================================${RESET}"
    echo -e "Direktori kerja saat ini: ${YELLOW}$(pwd)${RESET}"
    echo -e "Versi skrip: ${GREEN}$SCRIPT_VERSION${RESET}"
    echo ""
    echo -e "1. Pasang Dependensi"
    echo -e "2. Pasang Rust"
    echo -e "3. Clone & Build Nockchain"
    echo -e "4. Jalankan Node Miner"
    echo -e "5. Cadangkan Kunci Wallet"
    echo -e "6. Lihat Log"
    echo -e "7. Periksa Saldo"
    echo -e "0. Keluar"
    echo ""
    read -rp "Masukkan pilihan: " choice
    case $choice in
      1) install_dependencies ;;
      2) install_rust ;;
      3) clone_and_build ;;
      4) run_miner_node ;;
      5) backup_keys ;;
      6) view_logs ;;
      7) check_balance ;;
      0)
        echo -e "${GREEN}[+] Terima kasih telah menggunakan Nockchain CLI!${RESET}"
        exit 0
        ;;
      *)
        echo -e "${RED}[-] Pilihan tidak valid! Silakan coba lagi.${RESET}"
        sleep 2
        ;;
    esac
  done
}

# Jalankan menu utama
main_menu
