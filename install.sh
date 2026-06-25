#!/bin/bash

# install.sh - Installer script untuk groups-list utility
# Usage: ./install.sh [OPTIONS]
#   -p, --prefix <path>   Install path (default: /usr/local)
#   -u, --uninstall       Uninstall the tool
#   -h, --help           Show help message

set -e

INSTALL_PREFIX="/usr/local"
UNINSTALL=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tampilkan help
show_help() {
    cat << EOF
Installer untuk groups-list utility

Penggunaan: $0 [OPTIONS]

OPTIONS:
    -p, --prefix <path>   Path instalasi (default: /usr/local)
    -u, --uninstall       Uninstall tool
    -h, --help            Tampilkan help ini

CONTOH:
    $0                         # Install ke /usr/local
    $0 -p ~/.local             # Install ke ~/.local
    $0 -u                      # Uninstall
    $0 -p /opt/tools -u        # Uninstall dari /opt/tools

INFORMASI INSTALASI:
    - Binary akan dicopy ke: \$PREFIX/bin/groups-list
    - Library akan dicopy ke: \$PREFIX/lib/groups-lib/groups-lib.sh
    - Symlink akan dibuat untuk akses mudah

REQUIREMENTS:
    - bash >= 4.0
    - getent command
    - awk, grep, sort, sed
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Opsi tidak dikenali: $1"
            show_help
            exit 1
            ;;
    esac
done

# Tentukan lokasi source files
SRC_DIR="$SCRIPT_DIR/src"

# Validasi source files exist
if [ ! -f "$SRC_DIR/groups-list.sh" ]; then
    echo "❌ Error: groups-list.sh tidak ditemukan di $SRC_DIR"
    exit 1
fi

if [ ! -f "$SRC_DIR/lib/groups-lib.sh" ]; then
    echo "❌ Error: lib/groups-lib.sh tidak ditemukan di $SRC_DIR/lib"
    exit 1
fi

# Function untuk uninstall
uninstall() {
    local bin_path="$INSTALL_PREFIX/bin/groups-list"
    local lib_path="$INSTALL_PREFIX/lib/groups-lib"
    local bin_dir="$INSTALL_PREFIX/bin"

    echo "🔄 Uninstalling groups-list dari $INSTALL_PREFIX..."

    if [ -f "$bin_path" ]; then
        rm -f "$bin_path"
        echo "  ✓ Dihapus: $bin_path"
    else
        echo "  ⚠ Tidak ditemukan: $bin_path"
    fi

    if [ -d "$lib_path" ]; then
        rm -rf "$lib_path"
        echo "  ✓ Dihapus: $lib_path"
    else
        echo "  ⚠ Tidak ditemukan: $lib_path"
    fi

    # Remove from shell configs
    echo "🔧 Removing from shell configurations..."
    unconfigure_shells "$bin_dir"

    echo "✅ Uninstall selesai"
}

# Function untuk remove dari shell configs
unconfigure_shells() {
    local bin_dir="$1"

    # Bash
    if [ -f "$HOME/.bashrc" ]; then
        if grep -q "export PATH.*$bin_dir" "$HOME/.bashrc" 2>/dev/null; then
            sed -i "/# groups-list/d; |export PATH=.*$bin_dir|d" "$HOME/.bashrc" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.bashrc"
        fi
    fi

    # Zsh
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "export PATH.*$bin_dir" "$HOME/.zshrc" 2>/dev/null; then
            sed -i "/# groups-list/d; |export PATH=.*$bin_dir|d" "$HOME/.zshrc" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.zshrc"
        fi
    fi

    # Fish
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        if grep -q "set.*$bin_dir" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            sed -i "/# groups-list/d; |set -gx PATH.*$bin_dir|d" "$HOME/.config/fish/config.fish" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.config/fish/config.fish"
        fi
    fi
}

# Function untuk install
install() {
    local bin_path="$INSTALL_PREFIX/bin"
    local lib_path="$INSTALL_PREFIX/lib/groups-lib"

    echo "🔄 Installing groups-list ke $INSTALL_PREFIX..."

    # Create directories
    mkdir -p "$bin_path"
    mkdir -p "$lib_path"

    # Copy library from src/
    cp "$SRC_DIR/lib/groups-lib.sh" "$lib_path/groups-lib.sh"
    chmod 644 "$lib_path/groups-lib.sh"
    echo "  ✓ Library installed: $lib_path/groups-lib.sh"

    # Copy main script from src/
    cp "$SRC_DIR/groups-list.sh" "$bin_path/groups-list"
    chmod 755 "$bin_path/groups-list"
    echo "  ✓ Binary installed: $bin_path/groups-list"

    # Patch library path di binary
    sed -i "s|^LIB_DIR=.*|LIB_DIR=\"$lib_path\"|" "$bin_path/groups-list"
    sed -i "s|^LIB_FILE=.*|LIB_FILE=\"$lib_path/groups-lib.sh\"|" "$bin_path/groups-list"

    # Install shell completions
    echo "  🔧 Installing shell completions..."
    install_completions

    # Check if bin_path is in PATH
    if [[ ":$PATH:" == *":$bin_path:"* ]]; then
        echo ""
        echo "✅ Installation selesai!"
        echo "   Gunakan: groups-list [OPTIONS]"
    else
        echo ""
        echo "🔧 Configuring shells..."
        configure_shells "$bin_path"
    fi
}

# Function untuk install shell completions
install_completions() {
    # Bash completion
    if [ -d "/etc/bash_completion.d" ]; then
        cp "$SRC_DIR/completion/groups-list.bash" "/etc/bash_completion.d/groups-list" 2>/dev/null || true
        echo "    ✓ Bash completion installed"
    elif [ -d "/usr/local/etc/bash_completion.d" ]; then
        cp "$SRC_DIR/completion/groups-list.bash" "/usr/local/etc/bash_completion.d/groups-list" 2>/dev/null || true
        echo "    ✓ Bash completion installed"
    fi

    # Zsh completion
    if [ -d "/usr/share/zsh/site-functions" ]; then
        cp "$SRC_DIR/completion/groups-list.zsh" "/usr/share/zsh/site-functions/_groups-list" 2>/dev/null || true
        echo "    ✓ Zsh completion installed"
    elif [ -d "/usr/local/share/zsh/site-functions" ]; then
        cp "$SRC_DIR/completion/groups-list.zsh" "/usr/local/share/zsh/site-functions/_groups-list" 2>/dev/null || true
        echo "    ✓ Zsh completion installed"
    fi

    # Fish completion
    if [ -d "/usr/share/fish/vendor_completions.d" ]; then
        cp "$SRC_DIR/completion/groups-list.fish" "/usr/share/fish/vendor_completions.d/groups-list.fish" 2>/dev/null || true
        echo "    ✓ Fish completion installed"
    elif [ -d "/usr/local/share/fish/vendor_completions.d" ]; then
        cp "$SRC_DIR/completion/groups-list.fish" "/usr/local/share/fish/vendor_completions.d/groups-list.fish" 2>/dev/null || true
        echo "    ✓ Fish completion installed"
    fi

    # Fallback: add completion to shell config files
    add_completion_to_configs
}

# Function untuk add completion ke shell config files
add_completion_to_configs() {
    # Bash
    if [ -f "$HOME/.bashrc" ] && [ -f "$SRC_DIR/completion/groups-list.bash" ]; then
        if ! grep -q "groups-list.bash" "$HOME/.bashrc" 2>/dev/null; then
            echo "[ -f \"$SRC_DIR/completion/groups-list.bash\" ] && source \"$SRC_DIR/completion/groups-list.bash\"" >> "$HOME/.bashrc"
        fi
    fi

    # Zsh
    if [ -f "$HOME/.zshrc" ] && [ -f "$SRC_DIR/completion/groups-list.zsh" ]; then
        if ! grep -q "groups-list.zsh" "$HOME/.zshrc" 2>/dev/null; then
            echo "[ -f \"$SRC_DIR/completion/groups-list.zsh\" ] && source \"$SRC_DIR/completion/groups-list.zsh\"" >> "$HOME/.zshrc"
        fi
    fi

    # Fish
    if [ -f "$HOME/.config/fish/config.fish" ] && [ -f "$SRC_DIR/completion/groups-list.fish" ]; then
        if ! grep -q "groups-list.fish" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo "source \"$SRC_DIR/completion/groups-list.fish\"" >> "$HOME/.config/fish/config.fish"
        fi
    fi
}

# Function untuk configure shells (bash, zsh, fish)
configure_shells() {
    local bin_path="$1"
    local shells_updated=0

    # Bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "export PATH.*groups-list" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# groups-list" >> "$HOME/.bashrc"
            echo "export PATH=\"$bin_path:\$PATH\"" >> "$HOME/.bashrc"
            echo "   ✓ Updated: ~/.bashrc"
            shells_updated=$((shells_updated + 1))
        fi
    fi

    # Zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "export PATH.*groups-list" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# groups-list" >> "$HOME/.zshrc"
            echo "export PATH=\"$bin_path:\$PATH\"" >> "$HOME/.zshrc"
            echo "   ✓ Updated: ~/.zshrc"
            shells_updated=$((shells_updated + 1))
        fi
    fi

    # Fish
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        if ! grep -q "set.*groups-list" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo "" >> "$HOME/.config/fish/config.fish"
            echo "# groups-list" >> "$HOME/.config/fish/config.fish"
            echo "set -gx PATH $bin_path \$PATH" >> "$HOME/.config/fish/config.fish"
            echo "   ✓ Updated: ~/.config/fish/config.fish"
            shells_updated=$((shells_updated + 1))
        fi
    fi

    echo ""
    if [ $shells_updated -gt 0 ]; then
        echo "✅ Installation selesai!"
        echo ""
        echo "📝 Shell configuration updated. Silahkan:"
        echo "   1. Tutup dan buka terminal baru, ATAU"
        echo "   2. Jalankan: source ~/.bashrc  (untuk bash)"
        echo "   3. Jalankan: source ~/.zshrc   (untuk zsh)"
        echo "   4. Jalankan: source ~/.config/fish/config.fish  (untuk fish)"
        echo ""
        echo "Kemudian gunakan: groups-list [OPTIONS]"
    else
        echo "✅ Installation selesai!"
        echo ""
        echo "ℹ️  Shell configs sudah updated atau path sudah dalam PATH."
        echo "   Gunakan: groups-list [OPTIONS]"
        echo ""
        echo "   Jika command tidak ditemukan, restart terminal atau:"
        echo "   export PATH=\"$bin_path:\$PATH\""
    fi
}

# Main logic
if [ "$UNINSTALL" = true ]; then
    uninstall
else
    install
fi
