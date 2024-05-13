# Shell History
#
# TODO: find way to sync history of all shells with HISTFILE and to dedupcliate
#   HISTFILE (erasedups does not work on HISTFILE), see [1]
#   [1] https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history
#==============================================================================#

# TODO: is this necessary?
# Append to $HISTFILE rather than overwriting it
#shopt -s histappend

# Increase history size (default is 500)
export HISTSIZE=5000
export HISTFILESIZE=5000

# 
export HISTCONTROL=ignoredups:erasedups

_prompt-command-append 'history -a'

# Search through the central history file (see PROMPT_COMMAND) and either
# print or directly execute the selected command
# TODO: paste the command on the command line without executing it
hist() {
  _ensure-installed fzf || return 1
  if [[ "$1" = -x ]]; then
    eval $(cat "$HISTFILE" | fzf -e --tac)
  else
    cat "$HISTFILE" | fzf -e --tac
  fi
}
