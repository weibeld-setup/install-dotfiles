# Add location to end of PATH if it doesn't yet exist
addpath() { [[ ":$PATH:" =~ ":$1:" ]] || PATH="$PATH:$1";  }
export -f addpath

if [[ "$OSTYPE" =~ darwin ]]; then

  # Default colors (https://gist.github.com/thomd/7667642#lscolors)
  #export LSCOLORS=exgxHxHxcxHxHxcxcxexex
  # Bold colors (may be more readable on some screens)
  export LSCOLORS=ExGxHxHxcxHxHxcxcxExEx
  export CLICOLOR=1

  # System
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export EDITOR=vim
  export TERM=xterm-256color-italic # Enable italic text in Apple terminal

  # Java
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home
  export JUNIT_HOME=$JAVA_HOME/lib

  # Misc
  export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  export PYTHONSTARTUP=~/.python

  # PATH
  addpath "$HOME/bin"
  addpath "/usr/local/sbin"
  addpath "$HOME/.krew/bin"
  addpath "$HOME/.kubectl-plugins"
  addpath "$HOME/.cargo/bin"
  addpath "$HOME/google-cloud-sdk/bin"
  addpath "$(go env GOPATH)/bin"

fi

source ~/.bashrc
