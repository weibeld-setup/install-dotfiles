# ~/.bashrc
# Sourced by non-login shells
# ----
# Login vs. non-login shells:
# - Login shell: when starting a new terminal window/tab (or tmux window/pane)
#       - Sources /etc/profile, ~/.bash_profile
# - Non-login shell: when starting a shell from within a shell
#       - Sources ~/.bashrc
# ----
# FAQ:
#
# Q: Why are the functions in ~/.bashrc and not ~/.bash_profile?
# A: Because we want them also in sub-shells of the current shell. If we start
#    a new shell from within a shell by typing "bash", a non-login shell gets
#    created. Non-login shells source only ~/.bashrc, but not ~/.bash_profile.
#
# Q: Why are variables that we set variables in ~/.bash_profile available in
#    sub-shells, if ~/.bash_profile does not get sourced by non-login shells?
# A: Because all variables set in ~/.bash_profile are "exported". This means
#    that they are automatically available in sub-shells, no matter whether
#    a shell sources ~/.bash_profile or not.
#
# Q: Why is the PATH variable not exported in ~/.bash_profile?
# A: Because in ~/.bash_profile, we don't create this variable, but it already
#    exists and we just modify it. The PATH variable is exported by the script
#    that creates it (e.g. /etc/profile). So, there's no need to re-export
#    PATH in ~/.bash_profile.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Shell options
#------------------------------------------------------------------------------#

shopt -s extglob
shopt -s nullglob

#------------------------------------------------------------------------------#
# Prompt
#------------------------------------------------------------------------------#

PROMPT_COMMAND=__set-prompt
__set-prompt() {
  local EXIT_CODE=$?
  PS1='\[\e[1;32m\]\v:\w$ \[\e[0m\]'
  [[ "$EXIT_CODE" -ne 0 ]] && PS1="\e[1;31m$EXIT_CODE|$PS1"
}

#------------------------------------------------------------------------------#
# bash-completion (installed with Homebrew)
#------------------------------------------------------------------------------#

if [[ "$OSTYPE" =~ darwin ]]; then
  source /usr/local/etc/profile.d/bash_completion.sh
  for f in /usr/local/etc/bash_completion.d/*; do
    source "$f"
  done
fi

#------------------------------------------------------------------------------#
# complete-alias (https://github.com/cykerway/complete-alias)
#------------------------------------------------------------------------------#

source ~/.complete_alias.sh

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

#------------------------------------------------------------------------------#
# Base functions (used by other functions in this file)
#------------------------------------------------------------------------------#

# Is OS Mac or Linux?
is-mac()   { [[ "$OSTYPE" =~ darwin ]]; }
is-linux() { [[ "$OSTYPE" =~ linux  ]]; }

# Is variable set (non-empty) or unset (empty)?
is-set()   { [[ -n "$1" ]]; }
is-unset() { [[ -z "$1" ]]; }

# Does variable contain only whitespace characters?
is-nonblank() { [[ "$1" = *[^[:space:]]* ]]; }
is-blank() { ! is-nonblank "$1"; }

# Test whether an executable is installed, and print error message if it isn't.
ensure() {
  which -s "$1" || { echo "Error: '$1' not installed."; return 1; } 
}

# Capitalise the first letter of a string
capitalize () {
  echo $(echo "${1:0:1}" | tr '[:lower:]' '[:upper:]')"${1:1}"
}

# Convert lower-case to upper-case. Read input from arg list or stdin.
to-upper() { (($# == 0)) && __to-upper || __to-upper <<<"$@"; }
__to-upper() { tr '[:lower:]' '[:upper:]'; }

# Convert upper-case to lower-case. Read input from arg list or stdin.
to-lower() { (($# == 0)) && __to-lower || __to-lower <<<"$@"; }
__to-lower() { tr '[:upper:]' '[:lower:]'; }

# Pad args ($2...) with 0s to number of digits ($1). Read from arg list or stdin.
pad() {
  (($# == 0)) && return 1
  (($# == 1)) && __pad "$1" $(</dev/stdin) || __pad $@
}
__pad() { printf "%0$1s\n" ${@:2}; }

# Insert string ($2) into filename ($1), just before filename extension.
insert() {
  local file=$1; local str=$2
  echo "${file%.*}${str}.${file##*.}"
}

# Source file if exists.
s() { [[ -f "$1" ]] && . "$1"; }

# Create random alphanumeric string (only lower-case) of the specified length.
random() {
  length=${1:-16}
  [[ "$length" =~ ^[1-9][0-9]*$ ]] ||
    { echo "Argument must be positive integer"; return 1; }
  cat /dev/urandom | LC_ALL=C tr -dc a-z0-9 | head -c "$length"
}


#------------------------------------------------------------------------------#
# System management
#------------------------------------------------------------------------------#

alias br='vim ~/.bashrc'
alias bp='vim ~/.bash_profile'
alias sbr='. ~/.bashrc'
alias sbp='. ~/.bash_profile'
alias rmf='rm -rf'
alias la="ls -a"
alias ll="ls -al"
alias wl='wc -l'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias ssh='TERM=xterm-256color ssh'
alias pgrep='pgrep -fl'
alias x='chmod +x'
alias X='chmod -x'

# File sizes
alias dh='du -h'
alias ds='du | sort -k 1 -n -r'
alias dhg='du -h | grep G$"\t"'
alias dhm='du -h | grep M$"\t" | sort -k 1 -n -r'

# Print or remove completion specification of a command
alias comp='complete -p'
alias compr='complete -r'
complete -c comp compr


# Show local ports that are currently in use
ports() {
  lsof -i -P -n | grep LISTEN
}

# Show the help page of a shell builtin like man page
help() { builtin help -m "$1" | less; }
complete -b help 

# Show the source file of a shell function
func() {
  shopt -s extdebug
  declare -F "$1"
  shopt -u extdebug
}
complete -A function func

# Interactively select a command from the history and execute it
hist() {
  ensure fzf || return 1
  eval $(history | fzf -n 2.. -e --no-sort --tac | sed 's/^ *[0-9][0-9]* *//')
}

