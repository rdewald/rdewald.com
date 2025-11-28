#!/usr/bin/Rscript
library(blastula)
library(here)
library(yaml)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Usage: Rscript rant.R path/to/post.qmd")
}

blog_post <- args[1]
yaml_content <- rmarkdown::yaml_front_matter(blog_post)

# Read content, skip YAML
content <- readLines(blog_post)
yaml_end <- which(content == "---")[2]
body_lines <- content[(yaml_end + 1):length(content)]

# Remove the embedded image div, replace with link
body_text <- paste(body_lines, collapse = "\n")
body_text <- gsub('<div.*?</div>', '[View the x-ray image](https://rdewald.com/img/3views.jpg)\n\n', body_text)

# Create email with full text
email <- compose_email(
  body = md(body_text)
)

cat("Email size:", nchar(email$html_str), "bytes\n")

source(here('rantees.R'))

smtp_user <- Sys.getenv("PROTONMAIL_USER")
smtp_from <- Sys.getenv("PROTONMAIL_FROM", smtp_user)

smtp_settings <- creds_envvar(
  user = smtp_user,
  pass_envvar = "PROTONMAIL_PASSWORD",
  host = Sys.getenv("PROTONMAIL_HOST"),
  port = as.integer(Sys.getenv("PROTONMAIL_PORT")),
  use_ssl = FALSE
)

smtp_send(
  email,
  to = recipients,
  from = smtp_from,
  subject = yaml_content$title,
  credentials = smtp_settings
)

cat("Blog post sent to", length(recipients), "recipients\n")