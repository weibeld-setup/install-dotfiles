#!/usr/bin/env bash
#
# Delete all dotfiles and the dotfiles repository itself.
#------------------------------------------------------------------------------#

set -e

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

# Delete all files
echo "> Deleting files..."
git --git-dir "$git_dir" ls-files |
  while read f; do
    echo "  - $f"
    rm "$HOME/$f"
  done

# Delete directories that don't contain any files
echo "> Deleting empty directories..."
git --git-dir "$git_dir" ls-tree -d --format '%(path)' HEAD |
  while read d; do
    if [[ -z $(find "$d" -not -type d) ]]; then
      echo "  - $d"
      rm -rf "$HOME/$d"
    fi
  done

# Delete repository directory
echo "> Deleting repository ~/.dotfiles.git"
rm -rf "$git_dir"
