-- ============================================================
-- SEED DATA — initial students + Unit 1 chunks
-- Run after schema.sql
-- ============================================================

-- ------------------------------------------------------------
-- Students (initial 4 — new ones added via /admin.html later)
-- ------------------------------------------------------------
insert into students (nickname, full_name, level, current_unit) values
  ('Yana Soroka',     'Yana Soroka',     'B2', 1),
  ('Mike Pylypenko',  'Mike Pylypenko',  'B2', 1),
  ('Mike B2',         'Mike B2',         'B2', 1),
  ('Darina B2',       'Darina B2',       'B2', 1)
on conflict (nickname) do nothing;

-- ------------------------------------------------------------
-- Unit 1 CORE chunks (SB Vocabulary spot — direct teaching)
-- ------------------------------------------------------------
insert into chunks (id, unit, subtopic, headword, chunk, pos, tier, pattern, collocates, examples, extra_contexts, notes) values
-- 1A Films, music, books
('u1_1A_catchy',       1, '1A', 'catchy',       'a catchy tune / chorus / slogan',        'adj', 'core', null, '["catchy tune","catchy chorus","catchy slogan","catchy jingle"]', '["It''s a very catchy tune","a great song with a catchy chorus"]', '["a catchy TikTok jingle stuck in my head all day","the brand needs a catchier tagline"]', 'sticks in your mind'),
('u1_1A_hilarious',    1, '1A', 'hilarious',    'absolutely hilarious',                    'adj', 'core', 'extreme adjective (really/absolutely, NOT very)', '["a hilarious joke","hilarious YouTube clips"]', '["the entire speech was hilarious"]', '["my Monday meetings are hilariously chaotic","his impression of the boss is absolutely hilarious"]', 'extremely funny'),
('u1_1A_commercial',   1, '1A', 'commercial',   'a commercial success / failure',          'adj', 'core', null, '["a commercial TV channel","not commercially viable","a commercial success"]', '["the film was a flop commercially"]', '["her indie album turned surprisingly commercial","a commercially safe sequel"]', 'often negative — made just for money'),
('u1_1A_disturbing',   1, '1A', 'disturbing',   'find sth disturbing',                     'adj', 'core', 'extreme (really/deeply)', '["deeply disturbing news","find some scenes disturbing"]', '["a disturbing trend","a disturbing thought"]', '["I found the news alert disturbing","there''s a disturbing trend in tech layoffs"]', null),
('u1_1A_over_the_top', 1, '1A', 'over-the-top', 'over-the-top / OTT',                      'adj', 'core', null, '["over-the-top acting","his reaction was over-the-top","OTT"]', '[]', '["her Instagram is a bit OTT","an over-the-top wedding proposal on TikTok"]', 'so extreme it seems silly'),
('u1_1A_gripping',     1, '1A', 'gripping',     'a gripping tale / drama',                 'adj', 'core', 'extreme (really/absolutely)', '["a gripping tale","a gripping story","a gripping ending"]', '[]', '["the podcast is genuinely gripping","her memoir is a gripping account of survival"]', null),
('u1_1A_uplifting',    1, '1A', 'uplifting',    'an uplifting story / experience',         'adj', 'core', null, '["a joyful and uplifting occasion","uplifting music","an uplifting message"]', '[]', '["a genuinely uplifting graduation speech","I need something uplifting after this news"]', 'makes you feel hope'),
('u1_1A_weird',        1, '1A', 'weird',        'a bit weird / really weird',              'adj', 'core', null, '["a weird feeling","weirdly, the stadium was empty"]', '[]', '["it''s weird how empty the office is on Fridays","a weird notification popped up"]', 'strange and unusual'),
('u1_1A_astonishing',  1, '1A', 'astonishing',  'astonishing accomplishment',              'adj', 'core', 'extreme (really/absolutely)', '["an astonishing accomplishment","her creativity astonishes me"]', '[]', '["an astonishing turnaround in the second half","astonishingly, the flight was on time"]', null),
('u1_1A_dreadful',     1, '1A', 'dreadful',     'absolutely dreadful',                     'adj', 'core', 'extreme (really/absolutely, NOT very)', '["dreadful weather","absolutely dreadful news"]', '[]', '["the traffic this morning was dreadful","an absolutely dreadful first draft"]', null),

