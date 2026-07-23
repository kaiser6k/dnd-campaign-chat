# ⚔️ The Tavern — D&D Campaign Chat

A multiplayer D&D campaign chat app with Supabase Auth sign-in, real-time chat sync, dice rolling, and DM tools.

## 🚀 Live Demo

Open `index.html` in any browser — no build tools needed. Supabase is already wired up
via the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants near the top of the `<script>` tag,
so as long as those tables exist (see setup below), it works as soon as you open the file.

## ✨ Features

- **Supabase Auth sign-in** — Google or email/password
- **Live chat** — synced instantly across everyone in the same room via Supabase Realtime
- **Dice rolling** — d20 buttons (roll / advantage / disadvantage) plus a `/roll 2d6` style
  slash command typed directly into the message box
- **Presence** — see who else is currently online in the sidebar
- **DM tools panel** — shown automatically to whoever is an admin (see below): rename
  yourself, upload/remove a shared map image
- **Multiple rooms** — `index.html?room=yourcode` puts everyone who opens that link in
  their own separate room; leave it off and everyone lands in the default `valecrest` room

## 🎮 How to Use

1. Open `index.html` in your browser (or the hosted URL if you're using GitHub Pages)
2. Sign in with Google, or create an email/password account
3. You're in — send messages, roll dice, see who else is online

## 🎲 Becoming the DM

Whoever's email is listed in `ADMIN_EMAILS` (near the top of the `<script>` tag) gets the
DM tools panel automatically when they sign in. Open `index.html`, find this block, and add
your email:

```js
const ADMIN_EMAILS = [
  'you@example.com',
];
```

(As a fallback, any email containing "admin" or "dm" also gets DM tools — but listing your
real email explicitly is the reliable way to do it.)

## 🔗 Supabase Setup

1. Create a free project at [supabase.com](https://supabase.com)
2. In **Project Settings → API**, copy your Project URL and anon/publishable key into the
   `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants in `index.html`
3. Run this SQL in the Supabase SQL editor — it creates both tables the app actually uses:

```sql
create table campaign_messages (
  id uuid default gen_random_uuid() primary key,
  room_code text not null,
  speaker_id uuid,
  speaker_name text,
  speaker_role text,
  speaker_color text,
  body text,
  html text,
  created_at timestamptz default now()
);

alter table campaign_messages enable row level security;

create policy "allow all" on campaign_messages
  for all using (true) with check (true);

alter publication supabase_realtime add table campaign_messages;

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "allow all" on profiles
  for all using (true) with check (true);
```

4. If you want Google sign-in, enable the Google provider under
   **Authentication → Providers** in your Supabase project and add your site URL under
   **Authentication → URL Configuration → Redirect URLs**

> The `"allow all"` policies above are the fastest way to get this working for a small
> private group, but they mean anyone with your anon key can read/write every row. That's
> fine for a friends-only campaign; if you ever open this up more broadly, tighten these
> policies to check `auth.uid()` against the row's owner instead.

## 👥 Players

Designed for the DM + Vandur + Edward + any additional players.

## 🎲 Dice Modes

- Click any die button to roll and broadcast to the room
- Toggle **Adv** or **Dis** before rolling d20 for advantage/disadvantage
- Or type `/roll 2d6`, `/roll d20`, etc. directly into the message box
- All rolls are visible to everyone in the room

## 🚧 Not in this version

A few things mentioned in earlier plans for this app aren't actually built yet:

- **AI Dungeon Master** — the "Show AI DM in chat" checkbox in the DM tools panel currently
  just adds a fake "AI DM" entry to the online-users list. It doesn't call any AI service
  yet; there's no OpenAI wiring in the code.
- **Character creator** (race/class/ability scores/HP/AC) and **dark/light mode toggle**
  aren't present in the current `index.html`.

Happy to help build any of these out if you want them — just ask.
