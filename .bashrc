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

# TODO: move to 'sys' package of library

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

# TODO: move to 'sys' package of library, output in CSV

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

# TODO: move to 'bashrc' pacakge library (must be in library because depends on format in bashrc files)

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
## Text processing
#==============================================================================#

# TODO: move to 'text' package of library

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

# TODO: move to library
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

# TODO: see if can be combined with unicode()
# Dump the hexadecimal code of the provided string (output depends on encoding
# used by the terminal).
enc() {
  echo -n "$@" | hexdump | head -1 | cut -d ' ' -f 2-
}

# Print the character encoding used by the terminal
enc-type() {
  echo $LC_CTYPE
}


#==============================================================================#
## Number processing
#==============================================================================#

# TODO: move to math package of library (rename functions to dec2bin, dec2hex, etc.)
#
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

# TODO: create 'datetime' package of library

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

# TODO: create 'net' or 'network' package of library


# TODO: rename according to naming format
# Show local ports that are currently in use
ports() {
  lsof -i -P -n | grep LISTEN
}

# TODO: rename according to naming format
# Get public IP address of local machine
myip() {
  curl -s ifconfig.me
}

_ip-private-get() {
  ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1
}

# TODO: rename according to naming format
# Override MAC address of physical network interface
change_mac() {
  local mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//')
  sudo ifconfig en0 ether "$mac"
  echo "Changed MAC address of en0 device to $mac"
}

# TODO: add functions:
#   - Check whether an IP address is public or private
#   - Get the MAC address of the physical network interface

#==============================================================================#
## Module init parts
#==============================================================================#

_bashrc-mod-source ~/.bashrc.mod/homebrew.init.bash

#==============================================================================#
## Module main parts
#==============================================================================#

# Outcomment unneeded modules
_bashrc-mod-source ~/.bashrc.mod/bashrc.bash
_bashrc-mod-source ~/.bashrc.mod/bash-completion.bash
_bashrc-mod-source ~/.bashrc.mod/complete-alias.bash
_bashrc-mod-source ~/.bashrc.mod/util.bash
_bashrc-mod-source ~/.bashrc.mod/shellconf-base.bash
_bashrc-mod-source ~/.bashrc.mod/prompt.bash
_bashrc-mod-source ~/.bashrc.mod/readline.bash
_bashrc-mod-source ~/.bashrc.mod/history.bash
_bashrc-mod-source ~/.bashrc.mod/homebrew.bash
_bashrc-mod-source ~/.bashrc.mod/vim.bash
_bashrc-mod-source ~/.bashrc.mod/git.bash
_bashrc-mod-source ~/.bashrc.mod/grip.bash
_bashrc-mod-source ~/.bashrc.mod/macos-util.bash
#_bashrc-mod-source ~/.bashrc.mod/apt.bash
#_bashrc-mod-source ~/.bashrc.mod/docker.bash
#_bashrc-mod-source ~/.bashrc.mod/prometheus.bash
#_bashrc-mod-source ~/.bashrc.mod/terraform.bash
#_bashrc-mod-source ~/.bashrc.mod/multimedia.bash
#_bashrc-mod-source ~/.bashrc.mod/aws.bash
#_bashrc-mod-source ~/.bashrc.mod/azure.bash
#_bashrc-mod-source ~/.bashrc.mod/docker.bash
#_bashrc-mod-source ~/.bashrc.mod/kubernetes.bash
#_bashrc-mod-source ~/.bashrc.mod/terminfo.bash

#==============================================================================#
## Auto-added code
#==============================================================================#