# Create new directory and cd to it
mkcd() { mkdir "$1" && cd "$1"; }

# Move file by creating any intemediate dirs of the target, if they don't exist
mvp() { mkdir -p "$2" && mv "$1" "$2"; }

# Recursively list all the files in the specified directory.
listf() { local d=${1:-.}; find "${d%/}" -type f; }

# Recursively count the number of files in the specified directory.
countf () { listf "$1" | wc -l; }

# List all the dotfiles or dot-directories in the specified directory.
dotf() { local d=${1:-.}; __dotx "${d%/}" f; }
dotd() { local d=${1:-.}; __dotx "${d%/}" d; }
__dotx() { find "$1" -name '.*' -maxdepth 1 -type "$2" | xargs -Ix basename x; }

# Change the extension of a filename
chext() { echo "${1%.*}.$2"; }

# Print colours of this 256 colour terminal.
# Usage:
#   show-colors [delimiter] [#columns]
colors() {
  delim=${1:- }
  cols=$2
  for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i}${delim}"
    if is-set "$cols" && [[ $((($i + 1) % $cols)) = 0 ]]; then echo; fi
  done
}

# Dump the hexadecimal code of the provided string (output depends on the char
# encoding used by the terminal).
enc() { echo -n "$@" | hexdump | head -1 | cut -d ' ' -f 2-; }

# Print the character encoding used by the terminal
enc-type() { echo $LC_CTYPE; }

# Delete the processes supplied on stdin: one process per line, first white-
# space delimited token must be process ID. Intended to read output from pgrep.
mykill() {
  while read l; do
    pid=$(echo "$l" | awk '{print $1}')
    kill -9 "$pid"
    echo "Killed $pid"
  done
}

alias rmds='find . -type f \( -name .DS_Store -or -name ._.DS_Store \) -delete'


#------------------------------------------------------------------------------#
# Numbers
#------------------------------------------------------------------------------#

log2()  { bc -l <<<"l($1) / l(2)" ; }
log10() { bc -l <<<"l($1) / l(10)"; }

# Round number ($1) to specific number of digits ($2) after decimal point
round() { printf "%.$2f\n" "$1"; }

# Round number down to nearest integer
floor() { bc <<<"$1/1"; }

# Test if number is even or odd
even() { (($1 % 2 == 0)); }
odd()  { (($1 % 2 != 0)); }

