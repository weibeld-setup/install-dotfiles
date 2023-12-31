# ~/.bashrc
#
# Master .bashrc file sourcing all the specialised .bashrc.* files.
#------------------------------------------------------------------------------#

# Shell options (these come first before sourcing any of the .bashrc.* files
# because some of these options, such as extglob, alter the shell syntax).
shopt -s extglob
shopt -s nullglob
shopt -s direxpand
shopt -s histappend
set -o pipefail

# Source PATH setup
if [[ -f ~/.bashrc.path ]]; then
  . ~/.bashrc.path
fi

# Source shell function library
if [[ -f ~/.bashrc.lib ]]; then
  . ~/.bashrc.lib
fi

# Source main shell configuration
if [[ -f ~/.bashrc.config ]]; then
  . ~/.bashrc.config
fi

# Source all other .bashrc.* files
for f in ~/.bashrc.!(path|commons|config); do
  [[ -f "$f" ]] && . "$f"
done

# Clean PATH
PATH=$(clean-path)

# Auto-added code below this line
