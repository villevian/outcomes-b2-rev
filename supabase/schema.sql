-- ============================================================
-- OUTCOMES B2 — LEXICAL REVISION SYSTEM
-- Supabase schema (Postgres)
-- Everything is tied to student_nickname.
-- ============================================================

-- ------------------------------------------------------------
-- 1. STUDENTS  (admin-managed)
-- ------------------------------------------------------------
create table if not exists students (
  id            uuid primary key default gen_random_uuid(),
  nickname      text unique not null,          -- login handle: 'Yana Soroka', 'Mike B2', …
  full_name     text,
  level         text default 'B2',
  current_unit  int  default 1,
  created_at    timestamptz default now(),
  last_seen_at  timestamptz,
  notes         text                            -- teacher's private notes
);

create index if not exists idx_students_nickname on students (lower(nickname));

-- ------------------------------------------------------------
-- 2. CHUNKS  (loaded from /units/unit-XX/data.json)
-- ------------------------------------------------------------
create table if not exists chunks (
  id           text primary key,                -- e.g. 'u1_1A_catchy'
  unit         int  not null,
  subtopic     text not null,                   -- '1A' | '1B' | '1C'
  headword     text not null,
  chunk        text not null,                   -- 'a catchy tune / chorus / slogan'
  pos          text,                            -- 'adj' | 'n' | 'v' | 'phrase'
  pattern      text,                            -- 'addicted TO + noun/-ing'
  tier         text not null check (tier in ('core','extension','pattern')),
  collocates   jsonb default '[]'::jsonb,
  examples     jsonb default '[]'::jsonb,
  extra_contexts jsonb default '[]'::jsonb,
  notes        text,
  created_at   timestamptz default now()
);

create index if not exists idx_chunks_unit on chunks (unit, subtopic);
create index if not exists idx_chunks_tier on chunks (tier);

-- ------------------------------------------------------------
-- 3. CHUNK_PROGRESS  (Leitner boxes per student × chunk)
-- ------------------------------------------------------------
create table if not exists chunk_progress (
  student_id       uuid references students(id) on delete cascade,
  chunk_id         text references chunks(id)   on delete cascade,
  leitner_box      int  not null default 1 check (leitner_box between 1 and 5),
  status           text not null default 'new'
                   check (status in ('new','learning','shaky','confident','mastered')),
  reps_correct     int  default 0,
  reps_wrong       int  default 0,
  last_seen_at     timestamptz,
  next_review_at   timestamptz,
  last_format_used text,                        -- 'cloze' | 'l1_gloss' | 'micro_dialogue' | 'image' | 'voice' | …
  source           text default 'teacher'
                   check (source in ('teacher','student','ai')),
  ai_confidence    numeric,                     -- 0.00 – 1.00 (only if source='ai')
  ai_reasoning     text,
  confirmed_by_teacher_at timestamptz,
  history          jsonb default '[]'::jsonb,   -- [{date, format, result, response_time_ms}]
  primary key (student_id, chunk_id)
);

create index if not exists idx_progress_due
  on chunk_progress (student_id, next_review_at)
  where status != 'mastered';

-- View: chunks due today for a student
create or replace view due_today as
select cp.student_id, cp.chunk_id, cp.leitner_box, cp.status, c.chunk, c.headword, c.unit
from chunk_progress cp
join chunks c on c.id = cp.chunk_id
where cp.next_review_at <= now()
  and cp.status != 'mastered';

-- ------------------------------------------------------------
-- 4. SESSION_LOG  (one row per lesson)
-- ------------------------------------------------------------
create table if not exists session_log (
  id                uuid primary key default gen_random_uuid(),
  student_id        uuid references students(id) on delete cascade,
  unit              int  not null,
  lesson_date       date default current_date,
  started_at        timestamptz default now(),
  ended_at          timestamptz,
  blocks_done       jsonb default '[]'::jsonb,  -- ['snowflake','swipe','critic','dubbing',…]
  chunks_targeted   jsonb default '[]'::jsonb,  -- ids from data.json
  summary_note      text,                       -- shown to student next time
  ai_summary        text,                       -- AI-generated draft
  teacher_note      text                        -- private for teacher
);

