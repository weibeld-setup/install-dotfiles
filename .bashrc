# ~/.bashrc
# Default location for configuration code, except for the following two cases:
#   1. Library functions (general-purpose functions intended to be used by
#      other functions) are in separate files ~/.bashrc.lib/*
#   2. Topic-specific configuration that is not general purpose and might only
#      be used temporarily is in separates files in ~/.bashrc.topic/*
#==============================================================================#

#==============================================================================#
## Mandatory shell options
#
# Notes:
#   - These shell options must be mandatorily set because the library functions
#     in ~/.bashrc.lib rely on them
#   - The 'set' [1] and 'shopt' [2] commands are both shell builtins:
#     - 'set' originates from sh, is POSIX-compatible, and does various things
#       like setting shell options, setting and displaying variables, and
#       setting positional parameters
#     - 'shopt' is Bash-specific and is used exclusively for setting shell
#       options [3].
# References:
#   [1] https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
#   [2] https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin
#   [3] https://unix.stackexchange.com/a/305256/317243
#==============================================================================#

# Enable extended glob patterns (e.g. '!(...)', etc.)
shopt -s extglob
# If a glob has no matches, expand to empty string rather than glob text
shopt -s nullglob
# Last failing command in a pipe determines exit code of pipe
set -o pipefail

#==============================================================================#
## Standard library
#==============================================================================#

for f in ~/.bashrc.lib/*.bash; do
  . "$f"
done
unset f

#==============================================================================#
## Shell setup
#==============================================================================#

# Make filename completion expand directory names (e.g. variables)
shopt -s direxpand

# Set locale
# Note: see all available locales with 'locale -a'
export LC_ALL=en_GB.UTF-8

# Works with tmux (xterm-256color-italic may cause tmux to fail)
export TERM=xterm-256color
export EDITOR=vim

# Readline configuration
# https://www.gnu.org/software/bash/manual/html_node/Command-Line-Editing.html
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

#==============================================================================#
## Dotfiles
#==============================================================================#

alias df='git --git-dir "$HOME"/.dotfiles.git --work-tree "$HOME"'
alias dfs='df status'
alias dfl='df log'
alias dfa='df add'
alias dfr='df rm'
alias dfc='df commit'
alias dfp='df push'
alias dfd='df diff'

#==============================================================================#
## Miscellaneous functions
#==============================================================================#

# List all the types of a command.
# Usage:
#   whatis [-s] <cmd>
# Lists all the types (function, alias, file, or builtin) for <cmd> in order
# of precedence. For files, functions, and aliases, the source file is also
# listed. For functions and aliases, the line number of the definition is
# additionally appended to the filename. With -s, only the highest precedence
# type (i.e. the one taking effect) is listed.
# Notes:
#   - This function is similar to 'type -a', however, it does NOT list function
#     and alias bodies (use 'doc' for this), but in turn it lists file names
#     and line numbers for functions and aliases.
#   - Alias definitions are parsed from the .bashrc.* files (see '_get-bashrc').
#     In order to be parsed correctly, alias definitions must only have white-
#     space between the 'alias' keyword and the beginning of the line.
whatis() {
  if [[ "$#" -eq 1 ]]; then
    local cmd=$1
  elif [[ "$#" -eq 2 && "$1" = -s ]]; then
    local short=1 cmd=$2
  else
    _print-usage-msg "[-s] <cmd>" >/dev/stderr
    return 1
  fi
  local types=$(type -ta "$cmd")
  if _is-set "$short"; then
    types=$(echo "$types" | head -n 1)
  fi
  local file_i
  echo "$types" | while read t; do
    case "$t" in
      function)
        # Returns only latest definition if there are multiple ones
        { shopt -s extdebug; local res=$(declare -F "$cmd"); shopt -u extdebug; }
        local file=$(echo "$res" | cut -d ' ' -f 3-)
        local line=$(echo "$res" | cut -d ' ' -f 2)
        __whatis-print function "$([[ "$file" =~ ^/ ]] && echo "$file:$line")"
        ;;
      alias)
        # TODO: compare all matches against output of 'type' in order to determine
        # the latest alias definition (does not rely on the order of the files in _get-bashrc)
        __whatis-print alias "$(grep -nE "^[ ]*alias[ ]+$cmd=" $(_list-bashrc) /dev/null | tail -n 1 | cut -d : -f 1-2)"
        ;;
      file)
        ((file_i++))
        __whatis-print file "$(which -a "$cmd" | sed -n "${file_i}p")"
        ;;
      builtin)
        __whatis-print builtin
        ;;
    esac
  done
}
complete -c whatis

__whatis-print() {
  echo "$1,${2:-null}"
}

# Shorthand wrapper for _type.
# TODO: rename to 'inspect()'
t() {
  _type "$@"
}
complete -c t

# Print documentation for a function or alias.
# Usage:
#   doc <name> [-a]
# If <name> is a function or alias defined in a .bashrc.* file, print the
# documentation and body of this function or alias definition. By default,
# function bodies are truncated after 10 lines, however, this can be changed
# with the -a option, which causes the entire function body to be printed.
# Notes:
#   - In order for the documentation to be recognised, the corresponding
#     comment lines must be adjacent to the function or alias definition
#     without any empty lines between them.
doc() {
  local name=$1
  local all=$2
  local result=$(_type -s "$name")
  local type=$(echo "$result" | cut -d , -f 1)
  local location=$(echo "$result" | cut -d , -f 2)
  if [[ ! "$type" =~ function|alias || -z "$location" || "$location" = null ]]; then
    return
  fi
  echo -e "$location"
  local file=$(echo "$location" | cut -d : -f 1)
  local line_nr=$(echo "$location" | cut -d : -f 2)
  _cond-sgr cyan bold
  # Print comment block from line_nr-1 backwards
  tac "$file" | awk -v start_line_nr="$(($(wc -l <"$file")-line_nr+2))" '
    BEGIN {
      while ((getline line) > 0) {
        if (NR >= start_line_nr) {
          if (line ~ /^[ ]*#/) {
            gsub(/^[ ]*/, "", line)
            print line
          }
          else {
            break
          }
        }
      }
    }' | tac
  _cond-sgr reset yellow
  if [[ "$type" = function ]]; then
    local max_lines=10
    local body=$(type "$name" | tail -n +2)
    if [[ -n "$all" ]]; then
      echo "$body"
    else
      echo "$body" | head -n "$max_lines"
      if [[ $(echo "$body" | wc -l) -gt  "$max_lines" ]]; then
        _cond-sgr
        echo  "[...]"
      fi
    fi
  elif [[ "$type" = alias ]]; then
    command -v "$name"
  fi
  _cond-sgr
}
complete -c doc

