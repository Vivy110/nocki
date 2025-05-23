# nocki

```bash
wget -O nock-install.sh https://raw.githubusercontent.com/Vivy110/nocki/refs/heads/main/nock-install.sh && sed -i 's/\r$//' nock-install.sh && chmod +x nock-install.sh && ./nock-install.sh
```

# FULL CORE SETUP
buat dockerfile di folder nockchain
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
run dengan bash 
```bash
cd node1 && bash ../scripts/run_nockchain_miner.sh
cd node2 && bash ../scripts/run_nockchain_miner.sh
```
cek berapa core yang sudah terpakai

```bash
htop
```


# DONE

https://x.com/diva_hashimoto
