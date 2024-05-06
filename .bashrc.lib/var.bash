# List and filter variables
# Usage:
#   _list-vars [-nNvV <pat>] [-tT <attr>] [-l <len>] [-fs] [-c <cols>]
# Args:
#   -n|N <pat>:  postive/negative variable name filter
#   -v|V <pat>:  positive/negative variable value filter
#   -t|T <attr>: positive/negative attribute filter
#   -l <len>:    maximum length of printed variable values (default: 100)
#   -f:          print the full variable values (up to 2000 characters)
#   -s:          print only the variable names
#   -c <cols>:   columns to print (default: 1,2,3,4)
# Description:
#   Prints the variables matching the provided filters as a table consisting of
#   the following columns:
#     - 1: row number
#     - 2: attributes
#     - 3: variable name
#     - 4: variable value
#   The set of columns to print may be customised with the -c option. The -s
#   option is a shorthand for '-c 3' and prints only the variable names.
# Notes:
#   1. Lower-case options -n, -v, and -t allow specifying POSITIVE patterns.
#      For example '-n ^foo' selects all variables whose name starts with 'foo'.
#   2. Upper-case options -N, -V, and -T allow specifying NEGATIVE patterns.
#      For example, '-N ^foo' selects all variables whose name does NOT start
#      with 'foo'.
#   3. Multiple occurrences of the same lower-case options -n, -v, and -t are
#      conjoined with OR. For example, '-n ^foo -n ^bar' selects all variables
#      whose starts with 'foo' OR starts with 'bar'.
#   4. Multiple occurrences of the same upper-case options -N, -V, and -T are
#      conjoined wih AND. For example '-N ^foo -N ^bar' selects all variables
#      whose does NOT start with 'foo' AND does NOT start with 'bar'.
#   5. Different types of options (i.e. -n, -N, -v, -V, -t, and -T among each
#      other) are conjoined with AND. For example, '-n ^foo -t a' selects all
#      variables whose name starts with 'foo' AND have the 'a' attribute.
#   6. The above also hold for upper-case options. For example, '-n ^foo -N _'
#      selects all variables whose name starts with 'foo' AND whose name does
#      NOT contain an underline. As another example, '-n ^foo -T a' selects all
#      variables whose name starts with 'foo' AND do NOT have the 'a' attribute.
#   7. <pat> may be any pattern understood by AWK. Certain characters, such as
#      '(' and ')' must be escaped to not be interpreted by AWK.
#   8. In <attr>, the absence of any attribute can be specified with '-'.
#   9. Text variable values are printed with enclosing "...". Array variable 
#      values are printed with enclosing (...). These enclosing characters
#      must be taken into account when creating patterns with -v and -V.
#  10. The -l option is capped at 2000 characters. Similarly, the -f option
#      also truncates the variable values at 2000 characters. This limitation
#      is due to the maximum line length limit of 2048 characters of 'column'
#      which is used to format the output table.
#  11. The output rows are sorted alphabetically by variable name. This holds
#      even if the variable name column (column 3) is not printed.
_list-vars() {
  # Capture variables and add line numbers (indices) as first column
  local -r data=$(declare -p | __vars-format-declare | awk 'BEGIN { i = 1 }{ print i "\t" $0; i++; }')
  # Parse command-line arguments
  local -a pat_names_arr pat_names_i_arr pat_values_arr pat_values_i_arr attr_arr attr_i_arr
  local -ai columns=(1 2 3 4)
  local -i max_value_len=100
  local expect_n expect_N expect_v expect_V expect_t expect_T expect_l expect_c
  local a
  for a in "$@"; do
    case "$a" in
      -n) expect_n=1 ;;
      -N) expect_N=1 ;;
      -v) expect_v=1 ;;
      -V) expect_V=1 ;;
      -t) expect_t=1 ;;
      -T) expect_T=1 ;;
      -f) max_value_len=2000 ;;
      -l) expect_l=1 ;;
      -s) columns=(3) ;;
      -c) expect_c=1 ;;
      *)
        if _is-set "$expect_n"; then
          pat_names_arr+=("$a")
          expect_n=
        elif _is-set "$expect_N"; then
          pat_names_i_arr+=("$a")
          expect_N=
        elif _is-set "$expect_v"; then
          pat_values_arr+=("$a")
          expect_v=
        elif _is-set "$expect_V"; then
          pat_values_i_arr+=("$a")
          expect_V=
        elif _is-set "$expect_t"; then
          local attr=$(_parse-attributes "$a" '.*')
          _is-set "$attr" && attr_arr+=(".*$attr.*")
          expect_t=
        elif _is-set "$expect_T"; then
          local attr=$(_parse-attributes "$a" '.*')
          _is-set "$attr" && attr_i_arr+=(".*$attr.*")
          expect_T=
        elif _is-set "$expect_l"; then
          max_value_len=$([[ "$a" -gt 2000 ]] && echo 2000 || echo "$a")
          expect_l=
        elif _is-set "$expect_c"; then
          IFS=, read -a columns <<<"$a"
          #columns=($(echo "$a" | tr , '\n' | sort -u | sed -n '/^[1-4]$/p'))
          expect_c=
        else
          _err "Invalid option: $a"
          return  1
        fi
    esac
  done
  # Filter variables
  # Note: the reason that only indices are used is that 'comm' has a line
  # length limit of ~6000 characters
  local indices=$(cut -f 1 <<<"$data")
  [[ "${#attr_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter "$data" attr_arr 2 "$indices")
  [[ "${#attr_i_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter-inverted "$data" attr_i_arr 2 "$indices")
  [[ "${#pat_names_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter "$data" pat_names_arr 3 "$indices")
  [[ "${#pat_names_i_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter-inverted "$data" pat_names_i_arr 3 "$indices")
  [[ "${#pat_values_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter "$data" pat_values_arr 4 "$indices")
  [[ "${#pat_values_i_arr[@]}" -gt 0 ]] &&
    indices=$(__list-vars-filter-inverted "$data" pat_values_i_arr 4 "$indices")
  echo "${columns[@]}"
  return
  echo "$data" |
    sed -n "$(for i in $indices; do echo "${i}p;"; done)" |
    _truncate-column '\t' 4 "$max_value_len" |
    cut -f 2- |
    _add-line-numbers -s $'\t' -u : |
    _filter-cols "${columns[@]}" |
    column -t -s $'\t'
}

# Get indices of vars matching any of given patterns AND given set of indices
__list-vars-filter() {
  local -r __data=$1 __indices=$4
  local -nr __patterns=$2
  local -ir __field=$3
  local __p __new_matches
  for __p in "${__patterns[@]}"; do
    __new_matches+=$'\n'$(echo "$__data" | awk -F '\t' '$'"$__field"' ~ /'"$__p"'/ {print $1}')
  done
  comm -12 <(echo "$__indices" | sort) <(echo "$__new_matches" | sed '/^$/d' | sort -u)
}

# Get indices of vars NOT matching given patterns AND matching given indices
__list-vars-filter-inverted() {
  local -r __data=$1
  local -nr __patterns=$2
  local -ir __field=$3
  local __indices=$4
  local __p
  for __p in "${__patterns[@]}"; do
    __indices=$(comm -12 <(echo "$__indices" | sort) <(echo "$__data" | awk -F '\t' '$'"$__field"' !~ /'"$__p"'/ {print $1}' | sort -u))
  done
  echo "$__indices"
}

# Format the output of 'declare -p' as a table with three columns
# Usage:
#   __vars-format-declare
# Description
#   Formats the output of any 'declare -p' command as a table with the following
#   three columns:
#     1. Attributes
#     2. Variable name
#     3. Variable value
#   Reads from stdin.
__vars-format-declare() {
  awk '
    {
      attr = $2
      gsub(/--/, "+", attr)
      gsub(/-/, "", attr)
      gsub(/\+/, "-", attr)
      match($3, /^[^=]+/)
      name = substr($3, RSTART, RLENGTH)
      match($0, /=.*$/)
      value = substr($0, RSTART+1, RLENGTH)
      print attr "\t" name "\t" value
    }'
}

# Filter the columns of a table by column index
# Usage:
#   _filter-cols <col>... -- [-so <sep>] 
# Args:
#   <col>:     column index (starting at 1)
#   -s <sep>:  input field separator (default: '\t')
#   -o <sep>:  output field separator (default: '\t')
# TODO: if a 0 is in <columns>, the output is broken
_filter-cols() {
  local -ai columns
  local -a args
  _splitargs columns args -- "$@"
  _array-sort columns -u -n
  local fs='\t' ofs='\t'
  local expect_s expect_o
  local a
  for a in  "${args[@]}"; do
    case "$a" in
      -s) expect_s=1 ;;
      -o) expect_o=1 ;;
      *)
        if _is-set "$expect_s"; then
          fs=$a
          expect_s=
        elif _is-set "$expect_o"; then
          ofs=$a
          expect_o=
        else
          _err "Invalid argument: $a"
          return 1
        fi

    esac
  done
  awk -v fs="$fs" -v ofs="$ofs" -v cols="${columns[*]}" '
    BEGIN {
      split(cols, arr)
      FS = fs
      OFS = ofs
    }
    {
      for (i in arr) {
        if (arr[i] < 1 || arr[i] > NF ) delete arr[i]
      }
      if (length(arr) == 0) {
        for (i = 1; i <= NF; i++) arr[i] = i
      }
      output = ""
      for (i in arr) {
        output = output $arr[i]
        if (i < length(arr)) output = output OFS
      }
      print output
    }
  '
}

# Print value of a variable (for arrays, print array)
_get-var() {
  _ensure-variable "$1" || return 1
  declare -p "$1" | __vars-format-declare | column -t -s $'\t'
}
complete -v _get-var

# Print the attributes of a variable
# Usage:
#   _get-attributes <var-name> [-s]
# Args:
#   <var-name>: name of a variable
#   -s:         print only attribute names without descriptions
# Notes:
#   - If the variable has no attributes, the output is empty
#   - If <var-name> is not a variable, an error is returned
_get-attributes() {
  _ensure-variable "$1" || return 1
  local -n __ref=$1
  _describe-attributes "${__ref@a}" "$2"
}


# Parse a variable attribute specification
# Usage:
#   _parse-attributes <attr> [<sep>]
# Args:
#   <attr>:  a set of one or more attributes (e.g. 'i', 'ir')
#   <sep>:   separator between attributes in the output (default: "")
# Description:
#   Prints all valid attributes in the input in alphabetical order, discarding
#   any repeated and invalid attributes.
# Notes:
#   - Returns 1 if the output is empty (i.e. if there was no valid attribute
#     in the input).
#   - The separator may be a string of any length and may include characters
#     such as '\t' or '\n'.
_parse-attributes() {
  local -r attr=$1 sep=${2}
  echo "$attr" | sed "s/[^Aailnrtux-]//g" | grep -o . | sort -u | paste -s -d ' ' - | sed 's/ /'"$sep"'/g'
}

# Describe one or more attributes
# Usage:
#   _describe-attr [<attr>...]
# Args:
#   [<attr>]: a single attribute
# Notes:
#   - If <attr> is omitted, then all attributes are described
#   - The full list of attributes is: A, a, i, l, n, r, t, u, x
_describe-attr() {
  [[ "$#" -eq 0 ]] && set -- A a i l n r t u x
  local a
  for a in "$@"; do
    case "$a" in
      A) echo "A: associative array" ;;
      a) echo "a: indexed array" ;;
      i) echo "i: integer" ;;
      l) echo "l: lower case" ;;
      n) echo "n: name reference" ;;
      r) echo "r: read-only" ;;
      t) echo "t: trace" ;;
      u) echo "u: upper case" ;;
      x) echo "x: export" ;;
    esac
  done
}

