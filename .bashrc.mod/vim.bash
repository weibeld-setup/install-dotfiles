# Vim
#==============================================================================#

# If Neovim is installed, use Neovim
if _is-installed nvim; then
  alias vim=nvim
fi 

# Set EDITOR to what's behind 'vim' (alias or not)
if _is-alias vim; then
  export EDITOR=${BASH_ALIASES[vim]}
else
  export EDITOR=vim
fi

# Open a .vimrc* file in Vim
vre() {
  _ensure-installed fzf || return 1
  local select=$(basename ~/.vimrc* | sed 's/^/~\//' | fzf -e --tac | sed "s|~|$HOME|")
  if _is-set "$select"; then
    vim "$select"
  fi
}
