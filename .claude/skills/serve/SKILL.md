---
name: serve
description: Run the local Jekyll dev server for this portfolYOU site so changes can be previewed at http://localhost:4000. Use when the user wants to preview the site locally.
---

# Serve the site locally

Start the Jekyll dev server.

## Steps

1. **Ensure deps are installed.** If `bundle exec` fails with a missing-gem error, run `bundle install` first (no `Gemfile.lock` is committed).

2. **Start the server** (run in the background so the session stays interactive):
   ```bash
   bundle exec jekyll serve --livereload
   ```
   Add `--drafts` to include draft posts, or `--port 4001` if 4000 is in use.

3. **Point the user to** `http://localhost:4000`. Live-reload rebuilds on file changes — **except** `_config.yml`, which requires restarting the server.

4. If the `jekyll-github-metadata` plugin errors locally, remind the user to `export JEKYLL_GITHUB_TOKEN=<token>` before serving.
