#==============================================================================#
# Util
# Description:
#   Miscellaneous utility aliases and functions.
#==============================================================================#

# May also contain shortcuts, i.e. wrappers around library functions with 
# user-friendly names

alias rmf='rm -rf'
alias la="ls -a"
alias ll="ls -al"
alias wl='wc -l'
alias x='chmod +x'
alias X='chmod -x'
alias dh='du -h'
alias which='which -a'
alias curl='curl -s'
alias sed='sed -E'
alias gsed='gsed -E'
alias pgrep='pgrep -fl'
alias watch='watch -n 1'
alias diff='diff --color'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias minicom='minicom -c on'

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

# TODO: move to library?

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
  _array-has c 30 && printf "\e[47;30mBlack (30):\e[49m          \e[040m   \e[49m  \e[47mNormal\e[49m  \e[47;1mBold\e[0m\n"
  _array-has c 90 && printf "\e[90mBright black (90):   \e[100m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 31 && printf "\e[31mRed (31):            \e[041m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 91 && printf "\e[91mBright red (91):     \e[101m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 32 && printf "\e[32mGreen (32):          \e[042m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 92 && printf "\e[92mBright green (92):   \e[102m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 33 && printf "\e[33mYellow (33):         \e[043m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 93 && printf "\e[93mBright yellow (93):  \e[103m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 34 && printf "\e[34mBlue (34):           \e[044m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 94 && printf "\e[94mBright blue (94):    \e[104m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 35 && printf "\e[35mMagenta (35):        \e[045m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 95 && printf "\e[95mBright magenta (95): \e[105m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 36 && printf "\e[36mCyan (36):           \e[046m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 96 && printf "\e[96mBright cyan (96):    \e[106m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 37 && printf "\e[37mWhite (37):          \e[047m   \e[49m  Normal  \e[1mBold\e[0m\n"
  _array-has c 97 && printf "\e[97mBright white (97):   \e[107m   \e[49m  Normal  \e[1mBold\e[0m\n"
  return 0
}


# TODO: move to library?

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
