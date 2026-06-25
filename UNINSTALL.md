# Uninstall Guide - groups-list

Panduan lengkap untuk uninstall groups-list menggunakan dedicated uninstall script.

## Quick Start

```bash
# Auto-detect dan uninstall
./uninstall.sh

# Confirm dengan membuka terminal baru atau:
source ~/.bashrc  # bash
source ~/.zshrc   # zsh
```

---

## Usage

### Basic Uninstall (Auto-detect)

```bash
./uninstall.sh
```

Script akan:
1. Auto-detect installation path
2. Tampilkan path yang ditemukan untuk konfirmasi
3. Menunggu user confirm sebelum menghapus
4. Clean up semua files dan shell configs

### Specify Installation Path

Jika auto-detect tidak bekerja:

```bash
./uninstall.sh -p /usr/local
./uninstall.sh -p ~/.local
./uninstall.sh -p /opt/groups-list
```

### Force Uninstall (No Confirmation)

```bash
./uninstall.sh -f
./uninstall.sh -p ~/.local -f
```

**Warning:** Tidak akan tanya konfirmasi, langsung uninstall!

### Verbose Mode

Lihat detail proses uninstall:

```bash
./uninstall.sh -v
./uninstall.sh -p ~/.local -v
```

---

## How It Works

### 1. Auto-Detection (Sequential Methods)

Script mencari installation path dengan 4 metode:

**Method 1: Installation Info File**
```
~/.config/groups-list/install.info
```
- Paling akurat jika install menggunakan installer yang sama
- Menyimpan installation metadata

**Method 2: Which Command**
```bash
which groups-list  # Output: /usr/local/bin/groups-list
```
- Cari di PATH
- Bekerja jika PATH sudah dikonfigurasi

**Method 3: Shell Config Files**
```bash
grep "# groups-list" ~/.bashrc
grep "# groups-list" ~/.zshrc
```
- Cari PATH entry di shell configs
- Fallback jika not in PATH

**Method 4: Search Library Files**
```bash
find ~ -name "groups-lib.sh"  # Find di home directory
```
- Terakhir resort jika metode lain gagal
- Slower tapi paling thorough

### 2. Confirmation

Script menampilkan:
```
⚠️  UNINSTALL CONFIRMATION
────────────────────────────────────────────────────────────
Installation Path: /usr/local
Akan dihapus:
  • Binary: /usr/local/bin/groups-list
  • Library: /usr/local/lib/groups-lib/
  • PATH dari ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish
Lanjutkan uninstall? (y/N):
```

User harus ketik `y` untuk proceed (kecuali `-f` flag).

### 3. Uninstall Process

**Remove binary:**
```bash
rm -f /usr/local/bin/groups-list
```

**Remove library:**
```bash
rm -rf /usr/local/lib/groups-lib/
```

**Clean shell configs:**
- Remove `# groups-list` comment line
- Remove `export PATH="/usr/local/bin:$PATH"` line dari ~/.bashrc
- Remove similar lines dari ~/.zshrc
- Remove `set -gx PATH /usr/local/bin $PATH` dari ~/.config/fish/config.fish

**Remove completion files:**
- `/etc/bash_completion.d/groups-list`
- `/usr/share/zsh/site-functions/_groups-list`
- `/usr/share/fish/vendor_completions.d/groups-list.fish`

**Remove install info:**
- `~/.config/groups-list/install.info`

---

## Examples

### Scenario 1: Standard Uninstall

```bash
$ ./uninstall.sh
🔍 Auto-detecting installation path...
✓ Found installation at: /usr/local

⚠️  UNINSTALL CONFIRMATION
────────────────────────────────────────────────────────────
Installation Path: /usr/local
Akan dihapus:
  • Binary: /usr/local/bin/groups-list
  • Library: /usr/local/lib/groups-lib/
  • PATH dari ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish
Lanjutkan uninstall? (y/N): y

🔄 Uninstalling groups-list dari /usr/local...
  ✓ Dihapus: /usr/local/bin/groups-list
  ✓ Dihapus: /usr/local/lib/groups-lib

🔧 Removing from shell configurations...
  ✓ Removed from: ~/.bashrc
  ✓ Removed from: ~/.zshrc
  ✓ Removed from: ~/.config/fish/config.fish

🧹 Removing completion files...
  ✓ Removed: /etc/bash_completion.d/groups-list
  ✓ Removed: /usr/share/zsh/site-functions/_groups-list
  ✓ Removed: /usr/share/fish/vendor_completions.d/groups-list.fish

📝 Removing installation info...
  ✓ Removed: ~/.config/groups-list/install.info

✅ Uninstall selesai!

Post-uninstall:
  • Close dan open terminal baru, atau:
  • source ~/.bashrc (bash)
  • source ~/.zshrc (zsh)
  • source ~/.config/fish/config.fish (fish)
```

### Scenario 2: Custom Path

```bash
$ ./uninstall.sh -p ~/.local
🔍 Auto-detecting installation path...
ℹ️  Skipping auto-detect (path specified)

✓ Found installation at: /home/user/.local

⚠️  UNINSTALL CONFIRMATION
Lanjutkan uninstall? (y/N): y

🔄 Uninstalling groups-list dari /home/user/.local...
[Process continues...]
```

