# _CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Note**: The underscore prefix prevents this file from rendering to the website while maintaining Claude Code functionality.

## Project Overview

This is a Quarto website project (rdewald.com) deployed to Netlify. Quarto is a scientific and technical publishing system that converts `.qmd` (Quarto Markdown) files into static HTML websites.

The site has two distinct content sections:
- **Professional knowledge base** (`posts/` directory) - Formal nursing/clinical informatics articles displayed as a table on the homepage
- **Blog** (`blog/` directory) - Informal personal content with card-style layout, sent via email to subscribers using blastula

### Recent Additions (Nov 2025)
- **Preprocessing scripts** (`preprocessing/`) - Bash scripts for image processing and banner generation
  - `resize_image.sh` - Resize/compress images to max 800px wide using ImageMagick
  - `create_footer_banner.sh` - Generate footer banners for monthly Substack roll-up posts
- **Monthly roll-up workflow** - Template and banners for monthly digest posts to Substack
  - `blog/_roll_your_own.qmd` - Draft template for monthly roll-up posts
  - `blog/img/` - Footer banner images generated from blog posts
- **Email distribution system** (`rant.R`) - Sends blog posts via blastula with ProtonMail SMTP
- **Substack export** (`substack/subport.R`) - Converts blog posts to plain text for Substack composition panel
- **Mailing list management** (`xforms/`) - Subscriber data analysis and list generation
  - Non-free subscribers + upgrade candidates (38)
  - Top 25 engaged subscribers
  - Engagement scoring: opens + (clicks × 2) + (comments × 3) + (shares × 2)
- **renv integration** - R package management for reproducible environment
- **Image deployment** - Added `img/**` resources to _quarto.yml for proper image deployment
- **Blog migration** - Updated blog.qmd to reflect migration from Substack to self-hosted site

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
  - Resources: Includes `img/**` directory in site builds (added for image deployment)
  - Configures navbar navigation (Blog, BlueSky, GitHub, Substack)
  - Sets HTML theme (cosmo + brand) and custom CSS
  - Disables table of contents by default
  - Uses custom page layout

### Content Directories
- `posts/`: Professional knowledge base articles (table listing on homepage)
- `blog/`: Informal blog posts (card listing on blog.qmd page)
  - `blog/img/` - Footer banner images for monthly roll-up posts
  - `blog/_roll_your_own.qmd` - Draft template for monthly Substack digest
- `img/`: Images and assets (deployed via resources in _quarto.yml)
- `preprocessing/`: Image processing and banner generation scripts
  - `resize_image.sh` - Resize/compress images to max 800px wide
  - `create_footer_banner.sh` - Generate footer banners from .qmd files
- `xforms/`: Data transformations and mailing list management
  - `subs-*.csv` - Substack subscriber exports (gitignored for privacy)
  - `create_lists.R` - Script to generate mailing lists from subscriber data
  - `paid2rant.R` - Generated mailing list (gitignored)
  - `high_engagement.R` - Generated mailing list (gitignored)
- `substack/`: Substack export tools
  - `subport.R` - Export blog posts to Substack-compatible text format
  - `.gitignore` - Ignores generated output files

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

1. Copy `blog/_template.qmd` or create a new `.qmd` file in `blog/`
2. Add YAML frontmatter:
```yaml
---
title: "Post Title"
date: "date here"  # or use last-modified
description: "Brief description for listing and email"
categories: [rants, nursing, tech]
author: "Richard DeWald"
draft: true  # Remove this line when ready to publish
---
```
3. Write content - keep it simple for email compatibility
4. Remove `draft: true` when ready to publish
5. File will automatically appear in blog.qmd card listing (unless draft)

**Important**: Files starting with `_` (like `_template.qmd`, `_README.md`) are ignored by Quarto and won't render

### Date Handling

Use Quarto's built-in date keywords (no R required):
- `date: last-modified` - Updates when file is modified (recommended for blog)
- `date: today` - Current date at render time
- `date: "2025-11-28"` - Static date

## Sending Blog Posts via Email

### Using rant.R (The Hack)

**Note**: `rant.R` is a hack that bypasses blastula's normal rendering to get full control over email HTML.

```bash
Rscript rant.R blog/your-post.qmd
```

### How The Hack Works

1. **Renders with Quarto** (line 14): Uses `system("quarto render ...")` to render the .qmd to HTML in `_site/`
2. **Strips Quarto wrapper** (line 19): Regex removes everything before first `<img>` or `<p>` tag (removes navbar, headers, etc.)
3. **Fixes image paths** (lines 20-21): Converts relative paths to absolute URLs (`../img/` → `https://rdewald.com/img/`)
4. **Manually builds email HTML** (lines 23-31): String concatenation to create custom HTML structure with title, author, date
5. **Fakes blastula object** (lines 33-37): Manually creates a `blastula_message` object by setting the class - completely bypassing blastula's API
6. **Loads recipients** (line 41): Sources `rantees.R` (gitignored file containing `recipients` vector)
7. **Sends via SMTP** (lines 43-55): Uses blastula's `smtp_send()` with the fake message object

### Why It's A Hack

