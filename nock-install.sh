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

# ========= Menangani Port yang Terpakai =========
  if [ "$PORTS_OCCUPIED" = true ]; then
    echo -e "${YELLOW}[?] Port sedang digunakan, hentikan proses untuk membebaskan port? (y/n)${RESET}"
    read -r confirm_kill
    if [[ "$confirm_kill" == "y" || "$confirm_kill" == "Y" ]]; then
      for PID in "${!PID_PORT_MAP[@]}"; do
        PORTS=${PID_PORT_MAP[$PID]}
        echo -e "[*] Menghentikan proses yang menggunakan port $PORTS (PID: $PID)..."
        if ! ps -p "$PID" -o user= | grep -q "^$USER$"; then
          echo -e "${YELLOW}[!] Proses PID $PID dimiliki oleh pengguna lain, mencoba menggunakan sudo...${RESET}"
          sudo kill -9 "$PID" 2>/dev/null
        else
          kill -9 "$PID" 2>/dev/null
        fi
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}[+] Berhasil menghentikan PID $PID, port $PORTS seharusnya terbuka.${RESET}"
        else
          echo -e "${RED}[-] Gagal menghentikan PID $PID, harap periksa manual!${RESET}"
          pause_and_return
          return
        fi
      done
      echo -e "[*] Memverifikasi pembebasan port..."
      for PORT in "${PORTS_TO_CHECK[@]}"; do
        if command -v lsof &> /dev/null && lsof -i :$PORT -t >/dev/null 2>&1; then
          echo -e "${RED}[-] Port $PORT masih terpakai, harap periksa manual!${RESET}"
          pause_and_return
          return
        elif command -v netstat &> /dev/null && netstat -tuln | grep -q ":$PORT "; then
          echo -e "${RED}[-] Port $PORT masih terpakai, harap periksa manual!${RESET}"
          pause_and_return
          return
        fi
      done
    else
      echo -e "${RED}[-] Pembatalan oleh pengguna, tidak dapat memulai node Miner!${RESET}"
      pause_and_return
      return
    fi
  else
    echo -e "${GREEN}[+] Port $LEADER_PORT dan $FOLLOWER_PORT tersedia.${RESET}"
  fi

  # Membersihkan sesi screen miner yang ada
  echo -e "[*] Membersihkan sesi screen miner yang ada..."
  screen -ls | grep -q "miner" && screen -X -S miner quit

  # Memulai Node Miner dengan parameter pubkey dan peer
  echo -e "[*] Memulai Node Miner..."
  NOCKCHAIN_CMD="RUST_LOG=trace ./target/release/nockchain --mining-pubkey \"$public_key\" --mine --peer /ip4/95.216.102.60/udp/3006/quic-v1 --peer /ip4/65.108.123.225/udp/3006/quic-v1 --peer /ip4/65.109.156.108/udp/3006/quic-v1 --peer /ip4/65.21.67.175/udp/3006/quic-v1 --peer /ip4/65.109.156.172/udp/3006/quic-v1 --peer /ip4/34.174.22.166/udp/3006/quic-v1 --peer /ip4/34.95.155.151/udp/30000/quic-v1 --peer /ip4/34.18.98.38/udp/30000/quic-v1"

  echo -e "${GREEN}[+] Memulai node nockchain di sesi screen 'miner', log disimpan ke $NCK_DIR/miner.log${RESET}"
  echo -e "${YELLOW}[!] Gunakan 'screen -r miner' untuk melihat output langsung, Ctrl+A lalu D untuk detach (node tetap berjalan)${RESET}"
  screen -dmS miner -L -Logfile "$NCK_DIR/screen_miner.log" bash -c "source $HOME/.bashrc; $NOCKCHAIN_CMD 2>&1 | tee -a miner.log; echo 'nockchain telah berhenti, lihat log: $NCK_DIR/miner.log'; sleep 30"

  # Menunggu inisialisasi sesi screen
  sleep 5

  # Memverifikasi sesi screen
  if screen -ls | grep -q "miner"; then
    echo -e "${GREEN}[+] Node Miner berjalan di sesi screen 'miner', gunakan 'screen -r miner' untuk melihat${RESET}"
    echo -e "${GREEN}[+] Semua proses berhasil diselesaikan!${RESET}"
    echo -e "Direktori saat ini: $(pwd)"
    echo -e "MINING_PUBKEY telah diatur ke: $public_key"
    echo -e "Port Leader: $LEADER_PORT"
    echo -e "Port Follower: $FOLLOWER_PORT"
    if [ -f "wallet_keys.txt" ]; then
      echo -e "Kunci wallet telah dibuat dan disimpan di $NCK_DIR/wallet_keys.txt, simpan dengan aman!"
    fi
    if [ -f "miner.log" ] && [ -s "miner.log" ]; then
      echo -e "${YELLOW}[!] Isi miner.log:${RESET}"
      tail -n 10 miner.log
    else
      echo -e "${YELLOW}[!] File miner.log kosong, periksa nanti atau gunakan 'screen -r miner'${RESET}"
    fi
    if [ -f "$NCK_DIR/screen_miner.log" ] && [ -s "$NCK_DIR/screen_miner.log" ]; then
      echo -e "${YELLOW}[!] Isi screen_miner.log (10 baris terakhir):${RESET}"
      tail -n 10 "$NCK_DIR/screen_miner.log"
    else
      echo -e "${YELLOW}[!] File screen_miner.log kosong, mungkin ada masalah output${RESET}"
    fi
  else
    echo -e "${RED}[-] Gagal memulai Node Miner! Periksa $NCK_DIR/miner.log dan $NCK_DIR/screen_miner.log${RESET}"
    echo -e "${YELLOW}[!] 10 baris terakhir miner.log:${RESET}"
    tail -n 10 "$NCK_DIR/miner.log" 2>/dev/null || echo -e "${YELLOW}[!] File miner.log tidak ditemukan${RESET}"
    echo -e "${YELLOW}[!] 10 baris terakhir screen_miner.log:${RESET}"
    tail -n 10 "$NCK_DIR/screen_miner.log" 2>/dev/null || echo -e "${YELLOW}[!] File screen_miner.log tidak ditemukan${RESET}"
  fi
  pause_and_return
}

