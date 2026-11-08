# TRACEY — My Life. My Stories. My World.

A personal lifestyle and storytelling website built with React, TypeScript and Vite.

## Local development

1. Install Node.js 20.19+ or 22.12+.
2. Run `npm install`.
3. Run `npm run dev`.

## Build

- `npm run typecheck`
- `npm run build`

## Deployment

Deploy to Netlify or Vercel with build command `npm run build` and publish directory `dist`. Configure SPA fallback/rewrite to `/index.html` for client-side routes.

## Current scope

The initial website uses static demonstration content and does not require Supabase. This keeps setup simple while the design and public pages are developed.

A static frontend alone cannot provide secure shared admin accounts, multi-device publishing, durable public media uploads, or reliable email delivery. Those capabilities can be added later with a backend or dedicated services only if needed. Do not treat a browser-only admin preview or local storage as secure production content management.
