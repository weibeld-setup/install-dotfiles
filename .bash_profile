# ~/.bash_profile: sourced by login shells
#
# Login vs. non-login shells:
#
# - Login shell: created when starting a new terminal window/tab (or tmux
#   window/pane).
#       - Sources: 1) /etc/profile, 2) ~/.bash_profile
# - Non-login shell: created when starting a shell from within a shell.
#       - Sources: 1) ~/.bashrc
#
# Note that a non-login shell does not source ~/.bash_profile, and a login
# shell does not source ~/.bashrc.
#
# ------------
# 
# FAQ:
#
# Q: Why are the functions in ~/.bashrc?
# A: Because we want them also in sub-shells of the current shell, e.g. if we
#    start a new shell by typing "bash". In this case, only ~/.bashrc gets
#    sourced, but not ~/.bash_profile. That means, the functions would not be
#    available in the sub-shell if they were defined in ~/.bash_profile.
#
# Q: But then, why can we set variables in ~/.bash_profile, if ~/.bash_profile
#    does not get sourced in a sub-shell?
# A: Because all variables that we set in ~/.bash_profile are "exported", and 
#    thus automatically available in sub-shells. Thanks to the "exports", there
#    is no need to source ~/.bash_profile in a sub-shell.
#
# Q: Does PATH need to be "exported"?
# A: Yes, but this is already done by /etc/profile, when PATH is set to its
#    default values. There is no need to export PATH at any other place.
#
# Daniel Weibel <daniel@weibeld.net> May 2015 - February 2018
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# If running on macOS system
#------------------------------------------------------------------------------#
if [[ "$OSTYPE" =~ darwin ]]; then

  # ls colors (folders=blue, files=white, executables=green, links=cyan)
  export CLICOLOR=1
  export LSCOLORS=exgxHxHxcxHxHxcxcxexex

  # System
  export d=~/Desktop
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export EDITOR=vim
  export TERM=xterm-256color-italic # Enable italic text in Apple terminal

  # Java
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home
  export JUNIT_HOME=$JAVA_HOME/lib
  export CLASSPATH=.:$JUNIT_HOME/junit-4.10.jar:..

  # Misc
  export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  export GOPATH=~/.go
  export PYTHONSTARTUP=~/.python

  # PATH
  PATH="$PATH:~/bin"
  PATH="$PATH:/usr/local/Cellar/rabbitmq/3.7.3/sbin"

#------------------------------------------------------------------------------#
# If running on Linux system
#------------------------------------------------------------------------------#
elif [[ "$OSTYPE" =~ linux  ]]; then
  PATH="$PATH:~/bin"
fi

#------------------------------------------------------------------------------#
# Source ~/.bashrc
#------------------------------------------------------------------------------#
. ~/.bashrc