create index if not exists idx_session_student on session_log (student_id, lesson_date desc);

-- ------------------------------------------------------------
-- 5. CREATIVE_SUBMISSIONS  (all Create-level task outputs)
-- ------------------------------------------------------------
create table if not exists creative_submissions (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid references students(id) on delete cascade,
  session_id    uuid references session_log(id) on delete set null,
  unit          int  not null,
  task_slug     text not null,                  -- 'streaming_profile' | 'gallery_curator' | 'dubbing_lab' | …
  content_text  text,
  content_audio_url text,                       -- ref to Supabase Storage bucket
  chunks_used   jsonb default '[]'::jsonb,      -- chunk ids detected
  submitted_at  timestamptz default now()
);

create index if not exists idx_submissions_student on creative_submissions (student_id, submitted_at desc);

-- ------------------------------------------------------------
-- 6. ERRORS_LOG  (grammar + lexis error patterns)
-- ------------------------------------------------------------
create table if not exists errors_log (
  id               uuid primary key default gen_random_uuid(),
  student_id       uuid references students(id) on delete cascade,
  session_id       uuid references session_log(id) on delete set null,
  chunk_id         text references chunks(id) on delete set null,
  pattern_key      text,                        -- 'prep_after_adj' | 'extreme_adj' | 'habits_grammar'
  error_type       text,                        -- 'wrong_prep' | 'very_extreme_adj' | 'used_to_form' | …
  error_text       text,                        -- what student said/wrote
  correction       text,
  teacher_comment  text,
  source           text default 'teacher'
                   check (source in ('teacher','student','ai')),
  ai_confidence    numeric,
  confirmed_by_teacher_at timestamptz,
  created_at       timestamptz default now()
);

create index if not exists idx_errors_student on errors_log (student_id, created_at desc);

-- ------------------------------------------------------------
-- 7. RUBRIC_SCORES  (evaluate/create tasks scored per criterion)
-- ------------------------------------------------------------
create table if not exists rubric_scores (
  id               uuid primary key default gen_random_uuid(),
  student_id       uuid references students(id) on delete cascade,
  submission_id    uuid references creative_submissions(id) on delete cascade,
  criterion        text not null,               -- 'chunks_density' | 'naturalness' | 'precision' | 'register' | 'grammar_in_chunk'
  score            numeric not null,
  max_score        numeric not null default 5,
  note             text,
  source           text default 'teacher'
                   check (source in ('teacher','ai')),
  ai_confidence    numeric,
  confirmed_by_teacher_at timestamptz,
  created_at       timestamptz default now()
);

create index if not exists idx_rubric_student on rubric_scores (student_id, created_at desc);

-- ------------------------------------------------------------
-- 8. LESSON_TRANSCRIPTS  (input for AI post-processing)
-- ------------------------------------------------------------
create table if not exists lesson_transcripts (
  id                    uuid primary key default gen_random_uuid(),
  session_id            uuid references session_log(id) on delete cascade,
  student_id            uuid references students(id)    on delete cascade,
  unit                  int not null,
  transcript_text       text,
  transcript_source     text check (transcript_source in ('fireflies','manual','html_log','otter','zoom','voice_upload')),
  raw_submissions       jsonb default '{}'::jsonb,
  ai_processing_status  text default 'pending'
                        check (ai_processing_status in ('pending','processing','done','failed')),
  ai_summary            text,
  processed_at          timestamptz,
  created_at            timestamptz default now()
);

