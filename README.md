# nocki

```bash
wget -O nock-install.sh https://raw.githubusercontent.com/Vivy110/nocki/refs/heads/main/nock-install1.sh && sed -i 's/\r$//' nock-install1.sh && chmod +x nock-install1.sh && ./nock-install1.sh
```
jika sudah install lewati step ke 5 
# FULL CORE SETUP
masuk direktori
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

cek berapa core yang sudah terpakai

```bash
htop
```


# DONE

https://x.com/diva_hashimoto
