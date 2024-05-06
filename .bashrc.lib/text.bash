#------------------------------------------------------------------------------#
#= Text processing
#------------------------------------------------------------------------------#

# Transform the input to upper-case
# Usage:
#   _to-upper-case [<args>...]
# If no arguments are provided, the input is read from stdin.
_to-upper-case() {
  _get-input "$@" |
  tr '[:lower:]' '[:upper:]'
}

# Transform the input to lower-case
# Usage:
#   _to-lower-case [<args>...]
# If no arguments are provided, the input is read from stdin.
_to-lower-case() {
  _get-input "$@" |
  tr '[:upper:]' '[:lower:]'
}

# Transform the input to title-case (first letter of each word capitalised).
# Usage:
#   _to-title-case [<args>...]
# If no arguments are provided, the input is read from stdin.
_to-title-case() {
  _get-input "$@" |
  awk '{
    for (i=1; i<=NF; i++) {
      $i = toupper(substr($i,1,1)) substr($i,2)
    }
  }
  { print }'
}

# Transform the input to kebab-case (lower-case joined by dashes)
# Usage:
#   _to-kebab-case [<args>...]
# If no arguments are provided, the input is read from stdin.
# Notes:
#   - This implementation of kebab-case involves the following:
#     1. All characters are transformed to lower-case
#     2. Punctuation characters (except '-') are deleted
#     3. Whitespace characters are replaced by dashes 
#     4. Repeated dashes replaced with a single dash
#     5. Dashes at the beginning and end of strings are omitted
_to-kebab-case() {
  _get-input "$@" |
  tr '[:upper:]' '[:lower:]' |
  tr - ' ' |
  sed 's/[[:punct:]]//g;s/[[:space:]]/-/g' |
  tr -s - |
  sed 's/^-//;s/-$//'
}

# Pad a list of strings up to a desired total length.
# Usage:
#   _pad-left <length> <char> [<args>...]
#   _pad-right <length> <char> [<args>...]
# Example:
#   _pad-left 3 ' ' $(seq 100)
#   _pad-right 8 - red green blue yellow cyan
# In the first of the above examples, the numbers 1 to 100 are padded to the
# left with spaces to a total of 3 digits. In the second examples, the strings
# are padded to the right with dashes to a total width of 8 characters
# Notes:
#   - If no arguments are given beyond <length> and <char>, the strings to pad
#     are read from stdin.
#   - If a string to pad is longer than <length>, it is printed unchanged.
_pad-left() {
  if [[ "$#" -lt 2 ]]; then
    _print-usage-msg "<length> <char> [<args>...]"
    return 1
  fi
  __pad l "$1" "$2" $(shift 2 && _get-input "$@")
}
_pad-right() {
  if [[ "$#" -lt 2 ]]; then
    _print-usage-msg "<length> <char> [<args>...]"
    return 1
  fi
  __pad r "$1" "$2" $(shift 2 && _get-input "$@")
}
__pad() {
  local direction=$1
  local length=$2
  local char=$3
  shift 3
  for e in "$@"; do
    local fill_length=$(("$length"-"${#e}"))
    [[ "$fill_length" -lt 0 ]] && fill_length=0
    local fill=$(printf '%*s' "$fill_length" | tr ' ' "$char")
    case "$direction" in
      l) echo "$fill$e" ;;
      r) echo "$e$fill" ;;
    esac
  done
}

# Prepend line numbers to each line of input
# Usage:
#   _add-line-numbers [-s <sep>] [-u <suffix>] [-r]
# Args:
#   -s <sep>:    separator between line number and input line (default: ' ')
#   -u <suffix>: string to append to each line number (default: '')
#   -r:          right-align line numbers (default: left-align)
_add-line-numbers() {
  # Capture input
  local -r data=$(</dev/stdin)
  local -ir n=$(wc -l <<<"$data")
  # Parse arguments
  local sep=' ' suffix
  local expect_s expect_u align=ln
  for a in "$@"; do
    case "$a" in
      -s) expect_s=1 ;;
      -u) expect_u=1 ;;
      -r) align=rn ;;
      *)
        if _is-set "$expect_s"; then
          sep=$a
          expect_s=
        elif _is-set "$expect_u"; then
          suffix=$a
          expect_u=
        else
          _err "Invalid argument: $a"
          return 1
        fi
    esac
  done
  echo "$data" | nl -s "$sep" -n "$align" -w "$(($(_log10 "$n" -i)+1))" | sed "s/^([ ]*[0-9]+)/\1$suffix/"
}

# Read text from stdin and format it to width of terminal with word wrapping.
# This function is similar to the 'fmt' command, but it preserves all newlines.
# Notes:
#   - awk adds nroff commands to beginning of input (.pl = page length,
#     .ll = line length, .na=disable justification, hy 0 = disable hyphenation)
#   - nroff formats the text
#   - sed reverts the conversion of - to U+2010 (UTF-8 0xE28090) done by nroff
# See https://docstore.mik.ua/orelly/unix3/upt/ch21_03.htm
_wrap() {
  awk -v c=$(tput cols) '
    BEGIN {printf ".pl 1\n.ll %d\n.na\n.hy 0\n", c}
    {print}' |
    nroff |
    sed 's/\xE2\x80\x90/-/g'
}

# Truncate a specific column of a table to a given maximum length
# Usage:
#   _truncate-column <sep> <column> <length> [<mark>]
# Args:
#   <sep>:     column separator regex
#   <column>:  index of column to truncate (indices starting at 1)
#   <length>:  maximum length of column (including truncation mark)
#   [<mark>]:  truncation mark (default: '[...]')
# Description:
#   Reads a table from stdin, truncates the specified column to the given
#   maximum length, and writes the output to stdout.
# Notes:
#   - If an invalid column index is specified, the input table is printed
#     unchanged.
_truncate-column() {
    local -r sep=$1 mark=${4:-[...]}
    local -ir column=$2 length=$3 
    awk -F "$sep" -v COL="$column" -v LEN="$length" -v MARK="$mark" '
      BEGIN {
        OFS = FS
      }
      {
        if (COL >= 1 && COL <= NF) {
          if (length($COL) > LEN)
            $COL = substr($COL, 1, LEN - length(MARK)) MARK
        }
        print $0
      }'
}

# Insert string ($2) into filename ($1), just before filename extension.
# Add a suffix to a file basename, just before the extension
# Usage:
#   _insert-basename-suffix <suffix> <file>
# Example:
#   _insert-basename-suffix -foo test.txt  ==>  test-foo.txt
_insert-basename-suffix() {
  local suffix=$1
  local file=$2
  #echo "${file/%.+([^.])/$suffix&}"  # TODO: replace below with this (requires shopt options patsub_replacement for & and extglob for +())
  echo "${file%.*}${suffix}.${file##*.}"
}

# Change the extension of a file name.
# Usage:
#   _change-filename-extension <file> <extension>
# Example:
#   _change-filename-extension test.txt md  ==>  test.md
_change-filename-extension() {
  echo "${1%.*}.$2"
}
