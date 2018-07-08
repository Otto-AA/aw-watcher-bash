export PATH=$PATH:~/.local/bin/

_aw_current_shell="$(ps -p "$$" | tail -n 1 | awk '{ print $4 }')"
if [[ "$_aw_current_shell" == "zsh" ]]; then
  # zsh supports preexec natively, do nothing
  : # : is a nop
elif [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh
else
  echo "preexec is not supported by your terminal and bash-preexec is not installed at ~/.bash-preexec.sh, aw-watcher-bash will not work"
fi


function _aw_send_event() {
    # aw-watcher-bash "$BASHPID" "$(date --iso-8601=ns)" 'preexec' 'ls' 'bash'
    # for an accurate version of the parameters see add_arg
    pipe_message_args=()
    event="$1"
    pid="$2"
    extra_arg="$3"

    logfile="${XDG_CACHE_HOME:-$HOME/.cache}/activitywatch/log/aw-watcher-terminal/aw-watcher-bash.log"
    fifo_path="${XDG_DATA_HOME:-$HOME/.local/share}/activitywatch/aw-watcher-terminal/aw-watcher-terminal-fifo"


    function escape_quotes() {
        # escape_quotes
        # Prepends a backslash to every quote (") and every backslash (\)
        local _escaped="${1/\\/\\\\}"
        _escaped="${_escaped/\"/\\\"}"
        echo "$_escaped"
    }

    function add_arg() {
        # Add an argument (e.g. --pid 1234) to the pipe_message_args array
        # $1: key
        # $2: val (or --first-val)
        pipe_message_args+=("$1 \"$(escape_quotes "$2")\"")
    }

    add_arg '--event' "$event"
    add_arg '--pid' "$pid"
    add_arg '--path' "$PWD"
    add_arg '--time ' "$(date --iso-8601=ns)"
    add_arg '--shell' "$_aw_current_shell"


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

_aw_send_terminal_event() {
    # Call send_event in a background process to
    # prevent blocking and in a subshell to prevent logging
    (_aw_send_event "$1" "$PPID" "$2" &)
}

_aw_send_terminal_event 'preopen'

precmd() {
    _aw_send_terminal_event 'precmd' "$?"
}

preexec() {
    _aw_send_terminal_event 'preexec' "$1"
}

_aw_preclose() {
    _aw_send_terminal_event 'preclose'
}
trap _aw_preclose TERM EXIT
