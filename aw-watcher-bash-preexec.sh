export PATH=$PATH:~/.local/bin/

CURRENT_SHELL=$(ps -p "$$" | tail -n 1 | awk '{ print $4 }')
if [[ $CURRENT_SHELL == "zsh" ]]; then
  # zsh supports preexec natively, do nothing
  : # : is a nop
elif [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh
else
  echo "preexec is not supported by your terminal and bash-preexec is not installed at ~/.bash-preexec.sh, aw-watcher-bash will not work"
fi

send_aw_watcher_bash_event() {
  local base_args=("$PPID" 'bash' "$(date --iso-8601=ns)")
  local args=("${base_args[@]}" "$@")
  (aw-watcher-bash "${args[@]}" &)
}

send_aw_watcher_bash_event 'preopen'

preexec() {
  # Call aw-watcher-bash in a background process to
  # prevent blocking and in a subshell to prevent logging
  send_aw_watcher_bash_event 'preexec' "$1"
}

precmd() {
  send_aw_watcher_bash_event 'precmd' "$?"
}

aw-watcher-terminal-preclose() {
  send_aw_watcher_bash_event 'preclose'
}

trap aw-watcher-terminal-preclose INT TERM EXIT
