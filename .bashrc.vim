# ~/.bashrc.vim

#------------------------------------------------------------------------------#
# Vim/Neovim
#------------------------------------------------------------------------------#

# If Neovim is installed, use it by default instead of Vim
if _is-installed nvim; then
  alias vim=nvim
else
  # On macOS, if no Neovim but Homebrew Vim, use Homebrew Vim
  if _is-mac && _is-installed-homebrew vim; then
    alias vim=$(brew --prefix)/bin/vim
  fi
fi
