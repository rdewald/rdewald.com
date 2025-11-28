#!/usr/bin/Rscript
library(blastula)
library(rmarkdown)
library(yaml)

# Get the blog post file from command line argument
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Usage: Rscript send-blog-post.R path/to/post.qmd")
}

blog_post <- args[1]
if (!file.exists(blog_post)) {
  stop("Blog post file not found: ", blog_post)
}

# Read the YAML frontmatter to get metadata
yaml_content <- rmarkdown::yaml_front_matter(blog_post)

# Render the qmd/Rmd using blastula's render_email function
email <- render_email(blog_post)

recipients <- c(
  "rdewald@gmail.com",
  "rdewald@rdewald.com"
)

# ProtonMail SMTP configuration
smtp_user <- Sys.getenv("PROTONMAIL_USER")
smtp_from <- Sys.getenv("PROTONMAIL_FROM", smtp_user)

smtp_settings <- creds_envvar(
  user = smtp_user,
  pass_envvar = "PROTONMAIL_PASSWORD",
  host = Sys.getenv("PROTONMAIL_HOST"),
  port = as.integer(Sys.getenv("PROTONMAIL_PORT")),
  use_ssl = FALSE
)

# Send it
smtp_send(
  email,
  to = recipients,
  from = smtp_from,
  subject = yaml_content$title %||% "update",
  credentials = smtp_settings
)

cat("Blog post sent to", length(recipients), "recipients\n")
