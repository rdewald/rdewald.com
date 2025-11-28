#!/usr/bin/env Rscript
# Export blog post to Substack plain text with markdown formatting
# Usage: Rscript substack/subport.R blog/your-post.qmd

# Get the blog post file from command line argument
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Usage: Rscript substack/subport.R path/to/post.qmd")
}

blog_post <- args[1]
if (!file.exists(blog_post)) {
  stop("Blog post file not found: ", blog_post)
}

# Read the entire file
lines <- readLines(blog_post, warn = FALSE)

# Find YAML frontmatter boundaries
yaml_start <- which(lines == "---")[1]
yaml_end <- which(lines == "---")[2]

# Extract content after YAML (skip title and metadata)
if (!is.na(yaml_start) && !is.na(yaml_end)) {
  content_lines <- lines[(yaml_end + 1):length(lines)]
} else {
  content_lines <- lines
}

# Remove leading/trailing empty lines
content_lines <- content_lines[cumsum(content_lines != "") > 0]
while(length(content_lines) > 0 && content_lines[length(content_lines)] == "") {
  content_lines <- content_lines[-length(content_lines)]
}

# Strip divs and inline styling
content_lines <- gsub("^:::\\s*\\{[^}]*\\}\\s*$", "", content_lines)  # Remove div markers like ::: {.class}
content_lines <- gsub("^:::.*$", "", content_lines)  # Remove ::: closing tags

# Process images - replace with placeholders
content_lines <- gsub(
  "!\\[([^]]*)\\]\\(([^)]+)\\)",
  "[IMAGE: \\1 - Upload via Substack UI]",
  content_lines
)

# Convert markdown links to plain format: text (url)
content_lines <- gsub(
  "\\[([^]]*)\\]\\(([^)]+)\\)",
  "\\1 (\\2)",
  content_lines
)

# Join lines and convert to CRLF
content_text <- paste(content_lines, collapse = "\r\n")

# Create output filename in substack directory
base_name <- tools::file_path_sans_ext(basename(blog_post))
output_file <- file.path("substack", paste0(base_name, "-substack.txt"))

# Write with explicit CRLF line endings
con <- file(output_file, "wb")
writeLines(content_text, con, sep = "")
close(con)

cat("\n✓ Substack text created:", output_file, "\n")
cat("\nReady to copy-paste into Substack editor\n")
cat("- Markdown formatting preserved (links, bold, italic, etc.)\n")
cat("- Image placeholders included\n")
cat("- CRLF line endings\n\n")
