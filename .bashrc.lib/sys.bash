# sys
#==============================================================================#

# Print operating system name and version of local machine
# Usage:
#   _sys-os
_sys-os() {
  if _is-mac; then
    echo "$(sw_vers -productName)-$(sw_vers -productVersion)"
  elif [[ -f /etc/os-release ]]; then
    ( . /etc/os-release && echo "$ID-$VERSION_ID" )
  fi
}

# List the sources of a command
# Usage:
#   _sys-cmd-src <cmd>
# Args:
#   <cmd>: a command
# Notes:
#   - Lists the sources of all the definitions of a command
#   - A command is a keyword that is intepreted by the shell, which includes:
#       1. Aliases
#       2. Functions
#       3. Executable files in PATH
#       4. Shell builtins
#   - A command may be repeatedly overwritten by a new definition (for example,
#     when an alias for an executable file is defined) which results in a stack
#     of definitions with the topmost definition taking effect. This function
#     lists the sources of ALL the definitions of the given command.
#   - The output is written in CSV format with the following columns:
#       1. Index: position in the command definition stack (1=top)
#       2. Type: 'alias', 'function', 'file', or 'builtin'
#       3. File: absolute path of file containing/constituting the command
#          definition (applicable to 'alias', 'function', and 'file')
#       4. Line: line number of the command definition in the file (applicable
#          to 'alias' and 'function')
# Implementation notes:
#   - Alias definitions are parsed from the .bashrc.* files (see '_get-bashrc').
#     In order to be parsed correctly, alias definitions must only have white-
#     space between the 'alias' keyword and the beginning of the line.
_sys-cmd-src() {
  # TODO: ensure exactly 1 argument
  local cmd=$1
  local types=$(type -ta "$cmd")
  local i=1 i_file=1
  echo "$types" | while read t; do
    case "$t" in
      function)
        # Get source of currently active function definition
        {
          shopt -s extdebug
          local res=$(declare -F "$cmd")
          shopt -u extdebug
        }
        local file=$(echo "$res" | cut -d ' ' -f 3-)
        local line=$(echo "$res" | cut -d ' ' -f 2)
        file=$(realpath "$file")
        echo "$i,function,$file,$line"
        ;;
      alias)
        # TODO: compare all matches against output of 'type' in order to determine
        # the latest alias definition (does not rely on the order of the files in _get-bashrc)
        local res=$(grep -nE "^[ ]*alias[ ]+$cmd=" $(_bashrc-list) /dev/null | tail -n 1)
        local file=$(cut -d : -f 1 <<<"$res")
        local line=$(cut -d : -f 2 <<<"$res")
        echo "$i,alias,$file,$line"
        ;;
      file)
        local file=$(which -a "$cmd" | sed -n "${i_file}p")
        ((i_file++))
        echo "$i,file,$file,"
        ;;
      builtin)
        echo "$i,builtin,,"
        ;;
    esac
    ((i++))
  done
}
