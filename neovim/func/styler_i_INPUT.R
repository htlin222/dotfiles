args <- commandArgs(trailingOnly = TRUE)

# Ensure there is a filename provided
if (length(args) == 0) {
  stop("No filename provided")
}

filename <- args[1]

# Ensure the file exists
if (!file.exists(filename)) {
  stop("File does not exist")
}

# Load the styler library
library(styler)

# Read the contents of the file
ugly_code <- readLines(filename)

# Apply style_text to the code
pretty_code <- style_text(paste(ugly_code, collapse = "\n"))

# Overwrite the original file with the pretty code
writeLines(pretty_code, filename)