# ========= BACKUP KUNCI =========
function backup_keys() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ditemukan, silakan jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, silakan jalankan opsi 4 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Melakukan backup kunci..."
  nockchain-wallet export-keys > nockchain_keys_backup.txt 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Backup kunci berhasil! File tersimpan di $NCK_DIR/nockchain_keys_backup.txt${RESET}"
    echo -e "${YELLOW}[!] Harap simpan file ini dengan aman dan jangan sampai bocor!${RESET}"
  else
    echo -e "${RED}[-] Backup kunci gagal, silakan cek output perintah nockchain-wallet export-keys!${RESET}"
    echo -e "${YELLOW}[!] Informasi detail ada di $NCK_DIR/nockchain_keys_backup.txt${RESET}"
  fi
  pause_and_return
}

# ========= LIHAT LOG NODE =========
function view_logs() {
  LOG_FILE="$NCK_DIR/miner.log"
  if [ -f "$LOG_FILE" ]; then
    echo -e "${GREEN}[+] Menampilkan file log: $LOG_FILE${RESET}"
    tail -f "$LOG_FILE"
  else
    echo -e "${RED}[-] File log $LOG_FILE tidak ditemukan, pastikan sudah menjalankan opsi 7 untuk memulai Miner Node!${RESET}"
  fi
  pause_and_return
}

# ========= CEK SALDO =========
function check_balance() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ditemukan, silakan jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, silakan jalankan opsi 4 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  # Cek file socket
  SOCKET_PATH="/opt/nockchain/.socket/nockchain_npc.sock"
  if [ ! -S "$SOCKET_PATH" ]; then
    echo -e "${RED}[-] File socket $SOCKET_PATH tidak ditemukan, pastikan node nockchain berjalan (coba opsi 7)!${RESET}"
    pause_and_return
    return
  fi

  # Jalankan perintah cek saldo
  echo -e "[*] Sedang memeriksa saldo..."
  nockchain-wallet --nockchain-socket "$SOCKET_PATH" update-balance > balance_output.txt 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Cek saldo berhasil! Berikut hasilnya:${RESET}"
    echo -e "----------------------------------------"
    cat balance_output.txt
    echo -e "----------------------------------------"
  else
    echo -e "${RED}[-] Cek saldo gagal, silakan cek perintah nockchain-wallet atau status node!${RESET}"
    echo -e "${YELLOW}[!] Informasi detail ada di $NCK_DIR/balance_output.txt${RESET}"
  fi
  pause_and_return
}

# ========= MENU UTAMA =========
function main_menu() {
  show_banner
  echo "Silakan pilih operasi:"
  echo "  1) Instalasi dependensi sistem"
  echo "  2) Instalasi Rust"
  echo "  3) Setup repositori"
  echo "  4) Compile proyek dan konfigurasi environment"
  echo "  5) Buat dompet (wallet)"
  echo "  6) Atur kunci mining"
  echo "  7) Jalankan node Miner"
  echo "  8) Backup kunci"
  echo "  9) Lihat log node"
  echo " 10) Cek saldo"
  echo "  0) Keluar"
  echo ""
  read -p "Masukkan nomor pilihan: " choice
  case "$choice" in
    1) install_dependencies ;;
    2) install_rust ;;
    3) setup_repository ;;
    4) build_and_configure ;;
    5) generate_wallet ;;
    6) configure_mining_key ;;
    7) start_miner_node ;;
    8) backup_keys ;;
    9) view_logs ;;
    10) check_balance ;;
    0) echo -e "${GREEN}Keluar dari program.${RESET}"; exit 0 ;;
    *) echo -e "${RED}[-] Pilihan tidak valid!${RESET}"; pause_and_return ;;
  esac
}

# ========= MULAI PROGRAM UTAMA =========
main_menu
