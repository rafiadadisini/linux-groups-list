#!/bin/bash

# groups-lib.sh - Library functions untuk groups-list utility
# Berisi core functions untuk filtering, display, dan validation

# Tampilkan help message
show_help() {
    cat << EOF
Penggunaan: groups-list [OPTIONS]

SORTING OPTIONS:
    -g    Urutkan berdasarkan Group ID (GID) - DEFAULT
    -u    Urutkan berdasarkan User ID (UID)
    -n    Urutkan berdasarkan Group Name (nama)

DISPLAY OPTIONS:
    -a    Tampilkan semua field (name, passwd, gid, members)
    -m    Tampilkan members dari group

FILTER OPTIONS:
    -s    Tampilkan system groups only (GID < 1000)
    -U    Tampilkan user groups only (GID >= 1000)
    -f <pattern>        Filter group berdasarkan nama/pattern
    -L, --gid-min <num> Minimum GID (rentang bawah)
    -H, --gid-max <num> Maximum GID (rentang atas)
    -r, --range <min-max> Range GID format "min-max" (contoh: 0-1000)

INFO OPTIONS:
    -c    Tampilkan jumlah total groups
    -v    Verbose mode (tampilkan detail info)
    -h    Tampilkan help message ini

CONTOH PENGGUNAAN:
    groups-list                    # Urutkan berdasarkan GID (default)
    groups-list -n                 # Urutkan berdasarkan nama
    groups-list -u                 # Urutkan berdasarkan UID

    groups-list -s                 # Hanya system groups (GID < 1000)
    groups-list -U                 # Hanya user groups (GID >= 1000)
    groups-list -L 100 -H 1000     # GID antara 100-1000
    groups-list -r 0-1000          # GID antara 0-1000 (range format)
    groups-list -L 1000            # GID >= 1000
    groups-list -H 500             # GID <= 500

    groups-list -f sudo            # Filter group 'sudo'
    groups-list -a -m              # Semua field dengan members
    groups-list -v -c              # Verbose + count

    groups-list -n -U -L 1000 -m   # User groups >= 1000, sort by name, with members
    groups-list -s -r 0-100 -a     # System groups 0-100, all fields
    groups-list -H 1000 -v         # GID <= 1000, verbose
EOF
}

# Validasi conflict antara SYSTEM_ONLY dan USER_ONLY
validate_filter_conflicts() {
    local system_only="$1"
    local user_only="$2"

    if [ "$system_only" = true ] && [ "$user_only" = true ]; then
        echo "❌ Error: Tidak bisa gunakan -s dan -U bersamaan" >&2
        return 1
    fi
    return 0
}

