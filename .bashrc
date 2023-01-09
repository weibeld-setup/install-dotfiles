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
#
# Q: Is it necessary to declare all variables in functions as 'local'?
# A: See https://google.github.io/styleguide/shellguide.html#s7.6-use-local-variables
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Shell options
#------------------------------------------------------------------------------#

shopt -s extglob
shopt -s nullglob
# Expand environment variables containing a directory name in path strings
shopt -s direxpand
set -o pipefail

# Append to the history file ($HISTFILE) rather than overwriting it (for
# collecting history of all shells in the history file, see PROMPT_COMMAND)
shopt -s histappend

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

# Read text from stdin and format it to width of terminal with word wrapping.
# This function is similar to the 'fmt' command, but it preserves all newlines.
format() {
  awk -v c=$(tput cols) 'BEGIN{printf ".pl 1\n.ll %d\n.na\n.hy 0\n", c}{print}' |
    nroff |
    sed 's/\xE2\x80\x90/-/g'
  # - awk adds nroff commands to beginning of input (.pl = page length,
  #   .ll = line length, .na=disable justification, hy 0 = disable hyphenation)
  # - nroff formats the text
  # - sed reverts the conversion of - to U+2010 (UTF-8 0xE28090) done by nroff
  # https://docstore.mik.ua/orelly/unix3/upt/ch21_03.htm
}

# Split an args sequence at a custom delimiter into two arrays, one containing
# the args before the delimiter and one containing the args after the delimiter.
# Usage:
#   splitargs <arr_a> <arr_b> <delim> <args>...
# Args:
#   <arr_a>  Name of an array to which to assign the args before the delimiter
#   <arr_b>  Name of an array to which to assign the args after the delimiter
#   <delim>  The delimiter (e.g. --)
#   <args>   Sequence of arguments (possibly containing)
# Example usage:
#   splitargs arr1 arr2 -- before1 before2 -- after1 after2
# The above results in the following assignments to arr1 and arr2:
#   - arr1["before1", "before2"]
#   - arr2["after1", "after2"]
# If the args sequence does not contain the delimiter, then all the args are
# assigned to the first array (<arr_a>).
# CAUTION: the passed in array names must not be __a and __b as these are the
# locally used array names (causes a "circular name reference" error).
splitargs() {
  # Nameref variables, see [1]
  # [1] https://www.gnu.org/software/bash/manual/html_node/Shell-Parameters.html
  local -n __a=$1 __b=$2
  local delim=$3
  shift 3
  for i in $(seq 1 "$#"); do
    if [[ "${!i}" = "$delim" ]]; then
      __a=("${@:1:$(($i-1))}")  # Args before delimiter
      __b=("${@:$(($i+1))}")    # Args after delimiter
      return
    fi
  done
  __a=("$@")  # If the args don't contain the delimiter
}

# Test if an array contains a specific element.
# Usage example: array-contains "${myarr[@]}" foo
array-contains() {
  local array=("${@:1:$#-1}")
  local element=${@:$#}
  for i in $(seq 0 $(("${#array[@]}"-1))); do
    [[ "${array[$i]}" = "$element" ]] && return 0
  done
  return 1
}

# Print an ANSI Select Graphic Rendition (SGR) escape sequence (see [1])
#
# Usage:
#   c [<arg>]...
# Where <arg> is either a colour, or one or multiple modifiers.
#
# Colours:
#   - black
#   - red
#   - green
#   - yellow
#   - blue
#   - magenta
#   - cyan
#   - white
# A plus sign may be appended to each colour (e.g. 'red+'), in which case the
# bright version of the colour is used.
#
# Modifiers:
#   - x: reset
#   - b: bold
#   - d: dim
#   - i: italic
#   - u: underline
# The x modifier is special as it resets all the previously set attributes
# (colours and modifiers). Multiple modifiers can be combined in a single arg.
#
# Example usage:
#   c red        // Red 
#   c red+       // Bright red 
#   c red b      // Red, bold
#   c red biu    // Red, bold, italic, and underlined
#   c red b i u  // Equivalent to above command
#   c            // Reset all previously set colours and modifiers
#   c x          // Equivalent to above command
#   c bu         // Bold and underlined (don't change colour)
#
# Application:
#   echo "$(c red bi)red $(c x blue+ u)blue$(c) normal"
#
# [1] https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
c() {
  local p
  for a in "$@"; do
    # Parse colour
    case "$a" in
      black)    p+=(30); continue ;;
      red)      p+=(31); continue ;;
      green)    p+=(32); continue ;;
      yellow)   p+=(33); continue ;;
      blue)     p+=(34); continue ;;
      magenta)  p+=(35); continue ;;
      cyan)     p+=(36); continue ;;
      white)    p+=(37); continue ;;
      black+)   p+=(90); continue ;;
      red+)     p+=(91); continue ;;
      green+)   p+=(92); continue ;;
      yellow+)  p+=(93); continue ;;
      blue+)    p+=(94); continue ;;
      magenta+) p+=(95); continue ;;
      cyan+)    p+=(96); continue ;;
      white+)   p+=(97); continue ;;
    esac
    # Parse modifiers (x, b, i, u, d)
    a=($(grep -o . <<<"$a"))
    for i in "${a[@]}"; do
      case "$i" in
        x) p+=(0) ;;  # Reset
        b) p+=(1) ;;  # Bold
        d) p+=(2) ;;  # Dim
        i) p+=(3) ;;  # Italic
        u) p+=(4) ;;  # Underlined
      esac
    done
  done
  # Print escape sequence
  printf "\e[$(tr ' ' ';' <<<"${p[@]}")m"
}

