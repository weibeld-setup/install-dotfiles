# TODO: check whether moving these functions to the file with their related functions

# TODO:
#   - Create _is-bsd and _is-gnu as a more precise check about which version
#     of a command to use than _is-mac and _is-linux

# Check whether running on macOS
_is-mac() {
  [[ "$OSTYPE" =~ darwin ]]
}

# Check whether running on Linux
_is-linux() {
  [[ "$OSTYPE" =~ linux  ]]
}

# Check whether running on a WSL distribution of Linux
# References:
#   - https://learn.microsoft.com/en-us/windows/wsl/install
#   - https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux
_is-wsl() {
  _is-linux && [[ -n "$WSL_DISTRO_NAME" ]]
}


# Check whether Homebrew is used for package management
_is-pkg-mgmt-homebrew() {
  _is-installed brew
}

# Check whether APT is used for package management
_is-pkg-mgmt-apt() {
  _is-installed apt && _is-installed apt-get && _is-installed apt-cache
}

# TODO: check whether this is needed
# Check whether a given Homebrew formula or cask is installed
# Note: also checks whether Homebrew is installed, and aborts otherwise
_is-homebrew-poured() {
  _ensure-installed brew || return 1
  brew ls --versions "$1" >/dev/null || brew ls --cask --versions "$1" >/dev/null
}

# TODO:
#   - _is-set: take variable name
#   - _is-value: take value

# Check whether the variable with the provided name is set (i.e. non-empty)
# Notes:
#   - Returns 1 (false) if no variable with the provided name exists.
_has-value() {
  _is-var-name "$1" || return 1
  local -n __ref=$1
  _is-set "$__ref"
}

# Check whether the provided value is set (i.e. non-empty)
# Notes:
#   - Returns 1 (false) if no value is provided.
_is-set() {
  [[ -n "$1" ]]
}

# Check whether the provided value is empty (or non-existent)
# Notes:
#   - Returns 0 (true) if no value is provided.
_is-empty() {
  [[ -z "$1" ]]
}

# Check whether a number is even
_is-even() {
  (($1 % 2 == 0))
}

# Check whether a number is odd
_is-odd() {
  (($1 % 2 != 0))
}

# Check whether a number is an integer
_is-int() {
  _is-pos-int "$1" || _is-neg-int "$1"
}

# Check whether a value is a positive integer (including 0)
_is-pos-int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Check whether a number is a negative integer
_is-neg-int() {
  [[ "$1" =~ ^-[0-9]+$ ]]
}

# Check whether there is a variable with the provided name
_is-variable() {
  declare -p -- "$1" &>/dev/null
}

# Check whether a variable is an indexed array
# Usage:
#   _is-indexed-array <var-name>
_is-indexed-array() {
  _has-attributes "$1" a
}

# Check whether a variable is an associative array
# Usage:
#   _is-associative-array <var-name>
_is-associative-array() {
  _ensure-variable "$1" || return 1
  _has-attributes "$1" A
}

# Check whether a variable is either an indexed or an associative array 
# Usage:
#   _is-array <var-name>
_is-array() {
  _ensure-variable "$1" || return 1
  _has-attributes-any-of "$1" Aa
}

# Check whether a variable is read-only
# Usage:
#   _is-read-only <var-name>
_is-read-only() {
  _ensure-variable "$1" || return 1
  _has-attributes "$1" r
}

# Check whether the argument is the name of a shell function
_is-function() {
  [[ "$(type -t "$1")" = function ]]
}
complete -A function _is-function

# Check whether a given command is a shell alias
_is-alias() {
  [[ "$(type -t "$1")" = alias ]]
}
complete -a _is-alias

# Check whether a given command is a shell builtin
_is-builtin() {
  [[ "$(type -t "$1")" = builtin ]]
}
complete -b _is-builtin

# Check whether a given command is an executable file in the PATH
_is-exec-file() {
  [[ "$(type -t "$1")" = file ]]
}
complete -c _is-exec-file

# Alias of _is-exec-file
_is-installed() {
  _is-exec-file "$@"
}

# Check whether a given command exists (i.e. is either an executable file in 
# the path, an alias, a function, or a shell builtin)
_is-cmd() {
  _is-exec-file "$1" || _is-alias "$1" || _is-function "$1" || _is-builtin "$1"
}
complete -c _is-cmd

# TODO: change to _is-identifier()
# Check whether the argument is a valid variable name.
# Usage:
#   _is-var-name <name>
# Note: this function just checks whether the name adheres to the naming
# restrictions, not whether a variable with that name is declared or assigned.
_is-var-name() {
  [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

# Check whether PATH contains an entry matching the specified pattern
# Usage:
#   _is-in-path <pat>
# Args:
#   <pat>: regex pattern 
# Notes:
#   - The value of <pat> may be any valid regex. The regex is automatically
#     anchored with ^ and $. That means, "foo" matches the exact entry "foo".
#     To match any substring "foo", use ".*foo.*".
# Examples:
#   Test whether PATH contains any entries containing the substring 'homebrew':
#     _is-in-path '.*homebrew.*'
_is-in-path() {
  local -a path
  _path-to-array path
  _array-has path "$1"
}