-- ------------------------------------------------------------
-- 9. AI_SUGGESTIONS_QUEUE  (teacher inbox after AI processing)
-- ------------------------------------------------------------
create table if not exists ai_suggestions_queue (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid references students(id) on delete cascade,
  session_id    uuid references session_log(id) on delete cascade,
  target_table  text not null,                  -- 'chunk_progress' | 'errors_log' | 'rubric_scores' | 'session_log'
  target_row_id text,
  action        text not null,                  -- 'insert' | 'update'
  payload       jsonb not null,
  confidence    numeric not null,
  reasoning     text,
  status        text default 'pending'
                check (status in ('pending','confirmed','rejected','auto_applied')),
  reviewed_at   timestamptz,
  created_at    timestamptz default now()
);

create index if not exists idx_queue_pending
  on ai_suggestions_queue (student_id, status, created_at desc)
  where status = 'pending';

-- ------------------------------------------------------------
-- 10. LEITNER SCHEDULING FUNCTION
-- ------------------------------------------------------------
-- Box 1 → +1 day, Box 2 → +2 days, Box 3 → +7 days, Box 4 → +14 days, Box 5 → +30 days
create or replace function leitner_next_review(box int)
returns timestamptz language sql immutable as $$
  select now() + case box
    when 1 then interval '1 day'
    when 2 then interval '2 days'
    when 3 then interval '7 days'
    when 4 then interval '14 days'
    when 5 then interval '30 days'
    else interval '1 day'
  end;
$$;

-- Advance chunk on correct answer
create or replace function chunk_correct(p_student uuid, p_chunk text, p_format text)
returns void language plpgsql as $$
declare
  cur_box int;
begin
  select leitner_box into cur_box from chunk_progress
   where student_id = p_student and chunk_id = p_chunk;

  if not found then
    insert into chunk_progress (student_id, chunk_id, leitner_box, status, reps_correct,
                                last_seen_at, next_review_at, last_format_used)
    values (p_student, p_chunk, 2, 'learning', 1, now(), leitner_next_review(2), p_format);
    return;
  end if;

  update chunk_progress
     set leitner_box       = least(cur_box + 1, 5),
         status            = case when cur_box + 1 >= 5 then 'mastered'
                                  when cur_box + 1 >= 3 then 'confident'
                                  else 'learning' end,
         reps_correct      = reps_correct + 1,
         last_seen_at      = now(),
         next_review_at    = leitner_next_review(least(cur_box + 1, 5)),
         last_format_used  = p_format,
         history           = history || jsonb_build_object('date', now(), 'format', p_format, 'result', 'correct')
   where student_id = p_student and chunk_id = p_chunk;
end;
$$;

-- Reset to box 1 on wrong answer
create or replace function chunk_wrong(p_student uuid, p_chunk text, p_format text)
returns void language plpgsql as $$
begin
  insert into chunk_progress (student_id, chunk_id, leitner_box, status, reps_wrong,
                              last_seen_at, next_review_at, last_format_used, history)
  values (p_student, p_chunk, 1, 'shaky', 1, now(), leitner_next_review(1), p_format,
          jsonb_build_array(jsonb_build_object('date', now(), 'format', p_format, 'result', 'wrong')))
  on conflict (student_id, chunk_id) do update
     set leitner_box      = 1,
         status           = 'shaky',
         reps_wrong       = chunk_progress.reps_wrong + 1,
         last_seen_at     = now(),
         next_review_at   = leitner_next_review(1),
         last_format_used = p_format,
         history          = chunk_progress.history || jsonb_build_object('date', now(), 'format', p_format, 'result', 'wrong');
end;
$$;

-- ------------------------------------------------------------
-- 11. ROW-LEVEL SECURITY  (basic — refine when auth is added)
-- ------------------------------------------------------------
-- alter table students             enable row level security;
-- alter table chunk_progress       enable row level security;
-- alter table creative_submissions enable row level security;
-- alter table errors_log           enable row level security;
-- alter table rubric_scores        enable row level security;
-- alter table session_log          enable row level security;
-- Policies to be added once auth model is decided (nickname-based magic link, or teacher-only auth).
