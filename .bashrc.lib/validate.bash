#==============================================================================#
## Indicate sourcing of file
#==============================================================================#
export SOURCED_BASHRC_LIB_VALIDATE=1

#------------------------------------------------------------------------------#
#= Validation functions
#------------------------------------------------------------------------------#

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# These functions enforce a specific condition by printing an error message
# and returning 1, if the condition is not met.
#
# CAUTION: these functions are intended to be used in other functions.
#
# Example usage (in other function):
#   
#   _ensure-XXX || return 1
# 
# In the above example, the function aborts if the condition is not met.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Ensure that the argument is a valid command.
_ensure-installed() {
  if ! _is-cmd "$1"; then
    _err "'$1' is not installed"
    return 1
  fi
}

# Ensure that argument is a valid file descriptor.
# Note: the list of accepted file descriptors is hardcoded to 0, 1, and 3.
_ensure-file-descriptor() {
  if [[ ! "$1" =~ 0|1|2 ]]; then
    _err "'$1' is not a valid file descriptor"
    return 1
  fi
}

_ensure-array() {
  if ! _is-array "$1"; then
    _err "'$1' is not an array"
    return 1
  fi
}

# Ensure that the passed variable name belongs to an indexed array
# Usage:
#   _ensure-indexed-array <array-name>
_ensure-indexed-array() {
  if ! _is-indexed-array "$1"; then
    _err "'$1' must be an indexed array"
    return 1
  fi
}

# TODO: create variants with: 2, 2-, 2-3, -3
# Ensure that an argument list consists of a specific number of arguments
# Usage:
#   _ensure-arg-count <args>... <n>
# Args:
#   <args>...: the argument list to check
#   <n>:       the number specification with format '[min][-][max]'
# Notes:
#   - The number specification <n> can have the following formats:
#     - n:   exactly n arguments
#     - n-:  at least n arguments
#     - -n:  at most n arguments
#     - n-m: between n and m arguments
_ensure-arg-count() {
  local n=${@: -1}
  set -- "${@:1:$(($#-1))}"
  local n_min n_max n_msg
  if [[ "$n" =~ ^[0-9]+$ ]]; then
    n_min=$n
    n_max=$n
    n_msg=$n
  elif [[ "$n" =~ ^[0-9]+-$ ]]; then
    n_min=${n%-}
    n_max=$(getconf ARG_MAX)
    n_msg="at least $n_min"
  elif [[ "$n" =~ ^-[0-9]+$ ]]; then
    n_min=0
    n_max=${n#-}
    n_msg="at most $n_max"
  elif [[ "$n" =~ ^[0-9]+-[0-9]+$ ]]; then
    n_min=${a%-*}
    n_max=${a#*-}
    n_msg="between $n_min and $n_max"
  else
    _err "$FUNCNAME: invalid number specification: $n"
    return 1
  fi
  if [[ "$#" -lt "$n_min" || "$#" -gt "$n_max" ]]; then
    _err "'${FUNCNAME[1]}' must have $n_msg argument(s)"
    return 1
  fi
}

# Ensure that the argument is a valid variable name.
_ensure-var-name() {
  if ! _is-var-name "$1"; then
    _err "'$1' is not a valid variable name"
    return 1
  fi
}

# Ensure that the provided NAME is a declared variable
_ensure-variable() {
  if ! _is-variable "$1"; then
    _err "'$1' is not a variable"
    return 1
  fi
}

