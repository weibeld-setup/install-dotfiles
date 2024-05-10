# Terraform

# Aliases
alias tf=terraform
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfaa='terraform apply --auto-approve'
alias tfdd='terraform destroy --auto-approve'

# Enable command completion
if _is-mac && _is-cmd brew; then
  complete -C $(brew --prefix)/bin/terraform terraform
elif _is-linux; then
  complete -C /usr/bin/terraform terraform
fi
