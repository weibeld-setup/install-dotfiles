#!/usr/bin/env bash
#
# Delete all dotfiles and the dotfiles repository itself.
#------------------------------------------------------------------------------#

set -e

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

# Delete all files and submodule directories
echo "> Deleting files..."
git --git-dir "$git_dir" ls-files |
  while read f; do
    echo "  - $f"
    # ls-files also lists submodule directories, hence 'rm -rf' must be used
    rm -rf "$work_tree/$f"
  done

# Delete directories that don't contain any files
echo "> Deleting empty directories..."
git ls-tree -rd --format '%(objecttype) %(path)' HEAD |
  grep '^tree ' |
  sed 's/^tree //' |
  while read d; do
    if [[ -d "$work_tree/$d" && -z $(find "$work_tree/$d" -not -type d) ]]; then
      echo "  - $d"
      rm -rf "$work_tree/$d"
    fi
  done

# Delete repository directory
echo "> Deleting repository '~/.dotfiles.git'"
rm -rf "$git_dir"
