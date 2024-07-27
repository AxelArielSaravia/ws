#!/bin/sh

#Creator: Axel Ariel Saravia
#Licence: GLWT(Good Luck With That) Public License

VERSION="dev-2024-08"
NAME="ws"
WORKSPACE_FILE="$HOME/.$NAME/.workspace"

TMUX_WINDOWS=(
    "nvim"
    "terminal"
)

_commands=(
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
_list_flags=("-tmux")
_add_flags=("-tmux" "-open")
_remove_flags=("-tmux" "-ws")

workspace_names=()
workspace_dirs=()
workspace_exist=false
workspace_set=false

function set_workspace {
    if [[ $workspace_set == false ]]; then
        while read line; do
            if [[ "${line:0:1}" == "n" ]]; then
                workspace_names+=("${line:2}")
            else
                workspace_dirs+=("${line:2}")
            fi
        done < $WORKSPACE_FILE
    fi
    workspace_set=true
}

function create_tmux() {
    local name="$1"
    local dir="$2"

    if (( ${#TMUX_WINDOWS[@]} == 0 )); then
        echo "$NAME ERROR: No windows set"
        exit 1
    fi

    tmux new-session -s "$name" -c "$dir" -n "${TMUX_WINDOWS[0]}" -d ';'
    for ((i=1; i < ${#TMUX_WINDOWS[@]}; ++i)); do
        tmux new-window -t "$name" -n "${TMUX_WINDOWS[$i]}" -c "$dir" ';'
    done
    tmux select-window -t "${TMUX_WINDOWS[0]}"
}

function help_msg {
    local arg="$1"
    case $arg in
        "add")
            echo "Create a key-value workspace that represents a working directories."
            echo "You can directly create a related tmux session if you add '-tmux' at the end."
            echo ""
            echo "Usage: $NAME add NAME DIR [-tmux|-open]"
            echo ""
            echo "    NAME  is any sequence of characters."
            echo "    DIR   is any valid directory in the storage. if the DIR specified doe not"
            echo "          exist, 'ws add' can make it."
            echo ""
            echo "Options:"
            echo "    -tmux create a tmux session named with NAME thats opens on DIR working"
            echo "          directory. If creation success shows a mesage in the console,"
            echo "          otherwise do nothing."
            echo "    -open create a tmux session named with NAME thats opens on DIR working"
            echo "          directory. If creation success opens the tmux session, otherwise do"
            echo "          nothing."
            echo ""
            echo "Important:"
            echo "If '$NAME' workspace is overwritten, the related tmux session (if exist)"
            echo "will be deleted (kill-session) and a new session will be created with the"
            echo "changes. (If you are in the related tmux session, the tmux 'kill-session'"
            echo "command will automatically exit tmux)."
            echo ""
            echo "See '$NAME help tmux' for more information about the tmux windows defaults."
            ;;
        "clear-history")
            echo "Apply the tmux clear-history command for all tmux sessions related to ws"
            echo ""
            echo "Usage: $NAME clear-history"
            echo ""
            ;;

        "dir")
            echo "Get a directory path from a workspace name"
            echo ""
            echo "Usage: $NAME dir NAME"
            echo ""
            ;;
        "dirs")
            echo "Shows all working directories"
            echo ""
            echo "Usage: $NAME dirs"
            echo ""
            ;;
        "init-tmux")
            echo "Create tmux sessions from all workspaces"
            echo ""
            echo "Usage $NAME init-tmux"
            echo ""
            ;;
        "list")
            echo "Shows all workspaces"
            echo ""
            echo "Usage: $NAME list [-tmux]"
            echo ""
            echo "    -tmux  shows tmux sessions"
            echo ""
            ;;
        "names")
            echo "Shows all asigned names"
            echo ""
            echo "Usage: $NAME names"
            echo ""
            ;;
        "open")
            echo "Open a tmux session related to a workspace."
            echo ""
            echo "Usage: $NAME open [NAME]"
            echo ""
            echo "    NAME  must be an existing workspace name. If no NAME is set"
            echo "          will open the last attached tmux session"
            echo "          (See '$NAME' names)". 
            echo ""
            echo "(Is the as '$NAME tmux NAME' command)"
            ;;
        "remove")
            echo "Delete a specific workspace"
            echo ""
            echo "Usage: $NAME remove NAME [-tmux|-ws]"
            echo ""
            echo "Options:"
            echo "    -tmux  delete only the tmux session. You can use '$NAME init-tmux' to create"
            echo "           a related tmux session again."
            echo "    -ws    delete only the ws information. If the tmux session are not"
            echo "           persistent, the tmux information will be deleted."
            echo ""
            echo "If no option pass delete both, ws and tmux information"
            echo ""
            echo "If you are in a tmux session (and the '-tmux' option is set), the tmux"
            echo "'kill-session' command will automaically exit tmux"
            ;;
        "remove-all")
            echo "Delete all working direactory."
            echo ""
            echo "Usage: $NAME remove-all [-tmux|-ws]"
            echo ""
            echo "Options:"
            echo "    -all   (default) delete both ws and tmux information"
            echo "    -tmux  delete only the tmux session. You can use '$NAME init-tmux' to create"
            echo "           a related tmux session again."
            echo "    -ws    ddelete only the ws information. If the tmux session are not"
            echo "           persistent, the tmux information will be deleted."
            echo ""
            echo "If no option pass delete both, ws and tmux information"
            ;;
        "tmux")
            echo "Open a tmux  session related to a workspace."
            echo ""
            echo "Usage: $NAME tmux NAME"
            echo ""
            echo "    NAME  must be an existing workspace name. If no NAME is set"
            echo "          will open the last attached tmux session"
            echo "          (See '$NAME' names)". 
            echo ""
            echo "(Is the as '$NAME open NAME' command)"
            ;;
        "tmux-template")
            echo ""
            ;;
        "version")
            echo "Shows the current version"
            echo ""
            echo "Usage: $NAME version"
            echo ""
            ;;
        *)
            echo "$NAME is a tool to managing working directories, and simplify 'tmux sessions'."
            echo ""
            echo "Usage: $NAME <command>"
            echo ""
            echo "Commands:"
            echo "    add             add a new working directory"
            echo "    clear-history   clear history of all tmux sessions"
            echo "    dir             get dir path from a workspace name"
            echo "    dirs            get all asigned directories"
            echo "    help            this text"
            echo "    init-tmux       init all workspace as tmux sessions"
            echo "    list            list all working directories"
            echo "    names           get all asigned names"
            echo "    open            open an specific tmux session"
            echo "    remove          remove a working directory"
            echo "    remove-all      remove all working directories"
            echo "    tmux            open an specific tmux session"
            echo "    version         print version"
            echo ""
            echo "Use '$NAME help <command>' for more information about a command."
            echo "And use '$NAME help tmux-template' for tmux windows template for each session."
            ;;
    esac
}

