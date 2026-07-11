---
name: new-project
description: Scaffold a new project in _projects/ with the numbered "(N) Name.md" filename and portfolYOU project front matter. Use when the user wants to add a project to the portfolio.
---

# New project

Create a project entry in `_projects/`.

Input (via `$ARGUMENTS` or ask): the project **name**, a short **description**, the **tools/tags**, an **image** (URL or path), and an **external_url**.

## Steps

1. **Pick the number.** Filenames are `(N) Name.md`. Find the current highest `N` in `_projects/` and use `N+1` (e.g. if `(6) ...` exists, the new file is `_projects/(7) <Name>.md`).

2. **Write the front matter.** Unlike the bundled placeholders (which keep front matter wrapped in `<!-- ... -->` so they stay hidden), a real project must have the front matter **uncommented** so it renders:
   ```yaml
   ---
   name: <Name>
   tools: [<Tool1>, <Tool2>]
   image: <image URL or assets/img/... path>
   description: <one- to two-sentence summary>
   external_url: <https://...>
   ---
   ```

3. **Body (optional).** Add any longer write-up in Markdown below the front matter.

4. **Preview (optional).** `/serve`; projects render at `/projects/<name>`. The user commits directly to `main`.
