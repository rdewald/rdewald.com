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

system(paste("quarto render", blog_post, "--to html --quiet"))

html_file <- sub("^blog/", "_site/blog/", sub("\\.qmd$", ".html", blog_post))
html_content <- paste(readLines(html_file, warn = FALSE), collapse = "\n")

html_content <- sub(".*?(<img|<p)", "\\1", html_content)
html_content <- gsub('src="../img/', 'src="https://rdewald.com/img/', html_content)
html_content <- gsub('src="img/', 'src="https://rdewald.com/img/', html_content)

email_html <- paste0(
  '<!DOCTYPE html>',
  '<html><head><meta charset="utf-8"></head>',
  '<body style="font-family: Georgia, serif; line-height: 1.6; max-width: 650px; margin: 20px auto; padding: 0 20px;">',
  '<h1>', yaml_content$title, '</h1>',
  '<p style="color: #666;"><em>', yaml_content$author, ' • ', yaml_content$date, '</em></p>',
  html_content,
  '</body></html>'
)

email <- list(
  html_str = email_html,
  html_html = htmltools::HTML(email_html)
)
class(email) <- c("blastula_message", "email_message")

cat("Email size:", nchar(email_html), "bytes\n")

source(here('xforms/paid2rant.R'))
# source(here('xforms/testing.R'))

smtp_send(
  email,
  to = "rdewald@pm.me",
  bcc = recipients,
  from = Sys.getenv("PROTONMAIL_FROM"),
  subject = yaml_content$title,
  credentials = creds_envvar(
    user = Sys.getenv("PROTONMAIL_USER"),
    pass_envvar = "PROTONMAIL_PASSWORD",
    host = Sys.getenv("PROTONMAIL_HOST"),
    port = as.integer(Sys.getenv("PROTONMAIL_PORT")),
    use_ssl = FALSE
  )
)

cat("Sent\n")