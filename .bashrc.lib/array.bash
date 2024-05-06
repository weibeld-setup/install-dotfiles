# Array processing (indexed arrays only)

# TODO: complete argument checks for all functions:
#   - type of arguments
#   - number or arguments

# Check whether an indexed array is empty
# Usage:
#   _array-is-empty <name>
# Args:
#   <name>: the name of the array to check
# Notes:
#   - The array must exist. If the array doesn't exist, or is not an indexed
#     array, an error is returned.
_array-is-empty() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_is_empty__in=$1
  [[ "${#__array_is_empty__in[@]}" -eq 0 ]]
}

# Get the size of an indexed array
# Usage:
#   _array-size <name>
# Args:
#   <name>: the name of the array whose size to determine
_array-size() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_size__in=$1
  echo "${#__array_size__in[@]}"
}

# Get the index of the last element of an indexed array
# Usage:
#   _array-end <name>
# Args:
#   <name>: the name of the array
# Notes:
#   - If the array is empty, then an empty string is returned
_array-end() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_last_index__in=$1
  if ! _array-is-empty __array_last_index__in; then
    echo "$(($(_array-size __array_last_index__in)-1))"
  fi
}

# Check whether an indexed array contains an element matching a pattern
# Usage:
#   _array-has <name> <pat>
# Args:
#   <name>: name of the array
#   <pat>:  regex pattern 
# Notes:
#   - The value of <pat> may be any valid regex. The regex is automatically
#     anchored with ^ and $ at the beginning and the end, respectively.
#   - The function returns true if the array contains at least one element
#     matching the pattern in <pat>
_array-has() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_has__array=$1
  local __pat=$2
  local __elt
  for __elt in "${__array_has__array[@]}"; do
    # Regex must not be quoted
    if [[ "$__elt" =~ ^$__pat$ ]]; then
      return
    fi
  done
  return 1
}

# TODO: add option to print indices
# List the elements of an indexed array
# Usage:
#   _array-ls <name> [<delim>]
# Args:
#   <name>:    name of the array
#   [<delim>]: delimiter to separate array elements (default: $'\n')
# Notes:
#   - By default, array elements are separated by a newline
#   - The delimiter can be customised to be an arbitrary string
#   - The delimiter may include ANSI-C quoted strings ($'...'), such as $'\n'
#     for a newline, $'\t' for a tab, etc. (see [1]).
# References:
#   [1] https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html
_array-ls() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_ls__in=$1
  local __delim=${2:-$'\n'}
  _array-is-empty __array_ls__in && return
  local __out=${__array_ls__in[0]}
  local __elt
  for __elt in "${__array_ls__in[@]:1}"; do
    __out+=$__delim$__elt
  done
  echo "$__out"
}

# Create a copy of an indexed array
# Usage:
#   _array-cp <in-name> <out-name>
# Args:
#   <in-name>:  name of the array to copy
#   <out-name>: name of the copy to create
# Notes:
#   - If <out-name> doesn't exist, it is created, if it already exists, it is
#     overwritten
_array-cp() {
  _ensure-indexed-array "$1" || return 1
  _ensure-variable "$1" || return 1
  _ensure-var-name "$2" || return 1
  local -n __array_cp__in=$1
  local -n __array_cp__out=$2
  # Works with newlines in array elements and with changed IFS
  __array_cp__out=("${__array_cp__in[@]}")
}

# Reverse the elements of an indexed array
# Usage:
#   _array-rev <in-name> <out-name>
# Args:
#   <in-name>:  name of the array to reverse
#   <out-name>: name of the array to save the result to
# Notes:
#   - If <out-name> is already assigned to a variable, it is overwritten
#   - To perform the operation in-place on the input array, use the same array
#     for both <in-name> and <out-name>
_array-rev() {
  _ensure-indexed-array "$1" || return 1
  _ensure-var-name "$1" && _ensure-array "$1" || return 1
  _ensure-var-name "$2" || return 1
  local -n __array_rev__in=$1
  local -n __array_rev__out=$2
  if _array-is-empty __array_rev__in; then
    __array_rev__out=()
  else
    local __i
    local -a __array_rev__tmp
    for __i in $(seq -1 "-$(_array-size __array_rev__in)"); do
      __array_rev__tmp+=(${__array_rev__in[$__i]})
    done
    _array-cp __array_rev__tmp __array_rev__out
  fi
}

