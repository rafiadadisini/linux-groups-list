# 🚀 START HERE - linux-groups-list v2.0.0

Panduan pertama kali menggunakan project setelah refactoring modular.

## ⏱️ 5 Menit Setup

### 1. Cek Script (30 detik)
```bash
cd ~/claude-workspace/linux-groups-list
./src/groups-list.sh -h
```

### 2. Coba Command Dasar (1 menit)
```bash
./src/groups-list.sh              # List semua groups
./src/groups-list.sh -n           # Urutkan by name
./src/groups-list.sh -s -v        # System groups, verbose
./src/groups-list.sh -U -c        # Count user groups
```

### 3. Lihat Examples (2 menit)
```bash
./src/examples/custom-usage.sh
```

### 4. Install (1 menit)
```bash
sudo ./install.sh             # Ke /usr/local (recommended)
# Atau:
./install.sh -p ~/.local      # Ke user directory (no sudo)
```

Installer akan otomatis:
- ✅ Copy binary ke /usr/local/bin
- ✅ Update shell config (bash, zsh, fish)
- ✅ Install shell completions
- ✅ Buat accessible di PATH

### 5. Restart Terminal & Gunakan
```bash
# Close & open new terminal, atau:
source ~/.bashrc    # for bash
source ~/.zshrc     # for zsh

# Then use:
groups-list -h
groups-list -n -v
```

---

## 🎯 Struktur Project (Modular & Terorganisir!)

```
linux-groups-list/
├── install.sh              ⭐ Installer (local)
├── README.md               ⭐ User guide
├── START-HERE.md           ⭐ Quick start
├── QUICKSTART.md           ⭐ Quick reference
│
├── src/                    📁 Source code
│   ├── groups-list.sh      (orchestrator - 60 lines)
│   ├── lib/groups-lib.sh   (library - 190 lines)
│   ├── deploy.sh           (deployment to remote)
│   └── examples/           (usage examples)
│
└── docs/                   📁 Technical docs
    ├── DEVELOPMENT.md      (developer guide)
    ├── CHANGELOG.md        (version history)
    ├── INDEX.md            (file index)
    └── STRUCTURE.txt       (architecture)
```

---

## 💡 Keuntungan Modular

### 1. **Reusable Library**
Gunakan di script Anda sendiri:
```bash
#!/bin/bash
source /usr/local/lib/groups-lib/groups-lib.sh

all=$(getent group)
filtered=$(apply_filters "$all" false true "" "" "")
sorted=$(sort_data "$filtered" "name")
display_data "$sorted" false true
```

### 2. **Clean Separation**
- **Main Script**: Thin orchestrator
- **Library**: Core functions
- **Installer**: Automated setup
- **Deployer**: Remote distribution

### 3. **Easy to Extend**
Tambah feature tanpa touchMain script:
```bash
# Edit lib/groups-lib.sh
# Tambah function baru
# Main script otomatis bisa gunakan
```

---

## 📚 Documentation Map

| Butuh... | Baca... | Waktu |
|---------|---------|-------|
| Quick overview | QUICKSTART.md | 5 min |
| How to use | README.md | 10 min |
| Install guide | README.md + install.sh -h | 5 min |
| Architecture | STRUCTURE.txt | 10 min |
| Development | DEVELOPMENT.md | 15 min |
| Examples | examples/custom-usage.sh | 5 min |
| File listing | INDEX.md | 5 min |

---

## 🎓 Learning Path

### Beginner
1. Baca QUICKSTART.md (5 min)
2. Jalankan: `./groups-list.sh -h`
3. Coba: `./groups-list.sh -n -v`
4. Install: `sudo ./install.sh`

### Intermediate
1. Baca: README.md
2. Pelajari: examples/custom-usage.sh
3. Coba: Modifikasi script untuk kebutuhan Anda
4. Deploy: `./deploy.sh --tar-only`

### Advanced
1. Baca: DEVELOPMENT.md
2. Pahami: Architecture & library functions
3. Extend: Tambah features di lib/groups-lib.sh
4. Test: Modify examples sesuai kebutuhan

