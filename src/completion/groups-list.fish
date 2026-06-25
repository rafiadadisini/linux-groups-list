#!/usr/bin/env fish

# Fish completion for groups-list

set -l commands groups-list

# Sorting options
complete -c groups-list -n "__fish_use_subcommand_from_list" -s g -d "Sort by Group ID (GID) - default"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s u -d "Sort by User ID (UID)"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s n -d "Sort by Group Name"

# Display options
complete -c groups-list -n "__fish_use_subcommand_from_list" -s a -d "Show all fields (name, passwd, gid, members)"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s m -d "Show members of groups"

# Filter options
complete -c groups-list -n "__fish_use_subcommand_from_list" -s s -d "Show system groups only (GID < 1000)"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s U -d "Show user groups only (GID >= 1000)"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s f -d "Filter by group name pattern" -x
complete -c groups-list -n "__fish_use_subcommand_from_list" -s L -l gid-min -d "Minimum GID" -x
complete -c groups-list -n "__fish_use_subcommand_from_list" -s H -l gid-max -d "Maximum GID" -x
complete -c groups-list -n "__fish_use_subcommand_from_list" -s r -l range -d "GID range (format: min-max)" -x

# Info options
complete -c groups-list -n "__fish_use_subcommand_from_list" -s c -d "Count total groups"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s v -d "Verbose mode with statistics"
complete -c groups-list -n "__fish_use_subcommand_from_list" -s h -d "Show help message"
complete -c groups-list -n "__fish_use_subcommand_from_list" -l help -d "Show help message"