# Delete elements matching one or more patterns from an indexed array
# Usage:
#   _array-rm <in-name> <out-name> <pat>...
# Args:
#   <in-name>:  name of the input array
#   <out-name>: name of the output array in which to save the result
#   <pat>:      regex pattern to match against the array elements
# Notes:
#   - The value of <pat> may be any valid regex. The regex is automatically
#     anchored with ^ and $ at the beginning and end, respectively.
#   - A single <pat> may match, and thus delete, multiple array elements
#   - If <out-name> doesn't exist, it is created, if it already exists, it is
#     overwritten
#   - Use the same array name for both <in-name> and <out-name> to perform the
#     operation in-place on the input array
# Examples:
#   Delete all elements starting with an upper or lower-case F:
#     _array-rm a b '[Ff].*'
#   Delete all elements with the value 'foo' or 'bar':
#     _array-rm a b foo bar
_array-rm() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_rm__in=$1 
  local -n __array_rm__out=$2
  # Working copy of input array (will be mutated)
  local -a __array_rm__in_copy
  _array-cp __array_rm__in __array_rm__in_copy
  local __pat
  for __pat in "${@:3}"; do
    local __i
    for __i in ${!__array_rm__in_copy[@]}; do
      # Regex must not be quoted
      if [[ "${__array_rm__in_copy[$__i]}" =~ ^${__pat}$ ]]; then
        unset "__array_rm__in_copy[$__i]"
      fi
    done
  done
  _array-cp __array_rm__in_copy __array_rm__out
}

# Delete elements at one or more indices from an indexed array
# Usage:
#   _array-rmi <in-name> <out-name> <index>...
# Args:
#   <in-name>:  name of the input array
#   <out-name>: name of the output array in which to save the result
#   <index>:    index of an element to delete
# Notes:
#   - Repeated, invalid, and non-existing items in the index list are ignored.
#     For example,
#       _array-rmi in out 0 0 0 foo 1000 0
#     The above results only in the removal of index 0 (assuming that the input
#     array has less than 1001 elements).
#   - Negative indices may be used, which resolve to an index relative to the
#     end of the array: -1 translates to the last array element, -2 to the
#     second-last, and so on, until -n which translates to the first array
#     element (if n is the size of the array). If the translated negative index
#     is out of the bounds of the array, then it is ignored.
#   - The indices of the elements in the output array are updated to be
#     consecutive starting from 0
#   - If <out-name> doesn't exist, it is created, if it already exists, it is
#     overwritten
#   - Use the same array name for both <in-name> and <out-name> to perform the
#     operation in-place on the input array
_array-rmi() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_rmi__in=$1 
  local -n __array_rmi__out=$2
  local __array_rmi__in_size=$(_array-size __array_rmi__in)
  # Working copy of input array (will be mutated)
  local -a __array_rmi__in_copy
  _array-cp __array_rmi__in __array_rmi__in_copy
  local __i 
  for __i in "${@:3}"; do
    # Normal indices
    if [[ "$__i" =~ ^[0-9]+$ ]]; then
      unset "__array_rmi__in_copy[$__i]"
    # Negative indices (relative to end of array): convert to absolute indices
    elif [[ "$__i" =~ ^-[0-9]+$ ]]; then
      __i=$((__array_rmi__in_size + __i))
      if [[ "$__i" -ge 0 ]]; then
        unset "__array_rmi__in_copy[$__i]"
      fi
    fi
  done
  _array-cp __array_rmi__in_copy __array_rmi__out
}

# Delete duplicate elements from an indexed array
# Usage:
#   _array-uniq <in-name> <out-name>
# Args:
#   <in-name>:  name of the input array
#   <out-name>: name of the output array in which to save the result
# Notes:
#   - If a duplicate element is detected, the first occurrence of this element
#     is kept and all other occurrences are deleted
#   - If <out-name> doesn't exist, it is created, if it already exists, it is
#     overwritten
#   - Use the same array name for both <in-name> and <out-name> to perform the
#     operation in-place on the input array
_array-uniq() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_uniq__in=$1 
  local -n __array_uniq__out=$2
  local -a __array_uniq__tmp
  local __elt
  for __elt in "${__array_uniq__in[@]}"; do
    if ! _array-has __array_uniq__tmp "$__elt"; then
      __array_uniq__tmp+=("$__elt")
    fi
  done
  _array-cp __array_uniq__tmp __array_uniq__out
}

# Insert a new element at the specified index in an indexed array
# Usage:
#   _array-insert <in-name> <out-name> <elt> <index>
# Args:
#   <in-name>:  name of the input array
#   <out-name>: name of the output array in which to save the result
#   <elt>:      value to insert into the array
#   <index>:    index at which to insert the value
# Notes:
#   - The value <elt> becomes the new element at index <index> in the array.
#     That means, all elements after <index> have their index increased by 1
#   - Negative indices may be used, which resolve to an index relative to the
#     end of the array: -1 translates to the last array element, -2 to the
#     second-last, and so on, until -n which translates to the first array
#     element (if n is the size of the array)
#   - If <index> is out of the bounds of the array or invalid, it is ignored
#     and no changes are made to the array
#   - If <out-name> doesn't exist, it is created, if it already exists, it is
#     overwritten
#   - Use the same array name for both <in-name> and <out-name> to perform the
#     operation in-place on the input array
_array-insert() {
  _ensure-indexed-array "$1" || return 1
  local -n __array_insert__in=$1 
  local -n __array_insert__out=$2
  local __value=$3
  local __target_index=$4
  local __array_insert__in_size=$(_array-size __array_insert__in)
  # Ignore invalid indices by setting them to an out-of-bound index
  if ! _is-int "$__target_index"; then
    __target_index=-1
  # Convert negative indices (relative to end of array) to absolute indices
  elif _is-neg-int "$__target_index"; then
    # E.g. size=4 ([0][1][2][3]): -1 => [4], -2 => [3], etc.
    __target_index=$((__array_insert__in_size + __target_index + 1))
  fi
  local -a __array_insert__tmp
  local __i
  for __i in "${!__array_insert__in[@]}"; do
    if [[ "$__i" -eq "$__target_index" ]]; then
      __array_insert__tmp+=("$__value")
    fi
    __array_insert__tmp+=("${__array_insert__in[$__i]}")
  done
  # Insert as the new last element (not covered by above loop)
  if [[ "$__target_index" -eq "$__array_insert__in_size" ]]; then
    __array_insert__tmp+=("$__value")
  fi
  _array-cp __array_insert__tmp __array_insert__out
}

