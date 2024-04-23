#!/bin/env sh

# Copyright 2024 Axel Ariel Saravia

#COMMANDS
#"add"
#"clear-history"
#"dir"
#"go"
#"init"
#"list"
#"names"
#"remove"
#"remove-all"
#"tmux"
#"version"

function ws() {
    local VERSION="0.0.4"
    local NAME="ws"
    local WORKSPACE_FILE="$HOME/.$NAME/.workspace"

    local workspace_exist=false

    local workspace_names=()
    local workspace_dirs=()


    if [[ -f "$WORKSPACE_FILE" ]]; then
        if [[ -s "$WORKSPACE_FILE" ]]; then
            workspace_exist=true
        fi
    else
        touch $WORKSPACE_FILE
    fi

    _set_workspaces() {
        workspace_names=($(cat $WORKSPACE_FILE | cut -d" " -f1))
        workspace_dirs=($(cat $WORKSPACE_FILE | cut -d" " -f2))
    }

    _help() {
        local arg="$1"
        case "$arg" in
            "add")
                ######                                                                                #
                echo "Usage: $NAME add NAME DIR [-tmux]"
                echo ""
                echo "Create a key-value workspace that represents a working directories."
                echo "You can directly create a related tmux session if you add '-tmux' at the end."
                echo ""
                echo "    NAME  is any sequence of characters."
                echo "    DIR   is any valid directory in the storage. if the DIR specified doe not"
                echo "          exist, 'wmux add' can make it."
                echo ""
                echo "    Options:"
                echo "    -tmux create a tmux session named with NAME thats opens on DIR working"
                echo "          directory. If creation success shows a mesage in the console"
                echo "          otherwise do nothing."
                echo ""
                echo "Important:"
                echo "If '$NAME' workspace is overwritten, the related tmux session (if exist)"
                echo "will be deleted (kill-session) and a new session will be created with the"
                echo "changes. (If you are in the related tmux session, the tmux 'kill-session'"
                echo "command will automatically exit tmux)."
                echo ""
                echo "See '$NAME help tmux' for more information about the tmux windows defaults."
                echo ""
                ;;
            "clear-history")
                echo "Usage: $NAME clear-history"
                echo ""
                echo "Apply the tmux clear-history command in all tmux sessions related to wmux"
                echo ""
                ;;
            "dirs")
                echo "Usage: $NAME dirs"
                echo ""
                echo "Shows all working directories"
                echo ""
                ;;
            "go")
                echo "Usage: $NAME go NAME"
                echo ""
                echo "It is a 'cd' (change directory) command wrapper, to jump direct to a working"
                echo "directory."
                echo ""
                ;;
            "names")
                echo "Usage: $NAME names"
                echo ""
                echo "Shows all names related to a working directory"
                echo ""
                ;;
            "list")
                echo "Usage: $NAME list"
                echo ""
                echo "Shows the NAME-DIR value of all working directories"
                echo ""
                ;;
            "remove")
                echo "Usage: $NAME remove NAME [-tmux|-ws|-all]"
                echo ""
                echo "Delete a specific working direactory."
                echo ""
                echo "    NAME must be an existing workspace name.(See '$NAME names')"
                echo ""
                echo "    Options:"
                echo "    -all  (default) delete both wmux and tmux information"
                echo "    -tmux delete only the tmux session. You can use '$NAME init' to create"
                echo "          a related tmux session again."
                echo "    -ws   delete only the wmux information. If the tmux session are not"
                echo "          persistent, the tmux information will be deleted."
                echo ""
                echo "If you are in a tmux session (and the '-tmux' option is set), the tmux"
                echo "'kill-session' command will automaically exit tmux"
                echo ""
                ;;
            "remove-all")
                echo "Usage: $NAME remove-all [-tmux|-ws|-all]"
                echo ""
                echo "Delete all working direactory."
                echo ""
                echo "    Options:"
                echo "    -all  (default) delete both wmux and tmux information"
                echo "    -tmux delete only the tmux session. You can use '$NAME init' to create"
                echo "          a related tmux session again."
                echo "    -ws   delete only the wmux information. If the tmux session are not"
                echo "          persistent, the tmux information will be deleted."
                echo ""
                ;;
            "tmux")
                echo "Usage: $NAME tmux NAME"
                echo ""
                echo "Open a tmux session related to a workspace."
                echo ""
                echo "    NAME must be an existing workspace name.(See '$NAME names')"
                echo ""
                ;;
            "tmux-template")
                echo ""
                echo "The tmux session template:"
                echo ""
                echo '    tmux new-session -s $name -c $dir -n nvim -d\;\'
                echo '         new-window -t $name -n terminal -c "$dir" \;\'
                echo '         select-window -t nvim'
                echo ""
                echo "This template create 2 windows, 'nvim' and 'terminal', and define \$dir as the"
                echo "working directory."
                echo ""
                ;;
            *)
                echo "$NAME is a tool to managing working directories, and simplify 'tmux sessions'."
                echo ""
                echo "Usage: $NAME <command>"
                echo ""
                echo "The commands are:"
                echo ""
                echo "    add           add a new working directory"
                echo "    clear-history clear history of all tmux sessions"
                echo "    dirs          get all asigned directories"
                echo "    go            jump to a workspace"
                echo "    init          init all workspace as tmux sessions"
                echo "    list          list all working directories"
                echo "    names         get all asigned names"
                echo "    remove        remove a working directory"
                echo "    remove-all    remove all working directory"
                echo "    tmux          open an specific tmux session"
                echo "    version       print $NAME version"
                echo ""
                echo "Use '$NAME help <command>' for more information about a command."
                echo "And use '$NAME help tmux-template' for tmux windows template for each session."
                echo ""
                ;;
        esac
    }

    #_create_tmux_session [1]=name [2]=dir
    _create_tmux_session() {
        local name="$1"
        local dir="$2"

        #tmux windows names
        local WINDOWS=(nvim terminal)

        tmux new-session -s "$name" -c "$dir" -n "${WINDOWS[0]}" -d\;\
            new-window -t "$name" -n "${WINDOWS[1]}" -c "$dir" \;\
            select-window -t "${WINDOWS[0]}"
    }

    #_add [1]=new_name [2]=new_dir [3]=('-tmux')
    _add() {
        local new_name="$1"
        local new_dir=$(realpath "$2")
        local tmux_session=false

        if [[ "$3" == "-tmux" ]]; then
            tmux_session=true
        fi

        _set_workspaces

        local msg_name="$NAME add:"
        local msg_exit="$msg_name do nothing."

        local name_index=-1
        for i in ${!workspace_names[@]}; do
            if [[ "$new_name" == ${workspace_names[i]} ]]; then
                name_index=$i
                break;
            fi
        done

        local override_dir="n"
        if [[ $name_index != -1 ]]; then
            echo "$msg_name '$new_name' workspace already exist!!"
            read -p "$msg_name did you want to overrite it? [y|n (default)] " override_dir
            if [[ "$override_dir" != "y" ]]; then
                echo "$msg_exit"
                return;
            fi
        fi

        local create_dir="n"
        if [[ ! -d "$new_dir" ]]; then
            echo "$msg_name '$new_dir' dir does not exist!!"
            read -p "$msg_name did you want to create it? [y|n (default)] " create_dir
            if [[ "$create_dir" == "y" ]]; then
                mkdir "$new_dir"
            else
                echo "$msg_exit"
                return;
            fi
        fi

        if [[ "$override_dir" == "y" ]]; then 
            workspace_dirs[$name_index]=$new_dir
            echo -n > "$WORKSPACE_FILE"
            for i in ${!workspace_dirs[@]}; do
                echo "${workspace_names[$i]} ${workspace_dirs[$i]}"\
                    >> "$WORKSPACE_FILE"
            done

            tmux has-session -t "$new_name" &> /dev/null
            if [[ $? == 0 ]]; then
                tmux kill-session -t "${workspace_name}" &> /dev/null
            fi
        else
            echo "$new_name $new_dir" >> "$WORKSPACE_FILE"
        fi

        echo "$msg_name"
        echo "  $new_name $new_dir"


        if [[ $tmux_session == true ]]; then
            _create_tmux_session "$new_name" "$new_dir"
            echo "$msg_name create tmux session."
        fi
    }

    #_remove-all [1]=("-ws"|"-tmux"|"-all")
    _remove-all() {
        local tmux_clear=true
        local wmux_clear=true
        local msg_name="$NAME remove-all:"

        case "$1" in
            "-tmux") wmux_clear=false;;
            "-ws") tmux_clear=false;;
        esac

        if [[ $workspace_exist == true ]]; then
            _set_workspaces
            if [[ $tmux_clear == true ]]; then
                tmux kill-server &> /dev/null
            fi
            if [[ $wmux_clear == true ]]; then
                echo -n > "$WORKSPACE_FILE"
            fi
        fi
    }

    #_delete [1]=workspace_name [2]=("-ws"|"-tmux"|"-all")
    _remove() {
        local workspace_name="$1"

        local tmux_kill=true
        local wmux_kill=true
        case "$2" in
            "-tmux") wmux_kill=false;;
            "-ws") tmux_kill=false;;
        esac

        local msg_name="$NAME remove:"
        local msg_no_found="$msg_name '$workspace_name' workspace is not found, do nothing."

        if [[ $workspace_exist == false ]]; then
            echo $msg_no_found
            return;
        fi

        _set_workspaces

        local name_index=-1
        for i in "${!workspace_names[@]}"; do
            if [[ "$workspace_name" == ${workspace_names[i]} ]]; then
                name_index=$(($i))
                break
            fi
        done
        if [[ $name_index == -1 ]]; then
            echo $msg_no_found
            return;
        fi
        if [[ $tmux_kill == true ]]; then
            tmux has-session -t "$workspace_name" &> /dev/null
            if [[ $? == 0 ]]; then
                tmux kill-session -t "${workspace_name}"
                if [[ $? == 0 ]]; then
                    echo "$msg_name kill tmux session."
                fi
            fi
        fi
        if [[ $wmux_kill == true ]]; then
            echo -n > "$WORKSPACE_FILE"
            for i in "${!workspace_names[@]}"; do
                if [[ $i != $name_index ]]; then
                    echo "${workspace_names[$i]} ${workspace_dirs[$i]}"\
                        >> "$WORKSPACE_FILE"
                fi
            done
            echo "$msg_name '$workspace_name' was removed."
        fi
    }

    _init() {
        local name=""
        local dir=""
        for i in "${!workspace_names[@]}"; do
            name=${workspace_names[$i]}
            dir=${workspace_dirs[$i]}
            tmux has-session -t "$name" &> /dev/null
            if [[ $? != 0 ]]; then
                _create_tmux_session "$name" $dir
            fi
        done
    }

    #_go [1]=workspace_name
    _go() {
        local workspace_name="$1"
        local msg_name="$NAME go:"
        local msg_no_found="$msg_name sorry, '$workspace_name' workspace is not found."
        if [[ $workspace_exist == false ]]; then
            echo $msg_no_found
            return;
        fi

        _set_workspaces

        local name_index=-1;
        for i in ${!workspace_names[@]}; do
            if [[ "$workspace_name" == ${workspace_names[i]} ]]; then
                name_index=$(($i))
                break
            fi
        done
        if [[ $name_index == -1 ]]; then
            echo $msg_no_found
        else
            cd "${workspace_dirs[$name_index]}"
        fi
    }

    #_tmux [1]=workspace_name
    _tmux() {
        local workspace_name="$1"

        local msg_name="$NAME tmux:"
        local msg_no_found="$msg_name sorry, '$workspace_name' workspace is not found."

        if [[ $workspace_exist == false ]]; then
            echo $msg_no_found
            return;
        fi
        _set_workspaces

        local name_index=-1
        for i in ${!workspace_names[@]}; do
            if [[ "$workspace_name" == ${workspace_names[i]} ]]; then
                name_index=$(($i))
                break
            fi
        done

        if [[ $name_index == -1 ]]; then
            echo $msg_no_found
            return;
        fi

        tmux has-session -t "$workspace_name" &> /dev/null
        if [[ $? != 0 ]]; then
            _create_tmux_session "$workspace_name" "${workspace_dirs[$name_index]}"
        fi

        if [[ $TMUX ]]; then
            tmux switch-client -t "$workspace_name"
        else
            tmux a -t "$workspace_name"
        fi
    }

    case "$1" in
        "add")
            if [[ ! "$2" || ! "$3" ]]; then
                _help "add"
            else
                _add "$2" "$3" "$4"
            fi
            ;;
        "dirs")
            if [[ $workspace_exist == true ]]; then
                _set_workspaces
                for val in "${workspace_dirs[@]}"; do
                    echo $val
                done
            else
                echo "$NAME dirs: no workspace found."
            fi
            ;;
        "clear-history")
            if [[ $workspace_exist == true ]]; then
                _set_workspaces
                for name in "${workspace_names[@]}"; do
                    tmux has-session -t "$workspace_name" &> /dev/null
                    if [[ $? == 0 ]]; then
                        tmux clear-history -t "$name"
                    fi
                done
            fi
            ;;
        "go")
            if [[ ! "$2" ]]; then
                _help "go"
            else
                _go "$2"
            fi
            ;;
        "init")
            if [[ $workspace_exist == true ]]; then
                _set_workspaces
                _init
            fi
            ;;
        "list")
            if [[ $workspace_exist == true ]]; then
                _set_workspaces
                for i in "${!workspace_names[@]}"; do
                    echo "${workspace_names[$i]} -> ${workspace_dirs[$i]}"
                done
            else
                echo "$NAME list: no workspace found."
            fi
            ;;
        "names")
            if [[ $workspace_exist == true ]]; then
                _set_workspaces
                for val in "${workspace_names[@]}"; do
                    echo $val
                done
            else
                echo "$NAME names: no workspace found."
            fi
            ;;
        "remove")
            if [[ ! "$2" ]]; then
                _help "delete"
            else
                _remove "$2" "$3"
            fi
            ;;
        "remove-all")
            _remove-all "$2"
            ;;
        "tmux")
            if [[ ! "$2" ]]; then 
                _help "tmux"
            else
                _tmux "$2"
            fi
            ;;
        "version")
            echo "$VERSION"
            ;;
        "help")
            _help "$2"
            ;;
        *)
            _help
            ;;
    esac
}
