# aw-watcher-bash [WIP]

## Installation

### Install aw-watcher-terminal

This is the general watcher all shell-specific watchers require.
You can find it [here](https://github.com/Otto-AA/aw-watcher-terminal/).

### Install [bash-preexecute](https://github.com/rcaloras/bash-preexec#install)

```bash
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

### Copy aw-awtcher-bash.sh to a /bin dir

```bash
# It just needs to be callable via aw-watcher-bash
# Feel free to use other methods if you wish
cp ./aw-watcher-bash.sh ~/.local/bin/aw-watcher-bash
chmod +x ~/.local/bin/aw-watcher-bash
```

### Add following code to the bottom of your ~/.bashrc file

```bash
# Send data to local ActivityWatch server
if [[ -f ~/.bash-preexec.sh ]]; then
  source ~/.bash-preexec.sh
  preexec() {
    # Call aw-watcher-bash in a background process to
    # prevent blocking and in a subshell to prevent logging
    (aw-watcher-bash "$1" &)
  }
fi
```

### Make sure aw-watcher-terminal is started

As described [here](https://github.com/Otto-AA/aw-watcher-terminal/)

### Open a new terminal and start executing commands

```bash
echo "Finished installation"
```