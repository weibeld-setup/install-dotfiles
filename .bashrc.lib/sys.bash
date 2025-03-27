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
#   _sys-cmd-loc <cmd>
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
_sys-cmd-loc() {
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
complete -c _sys-cmd-loc

# TODO:
#   - Make it only for functions
#   - Print only documentation
#     - Can use 'type' for body and _sys-cmd-loc() for source

# Print documentation for a function or alias.
# Usage:
#   _sys-func-doc <func> [-a]
# If <name> is a function or alias defined in a .bashrc.* file, print the
# documentation and body of this function or alias definition. By default,
# function bodies are truncated after 10 lines, however, this can be changed
# with the -a option, which causes the entire function body to be printed.
# Notes:
#   - In order for the documentation to be recognised, the corresponding
#     comment lines must be adjacent to the function or alias definition
#     without any empty lines between them.
_sys-func-doc() {
  local func=$1
  local res=$(_sys-cmd-loc "$func" | head -n 1)
  local type=$(cut -d , -f 2 <<<"$res")
  local file=$(cut -d , -f 3 <<<"$res")
  local line=$(cut -d , -f 4 <<<"$res")
  if [[ "$type" != function ]] || _is-empty "$file" || _is-empty  "$line"; then
    return
  fi
  echo "Doc:"
  ((line--))
  while true; do
    local content=$(sed -n "${line}p" "$file")
    [[ "$content" =~ ^\ *# ]] || break
    echo  "  ${content#*# }"
    ((line--))
  done | tac
#  # Print comment block from line_nr-1 backwards
#  tac "$file" | awk -v start_line_nr="$(($(wc -l <"$file")-line+2))" '
#    BEGIN {
#      while ((getline line) > 0) {
#        if (NR >= start_line_nr) {
#          if (line ~ /^[ ]*#/) {
#            gsub(/^[ ]*/, "", line)
#            print line
#          }
#          else {
#            break
#          }
#        }
#      }
#    }' | tac
#  if [[ "$type" = function ]]; then
#    local max_lines=10
#    local body=$(type "$func" | tail -n +2)
#    if [[ -n "$all" ]]; then
#      echo "$body"
#    else
#      echo "$body" | head -n "$max_lines"
#      if [[ $(echo "$body" | wc -l) -gt  "$max_lines" ]]; then
#        _cond-sgr
#        echo  "[...]"
#      fi
#    fi
#  elif [[ "$type" = alias ]]; then
#    command -v "$func"
#  fi
}
# TODO: complete only function names
complete -c _sys-func-doc
