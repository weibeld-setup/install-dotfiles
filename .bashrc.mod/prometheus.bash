# Prometheus

# Display only the distinct metric names from a page of Prometheus metrics
prom-distinct() {
  sed '/^#/d;s/[{ ].*$//' | uniq
}

# Reduce a Prometheus metrics response to metric names and help texts
prometheus-clean() {
  # Remove labels and values (keep only metric names)
  sed '/^[^#]/s/[ {].*$//' |
  # Delete duplicate metric names
  uniq |
  # Remove TYPE comments
  sed '/^# TYPE/d' |
  # Simplify HELP comments (strip HELP keyword and metric name)
  sed '/^# HELP/s/HELP [^ ]* //'
}