function cmd_add {
    local name="$1"
    local dir=$(realpath "$2")
    local tmux_session=false
    local open_session=false
    if [[ "$3" == "-tmux" ]]; then
        tmux_session=true
    elif [[ "$3" == "-open" ]]; then
        open_session=true
    fi
    set_workspace

    local msg_nothing="$NAME add: do nothing"

    local name_i=-1
    for j in "${!workspace_names[@]}"; do
        if [[ "${workspace_names[$j]}" == "$arg_name" ]]; then
            name_i=$j
            break;
        fi
    done
    local override="n"
    if (( $name_i != -1 )); then
        echo "$NAME add: the workspace already exist"
        read -p "$NAME add: do you want to ovverite the dir? [y | n (default)]" override
        if [[ "$override" != "y" ]]; then
            echo $msg_nothing
            return;
        fi
    fi
    local make_dir="n"
    if [[ ! -d "$dir" ]]; then
        echo "$NAME add: the dir '$dir' does not exist"
        read -p "$NAME add: do you want to create it? [y | n (default)]" make_dir
        if [[ "$make_dir" == "y" ]]; then
            mkdir "$dir"
        else
            echo $msg_nothing
            return;
        fi
    fi
    if [[ $override == "y" ]]; then
        workspace_dirs[$name_i]="$dir"
        echo -n > "$WORKSPACE_FILE"
        for i in "${!workspace_dirs[@]}"; do
            echo "n ${workspace_names[$i]}" >> $WORKSPACE_FILE
            echo "d ${workspace_dirs[$i]}" >> $WORKSPACE_FILE
        done

        tmux has-session -t "$name" &> /dev/null
        if [[ $? == 0 ]]; then
            tmkux kill-session -t "$name" &> /dev/null
        fi
    fi

    echo "n $name" >> $WORKSPACE_FILE
    echo "d $dir" >> $WORKSPACE_FILE

    if [[ $open_session == false ]]; then
        echo "$NAME add: '$name' <- '${dir}'"
        if [[ $tmux_session == true ]]; then
            create_tmux "$name" "$dir"
            echo "$HOME add: create tmux session"
        fi
    else
        create_tmux "$name" "$dir"
        if [[ $TMUX ]]; then
            tmux switch_client -t "$name"
        else
            tmux a -t "$name"
        fi
    fi
}

