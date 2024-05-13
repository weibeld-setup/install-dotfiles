#==============================================================================#
# Shell Configuration: Base
#==============================================================================#

#------------------------------------------------------------------------------#
# Optional shell options
#------------------------------------------------------------------------------#

# Enable expansion of variables in filename completion
shopt -s direxpand

#------------------------------------------------------------------------------#
# Terminal capabilities
#------------------------------------------------------------------------------#
# Used by applications to learn the capabilities of the terminal they're
# running in. The value xterm-256color works with tmux (xterm-256color-italic
# may cause tmux to fail)
export TERM=xterm-256color
alias ssh='TERM=xterm-256color ssh'

#------------------------------------------------------------------------------#
# Default text editor
#------------------------------------------------------------------------------#
export EDITOR=vim

#------------------------------------------------------------------------------#
# Set locale
# TODO: set LC_* variables:
#   - Display values with `locale`
#   - Display all available locales with `locale -a | sort`
# Note: see all available locales with 'locale -a'
#------------------------------------------------------------------------------#
export LC_ALL=en_GB.UTF-8

#------------------------------------------------------------------------------#
# Set up 'ls' colour output
#   - BSD
#     - Fields (index)
#       - 1=dir, 2=symlink, 3=socket, 4=pipe, 5=executable, 6=block special,
#         7=char special, 8=executable with setuid, 9=executable with setgid,
#         10=other-writable dir with sticky bit, 11=other-writable dir without
#         sticky bit
#     - Colours
#       - a|A=black, b|B=red, c|C=green, d|D=yellow, e|E=blue, f|F=magenta,
#         g|G=cyan, h|H=white, x|X=default
#       - Upper-case means bold
#     - Format:
#         <foreground><background>...
#     - Example:
#         Gx: bold cyan foreground and default background
#     - Documentation:
#         man ls (search for 'LSCOLORS')
#   - GNU
#     - Fields:
#       - di=dir, ln=symlink, so=socket, pi=pipe, ex=executable, bd=block
#         special, cd=char special, su=executble with setuid, sg=executable with
#         setgid, tw=other-writable dir with sticky bit, ow=other-writable dir
#         without sticky bit
#     - Colours
#       - ANSI colour codes
#     - Documentation:
#       - man ls
#       - man dircolors
#       - dircolors
#------------------------------------------------------------------------------#

# TODO: use _is-bsd
if _is-mac; then
  export LSCOLORS=GxFxHxHxCxHxHxCxCxGxGx
  export CLICOLOR=1
fi

# TODO: use _is-gnu
if _is-linux; then
  # TODO: check if necessary or if CLICOLOR is understood
  alias ls='ls --color=auto'
  export LS_COLORS="di=1;36:ln=1;35:so=0:pi=0:ex=1;32:bd=0:cd=0:su=1;32:sg=1;32:tw=1;36:ow=1;36"
fi

# Make Bash resolve the word after 'sudo' as an alias [1,2], which makes it
# possible to execute aliases with sudo. Note that the replacement is done by
# the shell before invoking sudo and it works only with aliases, not with
# functions (sudo itself works only with executables, it doesn't resolve aliases
# or shell functions, nor does it source .bashrc or .bash_profile). For full
# access to the environment, start an interactive shell with 'sudo -s' which
# in turn sources the .bashrc file found in $HOME.
# [1] https://linuxhandbook.com/run-alias-as-sudo/
# [2] https://www.gnu.org/software/bash/manual/bash.html#Aliases
alias sudo='sudo '