-- 1B Reviews, remakes, plots
('u1_1B_box_office',   1, '1B', 'box office',   'a box-office hit / flop',                 'n',   'core', null, '["take at the box office","a box-office hit","a box-office smash hit"]', '[]', '["the sequel bombed at the box office","an unexpected box-office hit last summer"]', null),
('u1_1B_revolve',      1, '1B', 'revolve',      'the plot revolves around sb/sth',         'v',   'core', 'revolve AROUND + noun', '["the plot revolves around a young boy","his life revolves around making art"]', '[]', '["her career revolves around one big client","the meeting revolved around Q4 targets"]', null),
('u1_1B_twist',        1, '1B', 'twist',        'a plot twist / twists and turns',         'n',   'core', null, '["a plot twist","twists and turns","I didn''t expect a plot twist like this"]', '[]', '["life took a weird twist that year","the negotiation had more twists and turns than a thriller"]', null),
('u1_1B_sequel',       1, '1B', 'sequel',       'a sequel to sth',                          'n',   'core', 'sequel TO + noun', '["a sequel to the novel","the sequel came a few years later"]', '[]', '["her second album feels like a sequel to the first"]', null),
('u1_1B_adaptation',   1, '1B', 'adaptation',   'an adaptation of sth',                    'n',   'core', null, '["an adaptation of Macbeth","a television adaptation"]', '[]', '["a graphic-novel adaptation for streaming","the stage adaptation was tighter than the book"]', null),
('u1_1B_classic',      1, '1B', 'classic',      'a classic novel / film',                  'adj', 'core', null, '["a classic Brazilian novel","one of my all-time favourite classics"]', '[]', '["a modern classic","it''s a classic mistake we all make on our first job"]', null),
('u1_1B_smash_hit',    1, '1B', 'smash hit',    'a smash hit',                              'n',   'core', null, '["a smash hit album","a box-office smash hit"]', '[]', '["the song became an unexpected smash hit on TikTok","her podcast is a smash hit with under-30s"]', null),
('u1_1B_driven',       1, '1B', 'driven',       'driven by sth / a driven person',         'adj', 'core', 'driven BY + noun', '["driven by desire","a driven professional","a driven person"]', '[]', '["she''s driven by curiosity, not money","a decision driven by market pressure"]', null),
('u1_1B_reliant',      1, '1B', 'reliant',      'reliant on sth',                          'adj', 'core', 'reliant ON + noun', '["heavily reliant on box office success","reliant on technology"]', '[]', '["we''re too reliant on Slack","a business model reliant on ad revenue"]', null),
('u1_1B_tackle',       1, '1B', 'tackle',       'tackle a problem / challenge',            'v',   'core', null, '["tackle a challenge","tackle a problem","tackle the issue"]', '[]', '["how are you going to tackle that inbox?","the government failed to tackle inflation"]', null),
('u1_1B_touch_on',     1, '1B', 'touch',        'touch on a subject',                      'v',   'core', 'touch ON + noun', '["touches on the subject of","touches on people''s deepest fears"]', '[]', '["the podcast briefly touched on burnout","her essay touches on identity without preaching"]', null),
('u1_1B_sharp',        1, '1B', 'sharp',        'a sharp satire on sth / sharp criticism', 'adj', 'core', 'sharp satire ON + noun', '["a sharp satire on politics","sharp criticism","sharply critical of"]', '[]', '["a sharp satire on hustle culture","the review was sharply worded"]', null),
('u1_1B_tension',      1, '1B', 'tension',      'mounting tension / tension builds',       'n',   'core', null, '["mounting tension","the tension builds throughout the film","tensions are high"]', '[]', '["mounting tension in the group chat","you could feel the tension in the meeting"]', null),
('u1_1B_all_time',     1, '1B', 'all-time',     'an all-time favourite / high / low',      'adj', 'core', null, '["all-time favourite writer","an all-time high","an all-time low"]', '[]', '["Bitcoin hit an all-time high overnight","team morale is at an all-time low"]', null),

