# ~/.bashrc

# Shell options (first, because some of them alter shell syntax, e.g. extglob)
shopt -s extglob
shopt -s nullglob
shopt -s direxpand
shopt -s histappend
set -o pipefail

# Source PATH setup
if [[ -f ~/.bashrc.path ]]; then
  . ~/.bashrc.path
fi

# Source common shell functions
if [[ -f ~/.bashrc.commons ]]; then
  . ~/.bashrc.commons
fi

# Source extended shell configuration
if [[ -f ~/.bashrc.config ]]; then
  . ~/.bashrc.config
fi

# Source all other .bashrc files
for f in ~/.bashrc.!(path|commons|config); do
  [[ -f "$f" ]] && . "$f"
done

# Clean PATH
PATH=$(clean-path)

# Auto-added code below this line
