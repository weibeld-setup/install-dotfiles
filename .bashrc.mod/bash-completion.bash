# bash-completion
# Description:
#   Activates bash-completion [1], which is the basis and a requirement for
#   almost all Bash command completion [2] specifications out there.
# Refernces:
#   [1] https://github.com/scop/bash-completion
#   [2] https://www.gnu.org/software/bash/manual/bash.html#Programmable-Completion
# Requirements:
#   - bash-completion
#     - Command: N/A
#     - URL: https://github.com/scop/bash-completion
#==============================================================================#

# TODO:
#   - Add functions:
#     - List bash_completion.d directory
#     - List bash_completion script
#   - Check installation of bash-completion beforehand
#   - Add support for additional installation options of bash-completion

if _is-pkg-mgmt-homebrew; then
  . $(brew --prefix)/etc/profile.d/bash_completion.sh
elif _is-linux; then
  # Code from /etc/bash.bashrc which by default is outcommented
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi
