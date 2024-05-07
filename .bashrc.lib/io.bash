#==============================================================================#
## Indicate sourcing of file
#==============================================================================#
export SOURCED_BASHRC_LIB_IO=1

# If no arguments are provided, print stdin, else print the arguments.
# Usage:
#   _get-input [<args>...]
# This function can be used within another function to gather the function's
# input either from the arguments or from stdin.
# Notes:
#   - The tokenisation of the argument list is NOT maintained, that means, the
#     arguments are printed as a single string.
_get-input() {
  if [[ "$#" -gt 0 ]]
    then echo "$*"
  else
    echo "$(</dev/stdin)"
  fi
}

# Split arguments into two arrays separated by a delimiter.
# Usage:
#   _splitargs <array_name_1> <arrary_name_2> <delimiter> <args>...
# Args:
#   <array_name_1>  Name of array variable for elements before delimiter
#   <array_name_2>  Name of array variable for elements after delimiter
#   <delimiter>     Delimiter string 
#   <args>...       Argument sequence containing elements and delimiter
# Example:
#   _splitargs a1 a2 -- foo bar -- baz kux
# The above assigns ["foo" "bar"] to a variable named 'a1' and ["baz" "kux"] to
# a variable named 'a2'. These variables can be used in the calling context.
# Notes:
#   - The variable names DON'T need to be declared in the calling function, but
#     it's advisable to declare them with 'local' in order to keep them local.
#   - If <args>... does not contain the delimiter, then all elements are
#     assigned to <array_name_1> (and <array_name_2> is left empty)
#   - If <args>... contains multiple occurrences of the delimiter, then the
#     split happens at the first of these delimiters.
#   - The passed variable names must not be '__ref1' and '__ref2' as these are
#     internally used (otherwise, a "circular name reference" error occurs).
#   - The assignments to the passed in variable names are implemented through
#     the nameref attribute [1] (requires at least Bash 4.3)
# [1] https://www.gnu.org/software/bash/manual/html_node/Shell-Parameters.html
_splitargs() {
  local -n __ref1=$1 __ref2=$2
  local d=$3
  shift 3
  local i
  for i in $(seq "$#"); do
    if [[ "${!i}" = "$d" ]]; then
      __ref1=("${@:1:$(($i-1))}")  # Arguments before delimiter
      __ref2=("${@:$(($i+1))}")    # Arguments after delimiter
      return
    fi
  done
  # If no delimiter found
  __ref1=("$@")
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# These functions print output intended to be processed or used by other
# functions or commands.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Print a Select Graphic Rendition (SGR) code.
# Usage:
#   _sgr [<keyword>...]
# The available keywords are:
#    1. red[+]
#    2. green[+]
#    3. yellow[+]
#    4. blue[+]
#    5. magenta[+]
#    6. cyan[+]
#    7. white[+]
#    8. black[+]
#    9. bold
#   10. italic
#   11. dim
#   12. underline
#   13. reset
# The 8 colours without an appended + are the normal versions of these colours
# and appending a + means selecting the bright version of this colour. There
# may be any number of keywords and they may be in any order. However, the
# corresponding attributes are applied sequentially and a later keyword may
# override the effect of a previous keyword. For example 'red italic green'
# results in 'italic' and 'green' being select (the effect of 'red' is undone
# by the appearance of 'green' later in the list).
# Notes:
#   - The 'reset' keyword resets all previously specified attributes.
#   - If no keywords are specified, it has the same effect as specifying 'reset'
#     as the only or last keyword.
# Example:
#   echo "$(_sgr bold red)This is bold red. $(_sgr)This is normal."
# References:
#   - https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
_sgr() {
  local -a params
  local a
  for a in $@; do
    case "$a" in
      # Normal colours
      black)      params+=(30) ;;
      red)        params+=(31) ;;
      green)      params+=(32) ;;
      yellow)     params+=(33) ;;
      blue)       params+=(34) ;;
      magenta)    params+=(35) ;;
      cyan)       params+=(36) ;;
      white)      params+=(37) ;;
      # Bright colours
      black+)     params+=(90) ;;
      red+)       params+=(91) ;;
      green+)     params+=(92) ;;
      yellow+)    params+=(93) ;;
      blue+)      params+=(94) ;;
      magenta+)   params+=(95) ;;
      cyan+)      params+=(96) ;;
      white+)     params+=(97) ;;
      # Modifiers
      bold)       params+=(1) ;;
      dim)        params+=(2) ;;
      italic)     params+=(3) ;;
      underlined) params+=(4) ;;
      reset)      params+=(0) ;;
    esac
  done
  local IFS=';'
  printf "\e[${params[*]}m"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# These functions print user-facing output messages.