---

## ✨ Key Features

### Command Options
```bash
groups-list -h          # Help
groups-list -n          # Sort by name
groups-list -s          # System groups
groups-list -U          # User groups
groups-list -f pattern  # Filter
groups-list -L 1000     # Min GID
groups-list -H 2000     # Max GID
groups-list -c          # Count
groups-list -v          # Verbose
groups-list -m          # Show members
groups-list -a          # All fields
```

### Installation
```bash
sudo ./install.sh       # /usr/local
./install.sh -p ~/.local # User directory
./install.sh -u         # Uninstall
```

### Deployment
```bash
./deploy.sh -h user@host      # Deploy
./deploy.sh --tar-only        # Create tarball
./deploy.sh -h host1 -h host2 # Multiple
```

---

## 🔧 Common Scenarios

### Scenario 1: List User Groups
```bash
groups-list -U -n -m
```

### Scenario 2: Audit System Groups
```bash
groups-list -s -v -a
```

### Scenario 3: Find Specific Group
```bash
groups-list -f sudo -m
```

### Scenario 4: Deploy to Team
```bash
./deploy.sh -h user@host1 -h user@host2
```

### Scenario 5: Use in Custom Script
```bash
source lib/groups-lib.sh
# Use functions: apply_filters, sort_data, display_data, etc
```

---

## 🆘 Jika Ada Masalah

### "Command not found: groups-list"
```bash
# Solusi 1: Gunakan full path
/usr/local/bin/groups-list -h

# Solusi 2: Add to PATH
export PATH="/usr/local/bin:$PATH"

# Solusi 3: Re-install
sudo ./install.sh
```

### "Library not found"
```bash
# Reinstall:
sudo ./install.sh

# Verify:
ls /usr/local/lib/groups-lib/groups-lib.sh
```

### "Permission denied"
```bash
# Gunakan sudo:
sudo ./install.sh

# Atau user directory:
./install.sh -p ~/.local
```

---

## 📊 Files Overview

| File | Purpose | Size |
|------|---------|------|
| groups-list.sh | Main script | 2.9K |
| lib/groups-lib.sh | Library | 8.2K |
| install.sh | Installer | 3.8K |
| deploy.sh | Deployer | 5.7K |
| examples/custom-usage.sh | Examples | 4.7K |
| README.md | User guide | 5.4K |
| QUICKSTART.md | Quick ref | 4.2K |
| DEVELOPMENT.md | Dev guide | 9.2K |
| CHANGELOG.md | History | 3.1K |
| STRUCTURE.txt | Architecture | 7.8K |
| INDEX.md | Navigation | 3.0K |

---

## 🚀 Langkah Selanjutnya

1. **Immediate**: 
   ```bash
   ./groups-list.sh -h
   ```

2. **Learning** (10 min):
   ```bash
   cat QUICKSTART.md
   ./examples/custom-usage.sh
   ```

3. **Installation** (2 min):
   ```bash
   sudo ./install.sh
   groups-list -n -v
   ```

4. **Integration** (Optional):
   ```bash
   source lib/groups-lib.sh
   # Use in your scripts
   ```

5. **Sharing** (Optional):
   ```bash
   ./deploy.sh -h user@team-server
   ```

---

## 📞 Quick Links

- **Help**: `./groups-list.sh -h`
- **Examples**: `./examples/custom-usage.sh`
- **Install Help**: `./install.sh -h`
- **Deploy Help**: `./deploy.sh --help`
- **Full Docs**: See files in project directory

---

## ✅ You're Ready!

- ✅ Project is modular & clean
- ✅ All scripts are tested
- ✅ Documentation is complete
- ✅ Installation is automated
- ✅ Deployment is ready
- ✅ Examples are provided

**Start with**: `./groups-list.sh -h` then explore!

---

**Version**: 2.0.0 (Modular)  
**Date**: 2026-06-25  
**Status**: Production Ready ✅

