#!/usr/bin/env bash
# TODO:
#   - For some directories, such as ~/.config, merging would be better, as other
#     apps also put data there
#     - Either allow specifying for each directory whether it should be mreged
#       or replaced (complicated), or do one by default and the deleting or
#       merging must be done manually.
#     - Preferred solution: merge by default, and then directories which
#       should be replaced can simply be deleted before proceeding (simpler
#       than replacing by default and then the merged state must be manually
#       restored afterwards).
#   - In the conflict file output, mark more clearly which items are files
#     and which items are directories.

set -e

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

echo "> Cloning repository..."
git clone --quiet --bare https://github.com/weibeld-setup/install-dotfiles "$git_dir"

# Files and dirs in repo, sorted by type (dir/file), with dirs ending in /
repo_files=($(git --git-dir "$git_dir" ls-tree --format '%(objecttype) %(path)' HEAD | sed 's/^blob /f /;s/^tree /d /;/^d/ s/$/\//' | sort | sed 's/^[fd] //'))
conflict_files=()
for f in "${repo_files[@]}"; do
  [[ -e ~/"$f" ]] && conflict_files+=("$f")
done
if [[ "${#conflict_files[@]}" -gt 0 ]]; then
  echo "> The following files and/or directories already exist on the local system:"
  for f in "${conflict_files[@]}"; do
    echo "  - $HOME/$f"
  done
  echo "> If you proceed, the files from the repo will overwrite the above files"
  echo "  and the directories from the repo will be merged into above directories."
  read -p "> Proceed (Y/n)? " response
  if [[ "$response" =~ n|N ]]; then
    echo "> Deleting cloned repository..."
    rm -rf "$git_dir"
    echo "> Exiting (no changes have been applied)"
    exit
  fi
fi

# Delete files/dirs that will be replaced (prevents dirs from merging)
#for f in "${conflict_files[@]}"; do
#  rm -rf "$f"
#done

# Check out files/dirs
# Note: if there are submodules, .gitmodules is checked out to the workspace
echo "> Checking out files and directories:"
for f in "${repo_files[@]}"; do
  echo "  - $HOME/$f"
done
git --git-dir="$git_dir" --work-tree="$work_tree" checkout -f

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