#
# CAUTION: these functions are intended to be used in other functions.
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# Print an error message to stderr
# Usage:
#   _err <msg>
# Args:
#   <msg>: the error message
# Notes:
#   - The message ideally consists of a single line
#   - The prefix 'Error: ' is automatically added to the message in the output
#   - The output includes the complete function call stack
#   - The output is coloured if stderr is directed to a terminal (it is not
#     coloured if stderr is directed to anything else but a terminal)
_err() {
  local msg=$1
  # Format function call stack
  local -a stack
  _array-cp FUNCNAME stack
  # Remove _array-cp and _err from the call stack
  _array-rmi stack stack 0 1
  _array-rev stack stack
  local stack_str=$(_array-ls stack " > ")
  # Print message and function call stack
  _cond-sgr-msg red -- "Error:\n  $msg\nCall stack:\n  $stack_str\n"
}

# TODO:
#   - Omit this function and only use the documentation function for the usage
#   - Make <msg> a single argument and omit need for splitargs
# Print usage message for a function to stderr.
# Usage:
#   _print-usage-msg <msg>... [-- <func-stack-index>]
# The output is highlighed with Select Graphic Rendition (SGR) codes if stderr
# is directed to the terminal. The <func-stack-index> argument is the index in
# the function call stack of the function name to print. Its default value is
# 1, which corresponds to the immediate caller of _print-usage-msg.
# Notes:
#   - <msg> may include 'echo -e' escape codes such as '\n' and '\t'
_print-usage-msg() {
  local msg_arr index_arr
  _splitargs msg_arr index_arr -- "$@"
  _cond-sgr-msg cyan bold -- \
    "Usage:\n  ${FUNCNAME["${index_arr[0]:-1}"]:-<unknown>} ${msg_arr[@]}\n" -- \
    2
}

# Print a message if file descriptor is directed to terminal.
# Usage:
#   _cond <msg>... [-- <fd>]
# The default value for <fd> is 1, which corresponds to stdout. That means, the
# function prints the message to stdout IF stdout is directed to the terminal.
# To use stderr instead, append the delimiter -- followed by 2 to the argument
# list. In that case, the message is written to stderr IF stderr is directed
# to the terminal.
# Notes:
#   - The message is printed without an implicit newline at the end.
#   - All escape codes understood by 'echo -e' (such as '\n' or '\t') may be
#     included in the message.
_cond() {
  local msg_arr fd_arr
  _splitargs msg_arr fd_arr -- "$@"
  local fd=${fd_arr[0]:-1}
  _ensure-file-descriptor "$fd" || return 1
  if [[ -t "$fd" ]]; then
    echo -ne "${msg_arr[@]}" >&"$fd"
  fi
}

# Print an SGR code if file descriptor is directed to terminal.
# Usage:
#   _cond-sgr <sgr-arg>... [-- <fd>]
_cond-sgr() {
  local -a sgr_arr fd_arr
  _splitargs sgr_arr fd_arr -- "$@"
  local fd=${fd_arr[0]:-1}
  _ensure-file-descriptor "$fd" || return 1
  if [[ -t "$fd" ]]; then
    _sgr "${sgr_arr[@]}" >&"$fd"
  fi
}

# Print an SGR-formatted message if file descriptor is directed to terminal.
# Usage:
#   _cond-sgr-msg <sgr-arg>... -- <msg>... [-- <fd>]
# TODO:
#   - Make <msg> a single argument and avoid need for -- (change order of <msg>
#     and <sgr-arg>...)
#   - Create separate functions for stdout and stderr to avoid need for [-- <fd>]
#   - Make versions for printing lines (auto-adding newline) and other for
#     not printing a newline
_cond-sgr-msg() {
  local -a sgr_arr msg_fd_arr msg_arr fd_arr
  _splitargs sgr_arr msg_fd_arr -- "$@"
  _splitargs msg_arr fd_arr -- "${msg_fd_arr[@]}"
  local fd=${fd_arr[0]:-1}
  _ensure-file-descriptor "$fd" || return 1
  local msg="${msg_arr[@]}"
  if [[ -t "$fd" ]]; then
    msg="$(_sgr "${sgr_arr[@]}")${msg}$(_sgr)"
  fi
  echo -ne "$msg" >&"$fd"
}