# Parse stdin into an indexed array
# Usage:
#   _array-parse <name> [<delim>]
# Args:
#   <name>:    name of the array to create
#   [<delim>]: array element delimiter (default: $'\n')
# Notes:
#   - Do NOT use this function in a pipe, but instead redirect input to it
#     with e.g. file redirection (<), a here doc (<<), or a here string (<<<).
#     For example:
#         _array-parse arr $'\n\n' <file
#         _array-parse arr :: <<<foo::bar::baz
#         _array-parse arr <<<$(ls -l)
#     If the function is used in a pipe (e.g. echo a:b | _array-parse arr :),
#     the function is executed in a sub-shell and thus the array <name> will
#     also be created in the sub-shell and thus won't be accessible from the
#     current shell (this is the same behaviour as with readarray/mapfile).
#   - The value of <delim> may be a string of any length and may include:
#       1. ANSI-C quoted strings [1]
#       2. Glob patterns [2]
#   - Examples of valid <delim> expressions include:
#       - $'\n\n':       two consecutive newlines
#       - '[.:] ':       a period or column followed by a space
#       - '[[:punct:]]': any punctuation character
#   - To use character sequences belonging to ANSI-C quoted strings and glob
#     patterns in the delimiter, they must be quoted with a backslash. These
#     character sequences include (assuming 'extglob' is enabled): 
#         $'...', *, ?, [...], ?(...), *(...), +(...), @(...), !(...)
#     For example, to use ** in the delimiter, use '\*\*'. To use a backslash
#     in the delimiter, escape it with another backslash ('\\').
#   - If 'extglob' is enabled, the 'extglob' patterns (?(...), etc.) CAN'T be
#     used in their intended way in <delim>, e.g. to define delimiters of
#     variable length. This is because the matched length of these patterns is
#     determined by the operator in the parameter expansion [3] expressions
#     that are used internally (i.e. %% vs. % and ## vs #).
#   - If <name> doesn't exist, it is created, if it already exists, it is
#     overwritten
#   - The following workaround can be used for using the function as the LAST
#     command of a pipe:
#         shopt -s lastpipe  # Enable lastpipe [4]
#         set +o monitor     # Disable job control [5]
#     However, this only works if the function is the last command of the pipe,
#     otherwise, there is no effect.
# References:
#   [1] https://www.gnu.org/software/bash/manual/bash.html#ANSI_002dC-Quoting
#   [2] https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching
#   [3] https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
#   [4] https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin
#   [5] https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
_array-parse() {
  local -n __array_parse__out=$1
  local __delim=${2:-$'\n'}
  local __input_cur __input_next=$(cat)
  __array_parse__out=()
  while [[ "$__input_next" != "$__input_cur" ]]; do
      __input_cur=$__input_next
      __array_parse__out+=("${__input_cur%%$__delim*}")
      __input_next=${__input_cur#*$__delim}
  done
}

#------------------------------------------------------------------------------#
# TODO: check whether these functions are necessary
#------------------------------------------------------------------------------#

# Sort an array
# Usage:
#   _array-sort <array> [-u] [-n]
# Args:
#   <array>: name of an array
#   -u:      suppress repeated array elements
#   -n:      sort in numerical rather than alphabetical order
_array-sort() {
  local -n __array=$1
  [[ "${#__array[@]}" -eq 0 ]] && return
  local __arg_u __arg_n
  local __a
  for __a in "${@:2}"; do
    case "$__a" in
      -u) __arg_u=-u ;;
      -n) __arg_n=-n ;;
      *)
        _err "Invalid argument: $__a"
        return 1
    esac
  done
  readarray -t __array <<<$(_array-ls __array | sort $__arg_u $__arg_n)
}

# Return the type of an array variable.
# Usage:
#   _array-type <array-name>
# Returns either 'indexed' or 'associative'. If the passed name does not belong
# to an array variable, the function returns an error.
_array-type() {
  _ensure-arg-count "$@" 1 "<array-name>" && _ensure-var-name "$1" && _ensure-array "$1" || return 1
  local -n __ref=$1
  case "${__ref@a}" in
    a) echo indexed ;;
    A) echo associative ;;
  esac
}
