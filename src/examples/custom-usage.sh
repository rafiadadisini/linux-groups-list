#!/bin/bash

# custom-usage.sh - Contoh penggunaan library groups-lib.sh di script lain

# Tentukan lokasi library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_FILE="$SCRIPT_DIR/lib/groups-lib.sh"

# Import library
if [ ! -f "$LIB_FILE" ]; then
    echo "❌ Error: Library not found at $LIB_FILE" >&2
    exit 1
fi
source "$LIB_FILE"

# ============================================================================
# EXAMPLE 1: Filter dan display user groups
# ============================================================================
example_user_groups() {
    echo "📌 EXAMPLE 1: Display user groups only"
    echo ""

    local all_groups=$(getent group)
    local filtered=$(apply_filters "$all_groups" false true "" "" "")
    local sorted=$(sort_data "$filtered" "name")

    display_data "$sorted" false true

    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# EXAMPLE 2: Filter system groups dalam range tertentu
# ============================================================================
example_system_range() {
    echo "📌 EXAMPLE 2: System groups in range 0-100"
    echo ""

    local all_groups=$(getent group)
    local filtered=$(apply_filters "$all_groups" true false "0" "100" "")
    local sorted=$(sort_data "$filtered" "gid")

    display_data "$sorted" true false

    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# EXAMPLE 3: Search groups by name pattern
# ============================================================================
example_search() {
    echo "📌 EXAMPLE 3: Search groups matching pattern 'sudo'"
    echo ""

    local all_groups=$(getent group)
    local filtered=$(apply_filters "$all_groups" false false "" "" "sudo")

    if [ -z "$filtered" ]; then
        echo "⚠️  No groups found matching pattern"
    else
        local sorted=$(sort_data "$filtered" "name")
        display_data "$sorted" true true
    fi

    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# EXAMPLE 4: Count groups by category
# ============================================================================
example_statistics() {
    echo "📌 EXAMPLE 4: Count groups statistics"
    echo ""

    local all_groups=$(getent group)

    local system=$(apply_filters "$all_groups" true false "" "" "")
    local users=$(apply_filters "$all_groups" false true "" "" "")

    local system_count=$(count_groups "$system")
    local user_count=$(count_groups "$users")
    local total_count=$(echo "$all_groups" | wc -l)

    echo "📊 Statistics:"
    echo "  System groups (GID < 1000): $system_count"
    echo "  User groups (GID >= 1000): $user_count"
    echo "  Total groups: $total_count"
    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# EXAMPLE 5: Advanced usage - Group membership analysis
# ============================================================================
example_members() {
    echo "📌 EXAMPLE 5: Groups dengan members"
    echo ""

    local all_groups=$(getent group)
    local with_members=$(echo "$all_groups" | awk -F: '$4 != "" {print $0}')

    if [ -z "$with_members" ]; then
        echo "⚠️  No groups with members found"
    else
        echo "Groups dengan members:"
        display_data "$with_members" false true
    fi

    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# EXAMPLE 6: Export groups data ke format lain
# ============================================================================
example_export() {
    echo "📌 EXAMPLE 6: Export ke JSON-like format"
    echo ""

    local all_groups=$(getent group)
    local user_groups=$(apply_filters "$all_groups" false true "" "" "")
    local sorted=$(sort_data "$user_groups" "name")

    echo "User Groups (JSON-like):"
    echo "["
    echo "$sorted" | awk -F: 'NR==1 {print "  {\"name\": \""$1"\", \"gid\": "$3", \"members\": \""$4"\"}"} NR>1 {print "  {\"name\": \""$1"\", \"gid\": "$3", \"members\": \""$4"\"},"}'
    echo "]"
    echo ""
    echo "---"
    echo ""
}

# ============================================================================
# Main: Run all examples
# ============================================================================
main() {
    echo "🚀 Custom Usage Examples - groups-lib.sh"
    echo "=========================================="
    echo ""

    example_user_groups
    example_system_range
    example_search
    example_statistics
    example_members
    example_export

    echo "✅ All examples completed!"
}

# Run main function
main "$@"
