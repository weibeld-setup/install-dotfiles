# Functions for handling bashrc files.
#==============================================================================#


# Select and open a bashrc file in Vim
# Usage:
#   bre
bre() {
  _ensure-installed fzf || return 1
  local f=$(_bashrc-list | _filepath-insert-tilde | fzf -e | _filepath-expand-tilde)
  ! _is-set "$f" && return
  vim "$f"
}

# Source all bashrc files
# Usage:
#   brs
brs() {
  . ~/.bashrc
}

# List all bashrc modules including their sourcing status
# Usage:
#   brm
# Notes:
#   - The sourcing status of a module indicates whether the module file has
#     been sourced or not
brm() {
  # TODO: find solution for colouring output when output is terminal
  _bashrc-mod-status | _filepath-insert-tilde | sed 's/0$/FALSE/;s/1$/TRUE/' | column -t -s ,
}

# List the function and alias names defined in a .bashrc.* file
# Notes:
#   This function puts the following requirements on .bashrc.* files:
#     1. There MAY be headers starting with #=: at the beginning of the line
#     2. These headers MUST be exactly three lines high (the first line must
#        start with #=, the remaining two lines can have arbitrary content).
#   If the above requirements are met, then these headers are printed along
#   with the function and alias names. If the .bashrc.* file does not contain
#   any such headers, then only the function and alias names are printed.
lbr() {
  # Read input file
  local file=$1
  if ! _is-set "$file"; then
    _ensure-installed fzf || return 1
    file=$(basename ~/.bashrc.* | sed 's/^/~\//' | fzf -e --tac | sed "s|~|$HOME|")
    ! _is-set "$file" && { echo "No selection"; return; }
  fi
  # Add line numbers to input file
  local tmp=$(mktemp)
  cat "$file" | nl -b a -s ': ' | sed 's/^[ ]*// ; s/^[0-9]+: #/#/' >"$tmp"
  # Split input file into sections (demarcated by #=)
  local dir=$(mktemp -d)
  split -p '^#=' "$tmp" "$dir/"
  local linebreak=
  for f in $dir/*; do
    # Pretty-print header (with #--- instead of #=--)
    if [[ $(head -n 1 "$f") =~ ^#=: ]]; then
      echo -ne "$linebreak"
      sed -n '3p' "$f"
      sed -n '2,3p' "$f"
      linebreak="\n"
    fi
    # Print functions and aliases
    cat "$f" |
      grep -e '^[0-9]*: [ ]*[a-zA-Z0-9_-]*()' -e '^[0-9]*: [ ]*alias[ ]*[a-zA-Z0-9_-]*=' |
      sed 's/(^[0-9]*: )[ ]*/\1/ ; s/\(\).*/\(\)/ ; s/=.*//'
  done
}
