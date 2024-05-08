# List all bashrc files
# Usage:
#   _bashrc-list
# Notes:
#   - The files are listed with their absolute path in alphabetical order
_bashrc-list() {
  ls -1 "$HOME"/{.bashrc,.bashrc.lib/*.bash,.bashrc.mod/*.bash}
}

# List module bashrc files
# Usage:
#   _bashrc-mod-list
# Notes:
#   - Module bashrc files are all files in the ~/.bashrc.mod directory
#   - The files are listed with their absolute path in alphabetical order
_bashrc-mod-list() {
  ls -1 ~/.bashrc.mod/*.bash
}

# List the sourcing status of all module bashrc files
# Usage:
#   _bashrc-mod-status
# Notes:
#   - The sourcing status indicates whether the module bashrc file has been
#     sourced or not (1=true, 0=false)
#   - The output is formatted in CSV format with the module bashrc file name
#     in the first column, and the sourcing status in the second column
_bashrc-mod-status() {
  local f
  for f in $(_bashrc-mod-list); do
    echo "$f,$(_bashrc-mod-is-sourced "$f" && echo 1 || echo 0)"
  done
}

# Get the ID of a module bashrc file
# Usage:
#   _bashrc-mod-id <path>
# Args:
#   <path>: absolute path of a module bashrc file
# Notes:
#   - The ID of a module bashrc file has the form 'MOD_<NAME>' where '<NAME>'
#     is the part of the file's name before '.bash' in upper-case letters
#   - If <path> is not an absolute path of a module bashrc file, the function
#     returns 1 without printing any output
_bashrc-mod-id() {
  local path=$1
  _bashrc-list -m | grep -q "^$path$" || return 1
  echo "MOD_$(basename "$path" | sed 's/\.bash$//' | _to-upper-case)"
}

# Source a module bashrc file
# Usage:
#   _bashrc-mod-source <path>
# Args:
#   <path>: absolute path of a module bashrc file
# Notes:
#   - This function sources the specified module bashrc file and creates an
#     environment variable of the form 'BASHRC_SOURCED_<ID>' where <ID> is the
#     ID of the module bashrc file as returned by _bashrc-mod-id()
#   - This environment variable indicates whether the module bashrc file has
#     been sourced and is used by _bashrc-mod-is-sourced()
#   - If <path> is not an absolute path of a secondary bashrc file, the function
#     exits with 1 without printing any output
_bashrc-mod-source() {
  local path=$1
  _bashrc-list -m | grep -q "^$path$" || return 1
  export BASHRC_SOURCED_$(_bashrc-mod-id "$path")=1
  . "$path"
}

# Check whether a module bashrc file has been sourced
# Usage:
#   _bashrc-mod-is-sourced <path>
# Args:
#   <path>: absolute path of a module bashrc file
# Notes:
#   - This function relies on the BASHRC_SOURCED_<ID> environment variables
#     set by _bashrc-mod-source()
#   - If <path> is not an absolute path of a secondary bashrc file, the function
#     exits with 1 without printing any output
_bashrc-mod-is-sourced() {
  local path=$1
  _bashrc-list -m | grep -q "^$path$" || return 1
  # TODO: user library function to check variable by name
  local -n __ref=BASHRC_SOURCED_"$(_bashrc-mod-id "$path")"
  [[ "$__ref" = 1 ]]
}
