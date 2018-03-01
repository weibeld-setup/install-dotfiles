# ~/.bashrc: sourced by non-login shells
#
# Login vs. non-login shells:
#
# - Login shell: created when starting a new terminal window/tab (or tmux
#   window/pane).
#       - Sources: 1) /etc/profile, 2) ~/.bash_profile
# - Non-login shell: created when starting a shell from within a shell.
#       - Sources: 1) ~/.bashrc
#
# Note that a non-login shell does not source ~/.bash_profile, and a login
# shell does not source ~/.bashrc.
#
# ------------
# 
# FAQ:
#
# Q: Why are the functions in ~/.bashrc?
# A: Because we want them also in sub-shells of the current shell, e.g. if we
#    start a new shell by typing "bash". In this case, only ~/.bashrc gets
#    sourced, but not ~/.bash_profile. That means, the functions would not be
#    available in the sub-shell if they were defined in ~/.bash_profile.
#
# Q: But then, why can we set variables in ~/.bash_profile, if ~/.bash_profile
#    does not get sourced in a sub-shell?
# A: Because all variables that we set in ~/.bash_profile are "exported", and 
#    thus automatically available in sub-shells. Thanks to the "exports", there
#    is no need to source ~/.bash_profile in a sub-shell.
#
# Q: Does PATH need to be "exported"?
# A: Yes, but this is already done by /etc/profile, when PATH is set to its
#    default values. There is no need to export PATH at any other place.
#
# Daniel Weibel <daniel@weibeld.net> May 2015 - February 2018
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# Dotfiles repository (https://github.com/weibeld/dotfiles)
#------------------------------------------------------------------------------#
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'


#------------------------------------------------------------------------------#
# Shell options
#------------------------------------------------------------------------------#
shopt -s extglob
shopt -s nullglob


#------------------------------------------------------------------------------#
# System command shortcuts
#------------------------------------------------------------------------------#
alias br='vim ~/.bashrc'
alias bp='vim ~/.bash_profile'
alias sbr='. ~/.bashrc'
alias sbp='. ~/.bash_profile'
alias l='ls'
alias la="ls -a"
alias ll="ls -al"
alias rmf='rm -rf'
alias wl='wc -l'
alias dh='du -h'


#------------------------------------------------------------------------------#
# System command default options
#------------------------------------------------------------------------------#
alias ssh='TERM=xterm-256color ssh'
alias pgrep='pgrep -fl'


#------------------------------------------------------------------------------#
# Application shortcuts
#------------------------------------------------------------------------------#
alias g='./gradlew'
alias hk=heroku
alias gphm='git push heroku master'
alias hkp='git add -A && git commit --allow-empty -m "Commit" && git push heroku master'
alias jki="bundle exec jekyll serve --incremental"
alias jk="bundle exec jekyll serve"
alias dk=docker
alias dkc=docker-compose
alias dkm=docker-machine


#------------------------------------------------------------------------------#
# Base functions (used by other functions in this ~/.bashrc)
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


#------------------------------------------------------------------------------#
# Files
#------------------------------------------------------------------------------#

# Add/remove executable flag to/from a file
x() { chmod +x "$1"; }
X() { chmod -x "$1"; }

# Change to directory and list content
c() { cd "$1" && ls; }

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
# Terminal/Shell
#------------------------------------------------------------------------------#

# Display $PATH with each entry on its own line
path() { echo "$PATH" | tr : '\n'; }

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


#------------------------------------------------------------------------------#
# Document processing (mainly PDF)
#------------------------------------------------------------------------------#

# Pandoc wrapper using the (customised) LaTeX template of R Markdown
# USAGE: md2pdf in_file out_file [pandoc_args...]
pand() {
  local tmpl=~/.pandoc_latex_template.tex
  local in_file=$1
  local out_file=$2
  shift 2
  pandoc "$in_file" \
         -o "$out_file" \
         --template="$tmpl" \
         --highlight-style=tango \
         $@
}