# Convert numbers between numeral systems. Input read from stdin or arg list.
d2b() { __x2x 10  2 0    "$@"; }
d2o() { __x2x 10  8 0    "$@"; }
d2h() { __x2x 10 16 0    "$@"; }
b2d() { __x2x  2 10 0    "$@"; }
o2d() { __x2x  8 10 0    "$@"; }
h2d() { __x2x 16 10 0    "$@"; }
h2b() { __x2x 16  2 4    "$@"; }
h2o() { __x2x 16  8 0    "$@"; }
b2h() { __x2x  2 16 0.25 "$@"; }
o2h() { __x2x  8 16 0    "$@"; }
b2o() { __x2x  2  8 0.33 "$@"; }
o2b() { __x2x  8  2 3    "$@"; }
# Read input from stdin or arg list
__x2x() {
  (($# == 3)) && ____x2x "$@" $(</dev/stdin) || ____x2x "$@"
}
# Convert numbers and zero-pad based on number of digits and value of arg 3
____x2x() {
  local tok
  for tok in $(to-upper ${@:4}); do
    bc <<< "obase=$2; ibase=$1; $tok" | pad $(bc <<<"(${#tok}*$3)/1")
  done
}

# Print a number in hex, dec, oct bin. Input format: 0xA, 10, 012, 0b1010
n() {
  local PAT_HEX='^0x([0-9a-fA-F]+)$'
  local PAT_BIN='^0b([01]+)$'
  local PAT_OCT='^0([0-7]+)$'
  local PAT_DEC='^([1-9][0-9]*)$'
  local PAT_0='^(0)$'
  local n
  # Convert to decimal
  if   [[ $1 =~ $PAT_HEX ]]; then n=$(hex2dec ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_BIN ]]; then n=$(bin2dec ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_OCT ]]; then n=$(oct2dec ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_DEC || $1 =~ $PAT_0 ]]; then n=${BASH_REMATCH[1]}
  else
    echo "Invalid number: $1" && return 1
  fi
  # Convert from decimal to other systems
  echo "Hexadecimal: $(dec2hex $n)"
  echo "Decimal: $n"
  echo "Octal: $(dec2oct $n)"
  echo "Binary: $(dec2bin $n)"
}

#------------------------------------------------------------------------------#
# Documents
#------------------------------------------------------------------------------#

# Merge PDF files with pdftk. Requires pdftk.
pdf-merge() {
  ensure pdftk || return 1
  pdftk "$@" cat output mymerged.pdf
}

# Extract the table of contents from a PDF file
pdf-toc() {
  ensure mutool || return 1
  local tab=$(printf '\t')
  # Extract TOC and delete page numbers separated from section titles by a tab
  mutool show "$1" outline | sed -E "s/${tab}[0-9]+\$//"
}

# Scale PDF files, i.e. shrink or enlarge them by maintaining the aspect ratio.
# Requires pdfScale.sh (https://github.com/tavinus/pdfScale).
# Usage: scale-pdf RATIO FILE...
pdf-scale() {
  local factor=$1
  shift
  # Output directory
  local dir="SCALED_$factor"
  mkdir -p "$dir"
  for f in "$@"; do
    # Original width and height of the PDF file in pts
    local tmp=$(pdfScale.sh -i "$f" | grep Points | cut -d '|' -f 2)
    local w=$(echo "$tmp" | cut -d x -f 1 | xargs)
    local h=$(echo "$tmp" | cut -d x -f 2 | xargs)
    # Target width and height
    local scaled_w=$(bc <<<"$factor * $w")
    local scaled_w=$(printf %.f $scaled_w)
    local scaled_h=$(bc <<<"$factor * $h")
    local scaled_h=$(printf %.f $scaled_h)
    # Scale
    echo "$f: ${w}x${h} pts ==> ${scaled_w}x${scaled_h} pts"
    pdfScale.sh -r "custom pt $(printf %.f $scaled_w) $(printf %.f $scaled_h)" "$f" "$dir/$(basename $f)"
  done
}

# Convert an audio file to the MP3 format. Requires ffmpeg.
to-mp3() {
  ensure ffmpeg || return 1
  ffmpeg -i "$1" -acodec libmp3lame "${1/.*/.mp3}"
}

#------------------------------------------------------------------------------#
# ImageMagick
#------------------------------------------------------------------------------#

# Get the size of an image in pixels
img-size() {
  ensure identify || return 1
  identify "$1"
}