-- 1C Pictures, art
('u1_1C_abstract',     1, '1C', 'abstract',     'abstract painting / composition',         'adj', 'core', null, '["an exhibition of abstract paintings","abstract compositions","purely abstract"]', '[]', '["her artwork is purely abstract","the report is too abstract, we need specifics"]', null),
('u1_1C_ambiguous',    1, '1C', 'ambiguous',    'deliberately ambiguous',                  'adj', 'core', null, '["an ambiguous phrase","deliberately ambiguous"]', '[]', '["her email was deliberately ambiguous","the CEO''s answer was carefully ambiguous"]', null),
('u1_1C_atmospheric',  1, '1C', 'atmospheric',  'atmospheric music / painting',            'adj', 'core', 'extreme (really/genuinely)', '["atmospheric music","an atmospheric painting"]', '[]', '["a genuinely atmospheric café for working","the show has an atmospheric opening scene"]', null),
('u1_1C_beneath',      1, '1C', 'beneath',      'beneath the surface',                     'adv', 'core', null, '["beneath the surface","beneath her smile"]', '[]', '["beneath the friendly emails, tension was building","beneath the surface, the team was exhausted"]', null),
('u1_1C_bold',         1, '1C', 'bold',         'bold colours',                             'adj', 'core', null, '["bold colours","in bold","a bold red"]', '[]', '["she made a bold career move","the pitch deck uses bold colours effectively"]', null),
('u1_1C_conventional', 1, '1C', 'conventional', 'a conventional portrait ↔ unconventional','adj', 'core', null, '["a conventional novel","a highly conventional upbringing","an unconventional approach"]', '[]', '["a conventional career path","her unconventional teaching methods work"]', null),
('u1_1C_depict',       1, '1C', 'depict',       'depict sb/sth as sth',                    'v',   'core', 'depict AS + adj/noun', '["depicted as calm","depicted the main character as cruel"]', '[]', '["the media depicted her as reckless","the ad depicts working parents as heroes"]', null),
('u1_1C_dramatic',     1, '1C', 'dramatic',     'dramatic scenery / a dramatic painting',  'adj', 'core', null, '["dramatic scenery","highly dramatic fashion"]', '[]', '["a dramatic drop in engagement","her exit from the meeting was pretty dramatic"]', null),
('u1_1C_foreground',   1, '1C', 'foreground',   'in the foreground ↔ in the background',   'n',   'core', 'IN THE + foreground/background', '["in the foreground of the picture","a small cat in the foreground"]', '[]', '["in the foreground of the report: user churn","background music vs foreground focus"]', null),
('u1_1C_heated',       1, '1C', 'heated',       'a heated debate / argument',              'adj', 'core', null, '["a heated debate","a heated argument","in the heat of the moment"]', '[]', '["a heated Slack thread about the decision","things got heated at the family dinner"]', null),
('u1_1C_impression',   1, '1C', 'impression',   'get the impression that / a vivid impression', 'n', 'core', null, '["get the impression that","a first impression","a vivid impression","leave someone with the impression"]', '[]', '["I got the distinct impression she was joking","the demo left a vivid impression on the client"]', null),
('u1_1C_interpretation', 1, '1C', 'interpretation', 'open to interpretation',              'n',   'core', 'open TO interpretation', '["the book''s open to interpretation","your interpretation of the novel","several possible interpretations"]', '[]', '["her feedback was open to interpretation","the contract clause is open to interpretation"]', null),
('u1_1C_landscape',    1, '1C', 'landscape',    'a beautiful landscape',                   'n',   'core', null, '["a beautiful landscape","paint landscapes","a rocky landscape"]', '[]', '["the media landscape has changed","the political landscape shifted overnight"]', null),
('u1_1C_subtle',       1, '1C', 'subtle',       'subtle colours / a subtle shade',         'adj', 'core', null, '["subtle colours","a subtle shade of blue","subtly different"]', '[]', '["a subtle hint in her message","the redesign uses subtly different fonts"]', null),
('u1_1C_underlying',   1, '1C', 'underlying',   'the underlying message / causes',         'adj', 'core', null, '["the underlying message of the film","underlying causes"]', '[]', '["the underlying issue is trust, not process","the underlying assumption is that users will pay"]', null),
('u1_1C_visual',       1, '1C', 'visual',       'visual clues / a visual picture',         'adj', 'core', null, '["visual clues","a visual picture"]', '[]', '["I need visual references before I can build it","a strong visual identity for the brand"]', null)
on conflict (id) do nothing;

