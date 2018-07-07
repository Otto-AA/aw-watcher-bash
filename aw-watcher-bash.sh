export PATH=$PATH:~/.local/bin/

current_shell=$(ps -p "$$" | tail -n 1 | awk '{ print $4 }')
if [[ $current_shell == "zsh" ]]; then
  # zsh supports preexec natively, do nothing
  : # : is a nop
elif [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh
else
  echo "preexec is not supported by your terminal and bash-preexec is not installed at ~/.bash-preexec.sh, aw-watcher-bash will not work"
fi


function escape_quotes() {
    # escape_quotes
    # Prepends a backslash to every quote (") and every backslash followed by a quote (\") or backslash (\\)
    #
    # From: echo "\"" > "output"
    # To:   echo \"\\\"\" > \"output\"
    # From: echo "\\" > "output"
    # To:   echo \"\\\\\" > \"output\"
    original="$1"
    length=${#original}
    result=""

    # Iterate over chars and prepend a backslash to every quote and every backslash followed by a quote or a backslash
    for (( i=0; i<$length; i++ )); do
        char="${original:$i:1}"
        if [[ $char = \" ]]; then
            result+="\\"
        elif [[ $char = "\\" ]]; then
            next_char_index=$((i+1))
            if [[ $next_char_index -lt $length ]]; then
                next_char="${original:$next_char_index:1}"
                if [[ $next_char  = \" ]] || [[ $next_char = "\\" ]]; then
                    result+="\\"
                fi
            fi
        fi
        result+="$char"
    done

    echo "$result"
}


function send_event() {
    # aw-watcher-bash "$BASHPID" "$(date --iso-8601=ns)" 'preexec' 'ls' 'bash'
    # for an accurate version of the parameters see add_arg
    pipe_message_args=()
    event=$1
    pid=$2
    extra_arg=$3

    logfile="${XDG_CACHE_HOME:-$HOME/.cache}/activitywatch/log/aw-watcher-terminal/aw-watcher-bash.log"
    fifo_path="${XDG_DATA_HOME:-$HOME/.local/share}/activitywatch/aw-watcher-terminal/aw-watcher-terminal-fifo"

    function add_arg() {
        # Add an argument (e.g. --pid 1234) to the args array and escape the quotes
        # $1: key
        # $2: val (or --first-val)
        # $3: --shift or --no-shift  (use this to remove the latest value)
        key="$1"
        val="$2"
        pipe_message_args+=("$key \"$(escape_quotes "$val")\"")
    }

    add_arg '--event' "$event"
    add_arg '--pid' "$2"
    add_arg '--path' "$PWD"
    add_arg '--time ' "$(date --iso-8601=ns)"
    add_arg '--shell' "$current_shell"


    # Add arguments depending on event type
    case "$event" in
        'preopen')
            ;;
        'preexec')
            add_arg '--command' "$extra_arg"
            ;;
        'precmd')
            add_arg '--exit-code' "$extra_arg"
            ;;
        'preclose')
            ;;
        *)
            echo "Unknown event: $event" >> "$logfile"
            ;;
    esac

    # send message to pipe
    message="${pipe_message_args[*]} --send-heartbeat"
    echo "$message" > "$fifo_path" &

    # The background process would keep open if the pipe was not opened for reading at the time of execution
    # Therefore delete background process after delay
    pipe_sender_pid="$!"
    sleep 5 && kill "$pipe_sender_pid" &> /dev/null &
}

send_aw_watcher_bash_event() {
    # Call send_event in a background process to
    # prevent blocking and in a subshell to prevent logging
    (send_event "$1" "$PPID" "$2" &)
}

aw_watcher_terminal_preclose() {
    send_aw_watcher_bash_event 'preclose'
}

send_aw_watcher_bash_event 'preopen'
trap aw_watcher_terminal_preclose TERM EXIT

preexec() {
    send_aw_watcher_bash_event 'preexec' "$1"
}

precmd() {
    send_aw_watcher_bash_event 'precmd' "$?"
}
