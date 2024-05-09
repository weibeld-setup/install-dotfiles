# Homebrew
#==============================================================================#

# Set Homebrew environment variables (including PATH)
eval $(brew shellenv)

# Clean PATH
_path-uniq
_path-rectify

# Disable automatic updating of packages
export HOMEBREW_NO_AUTO_UPDATE=1
