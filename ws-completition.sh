#!/bin/bash

#Creator: Axel Ariel Saravia
#Licence: GLWT(Good Luck With That) Public License

_ws_complete() {
    local workspace_file="$HOME/.ws/.workspace"
    local commands=(
        "add"
        "clear-history"
        "dir"
        "dirs"
        "help"
        "init-tmux"
        "list"
        "names"
        "open"
        "remove"
        "remove-all"
        "tmux"
        "version"
    )
    local add_flags=("-tmux" "-open")
    local list_flags=("-tmux")
    local remove_flags=("-tmux" "-ws")
    local names=()
    local command="${COMP_WORDS[1]}"

    case $COMP_CWORD in
        1) COMPREPLY=($(compgen -W "${commands[*]}" -- "${COMP_WORDS[1]}")) ;;
        2) case $command in
            "help")
                COMPREPLY=($(compgen -W "${commands[*]}" -- "${COMP_WORDS[2]}"))
            ;;
            "remove-all")
                COMPREPLY=($(compgen -W "${remove_flags[*]}" -- ${COMP_WORDS[2]}))
            ;;
            "list")
                COMPREPLY=($(compgen -W "${list_flags[*]}" -- ${COMP_WORDS[2]}))
            ;;
            "remove"|"tmux"|"open"|"dir")
                if [[ -f $workspace_file && -s $workspace_file ]]; then
                    while read line; do
                        if [[ "${line:0:1}" == "n" ]]; then
                            names+=("${line:2}")
                        fi
                    done < $workspace_file
                    COMPREPLY=($(compgen -W "${names[*]}" -- "${COMP_WORDS[2]}"))
                fi
                ;;
            esac
        ;;
        3) case $command in
                "remove")
                    COMPREPLY=($(compgen -W "${remove_flags[*]}" -- ${COMP_WORDS[3]}))
                ;;
            esac
        ;;
        4) case $command in
            "add")
                COMPREPLY=($(compgen -W "${remove_flags[*]}" -- "${COMP_WORDS[4]}"))
            ;;
            esac
        ;;
    esac
}

complete -o default -D -F _ws_complete ws
