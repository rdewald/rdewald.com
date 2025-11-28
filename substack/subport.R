#!/usr/bin/env Rscript
# Export blog post to Substack-compatible HTML fragment
# Usage: Rscript substack/export-to-substack.R blog/your-post.qmd

library(xml2)
library(rmarkdown)

# Get the blog post file from command line argument
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Usage: Rscript substack/export-to-substack.R path/to/post.qmd")
}

blog_post <- args[1]
if (!file.exists(blog_post)) {
  stop("Blog post file not found: ", blog_post)
}

# Create temporary output file
temp_html <- tempfile(fileext = ".html")

# Render the qmd to HTML
rmarkdown::render(
  blog_post,
  output_format = html_document(
    self_contained = FALSE,
    theme = NULL,
    pandoc_args = c("--standalone")
  ),
  output_file = temp_html,
  quiet = TRUE
)

# Read and parse the HTML
html_content <- read_html(temp_html)

# Extract just the main content (body content)
body_nodes <- xml_find_all(html_content, "//body/*")

# Process images - replace src with placeholder text
images <- xml_find_all(html_content, "//img")
for (img in images) {
  original_src <- xml_attr(img, "src")
  alt_text <- xml_attr(img, "alt") %||% "image"

  # Create placeholder text
  placeholder <- sprintf('[IMAGE PLACEHOLDER: %s - Upload to Substack and replace this]',
                        basename(original_src))

  # Replace img with a comment placeholder
  xml_attr(img, "src") <- "#"
  xml_attr(img, "alt") <- placeholder
  xml_attr(img, "title") <- sprintf("Original: %s", original_src)
}

# Convert back to HTML string
# We want just the body content, not the full document
body_html <- as.character(body_nodes)

# Clean up and format for Substack
# Combine all body elements
final_html <- paste(body_html, collapse = "\n\n")

# Create output filename in substack directory
base_name <- tools::file_path_sans_ext(basename(blog_post))
output_file <- file.path("substack", paste0(base_name, "-substack.html"))

# Write the fragment
writeLines(final_html, output_file)

# Clean up temp file
unlink(temp_html)

cat("\n✓ Substack HTML fragment created:", output_file, "\n")
cat("\nInstructions:\n")
cat("1. Open", output_file, "\n")
cat("2. Copy the entire contents\n")
cat("3. Paste into Substack's HTML editor\n")
cat("4. Upload images to Substack\n")
cat("5. Replace [IMAGE PLACEHOLDER: ...] comments with actual image URLs\n\n")
