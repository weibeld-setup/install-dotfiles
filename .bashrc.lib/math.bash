#------------------------------------------------------------------------------#
#= Number processing
#------------------------------------------------------------------------------#

# Calculate the logarithm of a given number to a given base
# Usage:
#   log <base> <n> [-i]
# Description:
#   Prints the logarithm of <n> with respect to <base>. If -i is supplied as
#   the last argument, the result rounded to the nearest integer that is lower
#   than the result.
_log() {
  local base=$1 n=$2
  local result=$(bc -l <<<"l($n) / l($base)")
  if [[ "${@: -1}" = -i ]]; then
    _floor "$result"
  else
    echo "$result"
  fi
}

# Calculate the logarithm of two for a given number
# Usage:
#   log2 <n> [-i]
# Description:
#   Prints the logarithm of 2 of <n>. If -i is supplied as the last argument,
#   the result is rounded to the nearest integer that is lower than the result.
_log2() {
  _log 2 "$@"
}

# Calculate the logarithm of ten for a given number
# Usage:
#   log10 <n> [-i]
# Description:
#   Prints the logarithm of 10 of <n>. If -i is supplied as the last argument,
#   the result is rounded to the nearest integer that is lower than the result.
_log10() {
  _log 10 "$@"
}

# Round number ($1) to specific number of digits ($2) after decimal point
_round() {
  printf "%.$2f\n" "$1"
}

# Round number down to nearest integer
_floor() {
  bc <<<"$1/1"
}

