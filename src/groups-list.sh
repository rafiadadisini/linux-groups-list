#!/bin/bash

# groups-list.sh - Menampilkan daftar groups dengan berbagai opsi sorting dan filtering

# Tentukan lokasi script dan library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
LIB_FILE="$LIB_DIR/groups-lib.sh"

# Import library
if [ ! -f "$LIB_FILE" ]; then
    echo "❌ Error: Library file not found at $LIB_FILE" >&2
    exit 1
fi
source "$LIB_FILE"

# Default settings
SORT_BY="gid"
VERBOSE=false
SHOW_ALL=false
SHOW_MEMBERS=false
SYSTEM_ONLY=false
USER_ONLY=false
COUNT_ONLY=false
FILTER=""
GID_MIN=""
GID_MAX=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -g)
            SORT_BY="gid"
            shift
            ;;
        -u)
            SORT_BY="uid"
            shift
            ;;
        -n)
            SORT_BY="name"
            shift
            ;;
        -a)
            SHOW_ALL=true
            shift
            ;;
        -m)
            SHOW_MEMBERS=true
            shift
            ;;
        -s)
            SYSTEM_ONLY=true
            shift
            ;;
        -U)
            USER_ONLY=true
            shift
            ;;
        -c)
            COUNT_ONLY=true
            shift
            ;;
        -v)
            VERBOSE=true
            shift
            ;;
        -f)
            FILTER="$2"
            shift 2
            ;;
        -L|--gid-min)
            GID_MIN="$2"
            shift 2
            ;;
        -H|--gid-max)
            GID_MAX="$2"
            shift 2
            ;;
        -r|--range)
            # Parse format: 100-1000
            IFS='-' read -r GID_MIN GID_MAX <<< "$2"
            shift 2
            ;;
        -h)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Opsi tidak dikenali: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validasi
validate_filter_conflicts "$SYSTEM_ONLY" "$USER_ONLY" || exit 1
validate_gid_numeric "$GID_MIN" "$GID_MAX" || exit 1
validate_gid_range "$GID_MIN" "$GID_MAX" || exit 1

# Main logic
ALL_GROUPS=$(getent group)
FILTERED_DATA=$(apply_filters "$ALL_GROUPS" "$SYSTEM_ONLY" "$USER_ONLY" "$GID_MIN" "$GID_MAX" "$FILTER")

# Handle count only
if [ "$COUNT_ONLY" = true ]; then
    COUNT=$(count_groups "$FILTERED_DATA")
    echo "Total groups: $COUNT"
    exit 0
fi

# Sort data
SORTED_DATA=$(sort_data "$FILTERED_DATA" "$SORT_BY")

# Display data
display_data "$SORTED_DATA" "$SHOW_ALL" "$SHOW_MEMBERS"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Show verbose stats
if [ "$VERBOSE" = true ]; then
    display_verbose_stats "$SORTED_DATA" "$ALL_GROUPS" "$SORT_BY" "$SYSTEM_ONLY" \
        "$USER_ONLY" "$GID_MIN" "$GID_MAX" "$FILTER" "$SHOW_ALL" "$SHOW_MEMBERS"
fi

