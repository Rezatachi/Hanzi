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
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists content_entries_updated_at_idx on content_entries(updated_at desc);
create index if not exists content_entries_simplified_idx on content_entries(simplified);
create index if not exists content_entries_pinyin_search_idx on content_entries(pinyin_search);
