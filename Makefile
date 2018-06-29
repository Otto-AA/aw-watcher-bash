build:
	# Copy watchers and make them executable
	cp ./aw-watcher-bash-preopen.sh ~/.local/bin/aw-watcher-bash-preopen
	cp ./aw-watcher-bash-preexec.sh ~/.local/bin/aw-watcher-bash-preexec
	cp ./aw-watcher-bash-precmd.sh ~/.local/bin/aw-watcher-bash-precmd
	cp ./aw-watcher-bash-preclose.sh ~/.local/bin/aw-watcher-bash-preclose

	chmod +x ~/.local/bin/aw-watcher-bash-preopen
	chmod +x ~/.local/bin/aw-watcher-bash-preexec
	chmod +x ~/.local/bin/aw-watcher-bash-precmd
	chmod +x ~/.local/bin/aw-watcher-bash-preclose