-- ── Admin flag on profiles ──────────────────────────────────────────────
alter table profiles add column if not exists is_admin boolean not null default false;

update profiles set is_admin = true
where id = (select id from auth.users where email = 'kaiser6k@gmail.com');

-- security definer function so RLS policies can check admin status
-- without recursively re-triggering profiles' own RLS
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select coalesce((select p.is_admin from public.profiles p where p.id = auth.uid()), false);
$$;

-- DM can see and edit every player's profile, not just their own
create policy "admin can view all profiles" on profiles
  for select using (is_admin());

create policy "admin can update all profiles" on profiles
  for update using (is_admin()) with check (is_admin());

-- ── Characters table ─────────────────────────────────────────────────────
create table characters (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  room_code text not null default 'valecrest',
  name text not null default 'Unnamed Adventurer',
  race text,
  class text,
  subclass text,
  level int not null default 1,
  background text,
  alignment text,
  experience_points int not null default 0,
  abilities jsonb not null default '{"str":10,"dex":10,"con":10,"int":10,"wis":10,"cha":10}'::jsonb,
  armor_class int not null default 10,
  speed int not null default 30,
  hp_max int not null default 8,
  hp_current int not null default 8,
  hp_temp int not null default 0,
  hit_dice text default '1d8',
  saving_throw_profs text[] not null default '{}',
  skill_profs text[] not null default '{}',
  languages text,
  equipment text,
  features_traits text,
  personality_traits text,
  ideals text,
  bonds text,
  flaws text,
  spellcasting_ability text,
  spell_slots jsonb not null default '{}'::jsonb,
  spells_known text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table characters enable row level security;

-- Everyone in the campaign can see every character (party members can look
-- each other up); only the owner or a DM can create/change/delete one.
create policy "view all characters" on characters
  for select using (true);

create policy "create own character" on characters
  for insert with check (auth.uid() = user_id);

create policy "update own or admin" on characters
  for update using (auth.uid() = user_id or is_admin())
  with check (auth.uid() = user_id or is_admin());

create policy "delete own or admin" on characters
  for delete using (auth.uid() = user_id or is_admin());

alter publication supabase_realtime add table characters;
