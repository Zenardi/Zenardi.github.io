---
name: add-cert
description: Add a certification to the portfolio — appends an entry to _data/certifications.yml under the right category and places the badge image in assets/img/Certificates/<Category>/. Use when the user wants to add or record a new certificate.
---

# Add a certification

Add a certification to `_data/certifications.yml` and wire up its image.

Input (via `$ARGUMENTS` or ask if missing): the cert **title**, a short **description** (usually `Provider - what it covers`), the **category**, and the **image** (a path to the badge file, or a URL).

## Steps

1. **Pick the category.** Existing categories in `_data/certifications.yml` are top-level `- category:` blocks. Current ones:
   `DevOps`, `Coding`, `Self-Driving Cars`, `Machine Learning & AI`, `Cloud/Kubernetes`.
   Use an existing category when it fits. Only create a new `- category:` block if none fits, and confirm with the user first.

2. **Place the image.** Store the badge under `assets/img/Certificates/<Category-subdir>/`. Match the subdir already used by other items in that category (open the category block and copy an existing `image:` path to see the convention — e.g. DevOps images live in `assets/img/Certificates/DevOps/`). If the user gave a local file outside the repo, copy it in; if a URL, download it or use the URL directly as the `image:` value.

3. **Append the item.** Add under the category's `items:` list, matching the existing indentation exactly:
   ```yaml
       - title: <Title>
         description: <Provider - what it covers>
         image: assets/img/Certificates/<Category-subdir>/<file>
   ```

4. **Validate YAML.** Run `ruby -ryaml -e "YAML.load_file('_data/certifications.yml')"` — it must exit 0. A syntax error here silently breaks the GitHub Pages build.

5. **Preview (optional).** Suggest `/serve` to eyeball the certifications page, then the user commits directly to `main`.