# Check whether a variable has a specific set of attributes
# Usage:
#   _has-attr <var-name> <attr-spec>...
# Args:
#   <var-name>:  name of a variable
#   <attr-spec>: an attribute specification
# Notes:
#   - An <attr-spec> may contain multiple attributes
#   - The attributes within an <attr-spec> are ANDed
#   - The various <attr-spec> are ORed
#   - Example: "Ai a" translates to ("A" AND "i") OR "a"
#   - The special attribute '-' may be used to mean "no attributes"
#   - The full list of attributes is: A, a, i, l, n, r, t, u, x
_has-attr() {
  _ensure-arg-count "$@" 2 "<var-name> <attr-spec>"
  local -n __ref=$1
  shift
  # Attributes of the variable
  local target=$(echo "${__ref@a}" | grep -o .)
  local attr_spec attr match=FALSE
  # Or between <attr-spec>
  for attr_spec in "$@"; do
    # AND for attributes within an <attr-spec>
    while read attr; do
      if [[ "$attr" = - && -z "$target" ]]; then
        match=TRUE
      elif echo "$target" | grep -q "^$attr$"; then
        match=TRUE
      else
        match=FALSE
        break
      fi
    done <<<$(echo "$attr_spec" | grep -o .)
    [[ "$match" = TRUE ]] && break
  done
  [[ "$match" = TRUE ]]
}