function cmd_dir {
    local arg_name="$1"
    if [[ $workspace_exist == false ]]; then
        echo "$NAME dir: no workspace found"
        return;
    fi
    set_workspace
    local i=0
    for name in "${workspace_names[@]}"; do
        if [[ "$name" == "$arg_name" ]]; then
            echo "${workspace_dirs[$i]}"
            return;
        fi
        i=$(($i+1))
    done
    echo "$NAME dir: No directory found with the name '$arg_name'"
}

function cmd_clear_history {
    if [[ $workspace_exist == false ]]; then 
        echo "$HOME clear-history: no workspace found"
        return;
    fi
    for name in "${workspace_names[@]}"; do
        tmux has-session -t "$name" &> /dev/null
        if [[ $? == 0 ]]; then
            tmux clear-history -t "$name"
        fi
    done
}

function cmd_init_tmux {
    local name=""
    local dir=""
    if [[ $workspace_exist == false ]]; then
        echo "$NAME init-tmux: no workspace found"
        return;
    fi
    set_workspace
    for i in "${!workspace_names[@]}"; do
        name=${workspace_names[$i]}
        dir=${workspace_dirs[$i]}
        tmux has-session -t "$name" &> /dev/null
        if [[ $? != 0 ]]; then
            create_tmux "$name" "$dir"
        fi
    done
}