- Bypasses `blastula::render_email()` entirely
- Uses regex to strip HTML instead of proper parsing
- Hardcoded path assumptions (`_site/blog/`)
- Manual HTML string concatenation
- Creates fake blastula objects by forcing class attributes
- Fragile: breaks if Quarto changes its HTML structure

### Configuration

Email credentials via environment variables:
- `PROTONMAIL_USER` - SMTP username
- `PROTONMAIL_PASSWORD` - SMTP password
- `PROTONMAIL_FROM` - From address
- `PROTONMAIL_HOST` - SMTP host
- `PROTONMAIL_PORT` - SMTP port

### Recipients

Multiple mailing lists available (all gitignored for privacy):

- **`rantees.R`** - Main mailing list (root directory)
- **`xforms/paid2rant.R`** - Non-free subscribers + Upgrade candidates (38 subscribers)
  - Non-free (Paid + Comp + Author): 29
  - Upgrade candidates (Free but top 25 engaged): 9
- **`xforms/high_engagement.R`** - Top 25 by engagement score

To use a specific list, modify `rant.R` line 41:
```r
source(here('xforms/paid2rant.R'))      # For paid/comp + upgrade candidates
source(here('xforms/high_engagement.R'))  # For top 25 engaged subscribers
```

### Creating Mailing Lists from Substack Data

Subscriber data from Substack exports goes in `xforms/subs-*.csv` (gitignored for privacy, keep locally only).

To regenerate filtered lists from fresh Substack export:
```bash
Rscript xforms/create_lists.R
```

This script creates (in `xforms/` directory):
- `paid2rant.R` - Non-free subscribers + Upgrade candidates (38 total)
  - Non-free (Type: Paid, Comp, Author): 29
  - Upgrade candidates (Free but top 25 engaged): 9
- `high_engagement.R` - Top 25 subscribers by engagement score

Engagement scoring: `opens + (clicks × 2) + (comments × 3) + (shares × 2)`

Subscriber breakdown:
- Free: 68 (70%)
- Paid: 8 (8%)
- Comp: 20 (21%)
- Author: 1 (you)

## Image Processing Scripts

### Resizing Images (preprocessing/resize_image.sh)

Resize and compress images to max 800px wide for web deployment:

```bash
./preprocessing/resize_image.sh /path/to/image.jpg
```

**Features:**
- Resizes to maximum 800px width (maintains aspect ratio)
- Only resizes if image is wider than 800px
- Compresses with 85% quality for web optimization
- Overwrites source file (ensure source images are archived elsewhere)
- Uses ImageMagick's `convert` command

### Creating Footer Banners (preprocessing/create_footer_banner.sh)

Generate footer banners for monthly Substack roll-up posts:

```bash
./preprocessing/create_footer_banner.sh blog/your-post.qmd
```

**Features:**
- Extracts title, description, and date from .qmd YAML front matter
- Finds first image in .qmd file (supports both `<img>` tags and markdown images)
- Creates 800x120px banner with:
  - Square thumbnail (120x120) from first image on left
  - Title, description, and "now on RDeWald.com/blog - published {date}" text on right
  - 20px spacing between thumbnail and text
  - Subtle gray border
- Outputs to `blog/img/{filename}_footer.png`
- Handles both remote URLs (downloads temporarily) and local file paths
- Supports `<img>` tags with attributes in any order

**Banner Layout:**
```
[Thumbnail]  [Title (24pt bold)]
[120x120]    [Description (16pt)]
             [now on RDeWald.com/blog - published {date} (14pt italic)]
```

**Monthly Roll-Up Workflow:**
1. Write blog posts throughout the month
2. Generate footer banner for each post: `./preprocessing/create_footer_banner.sh blog/post.qmd`
3. Edit `blog/_roll_your_own.qmd` draft template
4. Stack footer banners vertically in the monthly digest
5. Export to Substack using `substack/subport.R` or copy/paste manually

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
- Files with `draft: true` in YAML frontmatter are excluded from listings and builds
- Images in `img/` directory are deployed via `resources` directive in _quarto.yml
- No dynamic R code executes during website builds - all content is static
- Blog posts with inline `<div>` styling will render on website but may need adjustment for email/Substack export

### Mailing List Management
- `rantees.R` - Main mailing list (tracked in git)
- `xforms/paid2rant.R` - Non-free + upgrade candidates (gitignored)
- `xforms/high_engagement.R` - Top 25 engaged (gitignored)
- Generated lists are gitignored for privacy; regenerate from `xforms/subs-nov2025.csv` using `xforms/create_lists.R`

### Image Processing Requirements
- ImageMagick must be installed for preprocessing scripts to work
- Install on Ubuntu/Debian: `sudo apt-get install imagemagick`
- Both scripts are executable bash scripts in `preprocessing/` directory
- Footer banner script requires: DejaVu-Sans fonts (usually pre-installed on Linux)
- Source images should be archived elsewhere before running `resize_image.sh` (overwrites originals)

### Blog Migration Notes
- Site migrated from Substack to self-hosted in November 2025
- New posts appear first on RDeWald.com/blog
- Email distribution via blastula to interested readers
- Monthly digest still distributed to Substack subscribers
- Footer banners used in monthly roll-up posts for visual consistency
