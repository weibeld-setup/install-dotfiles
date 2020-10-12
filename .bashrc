# ~/.bashrc
# Sourced by non-login shells
# ----
# Login vs. non-login shells:
# - Login shell: when starting a new terminal window/tab (or tmux window/pane)
#       - Sources /etc/profile, ~/.bash_profile
# - Non-login shell: when starting a shell from within a shell
#       - Sources ~/.bashrc
# ----
# FAQ:
#
# Q: Why are the functions in ~/.bashrc and not ~/.bash_profile?
# A: Because we want them also in sub-shells of the current shell. If we start
#    a new shell from within a shell by typing "bash", a non-login shell gets
#    created. Non-login shells source only ~/.bashrc, but not ~/.bash_profile.
#
# Q: Why are variables that we set variables in ~/.bash_profile available in
#    sub-shells, if ~/.bash_profile does not get sourced by non-login shells?
# A: Because all variables set in ~/.bash_profile are "exported". This means
#    that they are automatically available in sub-shells, no matter whether
#    a shell sources ~/.bash_profile or not.
#
# Q: Why is the PATH variable not exported in ~/.bash_profile?
# A: Because in ~/.bash_profile, we don't create this variable, but it already
#    exists and we just modify it. The PATH variable is exported by the script
#    that creates it (e.g. /etc/profile). So, there's no need to re-export
#    PATH in ~/.bash_profile.
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Shell options
#------------------------------------------------------------------------------#

shopt -s extglob
shopt -s nullglob
set -o pipefail

#------------------------------------------------------------------------------#
# Base functions (used by other functions in this file)
#------------------------------------------------------------------------------#

# Is OS Mac or Linux?
is-mac()   { [[ "$OSTYPE" =~ darwin ]]; }
is-linux() { [[ "$OSTYPE" =~ linux  ]]; }

# Is variable set (non-empty) or unset (empty)?
is-set()   { [[ -n "$1" ]]; }
is-unset() { [[ -z "$1" ]]; }

# Does variable contain only whitespace characters?
is-nonblank() { [[ "$1" = *[^[:space:]]* ]]; }
is-blank() { ! is-nonblank "$1"; }

# Test whether an executable is installed, and print error message if it isn't.
ensure() {
  which -s "$1" || { echo "Error: '$1' not installed."; return 1; } 
}

# Capitalise the first letter of a string
capitalize () {
  echo $(echo "${1:0:1}" | tr '[:lower:]' '[:upper:]')"${1:1}"
}

