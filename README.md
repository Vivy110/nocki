# nocki

```bash
wget -O nock-install.sh https://raw.githubusercontent.com/Vivy110/nocki/refs/heads/main/nock-install.sh && sed -i 's/\r$//' nock-install.sh && chmod +x nock-install.sh && ./nock-install.sh
```

# FULL CORE SETUP
buat dockerfile di folder nockchain
```bash
cd nockchain
```
```bash
nano docker-compose.yml
```
paste di docker-compose.yml
```bash
version: '3.8'

services:
  nock1:
    build: .
    ports:
      - "3005:3005"
      - "3006:3006"

  nock2:
    build: .
    ports:
      - "3015:3005"
      - "3016:3006"

  nock3:
    build: .
    ports:
      - "3025:3005"
      - "3026:3006"

  nock4:
    build: .
    ports:
      - "3035:3005"
      - "3036:3006"

  nock5:
    build: .
    ports:
      - "3045:3005"
      - "3046:3006"

  nock6:
    build: .
    ports:
      - "3055:3005"
      - "3056:3006"

  nock7:
    build: .
    ports:
      - "3065:3005"
      - "3066:3006"

  nock8:
    build: .
    ports:
      - "3075:3005"
      - "3076:3006"
```
jika ingin lebih banyak tinggal ulangi command 

```bash
  nock(ganti):
    build: .
    ports:
      - "port:port"
      - "port:port"
```
isi 4x port seperti di atas tapi jangan sama 
```bash
nano .dockerignore
```
paste di .dockerignore
```bash
target/
.git/
.gitignore
Cargo.lock
*.log
*.sock
.socket/
*.tmp
*.cache
```
buat docker file

```bash
nano Dockerfile
```
paste di dockerfile
```bash
FROM rust:1.76-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
  clang \
  libclang-dev \
  llvm-dev \
  pkg-config \
  cmake \
  build-essential \
  && apt-get clean

# Copy project files
COPY . .

# Build the project
RUN cargo build --release

CMD ["./target/release/nockchain"]
```
jalankan setup

```bash
docker-compose build
```
jalankan docker untuk 6 core (sesuaikan dengan docker compose)
```bash
docker run -d --name nock1 -p 3005:3005 -p 3006:3006 nockchain_nock1 
docker run -d --name nock2 -p 3025:3005 -p 3026:3006 nockchain_nock2
docker run -d --name nock3 -p 3017:3005 -p 3036:3006 nockchain_nock3 
docker run -d --name nock4 -p 3025:3005 -p 3037:3006 nockchain_nock4
docker run -d --name nock5 -p 3035:3005 -p 3038:3006 nockchain_nock5
docker run -d --name nock6 -p 3045:3005 -p 3039:3006 nockchain_nock6
```

NOTE:port tidak boleh sama nanti error

cek berapa core yang sudah terpakai
```bash
htop
```


# DONE

https://x.com/diva_hashimoto
