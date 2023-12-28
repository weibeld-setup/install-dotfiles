# ~/.bashrc.homebrew

#------------------------------------------------------------------------------#
# Tmux (referenced from ~/.tmux.conf)
#------------------------------------------------------------------------------#

# Create tmux pane in current working directory
tmux-split-window-same-dir() {
  tmux split-window $1
  tmux send-keys "cd $PWD; clear" Enter
}

# Create tmux window in current working directory
tmux-new-window-same-dir() {
  tmux new-window
  tmux send-keys "cd $PWD; clear" Enter
}

