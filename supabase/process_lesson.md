# Post-lesson AI processing

An edge function that runs after the teacher clicks **End lesson**.
Reads: transcript + student submissions + lesson plan.
Writes: chunk_progress updates, errors_log, rubric_scores, session_log summary — all with `source='ai'`, `confidence`, and (for most) awaiting teacher confirmation.

---

## Trigger

Teacher clicks **End lesson · run AI** on `units/unit-01/teacher.html`. The button posts to Supabase Edge Function `process_lesson` with the session_id.

## Inputs the function gathers

```sql
-- 1. session context
select * from session_log where id = :session_id;

-- 2. submissions from this lesson
select task_slug, content_text, chunks_used from creative_submissions
where session_id = :session_id;

-- 3. transcript (if any)
select transcript_text from lesson_transcripts where session_id = :session_id;

-- 4. target chunks that were supposed to appear
select id, chunk, headword, pattern, tier from chunks where unit = 1 and tier = 'core';

-- 5. student's Leitner state
select chunk_id, leitner_box, status from chunk_progress
where student_id = :student_id and chunk_id in (list from step 4);
```

## Anthropic API call (system prompt)

Model: `claude-sonnet-5`

```
You are an experienced B2-level lexical-approach teacher post-lesson assistant for Outcomes 3rd ed.
You will receive:
1. The lesson plan (target chunks for Unit 1, with pattern info)
2. The student's written submissions for each block (JSON)
3. Optionally a lesson transcript (voice → text)
4. The student's current Leitner state for these chunks

Your job:
Produce a structured JSON with the following keys:

{
  "chunk_progress_updates": [
    {
      "chunk_id": "u1_1A_hilarious",
      "suggested_status": "confident",
      "suggested_box": 3,
      "confidence": 0.92,
      "reasoning": "Used naturally 3× across blocks 3 and 5, with correct extreme-adj pattern (`absolutely hilarious`, `hilariously chaotic`)."
    }
  ],
  "errors": [
    {
      "chunk_id": "u1_1B_reliant",
      "pattern_key": "prep_after_adj",
      "error_type": "wrong_prep",
      "error_text": "reliant of streaming",
      "correction": "reliant on streaming",
      "confidence": 0.95,
      "reasoning": "Student wrote *reliant of streaming* in block 6. Typical B2 collision."
    }
  ],
  "rubric_scores": [
    {
      "task_slug": "streaming_profile",
      "criterion": "chunks_density",
      "score": 4,
      "max": 5,
      "confidence": 0.72,
      "note": "12 target chunks across 6 answers, mostly embedded."
    }
  ],
  "session_summary": "Yana finished all 10 blocks. Strong on extreme adjectives and habits (used to / would). Shaky on preposition-after-adjective patterns (3 misses out of 12). Streaming Profile: The Escapist. Best output: Gallery Curator wall label for Hopper — natural chunk-density, museum register.",
  "speaking_time_ratio_teacher_vs_student": null,
  "next_lesson_recommendation": "Warm up with 4 shaky prep chunks: reliant on, driven by, open to, close to. Consider running the psy-test replay for creative recall."
}

Rules:
- Only mark a chunk 'mastered' if you see it used productively at least 3 times across different formats.
- Only mark a chunk 'shaky' if the student made a pattern-related error OR failed to use it in a block that explicitly targeted it.
- Confidence ≥ 0.90 for chunk_progress is auto-applied (teacher sees it in changelog).
- Confidence < 0.90 or for errors_log / rubric_scores → always awaits teacher confirmation.
- Session summary must be ≤ 4 sentences, written FOR the student to read next lesson.
```

## Edge function pseudocode (Deno / TypeScript)

