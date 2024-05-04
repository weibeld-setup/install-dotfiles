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

declare file

# Source shell function library
if [[ -d ~/.bashrc.lib ]]; then
  for file in ~/.bashrc.lib/*.bash; do
    . "$file"
 done
fi

# Source PATH setup
if [[ -f ~/.bashrc.path ]]; then
  . ~/.bashrc.path
fi

# TODO:
# - Put content of .bashrc.main here
# - Rename .bashrc.path and .bashrc.lib to .bashrc.init.path and .bashrc.init.lib
# - Rename other .bashrc.* files to .bashrc.topic.*
# Source general .bashrc.* file
if [[ -f ~/.bashrc.main ]]; then
  . ~/.bashrc.main
fi

# Source all other .bashrc.* files
for file in ~/.bashrc.!(path|lib|main); do
  [[ -f "$file" ]] && . "$file"
done

unset file

# Auto-added code below this line
