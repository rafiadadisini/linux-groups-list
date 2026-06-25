# Quick Start Guide - groups-list

Panduan cepat untuk memulai menggunakan groups-list.

## 🚀 Installation (5 menit)

### Option 1: Install ke /usr/local (Recommended)

```bash
cd ~/claude-workspace/linux-groups-list
sudo ./install.sh
```

**Installer otomatis:**
- ✅ Update shell configs (bash, zsh, fish)
- ✅ Install completions
- ✅ Setup PATH

**Setelah selesai:**
```bash
# Buka terminal baru atau:
source ~/.bashrc   # untuk bash
source ~/.zshrc    # untuk zsh

# Gunakan langsung:
groups-list -h
```

### Option 2: Install ke User Directory (No sudo)

```bash
cd ~/claude-workspace/linux-groups-list
./install.sh -p ~/.local
```

Installer akan otomatis update shell configs.

### Option 3: Run Directly

```bash
cd ~/claude-workspace/linux-groups-list
./src/groups-list.sh [options]
```

---

## 📋 Common Commands

### List all groups (default)

```bash
groups-list
```

### List by name (A-Z)

```bash
groups-list -n
```

### List system groups only (GID < 1000)

```bash
groups-list -s
```

### List user groups only (GID >= 1000)

```bash
groups-list -U
```

### Count total groups

```bash
groups-list -c
```

### Verbose mode (show statistics)

```bash
groups-list -v
```

### Get help

```bash
groups-list -h
```

---

## 🔍 Filtering Examples

### Filter by name

```bash
# Search untuk group 'sudo'
groups-list -f sudo

# Search untuk group yang contains 'wheel'
groups-list -f wheel
```

### Filter by GID range

```bash
# GID between 100-1000
groups-list -L 100 -H 1000

# GID >= 1000
groups-list -L 1000

# GID <= 500
groups-list -H 500

# Range format
groups-list -r 100-1000
```

### Kombinasi filter

```bash
# System groups sorted by name
groups-list -s -n

# User groups dengan members, verbose
groups-list -U -m -v

# Groups 0-1000, all fields, sorted by name
groups-list -r 0-1000 -a -n
```

---

## 📊 Display Options

### Default (name + GID)

```bash
groups-list
```

### Show all fields

```bash
groups-list -a
# Columns: Group Name | GID | Password | Members
```

### Show members

```bash
groups-list -m
# Columns: Group Name | Members
```

### Combination

```bash
groups-list -a -m
groups-list -a -v
```

---

## 🚀 Deploy to Remote Host

### Single host

```bash
./deploy.sh -h user@remote.host.com
```

### Multiple hosts

```bash
./deploy.sh -h user@host1.com -h user@host2.com
```

### Manual transfer

```bash
# Create tarball
./deploy.sh --tar-only

# On local machine
scp groups-list.tar.gz user@host:/tmp/

# On remote machine
cd /tmp && tar -xzf groups-list.tar.gz
cd groups-list && sudo ./install.sh
```

---

## 💡 Use Cases

### Find all system services

```bash
groups-list -s
```

### Find user-created groups

```bash
groups-list -U -n
```

### Check group memberships

```bash
groups-list -f sudo -m
```

### Audit groups by range

```bash
groups-list -L 1000 -H 2000 -v
```

### Export for documentation

```bash
groups-list -a -v > groups-report.txt
```

---

## 🔗 Integration dengan Script Lain

Import library di custom script:

```bash
#!/bin/bash

source /usr/local/lib/groups-lib/groups-lib.sh

# Gunakan functions
all=$(getent group)
filtered=$(apply_filters "$all" false true "" "" "")
sorted=$(sort_data "$filtered" "name")
display_data "$sorted" false true
```

Lihat `examples/custom-usage.sh` untuk lebih banyak contoh.

---

## ⚡ Performance Tips

### Large number of groups

Untuk sistem dengan ribuan groups:

```bash
# Gunakan count saja
groups-list -c

# Gunakan range untuk limit output
groups-list -L 1000 -H 2000

# Kombinasi filters
groups-list -s -f pattern -n
```

---

## 🆘 Troubleshooting

### Command not found

```bash
# Option 1: Gunakan full path
/usr/local/bin/groups-list

# Option 2: Add to PATH
export PATH="/usr/local/bin:$PATH"

# Option 3: Check installation
sudo ./install.sh  # Re-run installer
```

### Permission denied

```bash
# For /usr/local install, use sudo
sudo ./install.sh

# For user install
./install.sh -p ~/.local
```

### Library not found

```bash
# Reinstall
./install.sh

# Or manually check
ls /usr/local/lib/groups-lib/groups-lib.sh
```

---

## 📚 Learn More

- Full documentation: `README.md`
- Developer guide: `DEVELOPMENT.md`
- Example usage: `examples/custom-usage.sh`
- Help command: `groups-list -h`

---

## 🎯 Next Steps

1. **Basic**: `groups-list -h`
2. **Explore**: `groups-list -s -n -v`
3. **Integrate**: Check `examples/custom-usage.sh`
4. **Deploy**: Use `./deploy.sh` untuk distribute ke team

---

Happy exploring! 🚀
