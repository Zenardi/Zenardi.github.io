---
name: new-post
description: Scaffold a new Jekyll blog post in _posts/ with the correct YYYY-MM-DD-title.md filename and portfolYOU front matter. Use when the user wants to write or start a new blog post.
---

# New blog post

Create a blog post in `_posts/`.

Input (via `$ARGUMENTS` or ask): the post **title**, and optionally **tags**, a one-line **description**, and the **date** (default to today).

## Steps

1. **Build the filename.** `_posts/YYYY-MM-DD-<slug>.md` where the slug is the lowercased, hyphenated title (e.g. `Learn React.js` on 2026-07-11 → `_posts/2026-07-11-learn-react-js.md`). Use today's date unless the user gives one. Match the naming of existing files in `_posts/`.

2. **Write the front matter** (portfolYOU convention — see existing posts):
   ```yaml
   ---
   title: <Title>
   tags: [<Tag1>, <Tag2>]
   style: fill        # or: border
   color: primary     # portfolYOU color: primary, secondary, success, danger, warning, info, light, dark
   description: <one-line summary>
   ---
   ```

3. **Add the body** in Markdown below the front matter. If the user only gave a title, leave a short placeholder line and tell them where to write.

4. **Preview (optional).** `/serve` (add `--drafts` if it's a draft). Posts appear at `/blog/<slug>`. The user commits directly to `main`.