#------------------------------------------------------------------------------#
# Old
#------------------------------------------------------------------------------#

# Print variable attributes
# Usage:
#   _describe-attributes [<attr-str>] [-s]
# Args:
#   <attr-str>: a string of one or more attributes (examples: 'a', 'iAau')
#   -s:         print only attribute names without descriptions
# Notes:
#   - If <attr-str> is omitted, all attributes are printed
#   - For the full list and description of attributes, see 'declare' [1]
# References:
#   [1] https://www.gnu.org/software/bash/manual/bash.html#index-declare
# TODO: make default option print all attributes on one line without spaces
_describe-attributes() {
  [[ "${@: -1}" = -s ]] && local short=1
  local data=$(cat <<EOF
A (associative array)
a (indexed array)
i (integer)
l (lower case)
n (name reference)
r (read-only)
t (trace)
u (upper case)
x (export)
EOF
  )
  # Print all attributes
  if [[ "$#" -eq 0 || ("$#" -eq 1 && "$1" = -s) ]]; then
    echo "$data"
  # Print only specified attributes
  else
    local -a attributes=($(_parse-attributes "$1" ' '))
    local a
    for a in "${attributes[@]}"; do
      echo "$data" | sed -n "/^$a /p"
    done
  fi |
  # Format as short or normal output based on -s option
  if _is-set "$short"; then
    cut -c 1
  else
    cat
  fi
}

