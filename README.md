# aw-watcher-bash [WIP]

Supports:
- bash
- zsh

## Installation

### Install [aw-watcher-terminal](https://github.com/Otto-AA/aw-watcher-terminal/)

This is the general watcher all shell-specific watchers send the data to.

### Install [bash-preexecute](https://github.com/rcaloras/bash-preexec#install)

**NOTE** This is not needed for zsh, only for bash

```bash
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

### Download aw-watcher-bash

```bash
git clone https://github.com/otto-aa/aw-watcher-bash
```

### Run aw-watcher-terminal in the background

Make sure that aw-watcher-terminal is running in the background.
This is needed because aw-watcher-bash is just a hook which sends terminal info to aw-watcher-terminal, the data itself is then packaged and sent by aw-watcher-terminal so without that running all data will be lost.

### Add following code to the bottom of your ~/.bashrc or ~/.zshrc file

Replace the AW_WATCHER_BASH_PREEXEC variable to the path to the aw-watcher-bash-preexec.sh script on your computer

```bash
source $AW_WATCHER_BASH_PREEXEC
```

### Make sure aw-watcher-terminal is started

As described [here](https://github.com/Otto-AA/aw-watcher-terminal/)

### Complete

Open a new terminal and start executing commands!
