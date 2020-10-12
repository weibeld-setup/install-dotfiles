# Append/prepend an entry to the PATH if it doesn't exist yet
path_append()  { [[ ":$PATH:" =~ ":$1:" ]] || PATH="$PATH:$1"; }
path_prepend() { [[ ":$PATH:" =~ ":$1:" ]] || PATH="$1:$PATH"; }
export -f path_append
export -f path_prepend

if [[ "$OSTYPE" =~ darwin ]]; then

  # Default colors (https://gist.github.com/thomd/7667642#lscolors)
  #export LSCOLORS=exgxHxHxcxHxHxcxcxexex
  # Directories cyan, symlinks blue (may be more readable on some screens)
  export LSCOLORS=GxExHxHxcxHxHxcxcxGxGx
  export CLICOLOR=1

  # System
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export EDITOR=vim
  export TERM=xterm-256color-italic # Enable italic text in Apple terminal

  # Java
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-10.0.2.jdk/Contents/Home
  export JUNIT_HOME=$JAVA_HOME/lib

  # Misc
  export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  export PYTHONSTARTUP=~/.python
  export d=~/Desktop

  # PATH
  path_append "$HOME/bin"
  path_append "/usr/local/sbin"
  path_append "$HOME/.krew/bin"
  path_append "$HOME/.kubectl-plugins"
  path_append "$HOME/.cargo/bin"
  path_append "$HOME/google-cloud-sdk/bin"
  path_append "$(go env GOPATH)/bin"
  path_prepend /usr/local/opt/ruby/bin
  path_prepend /usr/local/lib/ruby/gems/2.6.0/bin

fi

source ~/.bashrc
