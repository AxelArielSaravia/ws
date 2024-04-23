#!/bin/bash

# Copyright 2024 Axel Ariel Saravia

_ws_complete() {
    local command="${COMP_WORDS[1]}"
    if [[ $COMP_CWORD == 1 ]]; then
        COMPREPLY=($(compgen -W\
            "add clear-history dir go help init names list remove remove-all tmux version"\
            --\
            "${COMP_WORDS[1]}"\
        ))
        return;
    fi
    if [[ $COMP_CWORD == 2 ]]; then
        case $command in
           "help")
                COMPREPLY=($(compgen -W\
                "add clear-history dir go init names list remove remove-all tmux version"\
                    --\
                    "${COMP_WORDS[2]}"\
                ))
                ;;
            "go"|"remove"|"tmux")
                if [ -f "$HOME/.ws/.workspace"  ]; then
                    COMPREPLY=($(compgen -W\
                        "$(cat "$HOME/.ws/.workspace" | cut -d" " -f1 2> /dev/null)"\
                        --\
                        "${COMP_WORDS[2]}"\
                    ))
                fi
                ;;
            "remove-all")
                COMPREPLY=($(compgen -W "-ws -tmux -all" -- ${COMP_WORDS[3]}))
                ;;
        esac
        return;
    fi
    if [[ $COMP_CWORD == 3 ]]; then
        if [[ $command == "remove" ]]; then
            COMPREPLY=($(compgen -W "-ws -tmux -all" -- "${COMP_WORDS[3]}"))
        fi
        return;
    fi

    if [[ $COMP_CWORD == 4 ]]; then
        if [[ $command == "add" ]]; then
            COMPREPLY=($(compgen -W "-tmux" -- "${COMP_WORDS[4]}"))
        fi
        return;
    fi

}

complete -o default -o bashdefault -F _ws_complete ws
