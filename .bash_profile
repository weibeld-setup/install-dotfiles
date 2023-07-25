# Append/prepend an entry to the PATH if it doesn't exist yet
path_append()  { [[ ":$PATH:" =~ ":$1:" ]] || PATH="$PATH:$1"; }
path_prepend() { [[ ":$PATH:" =~ ":$1:" ]] || PATH="$1:$PATH"; }
export -f path_append
export -f path_prepend


if [[ "$OSTYPE" =~ linux ]]; then
  export LS_COLORS="di=1;31:ln=36:so=31:pi=5:ex=32:bd=37;44:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;42"
elif [[ "$OSTYPE" =~ darwin ]]; then

  # See LSCOLORS documentation in 'man ls' (LSCOLORS is BSD-specific)
  # Colours: a=black, b=red, c=green, d=yellow, e=blue, f=magenta, g=cyan,
  #   h=white, x=default (use upper-case letters for bold)
  # Positions: 1=dir, 2=symlink, 3=socket, 4=pipe, 5=exec, 6=block special,
  #   7=char special, 8=exec w. setuid, 9=exec wo. setgid, 10=dir w. sticky bit,
  #   11=dir wo. sticky bit
  # Format: [foreground][background]... (e.g. Gx)
  export LSCOLORS=GxFxHxHxCxHxHxCxCxGxGx
  export CLICOLOR=1

  # System
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export EDITOR=vim
  export TERM=xterm-256color # Works across multiple macOS systems and terminals
  # Increase history size (default 500)
  export HISTSIZE=5000
  export HISTFILESIZE=5000

  # Homebrew
  # Correct prefix depends on chip architecture (Intel or Apple).
  # See https://docs.brew.sh/FAQ#why-should-i-install-homebrew-in-the-default-location
  eval $(/opt/homebrew/bin/brew shellenv)
  #eval $(/usr/local/bin/brew shellenv)
  export HOMEBREW_NO_AUTO_UPDATE=1

  # Java
  #export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.0.3.jdk/Contents/Home
  #export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
  #export JUNIT_HOME=$JAVA_HOME/lib
  #export GROOVY_HOME=/usr/local/opt/groovy/libexec

  # Misc
  export d=~/Desktop
  #export tex_home=/usr/local/texlive
  export fonts_user=~/Library/Fonts
  export fonts_local=/Library/Fonts
  export fonts_system=/System/Library/Fonts
  #export PYTHONSTARTUP=~/.python
  #export GOPATH=$HOME/go
  #alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

  # PATH
  #path_append "$HOME/bin"
  #path_append "/usr/local/sbin"
  #path_append "$HOME/.krew/bin"
  #path_append "$HOME/.kubectl-plugins"
  #path_append "$HOME/google-cloud-sdk/bin"
  #path_append "$HOME/platform-tools"
  #path_append "$(go env GOPATH)/bin"
  #path_prepend /usr/local/opt/ruby/bin
  #path_prepend /usr/local/lib/ruby/gems/2.6.0/bin
  # GNU Make
  #path_prepend /usr/local/opt/make/libexec/gnubin
  # Homebrew version of curl
  #path_prepend /usr/local/opt/curl/bin
  # sketchtool
  #path_append /Applications/Sketch.app/Contents/MacOS
  # Added by serverless binary installer
  #export PATH="$HOME/.serverless/bin:$PATH"

  # Command completion
  #complete -C /usr/local/bin/packer packer

fi

. ~/.bashrc
