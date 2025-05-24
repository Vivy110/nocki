# nocki

```bash
 wget -O nock-install.sh https://raw.githubusercontent.com/Vivy110/nocki/refs/heads/main/nock-install.sh && sed -i 's/\r$//' nock-install.sh && chmod +x nock-install.sh && ./nock-install.sh
```
- jika sudah memiliki pubkey lewati step ke 5 
- langsung ke step 6 dan 7

# FULL CORE SETUP
masuk direktori
```bash
sudo sysctl -w vm.overcommit_memory=1
```
```bash
cd nockchain
```
buat direktori node1 node2 dst.
```bash
mkdir node1 node2
```
copy .env ke direktori 
```bash
cp .env node1/
cp .env node2/
```
```bash
screen -S miner1
```
run dengan bash 
```bash
cd node1 && bash ../scripts/run_nockchain_miner.sh
```

# NOTE: jika ingin memakai banyak core silahkan ulangi dari screen dan ubah nama miner sesuai dengan yang telah di buat 


FULL CORE OTOMATIS 
note: belum stabil
```bash
cd nockchain
nano start-miner.sh
```
```bash
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
```
```bash
chmod +x start-miner.sh
./start-miner.sh
```
cek berapa core yang sudah terpakai

```bash
htop
```


# DONE

https://x.com/diva_hashimoto