# TODO: combine with *-any-of() function and define 'aiu' as AND and 'a' 'i' 'u'
#       as OR. This allows combinations of AND and OR. Check how easy it is to
#       implement this.
# TODO: introduce -- as a special attribute to mean "no attributes"
# Check whether a variable has all of the specified attributes
# Usage:
#   _has-attributes <var-name> <attr-str>...
# Args:
#   <var-name>: name of a variable
#   <attr-str>: a string of one or more attributes (examples: 'a', 'iAau')
# Notes:
#   - The values of all <attr-str> are concatenated to a unified input, i.e.,
#     'a' 'i' 'u' is the same as 'aiu'
#   - If the attribute input is empty, 1 is returned
_has-attributes() {
  #_ensure-variable "$1" || return 1
  local -n __ref=$1
  shift
  local -a __input
  # If input is empty or contains invalid attributes, return 1
  __input=($(_parse-attributes "$@" ' ')) || return 1
  local __i
  for __i in "${__input[@]}"; do
    [[ "${__ref@a}" =~ "$__i" ]] || return 1
  done
}
complete -v _has-attributes

# TODO: introduce - as a special attribute to mean "no attributes"
# Check whether a variable has any of the specified attributes
# Usage:
#   _has-attributes-any-of <var-name> <attr-str>...
# Args:
#   <var-name>: name of a variable
#   <attr-str>: a string of one or more attributes (examples: 'a', 'iAau')
# Notes:
#   - The values of all <attr-str> are concatenated to a unified input, i.e.,
#     'a' 'i' 'u' is the same as 'aiu'
#   - If the attribute input is empty, 1 is returned
_has-attributes-any-of() {
  _ensure-variable "$1" || return 1
  local -n __ref=$1
  shift
  local __a
  for __a in $(_parse-attributes "$@" ' '); do
    [[ "${__ref@a}" =~ "$__a" ]] && return 0
  done
  return 1
}
complete -v _has-attributes-any-of

#------------------------------------------------------------------------------#
# End of Old
#------------------------------------------------------------------------------#

