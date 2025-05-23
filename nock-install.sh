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
  echo "   _____  _____  __   __   _____  "
  echo "  / ____||_   _||  \ |  | / ____| "
  echo " | |       | |  |   \|  || (___   "
  echo " | |       | |  | |\    | \___ \  "
  echo " | |____  _| |_ | | \   | ____) | "
  echo "  \_____||_____||_|  \__||_____/  "
  echo -e "${RESET}"
  echo "               Gabung Channel Telegram: Projek "
  echo "               GitHub Saya: Sok "
  echo "               Twitter Saya: Elit Kontl "
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
  if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}[-] Skrip ini mengasumsikan sistem Debian/Ubuntu (apt). Silakan instal dependensi secara manual!${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Memperbarui sistem dan menginstal dependensi..."
  apt-get update && apt-get upgrade -y
  sudo apt install -y curl git make clang llvm-dev libclang-dev screen
  echo -e "${GREEN}[+] Dependensi selesai diinstal.${RESET}"
  pause_and_return
}

# ========= Instalasi Rust =========
function install_rust() {
  if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}[!] Rust sudah terinstal, melewati instalasi.${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Menginstal Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env" || { echo -e "${RED}[-] Gagal mengkonfigurasi variabel lingkungan Rust!${RESET}"; pause_and_return; return; }
  rustup default stable
  echo -e "${GREEN}[+] Rust berhasil diinstal.${RESET}"
  pause_and_return
}

# ========= Setup Repository =========
function setup_repository() {
  echo -e "[*] Memeriksa repository nockchain..."
  if [ -d "$NCK_DIR" ]; then
    echo -e "${YELLOW}[?] Direktori nockchain sudah ada, hapus dan clone ulang? (y/n)${RESET}"
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
    echo -e "${RED}[-] Gagal mengclone repository, periksa jaringan atau izin!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  if [ -f ".env" ]; then
    cp .env .env.bak
    echo -e "[*] .env telah dibackup sebagai .env.bak"
  fi
  if [ -f ".env_example" ]; then
    cp .env_example .env
    echo -e "${GREEN}[+] File lingkungan .env telah dibuat.${RESET}"
  else
    echo -e "${RED}[-] File .env_example tidak ditemukan, periksa repository!${RESET}"
  fi
  echo -e "${GREEN}[+] Setup repository selesai.${RESET}"
  pause_and_return
}

# ========= Kompilasi Proyek =========
function build_and_configure() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Gagal masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengkompilasi komponen inti..."
  make install-hoonc || { echo -e "${RED}[-] Gagal menjalankan make install-hoonc, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  if command -v hoonc &> /dev/null; then
    echo -e "[*] hoonc berhasil diinstal, perintah tersedia: hoonc"
  else
    echo -e "${YELLOW}[!] Peringatan: perintah hoonc tidak tersedia, instalasi mungkin tidak lengkap.${RESET}"
  fi
  make build || { echo -e "${RED}[-] Gagal menjalankan make build, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  make install-nockchain-wallet || { echo -e "${RED}[-] Gagal menjalankan make install-nockchain-wallet, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  make install-nockchain || { echo -e "${RED}[-] Gagal menjalankan make install-nockchain, periksa Makefile atau dependensi!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengkonfigurasi variabel lingkungan..."
  RC_FILE="$HOME/.bashrc"
  [[ "$SHELL" == *"zsh"* ]] && RC_FILE="$HOME/.zshrc"
  if ! grep -q "$HOME/.cargo/bin" "$RC_FILE"; then
    echo "export PATH=\"\$PATH:$HOME/.cargo/bin\"" >> "$RC_FILE"
    source "$RC_FILE" || echo -e "${YELLOW}[!] Tidak dapat menerapkan variabel lingkungan segera, jalankan source $RC_FILE secara manual atau buka terminal baru.${RESET}"
  else
    source "$RC_FILE" || echo -e "${YELLOW}[!] Tidak dapat menerapkan variabel lingkungan segera, jalankan source $RC_FILE secara manual atau buka terminal baru.${RESET}"
  fi
  echo -e "${GREEN}[+] Kompilasi dan konfigurasi lingkungan selesai.${RESET}"
  pause_and_return
}

# ========= Menu Utama =========
function main_menu() {
  show_banner
  echo -e "${BOLD}${GREEN} Pilih opsi yang ingin dijalankan:${RESET}"
  echo "  1. Instal dependensi sistem"
  echo "  2. Instal Rust"
  echo "  3. Setup repository Nockchain"
  echo "  4. Kompilasi proyek Nockchain"
  echo "  5. Buat dompet"
  echo "  6. Atur kunci mining"
  echo "  7. Jalankan node"
  echo "  8. Backup kunci"
  echo "  9. Lihat log node"
  echo "  10. Cek saldo"
  echo "  0. Keluar"
  echo ""
  read -rp "Masukkan pilihan Anda: " choice

  case $choice in
    1) install_dependencies ;;
    2) install_rust ;;
    3) setup_repository ;;
    4) build_and_configure ;;
    5) generate_wallet ;;
    6) configure_mining_key ;;
    7) start_node ;;
    8) backup_keys ;;
    9) view_logs ;;
    10) check_balance ;;
    0) echo -e "${BLUE}Keluar dari program.${RESET}"; exit 0 ;;
    *) echo -e "${RED}Pilihan tidak valid. Coba lagi.${RESET}"; pause_and_return ;;
  esac
}

# ========= Jalankan Menu =========
main_menu
