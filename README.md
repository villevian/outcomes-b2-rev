# Outcomes B2 — Lexical Revision System

Live 120-minute lessons for Outcomes B2 3rd ed., built on the lexical approach (Dellar &amp; Walkley, Lewis, Selivan, Nation) + Bloom's taxonomy from **Apply upward**. Per-student progress and submissions stored in Supabase. Post-lesson AI drafts progress updates and rubric scores for the teacher to confirm.

## Structure

```
/
├── index.html              hub — 16 units × (Student / Teacher) buttons
├── login.html              nickname picker + teacher passphrase
├── admin.html              add / remove students (teacher only)
├── shared/
│   ├── config.js           Supabase URL, anon key, session helpers
│   └── styles.css          shared visual system
├── supabase/
│   ├── schema.sql          all tables + Leitner functions
│   ├── seed.sql            initial 4 students + Unit 1 chunks
│   └── process_lesson.md   post-lesson AI edge function spec
└── units/
    └── unit-01/
        ├── data.json       chunks (core + extension) + patterns
        ├── student.html    10-block live lesson
        └── teacher.html    method notes + rubrics + per-student dashboard + AI queue
```

## Method (one paragraph)

Chunks-first, grammar-as-a-servant. **Core chunks** (SB Vocabulary boxes) — direct teaching and drill. **Extension chunks** (VB) — met in context via tasks, glossed only if clicked. Tasks are 10 varied genres, all above Apply on Bloom: swipe reviews, bad-review rescue, emoji critic, dubbing lab, streaming-profile psy-test, gallery curator with real Wikimedia paintings. Spaced repetition on **Leitner 5-box** (1 → 2d → 7d → 14d → 30d). Grammar exponents (habits, extreme adjectives, fixed prepositions) live inside chunks, never in isolation.

## Deployment

### 1. Supabase

1. Create a Supabase project.
2. In SQL editor, run `supabase/schema.sql` then `supabase/seed.sql`.
3. Copy your project URL and anon key into `shared/config.js`.
4. Set a `TEACHER_PASSPHRASE` in `shared/config.js`.

### 2. Static hosting

Push to GitHub, enable Pages (branch `main`, root `/`). Site is live at `https://YOUR-USER.github.io/outcomes-b2-revision/`.

### 3. Post-lesson AI (optional but recommended)

Follow `supabase/process_lesson.md` — deploy the `process_lesson` edge function and add `ANTHROPIC_API_KEY` as a Supabase secret.

## Login flow

- **Student**: opens `/login.html` → picks nickname → session stored in `localStorage` → sees only Student pages.
- **Teacher**: passphrase → sees Student preview + Teacher pages + Admin.
- **Admin**: adds new nicknames via `/admin.html` (teacher only).

## 120-min lesson каркас (Unit 1)

| # | Block | Min | Bloom | Genre |
|---|---|---|---|---|
| 0 | Last-time recap | 3 | — | AI-generated summary from previous session |
| 1 | Snowflake cards | 10 | Apply | TB Comm Activity 1.1 pattern |
| 2 | Swipe left/right | 10 | Apply | Tinder-style with chunk-per-swipe |
| 3 | Bad-review rescue | 12 | Apply/Analyze | Extreme adjectives |
| 4 | Preposition collision | 8 | Analyze | Pattern noticing |
| 5 | The Critic (emoji → review) | 12 | Apply/Evaluate | 3-sentence hot take |
| 6 | Dubbing lab | 12 | Apply | Silent clip → dialogue |
| 7 | Guess the plot from 3 chunks | 8 | Create | Synopsis invention |
| 8 | Streaming Profile psy-test | 15 | Create | TB Comm Activity 2.1 pattern, universal (no art knowledge needed) |
| 9 | Gallery Curator | 20 | Create | 6 real paintings from Wikimedia |
| 10 | Self-log + voice recall | 10 | Metacog | Tag shaky chunks + 30-sec voice with 3 chunks |

## SRS (Leitner)

Box 1 (1d) → Box 2 (2d) → Box 3 (7d) → Box 4 (14d) → Box 5 (30d) → `mastered`.
Correct answer → next box. Wrong answer → back to Box 1 (`status='shaky'`).
Retrieval formats rotate: cloze prep, first-letter, micro-dialogue, image, voice, reformulation.

## References

- Dellar &amp; Walkley — *Teaching Lexically*
- Lewis — *The Lexical Approach*; *Teaching Collocation*
- Selivan — *Lexical Grammar*
- Nation — *Learning Vocabulary in Another Language*
- TB inspirations: Comm Activities 1.1 (snowflake), 1.2 (art exhibition), 2.1 (psy-test), 16.1 (elevator pitch), 16.2 (CYOA).
