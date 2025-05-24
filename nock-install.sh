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
  echo "               Ikuti channel TG: t.me/xuegaoz"
  echo "               GitHub saya: github.com/Gzgod"
  echo "               Twitter saya: Twitter Xuegao战神@Xuegaogx"
  echo "-----------------------------------------------"
  echo ""
}

# ========= Tunggu tombol untuk melanjutkan =========
function pause_and_return() {
  echo ""
  read -n1 -r -p "Tekan tombol apa saja untuk kembali ke menu utama..." key
  main_menu
}

# ========= Instal dependensi sistem =========
function install_dependencies() {
  if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}[-] Skrip ini mengasumsikan sistem Debian/Ubuntu (apt). Silakan instal dependensi secara manual!${RESET}"
    pause_and_return
    return
  fi
  echo -e "[*] Memperbarui sistem dan menginstal dependensi..."
  apt-get update && apt-get upgrade -y
  sudo apt install -y curl git make clang llvm-dev libclang-dev screen
  echo -e "${GREEN}[+] Dependensi berhasil diinstal.${RESET}"
  pause_and_return
}

# ========= Instal Rust =========
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

# ========= Setup repositori =========
function setup_repository() {
  echo -e "[*] Memeriksa repositori nockchain..."
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
    echo -e "${RED}[-] Gagal mengclone repositori, periksa jaringan atau izin!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  if [ -f ".env" ]; then
    cp .env .env.bak
    echo -e "[*] .env telah dicadangkan sebagai .env.bak"
  fi
  if [ -f ".env_example" ]; then
    cp .env_example .env
    echo -e "${GREEN}[+] File lingkungan .env telah dibuat.${RESET}"
  else
    echo -e "${RED}[-] File .env_example tidak ditemukan, periksa repositori!${RESET}"
  fi
  echo -e "${GREEN}[+] Setup repositori selesai.${RESET}"
  pause_and_return
}

# ========= Kompilasi proyek dan konfigurasi variabel lingkungan =========
function build_and_configure() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
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
    source "$RC_FILE" || echo -e "${YELLOW}[!] Tidak dapat langsung menerapkan variabel lingkungan, silakan jalankan source $RC_FILE secara manual atau buka terminal baru.${RESET}"
  else
    source "$RC_FILE" || echo -e "${YELLOW}[!] Tidak dapat langsung menerapkan variabel lingkungan, silakan jalankan source $RC_FILE secara manual atau buka terminal baru.${RESET}"
  fi
  echo -e "${GREEN}[+] Kompilasi dan konfigurasi variabel lingkungan selesai.${RESET}"
  pause_and_return
}

# ========= Buat dompet =========
function generate_wallet() {
  if [ ! -d "$NCK_DIR" ] || [ ! -f "$NCK_DIR/target/release/nockchain-wallet" ]; then
    echo -e "${RED}[-] Perintah dompet tidak ditemukan atau direktori nockchain tidak ada, jalankan opsi 3 dan 4 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Membuat pasangan kunci dompet..."
  read -p "[?] Buat dompet? [Y/n]: " create_wallet
  create_wallet=${create_wallet:-y}
  if [[ ! "$create_wallet" =~ ^[Yy]$ ]]; then
    echo -e "[*] Pembuatan dompet dilewati."
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, periksa direktori target/release atau proses build!${RESET}"
    pause_and_return
    return
  fi
  nockchain-wallet keygen > wallet_keys.txt 2>&1 || { echo -e "${RED}[-] Gagal menjalankan nockchain-wallet keygen!${RESET}"; pause_and_return; return; }
  echo -e "${GREEN}[+] Kunci dompet telah disimpan ke $NCK_DIR/wallet_keys.txt, simpan dengan aman!${RESET}"
  PUBLIC_KEY=$(grep -i "public key" wallet_keys.txt | awk '{print $NF}' | tail -1)
  if [ -n "$PUBLIC_KEY" ]; then
    echo -e "${YELLOW}Kunci Publik:${RESET}\n$PUBLIC_KEY"
    echo -e "${YELLOW}[!] Gunakan opsi 6 untuk mengatur kunci publik penambangan atau tambahkan secara manual ke file $NCK_DIR/.env:${RESET}"
    echo -e "MINING_PUBKEY=$PUBLIC_KEY"
  else
    echo -e "${RED}[-] Tidak dapat mengekstrak kunci publik, periksa wallet_keys.txt!${RESET}"
  fi
  echo -e "${GREEN}[+] Pembuatan dompet selesai.${RESET}"
  pause_and_return
}

