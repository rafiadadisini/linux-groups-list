#!/bin/bash

# Bash completion for groups-list

_groups_list_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Available options
    opts="-g -u -n -a -m -s -U -c -v -f -L -H -r -h --gid-min --gid-max --range --help"

    case "$prev" in
        -f|--filter)
            # Suggest common group names
            COMPREPLY=( $(compgen -W "sudo wheel docker audio video" -- "$cur") )
            return 0
            ;;
        -L|--gid-min|-H|--gid-max)
            # GID values - just complete with numbers
            COMPREPLY=( $(compgen -W "0 100 500 1000 2000" -- "$cur") )
            return 0
            ;;
        -r|--range)
            # Range format
            COMPREPLY=( $(compgen -W "0-1000 1000-2000" -- "$cur") )
            return 0
            ;;
        -p|--prefix)
            # Directory completion
            COMPREPLY=( $(compgen -d -- "$cur") )
            return 0
            ;;
    esac

    # Main options
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
}

complete -o bashdefault -o default -o nospace -F _groups_list_completion groups-list
