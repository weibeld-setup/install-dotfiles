# ~/.bashrc.azure

#==============================================================================#
## Indicate sourcing of file
#==============================================================================#
export SOURCED_BASHRC_TOPIC_AZURE=1

#------------------------------------------------------------------------------#
# Azure
#------------------------------------------------------------------------------#

# List all currently known Azure users (e.g. Microsoft accounts)
az-users() {
  az account list --all --query "[*].user.name" -o tsv | sort | uniq
}

# List the subscriptions for a specific user
az-subscriptions() {
  local user=${1:-$(az-users | fzf)}
  az account list --all --query "[?user.name=='$user']"
}

# List the tenants, includings its subscriptions, for a specific user
az-tenants() {
  local user=${1:-$(az-users | fzf)}
  local json=$(az account list --all --query "[?user.name=='$user']" -o json)
  for t in $(echo "$json" | jq -r '.[] | .tenantId' | sort |  uniq); do
    [[ -t 1 ]] && echo "$(_sgr bold)$t$(_sgr)" || echo "$t"
    echo "$json" | jq -r '.[] | select(.tenantId == "'$t'") | "  \(if .isDefault then "*" else "-" end) \(.name)\n    \(.id)"'
  done
}

# TODO: add similar commands for tenants when 'az account tenant' is out of preview

# Recursively list referenced templates in an Azure Pipelines file.
# Usage:
#   azure-pipeline-templates <file>...
# Depends on:
#   realpath (brew install coreutils)
azure-pipeline-templates() {
  for file in "$@"; do
    __azure-pipeline-templates "${file#./}" 0
  done
}
__azure-pipeline-templates() {
  local path=$1
  local depth=$2
  [[ ! -f "$path" ]] && { c-echo red "Error: file not found: $path"; return; }
  [[ "$depth" -gt 0 ]] && printf '|   %.0s' $(seq "$depth")
  echo "$path"
  local refs=$(sed -n '/[ -]*template:\s/s/^[ -]*template:\s*\([a-zA-Z0-9/._-]*\.yaml\).*$/\1/p' "$path")
  [[ -z "$refs" ]] && return
  for ref in $(realpath --relative-to "$PWD" $(sed "s|^|$(dirname "$path")/|" <<<"$refs") | awk '!seen[$0]++'); do
    __azure-pipeline-templates "$ref" "$(($depth+1))"
  done
}