# Validasi range input harus numeric
validate_gid_numeric() {
    local gid_min="$1"
    local gid_max="$2"

    if [ -n "$gid_min" ] && ! [[ "$gid_min" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: GID minimum harus angka, dapat: $gid_min" >&2
        return 1
    fi

    if [ -n "$gid_max" ] && ! [[ "$gid_max" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: GID maximum harus angka, dapat: $gid_max" >&2
        return 1
    fi

    return 0
}

# Validasi minimum tidak lebih besar dari maximum
validate_gid_range() {
    local gid_min="$1"
    local gid_max="$2"

    if [ -n "$gid_min" ] && [ -n "$gid_max" ] && [ "$gid_min" -gt "$gid_max" ]; then
        echo "❌ Error: GID minimum ($gid_min) tidak boleh lebih besar dari maximum ($gid_max)" >&2
        return 1
    fi
    return 0
}

# Apply filters ke data groups
apply_filters() {
    local data="$1"
    local system_only="$2"
    local user_only="$3"
    local gid_min="$4"
    local gid_max="$5"
    local filter="$6"

    # Apply system/user filter
    if [ "$system_only" = true ]; then
        data=$(echo "$data" | awk -F: '$3 < 1000 {print $0}')
    elif [ "$user_only" = true ]; then
        data=$(echo "$data" | awk -F: '$3 >= 1000 {print $0}')
    fi

    # Apply GID range filter
    if [ -n "$gid_min" ] && [ -n "$gid_max" ]; then
        data=$(echo "$data" | awk -F: -v min="$gid_min" -v max="$gid_max" '$3 >= min && $3 <= max {print $0}')
    elif [ -n "$gid_min" ]; then
        data=$(echo "$data" | awk -F: -v min="$gid_min" '$3 >= min {print $0}')
    elif [ -n "$gid_max" ]; then
        data=$(echo "$data" | awk -F: -v max="$gid_max" '$3 <= max {print $0}')
    fi

    # Apply name filter
    if [ -n "$filter" ]; then
        data=$(echo "$data" | grep -i "$filter")
    fi

    echo "$data"
}

# Display data dengan format yang sesuai
display_data() {
    local data="$1"
    local show_all="$2"
    local show_members="$3"

    if [ "$show_all" = true ]; then
        # Tampilkan semua field
        echo "═══════════════════════════════════════════════════════════════════════════════"
        printf "%-20s %-10s %-10s %s\n" "Group Name" "GID" "Password" "Members"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo "$data" | awk -F: '{printf "%-20s %-10s %-10s %s\n", $1, $3, $2, $4}'
    elif [ "$show_members" = true ]; then
        # Tampilkan name dan members
        echo "═══════════════════════════════════════════════════════════════════════════════"
        printf "%-20s %s\n" "Group Name" "Members"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo "$data" | awk -F: '{printf "%-20s %s\n", $1, ($4 == "" ? "(no members)" : $4)}'
    else
        # Default: tampilkan name dan GID
        echo "═══════════════════════════════════════════════════════════════════════════════"
        printf "%-20s %s\n" "Group Name" "GID"
        echo "═══════════════════════════════════════════════════════════════════════════════"
        echo "$data" | awk -F: '{printf "%-20s %s\n", $1, $3}'
    fi
}

# Sort data berdasarkan method
sort_data() {
    local data="$1"
    local sort_by="$2"

    case $sort_by in
        gid)
            echo "$data" | sort -t: -k3 -n
            ;;
        name)
            echo "$data" | sort -t: -k1
            ;;
        uid)
            echo "$data" | sort -t: -k1
            ;;
        *)
            echo "$data"
            ;;
    esac
}

# Hitung jumlah groups dari data
count_groups() {
    local data="$1"

    if [ -z "$data" ]; then
        echo 0
    else
        echo "$data" | grep -c '^'
    fi
}

# Display verbose statistics
display_verbose_stats() {
    local sorted_data="$1"
    local all_groups="$2"
    local sort_by="$3"
    local system_only="$4"
    local user_only="$5"
    local gid_min="$6"
    local gid_max="$7"
    local filter="$8"
    local show_all="$9"
    local show_members="${10}"

    local count=$(count_groups "$sorted_data")
    local system_count=$(echo "$all_groups" | awk -F: '$3 < 1000 {count++} END {print count+0}')
    local user_count=$(echo "$all_groups" | awk -F: '$3 >= 1000 {count++} END {print count+0}')
    local total_count=$(echo "$all_groups" | wc -l)

    echo ""
    echo "📊 STATISTICS:"
    echo "  Total groups (ditampilkan): $count"
    echo "  Total system groups: $system_count"
    echo "  Total user groups: $user_count"
    echo "  Total groups (semua): $total_count"
    echo ""
    echo "🔍 CURRENT FILTERS:"
    echo "  Sort by: $sort_by"
    [ "$system_only" = true ] && echo "  Filter: System groups only (GID < 1000)"
    [ "$user_only" = true ] && echo "  Filter: User groups only (GID >= 1000)"
    [ -n "$gid_min" ] && [ -n "$gid_max" ] && echo "  GID Range: $gid_min - $gid_max"
    [ -n "$gid_min" ] && [ -z "$gid_max" ] && echo "  GID Minimum: $gid_min"
    [ -z "$gid_min" ] && [ -n "$gid_max" ] && echo "  GID Maximum: $gid_max"
    [ -n "$filter" ] && echo "  Search pattern: $filter"
    [ "$show_all" = true ] && echo "  Display: All fields"
    [ "$show_members" = true ] && echo "  Display: With members"
    echo ""
}
