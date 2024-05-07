#==============================================================================#
## Indicate sourcing of file
#==============================================================================#
export SOURCED_BASHRC_LIB_PATH=1

#------------------------------------------------------------------------------#
## PATH manipulation
#------------------------------------------------------------------------------#

# Print the current value of PATH
# Usage:
#   _path
_path-get() {
  echo "$PATH"
}

# Read PATH into an indexed array
# Usage:
#   _path-parse <name>
# Args:
#   <name>: name of the array to create
# Notes:
#   - If <name> doesn't exist, it is created, if it already exists, it is
#     overwritten
_path-parse() {
  # TODO: check that $1 is a valid variable name
  _array-parse "$1" : <<<"$PATH"
}

# Delete duplicate entries from PATH
# Usage:
#   _path-uniq
# Notes:
#   - If a duplicate PATH entry is detected, the first occurrence of this entry
#     is kept and all other ocurrences are deleted
_path-uniq() {
  local -a path
  _path-parse path
  _array-uniq path path
  PATH=$(_array-ls path :)
}

# Delete entries that are not existing directories from PATH
# Usage:
#   _path-rectify
_path-rectify() {
  local -a path delete
  _path-parse path
  local elt
  for elt in "${path[@]}"; do
    if [[ ! -d "$elt" ]]; then
      delete+=("$elt")
    fi
  done
  _array-rm path path "${delete[@]}"
  PATH=$(_array-ls path :)
}

# Prepend one or more entries to the beginning of the PATH
# Usage:
#   _path-prepend <entry>...
# Args:
#   <entry>: absolute path of a directory on the local machine
# Notes:
#   - If PATH already contains the entry, the existing entry is deleted before
#     adding the new entry 
#   - Multiple entries are added so that the first argument will be the first
#     entry in PATH, the second argument the second entry, and so on
#   - This function does NOT check whether the entries are valid directories
# Examples:
#   Prepend multiple entries (result is "/foo:/bar:/baz:$PATH"):
#     _path-prepend /foo /bar /baz
_path-prepend() {
  local -a path entries
  _path-parse path
  entries=("$@")
  _array-rev entries entries
  local e
  for e in "${entries[@]}"; do
    _array-rm path path "$e"
    _array-insert path path "$e" 0
  done
  PATH=$(_array-ls path :)
}

# Append one or more entries to the end of the PATH
# Usage:
#   _path-append <entry>...
# Args:
#   <entry>: absolute path of a directory on the local machine
# Notes:
#   - If PATH already contains the entry, the existing entry is deleted before
#     adding the new entry 
#   - Multiple entries are added so that the last argument will be the last
#     entry in PATH, the second-last argument the second-last entry, and so on
#   - This function does NOT check whether the entries are valid directories
# Examples:
#   Append multiple entries (result is "$PATH:/foo:/bar:/baz"):
#     _path-append /foo /bar /baz
_path-append() {
  local -a path entries
  _path-parse path
  entries=("$@")
  local e
  for e in "${entries[@]}"; do
    _array-rm path path "$e"
    _array-insert path path "$e" -1
  done
  PATH=$(_array-ls path :)
}

# Delete one or more entries from PATH
# Usage:
#   _path-rm <pat>...
# Args:
#   <pat>: regex pattern
# Notes:
#   - The value of <pat> may be any valid regex. The regex is automatically
#     anchored with ^ and $. That means, the pattern "foo" matches complete
#     entries "foo". For matching the substring "foo", use '.*foo.*'.
# Examples:
#   Delete all PATH entries containing the substring '/System':
#     _path-rm '.*/System.*'
_path-rm() {
  local -a path
  _path-parse path
  _array-rm path path "$@"
  PATH=$(_array-ls path :)
}