# Convert lower-case to upper-case. Read input from arg list or stdin.
to-upper() { (($# == 0)) && __to-upper || __to-upper <<<"$@"; }
__to-upper() { tr '[:lower:]' '[:upper:]'; }

# Convert upper-case to lower-case. Read input from arg list or stdin.
to-lower() { (($# == 0)) && __to-lower || __to-lower <<<"$@"; }
__to-lower() { tr '[:upper:]' '[:lower:]'; }

# Pad args ($2...) with 0s to number of digits ($1). Read from arg list or stdin.
pad() {
  (($# == 0)) && return 1
  (($# == 1)) && __pad "$1" $(</dev/stdin) || __pad $@
}
__pad() { printf "%0$1s\n" ${@:2}; }

# Insert string ($2) into filename ($1), just before filename extension.
insert() {
  local file=$1; local str=$2
  echo "${file%.*}${str}.${file##*.}"
}

# Source file if exists.
s() { [[ -f "$1" ]] && . "$1"; }

# Create random alphanumeric string (only lower-case) of the specified length.
random() {
  length=${1:-16}
  [[ "$length" =~ ^[1-9][0-9]*$ ]] ||
    { echo "Argument must be positive integer"; return 1; }
  cat /dev/urandom | LC_ALL=C tr -dc a-z0-9 | head -c "$length"
}

# Read text from stdin and format it to width of terminal with word wrapping.
# This function is similar to the 'fmt' command, but it preserves all newlines.
format() {
  awk -v c=$(tput cols) 'BEGIN{printf ".pl 1\n.ll %d\n.na\n.hy 0\n", c}{print}' |
    nroff |
    sed 's/\xE2\x80\x90/-/g'
  # - awk adds nroff commands to beginning of input (.pl = page length,
  #   .ll = line length, .na=disable justification, hy 0 = disable hyphenation)
  # - nroff formats the text
  # - sed reverts the conversion of - to U+2010 (UTF-8 0xE28090) done by nroff
  # https://docstore.mik.ua/orelly/unix3/upt/ch21_03.htm
}

#------------------------------------------------------------------------------#
# Configure Readline
# https://www.gnu.org/software/bash/manual/html_node/Command-Line-Editing.html
#------------------------------------------------------------------------------#
bind 'set skip-completed-text on'

# Enable/disable vi line-editing mode (default is emacs)
vi-mode-on() {
  bind 'set editing-mode vi'  # Equivalen to set -o vi
  bind 'set show-mode-in-prompt on'
  bind 'set vi-ins-mode-string \1\033[1;32m@|\033[m\2'
  bind 'set vi-cmd-mode-string \1\033[1;42;37m@\033[;1;32m|\033[m\2'
  bind '"\C-k": vi-movement-mode'
}
vi-mode-off() {
  bind 'set editing-mode emacs'  # Equivalen to set +o vi
  bind 'set show-mode-in-prompt off'
}

#------------------------------------------------------------------------------#
# Prompt
#------------------------------------------------------------------------------#

PROMPT_COMMAND=__set-prompt
__set-prompt() {
  #PS1="$ " && return
  local EXIT_CODE=$?
  if is-mac; then
    PS1='\[\e[1;32m\]\v|\w$ \[\e[0m\]'
 else
    PS1='\[\e[1;33m\]\u@\h:\w$ \[\e[0m\]'
  fi
  [[ "$EXIT_CODE" -ne 0 ]] && PS1="\[\e[1;31m\]$EXIT_CODE|$PS1"
}

#------------------------------------------------------------------------------#
# bash-completion (installed with Homebrew)
#------------------------------------------------------------------------------#

if is-mac ; then
  source /usr/local/etc/profile.d/bash_completion.sh
  # Source completion scripts of Homebrew formulas
  for f in /usr/local/etc/bash_completion.d/*; do
    source "$f"
  done
fi

#------------------------------------------------------------------------------#
# complete-alias (https://github.com/cykerway/complete-alias)
#------------------------------------------------------------------------------#

source ~/.complete_alias

#------------------------------------------------------------------------------#
# Tmux (referenced from ~/.tmux.conf)
#------------------------------------------------------------------------------#

# Create tmux pane in current working directory
tmux-split-window-same-dir() {
  tmux split-window $1
  tmux send-keys "cd $PWD; clear" Enter
}

# Create tmux window in current working directory
tmux-new-window-same-dir() {
  tmux new-window
  tmux send-keys "cd $PWD; clear" Enter
}


#------------------------------------------------------------------------------#
# System management
#------------------------------------------------------------------------------#

alias br='vim ~/.bashrc'
alias bp='vim ~/.bash_profile'
alias sbr='. ~/.bashrc'
alias sbp='. ~/.bash_profile'
alias vr='vim ~/.vimrc'
alias rmf='rm -rf'
alias la="ls -a"
alias ll="ls -al"
alias ld="ls -d */"
alias wl='wc -l'
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
complete -F _complete_alias f
alias ssh='TERM=xterm-256color ssh'
alias torsocks='TERM=xterm-256color torsocks'
alias pgrep='pgrep -fl'
alias x='chmod +x'
alias X='chmod -x'
alias which='which -a'

# File sizes
alias dh='du -h'
alias ds='du | sort -k 1 -n -r'
alias dhm='du -h | grep M$"\t" | sort -k 1 -n -r'

# Print or remove completion specification of a command
alias comp='complete -p'
alias compr='complete -r'
complete -c comp compr

# Set default options
alias curl='curl -s'

# Print large directories in the current directory. The threshold for printing
# directories can be specified either as 'g' or 'm':
#   - 'g': print directories larger than 1 GB
#   - 'm': print directories larger than 1 MB
large-dirs() {
  threshold=${1:-g}
  case "$threshold" in
    g) pattern="G$(printf "\t")" ;;
    m) pattern="M$(printf "\t")\|G$(printf "\t")" ;;
  esac
  sudo du -h | grep "$pattern"
}

# Get public IP address of local machine
myip() {
  curl -s checkip.amazonaws.com
}

# Show local ports that are currently in use
ports() {
  lsof -i -P -n | grep LISTEN
}

# Show the help page of a shell builtin like man page
#help() { builtin help -m "$1" | less; }
#complete -b help 

# Show the source file and line where a function is defined
funcfile() {
  shopt -s extdebug
  declare -F "$1"
  shopt -u extdebug
}
complete -A function funcfile

# Interactively select a command from the history and execute it
hist() {
  ensure fzf || return 1
  eval $(history | fzf -n 2.. -e --no-sort --tac | sed 's/^ *[0-9][0-9]* *//')
}

# Change into the directory of the file pointed to by a symlink
cdl() {
  local t=$(readlink "$1")
  cd $([[ -f "$t" ]] && echo $(dirname "$t") || echo "$t")
}
complete -f cdl

# Create new directory and cd to it
mkcd() { mkdir "$1" && cd "$1"; }

# Move file by creating any intemediate dirs of the target, if they don't exist
mvp() { mkdir -p "$2" && mv "$1" "$2"; }

# Recursively list all the files in the specified directory.
listf() { local d=${1:-.}; find "${d%/}" -type f; }

# Recursively count the number of files in the specified directory.
countf () { listf "$1" | wc -l; }

# List all the dotfiles or dot-directories in the specified directory.
dotf() { local d=${1:-.}; __dotx "${d%/}" f; }
dotd() { local d=${1:-.}; __dotx "${d%/}" d; }
__dotx() { find "$1" -name '.*' -maxdepth 1 -type "$2" | xargs -Ix basename x; }

# Change the extension of a filename
chext() { echo "${1%.*}.$2"; }

# Print colours of this 256 colour terminal.
# Usage:
#   show-colors [delimiter] [#columns]
colors() {
  delim=${1:- }
  cols=$2
  for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i}${delim}"
    if is-set "$cols" && [[ $((($i + 1) % $cols)) = 0 ]]; then echo; fi
  done
}

# Dump the hexadecimal code of the provided string (output depends on the char
# encoding used by the terminal).
enc() { echo -n "$@" | hexdump | head -1 | cut -d ' ' -f 2-; }

# Print the character encoding used by the terminal
enc-type() { echo $LC_CTYPE; }


#------------------------------------------------------------------------------#
# Numbers
#------------------------------------------------------------------------------#

log2()  { bc -l <<<"l($1) / l(2)" ; }
log10() { bc -l <<<"l($1) / l(10)"; }

# Round number ($1) to specific number of digits ($2) after decimal point
round() { printf "%.$2f\n" "$1"; }

# Round number down to nearest integer
floor() { bc <<<"$1/1"; }

# Test if number is even or odd
even() { (($1 % 2 == 0)); }
odd()  { (($1 % 2 != 0)); }

# Convert numbers between numeral systems. Input read from stdin or arg list.
d2b() { __x2x 10  2 0    "$@"; }
d2o() { __x2x 10  8 0    "$@"; }
d2h() { __x2x 10 16 0    "$@"; }
b2d() { __x2x  2 10 0    "$@"; }
o2d() { __x2x  8 10 0    "$@"; }
h2d() { __x2x 16 10 0    "$@"; }
h2b() { __x2x 16  2 4    "$@"; }
h2o() { __x2x 16  8 0    "$@"; }
b2h() { __x2x  2 16 0.25 "$@"; }
o2h() { __x2x  8 16 0    "$@"; }
b2o() { __x2x  2  8 0.33 "$@"; }
o2b() { __x2x  8  2 3    "$@"; }
# Read input from stdin or arg list
__x2x() {
  (($# == 3)) && ____x2x "$@" $(</dev/stdin) || ____x2x "$@"
}
# Convert numbers and zero-pad based on number of digits and value of arg 3
____x2x() {
  local tok
  for tok in $(to-upper ${@:4}); do
    bc <<< "obase=$2; ibase=$1; $tok" | pad $(bc <<<"(${#tok}*$3)/1")
  done
}

# Print a number in binary, octal, decimal, and hexadecmial formats. The number
# can be provided as binary (0b...), octal (0...), decimal, or hexadecimal (0x...)
n() {
  local PAT_BIN='^0b([01]+)$'
  local PAT_OCT='^0([0-7]+)$'
  local PAT_DEC='^([1-9][0-9]*)$'
  local PAT_HEX='^0x([0-9a-fA-F]+)$'
  local PAT_0='^(0)$'
  local n
  # Convert number to decimal as an intermediary format
  if   [[ $1 =~ $PAT_HEX ]]; then n=$(h2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_BIN ]]; then n=$(b2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_OCT ]]; then n=$(o2d ${BASH_REMATCH[1]})
  elif [[ $1 =~ $PAT_DEC || $1 =~ $PAT_0 ]]; then n=${BASH_REMATCH[1]}
  else
    echo "Invalid number: $1" && return 1
  fi
  # Convert from decimal to other systems
  echo "Binary: $(d2b $n)"
  echo "Octal: $(d2o $n)"
  echo "Decimal: $n"
  echo "Hexadecimal: $(d2h $n)"
}

#------------------------------------------------------------------------------#
# Documents
#------------------------------------------------------------------------------#

# Merge PDF files with pdftk. Requires pdftk.
pdf-merge() {
  ensure pdftk || return 1
  pdftk "$@" cat output mymerged.pdf
}

# Extract the table of contents from a PDF file
pdf-toc() {
  ensure mutool || return 1
  local tab=$(printf '\t')
  # Extract TOC and delete page numbers separated from section titles by a tab
  mutool show "$1" outline | sed -E "s/${tab}[0-9]+\$//"
}

# Scale PDF files, i.e. shrink or enlarge them by maintaining the aspect ratio.
# Requires pdfScale.sh (https://github.com/tavinus/pdfScale).
# Usage: scale-pdf RATIO FILE...
pdf-scale() {
  local factor=$1
  shift
  # Output directory
  local dir="SCALED_$factor"
  mkdir -p "$dir"
  for f in "$@"; do
    # Original width and height of the PDF file in pts
    local tmp=$(pdfScale.sh -i "$f" | grep Points | cut -d '|' -f 2)
    local w=$(echo "$tmp" | cut -d x -f 1 | xargs)
    local h=$(echo "$tmp" | cut -d x -f 2 | xargs)
    # Target width and height
    local scaled_w=$(bc <<<"$factor * $w")
    local scaled_w=$(printf %.f $scaled_w)
    local scaled_h=$(bc <<<"$factor * $h")
    local scaled_h=$(printf %.f $scaled_h)
    # Scale
    echo "$f: ${w}x${h} pts ==> ${scaled_w}x${scaled_h} pts"
    pdfScale.sh -r "custom pt $(printf %.f $scaled_w) $(printf %.f $scaled_h)" "$f" "$dir/$(basename $f)"
  done
}

# Convert an audio file to the MP3 format. Requires ffmpeg.
to-mp3() {
  ensure ffmpeg || return 1
  ffmpeg -i "$1" -acodec libmp3lame "${1/.*/.mp3}"
}

#------------------------------------------------------------------------------#
# ImageMagick
#------------------------------------------------------------------------------#

# Get the size of an image in pixels
img-size() {
  ensure identify || return 1
  identify "$1"
}

# Crop an image to a specific size, optionally defining the upper left corner.
img-crop() {
  ensure convert || return 1
  if [[ $# -lt 3 ]]; then
    echo -e "${FUNCNAME[0]} file width height [top-offset] [left-offset] [out-file]"
    return
  fi
  file=$1
  w=$2
  h=$3
  x=${4:-0}
  y=${5:-0}
  out=${6:-$(insert "$file" "_cropped${w}x${h}")}
  convert -crop "${w}x${h}+${x}+${y}" "$file" "$out"
  echo "$out"
}

# Resize image. Usage: img-resize <file> <format> [<out_file>].
img-resize() {
  ensure convert || return 1
  local file=$1; local format=$2  # Format "50%" or "512x512"
  out_file=${3:-$(insert "$file" _resized)}
  convert "$file" -resize "$format" "$out_file"
}

# Read date a photo was taken from the photo's EXIF data.
img-date() {
  ensure identify || return 1
  identify -format %[exif:DateTimeOriginal] "$1"
}


#------------------------------------------------------------------------------#
# Git
#------------------------------------------------------------------------------#

alias gl='git log --decorate --graph' 
alias gr='git remote -v'
alias gs='git status -u'
alias ga='git add -A'
alias gc='git commit'
alias gce='git commit --allow-empty'
alias gp='git push'
alias gb="git branch"
alias gd="git diff"


#------------------------------------------------------------------------------#
# Docker
#------------------------------------------------------------------------------#

# Automatically set '--rm' flag when 'docker [container] run' is run
docker() {
  local args=("$@")
  if [[ "$1" = run ]]; then
    args=(run --rm "${args[@]:1}")
  elif [[ "$1" = container && "$2" = run ]]; then
    args=(container run --rm "${args[@]:2}")
  fi
  command docker "${args[@]}"
}

alias dk=docker
complete -F _complete_alias dk
alias dki='docker image ls'
#alias dkc='docker container ps -a'

# Remove ALL images
dkri() {
  local i=$(docker images -q)
  is-set "$i" && docker rmi -f $i || echo "No images"
}

# Remove only those images with a <none> name or tag
dkci() {
  local i=$(docker images | grep '<none>' | awk '{print $3}')
  is-set "$i" && docker rmi $i || echo "No unnamed/untagged images"
}

# Remove all containers
dkrc() {
  local c=$(docker ps -aq)
  is-set "$c" && docker rm $c || echo "No containers"
}

# Stop all running containers
dksc() {
  local c=$(docker ps -q)
  is-set "$c" && docker stop $c || echo "No running containers"
}

# Run a container in the host namespaces (allows to enter Docker Desktop VM)
docker-vm() {
  # The --pid=host flag starts the container in the same PID namespace as the
  # Docker Desktop VM. The nsenter -t 1 command then enters the specified name-
  # spaces of the process with PID 1 (root process on the Docker Desktop VM).
  # The entered namespaces are: mount (-m), UTS (-u), network (-n), IPC (-i).
  # (use the -a flag to enter all namespaces). All Linux namespaces: mount,
  # UTS, network, IPC, PID, cgroup, user.
  docker run -it --pid=host --privileged weibeld/ubuntu-networking nsenter -t 1 -m -u -n -i bash
}

#------------------------------------------------------------------------------#
# AWS CLI
#------------------------------------------------------------------------------#

alias ae='aws ec2'
complete -F _complete_alias ae



# Get availability zones of a region
aws-az() {
  local region=$1
  aws ec2 describe-availability-zones --region "$region" --query 'AvailabilityZones[*].ZoneName' --output text | tr '\t' '\n'
}

# Get AWS regions (for some reason doesn't return all regions)
aws-regions() {
  aws ec2 describe-regions --query 'Regions[*].RegionName' --output text | tr '\t' '\n'
}

# List EC2 instances in a given region with their private and public DNS names
aws-ec2() {
  local region=${1:-$(aws configure get region)}
  aws ec2 describe-instances --region "$region" --query 'Reservations[*].Instances[*].[InstanceId,PrivateDnsName,PublicDnsName]' --output text
}

alias cfn="aws cloudformation"

# List all CloudFormation export values in the default region
cfn-exports() {
  aws cloudformation list-exports --output json --query 'Exports[*].Name'
  #aws cloudformation list-exports --output json | jq -r '.Exports|.[]|.Name'
}

# Validate a template
cfn-validate() {
  aws cloudformation validate-template --template-body "$(cat  $1)"
}

# SAM package
smp() {
  sam package --template-file template.yml --output-template-file package.yml --s3-bucket quantumsense-sam
}

# SAM deploy
smd() {
  [[ -z "$1" ]] && { echo "Usage: smd STACK_NAME"; return 1; }
  sam deploy --template-file package.yml --capabilities CAPABILITY_IAM --stack-name "$1"
}
# SAM package and deploy
sm() {
  [[ -z "$1" ]] && { echo "Usage: smd STACK_NAME"; return 1; }
  smp && smd "$1"
}

# Get a secret from AWS Secrets Manager
aws-get-secret() {
  local NAME_OR_ARN=$1
  aws secretsmanager get-secret-value --secret-id "$NAME_OR_ARN" --query SecretString --output text 
}

# Create a secret in AWS Secrets Manager
aws-create-secret() {
  local NAME=$1
  local VALUE=$2
  local DESCRIPTION=$3  # Optional
  aws secretsmanager create-secret --name "$NAME" --secret-string "$VALUE" --description "$DESCRIPTION" --output json
}

# List all secrets in AWS Secrets Manager
aws-list-secrets() {
  RAW=$1
  if [[ "$RAW" = -r ]]; then
    aws secretsmanager list-secrets --query 'SecretList[*].{Name: Name, ARN: ARN, Description: Description}' --output json
  else
    aws secretsmanager list-secrets --query 'SecretList[*].[Name, Description]' --output table
  fi
}

# Delete a secret from AWS Secrets Manager
aws-delete-secret() {
  local NAME_OR_ARN=$1
  aws secretsmanager delete-secret --secret-id "$NAME_OR_ARN" --output json
}

# Search AMIs given a sequence of keywords that are matched against the name of
# the AMI. The order of the keywords is important. Thus, the keyword sequence
# ["foo" "bar"] will match "text-foo-text-bar-text", but ["bar" "foo"] will not.
aws-search-ami() {
  query=*
  for a in "$@"; do query=$query$a*; done
  aws ec2 describe-images --filters "Name=name,Values=$query" --query 'Images[*].[Name,ImageId]' --output text
}

#------------------------------------------------------------------------------#
# Kubernetes
#------------------------------------------------------------------------------#

# Display outputs of certain commands in terminal pager (less)
kubectl() {
  if
    [[ "$1" = explain || "$1" = describe ]] ||
    [[ "$*" =~ -o\ yaml|--output[=\ ]yaml ]]
  then
    command kubectl "$@" | less
  elif
    [[ "$*" =~ -h$|--help$ ]]
  then
    command kubectl "$@" | format | less
  else
    command kubectl "$@"
  fi
}

# Get current context
alias krc='kubectl config current-context'
# List all contexts
alias klc='kubectl config get-contexts -o name | sed "s/^/  /;\|^  $(krc)$|s/ /*/"'
# Change current context
alias kcc='kubectl config use-context "$(klc | fzf -e | sed "s/^..//")"'

# Get current namespace
alias krn='kubectl config get-contexts --no-headers "$(krc)" | awk "{print \$5}" | sed "s/^$/default/"'
# List all namespaces
alias kln='kubectl get -o name ns | sed "s|^.*/|  |;\|^  $(krn)$|s/ /*/"'
# Change current namespace
alias kcn='kubectl config set-context --current --namespace "$(kln | fzf -e | sed "s/^..//")"'

# Run a busybox container in the cluster 
alias kbb='kubectl run busybox --image=busybox:1.28 --rm -it --command --restart=Never --'

alias kga='kubectl get all'

# kubectl explain
alias ke='kubectl explain'
complete -F _complete_alias ke


# Show information about a specific API resource
alias kr='kubectl api-resources | grep '

# Set, unset, and print the KUBECONFIG environment variable
skc() { export KUBECONFIG=$1; }
dkc() { unset KUBECONFIG; }
pkc() { echo "$KUBECONFIG"; }

# Open kubeconfig file for editing
alias kc='vim ~/.kube/config'

# Delete similarly-named context, cluster, and user entries from kubeconfig file
kc-delete() {
  kubectl config unset contexts."$1"
  kubectl config unset clusters."$1"
  kubectl config unset users."$1"
}

# Show events for a resource specified by name
kge() {
  name=$1 && shift
  kubectl get events \
    --field-selector=involvedObject.name="$name" \
    --sort-by=lastTimestamp \
    -o custom-columns='KIND:involvedObject.kind,TIME:lastTimestamp,EMITTED BY:source.component,REASON:reason,MESSAGE:message' \
    "$@"
}

# List container images of each pod
kim() {
  kubectl get -o custom-columns='POD:.metadata.name,IMAGES:.spec.containers[*].image' pods
}

# Show the availability zone of each node
kaz() {
  kubectl get nodes -o custom-columns='NODE:metadata.name,ZONE:metadata.labels.failure-domain\.beta\.kubernetes\.io/zone'
}

# Show the node each pod is scheduled to
kno() {
  kubectl get pods -o custom-columns='POD:.metadata.name,NODE:.spec.nodeName' "$@"
}

# Show volume ID and availability zone of all awsElasticBlockStore volume
kpv-aws() {
  kubectl get pv -o custom-columns='PERSISTENT VOLUME:.metadata.name,VOLUME ID:.spec.awsElasticBlockStore.volumeID,AVAILABILITY ZONE:.metadata.labels.failure-domain\.beta\.kubernetes\.io/zone'
}

# Display information about the authorisation mode of the current cluster
kauthz() {
  kubectl cluster-info dump | grep authorization-mode | sed 's/^ *"//;s/",$//' ||
    kubectl api-versions | grep authorization
}

# List all (Cluster)RoleBindings with their role and subjects
kbindings() {
  local spec=NAME:metadata.name,ROLE:roleRef.name,SUBJECTS:subjects[*].name
  local preamble=KIND:kind,NAMESPACE:metadata.namespace
  [[ "$1" = -l ]] && spec=$preamble,$spec
  kubectl get rolebindings,clusterrolebindings --all-namespaces -o custom-columns="$spec"
}

kbindings2() {
  kubectl get rolebindings,clusterrolebindings \
    --all-namespaces \
    -o custom-columns='KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,SERVICE ACCOUNTS:subjects[?(@.kind=="ServiceAccount")].name'
}

# Run a one-off Pod with a shell in the cluster
kru() {
  local sa=${1:-default}
  kubectl run --serviceaccount="$sa" --image=weibeld/alpine-curl --generator=run-pod/v1 -ti --rm alpine
}

# Create temporary ServiceAccount in default namespace with cluster-admin rights
ksa() {
  if [[ "$1" = -d ]]; then
    kubectl delete -n default sa/tmp-admin clusterrolebinding/tmp-admin
  else
    kubectl create sa -n default tmp-admin
    kubectl create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:tmp-admin tmp-admin 
  fi
}

# kubectl-aliases (https://github.com/ahmetb/kubectl-aliases)
if [[ -f ~/.kubectl_aliases ]]; then
  source ~/.kubectl_aliases
  # Enable completion for aliases (depends on complete-alias)
  for _a in $(sed '/^alias /!d;s/^alias //;s/=.*$//' ~/.kubectl_aliases); do
    complete -F _complete_alias "$_a"
  done
fi

# https://github.com/kubermatic/fubectl
#[ -f ~/.fubectl ] && source ~/.fubectl

#------------------------------------------------------------------------------#
# Google Cloud Platform (GCP)
#------------------------------------------------------------------------------#

# SSH into a GCP compute instance.
gssh() {
  # Prevents "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"
  ssh-keygen -R "${1##*@}"
  ssh -i ~/.ssh/google_compute_engine -o StrictHostKeyChecking=no "$@"
}

alias gcil='gcloud compute instances list'

#------------------------------------------------------------------------------#
# Prometheus
#------------------------------------------------------------------------------#

# Display only the distinct metric names from a page of Prometheus metrics
prom-distinct() {
  sed '/^#/d;s/[{ ].*$//' | uniq
}

#------------------------------------------------------------------------------#
# Terraform
#------------------------------------------------------------------------------#

# Terraform autocompletion (installed with terraform --install-autocomplete)
complete -C /usr/local/bin/terraform terraform

alias tf=terraform
#complete -F _complete_alias t

alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfay='terraform apply --auto-approve'
alias tfdy='terraform destroy --auto-approve'

#------------------------------------------------------------------------------#
# macOS and Linux specific functions
#------------------------------------------------------------------------------#
if is-mac; then

  # Recursively delete all .DS_Store files in the current directory
  alias rmds='find . -type f \( -name .DS_Store -or -name ._.DS_Store \) -delete'

  # Make Finder hiding hidden files, e.g. dotfiles (default)
  finder_hide() {
    defaults write com.apple.finder AppleShowAllFiles FALSE
    killall Finder
  }

  # Make Finder displaying hidden files
  finder_show() {
    defaults write com.apple.finder AppleShowAllFiles TRUE
    killall Finder
  }

  # Permanently disable the Mac startup sound
  disable_startup_sound() {
    sudo nvram SystemAudioVolume=%80  # %80 = 0x80 (hex) = 128 (dec)
  }

  # Permanently re-enable the Mac startup sound
  enable_startup_sound() {
    sudo nvram -d SystemAudioVolume
  }

  # Get the bundle ID (e.g. com.apple.Preview) of an application
  app-id() {
    local app_name=$1
    osascript -e "id of app \"$app_name\""
  }

  # Convert a date string in a specific format to a UNIX timestamp in seconds.
  # If the date string doesn't include a time, the current time is assumed.
  #   Usage:   date2ts <date> <date_format>
  #   Example: date2ts "2016-02-02 13:21:45" "%Y-%m-%d %H:%M:%S"
  date2ts() {
    date -j -f "$2" "$1" '+%s'
    # Note: -j: disable setting of system date, -f: format of input date
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optinally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  #   Usage: ts2date <timestamp> [<out_format>]
  ts2date() {
    if is_set "$2"; then date -r "$1" "$2"
    else                 date -r "$1"
    fi
  }

  # Copy the content of the supplied file to the clipboard
  clip() {
    cat "$1" | pbcopy
  }

elif is-linux; then

  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

  # Customise keyboard layout with setxkbmap:
  #   - Add Swiss German keyboard layout
  #   - Swap Caps-Lock and Ctrl keys
  #   - Set key combination for toggling between keyboard layouts
  # All the options and keyboard layouts of setxkbmap can be found in the file
  # ==> /usr/share/X11/xkb/rules/base.lst
  # Notes:
  # - The settings made by setxkbmap do NOT persists across logins
  # - To make the settigns persistent, one option would be to put the setxkbmap
  #   commands directly into ~/.bashrc. However, this may cause an X error
  #   (cannot open display "default display")
  # - Another option would be to put the setxkbmap commands into ~/.xinitrc or
  #   /etc/X11/xorg.conf.d/00-keyboard.conf (different syntax). However, there
  #   are inconsistencies across systems, and different desktop environments
  #   read these files in different ways
  # - Because of the above problems, the setxkbmap commands are provided here
  #   as a function that can be called manually
  # Source: https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
  #         http://betabug.ch/blogs/ch-athens/1242
  config_keyboard() {
    if $(which setxkbmap); then
      # Set Swiss German and German as keyboard layouts (ch(de) is default)
      setxkbmap 'ch(de),de'
      # Left Alt-Shift for toggling between keyboard layouts
      setxkbmap -option grp:lalt_lshift_toggle
      # Swap Caps-Lock and Ctrl keys
      setxkbmap -option ctrl:swapcaps
    else
      echo "Error: setxkbmap is not installed."
    fi
  }

  # Convert a date string to a UNIX timestamp in seconds. The date string format
  # is the one described in the 'date' man page as '--date=STRING'.
  #   Usage: date2ts <date>
  date2ts() {
    date -d "$1" '+%s'
  }

  # Convert a UNIX timestamp in seconds to a date string. The format of the
  # output date string can be optionally specified (e.g. '+%Y-%m-%d %H:%M:%S').
  #   Usage: ts2date <timestamp> [<out_format>]
  ts2date() {
    if is_set "$2"; then date -d "@$1" "$2"
    else                 date -d "@$1"
    fi
  }

  # Check if the dependencies of a Debian package are installed
  checkdep() {
    dep=($(apt-cache depends "$1" | grep Depends: | cut -d : -f 2))
    for d in "${dep[@]}"; do
      echo -n "$d: "
     if dpkg -s "$d" 2>/dev/null | grep -q "Status: .* installed"; then
        echo installed
      else
        echo "NOT INSTALLED"
      fi
    done
  }
fi

#------------------------------------------------------------------------------#
# Misc
#------------------------------------------------------------------------------#

alias asciicast2gif='docker run --rm -v "$PWD":/data asciinema/asciicast2gif'
# Authenticate with SSH key
alias ssh-nine='ssh -i ~/.ssh/nine weibeld@weibeld.nine.ch'
# Authenticate with LDAP password and OTP from Google Authenticator
alias ssh-nine-login-server='ssh weibeld@login.nine.ch'

pw() {
  if ! which -s aws; then
    echo "You must install the AWS CLI to use this command"
    return 1
  fi
  LENGTH=${1:-32}
  aws secretsmanager get-random-password --exclude-punctuation --password-length "$LENGTH" --query RandomPassword --output text
}

anker() { ssh wk41@anker.inf.unibe.ch; }
#boyle() { torsocks ssh charles@63alsiqho43t37nfoavp3bctz55bjf4bmcicdt2qtmet6cmufx2juzqd.onion -p 30022; }
boyle() { ssh charles@130.92.63.21; }

#------------------------------------------------------------------------------#
# Ensure exit code 0 for the command that sources this file
#------------------------------------------------------------------------------#


return 0

