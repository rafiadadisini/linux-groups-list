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

    echo "✅ Uninstall selesai"
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

    # Check if bin_path is in PATH
    if [[ ":$PATH:" == *":$bin_path:"* ]]; then
        echo ""
        echo "✅ Installation selesai!"
        echo "   Gunakan: groups-list [OPTIONS]"
    else
        echo ""
        echo "⚠️  $bin_path tidak ada di PATH"
        echo "   Tambahkan ke ~/.bashrc atau ~/.zshrc:"
        echo "   export PATH=\"$bin_path:\$PATH\""
        echo ""
        echo "   Atau gunakan path penuh: $bin_path/groups-list [OPTIONS]"
    fi
}

# Main logic
if [ "$UNINSTALL" = true ]; then
    uninstall
else
    install
fi
