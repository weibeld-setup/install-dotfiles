# Grip
# Description:
#   Sets up Grip [1] to use a GitHub personal access token in order to avoid
#   the rate limit for anonymous users.
# References:
#   [1] https://github.com/joeyespo/grip
# Requirements:
#   - Grip
#     - Command: grip
#     - URL: https://github.com/joeyespo/grip
#==============================================================================#

#------------------------------------------------------------------------------#
# Set up a GitHub personal access token for Grip in order to avoid the rate
# limit for anonymous users. The token should be a CLASSIC personal access
# token, which can be created on GitHub on:
#
#   Settings > Developer Settings > Personal access tokens > Tokens (classic)
#
# The token does NOT need any of the permission scopes listed by the GitHub
# user interface when creating the token.
#------------------------------------------------------------------------------#

dir=~/.config/grip
file_username=$dir/github-username
file_token=$dir/github-personal-access-token

if [[ ! -f "$file_username" || ! -f "$file_token" ]]; then
  echo "Grip setup:"
  read -p "  > GitHub username: " username
  read -p "  > GitHub personal access token (classic): " token
  mkdir -p "$dir"
  echo "$username" >"$file_username"
  echo "$token" >"$file_token"
  echo "Data saved in directory '$(echo "$dir" | _filepath-insert-tilde)'"
  unset username token
fi

alias grip='grip --user "$(cat "'$file_username'")" --pass "$(cat "'$file_token'")"'

unset dir file_username file_token
