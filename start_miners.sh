#!/bin/bash

# ======= SETUP: buat folder scripts dan run_nockchain_miner.sh kalau belum ada =======
if [ ! -d "scripts" ]; then
  mkdir scripts
  echo "Folder scripts dibuat."
fi

if [ ! -f "scripts/run_nockchain_miner.sh" ]; then
  cat > scripts/run_nockchain_miner.sh <<'EOF'
#!/bin/bash

# Jalankan miner di folder node ini
PUB_KEY=$1
PEERS_ARGS=$2

export RUST_LOG='info,nockchain=info,nockchain_libp2p_io=info,libp2p=info,libp2p_quic=info'
export MINIMAL_LOG_FORMAT=true

nockchain --mine --mining-pubkey "$PUB_KEY" $PEERS_ARGS
EOF

  chmod +x scripts/run_nockchain_miner.sh
  echo "File scripts/run_nockchain_miner.sh dibuat otomatis."
fi

# ======= Input user =======
read -p "Masukkan public key mining: " PUB_KEY
read -p "Berapa jumlah miner yang ingin dijalankan? " NUM_MINERS
read -p "Masukkan tambahan peer id (boleh kosong, pisah spasi): " ADDITIONAL_PEERS

# ======= Loop buat folder node dan start miner pakai screen =======
for i in $(seq 1 $NUM_MINERS); do
  NODE_DIR="node$i"

  # Buat folder node kalau belum ada
  if [ ! -d "$NODE_DIR" ]; then
    mkdir "$NODE_DIR"
    echo "Folder $NODE_DIR dibuat."
  fi

  # Copy .env ke node folder
  cp .env "$NODE_DIR/" 2>/dev/null || echo ".env tidak ditemukan, skip copy."

  # Bersihkan data lama (jika ada)
  rm -rf "$NODE_DIR/.data.nockchain" "$NODE_DIR/.socket/nockchain_npc.sock" 2>/dev/null || true

  # Prepare argumen peers (dalam format --peer addr)
  PEERS_ARGS=""
  for p in $ADDITIONAL_PEERS; do
    PEERS_ARGS+=" --peer $p"
  done

  echo "Menjalankan miner di $NODE_DIR dengan screen session miner$i..."

  # Jalankan screen, kirim argumen PUB_KEY dan PEERS_ARGS ke run_nockchain_miner.sh
  screen -dmS "miner$i" bash -c "
    cd $NODE_DIR && \
    bash ../scripts/run_nockchain_miner.sh '$PUB_KEY' \"$PEERS_ARGS\"
  "

  # Delay 5 detik sebelum lanjut node berikutnya
  sleep 5
done

echo "Semua miner sudah dijalankan di background dengan screen session miner1 ... miner$NUM_MINERS."
echo "Gunakan 'screen -ls' untuk melihat session, dan 'screen -r minerX' untuk attach ke miner tertentu."