# ========= Atur kunci penambangan =========
function configure_mining_key() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mengatur kunci publik penambangan (MINING_PUBKEY)..."
  read -p "[?] Masukkan MINING_PUBKEY Anda (dapat diperoleh dari opsi 5): " public_key
  if [ -z "$public_key" ]; then
    echo -e "${RED}[-] MINING_PUBKEY tidak diberikan, masukkan kunci publik yang valid!${RESET}"
    pause_and_return
    return
  fi
  if [ ! -f ".env" ]; then
    echo -e "${RED}[-] File .env tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  if ! grep -q "^MINING_PUBKEY=" .env; then
    echo "MINING_PUBKEY=$public_key" >> .env
  else
    sed -i "s|^MINING_PUBKEY=.*|MINING_PUBKEY=$public_key|" .env || {
      echo -e "${RED}[-] Gagal memperbarui MINING_PUBKEY di file .env!${RESET}"
      pause_and_return
      return
    }
  fi
  if grep -q "^MINING_PUBKEY=$public_key$" .env; then
    echo -e "${GREEN}[+] MINING_PUBKEY di file .env berhasil diperbarui!${RESET}"
  else
    echo -e "${RED}[-] Gagal memperbarui file .env, periksa isi file!${RESET}"
  fi
  echo -e "${GREEN}[+] Pengaturan kunci penambangan selesai.${RESET}"
  pause_and_return
}

