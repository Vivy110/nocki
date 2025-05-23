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
  echo "                                                     
echo "██████╗ ██╗██╗   ██╗   █████╗ "
echo "██╔══██╗██║██║   ██║ ██╔══██╗"
echo "██║  ██║ ██║██║   ██║ ███████║"
echo "██║  ██║ ██║╚██╗ ██╔╝██╔══██║"
echo "██████╔╝██║ ╚████╔╝  ██║  ██║"
echo "╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝"                                                                                                   \::/                                                      \/____/
  echo -e "${RESET}"
  echo "               Gabung ke Channel TG: "
  echo "               GitHub saya: "
  echo "               Twitter saya: "
  echo "-----------------------------------------------"
  echo ""
}

# ========= Tunggu Tombol untuk Lanjut =========
function pause_and_return() {
  echo ""
  read -n1 -r -p "Tekan tombol apapun untuk kembali ke menu utama..." key
  main_menu
}

# ========= Instalasi Dependensi =========
function install_dependencies() {
  echo -e "${YELLOW}Menginstal dependensi yang dibutuhkan...${RESET}"
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git curl wget screen pkg-config libssl-dev libclang-dev make build-essential
  echo -e "${GREEN}Selesai menginstal dependensi.${RESET}"
  pause_and_return
}

# ========= Instalasi Rust =========
function install_rust() {
  echo -e "${YELLOW}Memasang Rust...${RESET}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  rustup default stable
  echo -e "${GREEN}Rust telah berhasil dipasang.${RESET}"
  pause_and_return
}

# ========= Clone Proyek =========
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

# ========= Build Proyek =========
function build_project() {
  echo -e "${YELLOW}Membangun proyek Nockchain...${RESET}"
  cd "$NCK_DIR" || { echo "Gagal masuk direktori proyek."; return; }
  cargo build --release
  echo -e "${GREEN}Build selesai.${RESET}"
  pause_and_return
}

# ========= Menjalankan Node =========
function run_node() {
  echo -e "${YELLOW}Menjalankan node dalam screen...${RESET}"
  cd "$NCK_DIR" || { echo "Gagal masuk direktori proyek."; return; }
  screen -dmS nockchain_node ./target/release/nockchain
  echo -e "${GREEN}Node sedang berjalan di dalam screen bernama 'nockchain_node'.${RESET}"
  echo "Gunakan perintah: screen -r nockchain_node untuk melihat log."
  pause_and_return
}

# ========= Menampilkan Status Node =========
function node_status() {
  echo -e "${YELLOW}Memeriksa status screen...${RESET}"
  screen -ls
  echo -e "${YELLOW}Untuk mengakses: screen -r nockchain_node${RESET}"
  echo -e "${YELLOW}Untuk keluar tanpa menghentikan node: tekan Ctrl+A lalu D${RESET}"
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
    0) echo -e "${BLUE}Keluar dari program.${RESET}"; exit 0 ;;
    *) echo -e "${RED}Pilihan tidak valid. Coba lagi.${RESET}"; pause_and_return ;;
  esac
}

# ========= Jalankan Menu =========
main_menu
