# aw-watcher-bash [WIP]

## Installation

### Install [aw-watcher-terminal](https://github.com/Otto-AA/aw-watcher-terminal/)

This is the general watcher all shell-specific watchers send the data to.

### Install [bash-preexecute](https://github.com/rcaloras/bash-preexec#install)

```bash
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

### Install aw-watcher-bash

```bash
git clone https://github.com/otto-aa/aw-watcher-bash
cd aw-watcher-bash
make build
```

### Add following code to the bottom of your ~/.bashrc file

_Note: In case you use zsh, drop the bash-preexec.sh part, as preexec is in-build in zsh_

```bash
# Send data to local ActivityWatch server
if [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh

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

  trap aw-watcher-terminal-preclose TERM EXIT
fi
```

### Make sure aw-watcher-terminal is started

As described [here](https://github.com/Otto-AA/aw-watcher-terminal/)

### Open a new terminal and start executing commands

```bash
echo "Finished installation"
```