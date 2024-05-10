# APT
# Description:
#   Utility functions for the Advanced Package Tool (APT) package management
#   system.
# References:
#   [1] https://wiki.debian.org/Apt
# Dependencies:
#   - APT
#     - Command: apt
#     - URL: https://wiki.debian.org/Apt
#==============================================================================#

if ! _is-pkg-mgmt-apt; then
  # TODO: signalise error/warning "module dependency unsatisfied"
  :
fi

checkdep() {
  local dep=($(apt-cache depends "$1" | grep Depends: | cut -d : -f 2))
  for d in "${dep[@]}"; do
    echo -n "$d: "
   if dpkg -s "$d" 2>/dev/null | grep -q "Status: .* installed"; then
      echo installed
    else
      echo "NOT INSTALLED"
    fi
  done
}
