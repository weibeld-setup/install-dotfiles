# Shell Prompt

_prompt-command-prepend __set-prompt

__set-prompt() {
  # Exit code of previous command (must be first statement)
  local exit_code=$?
  # Different colours for root and non-root users
  if [[ "$USER" = root ]]; then
    local colour=$(_sgr red bold)
    local user="root|"
  else
    local colour=$(_sgr green bold)
  fi
  # Include OS name and version on Linux
  if _is-linux; then
    local os="$(os)|"
  fi
  # Prompt
  PS1="\[$colour\]$$|$os$user\w\$ \[$(_sgr)\]"
  # Prepend exit code of previous command if it was non-zero
  if [[ "$exit_code" -ne 0 ]]; then
    PS1="\[$(_sgr red bold)\]$exit_code|$(_sgr)$PS1"
  fi
}
