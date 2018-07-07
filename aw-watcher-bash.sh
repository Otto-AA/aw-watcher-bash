#!/usr/bin/env bash

# usage of aw-watcher-bash.sh
#
# aw-watcher-bash "$BASHPID" "$(date --iso-8601=ns)" 'preexec' 'ls' 'bash'
# for an accurate version of the parameters see add_arg


# escape_quotes
# Prepends a backslash to every quote (") and every backslash followed by a quote (\") or backslash (\\)
#
# From: echo "\"" > "output"
# To:   echo \"\\\"\" > \"output\"
# From: echo "\\" > "output"
# To:   echo \"\\\\\" > \"output\"
escape_quotes() {
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

passed_args=("$@")
pipe_message_args=()

logfile="${XDG_CACHE_HOME:-$HOME/.cache}/activitywatch/log/aw-watcher-terminal/aw-watcher-bash.log"
fifo_path="${XDG_DATA_HOME:-$HOME/.local/share}/activitywatch/aw-watcher-terminal/aw-watcher-terminal-fifo"

# add_arg
# Add an argument (e.g. --pid 1234) to the args array and escape the quotes
# $1: key
# $2: val (or --first-val)
# $3: --shift or --no-shift  (use this to remove the latest value)
add_arg() {
    key="$1"
    val="$2"
    if [[ "$val" = "--first-val" ]] || [[ "$val" = "" ]]; then
        val="${passed_args[0]}"
    fi
    pipe_message_args+=("$key \"$(escape_quotes "$val")\"")
    if [[ "$3" = "--shift" ]] || [[ "$3" = "" ]]; then
        passed_args=("${passed_args[@]:1}")
    fi
}

# Reserved arguments
add_arg '--pid'
add_arg '--shell'
add_arg '--time'

event="${passed_args[0]}"
add_arg '--event'
add_arg '--path' "$PWD" --no-shift


# Add arguments depending on event type
case "$event" in
    'preopen')
        ;;
    'preexec')
        add_arg '--command'
        ;;
    'precmd')
        add_arg '--exit-code'
        ;;
    'preclose')
        ;;
    *)
        echo "Unknown event: $event" >> "$logfile"

esac


message="${pipe_message_args[*]} --send-heartbeat"

# send message to pipe and logfile
echo "$message" > "$fifo_path" &
echo "$message" >> "$logfile"

# The background process would keep open if the pipe was not opened for reading at the time of execution
# Therefore delete background process after delay
pipe_sender_pid="$!"
sleep 5 && kill "$pipe_sender_pid" &> /dev/null &