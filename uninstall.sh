#!/bin/bash

# uninstall.sh - Dedicated uninstall script untuk groups-list
# Auto-detects installation path dan menghapus semua files dengan clean

set -e

INSTALL_PREFIX=""
VERBOSE=false
FORCE=false

# Show help
show_help() {
    cat << 'EOF'
Uninstall script untuk groups-list utility

Penggunaan: ./uninstall.sh [OPTIONS]

OPTIONS:
    -p, --path <path>    Specify install path (default: auto-detect)
    -f, --force          Force uninstall tanpa konfirmasi
    -v, --verbose        Verbose output
    -h, --help           Show help message

EXAMPLES:
    ./uninstall.sh                    # Auto-detect dan uninstall
    ./uninstall.sh -p /usr/local      # Uninstall dari /usr/local
    ./uninstall.sh -f                 # Force uninstall tanpa konfirmasi
    ./uninstall.sh -v                 # Verbose mode

NOTES:
    - Script ini auto-detect installation path dari multiple sources
    - Menghapus binary, library, dan PATH dari shell configs
    - Aman untuk jalankan multiple times
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
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

# Auto-detect installation path
auto_detect_path() {
    local detected=""

    # Method 1: Check info file
    if [ -f "$HOME/.config/groups-list/install.info" ]; then
        detected=$(grep "INSTALL_PREFIX=" "$HOME/.config/groups-list/install.info" 2>/dev/null | cut -d= -f2)
        if [ -n "$detected" ]; then
            [ "$VERBOSE" = true ] && echo "  ℹ️  Found in install.info: $detected"
            echo "$detected"
            return 0
        fi
    fi

    # Method 2: Find from 'which' command
    local bin_path=$(which groups-list 2>/dev/null)
    if [ -n "$bin_path" ]; then
        detected=$(dirname $(dirname "$bin_path"))
        if [ -n "$detected" ]; then
            [ "$VERBOSE" = true ] && echo "  ℹ️  Found via which: $detected"
            echo "$detected"
            return 0
        fi
    fi

    # Method 3: Search in shell configs
    if [ -f "$HOME/.bashrc" ]; then
        detected=$(grep "# groups-list" "$HOME/.bashrc" -B 1 2>/dev/null | \
                  grep "export PATH" | \
                  sed 's/.*export PATH="//' | \
                  sed 's/:.*$//' | \
                  sed 's|/bin$||' | \
                  head -1)
        if [ -n "$detected" ]; then
            [ "$VERBOSE" = true ] && echo "  ℹ️  Found in ~/.bashrc: $detected"
            echo "$detected"
            return 0
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        detected=$(grep "# groups-list" "$HOME/.zshrc" -B 1 2>/dev/null | \
                  grep "export PATH" | \
                  sed 's/.*export PATH="//' | \
                  sed 's/:.*$//' | \
                  sed 's|/bin$||' | \
                  head -1)
        if [ -n "$detected" ]; then
            [ "$VERBOSE" = true ] && echo "  ℹ️  Found in ~/.zshrc: $detected"
            echo "$detected"
            return 0
        fi
    fi

    # Method 4: Search library files
    local lib_path=$(find "$HOME" -name "groups-lib.sh" -type f 2>/dev/null | head -1)
    if [ -n "$lib_path" ]; then
        detected=$(echo "$lib_path" | sed 's|/lib/groups-lib.*||')
        if [ -n "$detected" ]; then
            [ "$VERBOSE" = true ] && echo "  ℹ️  Found library at: $detected"
            echo "$detected"
            return 0
        fi
    fi

    # Not found
    return 1
}

# Confirm uninstall
confirm_uninstall() {
    local prefix="$1"

    if [ "$FORCE" = true ]; then
        return 0
    fi

    echo ""
    echo "⚠️  UNINSTALL CONFIRMATION"
    echo "────────────────────────────────────────────────────────────"
    echo "Installation Path: $prefix"
    echo ""
    echo "Akan dihapus:"
    echo "  • Binary: $prefix/bin/groups-list"
    echo "  • Library: $prefix/lib/groups-lib/"
    echo "  • PATH dari ~/.bashrc, ~/.zshrc, ~/.config/fish/config.fish"
    echo ""
    read -p "Lanjutkan uninstall? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall dibatalkan"
        exit 0
    fi
}

# Remove binary file
remove_binary() {
    local bin_path="$1/bin/groups-list"

    if [ -f "$bin_path" ]; then
        rm -f "$bin_path"
        echo "  ✓ Dihapus: $bin_path"
    else
        echo "  ⚠ Tidak ditemukan: $bin_path"
    fi
}

# Remove library directory
remove_library() {
    local lib_path="$1/lib/groups-lib"

    if [ -d "$lib_path" ]; then
        rm -rf "$lib_path"
        echo "  ✓ Dihapus: $lib_path"
    else
        echo "  ⚠ Tidak ditemukan: $lib_path"
    fi
}

# Remove from shell configs
remove_from_shells() {
    local bin_dir="$1/bin"

    [ "$VERBOSE" = true ] && echo "  🔧 Cleaning shell configurations..."

    # Bash
    if [ -f "$HOME/.bashrc" ]; then
        if grep -q "groups-list" "$HOME/.bashrc" 2>/dev/null; then
            sed -i "/# groups-list/d; |export PATH=.*$bin_dir|d" "$HOME/.bashrc" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.bashrc"
        fi
    fi

    # Zsh
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "groups-list" "$HOME/.zshrc" 2>/dev/null; then
            sed -i "/# groups-list/d; |export PATH=.*$bin_dir|d" "$HOME/.zshrc" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.zshrc"
        fi
    fi

    # Fish
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        if grep -q "groups-list" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            sed -i "/# groups-list/d; |set -gx PATH.*$bin_dir|d" "$HOME/.config/fish/config.fish" 2>/dev/null || true
            echo "  ✓ Removed from: ~/.config/fish/config.fish"
        fi
    fi
}

# Remove completion files
remove_completions() {
    local completion_dirs=(
        "/etc/bash_completion.d"
        "/usr/local/etc/bash_completion.d"
        "/usr/share/zsh/site-functions"
        "/usr/local/share/zsh/site-functions"
        "/usr/share/fish/vendor_completions.d"
        "/usr/local/share/fish/vendor_completions.d"
    )

    for dir in "${completion_dirs[@]}"; do
        if [ -f "$dir/groups-list" ]; then
            rm -f "$dir/groups-list" 2>/dev/null || true
            echo "  ✓ Removed: $dir/groups-list"
        elif [ -f "$dir/_groups-list" ]; then
            rm -f "$dir/_groups-list" 2>/dev/null || true
            echo "  ✓ Removed: $dir/_groups-list"
        elif [ -f "$dir/groups-list.fish" ]; then
            rm -f "$dir/groups-list.fish" 2>/dev/null || true
            echo "  ✓ Removed: $dir/groups-list.fish"
        fi
    done
}

# Remove installation info
remove_install_info() {
    local info_file="$HOME/.config/groups-list/install.info"

    if [ -f "$info_file" ]; then
        rm -f "$info_file"
        [ "$VERBOSE" = true ] && echo "  ✓ Removed: $info_file"
    fi
}

# Main uninstall function
uninstall() {
    local prefix="$1"

    echo "🔄 Uninstalling groups-list dari $prefix..."
    echo ""

    # Remove files
    remove_binary "$prefix"
    remove_library "$prefix"

    echo ""
    echo "🔧 Removing from shell configurations..."
    remove_from_shells "$prefix"

    echo ""
    echo "🧹 Removing completion files..."
    remove_completions

    echo ""
    echo "📝 Removing installation info..."
    remove_install_info

    echo ""
    echo "✅ Uninstall selesai!"
    echo ""
    echo "Post-uninstall:"
    echo "  • Close dan open terminal baru, atau:"
    echo "  • source ~/.bashrc (bash)"
    echo "  • source ~/.zshrc (zsh)"
    echo "  • source ~/.config/fish/config.fish (fish)"
}

# Show info if verbose
show_info() {
    echo "📊 Uninstall Information"
    echo "────────────────────────────────────────────────────────────"
    echo "Installation path: $INSTALL_PREFIX"
    echo "Verbose mode: $VERBOSE"
    echo "Force mode: $FORCE"
    echo ""
}

# Main logic
main() {
    # Auto-detect if not specified
    if [ -z "$INSTALL_PREFIX" ]; then
        echo "🔍 Auto-detecting installation path..."
        echo ""

        if INSTALL_PREFIX=$(auto_detect_path); then
            echo ""
            echo "✓ Found installation at: $INSTALL_PREFIX"
        else
            echo ""
            echo "❌ Could not auto-detect installation path"
            echo ""
            echo "Possible locations:"

            # Show possible locations
            if command -v which &> /dev/null && which groups-list &>/dev/null 2>&1; then
                echo "  • $(dirname $(dirname $(which groups-list 2>/dev/null)))"
            fi

            find "$HOME" -name "groups-lib.sh" 2>/dev/null | while read path; do
                echo "  • $(echo "$path" | sed 's|/lib/groups-lib.*||')"
            done

            echo ""
            echo "Solution: Use -p flag to specify path:"
            echo "  ./uninstall.sh -p <install_path>"
            exit 1
        fi
    fi

    # Show info if verbose
    [ "$VERBOSE" = true ] && show_info

    # Confirm uninstall
    confirm_uninstall "$INSTALL_PREFIX"

    # Perform uninstall
    uninstall "$INSTALL_PREFIX"

    echo "💡 Tip: Jika ingin install kembali, gunakan:"
    echo "   cd ~/projects/linux-groups-list"
    echo "   sudo ./install.sh  (atau ./install.sh -p <path>)"
}

# Run main
main