# Print coloured message to stdout/stderr if connected to terminal and omit the
# colours if not connected to a terminal.
# Usage:
#   c-echo <colour-attribute>... <msg>
# Examples:
#   c-echo red b "Foo bar"         # Print red bold message to stdout
#   c-echo red b "Foo bar" >out    # Colours omitted because stdout is file
#   c-echo-stderr red b "Foo bar"  # Print red bold message to stderr
c-echo() { __c-echo 1 "$@"; }
c-echo-stderr() { __c-echo 2 "$@"; }
__c-echo() {
  fd=$1
  c_args=(${@:2:$#-2})
  msg=${@:$#}
  [[ -t "$fd" ]] && msg=$(c "${c_args[@]}")$msg$(c)
  if [[ "$fd" -eq 1 ]]; then echo "$msg"
  elif [[ "$fd" -eq 2 ]]; then echo "$msg" >/dev/stderr
  else return 1; fi
}

#------------------------------------------------------------------------------#
# Configure Readline
# https://www.gnu.org/software/bash/manual/html_node/Command-Line-Editing.html
#------------------------------------------------------------------------------#
bind 'set skip-completed-text on'

# Enable/disable vi line-editing mode (default is emacs)
vi-mode-on() {
  bind 'set editing-mode vi'  # Equivalen to set -o vi
  bind 'set show-mode-in-prompt on'
  bind 'set vi-ins-mode-string \1\033[1;32m@|\033[m\2'
  bind 'set vi-cmd-mode-string \1\033[1;42;37m@\033[;1;32m|\033[m\2'
  bind '"\C-k": vi-movement-mode'
}
vi-mode-off() {
  bind 'set editing-mode emacs'  # Equivalen to set +o vi
  bind 'set show-mode-in-prompt off'
}

#------------------------------------------------------------------------------#
# Prompt
#------------------------------------------------------------------------------#

PROMPT_COMMAND='__set-prompt; __dump_history'
__set-prompt() {
  #PS1="$ " && return
  local EXIT_CODE=$?
  if is-mac; then
    PS1='\[\e[1;32m\]\v|\w$ \[\e[0m\]'
 else
    PS1='\[\e[1;33m\]\u@\h:\w$ \[\e[0m\]'
  fi
  [[ "$EXIT_CODE" -ne 0 ]] && PS1="\[\e[1;31m\]$EXIT_CODE|$PS1"
}

# Append the last command to the $HISTFILE history file (for aggregating the
# history of all active shells)
# TODO: emulate HISTCONTROL=ignoredups by omitting writing a command to the
# history file if it's equal to the lastly written command.
__dump_history() {
  history -a
}

#------------------------------------------------------------------------------#
# bash-completion (installed with Homebrew)
#------------------------------------------------------------------------------#

if is-mac ; then
  source /usr/local/etc/profile.d/bash_completion.sh
  # Source completion scripts of Homebrew formulas
  for f in /usr/local/etc/bash_completion.d/*; do
    source "$f"
  done
fi

#------------------------------------------------------------------------------#
# complete-alias (https://github.com/cykerway/complete-alias)
#------------------------------------------------------------------------------#

source ~/.complete_alias

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
# System management
#------------------------------------------------------------------------------#

alias br='vim ~/.bashrc'
alias bp='vim ~/.bash_profile'
alias sbr='. ~/.bashrc'
alias sbp='. ~/.bash_profile'
alias vr='vim ~/.vimrc'
alias rmf='rm -rf'
alias la="ls -a"
alias ll="ls -al"
alias ld="ls -d */"
alias wl='wc -l'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
complete -F _complete_alias f
alias ssh='TERM=xterm-256color ssh'
alias torsocks='TERM=xterm-256color torsocks'
alias pgrep='pgrep -fl'
alias x='chmod +x'
alias X='chmod -x'
alias which='which -a'
alias watch='watch -n 1'

# File sizes
alias dh='du -h'
alias ds='du | sort -k 1 -n -r'
alias dhm='du -h | grep M$"\t" | sort -k 1 -n -r'

# Print or remove completion specification of a command
alias comp='complete -p'
alias compr='complete -r'
complete -c comp compr

# Set default options
alias curl='curl -s'

# Coloured diff output (requires diffutils [1] package)
# [1] https://www.gnu.org/software/diffutils/
alias diff='diff --color'

# Print large directories in the current directory. The threshold for printing
# directories can be specified either as 'g' or 'm':
#   - 'g': print directories larger than 1 GB
#   - 'm': print directories larger than 1 MB
large-dirs() {
  threshold=${1:-g}
  case "$threshold" in
    g) pattern="G$(printf "\t")" ;;
    m) pattern="M$(printf "\t")\|G$(printf "\t")" ;;
  esac
  sudo du -h | grep "$pattern"
}

# Get public IP address of local machine
myip() {
  curl -s checkip.amazonaws.com
}

# Show local ports that are currently in use
ports() {
  lsof -i -P -n | grep LISTEN
}

# Show the help page of a shell builtin like man page
#help() { builtin help -m "$1" | less; }
#complete -b help 

# Show the source file and line where a function is defined
funcfile() {
  shopt -s extdebug
  declare -F "$1"
  shopt -u extdebug
}
complete -A function funcfile

# Search through the central history file (see PROMPT_COMMAND) and either
# print or directly execute the selected command
# TODO: add option for just pasting the selected command to the prompt without
# executing it
hist() {
  ensure fzf || return 1
  # Directly execute the command
  if [[ "$1" = -x ]]; then
    eval $(cat "$HISTFILE" | fzf -e --tac)
  # Print the command to stdout
  else
    cat "$HISTFILE" | fzf -e --tac
  fi
}


# Change into the directory of the file pointed to by a symlink
cdl() {
  local t=$(readlink "$1")
  cd $([[ -f "$t" ]] && echo $(dirname "$t") || echo "$t")
}
complete -f cdl

# Change <n> levels up in the directory hierarchy
cdu() {
  local n=${1:-1}
  for i in $(seq 1 "$n"); do
    cd ..
  done
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

# Location of the terminfo capabilities database, used by TODO and TODO.
export INFODB=~/.infodb

# Generate the terminfo capability information database. This database contains
# the following information about all capabilities known to terminfo:
#   1) Type: type of the capability  (boolean, numeric, or string)
#   2) Name: name of the capability (as used in the terminfo database)
#   3) Variable: C variable name of the capability in the terminfo library
#   4) Description: human-readable description of the capability
# The information is extracted from the terminfo man page. The above data fields
# are organised in tabular form with the columns separated by tabs. The order
# of the columns is as shown above. The lines are sorted alphabetically by the
# Type and Name fields.
# TODO: sort database alphabetically by the short terminfo name (currently
# is sorted by the long C variable name). Sort first by type (Boolean, Numeric,
# String), and secondly by the short terminfo name.
_infodb_create() {
  echo "Generating database in $INFODB..." >&2
  echo "# Generated by ${FUNCNAME[0]} on $(date)" >"$INFODB"
  cat $(man --path terminfo) | sed -n '/.*Variable.*Cap-.*TCap.*Description.*/,/.TE/p' | while read line; do
    case "$line" in
      *Variable*|T}|.TE) continue;;
      *Boolean**) type=Boolean;;
      *Numeric**) type=Numeric;;
      *String**) type=String;;
      *T{)
        varname=$(awk '{print $1}' <<<"$line")
        name=$(awk '{print $2}' <<<"$line");;
      *)
        description=$(tr '\t' ' ' <<<"$line")
        ready=1;;
    esac
    if [[ "$ready" = 1 ]]; then
      echo -e "$type\t$name\t$varname\t$description" >>"$INFODB"
      ready=0
    fi
  done
  # Add entries not included in the terminfo man page
  # Non-standard capabilities used by xterm, see:
  #   - https://man7.org/linux/man-pages/man5/user_caps.5.html
  #   - https://invisible-island.net/xterm/terminfo.html
  echo -e "String\tmeml\tmemory_lock\tlock memory above cursor" >>"$INFODB"
  echo -e "String\tmemu\tmemory_unlock\tunlock memory" >>"$INFODB"
}

