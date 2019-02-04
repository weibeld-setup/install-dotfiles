if [[ "$OSTYPE" =~ darwin ]]; then

  # ls colors (folders=blue, files=white, executables=green, links=cyan)
  export CLICOLOR=1
  export LSCOLORS=exgxHxHxcxHxHxcxcxexex

  # System
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export EDITOR=vim
  export TERM=xterm-256color-italic # Enable italic text in Apple terminal

  # Java
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home
  export JUNIT_HOME=$JAVA_HOME/lib

  # Go
  export GOPATH=~/Desktop/go
  export go=$GOPATH

  # Misc
  export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  export PYTHONSTARTUP=~/.python

  # PATH
  PATH="$PATH:~/bin"
  PATH="$PATH:/usr/local/sbin"
  PATH="$PATH:$GOPATH/bin"
fi

. ~/.bashrc
