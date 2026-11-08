-- TRACEY initial schema. Run in the Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete set null,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  slug text not null unique,
  excerpt text,
  body text not null default '',
  cover_image_url text,
  status text not null default 'draft' check (status in ('draft','published','archived')),
  featured boolean not null default false,
  seo_title text,
  seo_description text,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.media (
  id uuid primary key default gen_random_uuid(),
  uploaded_by uuid references auth.users(id) on delete set null,
  title text,
  caption text,
  description text,
  storage_path text not null,
  public_url text,
  media_type text not null check (media_type in ('image','video')),
  category text,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  display_name text not null,
  body text not null,
  status text not null default 'pending' check (status in ('pending','approved','hidden')),
  created_at timestamptz not null default now()
);

create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  subject text,
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  status text not null default 'active' check (status in ('active','unsubscribed')),
  unsubscribe_token uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now()
);

create or replace function public.is_tracey_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.profiles where id = auth.uid() and is_admin = true); $$;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.posts enable row level security;
alter table public.media enable row level security;
alter table public.site_settings enable row level security;
alter table public.comments enable row level security;
alter table public.contact_messages enable row level security;
alter table public.newsletter_subscribers enable row level security;

create policy "Profiles: owner reads own profile" on public.profiles for select to authenticated using (id = auth.uid() or public.is_tracey_admin());
create policy "Profiles: admin manages profiles" on public.profiles for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Categories: public reads" on public.categories for select to anon, authenticated using (true);
create policy "Categories: admin writes" on public.categories for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Posts: public reads published" on public.posts for select to anon, authenticated using (status = 'published' or public.is_tracey_admin());
create policy "Posts: admin writes" on public.posts for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Media: public reads published" on public.media for select to anon, authenticated using (is_published = true or public.is_tracey_admin());
create policy "Media: admin writes" on public.media for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Settings: public reads" on public.site_settings for select to anon, authenticated using (true);
create policy "Settings: admin writes" on public.site_settings for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Comments: public reads approved" on public.comments for select to anon, authenticated using (status = 'approved' or public.is_tracey_admin());
create policy "Comments: visitors submit pending" on public.comments for insert to anon, authenticated with check (status = 'pending');
create policy "Comments: admin moderates" on public.comments for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Contact: visitors submit" on public.contact_messages for insert to anon, authenticated with check (length(name) between 1 and 120 and length(message) between 1 and 5000);
create policy "Contact: admin reads and manages" on public.contact_messages for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());
create policy "Newsletter: visitor subscribes" on public.newsletter_subscribers for insert to anon, authenticated with check (length(email) <= 254);
create policy "Newsletter: admin manages" on public.newsletter_subscribers for all to authenticated using (public.is_tracey_admin()) with check (public.is_tracey_admin());

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('tracey-media','tracey-media',true,52428800,array['image/jpeg','image/png','image/webp','image/avif','video/mp4','video/webm'])
on conflict (id) do nothing;
create policy "TRACEY media public read" on storage.objects for select to anon, authenticated using (bucket_id = 'tracey-media');
create policy "TRACEY media admin upload" on storage.objects for insert to authenticated with check (bucket_id = 'tracey-media' and public.is_tracey_admin());
create policy "TRACEY media admin update" on storage.objects for update to authenticated using (bucket_id = 'tracey-media' and public.is_tracey_admin()) with check (bucket_id = 'tracey-media' and public.is_tracey_admin());
create policy "TRACEY media admin delete" on storage.objects for delete to authenticated using (bucket_id = 'tracey-media' and public.is_tracey_admin());

-- Create the first auth user in Supabase, then grant admin using the SQL editor:
-- update public.profiles set is_admin = true where id = 'AUTH_USER_UUID';
