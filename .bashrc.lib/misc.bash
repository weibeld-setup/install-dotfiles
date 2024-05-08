#==============================================================================#
## File system paths
#==============================================================================#

# Replace tildes (~) with home directories in input paths
# Usage:
#   _filepath-expand-tilde
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Paths that don't start with a tilde are printed unchanged
_filepath-expand-tilde() {
  sed "s|^~|$HOME|"
}

# Replace home directories with tildes (~) in input paths
# Usage:
#   _filepath-insert-tilde
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Paths that don't start with the absolute path of the home directory are
#     printed unchanged
_filepath-insert-tilde() {
  sed "s|^$HOME|~|"
}

# Delete a specified prefix from input paths
# Usage:
#   _filepath-cut-prefix <prefix>
# Args:
#   <prefix>: path prefix to cut from the input paths
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
#   - Tildes (~) are expanded in both the prefix and the paths before comparing
#     the prefix to the paths
#   - Path's that don't start with the prefix are printed unchanged
_filepath-cut-prefix() {
  # TODO: validate exactly one argument
  local paths=$(cat | _filepath-expand-tilde)
  local prefix=$(_filepath-expand-tilde <<<"$1")
  sed "s|^$prefix||" <<<"$paths"
}

# Remove trailing slashes from input paths
# Usage:
#   _filepath-trim-slashes
# Notes:
#   - Input is read from stdin
#   - The input may contain any number of paths with one path per line
_filepath-trim-slashes() {
  sed 's|/+$||'
}
