#!/bin/bash

# deploy.sh - Deployment script untuk groups-list utility ke remote host
# Usage: ./deploy.sh [OPTIONS]
#   -h, --host <user@host>  Remote host (dapat digunakan multiple times)
#   -d, --dest <path>       Destination path di remote (default: /opt/groups-list)
#   --tar-only              Hanya buat tarball, tidak deploy
#   --no-install            Tidak jalankan installer setelah transfer
#   --help                  Show help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_HOSTS=()
DEST_PATH="/opt/groups-list"
TAR_ONLY=false
NO_INSTALL=false
TEMP_DIR=""

# Cleanup temp files on exit
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

# Show help
show_help() {
    cat << EOF
Deployment script untuk groups-list utility

Penggunaan: $0 [OPTIONS]

OPTIONS:
    -h, --host <user@host>  Remote host untuk deploy (dapat digunakan multiple times)
    -d, --dest <path>       Destination path di remote (default: /opt/groups-list)
    --tar-only              Hanya buat tarball, tidak deploy ke remote
    --no-install            Transfer files tapi tidak jalankan installer
    --help                  Tampilkan help ini

CONTOH:
    # Deploy ke single host
    $0 -h user@remote.com -d /opt/groups-list

    # Deploy ke multiple hosts
    $0 -h user@host1.com -h user@host2.com -d /opt/groups-list

    # Buat tarball saja (transfer manual)
    $0 --tar-only

    # Transfer tapi jangan install otomatis
    $0 -h user@remote.com --no-install

REQUIREMENTS:
    - SSH access ke remote host (untuk deploy otomatis)
    - User harus bisa menggunakan sudo di remote host
    - tar, gzip installed di local dan remote

CATATAN:
    - Installer akan dijalankan dengan 'sudo' di remote
    - Jika tidak ada sudo access, gunakan --tar-only dan install manual
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--host)
            DEPLOY_HOSTS+=("$2")
            shift 2
            ;;
        -d|--dest)
            DEST_PATH="$2"
            shift 2
            ;;
        --tar-only)
            TAR_ONLY=true
            shift
            ;;
        --no-install)
            NO_INSTALL=true
            shift
            ;;
        --help)
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

# Validasi source files
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
if [ ! -f "$SCRIPT_DIR/groups-list.sh" ]; then
    echo "❌ Error: groups-list.sh tidak ditemukan di $SCRIPT_DIR"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/lib/groups-lib.sh" ]; then
    echo "❌ Error: lib/groups-lib.sh tidak ditemukan di $SCRIPT_DIR/lib"
    exit 1
fi

if [ ! -f "$PARENT_DIR/install.sh" ]; then
    echo "❌ Error: install.sh tidak ditemukan di $PARENT_DIR"
    exit 1
fi

# Create tarball
create_tarball() {
    local output_file="groups-list.tar.gz"

    echo "📦 Creating tarball..."

    TEMP_DIR=$(mktemp -d)
    local staging_dir="$TEMP_DIR/groups-list"
    mkdir -p "$staging_dir"

    # Copy files (groups-list.sh, lib, install.sh ada di parent)
    cp "$SCRIPT_DIR/groups-list.sh" "$staging_dir/"
    cp -r "$SCRIPT_DIR/lib" "$staging_dir/"
    cp "$PARENT_DIR/install.sh" "$staging_dir/"
    cp "$PARENT_DIR/README.md" "$staging_dir/" 2>/dev/null || true

    # Create tarball
    cd "$TEMP_DIR"
    tar -czf "$output_file" groups-list/
    cd - > /dev/null

    # Copy to current directory
    cp "$TEMP_DIR/$output_file" "./$output_file"
    echo "✅ Tarball created: $output_file"
    echo ""
    echo "📝 Instructions untuk manual deployment:"
    echo "   1. Transfer file: scp $output_file user@host:/tmp/"
    echo "   2. Login ke host: ssh user@host"
    echo "   3. Extract: cd /tmp && tar -xzf $output_file"
    echo "   4. Install: cd groups-list && sudo ./install.sh -p /usr/local"
    echo ""
}

# Deploy to remote host
deploy_to_host() {
    local host="$1"
    local dest="$2"

    echo "🚀 Deploying ke $host..."

    # Create tarball if not exists
    if [ ! -f "groups-list.tar.gz" ]; then
        TEMP_DIR=$(mktemp -d)
        local staging_dir="$TEMP_DIR/groups-list"
        mkdir -p "$staging_dir"

        cp "$SCRIPT_DIR/groups-list.sh" "$staging_dir/"
        cp -r "$SCRIPT_DIR/lib" "$staging_dir/"
        cp "$PARENT_DIR/install.sh" "$staging_dir/"
        cp "$PARENT_DIR/README.md" "$staging_dir/" 2>/dev/null || true

        cd "$TEMP_DIR"
        tar -czf "groups-list.tar.gz" groups-list/
        cd - > /dev/null

        cp "$TEMP_DIR/groups-list.tar.gz" "./groups-list.tar.gz"
    fi

    # Transfer file
    echo "  📤 Transferring files..."
    scp -q "groups-list.tar.gz" "$host:/tmp/"

    # Extract dan install
    if [ "$NO_INSTALL" = false ]; then
        echo "  📂 Extracting..."
        ssh "$host" "cd /tmp && tar -xzf groups-list.tar.gz"

        echo "  🔧 Installing..."
        ssh "$host" "cd /tmp/groups-list && sudo ./install.sh -p /usr/local"

        echo "  🧹 Cleaning up..."
        ssh "$host" "rm -f /tmp/groups-list.tar.gz && rm -rf /tmp/groups-list"
    else
        echo "  ℹ️  Files transferred to /tmp/groups-list.tar.gz"
        echo "     Manual installation required:"
        echo "     cd /tmp && tar -xzf groups-list.tar.gz && cd groups-list && sudo ./install.sh"
    fi

    echo "✅ Deploy ke $host selesai"
    echo ""
}

# Main logic
if [ "$TAR_ONLY" = true ]; then
    create_tarball
else
    # Validasi deploy_hosts
    if [ ${#DEPLOY_HOSTS[@]} -eq 0 ]; then
        echo "❌ Error: Minimal satu host harus dispecify dengan -h"
        echo ""
        show_help
        exit 1
    fi

    # Deploy ke setiap host
    for host in "${DEPLOY_HOSTS[@]}"; do
        deploy_to_host "$host" "$DEST_PATH"
    done

    echo "🎉 Semua deployment selesai!"
fi
