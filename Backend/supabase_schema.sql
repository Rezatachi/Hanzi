create table if not exists profiles (
  user_id uuid primary key,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists review_states (
  id uuid primary key,
  user_id uuid not null,
  entry_id uuid not null,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists review_logs (
  id uuid primary key,
  user_id uuid not null,
  entry_id uuid not null,
  payload jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists saved_entries (
  id uuid primary key,
  user_id uuid not null,
  entry_id uuid not null,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists content_import_batches (
  id uuid primary key,
  source_name text not null,
  source_url text,
  checksum text,
  entry_count integer not null default 0,
  imported_at timestamptz not null default now()
);

create table if not exists content_entries (
  id uuid primary key,
  simplified text not null,
  traditional text not null,
  pinyin text not null,
  pinyin_numeric text not null,
  pinyin_search text not null,
  definitions jsonb not null default '[]'::jsonb,
  part_of_speech text,
  hsk_level text,
  frequency_rank integer,
  radical text,
  radical_meaning text,
  stroke_count integer,
  components jsonb not null default '[]'::jsonb,
  categories jsonb not null default '["basics"]'::jsonb,
  example_chinese_simplified text,
  example_chinese_traditional text,
  example_pinyin text,
  example_english text,
  usage_note text,
  memory_hook text,
  tone_tip text,
  common_mistake text,
  related_entry_ids jsonb not null default '[]'::jsonb,
  is_premium boolean not null default true,
  source_name text not null default 'seed',
  source_url text,
  source_updated_at timestamptz,
  content_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists content_entries_updated_at_idx on content_entries(updated_at desc);
create index if not exists content_entries_simplified_idx on content_entries(simplified);
create index if not exists content_entries_pinyin_search_idx on content_entries(pinyin_search);
create index if not exists content_entries_hsk_level_idx on content_entries(hsk_level);
create index if not exists content_entries_frequency_rank_idx on content_entries(frequency_rank);
create index if not exists content_entries_categories_idx on content_entries using gin (categories);

alter table profiles enable row level security;
alter table review_states enable row level security;
alter table review_logs enable row level security;
alter table saved_entries enable row level security;

drop policy if exists "profiles_select_own" on profiles;
create policy "profiles_select_own"
  on profiles for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "profiles_insert_own" on profiles;
create policy "profiles_insert_own"
  on profiles for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "profiles_update_own" on profiles;
create policy "profiles_update_own"
  on profiles for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "profiles_delete_own" on profiles;
create policy "profiles_delete_own"
  on profiles for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "review_states_own" on review_states;
create policy "review_states_own"
  on review_states for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "review_logs_own" on review_logs;
create policy "review_logs_own"
  on review_logs for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "saved_entries_own" on saved_entries;
create policy "saved_entries_own"
  on saved_entries for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
