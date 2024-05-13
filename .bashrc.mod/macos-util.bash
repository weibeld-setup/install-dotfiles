# macOS Util
# Description:
#   Various utility functions for macOS.
# Dependencies:
#   - macOS
#==============================================================================#

export d=~/Desktop

# Recursively delete all .DS_Store files in the specified directory
rmds() {
  sudo find "${1:-.}" -type f \( -name .DS_Store -or -name ._.DS_Store \) -print -delete 2>/dev/null
  return 0
}

# Move one or more files or directories to the trash
trash() {
  for i in "$@"; do
    # mv fails if target directory already exists
    if ! mv "$i" ~/.Trash &>/dev/null; then
      rm -rf ~/.Trash/"$i"
      mv "$i" ~/.Trash
    fi
  done
}

# Hide hidden files in Finder
finder-hide-hidden-files() {
  defaults write com.apple.finder AppleShowAllFiles FALSE 
  killall Finder
}

# Show hidden files in Finder
finder-show-hidden-files() {
  defaults write com.apple.finder AppleShowAllFiles TRUE
  killall Finder
}

# Get the bundle ID (e.g. com.apple.Preview) of an application.
# Note: app names are case insensitive
app-id() {
  osascript -e "id of app \"$1\""
}
