#!/bin/zsh

# Zsh completion for groups-list

_groups_list() {
    local -a options
    local -a sort_opts
    local -a display_opts
    local -a filter_opts

    sort_opts=(
        '-g[Sort by Group ID (GID) - default]'
        '-u[Sort by User ID (UID)]'
        '-n[Sort by Group Name]'
    )

    display_opts=(
        '-a[Show all fields (name, passwd, gid, members)]'
        '-m[Show members of groups]'
    )

    filter_opts=(
        '-s[Show system groups only (GID < 1000)]'
        '-U[Show user groups only (GID >= 1000)]'
        '-f[Filter by group name pattern]:pattern:'
        '-L[Minimum GID]:gid:'
        '-H[Maximum GID]:gid:'
        '-r[GID range (format: min-max)]:range:'
        '--gid-min[Minimum GID]:gid:'
        '--gid-max[Maximum GID]:gid:'
        '--range[GID range (format: min-max)]:range:'
    )

    options=(
        '-c[Count total groups]'
        '-v[Verbose mode with statistics]'
        '-h[Show help message]'
        '--help[Show help message]'
    )

    _arguments \
        "${sort_opts[@]}" \
        "${display_opts[@]}" \
        "${filter_opts[@]}" \
        "${options[@]}"
}

compdef _groups_list groups-list