-- ------------------------------------------------------------
-- Unit 1 EXTENSION chunks (context-only, not drilled directly)
-- ------------------------------------------------------------
insert into chunks (id, unit, subtopic, headword, chunk, pos, tier) values
-- 1A extension
('u1_1A_addicted',      1, '1A', 'addicted',      'be addicted to sth / -ing',        'adj', 'extension'),
('u1_1A_background',    1, '1A', 'background',    'in the background',                'n',   'extension'),
('u1_1A_big_budget',    1, '1A', 'big-budget',    'a big-budget film / production',   'adj', 'extension'),
('u1_1A_control',       1, '1A', 'control',       'keep control of / under control',  'v',   'extension'),
('u1_1A_on_demand',     1, '1A', 'on demand',     'on demand',                        'phrase','extension'),
('u1_1A_glued',         1, '1A', 'glued',         'be glued to sth',                  'adj', 'extension'),
('u1_1A_inspiring',     1, '1A', 'inspiring',     'an inspiring speech / teacher',    'adj', 'extension'),
('u1_1A_remake',        1, '1A', 'remake',        'a remake of sth',                  'n',   'extension'),
('u1_1A_stuff',         1, '1A', 'stuff',         'stuff like that / that kind of stuff','n', 'extension'),
('u1_1A_tear',          1, '1A', 'tear',          'burst into tears / be in tears',   'n',   'extension'),
-- 1B extension
('u1_1B_basement',      1, '1B', 'basement',      'a basement flat',                  'n',   'extension'),
('u1_1B_cast',          1, '1B', 'cast',          'an amazing cast / be cast as',     'n',   'extension'),
('u1_1B_common_ground', 1, '1B', 'common ground', 'find common ground on sth',        'n',   'extension'),
('u1_1B_desire',        1, '1B', 'desire',        'a strong desire to do sth / desire for','n','extension'),
('u1_1B_division',      1, '1B', 'division',      'social divisions / division of labour','n','extension'),
('u1_1B_dubbing',       1, '1B', 'dubbing',       'prefer subtitles to dubbing',      'n',   'extension'),
('u1_1B_elsewhere',     1, '1B', 'elsewhere',     'popular elsewhere / go elsewhere', 'adv', 'extension'),
('u1_1B_evermore',      1, '1B', 'evermore',      'evermore sophisticated',           'adv', 'extension'),
('u1_1B_flaw',          1, '1B', 'flaw',          'flaws in sth / deeply flawed',     'n',   'extension'),
('u1_1B_graphic_novel', 1, '1B', 'graphic novel', 'a graphic novel',                  'n',   'extension'),
('u1_1B_prestigious',   1, '1B', 'prestigious',   'a prestigious award / university', 'adj', 'extension'),
('u1_1B_psychological', 1, '1B', 'psychological', 'a psychological need / disorder',  'adj', 'extension'),
('u1_1B_satire',        1, '1B', 'satire',        'political satire',                 'n',   'extension'),
('u1_1B_shoot',         1, '1B', 'shoot',         'shoot a TV series',                'v',   'extension'),
('u1_1B_streaming',     1, '1B', 'streaming',     'streaming services / live streaming','n', 'extension'),
('u1_1B_terrorism',     1, '1B', 'terrorism',     'acts of terrorism',                'n',   'extension'),
('u1_1B_iceberg',       1, '1B', 'tip of the iceberg', 'just the tip of the iceberg','phrase','extension'),
('u1_1B_wealth',        1, '1B', 'wealth',        'a wealth gap / wealthy people',    'n',   'extension'),
-- 1C extension
('u1_1C_companion',     1, '1C', 'companion',     'companion pieces / a travel companion','n','extension'),
('u1_1C_compose',       1, '1C', 'compose',       'compose music',                    'v',   'extension'),
('u1_1C_digest',        1, '1C', 'digest',        'digest information / hard to digest','v','extension'),
('u1_1C_disrupt',       1, '1C', 'disrupt',       'disrupt a meeting / disruptive',   'v',   'extension'),
('u1_1C_domestic',      1, '1C', 'domestic',      'a domestic scene / life',          'adj', 'extension'),
('u1_1C_maid',          1, '1C', 'maid',          'worked as a maid',                 'n',   'extension'),
('u1_1C_presumably',    1, '1C', 'presumably',    'presumably because',               'adv', 'extension')
on conflict (id) do nothing;
