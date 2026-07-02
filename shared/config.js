// ============================================================
// SUPABASE CONFIG
// Fill in your project URL and anon key.
// (Anon key is safe to expose in the browser — protected by RLS.)
// ============================================================
window.OUTCOMES_CONFIG = {
  SUPABASE_URL:      'https://limjrozcsedvnhvzqmml.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_WNTDqd2YxAzQ0fpSTlkelQ_dCDJRx1t',

  // Session storage keys
  SESSION_KEY: 'outcomes_session_v1',

  // Roles
  ROLE_TEACHER: 'teacher',
  ROLE_STUDENT: 'student',

  // Teacher passphrase (client-side gate — Supabase RLS is the real security)
  // CHANGE THIS to something only you know.
  TEACHER_PASSPHRASE: 'outcomes-vale-2026'
};

// Session helpers
window.OutcomesSession = {
  get() {
    try { return JSON.parse(localStorage.getItem(window.OUTCOMES_CONFIG.SESSION_KEY)); }
    catch (e) { return null; }
  },
  set(sess) {
    localStorage.setItem(window.OUTCOMES_CONFIG.SESSION_KEY, JSON.stringify(sess));
  },
  clear() {
    localStorage.removeItem(window.OUTCOMES_CONFIG.SESSION_KEY);
  },
  requireStudent(redirect = '../../login.html') {
    const s = this.get();
    if (!s || s.role !== window.OUTCOMES_CONFIG.ROLE_STUDENT) {
      window.location.href = redirect;
    }
    return s;
  },
  requireTeacher(redirect = '../../login.html') {
    const s = this.get();
    if (!s || s.role !== window.OUTCOMES_CONFIG.ROLE_TEACHER) {
      window.location.href = redirect;
    }
    return s;
  }
};

// Supabase client (lazy)
window.getSupabase = function () {
  if (!window._sb) {
    if (!window.supabase) {
      console.warn('Supabase JS SDK not loaded');
      return null;
    }
    window._sb = window.supabase.createClient(
      window.OUTCOMES_CONFIG.SUPABASE_URL,
      window.OUTCOMES_CONFIG.SUPABASE_ANON_KEY
    );
  }
  return window._sb;
};
