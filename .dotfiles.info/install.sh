#!/usr/bin/env bash

set -e

check-name-conflicts() {
  echo "> Checking for name conflicts in '$work_tree'..."
  conflict_files=()
  for f in "${repo_files[@]}"; do
    [[ -e ~/"$f" ]] && conflict_files+=("$f")
  done
  if [[ "${#conflict_files[@]}" -gt 0 ]]; then
    echo "> The following directories/files already exist in '$work_tree':"
    for f in "${conflict_files[@]}"; do
      echo "    $f"
    done
    echo "> You have the following options:"
    echo "  1) Overwrite conflicting files (directories will be merged)"
    echo "  2) Launch dialog to back up conflicting files, then proceed with (1)"
    echo "  3) Rerun the name conflicts check"
    echo "  4) Abort the installation (no changes will be applied)"
    prompt
  fi
}

prompt() {
  read -p "> Reponse: " response
  case "$response" in
    1) ;;
    2)
      read -p "> Backup directory (default '$work_tree/.dotfiles.backup'): " response
      backup_dir=${response:-$work_tree/.dotfiles.backup}
      echo "> Copying directories/files to '$backup_dir':"
      mkdir -p "$backup_dir" || { echo "> Error creating backup directory"; prompt; }
      for f in "${conflict_files[@]}"; do
        echo "    $work_tree/$f => $backup_dir/$f"
        cp -r "$work_tree/${f%/}" "$backup_dir" 2>/dev/null
      done
      ;;
    3) check-name-conflicts ;;
    4)
      echo "> Aborting..."
      rm -rf "$git_dir"
      exit
      ;;
    *) prompt ;;
  esac
}

# Git repository directory (.git directory)
git_dir=$HOME/.dotfiles.git
# Workspace directory (where files are checked out)
work_tree=$HOME

if [[ -d "$git_dir" ]]; then
  echo "Error: the directory '$git_dir' already exists"
  echo "> Are the dotfiles already installed?"
  exit 1
fi

echo "> Cloning repository into '$git_dir'..."
git clone --quiet --bare https://github.com/weibeld-setup/install-dotfiles "$git_dir"

# Files and dirs in repo, sorted by type (dir or file), dirs end with "/"
repo_files=($(git --git-dir "$git_dir" ls-tree --format '%(objecttype) %(path)' HEAD | sed 's/^blob /f /;s/^tree /d /;/^d/ s/$/\//' | sort | sed 's/^[fd] //'))

# Checking for name conflicts with local files and directories
check-name-conflicts

# Check out files/dirs
# Note: if there are submodules, .gitmodules is checked out to the workspace
echo "> Checking out files and directories to '$work_tree':"
for f in "${repo_files[@]}"; do
  echo "    $f"
done
git --git-dir="$git_dir" --work-tree="$work_tree" checkout -f

# Check out submodules
submodules=($(git --git-dir="$git_dir" --work-tree="$work_tree" submodule status | awk '{print $2}'))
if [[ "${#submodules[@]}" -gt 0 ]]; then
  echo "> Checking out submodules:" 
  for s in "${submodules[@]}"; do
    echo "    $(basename $s)"
    git --git-dir="$git_dir" --work-tree="$work_tree" submodule --quiet update --init "$s"
  done
fi

# Set config option for local repo to omit untracked files from 'git status'
git --git-dir="$git_dir" --work-tree="$work_tree" config status.showUntrackedFiles no
