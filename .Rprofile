# ~/.Rprofile
# 
# Daniel Weibel <daniel.weibel@unifr.ch> Sep. 2014 - May. 2015
#------------------------------------------------------------------------------#

# Options
#------------------------------------------------------------------------------#

# Increase default output width (assuming we use R with wide terminal window)
options(width=150)

# Increase maximum number of output lines
options(max.print=200000)

# Use fixed notation (e.g. 1000000) instead of scientific noation (e.g. 1e+06).
# Scientific will be only used if fixed is more than 'scipen' digits longer.
options(scipen=10)

# Set default CRAN mirror, so we don't get asked about it by install.packages()
options(repos="http://stat.ethz.ch/CRAN/")


# Variables
#------------------------------------------------------------------------------#

# Listing of current working directory (like "ls")
d <- dir()


# Function definitions
#------------------------------------------------------------------------------#

Fill <- function() {
  # Adjust R output width to terminal width
  #----------------------------------------------------------------------------#
  width <- Sys.getenv("COLUMNS")
  options(width=width)
  write(paste0("Output width set to ", width), file=stderr())
}

# Source all R files in the specified directory
SourceDir <- function(dir) {
  for (f in list.files(dir, pattern = "*.[Rr]")) {
    file <- file.path(dir, f)
    source(file);
    write(paste0("Sourcing ", file), "")
  }
}

MySource <- function() {
  # Source the R files in a set of directories
  #----------------------------------------------------------------------------#
  dirs <- c("~/r-lib")
  for (d in dirs) {
    SourceDir(d)
  }
}

ColClasses <- function(df) {
  # Return classes of the columns of a data frame
  #----------------------------------------------------------------------------#
  sapply(df, class)
}

Clear <- function() {
  # Remove all existing variables
  #----------------------------------------------------------------------------#
  rm(list=ls())
}


# mW (milliwatts) to Bm (bel-milliwatt)
mw2bm <- function(mw)   { log10(mw) }
# Bm (bel-milliwatt) to mW (milliwatts)
bm2mw <- function(bm)   { 10^bm }

# Function calls
#------------------------------------------------------------------------------#

MySource()

# Load packages
#------------------------------------------------------------------------------#
library('knitr')
