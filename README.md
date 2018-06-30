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

  base_args=("$PPID" "$(date --iso-8601=ns)")

  (aw-watcher-bash "${base_args[@]}" 'preopen')

  preexec() {
    # Call aw-watcher-bash in a background process to 
    # prevent blocking and in a subshell to prevent logging
    (aw-watcher-bash "${base_args[@]}" 'preexec' "$1" 'bash' &)
  }
  
  precmd() {
    (aw-watcher-bash "${base_args[@]}" 'precmd' "$?" &)
  }
  
  aw-watcher-terminal-preclose() {
    (aw-watcher-bash "${base_args[@]}" 'preclose' &)
  }

  trap aw-watcher-terminal-preclose INT TERM EXIT
fi
```

### Make sure aw-watcher-terminal is started

As described [here](https://github.com/Otto-AA/aw-watcher-terminal/)

### Open a new terminal and start executing commands

```bash
echo "Finished installation"
```