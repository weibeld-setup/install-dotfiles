# Print all .bashrc* files
# Usage:
#   _bashrc
# Notes:
#   - The .bashrc* files are printed with their absolute paths
#   - The .bashrc* files are printed in alphabetical order
_bashrc() {
  ls -1 "$HOME"/{.bashrc,.bashrc.lib/*.bash,.bashrc.topic/*.bash}
}

# Replace tildes (~) with home directories in input paths
# Usage:
#   _path-expand-tilde
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Paths that don't start with a tilde are printed unchanged
_path-expand-tilde() {
  sed "s|^~|$HOME|"
}

# Replace home directories with tildes (~) in input paths
# Usage:
#   _path-include-tilde
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Paths that don't start with the absolute path of the home directory are
#     printed unchanged
_path-include-tilde() {
  sed "s|^$HOME|~|"
}

# Remove a specified prefix from input paths
# Usage:
#   _pat-cut-prefix <prefix>
# Args:
#   <prefix>: path prefix to cut from the input paths
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Tildes (~) are expanded in both the prefix and the paths before matching
#     the prefix to the paths
#   - Path's that don't start with the prefix are printed unchanged
_path-cut-prefix() {
  # TODO: validate exactly one argument
  local paths=$(cat | _path-expand-tilde)
  local prefix=$(_path-expand-tilde <<<"$1")
  sed "s|^$prefix||" <<<"$paths"
}

# Remove trailing slashes from input paths
# Usage:
#   _path-trim-slashes
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
_path-cut-trailing-slashes() {
  sed 's|/+$||'
}
