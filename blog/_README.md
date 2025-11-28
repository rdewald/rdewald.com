# Blog Setup

This directory contains blog posts that are distinct from the professional nursing content in `/posts`.

## Creating a New Blog Post

Create a new `.qmd` file in this directory with the following frontmatter:

```yaml
---
title: "Your Post Title"
date: "YYYY-MM-DD"
description: "A brief description that appears in listings and emails"
categories: [category1, category2]
author: "Richard DeWald"
---
```

## Sending via Blastula

### First-time Setup

1. Install required packages:
```r
install.packages(c("blastula", "rmarkdown", "yaml"))
```

2. Configure SMTP credentials:
```r
library(blastula)
create_smtp_creds_file(
  user = "your-email@example.com",
  host = "smtp.example.com",
  port = 587,
  use_ssl = TRUE
)
```

### Sending a Post

From the project root:

```bash
Rscript send-blog-post.R blog/your-post.qmd
```

Edit `send-blog-post.R` to customize recipients and email settings.