function cmd_list {
    if [[ "$1" == "-tmux" ]]; then
        tmux ls -F'id: #{session_id}  name: #{session_name}'
        return;
    fi
    if [[ $workspace_exist == false ]]; then
        echo "$NAME list: no workspace found"
        return;
    fi
    set_workspace
    local max_len=0;
    local len=0
    for name in "${workspace_names[@]}"; do
        len=${#name}
        if (( $max_len < $len )); then
            max_len=$len
        fi
    done
    for i in "${!workspace_names[@]}"; do
        printf "%-0${max_len}s -> %s\n" "${workspace_names[$i]}" "${workspace_dirs[$i]}"
    done
}

function cmd_open {
    local cmd="$1"
    local arg_name="$2"
    if [[ $workspace_exist == false ]]; then
        echo "$NAME $cmd: no workspace found"
        return;
    fi
    set_workspace
    if [[ "$arg_name" != "" ]]; then
        local i=-1
        for j in "${!workspace_names[@]}"; do
            if [[ "${workspace_names[$j]}" == "$arg_name" ]]; then
                i=$j
                break;
            fi
        done
        if (( $i == -1 )); then
            echo "$NAME $cmd: '$arg_name' workspace is not found"
        fi

        tmux has-session -t "$arg_name" &> /dev/null
        if [[ $? != 0 ]]; then
            create_tmux "$arg_name" "${workspace_dirs[$i]}"
        fi
    fi
    if [[ $TMUX ]]; then
        tmux switch-client -t "$arg_name"
    else
        tmux a -t "$arg_name"
    fi
}

function cmd_remove {
    local arg_name="$1"
    local rm_tmux=true
    local rm_ws=true
    case "$2" in
        "-tmux") rm_ws=false;;
        "-ws") rm_tmux=false;;
    esac
    if [[ $workspace_exist == false ]]; then
        echo "$NAME remove: no workspace found"
        return;
    fi


    set_workspace

    local name_i=0
    for i in "${!workspace_names[@]}"; do
        if [[ "$arg_name" == "${workspace_names[$i]}" ]]; then
            name_i=$(($i))
            break;
        fi
    done
    if (( $name_i == -1 )); then
        echo "$NAME remove: '$arg_name' workspace is not found"
        return;
    fi
    if [[ $rm_tmux == true ]]; then
        tmux has-session -t "$arg_name"
        if [[ $? == 0 ]]; then
            tmux kill-session -t "$arg_name"
            if [[ $? == 0 ]]; then
                echo "$NAME remove: kill '$arg_name' tmux session"
            fi
        fi
    fi
    if [[ $rm_ws == true ]]; then
        echo -n > $WORKSPACE_FILE
        for i in "${!workspace_names[@]}"; do
            if (( $i != $name_i )); then
                echo "n ${workspace_names[$i]}" >> $WORKSPACE_FILE
                echo "d ${workspace_dirs[$i]}" >> $WORKSPACE_FILE
            fi
        done
        echo "$NAME remove: '$arg_name' was removed"
    fi
}

function cmd_remove_all {
    local rm_tmux=true
    local rm_ws=true
    case "$1" in
        "-tmux") rm_ws=false;;
        "-ws") rm_tmux=false;;
    esac
    if [[ $workspace_exist == false ]]; then
        echo "$NAME remove-all: no workspace found"
        return;
    fi
    set_workspace
    if [[ $rm_tmux == true ]]; then
        tmux kill-server &> /dev/null
        echo "$NAME remove-all: kill tmux server"
    fi
    if [[ $rm_ws == true ]]; then
        echo -n > $WORKSPACE_FILE
        echo "$NAME remove-all: removed all workspaces"
    fi

}

if [[ -f $WORKSPACE_FILE ]]; then
    if [[ -s $WORKSPACE_FILE ]]; then
        workspace_exist=true
    fi
else
    touch $WORKSPACE_FILE
fi
case "$1" in
    "add")
        if [[ ! "$2" || ! "$3" ]]; then
            help_msg add
        else
            cmd_add "$2" "$3" "$4"
        fi
        ;;
    "clear-history") cmd_clear_history;;
    "dir")
        if [[ ! "$2" ]]; then
            help_msg dir
        else
            cmd_dir "$2"
        fi
        ;;
    "dirs")
        if [[ $workspace_exist == true ]]; then
            set_workspace
            printf "%s\n" "${workspace_dirs[@]}"
        else
            echo "$NAME names: no workspace found"
        fi
        ;;
    "help") help_msg "$2";;
    "init-tmux") cmd_init_tmux;;
    "list") cmd_list "$2";;
    "names")
        if [[ $workspace_exist == true ]]; then
            set_workspace
            printf "%s\n" "${workspace_names[@]}"
        else
            echo "$NAME names: no workspace found"
        fi
        ;;
    "open") cmd_open open "$2";;
    "remove")
        if [[ ! "$2" ]]; then
            help_msg remove
        else
            cmd_remove "$2"
        fi
        ;;
    "remove-all") cmd_remove_all "$2";;
    "tmux") cmd_open tmux "$2";;
    "version") echo "$NAME version $VERSION";;
    *) help_msg;;
esac