#==============================================================================#
## File system operations
#==============================================================================#

alias rmf='rm -rf'
alias la="ls -a"
alias ll="ls -al"
alias x='chmod +x'
alias X='chmod -x'
alias dh='du -h'
alias which='which -a'
alias diff='diff --color'

if _is-mac; then
  export d=~/Desktop
  # LSCOLORS (BSD-specific)
  # Positions:
  #   1=dir, 2=symlink, 3=socket, 4=pipe, 5=executable, 6=block special,
  #   7=char special, 8=executable with setuid, 9=executable with setgid,
  #   10=other-writable dir w. sticky bit, 11=other-writable dir wo. sticky bit
  # Colours (lower-case means normal, upper-case means bold):
  #   a=black, b=red, c=green, d=yellow, e=blue, f=magenta, g=cyan, h=white,
  #   x=default
  # Format:
  #   <foreground><background>...
  # Example:
  #   Gx: bold cyan foreground and default background
  # Documentation:
  #   man ls (search for 'LSCOLORS')
  export LSCOLORS=GxFxHxHxCxHxHxCxCxGxGx
  export CLICOLOR=1
elif _is-linux; then
  alias ls='ls --color=auto'
  # LS_COLORS (GNU-specific)
  # Fields:
  #   di=dir, ln=symlink, so=socket, pi=pipe, ex=executable, bd=block special,
  #   cd=char special, su=executble with setuid, sg=executable with setgid,
  #   tw=other-writable dir w. sticky bit, ow=other-writable dir wo. sticky bit
  # Colours:
  #   ANSI colour codes
  # Documentation:
  #   'man ls', 'man dircolors', 'dircolors'
  export LS_COLORS="di=1;36:ln=1;35:so=0:pi=0:ex=1;32:bd=0:cd=0:su=1;32:sg=1;32:tw=1;36:ow=1;36"
fi

# Create new directory and navigate into it
mkcd() {
  mkdir "$1" && cd "$1"
}

