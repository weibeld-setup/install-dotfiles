# ~/.bashrc.aws
#
# Utility functions and settings for the AWS CLI.
#------------------------------------------------------------------------------#

#==============================================================================#
## Indicate sourcing of file
#==============================================================================#
export SOURCED_BASHRC_TOPIC_AWS=1

# Enable command completion
if _is-mac && _is-cmd brew; then
  complete -C $(brew --prefix)/bin/aws_completer aws
elif _is-linux; then
  complete -C aws_completer aws
fi

#------------------------------------------------------------------------------#
# areg
#------------------------------------------------------------------------------#
# List AWS regions including opt-in status.
# Usage:
#   areg [-c] [region...]
# Examples:
#   areg
#   areg -c
#   areg us-west-1 us-west-2
#   areg eu- us-
# If no regions are specified, then all regions are listed. The -c option
# outputs the result in CSV format. Regions may be specified with substrings
# that may match multiple regions (e.g. "eu-", "us-", etc.).
# Notes:
#   - Since 2019, new regions have to be explicitly enabled [1]
#   - Region names are hardcoded in the function body and must be manually
#     udpated when new AWS regions become available 
#   - Full list of regions including full region names can be found in [2]
# [1] https://docs.aws.amazon.com/general/latest/gr/rande-manage.html
# [2] https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions
areg() {
  # Parse command-line arguments
  if _array-has "$@" -c; then
    local output_csv=1
  fi
  local -a regions
  _array-remove "$@" -c regions
  # Retrieve all regions in CSV format
  local csv=$(
    aws ec2 describe-regions \
      --no-cli-auto-prompt \
      --output json \
      --all-regions \
      --query 'Regions[].[RegionName,OptInStatus]' |
    jq -r '.[] | join(",")' |
    sed '
      s/,opted-in/,Enabled,Opted-in/;
      s/,opt-in-not-required/,Enabled,Default/;
      s/,not-opted-in/,Disabled,Opt-in possible/' |
    sed '
      s/^af-south-1,/\0Cape Town,/;
      s/^ap-east-1,/\0Hong Kong,/;
      s/^ap-northeast-1,/\0Tokyo,/;
      s/^ap-northeast-2,/\0Seoul,/;
      s/^ap-northeast-3,/\0Osaka,/;
      s/^ap-south-1,/\0Mumbai,/;
      s/^ap-south-2,/\0Hyderabad,/;
      s/^ap-southeast-1,/\0Singapore,/;
      s/^ap-southeast-2,/\0Sydney,/;
      s/^ap-southeast-3,/\0Jakarta,/;
      s/^ap-southeast-4,/\0Melbourne,/;
      s/^ca-central-1,/\0Central,/;
      s/^ca-west-1,/\0Calgary,/;
      s/^eu-central-1,/\0Frankfurt,/;
      s/^eu-central-2,/\0Zurich,/;
      s/^eu-north-1,/\0Stockholm,/;
      s/^eu-south-1,/\0Milan,/;
      s/^eu-south-2,/\0Spain,/;
      s/^eu-west-1,/\0Ireland,/;
      s/^eu-west-2,/\0London,/;
      s/^eu-west-3,/\0Paris,/;
      s/^il-central-1,/\0Tel Aviv,/;
      s/^me-central-1,/\0UAE,/;
      s/^me-south-1,/\0Bahrain,/;
      s/^sa-east-1,/\0São Paulo,/;
      s/^us-east-1,/\0North Virginia,/;
      s/^us-east-2,/\0Ohio,/;
      s/^us-west-1,/\0North California,/;
      s/^us-west-2,/\0Oregon,/' |
    sort
  )
  # Filter desired regions in CSV format
  local grep_pattern=$(_array-join "${regions[@]}" '\|')
  local csv_filtered=$(echo "$csv" | grep -- "$grep_pattern")
  # Output result either as CSV or pretty table
  if _is-set "$output_csv"; then
    echo "$csv_filtered"
  else
    echo "$csv_filtered" |
    column -t -s , |
    sed "s/Default/$(_sgr black+)\0$(_sgr)/;s/Enabled/$(_sgr green)\0$(_sgr)/;s/Disabled/$(_sgr red)\0$(_sgr)/" |
    nl -w 2 -s '  '
  fi
}

