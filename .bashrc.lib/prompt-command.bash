#------------------------------------------------------------------------------#
## PROMPT_COMMAND manipulation
#------------------------------------------------------------------------------#

# TODO: see .bashrc.lib/path.bash for examples for additional functions

# Print the current value of PROMPT_COMMAND
# Usage:
#   _prompt-command-get
_prompt-command-get() {
  echo "$PROMPT_COMMAND"
}

# Split PROMPT_COMMAND into an indexed array of individual commands
# Usage:
#   _prompt-command-to-array <name>
# Args:
#   <name>: name of the array to create
# Notes:
#   - The PROMPT_COMMAND value is split at semicolons (;) into array elements
#   - If <name> doesn't exist, it is created, if it already exists, it is
#     overwritten
_prompt-command-to-array() {
  # TODO: check that $1 is a valid variable name
  _array-parse "$1" '; ' <<<"$PROMPT_COMMAND"
}

# Prepend one or more commands to the beginning of PROMPT_COMMAND
# Usage:
#   _prompt-command-prepend <cmd>...
# Args:
#   <cmd>: command to prepend to PROMPT_COMMAND
# Notes:
#   - TODO: check what happens if has multiple lines, includes semicolons, etc.
#       (<cmd> is ideally a single-line command and should not contain any ;)
#   - If PROMPT_COMMAND already contains <cmd>, the existing instance of <cmd>
#     is deleted before prepending the new instance
#   - If multiple commands are provided, they are prepended to PROMPT_COMMAND
#     so that they end up in the same order in PROMPT_COMMAND in which they
#     have been specified on the command line
_prompt-command-prepend() {
  local -a arr new_commands
  _prompt-command-to-array arr
  new_commands=("$@")
  _array-rev new_commands new_commands
  local c
  for c in "${new_commands[@]}"; do
    _array-rm arr arr "$c"
    _array-insert arr arr "$c" 0
  done
  PROMPT_COMMAND=$(_array-ls arr '; ')
}

# Append one or more commands to the end of PROMPT_COMMAND
# Usage:
#   _prompt-command-append <cmd>...
# Args:
#   <cmd>: command to append to PROMPT_COMMAND
# Notes:
#   - If PROMPT_COMMAND already contains <cmd>, the existing instance of <cmd>
#     is deleted before appending the new instance
_prompt-command-append() {
  local -a arr new_commands
  _prompt-command-to-array arr
  new_commands=("$@")
  local c
  for c in "${new_commands[@]}"; do
    _array-rm arr arr "$c"
    _array-insert arr arr "$c" -1
  done
  PROMPT_COMMAND=$(_array-ls arr '; ')
}
