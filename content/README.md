# Content editing guide

Edit these files using GitHub's web editor on a phone or computer.

- `settings.json`: biography, contact email, social links and Giscus configuration.
- `posts.json`: articles. Only records with `"status": "published"` appear publicly. Drafts use `"status": "draft"`.
- `categories.json`: category names and optional descriptions.
- `gallery.json`: image paths and captions for the gallery.

Article body uses plain text blocks only; supported block types are `paragraph`, `heading`, and `quote`. Do not add HTML. Article image paths must be relative paths inside `assets/uploads/`.

See README.md for complete examples and publishing instructions.
