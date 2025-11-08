# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Quarto website project (rdewald.com) deployed to Netlify. Quarto is a scientific and technical publishing system that converts `.qmd` (Quarto Markdown) files into static HTML websites.

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

To test the Netlify build locally, you can simulate it with:
```bash
quarto render
```

## Project Structure

### Configuration Files
- `_quarto.yml`: Main Quarto configuration
  - Defines project type as website
  - Configures navbar navigation (Home, About)
  - Sets HTML theme (cosmo + brand) and custom CSS
  - Enables table of contents (toc)

### Content Files
- `index.qmd`: Homepage
- `about.qmd`: About page
- `styles.css`: Custom CSS styles applied to all pages

### Theme System
The site uses a dual-theme approach:
- Base theme: "cosmo" (a Bootswatch theme)
- Custom theme: "brand" (applied on top)
- Additional customization via `styles.css`

## Adding New Pages

1. Create a new `.qmd` file in the project root
2. Add YAML frontmatter with at least a `title:` field
3. Add the page to the navbar in `_quarto.yml` under `website.navbar.left`
4. Run `quarto preview` to see changes

Example:
```yaml
---
title: "My New Page"
---

Content goes here.
```

## Key Technical Details

- Quarto version used in Netlify: 1.6.40 (specified in netlify.toml:3)
- Local development may use a different Quarto version (check with `quarto --version`)
- R project files (`.Rproj`, `.Rproj.user/`) are present but gitignored
- The `.quarto/` cache directory is gitignored and auto-generated
