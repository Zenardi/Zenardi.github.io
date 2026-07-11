# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal portfolio site (`zenardi.github.io`) built with **Jekyll** using the **remote** `yousinix/portfolYOU` theme. The theme is pulled at build time via `remote_theme` in `_config.yml` — there are no local `_layouts/` and most theme partials live in the gem, not the repo. To override a theme file, create a matching path locally (e.g. `_layouts/page.html`, `assets/css/...`).

## Commands

- `bundle install` — install dependencies (first time; no `Gemfile.lock` is committed — it's gitignored)
- `bundle exec jekyll serve` — local dev server at `http://localhost:4000`
- `bundle exec jekyll serve --livereload --drafts` — auto-reload + preview drafts
- `bundle exec jekyll serve --port 4001` — if 4000 is taken
- `bundle exec jekyll build` — build to `_site/` (do not edit `_site/`; it's gitignored)
- `bundle exec jekyll clean` — remove `_site/` and caches

**Gotcha:** Jekyll does NOT hot-reload `_config.yml`. After editing it, restart the server.

`JEKYLL_GITHUB_TOKEN` must be set for the `jekyll-github-metadata` plugin to work locally (not needed on GitHub Pages).

## Content model (data-driven — edit these, not HTML)

- `_data/*.yml` — site content: `certifications.yml`, `skills.yml`, `programming-skills.yml`, `other-skills.yml`, `professional-experience.yml`, `timeline.yml`, `social-media.yml`. A malformed YAML file silently breaks the GitHub Pages build.
- `_posts/YYYY-MM-DD-title.md` — blog posts. Front matter: `title`, `tags: [..]`, `style` (`fill`/`border`), `color` (`primary`/etc.), `description`.
- `_projects/(N) Name.md` — projects, numbered filenames. Front matter keys: `name`, `tools: [..]`, `image`, `description`, `external_url`. The bundled placeholder projects keep their front matter wrapped in `<!-- ... -->` so they don't render — uncomment (remove the `<!--`/`-->`) for a real project.
- `pages/` — top-level pages (`about.md`, `blog.html`, `projects.html`, `certifications.md`).

### Certifications

`_data/certifications.yml` groups entries under `- category:` blocks (current: `DevOps`, `Coding`, `Self-Driving Cars`, `Machine Learning & AI`, `Cloud/Kubernetes`). Each item has `title`, `description`, `image`. Cert images live under `assets/img/Certificates/<Category-subdir>/`.

## Deploy

Push to `main` → GitHub Pages auto-builds and deploys. There is no separate deploy step or CI check; a broken build shows up only on the live site. Commits go **directly to `main`** (no PR flow).

## Slash commands

- `/add-cert` — add a certification entry + image
- `/new-post` — scaffold a dated blog post
- `/new-project` — scaffold a numbered project file
- `/serve` — run the local dev server
