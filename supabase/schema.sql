

-- Recreate from scratch for a clean setup.
drop view if exists public.feed_view;
drop table if exists public.post_likes cascade;
drop table if exists public.comments cascade;
drop table if exists public.posts cascade;
drop table if exists public.profiles cascade;
drop table if exists public.groups cascade;

create extension if not exists pgcrypto;


-- Utility: автоматически обновлять updated_at

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;


-- Utility: создавать профиль при регистрации

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, username, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(coalesce(new.email, 'Пользователь'), '@', 1)),
    nullif(new.raw_user_meta_data ->> 'username', ''),
    null
  )
  on conflict (id) do update
  set
    display_name = excluded.display_name,
    username = coalesce(excluded.username, public.profiles.username),
    updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();


-- Table: groups

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null,
  category text not null,
  members_count integer not null default 0 check (members_count >= 0),
  accent_color text not null default '#6750A4',
  cover_image_url text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_groups_category on public.groups (category);
create index if not exists idx_groups_name on public.groups (name);

-- ---------------------------------------------------------
-- Table: profiles
-- ---------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  username text unique,
  avatar_url text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_profiles_username on public.profiles (username);

-- ---------------------------------------------------------
-- Table: posts
-- ---------------------------------------------------------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  author_id uuid references auth.users (id) on delete set null,
  group_name text not null,
  author_name text not null,
  title text not null,
  content text not null,
  tag text,
  image_url text,
  likes_count integer not null default 0 check (likes_count >= 0),
  comments_count integer not null default 0 check (comments_count >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_posts_group_id on public.posts (group_id);
create index if not exists idx_posts_author_id on public.posts (author_id);
create index if not exists idx_posts_created_at on public.posts (created_at desc);
create index if not exists idx_posts_tag on public.posts (tag);

-- ---------------------------------------------------------
-- Table: comments
-- ---------------------------------------------------------
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  author_id uuid references auth.users (id) on delete set null,
  author_name text not null,
  content text not null check (length(trim(content)) > 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_comments_post_id on public.comments (post_id);
create index if not exists idx_comments_created_at on public.comments (created_at asc);

-- ---------------------------------------------------------
-- Table: post_likes
-- ---------------------------------------------------------
create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  unique (post_id, user_id)
);

create index if not exists idx_post_likes_post_id on public.post_likes (post_id);
create index if not exists idx_post_likes_user_id on public.post_likes (user_id);

-- ---------------------------------------------------------
-- Count sync triggers
-- ---------------------------------------------------------
create or replace function public.sync_post_like_count()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts
    set likes_count = likes_count + 1,
        updated_at = timezone('utc', now())
    where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.posts
    set likes_count = greatest(likes_count - 1, 0),
        updated_at = timezone('utc', now())
    where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_post_likes_count_insert on public.post_likes;
create trigger trg_post_likes_count_insert
after insert on public.post_likes
for each row
execute function public.sync_post_like_count();

drop trigger if exists trg_post_likes_count_delete on public.post_likes;
create trigger trg_post_likes_count_delete
after delete on public.post_likes
for each row
execute function public.sync_post_like_count();

create or replace function public.sync_comment_count()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts
    set comments_count = comments_count + 1,
        updated_at = timezone('utc', now())
    where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.posts
    set comments_count = greatest(comments_count - 1, 0),
        updated_at = timezone('utc', now())
    where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_comments_count_insert on public.comments;
create trigger trg_comments_count_insert
after insert on public.comments
for each row
execute function public.sync_comment_count();

drop trigger if exists trg_comments_count_delete on public.comments;
create trigger trg_comments_count_delete
after delete on public.comments
for each row
execute function public.sync_comment_count();

-- ---------------------------------------------------------
-- Triggers for updated_at
-- ---------------------------------------------------------
drop trigger if exists trg_groups_updated_at on public.groups;
create trigger trg_groups_updated_at
before update on public.groups
for each row
execute function public.set_updated_at();

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

drop trigger if exists trg_posts_updated_at on public.posts;
create trigger trg_posts_updated_at
before update on public.posts
for each row
execute function public.set_updated_at();

drop trigger if exists trg_comments_updated_at on public.comments;
create trigger trg_comments_updated_at
before update on public.comments
for each row
execute function public.set_updated_at();

-- ---------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------
alter table public.groups enable row level security;
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;

-- Groups
 drop policy if exists "Authenticated can read groups" on public.groups;
create policy "Authenticated can read groups"
  on public.groups
  for select
  to authenticated
  using (true);

 drop policy if exists "Authenticated can manage groups" on public.groups;
create policy "Authenticated can manage groups"
  on public.groups
  for all
  to authenticated
  using (true)
  with check (true);

-- Profiles
 drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

 drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

 drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

-- Posts
 drop policy if exists "Authenticated can read posts" on public.posts;
create policy "Authenticated can read posts"
  on public.posts
  for select
  to authenticated
  using (true);

 drop policy if exists "Authenticated can insert own posts" on public.posts;
create policy "Authenticated can insert own posts"
  on public.posts
  for insert
  to authenticated
  with check (auth.uid() = author_id);

 drop policy if exists "Authenticated can update own posts" on public.posts;
create policy "Authenticated can update own posts"
  on public.posts
  for update
  to authenticated
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

 drop policy if exists "Authenticated can delete own posts" on public.posts;
create policy "Authenticated can delete own posts"
  on public.posts
  for delete
  to authenticated
  using (auth.uid() = author_id);

-- Comments
 drop policy if exists "Authenticated can read comments" on public.comments;
create policy "Authenticated can read comments"
  on public.comments
  for select
  to authenticated
  using (true);

 drop policy if exists "Authenticated can insert own comments" on public.comments;
create policy "Authenticated can insert own comments"
  on public.comments
  for insert
  to authenticated
  with check (auth.uid() = author_id);

 drop policy if exists "Authenticated can update own comments" on public.comments;
create policy "Authenticated can update own comments"
  on public.comments
  for update
  to authenticated
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

 drop policy if exists "Authenticated can delete own comments" on public.comments;
create policy "Authenticated can delete own comments"
  on public.comments
  for delete
  to authenticated
  using (auth.uid() = author_id);

-- Likes
 drop policy if exists "Authenticated can read own likes" on public.post_likes;
create policy "Authenticated can read own likes"
  on public.post_likes
  for select
  to authenticated
  using (auth.uid() = user_id);

 drop policy if exists "Authenticated can insert own likes" on public.post_likes;
create policy "Authenticated can insert own likes"
  on public.post_likes
  for insert
  to authenticated
  with check (auth.uid() = user_id);

 drop policy if exists "Authenticated can delete own likes" on public.post_likes;
create policy "Authenticated can delete own likes"
  on public.post_likes
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------------------
-- Seed demo data
-- ---------------------------------------------------------
insert into public.groups (id, name, description, category, members_count, accent_color)
values
  ('11111111-1111-1111-1111-111111111111', 'Flutter Friends', 'Обсуждения о Flutter, архитектуре и мобильной разработке.', 'Разработка', 1280, '#6750A4'),
  ('22222222-2222-2222-2222-222222222222', 'Design Hub', 'UI/UX, дизайн-системы и визуальные эксперименты.', 'Дизайн', 860, '#0F9D58'),
  ('33333333-3333-3333-3333-333333333333', 'Campus Life', 'Учёба, мероприятия и студенческие новости.', 'Сообщество', 540, '#E67E22')
on conflict (id) do update
set
  name = excluded.name,
  description = excluded.description,
  category = excluded.category,
  members_count = excluded.members_count,
  accent_color = excluded.accent_color,
  updated_at = timezone('utc', now());

insert into public.posts (
  id,
  group_id,
  author_id,
  group_name,
  author_name,
  title,
  content,
  tag,
  likes_count,
  comments_count,
  created_at
)
values
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    null,
    'Flutter Friends',
    'Алина',
    'Запустили мини-лендинг на Flutter',
    'Собрали быстрый MVP для студенческого проекта: навигация, форма и карта экрана заняли один вечер.',
    'UI',
    24,
    3,
    timezone('utc', now()) - interval '1 day'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222',
    null,
    'Design Hub',
    'Илья',
    'Новая палитра для комьюнити-приложения',
    'Проверили несколько вариантов и остановились на мягком градиенте с акцентами для карточек.',
    'Brand',
    18,
    2,
    timezone('utc', now()) - interval '6 hours'
  ),
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '33333333-3333-3333-3333-333333333333',
    null,
    'Campus Life',
    'Дарья',
    'Открыт набор в команду по хакатону',
    'Ищем разработчиков, дизайнеров и аналитиков. Встреча участников — в пятницу в 17:00.',
    'Event',
    31,
    5,
    timezone('utc', now()) - interval '2 days'
  )
on conflict (id) do update
set
  group_id = excluded.group_id,
  group_name = excluded.group_name,
  author_name = excluded.author_name,
  title = excluded.title,
  content = excluded.content,
  tag = excluded.tag,
  likes_count = excluded.likes_count,
  comments_count = excluded.comments_count,
  created_at = excluded.created_at,
  updated_at = timezone('utc', now());

-- ---------------------------------------------------------
-- Optional view for admin queries
-- ---------------------------------------------------------
create or replace view public.feed_view as
select
  p.id,
  p.group_id,
  p.author_id,
  p.group_name,
  p.author_name,
  p.title,
  p.content,
  p.tag,
  p.image_url,
  p.likes_count,
  p.comments_count,
  p.created_at,
  p.updated_at,
  g.category,
  g.accent_color
from public.posts p
join public.groups g on g.id = p.group_id
order by p.created_at desc;

