#!/usr/bin/env bash
#
# Delete all dotfiles and the dotfiles repository itself.
#------------------------------------------------------------------------------#

set -e
set -o pipefail

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git

# Workspace directory (where files are checked out)
work_tree=$HOME

if [[ ! -d "$git_dir" ]]; then
  echo "Error: the dotfiles repository '$git_dir' does not exist"
  exit 1  
fi

# Delete files
items=$(git --git-dir "$git_dir" ls-tree -r --format '%(objecttype) %(path)' HEAD | grep '^blob ' | sed 's/^blob //')
if [[ -n "$items" ]]; then
  echo "> Deleting files in '$work_tree'..."
  echo "$items" | while read p; do
    echo "    $p"
    rm  "$work_tree/$p"
  done
fi

# Delete submodules
items=$(git --git-dir "$git_dir" ls-tree -r --format '%(objecttype) %(path)' HEAD | grep '^commit ' | sed 's/^commit //')
if [[ -n "$items" ]]; then
  echo "> Deleting submodules in '$work_tree'..."
  echo "$items" | while read p; do
    echo "    $p/"
    rm  -rf "$work_tree/$p"
  done
fi

# Delete empty directories
items=$(
  for d in $(git --git-dir "$git_dir" ls-tree -rd --format '%(objecttype) %(path)' HEAD | grep '^tree ' | sed 's/^tree //'); do
    if [[ -d "$work_tree/$d" && -z $(find "$work_tree/$d" -not -type d) ]]; then
      echo "$d"
    fi
  done
)
if [[ -n "$items" ]]; then
  echo "> Deleting empty directories in '$work_tree'..."
  echo "$items" | while read p; do
    echo "    $p/"
    rm  -rf "$work_tree/$p"
  done
fi

# Delete repository directory
echo "> Deleting repository '$git_dir'"
rm -rf "$git_dir"

echo "✅ UNINSTALLATION COMPLETE"
