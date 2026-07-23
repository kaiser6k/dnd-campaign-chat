# ⚔️ The Tavern — D&D Campaign Chat

A multiplayer D&D campaign chat app with Supabase Auth sign-in, real-time chat sync, dice rolling, full 5E character sheets tied to accounts, and DM tools.

## 🚀 Live Demo

Open `index.html` in any browser — no build tools needed. Supabase is already wired up
via the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants near the top of the `<script>` tag,
so as long as the database tables exist (see setup below), it works as soon as you open the file.

## ✨ Features

- **Supabase Auth sign-in** — Google or email/password
- **Live chat** — synced instantly across everyone in the same room via Supabase Realtime
- **Dice rolling** — d20 buttons (roll / advantage / disadvantage) plus a `/roll 2d6` style
  slash command typed directly into the message box
- **Presence** — see who else is currently online in the sidebar
- **D&D 5E character sheets** — each account can create multiple characters: race, class,
  subclass, background, alignment, level, XP, all six ability scores with auto-computed
  modifiers, AC/HP/speed/hit dice, saving throw and skill proficiencies with computed bonuses,
  passive perception, spellcasting (ability, save DC, attack bonus, spell slots by level,
  known/prepared spells), equipment, features & traits, and personality traits/ideals/bonds/flaws
- **DM tools panel** — shown automatically to whoever is an admin (see below): rename
  yourself, upload/remove a shared map image
- **DM: All Characters** — DMs can view and edit *any* player's character, not just their own
- **DM: Manage Players** — DMs can fix any player's display name directly
- **Multiple rooms** — `index.html?room=yourcode` puts everyone who opens that link in
  their own separate room; leave it off and everyone lands in the default `valecrest` room

## 🎮 How to Use

1. Open `index.html` in your browser (or the hosted URL if you're using GitHub Pages)
2. Sign in with Google, or create an email/password account
3. Click **Characters** in the header to build one or more characters, or **Chat** to talk
   and roll dice

## 🎲 Becoming the DM

Whoever's email is listed in `ADMIN_EMAILS` (near the top of the `<script>` tag) gets DM
tools automatically when they sign in — including editing any player's character and display
name. Open `index.html` and edit:

```js
const ADMIN_EMAILS = [
  'you@example.com',
];
```

(As a fallback, any email containing "admin" or "dm" also gets DM tools — but listing your
real email explicitly is the reliable way to do it.)

DM status is also mirrored server-side: the `profiles.is_admin` column controls what the
database itself allows a DM to edit (any character, any profile), independent of the
client-side check above. Both need to agree for a smooth experience — see setup below.

## 🔗 Supabase Setup

1. Create a free project at [supabase.com](https://supabase.com)
2. In **Project Settings → API**, copy your Project URL and anon/publishable key into the
   `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants in `index.html`
3. Run this SQL in the Supabase SQL editor to create the chat tables:

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

4. Then run **`characters-migration.sql`** (included alongside this README) to add
   character sheets and DM override permissions. It adds an `is_admin` column to `profiles`,
   a `characters` table, and the row-level security policies that let a DM edit anyone's
   character or profile while players can only touch their own. **Before running it**, open
   the file and check the email in this line matches your real sign-in email:
   ```sql
   update profiles set is_admin = true
   where id = (select id from auth.users where email = 'kaiser6k@gmail.com');
   ```
5. If you want Google sign-in, enable the Google provider under
   **Authentication → Providers** and add your site URL under
   **Authentication → URL Configuration → Redirect URLs**

> The `"allow all"` chat/profile policies are the fastest way to get this working for a
> small private group, but they mean anyone with your anon key can read/write those rows.
> Character rows are a bit tighter by default: everyone can *view* every character (so the
> party can look each other up), but only the owner or a DM can create, edit, or delete one.

## 👥 Players

Designed for the DM + Vandur + Edward + any additional players.

## 🎲 Dice Modes

- Click any die button to roll and broadcast to the room
- Toggle **Adv** or **Dis** before rolling d20 for advantage/disadvantage
- Or type `/roll 2d6`, `/roll d20`, etc. directly into the message box
- All rolls are visible to everyone in the room

## 🧙 Character Sheets

- Click **+ New Character** under **My Characters** to build one — you can make more than one
- Ability score modifiers, saving throw/skill bonuses, passive perception, and spellcasting
  DC/attack bonus are all calculated automatically as you fill in scores and proficiency
  checkboxes
- Race, class, background, and alignment options match the D&D 5E System Reference Document
  (SRD) — the open ruleset D&D is built on
- As a DM, the **DM: All Characters** panel shows every character in the room with an Edit
  button that opens the same form, regardless of who owns it

## 🚧 Not in this version

- **AI Dungeon Master** — the "Show AI DM in chat" checkbox in the DM tools panel currently
  just adds a fake "AI DM" entry to the online-users list. It doesn't call any AI service
  yet; there's no OpenAI wiring in the code.
- **Dark/light mode toggle** isn't present in the current `index.html`.

Happy to help build any of these out if you want them — just ask.
