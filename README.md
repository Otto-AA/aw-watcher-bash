# aw-watcher-bash [WIP]

## Installation

### Install aw-watcher-terminal

This is the general watcher all shell-specific watchers require.
You can find it [here](https://github.com/Otto-AA/aw-watcher-terminal/).

### Install [bash-preexecute](https://github.com/rcaloras/bash-preexec#install)

```bash
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

### Copy the aw-watcher-bash-* scripts to a /bin dir

```bash
make build
```

### Add following code to the bottom of your ~/.bashrc file

```bash
# Send data to local ActivityWatch server
if [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh

  (aw-watcher-bash-preopen "$PPID" &)

  preexec() {
    # Call aw-watcher-bash in a background process to 
    # prevent blocking and in a subshell to prevent logging
    (aw-watcher-bash-preexec "$PPID" "$1" "bash" &)
  }
  
  precmd() {
    (aw-watcher-bash-precmd  "$PPID" "$?" &)
  }
  
  aw-watcher-terminal-preclose() {
    (aw-watcher-bash-preclose "$PPID" &)
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