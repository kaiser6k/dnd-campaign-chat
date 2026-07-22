# ⚔️ The Tavern — D&D Campaign Chat

A multiplayer D&D campaign chat app with real-time sync, AI Dungeon Master, character creator, dice rolling, and profile management.

## 🚀 Live Demo

Open `index.html` in any browser — no build tools needed.

## ✨ Features

- **Character Creator** — Name, race, class, background, ability scores (STR/DEX/CON/INT/WIS/CHA), HP, AC, level
- **Profile Editing** — Edit any character or delete players from the session
- **Dice Rolling** — d4, d6, d8, d10, d12, d20, d100 with Advantage/Disadvantage for d20
- **AI Dungeon Master** — Powered by GPT-4o-mini with 5 personality modes
- **Multiplayer Sync** — Supabase Realtime for live cross-browser chat
- **Dark/Light Mode** — Toggle between tavern ambience

## 🎮 How to Use

1. Open `index.html` in your browser
2. Enter your name, pick a color, choose Player or DM, set a room code
3. Click **Enter the Tavern**
4. Share the same HTML file + room code with friends

## 🤖 AI DM Setup

1. Go to the **Settings** tab (right sidebar)
2. Paste your [OpenAI API key](https://platform.openai.com/api-keys)
3. Choose a DM personality
4. Optionally add campaign context
5. Toggle **Enable AI DM** on
6. The AI will respond as DM after every player message

## 🔗 Multiplayer (Supabase)

1. Create a free project at [supabase.com](https://supabase.com)
2. Run this SQL in the Supabase SQL editor:

```sql
create table campaign_messages (
  id uuid default gen_random_uuid() primary key,
  room text not null,
  player_id text,
  player_name text,
  player_color text,
  player_role text,
  content text,
  msg_type text default 'chat',
  dice_type int,
  dice_result int,
  created_at timestamptz default now()
);

alter table campaign_messages enable row level security;

create policy "allow all" on campaign_messages
  for all using (true) with check (true);

alter publication supabase_realtime add table campaign_messages;
```

3. Go to the **Connect** tab in the app
4. Paste your Supabase URL and anon key
5. Click **Connect** — messages now sync live across all players

## 👥 Players

Designed for the DM + Vandur + Edward + any additional players.

## 🎲 Dice Modes

- Click any die button to roll and broadcast to the room
- Toggle **Adv** or **Dis** before rolling d20 for advantage/disadvantage
- All rolls are visible to everyone in the room