# ========= Mulai node (Miner atau Non-Miner) =========
function start_node() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  # Verifikasi apakah perintah nockchain tersedia
  echo -e "[*] Memverifikasi perintah nockchain..."
  if ! command -v nockchain &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain tidak tersedia, periksa apakah opsi 4 berhasil!${RESET}"
    echo -e "${YELLOW}[!] Pastikan \$PATH mencakup $HOME/.cargo/bin, jalankan 'source ~/.bashrc' atau buka terminal baru${RESET}"
    pause_and_return
    return
  fi

  # Verifikasi apakah perintah screen tersedia
  echo -e "[*] Memverifikasi perintah screen..."
  if ! command -v screen &> /dev/null; then
    echo -e "${RED}[-] Perintah screen tidak tersedia, pastikan screen sudah diinstal (jalankan opsi 1 atau instal manual)!${RESET}"
    pause_and_return
    return
  fi

  # Pilih tipe node
  echo -e "[*] Pilih tipe node:"
  echo -e "  1) Node Miner (penambangan)"
  echo -e "  2) Node Non-Miner (hanya menjalankan node)"
  read -p "[?] Masukkan nomor (1/2): " node_type
  if [[ "$node_type" != "1" && "$node_type" != "2" ]]; then
    echo -e "${RED}[-] Opsi tidak valid, pilih 1 atau 2!${RESET}"
    pause_and_return
    return
  fi

  # Set direktori kerja
  echo -e "[*] Masukkan direktori kerja node (default: $NCK_DIR)..."
  read -p "[?] Direktori kerja [$NCK_DIR]: " work_dir
  work_dir=${work_dir:-$NCK_DIR}
  if [ ! -d "$work_dir" ]; then
    echo -e "[*] Membuat direktori kerja $work_dir..."
    mkdir -p "$work_dir" || { echo -e "${RED}[-] Gagal membuat direktori kerja!${RESET}"; pause_and_return; return; }
    cp "$NCK_DIR/.env" "$work_dir/.env" 2>/dev/null || echo -e "${YELLOW}[!] File .env tidak ditemukan, pastikan opsi 3 sudah dijalankan!${RESET}"
  fi
  cd "$work_dir" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori kerja $work_dir!${RESET}"; pause_and_return; return; }

  # Jika node Miner, dapatkan kunci publik
  public_key=""
  if [ "$node_type" = "1" ]; then
    if [ -f ".env" ]; then
      public_key=$(grep "^MINING_PUBKEY=" .env | cut -d'=' -f2)
      if [ -z "$public_key" ]; then
        echo -e "${YELLOW}[!] MINING_PUBKEY tidak ditemukan di file .env, gunakan opsi 6 untuk mengatur atau masukkan secara manual.${RESET}"
        read -p "[?] Masukkan MINING_PUBKEY Anda (dapat diperoleh dari opsi 5): " public_key
        if [ -z "$public_key" ]; then
          echo -e "${RED}[-] MINING_PUBKEY tidak diberikan, masukkan kunci publik yang valid!${RESET}"
          pause_and_return
          return
        fi
      else
        echo -e "[*] Menggunakan MINING_PUBKEY dari file .env: $public_key"
      fi
    else
      echo -e "${YELLOW}[!] File .env tidak ada, gunakan opsi 6 untuk mengatur atau masukkan MINING_PUBKEY secara manual.${RESET}"
      read -p "[?] Masukkan MINING_PUBKEY Anda (dapat diperoleh dari opsi 5): " public_key
      if [ -z "$public_key" ]; then
        echo -e "${RED}[-] MINING_PUBKEY tidak diberikan, masukkan kunci publik yang valid!${RESET}"
        pause_and_return
        return
      fi
    fi
  fi

  # Prompt untuk membersihkan direktori data
  if [ -d ".data.nockchain" ]; then
    echo -e "${YELLOW}[?] Direktori data .data.nockchain terdeteksi, bersihkan untuk inisialisasi ulang? (y/n)${RESET}"
    read -r confirm_clean
    if [[ "$confirm_clean" == "y" || "$confirm_clean" == "Y" ]]; then
      echo -e "[*] Mencadangkan dan membersihkan direktori data..."
      mv .data.nockchain .data.nockchain.bak-$(date +%F-%H%M%S) 2>/dev/null
      echo -e "${GREEN}[+] Direktori data telah dibersihkan, dicadangkan ke .data.nockchain.bak-*${RESET}"
    fi
  fi

  # Set port
  echo -e "[*] Masukkan port node (default Leader: 3005, Follower: 3006)..."
  read -p "[?] Port Leader [3005]: " LEADER_PORT
  LEADER_PORT=${LEADER_PORT:-3005}
  read -p "[?] Port Follower [3006]: " FOLLOWER_PORT
  FOLLOWER_PORT=${FOLLOWER_PORT:-3006}
  PORTS_TO_CHECK=("$LEADER_PORT" "$FOLLOWER_PORT")
  PORTS_OCCUPIED=false
  declare -A PID_PORT_MAP

  # Set alamat binding
  echo -e "[*] Masukkan alamat binding P2P (contoh /ip4/0.0.0.0/udp/$FOLLOWER_PORT/quic-v1, jika di belakang NAT masukkan IP publik)..."
  read -p "[?] Alamat binding [/ip4/0.0.0.0/udp/$FOLLOWER_PORT/quic-v1]: " bind_addr
  bind_addr=${bind_addr:-/ip4/0.0.0.0/udp/$FOLLOWER_PORT/quic-v1}

  # Periksa port yang digunakan
  echo -e "[*] Memeriksa apakah port $LEADER_PORT dan $FOLLOWER_PORT sedang digunakan..."
  if command -v lsof &> /dev/null; then
    for PORT in "${PORTS_TO_CHECK[@]}"; do
      PIDS=$(lsof -i :$PORT -t | sort -u)
      if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}[!] Port $PORT sedang digunakan.${RESET}"
        for PID in $PIDS; do
          echo -e "${YELLOW}[!] Proses yang menggunakan port $PORT PID: $PID${RESET}"
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
          echo -e "${YELLOW}[!] Proses yang menggunakan port $PORT PID: $PID${RESET}"
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
    echo -e "${YELLOW}[?] Port sedang digunakan, apakah ingin menghentikan proses untuk membebaskan port? (y/n)${RESET}"
    read -r confirm_kill
    if [[ "$confirm_kill" == "y" || "$confirm_kill" == "Y" ]]; then
      for PID in "${!PID_PORT_MAP[@]}"; do
        PORTS=${PID_PORT_MAP[$PID]}
        echo -e "[*] Menghentikan proses yang menggunakan port $PORTS (PID: $PID)..."
        if ! ps -p "$PID" -o user= | grep -q "^$USER$"; then
          echo -e "${YELLOW}[!] Proses PID $PID dimiliki oleh pengguna lain, mencoba menggunakan sudo untuk menghentikan...${RESET}"
          sudo kill -9 "$PID" 2>/dev/null
        else
          kill -9 "$PID" 2>/dev/null
        fi
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}[+] Berhasil menghentikan PID $PID, port $PORTS seharusnya sudah bebas.${RESET}"
        else
          echo -e "${RED}[-] Gagal menghentikan PID $PID, periksa secara manual!${RESET}"
          pause_and_return
          return
        fi
      done
      echo -e "[*] Memverifikasi apakah port sudah bebas..."
      for PORT in "${PORTS_TO_CHECK[@]}"; do
        if command -v lsof &> /dev/null && lsof -i :$PORT -t >/dev/null 2>&1; then
          echo -e "${RED}[-] Port $PORT masih digunakan, periksa secara manual!${RESET}"
          pause_and_return
          return
        elif command -v netstat &> /dev/null && netstat -tuln | grep -q ":$PORT "; then
          echo -e "${RED}[-] Port $PORT masih digunakan, periksa secara manual!${RESET}"
          pause_and_return
          return
        fi
      done
    else
      echo -e "${RED}[-] Pengguna membatalkan penghentian proses, tidak dapat memulai node!${RESET}"
      pause_and_return
      return
    fi
  else
    echo -e "${GREEN}[+] Port $LEADER_PORT dan $FOLLOWER_PORT tidak digunakan.${RESET}"
  fi

  # Set level log
  echo -e "[*] Pilih level log:"
  echo -e "  1) info (rekomendasi, informasi reguler)"
  echo -e "  2) debug (informasi debugging)"
  echo -e "  3) trace (informasi debugging detail)"
  read -p "[?] Masukkan nomor (1/2/3) [1]: " log_level_choice
  case "$log_level_choice" in
    2) log_level="debug" ;;
    3) log_level="trace" ;;
    *) log_level="info" ;;
  esac
  if [ -f ".env" ]; then
    if ! grep -q "^RUST_LOG=" .env; then
      echo "RUST_LOG=$log_level" >> .env
    else
      sed -i "s|^RUST_LOG=.*|RUST_LOG=$log_level|" .env
    fi
  fi
  echo -e "[*] Level log diatur ke: $log_level"

  # Tanya apakah ingin output ke miner.log
  echo -e "${YELLOW}[?] Apakah ingin menulis log ke file miner.log? (Peringatan: file log dapat memakan banyak ruang disk, pilih dengan hati-hati!) [y/N]${RESET}"
  read -r log_to_file
  log_to_file=${log_to_file:-n}
  if [[ "$log_to_file" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}[+] Log akan ditulis ke $work_dir/miner.log, bersihkan secara berkala untuk menghindari kehabisan ruang disk!${RESET}"
    log_output="2>&1 | tee -a miner.log"
  else
    echo -e "${YELLOW}[!] Tidak menulis miner.log, log hanya disimpan di log screen $work_dir/screen_$session_name.log${RESET}"
    log_output="2>&1"
  fi

  # Bersihkan sesi screen yang ada
  if [ "$node_type" = "1" ]; then
    session_name="miner"
  else
    session_name="node"
  fi
  echo -e "[*] Membersihkan sesi screen $session_name yang ada..."
  screen -ls | grep -q "$session_name" && screen -X -S "$session_name" quit

  # Mulai node
  echo -e "[*] Memulai node..."
  if [ "$node_type" = "1" ]; then
    script="$NCK_DIR/scripts/run_nockchain_miner.sh"
  else
    script="$NCK_DIR/scripts/run_nockchain_node.sh"
  fi
  if [ ! -f "$script" ]; then
    echo -e "${RED}[-] $script tidak ditemukan, periksa repositori nockchain!${RESET}"
    pause_and_return
    return
  fi
  chmod +x "$script"
  echo -e "${GREEN}[+] Memulai node di sesi screen '$session_name', log screen ditulis ke $work_dir/screen_$session_name.log${RESET}"
  echo -e "${YELLOW}[!] Gunakan 'screen -r $session_name' untuk melihat output real-time node, Ctrl+A lalu D untuk keluar dari screen (node tetap berjalan)${RESET}"
  screen -dmS "$session_name" -L -Logfile "$work_dir/screen_$session_name.log" bash -c "source $HOME/.bashrc; sh $script --bind \"$bind_addr\" $log_output; echo 'Node telah berhenti, lihat log screen: $work_dir/screen_$session_name.log'; sleep 30"

  # Tunggu cukup waktu untuk memastikan sesi screen terinisialisasi
  sleep 5

  # Periksa apakah sesi screen berjalan
  if screen -ls | grep -q "$session_name"; then
    echo -e "${GREEN}[+] Node berjalan di sesi screen '$session_name', gunakan 'screen -r $session_name' untuk melihat${RESET}"
    echo -e "${GREEN}[+] Semua langkah berhasil diselesaikan!${RESET}"
    echo -e "Direktori kerja: $work_dir"
    [ -n "$public_key" ] && echo -e "MINING_PUBKEY：$public_key"
    echo -e "Port Leader：$LEADER_PORT"
    echo -e "Port Follower：$FOLLOWER_PORT"
    echo -e "Alamat binding：$bind_addr"
    if [ -f "wallet_keys.txt" ]; then
      echo -e "Kunci dompet telah dibuat, disimpan di $work_dir/wallet_keys.txt, simpan dengan aman!"
    fi
    # Periksa apakah miner.log ada isinya (jika diaktifkan)
    if [[ "$log_to_file" =~ ^[Yy]$ ]] && [ -f "miner.log" ] && [ -s "miner.log" ]; then
      echo -e "${YELLOW}[!] Isi miner.log (10 baris terakhir):${RESET}"
      tail -n 10 miner.log
    elif [[ "$log_to_file" =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}[!] File miner.log belum dibuat atau kosong, periksa nanti atau gunakan 'screen -r $session_name' untuk melihat output real-time${RESET}"
    fi
    # Periksa log screen
    if [ -f "$work_dir/screen_$session_name.log" ] && [ -s "$work_dir/screen_$session_name.log" ]; then
      echo -e "${YELLOW}[!] Isi screen_$session_name.log (10 baris terakhir):${RESET}"
      tail -n 10 "$work_dir/screen_$session_name.log"
    else
      echo -e "${YELLOW}[!] File screen_$session_name.log belum dibuat atau kosong, mungkin ada masalah dengan output screen${RESET}"
    fi
  else
    echo -e "${RED}[-] Gagal memulai node! Periksa $work_dir/screen_$session_name.log${RESET}"
    if [[ "$log_to_file" =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}[!] 10 baris terakhir miner.log:${RESET}"
      tail -n 10 "$work_dir/miner.log" 2>/dev/null || echo -e "${YELLOW}[!] miner.log tidak ditemukan${RESET}"
    fi
    echo -e "${YELLOW}[!] 10 baris terakhir screen_$session_name.log:${RESET}"
    tail -n 10 "$work_dir/screen_$session_name.log" 2>/dev/null || echo -e "${YELLOW}[!] screen_$session_name.log tidak ditemukan${RESET}"
  fi
  pause_and_return
}

# ========= Cadangkan kunci =========
function backup_keys() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, jalankan opsi 4 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }
  echo -e "[*] Mencadangkan kunci..."
  nockchain-wallet export-keys > keys.export 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Kunci berhasil dicadangkan! Disimpan ke $NCK_DIR/keys.export${RESET}"
    echo -e "${YELLOW}[!] Simpan file ini dengan aman, jangan sampai bocor!${RESET}"
  else
    echo -e "${RED}[-] Gagal mencadangkan kunci, periksa output perintah nockchain-wallet export-keys!${RESET}"
    echo -e "${YELLOW}[!] Detail lihat $NCK_DIR/keys.export${RESET}"
  fi
  pause_and_return
}

