#!/usr/bin/env bash

set -e

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

echo "> Cloning repository..."
git clone --quiet --bare https://github.com/weibeld-setup/install-dotfiles "$git_dir"

# List files/dirs that will be replaced by checkout
# If --work-tree is present, output is empty
#repo_files=($(git --git-dir="$git_dir" --work-tree="$work_tree" ls-tree --name-only HEAD))
repo_files=($(git --git-dir="$git_dir" ls-tree --name-only HEAD))
conflict_files=()
for f in "${repo_files[@]}"; do
  [[ -e ~/"$f" ]] && conflict_files+=("$f")
done
if [[ "${#conflict_files[@]}" -gt 0 ]]; then
  echo "> The following files and directories will be overwritten:"
  for f in "${conflict_files[@]}"; do
    echo "  - $HOME/$f"
  done
  read -p "> Proceed (Y/n)? " response
  if [[ "$response" =~ n|N ]]; then
    echo "> Deleting cloned repository..."
    rm -rf "$git_dir"
    echo "> Exiting (no changes have been applied)"
    exit
  fi
fi

# Delete files/dirs that will be replaced (prevents dirs from merging)
for f in "${conflict_files[@]}"; do
  rm -rf "$f"
done

# Check out files/dirs
# Note: if there are submodules, .gitmodules is checked out to the workspace too
echo "> Checking out files and directories:"
for f in "${repo_files[@]}"; do
  echo "  - $HOME/$f"
done
git --git-dir="$git_dir" --work-tree="$work_tree" checkout

# Check out submodules
submodules=($(git --git-dir="$git_dir" --work-tree="$work_tree" submodule status | awk '{print $2}'))
if [[ "${#submodules[@]}" -gt 0 ]]; then
  echo "> Checking out submodules:" 
  for s in "${submodules[@]}"; do
    echo "  - $s..."
    git --git-dir="$git_dir" --work-tree="$work_tree" submodule --quiet update --init "$s"
  done
fi

# Omit files that are not part of the repository in 'git status' output
git --git-dir="$git_dir" --work-tree="$work_tree" config status.showUntrackedFiles no