# Convert Pandoc markdown to PDF using the R Markdown LaTeX template
# USAGE: md2pdf in_file [pandoc_args...]
md2pdf() {
  local in_file=$1
  local out_file=${1%.*}.pdf
  shift 1
  pand "$in_file" "$out_file" $@ &&
  echo "$out_file"
}

md2html() {
  pandoc -i "$1" -o "${1%.*}.html"
}

# Convert a man page to PDF
man2pdf() {
  man -t "$1" | ps2pdf - "$1".pdf
  echo "$1".pdf
}

# Convert an EPUB file to PDF for reading on screen (requires Calibre)
epub2pdf() {
  ensure ebook-convert || return 1
  in=$1             # Input file (.epub)
  out=$2            # Output file (.pdf)
  fontsize=${3:-8}  # Base font size in pt
  mrg_l=${4:-40}    # Margins in pt ...
  mrg_t=${5:-30}
  mrg_r=${6:-40}
  mrg_b=${7:-40}
  # See all options for EPUB -> PDF: ebook-convert in.epub out.pdf -h
  ebook-convert "$in" "$out" --paper-size=a4 --pretty-print --pdf-page-number \
    --unit=centimeter --base-font-size="$fontsize" --margin-left="$mrg_l" \
    --margin-top="$mrg_t" --margin-right="$mrg_r" --margin-bottom="$mrg_b"
}

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
# Tmux
#------------------------------------------------------------------------------#

# Create a new tmux pane initialised to the the current working directory.
tmux-split-window-same-dir() {
  tmux split-window $1
  tmux send-keys "cd $PWD; clear" Enter
}

# Create a new tmux window initialised to the current working directory.
tmux-new-window-same-dir() {
  tmux new-window
  tmux send-keys "cd $PWD; clear" Enter
}


#------------------------------------------------------------------------------#
# Git
#------------------------------------------------------------------------------#

alias gl='git log --decorate --graph' 
alias gr='git remote -v'
alias gst='git status -u'
alias ga='git add -A'
alias gc='git commit'
alias gce='git commit --allow-empty'
alias gcee='git commit --allow-empty -m "Empty commit"'
alias gp='git push'
alias gf="git flow"

# List all the Git objects in the Git repo in $1 with their type. If $2 is set,
# then they type is not printed, only the ID.
git-ls() {
  root=${1:-.}
  root=${root%/}
  short=$2
  for d in "$root"/.git/objects/!(pack|info); do
    for f in "$d"/*; do
      id=$(basename $d)$(basename $f)
      echo -n "$id "
      is-set "$short" && echo || git cat-file -t "$id"
    done
  done
}

# Count the number of Git objects split up by their type.
git-stat() {
  root=${1:-.}
  root=${root%/}
  git-ls "$root" |
    awk '
      BEGIN    {blobs=0; trees=0; commits=0; tags=0}
      /blob/   {blobs++}
      /tree/   {trees++}
      /commit/ {commits++}
      /tag/    {tags++}
      END      {print "Blobs:", blobs
                print "Trees:", trees
                print "Commits:", commits
                print "Tags:", tags}'
}

# Reads IDs from stdin and prints out the corresponding Git objects.
git-cat() {
  while read id; do
    echo -e "\n--------------------\n"
    git cat-file -p "$id"
  done < /dev/stdin
}


#------------------------------------------------------------------------------#
# Configure prompt
#------------------------------------------------------------------------------#
s ~/.bash_prompt


#------------------------------------------------------------------------------#
# Mac and Linux specific functions, aliases, and settings
#------------------------------------------------------------------------------#
if is-mac; then
  s ~/.bash_mac
elif is-linux; then
  s ~/.bash_linux
fi


#------------------------------------------------------------------------------#
# Temporary functions and settings (not included in dotfiles repo)
#------------------------------------------------------------------------------#
s ~/.bashrc_trash


#------------------------------------------------------------------------------#
# Ensure exit code of the command sourcing this ~/.bashrc is 0
#------------------------------------------------------------------------------#
return 0