# ========= Lihat log node =========
function view_logs() {
  LOG_FILE="$NCK_DIR/miner.log"
  if [ -f "$LOG_FILE" ]; then
    echo -e "${GREEN}[+] Menampilkan file log: $LOG_FILE${RESET}"
    tail -f "$LOG_FILE"
  else
    echo -e "${RED}[-] File log $LOG_FILE tidak ada, pastikan opsi 7 sudah dijalankan dan output miner.log diaktifkan!${RESET}"
    echo -e "${YELLOW}[!] Anda dapat memeriksa log screen $NCK_DIR/screen_miner.log atau $NCK_DIR/screen_node.log${RESET}"
  fi
  pause_and_return
}

# ========= Periksa saldo =========
function check_balance() {
  if [ ! -d "$NCK_DIR" ]; then
    echo -e "${RED}[-] Direktori nockchain tidak ada, jalankan opsi 3 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  if ! command -v nockchain-wallet &> /dev/null; then
    echo -e "${RED}[-] Perintah nockchain-wallet tidak tersedia, jalankan opsi 4 terlebih dahulu!${RESET}"
    pause_and_return
    return
  fi
  cd "$NCK_DIR" || { echo -e "${RED}[-] Tidak dapat masuk ke direktori nockchain!${RESET}"; pause_and_return; return; }

  # Periksa file socket
  SOCKET_PATH="$NCK_DIR/nockchain.sock"
  if [ ! -S "$SOCKET_PATH" ]; then
    echo -e "${RED}[-] File socket $SOCKET_PATH tidak ada, pastikan node nockchain sedang berjalan (coba opsi 7)!${RESET}"
    pause_and_return
    return
  fi

  # Dapatkan kunci publik
  public_key=""
  if [ -f ".env" ]; then
    public_key=$(grep "^MINING_PUBKEY=" .env | cut -d'=' -f2)
  fi

  # Jalankan query saldo
  echo -e "[*] Memeriksa saldo..."
  echo -e "${YELLOW}[!] Memeriksa semua UTXOs...${RESET}"
  nockchain-wallet --nockchain-socket "$SOCKET_PATH" list-notes > balance_output.txt 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Query semua UTXOs berhasil!${RESET}"
    echo -e "----------------------------------------"
    cat balance_output.txt
    echo -e "----------------------------------------"
  else
    echo -e "${RED}[-] Query semua UTXOs gagal, periksa perintah nockchain-wallet atau status node!${RESET}"
    echo -e "${YELLOW}[!] Detail lihat $NCK_DIR/balance_output.txt${RESET}"
  fi

  if [ -n "$public_key" ]; then
    echo -e "${YELLOW}[!] Mengecek UTXOs untuk kunci publik $public_key...${RESET}"
    nockchain-wallet --nockchain-socket "$SOCKET_PATH" list-notes-by-pubkey "$public_key" > balance_output_pubkey.txt 2>&1
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}[+] Pengecekan UTXOs kunci publik berhasil!${RESET}"
      echo -e "----------------------------------------"
      cat balance_output_pubkey.txt
      echo -e "----------------------------------------"
    else
      echo -e "${RED}[-] Gagal mengecek UTXOs kunci publik, periksa kunci publik atau status node!${RESET}"
      echo -e "${YELLOW}[!] Detail lihat $NCK_DIR/balance_output_pubkey.txt${RESET}"
    fi
  else
    echo -e "${YELLOW}[!] MINING_PUBKEY tidak ditemukan, tidak bisa mengecek UTXOs kunci publik tertentu!${RESET}"
  fi
  pause_and_return
}

# ========= Menu Utama =========
function main_menu() {
  show_banner
  echo "Pilih operasi:"
  echo "  1) Instal dependensi sistem"
  echo "  2) Instal Rust"
  echo "  3) Setup repositori"
  echo "  4) Kompilasi proyek dan konfigurasi variabel lingkungan"
  echo "  5) Buat dompet"
  echo "  6) Atur kunci penambangan"
  echo "  7) Mulai node (Miner atau Non-Miner)"
  echo "  8) Cadangkan kunci"
  echo "  9) Lihat log node"
  echo " 10) Cek saldo"
  echo "  0) Keluar"
  echo ""
  read -p "Masukkan pilihan: " choice
  case "$choice" in
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
    0) echo -e "${GREEN}Keluar.${RESET}"; exit 0 ;;
    *) echo -e "${RED}[-] Pilihan tidak valid!${RESET}"; pause_and_return ;;
  esac
}

# ========= Jalankan Program Utama =========
main_menu



      
