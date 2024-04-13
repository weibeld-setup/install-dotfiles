#!/usr/bin/env bash

set -e

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

if [[ -d "$git_dir" ]]; then
  echo "Error: the directory '$git_dir' already exists"
  echo "Are the dotfiles already installed?"
  exit 1
fi

echo "> Cloning repository..."
git clone --quiet --bare https://github.com/weibeld-setup/install-dotfiles "$git_dir"

# Files and dirs in repo, sorted by type (dir or file), dirs end with "/"
repo_files=($(git --git-dir "$git_dir" ls-tree --format '%(objecttype) %(path)' HEAD | sed 's/^blob /f /;s/^tree /d /;/^d/ s/$/\//' | sort | sed 's/^[fd] //'))
conflict_files=()
for f in "${repo_files[@]}"; do
  [[ -e ~/"$f" ]] && conflict_files+=("$f")
done
if [[ "${#conflict_files[@]}" -gt 0 ]]; then
  echo "> The following files and directories already exist in $HOME:"
  for f in "${conflict_files[@]}"; do
    echo "  - $f"
  done
  echo "> If you proceed, the above files will be overwritten by the repo files,"
  echo "  and the above directories will be merged with the repo directories."
  read -p "> Proceed (Y/n)? " response
  if [[ "$response" =~ n|N ]]; then
    echo "> Deleting cloned repository..."
    rm -rf "$git_dir"
    echo "> Exiting (no changes have been applied)"
    exit
  fi
fi

# Check out files/dirs
# Note: if there are submodules, .gitmodules is checked out to the workspace
echo "> Checking out files and directories:"
for f in "${repo_files[@]}"; do
  echo "  - $f"
done
git --git-dir="$git_dir" --work-tree="$work_tree" checkout -f

# Check out submodules
submodules=($(git --git-dir="$git_dir" --work-tree="$work_tree" submodule status | awk '{print $2}'))
if [[ "${#submodules[@]}" -gt 0 ]]; then
  echo "> Checking out submodules:" 
  for s in "${submodules[@]}"; do
    echo "  - $(basename $s)"
    git --git-dir="$git_dir" --work-tree="$work_tree" submodule --quiet update --init "$s"
  done
fi

# Set config option for local repo to omit untracked files from 'git status'
git --git-dir="$git_dir" --work-tree="$work_tree" config status.showUntrackedFiles no
