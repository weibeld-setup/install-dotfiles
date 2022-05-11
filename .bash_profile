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
  export TERM=xterm-256color # Works across multiple macOS systems and terminals
  # Increase history size (default 500)
  export HISTSIZE=5000
  export HISTFILESIZE=5000

  # Java
  #export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.3.jdk/Contents/Home
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
  export JUNIT_HOME=$JAVA_HOME/lib
  export GROOVY_HOME=/usr/local/opt/groovy/libexec

  # Misc
  export d=~/Desktop
  export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  export PYTHONSTARTUP=~/.python
  export GOPATH=$HOME/go
  export HOMEBREW_NO_AUTO_UPDATE=1

  # PATH
  path_append "$HOME/bin"
  path_append "/usr/local/sbin"
  path_append "$HOME/.krew/bin"
  path_append "$HOME/.kubectl-plugins"
  path_append "$HOME/google-cloud-sdk/bin"
  path_append "$HOME/platform-tools"
  path_append "$(go env GOPATH)/bin"
  path_prepend /usr/local/opt/ruby/bin
  path_prepend /usr/local/lib/ruby/gems/2.6.0/bin
  # GNU Make
  path_prepend /usr/local/opt/make/libexec/gnubin
  # Homebrew version of curl
  path_prepend /usr/local/opt/curl/bin
  # sketchtool
  path_append /Applications/Sketch.app/Contents/MacOS
  # Added by serverless binary installer
  export PATH="$HOME/.serverless/bin:$PATH"

  # Command completion
  complete -C /usr/local/bin/packer packer

fi

. ~/.bashrc
