# Documentation - Penggunaan groups-list

Panduan lengkap untuk menggunakan groups-list setelah instalasi.

---

## 📖 Daftar Isi

1. [Perkenalan](#perkenalan)
2. [Instalasi](#instalasi)
3. [Basic Usage](#basic-usage)
4. [Opsi & Flag](#opsi--flag)
5. [Common Scenarios](#common-scenarios)
6. [Output Interpretation](#output-interpretation)
7. [Advanced Usage](#advanced-usage)
8. [Tips & Tricks](#tips--tricks)
9. [FAQ](#faq)

---

## Perkenalan

**groups-list** adalah utility untuk menampilkan dan memfilter Linux groups dengan berbagai opsi.

**Fitur Utama:**
- ✅ Tampilkan semua groups di sistem
- ✅ Filter berdasarkan nama, GID, tipe
- ✅ Sortir berdasarkan nama, GID, atau UID
- ✅ Tampilkan members dari setiap group
- ✅ Verbose mode dengan statistik
- ✅ Support bash, zsh, fish dengan auto-completion

---

## Instalasi

### Install ke Sistem (Recommended)

```bash
cd ~/projects/linux-groups-list
sudo ./install.sh
```

**Installer akan otomatis:**
- Copy binary ke `/usr/local/bin/`
- Copy library ke `/usr/local/lib/`
- Update shell configs (bash/zsh/fish)
- Install tab completions

**Setelah install:**
```bash
# Buka terminal baru atau:
source ~/.bashrc

# Cek instalasi:
which groups-list
groups-list -h
```

### Install ke User Directory (Tanpa sudo)

```bash
./install.sh -p ~/.local
```

---

## Basic Usage

### 1. List Semua Groups (Default)

```bash
$ groups-list
═══════════════════════════════════════════════════════════════════════════
Group Name           GID
═══════════════════════════════════════════════════════════════════════════
root                 0
daemon               1
bin                  2
sys                  3
...
```

**Default:** Urutkan berdasarkan GID (ascending)

### 2. List dengan Verbose

```bash
$ groups-list -v
[Output groups list]

📊 STATISTICS:
  Total groups (ditampilkan): 92
  Total system groups: 65
  Total user groups: 27
  Total groups (semua): 92

🔍 CURRENT FILTERS:
  Sort by: gid
  Display: Default
```

### 3. Hitung Total Groups

```bash
$ groups-list -c
Total groups: 92
```

### 4. Help Message

```bash
$ groups-list -h
[Tampilkan semua opsi dan contoh]
```

---

## Opsi & Flag

### Sorting Options (Pilih 1)

| Flag | Hasil | Contoh |
|------|-------|--------|
| `-g` | Sort by GID (default) | `groups-list -g` |
| `-n` | Sort by Group Name (A-Z) | `groups-list -n` |
| `-u` | Sort by UID | `groups-list -u` |

```bash
# Sort by name
$ groups-list -n
adm         4
audio       29
avahi       111
backup      34
bin         2

# Sort by GID (default)
$ groups-list -g
root        0
daemon      1
bin         2
sys         3
```

### Display Options

| Flag | Tampilkan | Contoh |
|------|-----------|--------|
| `-a` | Semua field (name, GID, password, members) | `groups-list -a` |
| `-m` | Name + members | `groups-list -m` |
| Default | Name + GID | `groups-list` |

```bash
# Default: name + GID
$ groups-list
Group Name           GID
root                 0
daemon               1

# With members (-m)
$ groups-list -m
Group Name           Members
root                 (no members)
daemon               (no members)
sudo                 rafi,user2

# All fields (-a)
$ groups-list -a
Group Name   GID    Password   Members
root         0      x          
daemon       1      x          
sudo         27     x          rafi,user2
```

### Filter Options (Kombinasikan)

| Flag | Filter | Contoh |
|------|--------|--------|
| `-s` | System groups (GID < 1000) | `groups-list -s` |
| `-U` | User groups (GID >= 1000) | `groups-list -U` |
| `-f <pattern>` | Filter by name | `groups-list -f sudo` |
| `-L <num>` | Min GID | `groups-list -L 1000` |
| `-H <num>` | Max GID | `groups-list -H 500` |
| `-r <min-max>` | Range | `groups-list -r 0-1000` |

```bash
# System groups only
$ groups-list -s
adm         4
audio       29
avahi       111

# User groups only (GID >= 1000)
$ groups-list -U
rafi        1000
admin       1001
docker      1002

# Filter by name
$ groups-list -f sudo
sudo        27

# GID between 0-100
$ groups-list -r 0-100
root        0
daemon      1
bin         2
...
lp          7
mail        8
...

# GID >= 1000
$ groups-list -L 1000
rafi        1000
admin       1001
```

### Info Options

| Flag | Hasil |
|------|-------|
| `-c` | Count only |
| `-v` | Verbose (statistics) |
| `-h` | Help message |

---

## Common Scenarios

### Scenario 1: Find Specific Group

```bash
$ groups-list -f sudo
sudo                 27

$ groups-list -f sudo -m
sudo                 rafi,user2
```

**Use case:** Cari group spesifik dan lihat members

### Scenario 2: List User Groups

```bash
$ groups-list -U -n
admin        1001
docker       1002
games        1003
rafi         1000
```

**Use case:** Audit custom user groups yang dibuat

### Scenario 3: Audit System Groups

```bash
$ groups-list -s -v
[System groups list]

📊 STATISTICS:
  Total system groups: 65
  Total groups (semua): 92
```

**Use case:** Check system groups yang tersedia

### Scenario 4: GID Range Check

```bash
$ groups-list -r 0-100
root                 0
daemon               1
bin                  2
...
mail                 8
news                 9
...

$ groups-list -L 1000 -H 2000
admin        1001
docker       1002
games        1003
```

**Use case:** Find groups dalam range tertentu

### Scenario 5: Check Group Members

```bash
$ groups-list -U -m
admin        rafi,john
docker       rafi,container-user
sudo         rafi
wheel        rafi,admin-user
```

**Use case:** Siapa saja yang ada di group tertentu

### Scenario 6: Count Groups by Type

```bash
$ groups-list -s -c
Total groups: 65

$ groups-list -U -c
Total groups: 27

$ groups-list -c
Total groups: 92
```

**Use case:** Audit total groups di sistem

### Scenario 7: Full Audit Report

```bash
$ groups-list -a -n -v > groups-audit.txt
```

Generates report dengan:
- Semua fields (name, GID, password, members)
- Sorted by name
- Statistics

---

## Output Interpretation

### Default Output

```
═══════════════════════════════════════════════════════════════════════════
Group Name           GID
═══════════════════════════════════════════════════════════════════════════
root                 0
daemon               1
bin                  2
```

**Kolom:**
- **Group Name**: Nama grup
- **GID**: Group ID (unique identifier)

### All Fields Output (-a)

```
═══════════════════════════════════════════════════════════════════════════
Group Name   GID    Password   Members
═══════════════════════════════════════════════════════════════════════════
root         0      x          
daemon       1      x          
sudo         27     x          rafi,user2
```

**Kolom:**
- **Group Name**: Nama grup
- **GID**: Group ID
- **Password**: Password field (biasanya 'x' = no password)
- **Members**: Siapa yang ada di group (comma-separated)

### Members Output (-m)

```
═══════════════════════════════════════════════════════════════════════════
Group Name           Members
═══════════════════════════════════════════════════════════════════════════
root                 (no members)
sudo                 rafi,user2
docker               rafi,container-user
```

**Kolom:**
- **Group Name**: Nama grup
- **Members**: User yang termasuk dalam group
  - `(no members)` = group kosong
  - `user1,user2,...` = member list

### Verbose Output (-v)

```
📊 STATISTICS:
  Total groups (ditampilkan): 92
  Total system groups: 65
  Total user groups: 27
  Total groups (semua): 92

🔍 CURRENT FILTERS:
  Sort by: gid
  Filter: System groups only (GID < 1000)
  GID Range: 0 - 1000
  Search pattern: sudo
  Display: All fields
```

**Informasi:**
- **Displayed**: Jumlah groups yang ditampilkan (sesuai filter)
- **System groups**: Groups dengan GID < 1000
- **User groups**: Groups dengan GID >= 1000
- **CURRENT FILTERS**: Menunjukkan filter yang digunakan

---

## Advanced Usage

### Kombinasi Multiple Filters

```bash
# System groups, sorted by name, dengan members
$ groups-list -s -n -m
adm                  syslog,rafi
audio                rafi
avahi                avahi
backup               (no members)

# User groups dalam range 1000-2000, all fields, verbose
$ groups-list -U -r 1000-2000 -a -v
[Groups list]
📊 STATISTICS:
  Total groups (ditampilkan): 5
  Total user groups: 27
  Total groups (semua): 92

# System groups >= 100, sorted by name, verbose
$ groups-list -s -L 100 -n -v
```

### Filter Patterns

```bash
# Search with partial match
$ groups-list -f "admin"   # Matches: admin, admingroup, etc
$ groups-list -f "docker"  # Matches: docker
$ groups-list -f "group"   # Matches: any group containing "group"

# Case-insensitive search
$ groups-list -f "SUDO"    # Works! (case-insensitive)
$ groups-list -f "Docker"  # Works!
```

### Export/Redirect Output

```bash
# Save to file
$ groups-list -a -n > groups-backup.txt

# Pipe to other commands
$ groups-list | grep "docker"
$ groups-list | wc -l           # Count groups
$ groups-list -m | grep "rafi"  # Find groups containing "rafi"

# Append to existing file
$ groups-list -v >> system-audit.log
```

### Combine with Other Tools

```bash
# Find specific GID
$ groups-list | grep "^sudo"

# Get GID only
$ groups-list | grep "^sudo" | awk '{print $2}'

# List members of group
$ groups-list -f sudo -m

# Sort by name, then by GID
$ groups-list -n

# Find highest GID
$ groups-list -U | tail -1

# Count members
$ groups-list -m | grep -v "no members" | wc -l
```

---

## Tips & Tricks

### Tip 1: Quick Group Lookup

```bash
# Fastest way to find group info
$ groups-list -f groupname -m
```

### Tip 2: Audit User Permissions

```bash
# Semua groups yang ada di sistem
$ groups-list -U -n

# Untuk audit: user mana saja yang ada di group tertentu
$ groups-list -f sudo -m
```

### Tip 3: GID Gap Detection

```bash
# List semua groups dan cari gap
$ groups-list -n
# Cari ada GID berapa yang missing (gap)
```

### Tip 4: Regular Backups

```bash
# Backup group configuration
$ groups-list -a -v > /var/backups/groups-$(date +%Y%m%d).txt
```

### Tip 5: Tab Completion

```bash
# Start typing dan tekan TAB
$ groups-list -[TAB]          # Shows all options
$ groups-list -f [TAB]        # Suggests groups
$ groups-list -L [TAB]        # Suggests GID values
```

### Tip 6: Combine Filters Strategically

```bash
# Bad (terlalu banyak output)
$ groups-list

# Better (fokus ke user groups)
$ groups-list -U

# Best (fokus ke specific group)
$ groups-list -f docker -m
```

### Tip 7: Use Verbose for Understanding

```bash
# Jika hasil tidak sesuai ekspektasi, gunakan -v
$ groups-list -r 0-100 -v
# Lihat "CURRENT FILTERS" section untuk understand apa yang diterapkan
```

---

## FAQ

### Q: Bagaimana cara find user dalam group spesifik?

A: Gunakan filter + members:
```bash
$ groups-list -f groupname -m
```

Atau grep:
```bash
$ groups-list -m | grep "username"
```

### Q: Apa perbedaan GID, UID, dan Group ID?

A:
- **GID**: Group ID - identifier unik untuk group
- **UID**: User ID - identifier unik untuk user
- **Group ID**: Sama dengan GID

### Q: Apakah groups-list bisa modify groups?

A: Tidak. Tool ini hanya untuk **viewing dan filtering** groups. Untuk modify, gunakan `groupadd`, `groupmod`, `groupdel`.

### Q: Bagaimana cara export output?

A:
```bash
# Save to file
$ groups-list > groups.txt

# Save dengan all fields
$ groups-list -a > groups-full.txt

# Append to file
$ groups-list >> groups.txt
```

### Q: Apakah -s dan -U bisa digunakan bersamaan?

A: Tidak! Akan error:
```bash
$ groups-list -s -U
❌ Error: Tidak bisa gunakan -s dan -U bersamaan
```

### Q: GID 0-1000 apa maksudnya?

A:
- **GID 0-999**: System groups (reserved untuk sistem)
- **GID 1000+**: User groups (untuk user-created groups)

### Q: Bagaimana cara update groups-list?

A:
```bash
# Go to project directory
cd ~/projects/linux-groups-list

# Update dari repo
git pull

# Re-install
sudo ./install.sh
```

### Q: Apakah groups-list bisa preview changes?

A: Tidak, tool ini read-only. Untuk preview changes, gunakan command lain dulu.

### Q: Bagaimana jika groups-list error?

A:
```bash
# Check installation
which groups-list

# Check library
ls /usr/local/lib/groups-lib/groups-lib.sh

# Reinstall
sudo ./install.sh
```

### Q: Apakah tab completion work?

A: Ya! Setelah install:
```bash
$ groups-list -[TAB]    # Akan show options
$ groups-list -f [TAB]  # Akan suggest groups
```

Jika tidak work, restart terminal atau:
```bash
source ~/.bashrc    # bash
source ~/.zshrc     # zsh
```

### Q: Bagaimana cara uninstall?

A:
```bash
# Auto-detect dan uninstall
./uninstall.sh

# Atau specify path
./uninstall.sh -p ~/.local
```

---

## Contoh Lengkap Workflow

### Scenario: Audit Docker Group Access

```bash
# 1. Find docker group
$ groups-list -f docker -m
docker               rafi,john,container-user

# 2. Check GID
$ groups-list -f docker -a
docker               997    x          rafi,john,container-user

# 3. Audit: Apakah semua user dalam group sudah seharusnya?
$ groups-list -U -n
# Verify rafi, john, container-user ada di list

# 4. Get report
$ groups-list -a -n -v > docker-audit.txt
```

### Scenario: System Group Audit

```bash
# 1. Count system groups
$ groups-list -s -c
Total groups: 65

# 2. List semua system groups
$ groups-list -s -n

# 3. Detail report
$ groups-list -s -a -v > system-groups-audit.txt
```

### Scenario: Find Gap in GID Numbering

```bash
# 1. List all groups dengan GID
$ groups-list -n

# 2. Manually identify gaps
# Atau pipe to file dan analysis

# 3. Generate report
$ groups-list -a > groups-analysis.txt
```

---

## Kesimpulan

**groups-list** adalah tool yang powerful untuk:
- ✅ View dan filter Linux groups
- ✅ Audit group membership
- ✅ Generate reports
- ✅ Quick lookup group information

**Best Practice:**
1. Gunakan `-f` untuk quick search
2. Gunakan `-m` untuk lihat members
3. Gunakan `-v` jika confused dengan output
4. Gunakan `-a` untuk detailed audit
5. Redirect output ke file untuk records

---

**Butuh bantuan lebih?** Jalankan: `groups-list -h`
