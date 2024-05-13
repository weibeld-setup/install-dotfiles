# Readline
# Description:
#   TODO
# References:
#   [1] https://www.gnu.org/software/bash/manual/bash.html#Command-Line-Editing
#   [2] https://www.gnu.org/software/bash/manual/bash.html#Readline-Init-File-Syntax
#==============================================================================#

# Avoid duplication when completing in the middle of a word
bind 'set skip-completed-text on'

# Enable/disable vi line-editing mode
vi-mode-on() {
  bind 'set editing-mode vi'  # Equivalent to 'set -o vi'
  bind 'set show-mode-in-prompt on'
  bind 'set vi-ins-mode-string \1\033[1;32m@|\033[m\2'
  bind 'set vi-cmd-mode-string \1\033[1;42;37m@\033[;1;32m|\033[m\2'
  bind '"\C-k": vi-movement-mode'
}

vi-mode-off() {
  bind 'set editing-mode emacs'  # Equivalent to 'set +o vi'
  bind 'set show-mode-in-prompt off'
}