# Change <n> levels up in the directory hierarchy
cdu() {
  local n=${1:-1}
  for i in $(seq "$n"); do
    cd ..
  done
}

# Change into the directory of the file pointed to by a symlink
cdl() {
  local t=$(readlink "$1")
  cd $([[ -f "$t" ]] && echo $(dirname "$t") || echo "$t")
}
complete -f cdl

# List all the dotfiles or dot-directories in the specified directory.
dotfiles() {
  local d=${1:-.}
  __dotx "${d%/}" f
}
dotdirs() {
  local d=${1:-.}
  __dotx "${d%/}" d
}
__dotx() {
  find "$1" -name '.*' -maxdepth 1 -type "$2" |
  grep -v '^\.$' |
  xargs -Ix basename x |
  sort --ignore-case
}

if _is-mac; then
  # Recursively delete all .DS_Store files in the specified directory
  rmds() {
    sudo find "${1:-.}" -type f \( -name .DS_Store -or -name ._.DS_Store \) -print -delete 2>/dev/null
    return 0
  }

  # Move one or more files or directories to the trash
  trash() {
    for i in "$@"; do
      # mv fails if target directory already exists
      if ! mv "$i" ~/.Trash &>/dev/null; then
        rm -rf ~/.Trash/"$i"
        mv "$i" ~/.Trash
      fi
    done
  }
fi

# Recursively find GB or MB sized directories under the specified directory.
find-gb-dirs() { __find-x-dirs g "${1:-.}"; }
find-mb-dirs() { __find-x-dirs m "${1:-.}"; }
__find-x-dirs() {
  case "$1" in
    g) local pattern="G$(printf "\t")" ;;
    m) local pattern="M$(printf "\t")\|G$(printf "\t")" ;;
  esac
  sudo du -h "$2" 2>/dev/null | grep "$pattern"
  return 0
}

#==============================================================================#
## Miscellaneous tools and settings
#==============================================================================#

alias curl='curl -s'
alias ssh='TERM=xterm-256color ssh'
alias pgrep='pgrep -fl'
alias watch='watch -n 1'

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

# Print operating system name and version
os() {
  if _is-mac; then
    echo "$(sw_vers -productName)-$(sw_vers -productVersion)"
  elif _is-linux; then
    if [[ -f /etc/os-release ]]; then
      (. /etc/os-release; echo "$ID-$VERSION_ID"; )
    else
      echo unknown
    fi
  fi
}

# Copy file or stdin to system clipboard
# Usage:
#   clip [file]
# If a file is provided, its content is copied to the clipboard. If no file is
# provided, then stdin is copied to the clipboard.
clip() {
  local cmd
  _is-mac && cmd=pbcopy
  _is-linux && cmd=xclip
  _is-wsl && cmd=clip.exe
  if [[ "$#" -eq 0 ]]; then
    eval "$cmd"
  else
    cat "$1" | eval "$cmd"
  fi
}

#==============================================================================#
## Command completion
#==============================================================================#

