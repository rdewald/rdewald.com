# _CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Note**: The underscore prefix prevents this file from rendering to the website while maintaining Claude Code functionality.

## Project Overview

This is a Quarto website project (rdewald.com) deployed to Netlify. Quarto is a scientific and technical publishing system that converts `.qmd` (Quarto Markdown) files into static HTML websites.

The site has two distinct content sections:
- **Professional knowledge base** (`posts/` directory) - Formal nursing/clinical informatics articles displayed as a table on the homepage
- **Blog** (`blog/` directory) - Informal personal content with card-style layout, sent via email to subscribers using blastula

## Build and Development Commands

### Local Development
```bash
# Render the entire site
quarto render

# Preview the site with live reload (recommended for development)
quarto preview

# Preview on a specific port
quarto preview --port 8080
```

### Output
- Build output is written to the `_site/` directory (gitignored)
- The `_site/` directory contains the static HTML files ready for deployment

## Deployment

The site is deployed to Netlify with a custom build process:
- Netlify downloads Quarto 1.6.40 during build time (see netlify.toml:1-6)
- Runs `quarto render` to generate the static site
- Publishes the `_site/` directory
- **No R code executes during Netlify builds** - all content is static Quarto markdown

To test the Netlify build locally:
```bash
quarto render
```

## R Environment Management

This project uses `renv` for R package management:
- `renv.lock` tracks package versions (committed to git)
- `renv/` directory contains package cache (gitignored)
- `.Rprofile` activates renv when working locally (committed to git)

The R environment is only used locally for:
- Sending blog posts via email (blastula package)
- Local development and testing

To restore the R environment on a new machine:
```r
renv::restore()
```

## Project Structure

### Configuration Files
- `_quarto.yml`: Main Quarto configuration
  - Defines project type as website
  - Configures navbar navigation (Blog, BlueSky, GitHub, Substack)
  - Sets HTML theme (cosmo + brand) and custom CSS
  - Disables table of contents by default
  - Uses custom page layout

### Content Directories
- `posts/`: Professional knowledge base articles (table listing on homepage)
- `blog/`: Informal blog posts (card listing on blog.qmd page)
- `img/`: Images and assets

### Styling
- `styles.css`: Custom CSS styles
  - Base styles optimized for readability (24px font, comfortable line length)
  - Blog-specific styles for informal feel (cards, rounded corners, softer colors)
  - Professional content uses table layout
  - Blog content uses card layout with categories

### Key Files
- `index.qmd`: Homepage with professional articles listing
- `blog.qmd`: Blog landing page with informal intro and blog posts listing
- `about.qmd`: About page
- `rant.R`: Script for sending blog posts via blastula email

## Theme System

The site uses a dual-theme approach:
- Base theme: "cosmo" (a Bootswatch theme)
- Custom theme: "brand" (applied on top)
- Additional customization via `styles.css`
- Blog section has distinct styling from professional sections

## Content Creation

### Adding Professional Articles (posts/)

1. Create a new `.qmd` file in `posts/`
2. Add YAML frontmatter:
```yaml
---
title: "Article Title"
date: last-modified
description: "Brief description"
---
```
3. Write content in Quarto markdown
4. File will automatically appear in homepage table listing

### Adding Blog Posts (blog/)

1. Create a new `.qmd` file in `blog/`
2. Add YAML frontmatter:
```yaml
---
title: "Post Title"
date: last-modified
description: "Brief description for listing and email"
categories: [category1, category2]
author: "Richard DeWald"
---
```
3. Write content - keep it simple for email compatibility
4. File will automatically appear in blog.qmd card listing

### Date Handling

Use Quarto's built-in date keywords (no R required):
- `date: last-modified` - Updates when file is modified (recommended for blog)
- `date: today` - Current date at render time
- `date: "2025-11-28"` - Static date

## Sending Blog Posts via Email

### Using rant.R

The `rant.R` script sends blog posts to subscribers via blastula:

```bash
Rscript rant.R blog/your-post.qmd
```

### Configuration

Email credentials are set via environment variables:
- `PROTONMAIL_USER` - SMTP username
- `PROTONMAIL_PASSWORD` - SMTP password
- `PROTONMAIL_FROM` - From address (defaults to PROTONMAIL_USER)
- `PROTONMAIL_HOST` - SMTP host
- `PROTONMAIL_PORT` - SMTP port

### How it Works

1. Reads the `.qmd` file's YAML frontmatter
2. Renders the file using `blastula::render_email()`
3. Sends via SMTP to configured recipients
4. Uses post title as email subject

### Recipients

Edit the `recipients` vector in `rant.R` to manage the mailing list.

## Exporting Blog Posts to Substack

### Using substack/subport.R

The export script creates plain text files with markdown formatting for Substack:

```bash
Rscript substack/subport.R blog/your-post.qmd
```

### Output

- Creates `substack/your-post-substack.txt` (gitignored)
- Plain text with basic formatting (bold, italic, headings)
- Links converted to: `text (url)` format
- Div styling and inline HTML stripped out
- CRLF line endings
- No title or YAML metadata (just content)
- Image placeholders: `[IMAGE: alt-text - Upload via Substack UI]`

### Workflow

1. Run the export script on your blog post
2. Open the generated `.txt` file in the `substack/` directory
3. Copy the entire contents
4. Paste into Substack's composition editor
5. Upload images using Substack's UI and place where placeholders indicate

### Directory Structure

- `substack/subport.R` - Export script (committed to git)
- `substack/.gitignore` - Ignores generated output files (redundant)
- `substack/*.txt` - Generated text files (gitignored)

## Key Technical Details

- Quarto version used in Netlify: 1.6.40 (specified in netlify.toml:3)
- Local development may use a different Quarto version (check with `quarto --version`)
- R project files (`.Rproj`, `.Rproj.user/`) are present but gitignored
- The `.quarto/` cache directory is gitignored and auto-generated
- Files starting with `_` (like this file) are not rendered to the website
- No dynamic R code executes during website builds - all content is static