# Crop an image to a specific size, optionally defining the upper left corner.
img-crop() {
  ensure convert || return 1
  if [[ $# -lt 3 ]]; then
    echo -e "${FUNCNAME[0]} file width height [top-offset] [left-offset] [out-file]"
    return
  fi
  file=$1
  w=$2
  h=$3
  x=${4:-0}
  y=${5:-0}
  out=${6:-$(insert "$file" "_cropped${w}x${h}")}
  convert -crop "${w}x${h}+${x}+${y}" "$file" "$out"
  echo "$out"
}

# Resize image. Usage: img-resize <file> <format> [<out_file>].
img-resize() {
  ensure convert || return 1
  local file=$1; local format=$2  # Format "50%" or "512x512"
  out_file=${3:-$(insert "$file" _resized)}
  convert "$file" -resize "$format" "$out_file"
}

# Read date a photo was taken from the photo's EXIF data.
img-date() {
  ensure identify || return 1
  identify -format %[exif:DateTimeOriginal] "$1"
}


#------------------------------------------------------------------------------#
# Git
#------------------------------------------------------------------------------#

alias gl='git log --decorate --graph' 
alias gr='git remote -v'
alias gs='git status -u'
alias ga='git add -A'
alias gc='git commit'
alias gp='git push'
alias gf="git flow"


#------------------------------------------------------------------------------#
# Docker
#------------------------------------------------------------------------------#

alias dk=docker
alias dki='docker images'
alias dkc='docker ps -a'

# Remove ALL images
dkri() {
  local i=$(docker images -q)
  is-set "$i" && docker rmi -f $i || echo "No images"
}

# Remove only those images with a <none> name or tag
dkci() {
  local i=$(docker images | grep '<none>' | awk '{print $3}')
  is-set "$i" && docker rmi $i || echo "No unnamed/untagged images"
}

# Remove all containers
dkrc() {
  local c=$(docker ps -aq)
  is-set "$c" && docker rm $c || echo "No containers"
}

# Stop all running containers
dksc() {
  local c=$(docker ps -q)
  is-set "$c" && docker stop $c || echo "No running containers"
}



#------------------------------------------------------------------------------#
# AWS CLI
#------------------------------------------------------------------------------#

alias cfn="aws cloudformation"

# List all CloudFormation export values in the default region
cfn-exports() {
  aws cloudformation list-exports --output json --query 'Exports[*].Name'
  #aws cloudformation list-exports --output json | jq -r '.Exports|.[]|.Name'
}

# Validate a template
cfn-validate() {
  aws cloudformation validate-template --template-body "$(cat  $1)"
}

# SAM package
smp() {
  sam package --template-file template.yml --output-template-file package.yml --s3-bucket quantumsense-sam
}

# SAM deploy
smd() {
  [[ -z "$1" ]] && { echo "Usage: smd STACK_NAME"; return 1; }
  sam deploy --template-file package.yml --capabilities CAPABILITY_IAM --stack-name "$1"
}
# SAM package and deploy
sm() {
  [[ -z "$1" ]] && { echo "Usage: smd STACK_NAME"; return 1; }
  smp && smd "$1"
}

#------------------------------------------------------------------------------#
# Kubernetes
#------------------------------------------------------------------------------#

# Get current context, list contexts, change current context
alias ksc='kubectl config current-context'
alias klc='kubectl config get-contexts -o name | sed "s/^/  /;\|$(ksc)|s/ /*/"'
alias kcc='kubectl config use-context "$(klc | fzf -e | sed "s/^..//")"'

# Get namespace (ns) of current context, list ns, change ns of current context
alias ksn='kubectl config get-contexts --no-headers "$(ksc)" | awk "{print \$5}" | sed "s/^$/default/"'
alias kln='kubectl get -o name ns | sed "s|^.*/|  |;\|$(ksn)|s/ /*/"'
alias kcn='kubectl config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'

# Delete a context, cluster, and user from the default kubeconfig file. It is
# asumed that context, cluster, and user that belong together identical names.
# If "error: open ~/.kube/config.lock: file exists", unset KUBECONFIG variable.
kc-delete() {
  local name=$1
  kubectl config delete-context "$name" &&
  kubectl config delete-cluster "$name" &&
  kubectl config unset users."$name"
}


# https://github.com/kubermatic/fubectl
#[ -f ~/.fubectl ] && source ~/.fubectl

# Display the container images of each pod in the current namespace
alias kpi='kubectl get pods -o custom-columns="POD:.metadata.name,IMAGES:.spec.containers[*].image"'
# Display the container images of each pod in a specific namespace 
alias kpin='kubectl get pods -o custom-columns="POD:.metadata.name,IMAGES:.spec.containers[*].image" -n $(_list-ns | _mark $(_current-ns) | fzf | _unmark)'
# Display the container images of each pod across all namespaces
alias kpia='kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name,IMAGES:.spec.containers[*].image"'

# Display the node of each pod in the current namespace
alias kpn='kubectl get pods -o custom-columns=POD:.metadata.name,NODE:.spec.nodeName'
# Display the node of each pod in a specific namespace
alias kpnn='kubectl get pods -o custom-columns=POD:.metadata.name,NODE:.spec.nodeName -n $(_list-ns | _mark $(_current-ns) | fzf | _unmark)'
# Display the node of each pod across all namespaces
alias kpna='kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,NODE:.spec.nodeName'

# kubectl-aliases (https://github.com/ahmetb/kubectl-aliases)
if [[ -f ~/.kubectl_aliases ]]; then
  source ~/.kubectl_aliases
  # Enable completion for aliases (depends on complete-alias)
  for _a in $(sed '/^alias /!d;s/^alias //;s/=.*$//' ~/.kubectl_aliases); do
    complete -F _complete_alias "$_a"
  done
fi

#------------------------------------------------------------------------------#
# Mac and Linux specific functions
#------------------------------------------------------------------------------#
if is-mac; then

  # Make Finder hiding hidden files, e.g. dotfiles (default)
  finder_hide() {
    defaults write com.apple.finder AppleShowAllFiles FALSE
    killall Finder
  }

  # Make Finder displaying hidden files
  finder_show() {
    defaults write com.apple.finder AppleShowAllFiles TRUE
    killall Finder
  }

  # Permanently disable the Mac startup sound
  disable_startup_sound() {
    sudo nvram SystemAudioVolume=%80  # %80 = 0x80 (hex) = 128 (dec)
  }

  # Permanently re-enable the Mac startup sound
  enable_startup_sound() {
    sudo nvram -d SystemAudioVolume
  }

  # Get the bundle ID (e.g. com.apple.Preview) of an application
  app-id() {
    local app_name=$1
    osascript -e "id of app \"$app_name\""
  }

  # Convert a date string in a specific format to a UNIX timestamp in seconds.
  # If the date string doesn't include a time, the current time is assumed.
  #   Usage:   date2ts <date> <date_format>
  #   Example: date2ts "2016-02-02 13:21:45" "%Y-%m-%d %H:%M:%S"
  date2ts() {
    date -j -f "$2" "$1" '+%s'
    # Note: -j: disable setting of system date, -f: format of input date
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optinally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  #   Usage: ts2date <timestamp> [<out_format>]
  ts2date() {
    if is_set "$2"; then date -r "$1" "$2"
    else                 date -r "$1"
    fi
  }

elif is-linux; then
  # Customise keyboard layout with setxkbmap:
  #   - Add Swiss German keyboard layout
  #   - Swap Caps-Lock and Ctrl keys
  #   - Set key combination for toggling between keyboard layouts
  # All the options and keyboard layouts of setxkbmap can be found in the file
  # ==> /usr/share/X11/xkb/rules/base.lst
  # Notes:
  # - The settings made by setxkbmap do NOT persists across logins
  # - To make the settigns persistent, one option would be to put the setxkbmap
  #   commands directly into ~/.bashrc. However, this may cause an X error
  #   (cannot open display "default display")
  # - Another option would be to put the setxkbmap commands into ~/.xinitrc or
  #   /etc/X11/xorg.conf.d/00-keyboard.conf (different syntax). However, there
  #   are inconsistencies across systems, and different desktop environments
  #   read these files in different ways
  # - Because of the above problems, the setxkbmap commands are provided here
  #   as a function that can be called manually
  # Source: https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
  #         http://betabug.ch/blogs/ch-athens/1242
  config_keyboard() {
    if $(which setxkbmap); then
      # Set Swiss German and German as keyboard layouts (ch(de) is default)
      setxkbmap 'ch(de),de'
      # Left Alt-Shift for toggling between keyboard layouts
      setxkbmap -option grp:lalt_lshift_toggle
      # Swap Caps-Lock and Ctrl keys
      setxkbmap -option ctrl:swapcaps
    else
      echo "Error: setxkbmap is not installed."
    fi
  }

  # Convert a date string to a UNIX timestamp in seconds. The date string format
  # is the one described in the 'date' man page as '--date=STRING'.
  #   Usage: date2ts <date>
  date2ts() {
    date -d "$1" '+%s'
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optionally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  #   Usage: ts2date <timestamp> [<out_format>]
  ts2date() {
    if is_set "$2"; then date -d "@$1" "$2"
    else                 date -d "@$1"
    fi
  }

  # Check if the dependencies of a Debian package are installed
  checkdep() {
    dep=($(apt-cache depends "$1" | grep Depends: | cut -d : -f 2))
    for d in "${dep[@]}"; do
      echo -n "$d: "
     if dpkg -s "$d" 2>/dev/null | grep -q "Status: .* installed"; then
        echo installed
      else
        echo "NOT INSTALLED"
      fi
    done
  }
fi

#------------------------------------------------------------------------------#
# Misc
#------------------------------------------------------------------------------#

alias asciicast2gif='docker run --rm -v "$PWD":/data asciinema/asciicast2gif'

#------------------------------------------------------------------------------#
# Ensure exit code 0 for the command that sources this file
#------------------------------------------------------------------------------#

return 0