### Scenario 3: Force Uninstall

```bash
$ ./uninstall.sh -f
🔍 Auto-detecting installation path...
✓ Found installation at: /usr/local

🔄 Uninstalling groups-list dari /usr/local...
[Uninstall immediately without asking]
```

### Scenario 4: Verbose Mode

```bash
$ ./uninstall.sh -v
📊 Uninstall Information
────────────────────────────────────────────────────────────
Installation path: /usr/local
Verbose mode: true
Force mode: false

🔍 Auto-detecting installation path...
  ℹ️  Found via which: /usr/local

[Detailed output for each step]
```

---

## Auto-Detection Details

### Info File Content

`~/.config/groups-list/install.info`:
```ini
INSTALL_PREFIX=/usr/local
INSTALL_DATE=2026-06-25
INSTALL_TIME=15:30:45
INSTALL_USER=rafi
INSTALL_SHELL_BASH=yes
INSTALL_SHELL_ZSH=yes
INSTALL_SHELL_FISH=no
```

### Which Output

```bash
$ which groups-list
/usr/local/bin/groups-list

# Script extracts: /usr/local (parent of parent)
```

### Shell Config Example

```bash
# ~/.bashrc
...
# groups-list
export PATH="/usr/local/bin:$PATH"
...
```

Script finds path from this entry.

---

## Troubleshooting

### "Could not auto-detect installation path"

**Cause:** Script tidak menemukan installation di 4 metode yang tersedia

**Solutions:**

1. Check installed paths:
```bash
which groups-list
find ~ -name "groups-lib.sh"
grep "groups-list" ~/.bashrc ~/.zshrc
```

2. Specify path manually:
```bash
./uninstall.sh -p /path/to/installation
```

### "Uninstall dibatalkan"

User memilih 'N' atau tidak meng-confirm. Jalankan ulang untuk uninstall.

### "File tidak ditemukan" warnings

Ini normal jika:
- Binary sudah dihapus
- Completion files tidak terinstall
- Library sudah dihapus

Script akan continue dan clean shell configs.

### Shell config tidak dibersihkan

Jika hanya ada warning untuk shell yang tidak ada:
- Script hanya clean shells yang ada di sistem
- Tidak akan error jika ~/.zshrc tidak ada

---

## Legacy Method

Masih bisa gunakan installer script untuk uninstall:

```bash
# Old way (still works)
./install.sh -u
./install.sh -p ~/.local -u
```

Uninstall.sh adalah **recommended** karena:
- ✅ Auto-detect path (tidak perlu ingat)
- ✅ Better error handling
- ✅ Dedicated untuk uninstall saja
- ✅ User-friendly confirmation

---

## Safety Features

1. **Confirmation Prompt**
   - Tanya user sebelum menghapus
   - Tampilkan apa yang akan dihapus

2. **Auto-Detection**
   - Cari dari multiple sources
   - Tidak asumsi path

3. **Graceful Errors**
   - Tidak fail jika file sudah dihapus
   - Continue dengan shell cleanup
   - Report status untuk setiap action

4. **Safe Deletion**
   - `rm -f` = tidak error jika tidak ada
   - `rm -rf` = recursive force
   - Check existence sebelum delete

5. **Multiple Runs**
   - Aman untuk jalankan multiple times
   - Idempotent - hasil sama setiap kali

---

## Command Reference

| Command | Effect |
|---------|--------|
| `./uninstall.sh` | Auto-detect dan uninstall dengan confirm |
| `./uninstall.sh -p <path>` | Uninstall dari path yang spesifik |
| `./uninstall.sh -f` | Force uninstall tanpa confirm |
| `./uninstall.sh -v` | Verbose output |
| `./uninstall.sh -h` | Show help |
| `./uninstall.sh -p <path> -f -v` | Kombinasi flags |

---

## Post-Uninstall

Setelah uninstall:

1. **Reload shell config:**
```bash
source ~/.bashrc    # bash
source ~/.zshrc     # zsh
source ~/.config/fish/config.fish  # fish
```

2. **Or open new terminal**

3. **Verify uninstall:**
```bash
which groups-list   # Should show: command not found
grep groups-list ~/.bashrc  # Should show no results
ls ~/.local/lib/groups-lib  # Should not exist
```

4. **Reinstall jika diperlukan:**
```bash
cd ~/projects/linux-groups-list
sudo ./install.sh  # atau ./install.sh -p ~/.local
```

---

## FAQ

**Q: Apakah aman jalankan uninstall.sh multiple times?**
A: Ya! Script idempotent - aman jalankan berkali-kali.

**Q: Apa jika installation path tidak ditemukan?**
A: Script akan show possible locations dan minta user specify path.

**Q: Apakah uninstall.sh menghapus source code?**
A: Tidak! Hanya menghapus installed files di bin/ dan lib/. Source code tetap di project directory.

**Q: Bagaimana jika lupa path instalasi?**
A: Gunakan `./uninstall.sh` tanpa flag - auto-detect akan cari path.

---

**Need more help?** Lihat README.md atau jalankan `./uninstall.sh -h`