# Retrieve one or more entries from the database by their capability name.
# Usage (examples):
#   _infodb_lookup cub1
#   _infodb_lookup cub1 cud1 cuu1 cuf1
# The data is returned in the same format as it's saved in the database.
_infodb_lookup() {
  [[ -f "$INFODB" ]] || _infodb_create
  result=$(grep "$(sed 's/^/\\t/;s/ /\\t\\|\\t/g;s/$/\\t/' <<<"$@")" "$INFODB")
  # Test if result contains all requested capabilities
  not_found=$(sed "/$(echo "$result" | cut -d $'\t' -f 2 | paste -sd ' ' - | sed 's/ /\\|/g')/d" <<<$(IFS=$'\n'; echo "$*" | sort | uniq))
  if [[ -n "$not_found" ]]; then
    echo -e "${FUNCNAME[0]}: unknown capabilities (not present in $INFODB):\n$(sed 's/^/  - /' <<<"$not_found")" >&2
    return 1
  fi
  echo "$result"
}

# Helper functions returning a portion of the infocmp output:
#   _infonames: return names of capabilities in default order
#   _infovals: return values of capabilities in defalt order
#   _infoheader: return only the header line with terminal name and aliases
# Each function outputs one item per line. Each function optionally accepts a
# terminal name as an argument. By default, the terminal in TERM is used.
_infonames() {
  infocmp -1 ${1:-$TERM} | sed '/^#/d' | sed 1d | sed 's/[,=#].*//;s/^[[:blank:]]*//'
}
_infovals() {
  infocmp -1 ${1:-$TERM} | sed '/^#/d' | sed 1d | sed 's/[^#=]*//;s/^[#=]//;s/,$//'
}
_infoheader() {
  infocmp -1 ${1:-$TERM} | sed '/^#/d' | sed -n 1p | sed 's/,$//'
}

# TODO: create single command combining all functionality:
#   infocap             # Display all capabilities of terminal in TERM
#   infocap -t <term>   # Display all capabilities of specified terminal
#   infocap <cap>...    # Display specified capabilities of terminal in TERM
#   infocap -a          # Display all capabilities known to terminfo (without values)
#   infocap -a <cap>... # Display the specified capabilities (without values)
# The 'infocap -a' variant provides the functionality of infolookup, and the
# variant without '-a' provides the functionality of infonice.
# Extension: for the variant without '-a', by default, only display the Type,
# Name, and Value columns. Add flags '-c' and '-d' to additionally display the
# Variable, and Description column. For the '-a' variant, always display all
# columns.

# Format output of infocmp in tabular form.
# Usage:
#   infonice [term]
# By default, the terminal in the TERM environment variable is used.
# The output columns include:
#   1) Capability type (boolean, numeric, or string)
#   2) Capability name
#   3) Corresponding variable name in the terminfo C library
#   4) Value (for numeric and string capabilities)
# TODO: rewrite to use ~/.infolookup database (see infolookup), then use
# something like this:
#   cat ../.infolookup | grep "$(infocmp -1 | _infonames | sed 's/^/\\t/;s/$/\\t\\|/' | tr -d '\n' | sed 's/\\|$//')" | column -t -s $'\t'
# And use 'paste' of the above with the values from the infocmp output. This
# should be much faster than the current solution.
# TODO: infoterm
# TODO: there may be capabilities in the infocmp output that are not in the
# infodb database (i.e. that are not in the terminfo man page). For example,
# meml and memu for xterm-256colors.
infonice() {
  local term=${1:-$TERM}
  local names=$(_infonames "$term")
  local values=$(_infovals "$term") 
  local header=$(_infoheader "$term")
  local info; info=$(_infodb_lookup "$names") || return 1
  echo "$header"
  paste -d '\t' <(echo "$info") <(echo "$values") | column -t -s $'\t'
#  
#  IFS=, read -r -a fields<<<$(infocmp -1 "$term" | sed '/^#/d' | sed 's/^[[:blank:]]*//' | tr -d '\n')
#  local dict=$(paste -d , <(infocmp -1x "$term" | _infonames) <(infocmp -1xL -s i "$term" | _infonames))
#  echo "${fields[0]}"
#  for i in $(seq 1 $(("${#fields[@]}"-1))); do
#    name=${fields[$i]%%[#=]*}
#    value=${fields[$i]#*[#=]}
#    longname=$(echo "$dict" | grep "^$name," | cut -d , -f 2)
#    [[ ! "${fields[$i]}" =~ [=#] ]] && type=Boolean value=
#    [[ "${fields[$i]}" =~ '#' ]] && type=Numeric
#    [[ "${fields[$i]}" =~ '=' ]] && type=String
#    echo "$i,$type,$name,$longname,$value"
#  done | column -t -s ,
}


# Look up information aboutany terminfo capabilities.
# Usage:
#   infolookup <name>...
#   infolookup '*'
# <name> is the name of any capability supported by terminfo (may be repeated).
# If '*' is given as the only argument, then all terminfo capabilities are
# printed in a compact form.
# The data is extracted from the terminfo man page. On the first run, a database
# is created in a local file. Subsequent runs then just look up the information
# from this database.
# The displayed information for each capability includes:
#   1) Type (boolean, numeric, or string)
#   2) C variable name (as used in the terminfo library)
#   3) Description 
# TODO: infocap
# TODO: print all capabilities if no arguments are given
infolookup() {
  [[ -f "$INFODB" ]] || _infodb_create
  if [[ "$1" = '*' ]]; then
    cat "$INFODB" | sed '/^#/d' | nl -w 3 | column -t -s $'\t'
  else
    for a in "$@"; do
      result=$(grep "\t$a\t" "$INFODB") || { echo "Error: $a not found" >&2; return 1; }
      echo -e "\e[1m$(echo "$result" | cut -d $'\t' -f 2)\e[0m"
      echo "  $(echo "$result" | cut -d $'\t' -f 1)"
      echo "  $(echo "$result" | cut -d $'\t' -f 3)"
      echo "  $(echo "$result" | cut -d $'\t' -f 4 | sed 's/^./\U&/;/[^\.]$/s/$/\./')"
    done
  fi
}

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

# Print a number in binary, octal, decimal, and hexadecmial formats. The number
# can be provided as binary (0b...), octal (0...), decimal, or hexadecimal (0x...)
n() {
  local PAT_BIN='^0b([01]+)$'
  local PAT_OCT='^0([0-7]+)$'
  local PAT_DEC='^([1-9][0-9]*)$'
  local PAT_HEX='^0x([0-9a-fA-F]+)$'
  local PAT_0='^(0)$'
  local n
  # Convert number to decimal as an intermediary format
  if   [[ $1 =~ $PAT_HEX ]]; then n=$(h2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_BIN ]]; then n=$(b2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_OCT ]]; then n=$(o2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_DEC || $1 =~ $PAT_0 ]]; then n=${BASH_REMATCH[1]}
  else
    echo "Invalid number: $1" && return 1
  fi
  # Convert from decimal to other systems
  echo "Binary: $(d2b $n)"
  echo "Octal: $(d2o $n)"
  echo "Decimal: $n"
  echo "Hexadecimal: $(d2h $n)"
}

