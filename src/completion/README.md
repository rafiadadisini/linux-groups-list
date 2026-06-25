# Shell Completions for groups-list

Completion scripts untuk bash, zsh, dan fish shells.

## Auto-Installation

Saat menjalankan `sudo ./install.sh`, completion scripts otomatis:
1. Dideteksi shell yang digunakan
2. Dicopy ke direktori system completion (jika ada sudo)
3. Ditambahkan ke shell config files (fallback)

## Manual Installation

### Bash

Opsi 1: Copy ke system directory
```bash
sudo cp src/completion/groups-list.bash /etc/bash_completion.d/groups-list
```

Opsi 2: Tambah ke ~/.bashrc
```bash
echo "source /path/to/groups-list.bash" >> ~/.bashrc
source ~/.bashrc
```

### Zsh

Opsi 1: Copy ke system directory
```bash
sudo cp src/completion/groups-list.zsh /usr/share/zsh/site-functions/_groups-list
```

Opsi 2: Tambah ke ~/.zshrc
```bash
echo "source /path/to/groups-list.zsh" >> ~/.zshrc
source ~/.zshrc
```

### Fish

Opsi 1: Copy ke system directory
```bash
sudo cp src/completion/groups-list.fish /usr/share/fish/vendor_completions.d/groups-list.fish
```

Opsi 2: Tambah ke ~/.config/fish/config.fish
```bash
echo "source /path/to/groups-list.fish" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

## Testing Completions

### Bash
```bash
# Start typing and press TAB
groups-list -[TAB]           # List all options
groups-list -f [TAB]         # Suggest common groups
groups-list -L [TAB]         # Suggest GID values
```

### Zsh
```bash
# Same as bash, TAB untuk autocomplete
groups-list -[TAB]
groups-list -f [TAB]
```

### Fish
```bash
# Same as bash/zsh
groups-list -[TAB]
groups-list -f [TAB]
```

## Features

Completion scripts menyediakan:
- **Options**: Semua available flags (-g, -n, -s, -U, -f, -L, -H, -r, -c, -v, -h)
- **Descriptions**: Help text untuk setiap option
- **Context-aware**: Suggestions berdasarkan previous arguments
  - Filter names untuk `-f`
  - GID values untuk `-L` dan `-H`
  - Range format untuk `-r`

## Troubleshooting

### Completions tidak work

1. Check apakah file ada:
```bash
ls /usr/share/bash-completion/completions/groups-list
ls /usr/share/zsh/site-functions/_groups-list
ls /usr/share/fish/vendor_completions.d/groups-list.fish
```

2. Restart shell:
```bash
exec bash    # untuk bash
exec zsh     # untuk zsh
exec fish    # untuk fish
```

3. Manual source:
```bash
source /path/to/groups-list.bash  # bash
source /path/to/groups-list.zsh   # zsh
source /path/to/groups-list.fish  # fish
```

## Files

- `groups-list.bash` - Bash completion script
- `groups-list.zsh` - Zsh completion script
- `groups-list.fish` - Fish completion script
