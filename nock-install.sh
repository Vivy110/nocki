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
  echo "               GitHub saya: github.com/vivy110"
  echo "               Twitter saya: @Diva_Hashimoto"
  echo "-----------------------------------------------"
  echo ""
}

# ========= Instal Dependensi Sistem =========
function install_dependencies() {
  echo -e "[*] Mendeteksi manajer paket sistem..."
  if command -v apt-get &> /dev/null; then
    echo -e "[*] Terdeteksi sistem Debian/Ubuntu (apt), mulai instal dependensi..."
    apt-get update && apt-get upgrade -y && apt install -y sudo
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}[+] Dependensi berhasil diinstal.${RESET}"
    else
      echo -e "${RED}[-] Gagal menginstal dependensi, periksa jaringan atau izin!${RESET}"
    fi
  elif command -v yum &> /dev/null; then
    echo -e "[*] Terdeteksi sistem CentOS/RHEL (yum), mulai instal dependensi..."
    sudo yum update -y && sudo yum upgrade -y
    sudo yum install -y curl iptables gcc-c++ git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli mesa-libgbm pkgconf openssl-devel leveldb-devel tar clang bsdmainutils ncdu unzip screen
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}[+] Dependensi berhasil diinstal.${RESET}"
    else
      echo -e "${RED}[-] Gagal menginstal dependensi, periksa jaringan atau izin!${RESET}"
    fi
  elif command -v pacman &> /dev/null; then
    echo -e "[*] Terdeteksi sistem Arch Linux (pacman), mulai instal dependensi..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm curl iptables base-devel git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli mesa-libgbm pkgconf openssl leveldb tar clang bsdmainutils ncdu unzip screen
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}[+] Dependensi berhasil diinstal.${RESET}"
    else
      echo -e "${RED}[-] Gagal menginstal dependensi, periksa jaringan atau izin!${RESET}"
    fi
  else
    echo -e "${RED}[-] Sistem tidak didukung (apt/yum/pacman tidak ditemukan). Silakan instal dependensi manual!${RESET}"
    echo -e "${YELLOW}[!] Dependensi diperlukan: curl, iptables, build-essential, git, wget, lz4, jq, make, gcc, nano, automake, autoconf, tmux, htop, nvme-cli, libgbm1, pkg-config, libssl-dev, libleveldb-dev, tar, clang, bsdmainutils, ncdu, unzip, screen${RESET}"
    pause_and_return
    return
  fi
  pause_and_return
}

# ========= Instal Rust =========
function install_rust() {
  if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}[!] Rust sudah terinstal, dilewati.${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Menginstal Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env" || { echo -e "${RED}[-] Gagal mengatur environment variable Rust!${RESET}"; pause_and_return; return; }
  rustup default stable
  echo -e "${GREEN}[+] Rust berhasil diinstal.${RESET}"
  pause_and_return
}

# ========= Setup Repositori =========
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
    echo -e "${RED}[-] Gagal mengclone repositori, periksa jaringan atau izin!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  if [ -f ".env" ]; then
    cp .env .env.bak
    echo -e "[*] File .env telah dibackup sebagai .env.bak"
  fi
  if [ -f ".env_example" ]; then
    cp .env_example .env
    echo -e "${GREEN}[+] File environment .env telah dibuat.${RESET}"
  else
    echo -e "${RED}[-] File .env_example tidak ditemukan, periksa repositori!${RESET}"
  fi
  echo -e "${GREEN}[+] Setup repositori selesai.${RESET}"
  pause_and_return
}