```ts
// supabase/functions/process_lesson/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Anthropic from 'https://esm.sh/@anthropic-ai/sdk@0.30.0';

serve(async (req) => {
  const { session_id } = await req.json();
  const sb = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });

  // 1. Gather inputs
  const { data: session } = await sb.from('session_log').select('*').eq('id', session_id).single();
  const { data: subs }    = await sb.from('creative_submissions').select('*').eq('session_id', session_id);
  const { data: chunks }  = await sb.from('chunks').select('*').eq('unit', session.unit).eq('tier', 'core');
  const { data: progress }= await sb.from('chunk_progress').select('*').eq('student_id', session.student_id);
  const { data: transcript } = await sb.from('lesson_transcripts').select('transcript_text').eq('session_id', session_id).maybeSingle();

  // 2. Call Claude
  const msg = await anthropic.messages.create({
    model: 'claude-sonnet-5',
    max_tokens: 4096,
    system: SYSTEM_PROMPT, // see above
    messages: [{
      role: 'user',
      content: JSON.stringify({
        target_chunks: chunks,
        submissions: subs,
        current_progress: progress,
        transcript: transcript?.transcript_text ?? null
      })
    }]
  });

  const ai = JSON.parse(msg.content[0].text);

  // 3. Insert into ai_suggestions_queue (with auto-apply for high-confidence chunk_progress)
  for (const u of ai.chunk_progress_updates) {
    if (u.confidence >= 0.9) {
      // Auto-apply
      await sb.from('chunk_progress').upsert({
        student_id: session.student_id,
        chunk_id: u.chunk_id,
        leitner_box: u.suggested_box,
        status: u.suggested_status,
        source: 'ai',
        ai_confidence: u.confidence,
        ai_reasoning: u.reasoning,
        confirmed_by_teacher_at: new Date().toISOString() // auto-applied
      });
      await sb.from('ai_suggestions_queue').insert({
        student_id: session.student_id, session_id,
        target_table: 'chunk_progress', action: 'upsert',
        payload: u, confidence: u.confidence, reasoning: u.reasoning,
        status: 'auto_applied'
      });
    } else {
      await sb.from('ai_suggestions_queue').insert({
        student_id: session.student_id, session_id,
        target_table: 'chunk_progress', action: 'upsert',
        payload: u, confidence: u.confidence, reasoning: u.reasoning,
        status: 'pending'
      });
    }
  }

  for (const e of ai.errors) {
    await sb.from('ai_suggestions_queue').insert({
      student_id: session.student_id, session_id,
      target_table: 'errors_log', action: 'insert',
      payload: e, confidence: e.confidence, reasoning: e.reasoning,
      status: 'pending'
    });
  }

  for (const r of ai.rubric_scores) {
    await sb.from('ai_suggestions_queue').insert({
      student_id: session.student_id, session_id,
      target_table: 'rubric_scores', action: 'insert',
      payload: r, confidence: r.confidence, reasoning: r.note,
      status: 'pending'
    });
  }

  // 4. Update session_log with AI summary
  await sb.from('session_log').update({
    ai_summary: ai.session_summary,
    summary_note: ai.session_summary, // shown to student next time
    ended_at: new Date().toISOString()
  }).eq('id', session_id);

  return new Response(JSON.stringify({ ok: true, ai }), { headers: { 'Content-Type': 'application/json' } });
});
```

## Deploy

```bash
supabase functions deploy process_lesson --no-verify-jwt
supabase secrets set ANTHROPIC_API_KEY=sk-ant-…
```

## Fireflies integration (optional)

Before running `process_lesson`, teacher can attach a meeting_id in the UI:
```
POST /rest/v1/lesson_transcripts
{
  session_id, student_id, unit: 1,
  transcript_source: 'fireflies',
  transcript_text: <fetched via Fireflies API using meeting_id>
}
```
Or an admin-side manual paste.

## Manual dry-run (without edge function)

For MVP testing:
1. Teacher clicks **End lesson**.
2. `session_log.ended_at` gets set client-side.
3. Teacher opens the AI queue tab — sees empty state ("configure edge function").
4. In parallel: paste submissions into Claude with the system prompt above, insert results manually into `ai_suggestions_queue`.

This way we can validate the prompt on real student data before spending on edge-function infrastructure.
