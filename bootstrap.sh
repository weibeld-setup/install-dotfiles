#!/bin/bash
#
# Install dotfiles https://github.com/weibeld/dotfiles to local HOME directory.
#
# TODO: correctly handle dotfile directories.
#------------------------------------------------------------------------------#

set -e
shopt -s expand_aliases

echo "> Downloading dotfiles..."
git clone --quiet --bare https://github.com/weibeld/dotfiles ~/.git-dotfiles
alias git-dotfiles='git --git-dir=$HOME/.git-dotfiles --work-tree=$HOME'
files=($(git-dotfiles ls-tree -r HEAD | awk '{print $NF}'))
for f in "${files[@]}"; do
    [[ -f "$HOME/$f" ]] && mkdir -p ~/.dotfiles.backup && mv "$HOME/$f" ~/.dotfiles.backup &&
    echo "> Backing up: ~/$f ==> ~/.dotfiles.backup/$f"
done
git-dotfiles checkout
git-dotfiles config status.showUntrackedFiles no
echo "> Success! The following dotfiles have been installed in $HOME:"
printf '    %s\n' "${files[@]}"