# ========= Kompilasi dan Konfigurasi =========
function build_and_configure() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengompilasi komponen inti..."
  make install-hoonc 
  export PATH="$HOME/.cargo/bin:$PATH" || { echo -e "${RED}[-] Gagal menjalankan make install-hoonc, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  if command -v hoonc &> /dev/null; then
    echo -e "[*] hoonc berhasil diinstal, perintah tersedia: hoonc"
  else
    echo -e "${YELLOW}[!] Peringatan: perintah hoonc tidak tersedia, instalasi mungkin tidak lengkap.${RESET}"
  fi
  make build || { echo -e "${RED}[-] Gagal menjalankan make build, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  make install-nockchain-wallet 
  export PATH="$HOME/.cargo/bin:$PATH" || { echo -e "${RED}[-] Gagal menjalankan make install-nockchain-wallet, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  make install-nockchain
  export PATH="$HOME/.cargo/bin:$PATH" || { echo -e "${RED}[-] Gagal menjalankan make install-nockchain, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengatur environment variable..."
  RC_FILE="$HOME/.bashrc"
  [[ "$SHELL" == *"zsh"* ]] && RC_FILE="$HOME/.zshrc"
  if ! grep -q "$NCK_DIR/target/release" "$RC_FILE"; then
    echo "export PATH=\"\$PATH:$NCK_DIR/target/release\"" >> "$RC_FILE"
    source "$RC_FILE" || echo -e "${YELLOW}[!] Environment variable tidak dapat diaplikasikan, jalankan manual 'source $RC_FILE' atau buka terminal baru.${RESET}"
  else
    source "$RC_FILE" || echo -e "${YELLOW}[!] Environment variable tidak dapat diaplikasikan, jalankan manual 'source $RC_FILE' atau buka terminal baru.${RESET}"
  fi
  echo -e "${GREEN}[+] Kompilasi dan konfigurasi environment selesai.${RESET}"
  pause_and_return
}

# ========= Generate Wallet =========
function generate_wallet() {
  if [ ! -d "$NCK_DIR" ] || [ ! -f "$NCK_DIR/target/release/nockchain-wallet" ]; then
    echo -e "${RED}[-] Perintah wallet tidak ditemukan, jalankan opsi 3 dan 4 terlebih dahulu!${RESET}"
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
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, periksa direktori target/release!${RESET}"
    pause_and_return
    return
  fi
  nockchain-wallet keygen > wallet_keys.txt 2>&1 || { echo -e "${RED}[-] Gagal menjalankan nockchain-wallet keygen!${RESET}"; pause_and_return; return; }
  echo -e "${GREEN}[+] Key wallet disimpan di $NCK_DIR/wallet_keys.txt, simpan dengan aman!${RESET}"
  PUBLIC_KEY=$(grep -i "public key" wallet_keys.txt | awk '{print $NF}' | tail -1)
  if [ -n "$PUBLIC_KEY" ]; then
    echo -e "${YELLOW}Public Key:${RESET}\n$PUBLIC_KEY"
    echo -e "${YELLOW}[!] Gunakan opsi 6 untuk set mining pubkey atau tambahkan manual ke file $NCK_DIR/.env:${RESET}"
    echo -e "MINING_PUBKEY=$PUBLIC_KEY"
  else
    echo -e "${RED}[-] Gagal mengekstrak public key, periksa wallet_keys.txt!${RESET}"
  fi
  echo -e "${GREEN}[+] Pembuatan wallet selesai.${RESET}"
  pause_and_return
}

# ========= Konfigurasi Mining Key =========
function configure_mining_key() {
  if [ ! -d "$NCK_DIR" ] || [ ! -f "$NCK_DIR/.env" ]; then
    echo -e "${RED}[-] Direktori nockchain atau file .env tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengatur mining public key..."
  read -p "[?] Masukkan MINING_PUBKEY Anda: " public_key
  if [ -z "$public_key" ]; then
    echo -e "${RED}[-] MINING_PUBKEY tidak valid!${RESET}"
    pause_and_return
    return
  fi
  if ! grep -q "^MINING_PUBKEY=" .env; then
    echo "MINING_PUBKEY=$public_key" >> .env
  else
    sed -i "s|^MINING_PUBKEY=.*|MINING_PUBKEY=$public_key|" .env || {
      echo -e "${RED}[-] Gagal memperbarui MINING_PUBKEY di .env!${RESET}"
      pause_and_return
      return
    }
  fi
  if grep -q "^MINING_PUBKEY=$public_key$" .env; then
    echo -e "${GREEN}[+] Mining pubkey berhasil diatur!${RESET}"
  else
    echo -e "${RED}[-] Gagal memperbarui file .env!${RESET}"
  fi
  pause_and_return
}

# ========= Mulai Node Miner =========
function start_miner_node() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  # Verifikasi ketersediaan perintah nockchain
  echo -e "[*] Memverifikasi perintah nockchain..."
  if ! command -v nockchain &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain tidak tersedia, periksa opsi 4!${RESET}"
    pause_and_return
    return
  fi

  # Verifikasi file .env dan MINING_PUBKEY
  if [ ! -f ".env" ] || ! grep -q "^MINING_PUBKEY=" .env; then
    echo -e "${RED}[-] File .env atau MINING_PUBKEY tidak ditemukan, jalankan opsi 6 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  PUBLIC_KEY=$(grep "^MINING_PUBKEY=" .env | cut -d'=' -f2)
  if [ -z "$PUBLIC_KEY" ]; then
    echo -e "${RED}[-] MINING_PUBKEY kosong, periksa file .env!${RESET}"
    pause_and_return
    return
  fi

  # Pembersihan direktori data
  if [ -d ".data.nockchain" ]; then
    echo -e "${YELLOW}[?] Direktori data .data.nockchain ditemukan. Hapus untuk inisialisasi ulang? (y/n)${RESET}"
    read -r confirm_clean
    if [[ "$confirm_clean" == "y" || "$confirm_clean" == "Y" ]]; then
      echo -e "[*] Membackup dan membersihkan direktori data..."
      mv .data.nockchain .data.nockchain.bak-$(date +%F-%H%M%S) 2>/dev/null
      echo -e "${GREEN}[+] Direktori data telah dibersihkan, backup disimpan sebagai .data.nockchain.bak-*${RESET}"
    fi
  fi

  # Default port
  LEADER_PORT=3005
  FOLLOWER_PORT=3006
  PORTS_TO_CHECK=("$LEADER_PORT" "$FOLLOWER_PORT")
  PORTS_OCCUPIED=false
  declare -A PID_PORT_MAP

  # Periksa penggunaan port
echo -e "[*] Memeriksa apakah port $LEADER_PORT dan $FOLLOWER_PORT sedang digunakan..."
if command -v lsof &> /dev/null; then
  for PORT in "${PORTS_TO_CHECK[@]}"; do
    PIDS=$(lsof -i :$PORT -t | sort -u)
    if [ -n "$PIDS" ]; then
      echo -e "${YELLOW}[!] Port $PORT sudah digunakan.${RESET}"
      for PID in $PIDS; do
        echo -e "${YELLOW}[!] Proses dengan PID: $PID menggunakan port $PORT${RESET}"
        PID_PORT_MAP[$PID]+="$PORT "
        PORTS_OCCUPIED=true
      done
    fi
  done
elif command -v netstat &> /dev/null; then
  for PORT in "${PORTS_TO_CHECK[@]}"; do
    PIDS=$(netstat -tulnp 2>/dev/null | grep ":$PORT " | awk '{print $7}' | cut -d'/' -f1 | sort -u)
    if [ -n "$PIDS" ]; then
      echo -e "${YELLOW}[!] Port $PORT sudah digunakan.${RESET}"
      for PID in $PIDS; do
        echo -e "${YELLOW}[!] Proses dengan PID: $PID menggunakan port $PORT${RESET}"
        PID_PORT_MAP[$PID]+="$PORT "
        PORTS_OCCUPIED=true
      done
    fi
  done
else
  echo -e "${RED}[-] Perintah lsof atau netstat tidak ditemukan, tidak dapat memeriksa port!${RESET}"
  pause_and_return
  return
fi

# Tangani port yang digunakan
if [ "$PORTS_OCCUPIED" = true ]; then
  echo -e "${YELLOW}[?] Terdeteksi port sedang digunakan, apakah ingin mematikan proses yang menggunakan port untuk membebaskan? (y/n)${RESET}"
  read -r confirm_kill
  if [[ "$confirm_kill" == "y" || "$confirm_kill" == "Y" ]]; then
    for PID in "${!PID_PORT_MAP[@]}"; do
      PORTS=${PID_PORT_MAP[$PID]}
      echo -e "[*] Mematikan proses dengan PID: $PID yang menggunakan port $PORTS..."
      if ! ps -p "$PID" -o user= | grep -q "^$USER$"; then
        echo -e "${YELLOW}[!] Proses PID $PID dimiliki pengguna lain, mencoba mematikan dengan sudo...${RESET}"
        sudo kill -9 "$PID" 2>/dev/null
      else
        kill -9 "$PID" 2>/dev/null
      fi
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Berhasil mematikan PID $PID, port $PORTS seharusnya sudah bebas.${RESET}"
      else
        echo -e "${RED}[-] Gagal mematikan PID $PID, silakan cek secara manual!${RESET}"
        pause_and_return
        return
      fi
    done
    # Verifikasi port sudah bebas
    echo -e "[*] Memverifikasi apakah port sudah bebas..."
    for PORT in "${PORTS_TO_CHECK[@]}"; do
      if command -v lsof &> /dev/null && lsof -i :$PORT -t >/dev/null 2>&1; then
        echo -e "${RED}[-] Port $PORT masih digunakan, silakan cek secara manual!${RESET}"
        pause_and_return
        return
      elif command -v netstat &> /dev/null && netstat -tuln | grep -q ":$PORT "; then
        echo -e "${RED}[-] Port $PORT masih digunakan, silakan cek secara manual!${RESET}"
        pause_and_return
        return
      fi
    done
  else
    echo -e "${RED}[-] Pengguna membatalkan mematikan proses, tidak bisa menjalankan Miner node!${RESET}"
    pause_and_return
    return
  fi
else
  echo -e "${GREEN}[+] Port $LEADER_PORT dan $FOLLOWER_PORT belum digunakan.${RESET}"
fi

# Bersihkan sesi screen miner yang ada
echo -e "[*] Membersihkan sesi screen miner yang ada..."
screen -ls | grep -q "miner" && screen -X -S miner quit

# Mulai Miner node
echo -e "[*] Memulai Miner node (menggunakan port $LEADER_PORT dan $FOLLOWER_PORT)..."
# Periksa apakah nockchain mendukung --leader-port dan --follower-port
if ./target/release/nockchain --help | grep -q -- "--leader-port"; then
  NOCKCHAIN_CMD="RUST_LOG=trace ./target/release/nockchain --mining-pubkey \"$PUBLIC_KEY\" --mine --leader-port $LEADER_PORT --follower-port $FOLLOWER_PORT"
else
  NOCKCHAIN_CMD="RUST_LOG=trace ./target/release/nockchain --mining-pubkey \"$PUBLIC_KEY\" --mine"
else
  NOCKCHAIN_CMD="sh ./scripts/run_nockchain_miner.sh"
fi

# Jalankan perintah nockchain di sesi screen, output tampil di screen dan file miner.log
echo -e "${GREEN}[+] Menjalankan node nockchain di sesi screen 'miner', log tersimpan di $NCK_DIR/miner.log${RESET}"
echo -e "${YELLOW}[!] Gunakan 'screen -r miner' untuk melihat output realtime, Ctrl+A lalu D untuk detach (node tetap berjalan)${RESET}"
screen -dmS miner bash -c "$NOCKCHAIN_CMD 2>&1 | tee miner.log"
sleep 2
if screen -ls | grep -q "miner"; then
  echo -e "${GREEN}[+] Miner node sudah berjalan di sesi screen 'miner', gunakan 'screen -r miner' untuk melihat${RESET}"
  echo -e "${GREEN}[+] Semua langkah berhasil diselesaikan!${RESET}"
  echo -e "Direktori saat ini: $(pwd)"
  echo -e "MINING_PUBKEY sudah diset: $PUBLIC_KEY"
  echo -e "Port Leader: $LEADER_PORT"
  echo -e "Port Follower: $FOLLOWER_PORT"
  if [[ -n "$create_wallet" && "$create_wallet" =~ ^[Yy]$ ]]; then
    echo -e "Kunci dompet sudah dibuat, harap simpan dengan baik!"
  fi
  # Periksa apakah proses masih berjalan
  if ! ps aux | grep -v grep | grep -q "nockchain.*--mine"; then
    echo -e "${RED}[-] Peringatan: proses nockchain mungkin sudah berhenti, silakan cek $NCK_DIR/miner.log${RESET}"
    echo -e "${YELLOW}[!] 10 baris terakhir log:${RESET}"
    tail -n 10 $NCK_DIR/miner.log 2>/dev/null || echo -e "${YELLOW}[!] file miner.log tidak ditemukan${RESET}"
  fi
else
  echo -e "${RED}[-] Gagal memulai Miner node! Silakan cek $NCK_DIR/miner.log${RESET}"
  echo -e "${YELLOW}[!] 10 baris terakhir log:${RESET}"
  tail -n 10 $NCK_DIR/miner.log 2>/dev/null || echo -e "${YELLOW}[!] file miner.log tidak ditemukan${RESET}"
fi
pause_and_return
}

# ========= Lihat log node =========
function view_logs() {
  echo -e "${BOLD}${BLUE}"
  echo "Lihat log node:"
  echo "  1) Miner node"
  echo "  0) Kembali ke menu utama"
  echo -e "${RESET}"
  read -p "Pilih log node yang ingin dilihat: " log_choice
  case "$log_choice" in
    1)
      if screen -list | grep -q "miner"; then
        screen -r miner
      else
        echo -e "${RED}[-] Miner node tidak berjalan!${RESET}"
      fi
      ;;
    0) pause_and_return ;;
    *) echo -e "${RED}[-] Pilihan tidak valid!${RESET}" ;;
  esac
  pause_and_return
}

# ========= Tunggu tekan tombol apa saja =========
function pause_and_return() {
  echo ""
  read -n1 -r -p "Tekan tombol apa saja untuk kembali ke menu utama..." key
  main_menu
}

# ========= Menu utama =========
function main_menu() {
  show_banner
  echo "Pilih operasi:"
  echo "  1) Pasang dependensi sistem"
  echo "  2) Pasang Rust"
  echo "  3) Siapkan repository"
  echo "  4) Kompilasi proyek dan atur variabel lingkungan"
  echo "  5) Buat dompet"
  echo "  6) Setel kunci publik untuk mining"
  echo "  7) Mulai Miner node"
  echo "  8) Backup kunci"
  echo "  9) Lihat log node"
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
    0) echo -e "${GREEN}Keluar.${RESET}"; exit 0 ;;
    *) echo -e "${RED}[-] Pilihan tidak valid!${RESET}"; pause_and_return ;;
  esac
}

# ========= Jalankan program utama =========
main_menu