# bash-completion (https://github.com/scop/bash-completion)
# Use Homebrew bash-completion
if _is-mac && _is-cmd brew ; then
  source $(brew --prefix)/etc/profile.d/bash_completion.sh
  for f in $(brew --prefix)/etc/bash_completion.d/*; do
    source "$f"
  done
# Only execute if bash-completion isn't activated yet
elif _is-linux && ! type _init_completion &>/dev/null; then
  # Code from /etc/bash.bashrc which by default is outcommented
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

# complete-alias (https://github.com/cykerway/complete-alias)
source ~/.complete_alias

#==============================================================================#
## Terminal colours
#==============================================================================#

# Print the 8 base colours of this terminal (black, red, green, yellow, blue,
# magenta, cyan, white) in normal, bright, and bold variations.
# Usage:
#   c8 [c]...
# Args:
#   c: ANSI colour code for one of the 8 base colours and their bright versions.
#      Possible values are: 30-37 (normal colours) and 90-97 (bright versions).
# Note:
#   If no arguments are given, all colours are printed.
c8() {
  local c=(${@:-30 90 31 91 32 92 33 93 34 94 35 95 36 96 37 97})
  _array-has "${c[@]}" 30 && printf "\e[47;30mBlack (30):\e[49m          \e[040m   \e[49m  \e[47mNormal\e[49m  \e[47;1mBold\e[0m\n"
  _array-has "${c[@]}" 90 && printf "\e[90mBright black (90):   \e[100m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 31 && printf "\e[31mRed (31):            \e[041m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 91 && printf "\e[91mBright red (91):     \e[101m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 32 && printf "\e[32mGreen (32):          \e[042m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 92 && printf "\e[92mBright green (92):   \e[102m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 33 && printf "\e[33mYellow (33):         \e[043m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 93 && printf "\e[93mBright yellow (93):  \e[103m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 34 && printf "\e[34mBlue (34):           \e[044m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 94 && printf "\e[94mBright blue (94):    \e[104m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 35 && printf "\e[35mMagenta (35):        \e[045m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 95 && printf "\e[95mBright magenta (95): \e[105m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 36 && printf "\e[36mCyan (36):           \e[046m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 96 && printf "\e[96mBright cyan (96):    \e[106m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 37 && printf "\e[37mWhite (37):          \e[047m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has "${c[@]}" 97 && printf "\e[97mBright white (97):   \e[107m   \e[49m  Normal  \e[1mBold\e[0m\n"
  return 0
}

# Print all 256 colours if this is a 256-colour terminal.
# Usage:
#   c256 [columns] [string]
# Args:
#   columns: number of columns in the output (default: 6)
#   string:  string to print for each colour (default: "colour-")
# Example:
#  c256 6 ABCDEF
c256() {
  local n=$(tput colors)
  if [[ "$n" != 256 ]]; then
    echo "Not a 256 colour terminal (only $n colours)"
    return 1
  fi
  local columns=${1:-6}
  local string=${2:-colour-}
  for i in {0..255} ; do
    printf "\e[38;5;${i}m${string}$(_pad-left 3 0 "$i") "
    [[ $((($i + 1) % $columns)) = 0 && "$i" -lt 255 ]] && echo
  done
  printf "\e[0m\n"
}

#==============================================================================#
## Package management
#==============================================================================#

if _is-linux; then
  # Check if the dependencies of a Debian package are installed
  checkdep() {
    local dep=($(apt-cache depends "$1" | grep Depends: | cut -d : -f 2))
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


# TODO: create module in ~/.bashrc.mod
#==============================================================================#
## Git
#==============================================================================#

alias gl='git log --decorate --graph' 
alias gr='git remote -v'
alias gs='git status -u'
alias ga='git add -A'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push -f'
alias gb="git branch"
alias gd="git diff"
alias gpu="git pull"

# Use Grip with a GitHub personal access token (PAT) to avoid the rate limit
# https://github.com/joeyespo/grip
alias grip='grip --user weibeld --pass $(cat ~/.config/grip/personal-access-token)'

#==============================================================================#
## Text processing
#==============================================================================#

alias sed='sed -E'
alias gsed='gsed -E'
alias wl='wc -l'
if _is-linux; then
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Create a random string in one of different formats.
# Usage:
#   rand [r|R|a|A|h|H|n] [<length>]
# Args:
#   format: r|R: alphanumeric with all lower-case (r) or all upper-case (R)
#           a|A: alphabetic with all lower-case (a) or all upper-case (A)
#           h|H: hexadecimal with all lower-case (h) or all upper-case (H)
#           n:   numeric
#           Default is 'r'
#   length: positive integer (default is 8)
rand() {
  local format=r
  local upper
  if [[ "$1" =~ r|R|h|H|a|A|n ]]; then
    format=$(_to-lower-case "$1")
    upper=$([[ "$1" =~ [[:upper:]] ]] && echo 1)
    shift
  fi
  local length=${1:-8}
  if [[ ! "$length" =~ [0-9]+ ]]; then
    _err "Length must be a number but found '$length'"
    return 1
  fi
  local str
  case "$format" in
    r) str=$(cat /dev/urandom | LC_ALL=C tr -dc a-z0-9 | head -c "$length") ;;
    a) str=$(cat /dev/urandom | LC_ALL=C tr -dc a-z | head -c "$length") ;;
    n) str=$(cat /dev/urandom | LC_ALL=C tr -dc 0-9 | head -c "$length") ;;
    h) str=$(cat /dev/urandom | hexdump -e '"%x"' | head -c "$length" ) ;;
  esac
  if _is-set "$upper"; then
    _to-upper-case "$str"
  else
    echo "$str"
  fi
}

# Get the Unicode code point of a single character
# Source: https://superuser.com/a/1019853
unicode() {
  local char=$(_get-input "$@")
  if [[ "${#char}" -ne 1 ]]; then
    _err "Argument must be a single character"
    return 1
  fi
  echo -n "$char" | iconv -f UTF-8 -t UTF-32BE | xxd -p | sed -r 's/^0+/0x/' | xargs printf 'U+%04X\n'
}

# Dump the hexadecimal code of the provided string (output depends on encoding
# used by the terminal).
enc() {
  echo -n "$@" | hexdump | head -1 | cut -d ' ' -f 2-
}

# Print the character encoding used by the terminal
enc-type() {
  echo $LC_CTYPE
}

# TODO: set LC_* variables:
#   - Display values with `locale`
#   - Display all available locales with `locale -a | sort`

#==============================================================================#
## Number processing
#==============================================================================#

# TODO:
#   - Move __x2x to ~/.bashrc.lib/?
#   - Rename functions to dec2bin, dec2hex, etc.
# Convert numbers between numeral systems. Input read from stdin or arg list.
# Convert a list of numbers between numeral systems
# Usage:
#   d2b 10 999 
d2b() {
  __x2x 10 2 "$(_get-input "$@")"
}
d2o() {
  __x2x 10 8 "$(_get-input "$@")"
}
d2h() {
  __x2x 10 16 "$(_get-input "$@")"
}
h2b() {
  __x2x 16 2 "$(_get-input "$@")"
}
h2o() {
  __x2x 16 8 "$(_get-input "$@")"
}
h2d() {
  __x2x 16 10 "$(_get-input "$@")"
}
b2o() {
  __x2x 2 8 "$(_get-input "$@")"
}
b2d() {
  __x2x 2 10 "$(_get-input "$@")"
}
b2h() {
  __x2x 2 16 "$(_get-input "$@")"
}
o2b() {
  __x2x 8 2 "$(_get-input "$@")"
}
o2d() {
  __x2x 8 10 "$(_get-input "$@")"
}
o2h() {
  __x2x 8 16 "$(_get-input "$@")"
}
__x2x() {
  local from=$1
  local to=$2
  shift 2
  local n
  for n in $@; do
    # Note: obase must be before ibase
    bc <<<"obase=$to; ibase=$from; $(_to-upper-case "$n")"
  done
}

# Print a number in binary, octal, decimal, and hexadecmial formats. The input
# number may be provided as a binary, octal, decimal, or hexadecimal number.
# Usage:
#   n <number>
# Examples:
#   n 0b10  // Binary
#   n 010   // Octal
#   n 10    // Decimal
#   n 0x10  // Hexadecimal
n() {
  local PAT_BIN='^0b([01]+)$'
  local PAT_OCT='^0([0-7]+)$'
  local PAT_DEC='^([1-9][0-9]*)$'
  local PAT_HEX='^0x([0-9a-fA-F]+)$'
  local PAT_0='^(0)$'
  local n
  # Convert number to decimal as an intermediate format
  if   [[ $1 =~ $PAT_HEX ]]; then n=$(h2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_BIN ]]; then n=$(b2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_OCT ]]; then n=$(o2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_DEC || $1 =~ $PAT_0 ]]; then n=${BASH_REMATCH[1]}
  else
    echo "Invalid number: $1" && return 1
  fi
  # Convert from decimal to binary, octal, decimal, and hexadecimal
  echo "$(d2b $n)"
  echo "$(d2o $n)"
  echo "$n"
  echo "$(d2h $n)"
}

#==============================================================================#
## Date and time processing
#==============================================================================#

# Convert a number of seconds to a "<X>m <Y>s" representation.
sec2min() {
  echo "$(("$1"/60))m $(("$1"%60))s"
}

if _is-mac; then
  # Convert a date string in a specific format to a UNIX timestamp in seconds.
  # If the date string doesn't include a time, the current time is assumed.
  # Usage:
  #   date2ts <date> <date_format>
  # Example:
  #   date2ts "2016-02-02 13:21:45" "%Y-%m-%d %H:%M:%S"
  date2ts() {
    # '-j' disables setting of system date, '-f' is the format of input date
    date -j -f "$2" "$1" '+%s'
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optinally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  # Usage:
  #   ts2date <timestamp> [<out_format>]
  ts2date() {
    date -r "$@"
  }
elif _is-linux; then
  # Convert a date string to a UNIX timestamp in seconds. The date string format
  # is the one described in the 'date' man page as '--date=STRING'.
  # Usage:
  #   date2ts <date>
  date2ts() {
    date -d "$1" '+%s'
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optionally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  # Usage:
  #   ts2date <timestamp> [<out_format>]
  ts2date() {
    _is-set "$2" && date -d "@$1" "$2" || date -d "@$1"
  }
fi

#==============================================================================#
## Networking
#==============================================================================#

# Get public IP address of local machine
myip() {
  curl -s checkip.amazonaws.com
}

# Show local ports that are currently in use
ports() {
  lsof -i -P -n | grep LISTEN
}

change_mac() {
  local mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//')
  sudo ifconfig en0 ether "$mac"
  echo "Changed MAC address of en0 device to $mac"
}

# TODO: move to Misc
#==============================================================================#
## macOS
#==============================================================================#

if _is-mac; then
  # Hide hidden files in Finder
  finder-hide-hidden-files() {
    defaults write com.apple.finder AppleShowAllFiles FALSE 
    killall Finder
  }

  # Show hidden files in Finder
  finder-show-hidden-files() {
    defaults write com.apple.finder AppleShowAllFiles TRUE
    killall Finder
  }

  # Get the bundle ID (e.g. com.apple.Preview) of an application.
  # Note: app names are case insensitive
  app-id() {
    osascript -e "id of app \"$1\""
  }
fi

# TODO: create module in ~/.bashrc.mod
#==============================================================================#
## Terraform
#==============================================================================#

if _is-cmd terraform; then
  # Aliases
  alias tf=terraform
  alias tfa='terraform apply'
  alias tfd='terraform destroy'
  alias tfaa='terraform apply --auto-approve'
  alias tfdd='terraform destroy --auto-approve'

  # Enable command completion
  if _is-mac && _is-cmd brew; then
    complete -C $(brew --prefix)/bin/terraform terraform
  elif _is-linux; then
    complete -C /usr/bin/terraform terraform
  fi
fi

# TODO: create module in ~/.bashrc.mod
#==============================================================================#
## Prometheus
#==============================================================================#

# Display only the distinct metric names from a page of Prometheus metrics
prom-distinct() {
  sed '/^#/d;s/[{ ].*$//' | uniq
}

# Reduce a Prometheus metrics response to metric names and help texts
prometheus-clean() {
  # Remove labels and values (keep only metric names)
  sed '/^[^#]/s/[ {].*$//' |
  # Delete duplicate metric names
  uniq |
  # Remove TYPE comments
  sed '/^# TYPE/d' |
  # Simplify HELP comments (strip HELP keyword and metric name)
  sed '/^# HELP/s/HELP [^ ]* //'
}

#==============================================================================#
## Misc
#==============================================================================#

# Open a JMESPath Terminal
# https://github.com/jmespath/jmespath.terminal)
jpterm() {
  python /Users/dw/Library/Python/2.7/lib/python/site-packages/jpterm.py
}

# Minicom
alias minicom='minicom -c on'


#==============================================================================#
## Module init parts
#==============================================================================#

_bashrc-mod-source ~/.bashrc.mod/homebrew.init.bash

#==============================================================================#
## Module main parts
#==============================================================================#

# Outcomment unneeded modules
_bashrc-mod-source ~/.bashrc.mod/homebrew.bash
_bashrc-mod-source ~/.bashrc.mod/vim.bash
_bashrc-mod-source ~/.bashrc.mod/bashrc.bash
_bashrc-mod-source ~/.bashrc.mod/shell-prompt.bash
_bashrc-mod-source ~/.bashrc.mod/shell-history.bash
#_bashrc-mod-source ~/.bashrc.mod/multimedia.bash
#_bashrc-mod-source ~/.bashrc.mod/aws.bash
#_bashrc-mod-source ~/.bashrc.mod/azure.bash
#_bashrc-mod-source ~/.bashrc.mod/docker.bash
#_bashrc-mod-source ~/.bashrc.mod/kubernetes.bash
#_bashrc-mod-source ~/.bashrc.mod/terminfo.bash

#==============================================================================#
## Auto-added code
#==============================================================================#

