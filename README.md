# groups-list - Linux Groups Utility

Utility untuk menampilkan dan filter Linux groups dengan berbagai opsi sorting dan filtering.

## 📁 Struktur Project (Modular)

```
linux-groups-list/
├── 📄 install.sh              # Installer script (local)
├── 📄 README.md               # User guide
├── 📄 START-HERE.md           # Quick start guide
├── 📄 QUICKSTART.md           # Quick reference
├── 📄 .gitignore              # Git configuration
│
├── 📁 src/                    # Source code & executables
│   ├── groups-list.sh         # Main script (entry point)
│   ├── deploy.sh              # Deployment script (remote)
│   ├── lib/
│   │   └── groups-lib.sh      # Library dengan core functions
│   └── examples/
│       └── custom-usage.sh    # Usage examples
│
└── 📁 docs/                   # Technical documentation
    ├── DEVELOPMENT.md         # Developer guide
    ├── CHANGELOG.md           # Version history
    ├── INDEX.md               # File index
    └── STRUCTURE.txt          # Architecture overview
```

## 🚀 Quick Start

### 1. Install ke Sistem Lokal

```bash
# Install ke /usr/local (recommended)
./install.sh

# Install ke custom path
./install.sh -p ~/.local

# Uninstall
./install.sh -u
```

### 2. Deploy ke Komputer Lain

```bash
# Deploy menggunakan SSH
./deploy.sh -h user@remote-host -d /opt/groups-list

# Deploy tanpa SSH (copy manual)
./deploy.sh --tar-only  # Buat tarball, lalu transfer manual
```

### 3. Gunakan Tool

```bash
# Default: urutkan berdasarkan GID
groups-list

# Urutkan berdasarkan nama
groups-list -n

# Tampilkan system groups saja
groups-list -s

# Verbose mode
groups-list -v

# Lihat semua opsi
groups-list -h
```

## 📚 Dokumentasi Lengkap

### Library Functions (lib/groups-lib.sh)

Berisi reusable functions yang dapat digunakan oleh script lain:

- `show_help()` - Tampilkan help message
- `validate_filter_conflicts()` - Validasi conflict antara filters
- `validate_gid_numeric()` - Validasi GID harus numeric
- `validate_gid_range()` - Validasi min tidak lebih besar dari max
- `apply_filters()` - Apply filter ke group data
- `display_data()` - Display data dengan format yang sesuai
- `sort_data()` - Sort data berdasarkan metode
- `count_groups()` - Hitung jumlah groups
- `display_verbose_stats()` - Tampilkan verbose statistics

### Main Script (groups-list.sh)

Entry point yang menggunakan library functions. Script ini:
1. Import library dari `lib/groups-lib.sh`
2. Parse command-line arguments
3. Call library functions untuk filtering, sorting, display
4. Handle output formatting

### Installer (install.sh)

Script untuk install dan uninstall:

```bash
# Install ke /usr/local
./install.sh

# Install ke custom path
./install.sh -p /opt/tools

# Uninstall
./install.sh -u
./install.sh -p /opt/tools -u

# Help
./install.sh -h
```

Features:
- Membuat direktori yang diperlukan
- Copy library files
- Copy binary files
- Set permissions yang benar
- Patch library path di main script
- Validasi bahwa files exist sebelum install

### Deployer (deploy.sh)

Script untuk deploy ke komputer lain:

```bash
# Deploy ke remote host via SSH
./deploy.sh -h user@remote-host -d /opt/groups-list

# Deploy ke banyak hosts
./deploy.sh -h user@host1 -h user@host2 -d /opt/groups-list

# Buat tarball saja (transfer manual)
./deploy.sh --tar-only

# Help
./deploy.sh -h
```

## 🔧 Keuntungan Struktur Modular

### 1. **Reusability**
Fungsi-fungsi di library dapat digunakan oleh script lain:

```bash
source /path/to/lib/groups-lib.sh

all_groups=$(getent group)
filtered=$(apply_filters "$all_groups" true false "" "" "sudo")
sort_data "$filtered" "name"
```

### 2. **Maintainability**
- Core logic terpisah di library
- Mudah untuk modify/extend functions
- Testing per-function lebih mudah
- Version control lebih jelas

### 3. **Scalability**
- Mudah menambah features baru tanpa mengubah main script
- Library dapat dijadikan shared library untuk tools lain
- Struktur siap untuk testing framework

### 4. **Portability**
- Installer menangani setup otomatis
- Deployer memudahkan distribusi ke banyak host
- Library path secara otomatis di-patch saat install

## 📦 Usage Examples

### Basic Usage

```bash
# List semua groups
groups-list

# List dengan verbose
groups-list -v

# List system groups only
groups-list -s

# Count total groups
groups-list -c
```

### Filtering

```bash
# Filter by name
groups-list -f sudo

# Filter by GID range
groups-list -L 1000 -H 2000
groups-list -r 1000-2000

# Kombinasi filter
groups-list -s -n -m  # System groups, sort by name, show members
```

### Output Formats

```bash
# Default: name + GID
groups-list

# Show all fields
groups-list -a

# Show members
groups-list -m

# All fields dengan members
groups-list -a -m
```

## 🔌 Integration dengan Script Lain

Contoh menggunakan library di script lain:

```bash
#!/bin/bash

# Import library
source /usr/local/lib/groups-lib/groups-lib.sh

# Gunakan functions
all_groups=$(getent group)
user_groups=$(apply_filters "$all_groups" false true "" "" "")
sorted=$(sort_data "$user_groups" "name")
display_data "$sorted" false true
```

## 📋 Requirements

- bash >= 4.0
- getent command (GNU libc)
- Standard Unix tools: awk, grep, sort, sed, cut
- read/write permission untuk install path

## 🐛 Troubleshooting

### Library not found
```
Error: Library file not found
```

Solusi:
- Pastikan `lib/groups-lib.sh` ada di direktori yang sama dengan `groups-list.sh`
- Jika install custom, pastikan `-p` path sesuai

### Permission denied
```
Permission denied: /usr/local/bin/groups-list
```

Solusi:
- Gunakan `sudo ./install.sh` untuk install ke /usr/local
- Atau gunakan `./install.sh -p ~/.local` untuk user-space install

### getent not found
```
getent: command not found
```

Solusi:
- Install libc6-tools atau setara di sistem Anda
- Gunakan `/etc/group` secara langsung sebagai alternative

## 📝 License

MIT

## 👨‍💻 Author

@rafiadadisini (raficodedisini@gmail.com)
