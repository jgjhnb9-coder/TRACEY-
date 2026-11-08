# TRACEY — My Life. My Stories. My World.

A personal lifestyle and storytelling website built with React, TypeScript, Vite and Supabase.

## Local development

1. Install Node.js 20.19+ or 22.12+.
2. Run `npm install`.
3. Copy `.env.example` to `.env`.
4. Add your Supabase project URL and publishable/anon key.
5. Run `npm run dev`.

## Supabase setup

1. Create or select a Supabase project.
2. Run `supabase/migrations/001_initial_schema.sql` in the Supabase SQL Editor.
3. Create the first administrator using Supabase Authentication.
4. Copy that user's UUID and run the admin-grant statement at the bottom of the migration (replace the placeholder UUID).
5. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` to your local environment and deployment environment.

Never put a Supabase service-role key in frontend environment variables. The browser uses only the publishable/anon key; authorization is enforced by RLS.

## Build

- `npm run typecheck`
- `npm run build`

## Deployment

Deploy the repository to Netlify or Vercel with build command `npm run build` and publish directory `dist`. Configure the two `VITE_SUPABASE_*` environment variables in the deployment dashboard. Configure SPA fallback/rewrite to `/index.html` for client-side routes.

## Current implementation status

The initial app foundation, responsive editorial design, public routes, Supabase client, first database migration and initial RLS policies are in place. Demo editorial cards are placeholders until real posts are published. The admin area currently authenticates and checks the database-backed admin profile; full content-management forms, media upload workflow, comment moderation, newsletter unsubscribe endpoint, SEO sitemap generation and end-to-end testing remain follow-up implementation work. Contact and newsletter forms require the Supabase migration and project configuration before they can persist data.