# Generate a random hexadecimal string of a given length
hex(){
  digits=$1
  cat /dev/urandom | head -c $((("$digits"/2)+1)) | hexdump -e '"%x"' | head -c "$digits"
  echo
}

# Convert a number of seconds to a "<X>m <Y>s" representation.
sec2min() {
  echo "$(("$1"/60))m $(("$1"%60))s"
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
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push -f'
alias gb="git branch"
alias gd="git diff"
alias gpu="git pull"
gco() {
  git checkout $(git branch | fzf --tac | sed 's/^[^a-zA-Z0-9]*//')
}


#------------------------------------------------------------------------------#
# Docker
#------------------------------------------------------------------------------#

# Automatically set '--rm' flag when 'docker [container] run' is run
docker() {
  local args=("$@")
  if [[ "$1" = run ]]; then
    args=(run --rm "${args[@]:1}")
  elif [[ "$1" = container && "$2" = run ]]; then
    args=(container run --rm "${args[@]:2}")
  fi
  command docker "${args[@]}"
}

alias dk=docker
complete -F _complete_alias dk
alias dki='docker image ls'
#alias dkc='docker container ps -a'

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
dks() {
  local c=$(docker ps -q)
  is-set "$c" && docker stop $c || echo "No running containers"
}

# Run a container in the host namespaces (allows to enter Docker Desktop VM)
docker-vm() {
  # The --pid=host flag starts the container in the same PID namespace as the
  # Docker Desktop VM. The nsenter -t 1 command then enters the specified name-
  # spaces of the process with PID 1 (root process on the Docker Desktop VM).
  # The entered namespaces are: mount (-m), UTS (-u), network (-n), IPC (-i).
  # (use the -a flag to enter all namespaces). All Linux namespaces: mount,
  # UTS, network, IPC, PID, cgroup, user.
  docker run -it --pid=host --privileged weibeld/ubuntu-networking nsenter -t 1 -m -u -n -i bash
}

# List the most recent tags of an image on Docker Hub.
# Usage:
#   dktags name [number]
# Args:
#   name      Name of the image (e.g. 'ubuntu', 'weibeld/ubuntu-networking')
#   [number]  Number of tags to list (default: 15)
dktags() {
  name=$1
  number=${2:-15}
  # Expand the names of official images (where the repository is omitted)
  [[ ! "$name" =~ .*/.* ]] && name=library/"$name"
  curl -L "https://registry.hub.docker.com/v2/repositories/$name/tags?page_size=$number" \
    | jq -r '.results[] | [.name, .last_updated] | @tsv' \
    | awk '{gsub("T", " ", $2); gsub("\\..*$", "", $2); print $1"\t"$2}' \
    | sed 's/^\([a-zA-Z0-9._-]*\)/'$(echo -e '\e')'[33m\1'$(echo -e '\e')'[0m/' \
    | column -t -s $'\t' 
}

#------------------------------------------------------------------------------#
# AWS CLI
#------------------------------------------------------------------------------#

alias ac="vim ~/.aws/config"
alias acr="vim ~/.aws/credentials"

# List enabled (or all) AWS regions.
# Usage:
#   areg [-a|--all]
# Without any arguments, only the IDs of the enabled regions are listed (since
# 2019, new regions have to be explicitly enabled [1]). With -a|--all, all
# regions (including disabled ones) are listed, including additional info.
# [1] https://docs.aws.amazon.com/general/latest/gr/rande-manage.html
areg() {
  if [[ "$#" = 0 ]]; then
    aws ec2 describe-regions \
      --no-cli-auto-prompt \
      --query 'Regions[].RegionName' |
      jq -r '.[]' |
      sort
  # sed expression for inserting region name column can be created from a file
  # containing region IDs and names in tab-separated columns as in [1]. A full
  # list of regions, including human-readable names, can be found in [2].
  # [1] sed 's|^|        s/^|;s|\t|\\t/\\0|;s|$|\\t/;|'
  # [2] https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions
  elif [[ "$1" =~ --all|-a ]]; then
    aws ec2 describe-regions \
      --no-cli-auto-prompt \
      --all-regions \
      --query 'Regions[].[RegionName,OptInStatus]' |
      jq -r '.[] | join("\t")' |
      sed "
        s/\topted-in/\tenabled\tManually enabled/;
        s/\topt-in-not-required/\tenabled\tEnabled by default/;
        s/\tnot-opted-in/\tdisabled\tMay be enabled/" |
      sed '
        s/^af-south-1\t/\0Cape Town\t/;
        s/^ap-east-1\t/\0Hong Kong\t/;
        s/^ap-northeast-1\t/\0Tokyo\t/;
        s/^ap-northeast-2\t/\0Seoul\t/;
        s/^ap-northeast-3\t/\0Osaka\t/;
        s/^ap-south-1\t/\0Mumbai\t/;
        s/^ap-south-2\t/\0Hyderabad\t/;
        s/^ap-southeast-1\t/\0Singapore\t/;
        s/^ap-southeast-2\t/\0Sydney\t/;
        s/^ap-southeast-3\t/\0Jakarta\t/;
        s/^ca-central-1\t/\0Central\t/;
        s/^eu-central-1\t/\0Frankfurt\t/;
        s/^eu-central-2\t/\0Zurich\t/;
        s/^eu-north-1\t/\0Stockholm\t/;
        s/^eu-south-1\t/\0Milan\t/;
        s/^eu-south-2\t/\0Spain\t/;
        s/^eu-west-1\t/\0Ireland\t/;
        s/^eu-west-2\t/\0London\t/;
        s/^eu-west-3\t/\0Paris\t/;
        s/^me-central-1\t/\0UAE\t/;
        s/^me-south-1\t/\0Bahrain\t/;
        s/^sa-east-1\t/\0São Paulo\t/;
        s/^us-east-1\t/\0N. Virginia\t/;
        s/^us-east-2\t/\0Ohio\t/;
        s/^us-west-1\t/\0N. California\t/;
        s/^us-west-2\t/\0Oregon\t/' |
      sort -t $'\t' -k3,3r -k1,1 |
      column -t -s $'\t' |
      sed "
        /May be enabled$/s/^/$(c d)/;s/$/$(c)/;
        s/Manually enabled/$(c d)\0$(c)/" |
      sed "
        s/ enabled /$(c green)\0$(c)/;
        s/ disabled /$(c)$(c red)\0$(c)$(c d)/"
  fi
}

# List the availability zones of a specific region. Additional arguments for
# the 'describe-availability-zones' command may be supplied (e.g. --region).
aaz() {
  aws ec2 describe-availability-zones \
    --no-cli-auto-prompt \
    --query 'AvailabilityZones[].ZoneName' \
    "$@" |
    jq -r '.[]' |
    sort
}

# List the AMIs matching a given name pattern in the current region. The AMIs
# are sorted by creation date with the newest at the bottom. Additional args
# for the 'describe-images' command may be supplied (e.g. --region, --owner).
# Usage:
#   aami <pattern> [args...]
# Examples:
#   aami '*ubuntu*22.10*'
#   aami '*ubuntu*22.10*' --region eu-central-1
#   aami '*ubuntu*22.10*' --owner 099720109477
# Notes:
#   - For server-side (--filter) and client-side (--query) filtering, see [1].
#   - Client-side filtering uses JMESPath [2]. For sort_by(), see [3].
#   - 099720109477 is Canonical's owner ID. Owner IDs are stable across regions.
# [1] https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html
# [2] https://jmespath.org/
# [3] https://jmespath.org/specification.html#sort-by
aami() {
  local filter=$1
  shift 1
  aws ec2 describe-images \
    --no-cli-auto-prompt \
    --filter "Name=name,Values=$filter" \
    --query 'sort_by(Images,&CreationDate)[].{name:Name,description:Description,owner:OwnerId,date:CreationDate,id:ImageId}' \
    "$@"
}

# List all security groups in the current region. Additional arguments for the
# 'describe-security-groups' command may be supplied (e.g. --region).
asg() {
  aws ec2 describe-security-groups \
    --no-cli-auto-prompt \
    --query 'SecurityGroups[].{id:GroupId,name:GroupName,description:Description}' \
    "$@"
}

# List all key pairs in the current region. Additional arguments for the
# 'describe-key-pairs' command may be supplied (e.g. --region).
akey() {
   aws ec2 describe-key-pairs \
    --no-cli-auto-prompt \
    --query 'KeyPairs[].{id:KeyPairId,name:KeyName,description:Description}' \
    "$@"
}

# List all EC2 instances in the current region. Additional arguments for the
# 'describe-instances' command may be supplied (e.g. --region).
ai() {
  aws ec2 describe-instances \
    --no-cli-auto-prompt \
    --query 'Reservations[].Instances[].{id:InstanceId,type:InstanceType,public_ip:PublicIpAddress,key:KeyName,state:State.Name,launched:LaunchTime}' \
    "$@"
}

# Get a secret from AWS Secrets Manager
aws-get-secret() {
  local NAME_OR_ARN=$1
  aws secretsmanager get-secret-value --secret-id "$NAME_OR_ARN" --query SecretString --output text 
}

# Create a secret in AWS Secrets Manager
aws-create-secret() {
  local NAME=$1
  local VALUE=$2
  local DESCRIPTION=$3  # Optional
  aws secretsmanager create-secret --name "$NAME" --secret-string "$VALUE" --description "$DESCRIPTION" --output json
}

# List all secrets in AWS Secrets Manager
aws-list-secrets() {
  RAW=$1
  if [[ "$RAW" = -r ]]; then
    aws secretsmanager list-secrets --query 'SecretList[*].{Name: Name, ARN: ARN, Description: Description}' --output json
  else
    aws secretsmanager list-secrets --query 'SecretList[*].[Name, Description]' --output table
  fi
}

# Delete a secret from AWS Secrets Manager
aws-delete-secret() {
  local NAME_OR_ARN=$1
  aws secretsmanager delete-secret --secret-id "$NAME_OR_ARN" --output json
}

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

complete -C /usr/local/bin/aws_completer aws

#------------------------------------------------------------------------------#
# Azure
#------------------------------------------------------------------------------#

# List all currently known Azure users (e.g. Microsoft accounts)
az-users() {
  az account list --all --query "[*].user.name" -o tsv | sort | uniq
}

# List the subscriptions for a specific user
az-subscriptions() {
  local user=${1:-$(az-users | fzf)}
  az account list --all --query "[?user.name=='$user']"
}

# List the tenants, includings its subscriptions, for a specific user
az-tenants() {
  local user=${1:-$(az-users | fzf)}
  local json=$(az account list --all --query "[?user.name=='$user']" -o json)
  for t in $(echo "$json" | jq -r '.[] | .tenantId' | sort |  uniq); do
    [[ -t 1 ]] && echo "$(c b)$t$(c)" || echo "$t"
    echo "$json" | jq -r '.[] | select(.tenantId == "'$t'") | "  \(if .isDefault then "*" else "-" end) \(.name)\n    \(.id)"'
  done
}

# TODO: add similar commands for tenants when 'az account tenant' is out of preview

# Recursively list referenced templates in an Azure Pipelines file.
# Usage:
#   azure-pipeline-templates <file>...
# Depends on:
#   realpath (brew install coreutils)
azure-pipeline-templates() {
  for file in "$@"; do
    __azure-pipeline-templates "${file#./}" 0
  done
}
__azure-pipeline-templates() {
  local path=$1
  local depth=$2
  [[ ! -f "$path" ]] && { c-echo red "Error: file not found: $path"; return; }
  [[ "$depth" -gt 0 ]] && printf '|   %.0s' $(seq "$depth")
  echo "$path"
  local refs=$(sed -n '/[ -]*template:\s/s/^[ -]*template:\s*\([a-zA-Z0-9/._-]*\.yaml\).*$/\1/p' "$path")
  [[ -z "$refs" ]] && return
  for ref in $(realpath --relative-to "$PWD" $(sed "s|^|$(dirname "$path")/|" <<<"$refs") | awk '!seen[$0]++'); do
    __azure-pipeline-templates "$ref" "$(($depth+1))"
  done
}

#------------------------------------------------------------------------------#
# Kubernetes
#------------------------------------------------------------------------------#

# Display outputs of certain commands in terminal pager (less)
kubectl() {
  if
    [[ "$1" = explain || "$1" = describe ]] ||
    [[ "$*" =~ -o\ yaml|--output[=\ ]yaml ]]
  then
    command kubectl "$@" | less
  elif
    [[ "$*" =~ -h$|--help$ ]]
  then
    command kubectl "$@" | format | less
  else
    command kubectl "$@"
  fi
}

# Get current context
alias krc='kubectl config current-context'
# List all contexts
alias klc='kubectl config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"'
# Change current context
alias kcc='kubectl config use-context "$(klc | fzf -e | sed "s/^..//")"'

# Get current namespace
alias krn='kubectl config get-contexts --no-headers "$(krc)" | awk "{print \$5}" | sed "s/^$/default/"'
# List all namespaces
alias kln='kubectl get -o name ns | sed "s|^.*/|  |;\|^  $(krn)$|s/ /*/"'
# Change current namespace
alias kcn='kubectl config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'

# Run a busybox container in the cluster 
alias kbb='kubectl run busybox --image=busybox:1.28 --rm -it --command --restart=Never --'

alias kga='kubectl get all'

# kubectl explain
alias ke='kubectl explain'
complete -F _complete_alias ke


# Show information about a specific API resource
alias kr='kubectl api-resources | grep '

# Set, unset, and print the KUBECONFIG environment variable
skc() { export KUBECONFIG=$1; }
dkc() { unset KUBECONFIG; }
pkc() { echo "$KUBECONFIG"; }

# Open kubeconfig file for editing
alias kc='vim ~/.kube/config'

# Get a specific field from a kubeconfig file
# Usage examples:
#   // Get server URL of cluster "mycluster"
#   kcg clusters.mycluster.cluster.server
#   // Get entire entry of user "myuser"
#   kcg users.myuser
#   // Get entries of all users
#   kcg users
#   // Use a different kubeconfig file (default: ~/.kube/config)
#   kcg users.myuser my-kubeconfig
kcg() {
  local file=${2:-~/.kube/config}
  if [[ "$1" =~ \. ]]; then
    local list=$(cut -d . -f 1 <<<"$1")
    local name=$(cut -d . -f 2 <<<"$1")
    local field=$(cut -d . -f 3- <<<"$1")
    yq eval ".$list[] | select(.name == \"$name\") | .$field" "$file"
  else
    yq eval ".$1" "$file"
  fi
}

# Delete similarly-named context, cluster, and user entries from kubeconfig file
kc-delete() {
  kubectl config unset contexts."$1"
  kubectl config unset clusters."$1"
  kubectl config unset users."$1"
}

# Show events for a resource specified by name
kge() {
  name=$1 && shift
  kubectl get events \
    --field-selector=involvedObject.name="$name" \
    --sort-by=lastTimestamp \
    -o custom-columns='KIND:involvedObject.kind,TIME:lastTimestamp,EMITTED BY:source.component,REASON:reason,MESSAGE:message' \
    "$@"
}

# List names of Pods in current namespace
kgpn() {
  kubectl get pods --no-headers -o custom-columns=:.metadata.name
}

# Show the availability zone of each node
kaz() {
  kubectl get nodes -o custom-columns='NODE:metadata.name,ZONE:metadata.labels.failure-domain\.beta\.kubernetes\.io/zone'
}

# Show the node each pod is scheduled to
kno() {
  kubectl get pods -o custom-columns='POD:.metadata.name,NODE:.spec.nodeName' "$@"
}

# Show volume ID and availability zone of all awsElasticBlockStore volume
kpv-aws() {
  kubectl get pv -o custom-columns='PERSISTENT VOLUME:.metadata.name,VOLUME ID:.spec.awsElasticBlockStore.volumeID,AVAILABILITY ZONE:.metadata.labels.failure-domain\.beta\.kubernetes\.io/zone'
}

# Display information about the authorisation mode of the current cluster
kauthz() {
  kubectl cluster-info dump | grep authorization-mode | sed 's/^ *"//;s/",$//' ||
    kubectl api-versions | grep authorization
}

# List all (Cluster)RoleBindings with their role and subjects
kbindings() {
  local spec=NAME:metadata.name,ROLE:roleRef.name,SUBJECTS:subjects[*].name
  local preamble=KIND:kind,NAMESPACE:metadata.namespace
  [[ "$1" = -l ]] && spec=$preamble,$spec
  kubectl get rolebindings,clusterrolebindings --all-namespaces -o custom-columns="$spec"
}

kbindings2() {
  kubectl get rolebindings,clusterrolebindings \
    --all-namespaces \
    -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'
}

# Run a one-off Pod with a shell in the cluster
kru() {
  local sa=${1:-default}
  kubectl run --serviceaccount="$sa" --image=weibeld/alpine-curl --generator=run-pod/v1 -ti --rm alpine
}

# Deploy a jump Pod to the current namespace of the cluster
kjump() {
  kubectl apply -f https://bit.ly/jump-pod
}

# Create temporary ServiceAccount in default namespace with cluster-admin rights
ksa() {
  if [[ "$1" = -d ]]; then
    kubectl delete -n default sa/tmp-admin clusterrolebinding/tmp-admin
  else
    kubectl create sa -n default tmp-admin
    kubectl create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:tmp-admin tmp-admin 
  fi
}

# Test permissions of a ServiceAccount
kauthsa() {
  serviceaccount=$1
  namespace=$2
  shift 2
  kubectl auth can-i --as system:serviceaccount:$namespace:$serviceaccount "$@"
}

# Create port-forwarding to a Service
kpf() {
  service=$1
  port=$2
  shift 2
  kubectl port-forward svc/"$service" "$port" "$@"
}

# Read a field from a ConfigMap
# Usage:
#   kcm <configmap> [<key>]
# If <key> is omitted, then all keys of the ConfigMap are listed.
# TODO: support specifying namespace for ConfigMap
kcm() {
  local cm=$1
  local key=${2}
  if [[ -z "$key" ]]; then
    kubectl get cm "$cm" -o jsonpath='{.data}' | jq -r 'keys | join("\n")'
  else
    key=$(sed 's/\./\\\./' <<<"$key")
    kubectl get cm "$cm" -o jsonpath="{.data.$key}"
  fi
}

# Read and decode a field from a Secret
# Usage:
#   ksec <secret> [<key>]
# If <key> is omitted, then all keys of the Secret are listed.
# TODO: support specifying namespace for Secret
ksec() {
  local secret=$1
  local key=${2}
  if [[ -z "$key" ]]; then
    kubectl get secret "$secret" -o jsonpath='{.data}' | jq -r 'keys | join("\n")'
  else
    key=$(sed 's/\./\\\./' <<<"$key")
    local value=$(kubectl get secret "$secret" -o jsonpath="{.data.$key}")
    # In Secrets, null values may be returned as <nil> (in ConfigMaps, "")
    if [[ "$value" != '<nil>' ]]; then
      echo "$value" | base64 -d
    fi
  fi
}

# Pretty-print the annotations of the specified resources
# Usage:
#   kann <args>... [-- <regex>]
# Parameters:
#   <args>   Arguments for 'kubectl get' (e.g. 'pods' or 'pods -n foo')
#   --       Delimiter between 'kubectl get' arguments and an optional regex
#   <regex>  A regex to filter resources by name
# Usage examples:
#   kann svc                  // All Services in the current namespace
#   kann svc mysvc -n myns    // A specific Service in a specific namespace
#   kann pods -- '[0-9]$'     // All Pods whose name ends with a number
kann() {
  local args regex=.*
  splitargs args regex -- "$@"
  kubectl get "${args[@]}" -o json | jq -r '
    if .items then
      .items[]
    else
      .
    end
    | .metadata
    | if (.name | test("'"$regex"'")) then
        "'$(c yellow+ b)'\(.name)'$(c)'",
        if .annotations then
          .annotations | to_entries[] | "  '$(c b)'\(.key)'$(c)'\n    \(.value)"
        else
          "  '$(c d)'<none>'$(c)'"
        end
      else
        empty
      end'
}

# Pretty-print the labels of the specified resources
# Usage:
#   klab <args>... [-- <regex>]
# Parameters:
#   <args>   Arguments for 'kubectl get' (e.g. 'pods' or 'pods -n foo')
#   --       Delimiter between 'kubectl get' arguments and an optional regex
#   <regex>  A regex to filter resources by name
# Usage examples:
#   klab svc                  // All Services in the current namespace
#   klab svc mysvc -n myns    // A specific Service in a specific namespace
#   klab pods -- '[0-9]$'     // All Pods whose name ends with a number
# TODO: fix output when there is only a single (or no) label
klab() {
  local args regex=.*
  splitargs args regex -- "$@"
  kubectl get "${args[@]}" --no-headers -o custom-columns=':metadata.name,:metadata.labels' \
    | awk "\$1~/$regex/" \
    | sed 's/map\[//;s/\]//' \
    | tr -s ' ' \
    | tr ' ' '\n' \
    | sed '/:/s/^/  /' \
    | awk -F : '!/^ / {print "'$(c b)'"$0"'$(c)'"} /^ / {print "'$(c)'"$1":'$(c)'"$2"'$(c)'"}' \
    | column -s : -t 
    # Fill space between name and value with dots. Note that this prevents
    # selection of name or value by double-clicking in iTerm2.
    #| sed '/^[^a-z0-9]/s/ /\./g;/^[^a-z0-9]/s/^\([^\.]*\)\.\.\([^\.]*\)/\1  \2/'
}


# List resources whose name matches a regex.
# Usage:
#   kget <args>... <regex>
# Parameters:
#   <args>   Arguments for 'kubectl get'
#   <regex>  Regex to match against resource names
kget() {
  local args=(${@:1:$#-1})
  local regex=${@:$#}
  local field=1
  # With --all-namespaces, the resource name is in the second field
  array-contains "${args[@]}" --all-namespaces && field=2 
  kubectl get "${args[@]}" --no-headers | awk "\$$field~/$regex/"
}

# Print container images of specified pods.
# Usage:
#   kim [<pods>] [-- [-c]]
# Args:
#   <pods>: Arguments for 'kubectl get pods', e.g. '--all-namespaces'
#   -c:     Print the output as a CSV file (default is table)
# Example:
#   kim -n kube-system -- -c
# TODO:
#   - Include init containers in the output?
kim() {
  local args1 args2
  splitargs args1 args2 -- "$@"
  local out=$(kubectl get pods "${args1[@]}" --no-headers -o custom-columns=':metadata.namespace,:metadata.name,:spec.containers[*].image' | tr -s ' ' | tr ' ' ,)
  [[ -z "$out" ]] && { echo "No pods found"; return; }
  # Make first two columns bold, if stdout is terminal or pipe (i.e. not file)
  if [[ ! -f /dev/stdout ]]; then
    out=$(echo "$out" | sed "s/^\([^,]*,[^,]*\)/\1$(c)/;s/^\([^,]*,\)/\1$(c b)/;s/^\([^,]*\)/\1$(c)/;s/^/$(c b)/")
  fi
  # Remove first column, if pods are only from single namespace
  if [[ ! "${args1[@]}" =~ --all-namespaces|-A ]]; then
    out=$(echo "$out" | sed 's/^[^,]*,//')
  fi
  # Format output as table, if -c is not specified
  if [[ ! "${args2[@]}" =~ -c ]]; then
    out=$(echo "$out" | column -t -s ,)
  fi
  echo "$out"
}

# Get the number of containers or init containers in the specified Pods
# Usage:
#   kcon <kubectl_args>... [-- <args>]
# Args:
#   <kubectl_args>  Arguments for 'kubectl get pods'
#   <args>          Arguments for command (currently, only 'init' is supported)
# Examples:
#   kcon                   # Number of containers of Pods in current namespace
#   kcon --all-namespaces  # Number of containers of Pods across all namespaces
#   kcon -n foo            # Number of containers of Pods in namespace 'foo'
#   kcon -n foo -- init    # Number of init containers instead of normal containers
kcon() {
  local kubectl_args args
  splitargs kubectl_args args -- "$@"
  [[ "$args" = init ]] && c=initContainers || c=containers
  kubectl get pods "${kubectl_args[@]}" -o json | jq -r "[.items[].spec.$c | length] | add"
}

# List the conditions of all the nodes
# Note: requires GNU sed as gsed
kncond() {
  for n in $(kubectl get nodes -o name | cut -d / -f 2); do
    echo "$(c b)$n$(c)";
    command kubectl describe node "$n" \
      | gsed -n '/Conditions:/{:a;N;/Addresses:/!ba;p}' \
      | sed '1d;$d';
  done
}

# Find resources that match a regex in their YAML definition
# Usage:
#   kf  <kubectl_args>... <regex> [ -- <grep_args>... ]
# Args:
#   <kubectl_args> Args as supplied to 'kubectl get' (e.g. 'pods' '-n' 'foo')
#   <regex>        Regex as supplied to grep (e.g. 'name: foo-[xyz].*')
#   <grep_args>    Args as supplied to grep (e.g. '-A2')
# Examples:
#   # Find all CronJobs in the cluster that have an imagePullPolicy field
#   kf cronjobs --all-namespaces ' imagePullPolicy:'
#   # Find all Pods in the 'foo' namespace that have an imagePullSecrets field
#   kf pods -n foo ' imagePullSecrets:'
#   # As above, but also print one line after each matching line (grep option)
#   kf pods -n foo ' imagePullSecrets:' -- -A1
# Notes:
# - Only line-based matching is supported, i.e. regexes spanning multiple
#   lines are not supported.
kf() {
  local kubectl_args grep_args regex
  if array-contains "$@" --; then
    local tmp
    splitargs tmp grep_args -- "$@"
    # Overwrite $@ with args before '--'
    set -- "${tmp[@]}"
  fi
  kubectl_args=("${@:1:$#-1}")
  regex="${@:$#}"
  local line
  kubectl get "${kubectl_args[@]}" -o custom-columns=:.metadata.namespace,:.kind,:.metadata.name --no-headers | while read line; do
    local namespace=$(awk '{print $1}' <<<"$line")
    local kind=$(awk '{print tolower($2)}' <<<"$line")
    local name=$(awk '{print $3}' <<<"$line")
    local result
    if result=$(kubectl get "$kind" "$name" -n "$namespace" -o yaml | grep -n --color=always "${grep_args[@]}" "$regex"); then
      resource="$kind/$name"
      array-contains "${kubectl_args[@]}" --all-namespaces && resource="$namespace/$resource"
      echo "$(c b)$resource$(c)"
      echo "$result" | sed 's/^/  /'
    fi
  done
}

# Print all the volumes of a Pod in the current namespace
# Usage:
#   kvol <pod>
# Notes:
# - Only a few selected volume types are currently supported (see below). For
#   other volume types, emptyDir is assumed. This is because emptyDir is the
#   only volume type where the volume type field can either be omitted or empty
#   (it can be omitted because emptyDir is the default volume type and it can
#   be empty because there are no mandatory settings required for emptyDir).
#   For example, the following is a valid emptyDir volume specification:
#     - name: foo
#   As is the following:
#     - name: foo
#       emptyDir: {}
#   The easiest way to handle this in Go templates is to assume emptyDir when
#   the volume can't be recognised as any other type. That's because it's not
#   possible to create an 'if' condition yielding true for a missing map field
#   (the first case) or for a map field with an empty value (the second case).
#   The caveat of this is that volume types which are currently not supported
#   would be displayed as emptyDir.
# - Currently supported volume types: configMap, secret, persistentVolumeclaim,
#   hostPath, emptyDir
# - See all existing volume types in [1]
# [1] https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#volume-v1-core
# TODO:
# - Allow specifying multiple Pods
# - Sort the volumes according to volume type and name
kvol() {
  local pod=$1
  shift
  kubectl get pod "$pod" "$@" -o go-template='
    {{- range .spec.volumes }}
      {{- if .configMap }}{{ printf "ConfigMap: %s\n  ConfigMap: %s\n" .name .configMap.name }}
      {{- else if .secret }}{{ printf "Secret: %s\n  Secret: %s\n" .name .secret.secretName }}
      {{- else if .persistentVolumeClaim }}{{ printf "PVC: %s\n  PVC: %s\n" .name .persistentVolumeClaim.claimName }}
      {{- else if .hostPath }}{{ printf "HostPath: %s\n  Path: %s\n" .name .hostPath.path }}
      {{- else if .emptyDir }}{{ printf "EmptyDir: %s\n" .name }}
      {{- else }}{{ printf "EmptyDir: %s\n" .name }}{{ end }}
    {{- end }}' \
    | sed -E 's/^([^ ].*)/'$(c b)'\1'$(c)'/'
} 

# kubectl-aliases (https://github.com/ahmetb/kubectl-aliases)
if [[ -f ~/.kubectl_aliases ]]; then
  source ~/.kubectl_aliases
  # Enable completion for aliases (depends on complete-alias)
  for _a in $(sed '/^alias /!d;s/^alias //;s/=.*$//' ~/.kubectl_aliases); do
    complete -F _complete_alias "$_a"
  done
fi


# https://github.com/kubermatic/fubectl
#[ -f ~/.fubectl ] && source ~/.fubectl

alias k9s='k9s --readonly'

#------------------------------------------------------------------------------#
# Google Cloud Platform (GCP)
#------------------------------------------------------------------------------#

# SSH into a GCP compute instance.
gssh() {
  # Prevents "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"
  ssh-keygen -R "${1##*@}"
  ssh -i ~/.ssh/google_compute_engine -o StrictHostKeyChecking=no "$@"
}

alias gcil='gcloud compute instances list'

#------------------------------------------------------------------------------#
# Prometheus
#------------------------------------------------------------------------------#

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

#------------------------------------------------------------------------------#
# Terraform
#------------------------------------------------------------------------------#

# Terraform autocompletion (installed with terraform --install-autocomplete)
complete -C /usr/local/bin/terraform terraform

alias tf=terraform
#complete -F _complete_alias t

alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfay='terraform apply --auto-approve'
alias tfdy='terraform destroy --auto-approve'

#------------------------------------------------------------------------------#
# macOS and Linux specific functions
#------------------------------------------------------------------------------#
if is-mac; then

  # Recursively delete all .DS_Store files in the current directory
  alias rmds='find . -type f \( -name .DS_Store -or -name ._.DS_Store \) -delete'

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

  # Copy the content of the supplied file to the clipboard
  clip() {
    cat "$1" | pbcopy
  }

elif is-linux; then

  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

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

# Authenticate with SSH key
alias ssh-nine='ssh -i ~/.ssh/nine weibeld@weibeld.nine.ch'
# Authenticate with LDAP password and OTP from Google Authenticator
alias ssh-nine-login-server='ssh weibeld@login.nine.ch'

pw() {
  if ! which -s aws; then
    echo "You must install the AWS CLI to use this command"
    return 1
  fi
  LENGTH=${1:-32}
  aws secretsmanager get-random-password --exclude-punctuation --password-length "$LENGTH" --query RandomPassword --output text
}

anker() { ssh wk08@anker.inf.unibe.ch; }
#boyle() { torsocks ssh charles@63alsiqho43t37nfoavp3bctz55bjf4bmcicdt2qtmet6cmufx2juzqd.onion -p 30022; }
boyle() { ssh charles@130.92.63.21; }

delete-31-august() { ssh -i ~/.ssh/id_rsa root@74.220.21.72; }
delete-31-august-tmp() { ssh -i ~/.ssh/id_rsa root@74.220.23.205; }

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/__tabtab.bash ] && . ~/.config/tabtab/__tabtab.bash || true

change_mac() {
  local mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g;s/.$//')
  sudo ifconfig en0 ether "$mac"
  echo "Changed MAC address of en0 device to $mac"
}

# JMESPath Terminal
# https://github.com/jmespath/jmespath.terminal
jpterm() {
  python /Users/dw/Library/Python/2.7/lib/python/site-packages/jpterm.py
}

# Split a GIF file into its individual frames. Each frame is saved as an
# individual GIF file in a directory named after the input file.
# Usage:
#   gif-split <file.gif>
# Notes:
#   - Requires gifsicle [1]. Install with 'brew install gifsicle'.
# [1] https://www.lcdf.org/gifsicle/
gif-split() {
  ensure gifsicle
  local name=${1%.gif}
  local dir=$name.gif.split
  mkdir "$dir"
  gifsicle --unoptimize --explode --output "$dir/$name" "$1"
  # Rename files from '<name>.<i>' to '<name>.<i+1>.gif'. The increment by 1
  # is because gifsicle labels the frames starting from 0 rather than 1.
  for f in "$dir"/*; do
    local i=${f##*.}
    mv "$f" "${f%.*}.$(pad "${#i}" $(bc <<<"$i+1")).gif"
  done
  echo "$(($(ls "$dir" | wc -l))) frames saved in $dir"
}

# Trim a GIF file from a given start frame number to a given end frame number.
# The counting of the frame numbers starts at 1.
# Usage:
#   gif-trim <file.gif> <start> <end>
gif-trim() {
  ensure gifsicle
  gifsicle --unoptimize "$1" "#$(("$2"-1))-$(("$3"-1))" -O2 -o "${1%.gif}"-trimmed.gif
}

#------------------------------------------------------------------------------#
# Ensure exit code 0 for the command that sources this file
#------------------------------------------------------------------------------#

return 0