#------------------------------------------------------------------------------#
# aaz
#------------------------------------------------------------------------------#
# List availability zones (AZs) of one or more regions.
# Usage:
#   aaz [-c] [region...]
# Examples:
#   aaz
#   aaz -c
#   aaz us-west-1 us-west-2
#   aaz eu- us-
# If no regions are specified, then the AZs of all regions are listed. The -c
# option outputs the result in CSV format. Regions may be specified with 
# substrings that may match multiple regions (e.g. "eu-", "us-", etc.).
aaz() {
  # Parse command-line arguments
  if _array-has "$@" -c; then
    local output_csv=1
  fi
  local -a region_patterns
  _array-remove "$@" -c region_patterns
  # Create full list of desired regions
  local grep_pattern=$(_array-join "${region_patterns[@]}" '\|')
  local all_regions=$(
    aws ec2 describe-regions \
      --no-cli-auto-prompt \
      --output text \
      --all-regions \
      --query 'Regions[].[RegionName]' | sort
  )
  local selected_regions=($(echo "$all_regions" | grep -- "$grep_pattern"))
  # Formatting settings
  if _is-set "$output_csv"; then
    local delim=,
  else
    local delim=' | '
    # Length of longest region string (for aligning columns)
    local max=$(awk -v RS=" " '{ if (length > max) max = length } END { print max }' <<<$(echo -n "${selected_regions[@]}"))
    local i=1
  fi
  # Cycle through all selected regions
  for r in "${selected_regions[@]}"; do
    # Print region name
    if _is-set "$output_csv"; then
      echo -n "$r,"
    else
      echo -n "$(_pad-left 2 ' ' "$i")  $(_pad-right "$max" ' ' "$r")  "
      i=$(("$i"+1))
    fi
    # Query availability zone for region
    local response=$(
      aws ec2 describe-availability-zones \
        --no-cli-auto-prompt \
        --output json \
        --query 'AvailabilityZones[].ZoneName' \
        --region "$r" 2>/dev/null
    )
    # Detect disabled regions (which cannot be queried)
    local na='Region disabled'
    if ! _is-set "$response"; then
      local value=$na
    # Format response
    else
      local value=$(echo "$response" | jq -r "sort | join(\"$delim\")")
    fi
    # Output
    if _is-set "$output_csv"; then
      echo "$value"
    else
      echo "$value" | sed "s|$na|$(_sgr red)\0$(_sgr)|"
    fi
  done
}

#------------------------------------------------------------------------------#
# aami
#------------------------------------------------------------------------------#
# List AMIs that match a given name pattern in the current region. Pattern
# matching may be skipped by using '-' as the pattern. This allows to either
# list all AMIs or look up specific AMIs by their IDs (with --image-ids). The
# AMIs are sorted by creation date with the newest at the bottom. Additional
# arguments for the 'describe-images' command may be supplied (e.g. --region,
# --owner, --image-ids).
# Usage:
#   aami <pattern>|- [args...]
# Examples:
#   aami '*ubuntu*22.10*'
#   aami '*ubuntu*22.10*' --region eu-central-1
#   aami '*ubuntu*22.10*' --owner 099720109477
#   aami - --image-ids ami-07ba2051dbeeac4b7 ami-024dbc4111461f2f9
#   aami -
# Notes:
#   - For server-side (--filters) and client-side (--query) filtering, see [1].
#   - Client-side filtering uses JMESPath [2]. For sort_by(), see [3].
#   - 099720109477 is Canonical's owner ID. Owner IDs are stable across regions.
# [1] https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html
# [2] https://jmespath.org/
# [3] https://jmespath.org/specification.html#sort-by

# List AMIs matching a sequence of keywords.
# Usage:
#   aami <keywords>... [-- <args>...]
# Examples:
#   aami ubuntu 23.10
#   aami ubuntu 23.10 -- --region eu-central-1 --owner 123456789
#
aami() {
  # Parse command-line arguments
  local -a keywords args
  _splitargs keywords args -- "$@"
  # Construct filter expressions
  local -a filters_name filters_description 
  for e in "${keywords[@]}"; do
    local E=$(_to-title-case "$e")
    filters_name+=("Name=name,Values=*$e*,*$E*")
    filters_description+=("Name=description,Values=*$e*,*$E*")
  done
  # Make two queries with filters against 'name' and 'description' fields, 
  # combine results (OR), and sort results by creation date (newest first)
  local results=$(
    {
      __aami-query "${filters_name[@]}" -- "${args[@]}";
      __aami-query "${filters_description[@]}" -- "${args[@]}";
    } | sort | uniq | sort -r -t $'\t' -k 1
  )
  # Output
  if _is-cmd fzf; then
    echo "$results" | fzf -e
  else
    echo "$results" | less
  fi

}
__aami-query() {
  local -a filters args
  _splitargs filters args -- "$@"
  aws ec2 describe-images \
    --no-cli-auto-prompt \
    --output json \
    --filters "${filters[@]}" \
    --query 'Images[].{creation_date:CreationDate,id:ImageId,owner:OwnerId,name:Name,description:Description}' \
    "${args[@]}" |
  jq -r '.[] | join("\t")'
}

# List all security groups in the current region. Additional arguments for the
# 'describe-security-groups' command may be supplied (e.g. --region).
asg() {
  aws ec2 describe-security-groups \
    --no-cli-auto-prompt \
    --query 'SecurityGroups[].{id:GroupId,name:GroupName,description:Description}' \
    "$@"
}

# List all key pairs in the current region. Additional arguments for the
# 'describe-key-pairs' command may be supplied (e.g. --region).
akey() {
   aws ec2 describe-key-pairs \
    --no-cli-auto-prompt \
    --query 'KeyPairs[].{id:KeyPairId,name:KeyName,description:Description}' \
    "$@"
}

# List all EC2 instances in the current region. Additional arguments for the
# 'describe-instances' command may be supplied (e.g. --region, --filters).
ai() {
  aws ec2 describe-instances \
    --no-cli-auto-prompt \
    --query 'Reservations[].Instances[].{id:InstanceId,type:InstanceType,image:ImageId,public_ip:PublicIpAddress,key:KeyName,launch_date:LaunchTime,state:State.Name} | sort_by([],&launch_date)' \
    "$@" |
    if [[ -t 1 ]]; then sed -E "s/\"(running)\"/\"$(_sgr green)\1$(_sgr)\"/;s/\"(pending|shutting-down|terminated|stopping|stopped)\"/\"$(_sgr red)\1$(_sgr)\"/"; else cat; fi
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

