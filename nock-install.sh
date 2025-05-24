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

# ========= Banner & Kredit =========
function show_banner() {
  clear
  echo -e "${BOLD}${BLUE}"
  echo "   ____  _____ ____    _    "
  echo "  |  _ \| ____|  _ \  / \   "
  echo "  | | | |  _| | | | |/ _ \  "
  echo "  | |_| | |___| |_| / ___ \ "
  echo "  |____/|_____|____/_/   \_\ "
  echo -e "${RESET}"
  echo "               Gabung Channel Telegram: Projek"
  echo "               GitHub Saya: Sok"
  echo "               Twitter Saya: Elit Kontl"
  echo "-----------------------------------------------"
  echo ""
}

# ========= Fungsi-fungsi =========
function pause_and_return() {
  echo ""
  read -n1 -r -p "Tekan tombol apapun untuk kembali ke menu utama..." key
  main_menu
}

function install_dependencies() {
  echo -e "${YELLOW}Menginstal dependensi yang dibutuhkan...${RESET}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git curl wget screen pkg-config libssl-dev libclang-dev make build-essential
  echo -e "${GREEN}Selesai menginstal dependensi.${RESET}"
  pause_and_return
}

function install_rust() {
  echo -e "${YELLOW}Memasang Rust...${RESET}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  rustup default stable
  echo -e "${GREEN}Rust telah berhasil dipasang.${RESET}"
  pause_and_return
}

function clone_project() {
  echo -e "${YELLOW}Mengkloning repositori Nockchain...${RESET}"
  if [ -d "$NCK_DIR" ]; then
    echo -e "${RED}Direktori nockchain sudah ada. Menghapus terlebih dahulu...${RESET}"
    rm -rf "$NCK_DIR"
  fi
  git clone https://github.com/Gzgod/nockchain.git "$NCK_DIR"
  echo -e "${GREEN}Repositori berhasil dikloning ke $NCK_DIR.${RESET}"
  pause_and_return
}

function build_project() {
  echo -e "${YELLOW}Membangun proyek Nockchain...${RESET}"
  cd "$NCK_DIR" || { echo "Gagal masuk direktori proyek."; return; }
  cargo build --release
  echo -e "${GREEN}Build selesai.${RESET}"
  pause_and_return
}

function run_node() {
  echo -e "${YELLOW}Menjalankan node dalam screen...${RESET}"
  cd "$NCK_DIR" || { echo "Gagal masuk direktori proyek."; return; }
  screen -dmS nockchain_node ./target/release/nockchain
  echo -e "${GREEN}Node sedang berjalan di dalam screen bernama 'nockchain_node'.${RESET}"
  echo "Gunakan perintah: screen -r nockchain_node untuk melihat log."
  pause_and_return
}

function node_status() {
  echo -e "${YELLOW}Memeriksa status screen...${RESET}"
  screen -ls
  echo -e "${YELLOW}Untuk mengakses: screen -r nockchain_node${RESET}"
  echo -e "${YELLOW}Untuk keluar tanpa menghentikan node: tekan Ctrl+A lalu D${RESET}"
  pause_and_return
}

function configure_mining_key() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  echo -e "${YELLOW}[*] Mengatur kunci mining...${RESET}"
  
  if [ -f "wallet_keys.txt" ]; then
    PUBLIC_KEY=$(grep -i "public key" wallet_keys.txt | awk '{print $NF}' | tail -1)
    echo -e "${GREEN}[+] Public key ditemukan:${RESET} $PUBLIC_KEY"
  else
    echo -e "${YELLOW}[!] File wallet_keys.txt tidak ditemukan${RESET}"
    read -p "Masukkan public key mining Anda: " PUBLIC_KEY
  fi

  if [ -z "$PUBLIC_KEY" ]; then
    echo -e "${RED}[-] Public key tidak valid!${RESET}"
    pause_and_return
    return
  fi

  if [ -f ".env" ]; then
    sed -i "s/^MINING_PUBKEY=.*/MINING_PUBKEY=$PUBLIC_KEY/" .env
    echo -e "${GREEN}[+] Berhasil mengupdate MINING_PUBKEY di .env${RESET}"
  else
    echo "MINING_PUBKEY=$PUBLIC_KEY" > .env
    echo -e "${GREEN}[+] File .env dibuat dengan MINING_PUBKEY${RESET}"
  fi

  echo -e "${YELLOW}[!] Pastikan untuk membackup file .env dan wallet_keys.txt${RESET}"
  pause_and_return
}

# ========= Menu Utama =========
function main_menu() {
  show_banner
  echo -e "${BOLD}${GREEN} Pilih opsi yang ingin dijalankan:${RESET}"
  echo "  1. Instal dependensi"
  echo "  2. Instal Rust"
  echo "  3. Clone repositori Nockchain"
  echo "  4. Build proyek Nockchain"
  echo "  5. Jalankan node"
  echo "  6. Cek status node"
  echo "  7. Atur kunci mining"
  echo "  0. Keluar"
  echo ""
  read -rp "Masukkan pilihan Anda: " choice

  case $choice in
    1) install_dependencies ;;
    2) install_rust ;;
    3) clone_project ;;
    4) build_project ;;
    5) run_node ;;
    6) node_status ;;
    7) configure_mining_key ;;
    0) echo -e "${BLUE}Keluar dari program.${RESET}"; exit 0 ;;
    *) echo -e "${RED}Pilihan tidak valid. Coba lagi.${RESET}"; pause_and_return ;;
  esac
}

# ========= Jalankan Menu =========
main_menu
