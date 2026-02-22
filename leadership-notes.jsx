import { useState, useEffect, useCallback } from "react";

/* ════════════════════════════════════════════════════════
   LEADERSHIP NOTES — Private On-Device Coaching Journal
   ════════════════════════════════════════════════════════ */

const THEMES = {
  light: {
    bg: "#f4f1eb", bgCard: "#ffffff", bgInput: "#ffffff", bgNav: "#ffffff",
    text: "#1a1a2e", textSoft: "#666", textMuted: "#aaa",
    accent: "#2d6a4f", accentGlow: "rgba(45,106,79,0.15)",
    border: "#e0ddd5", borderAccent: "#2d6a4f",
    danger: "#d63031", dangerBg: "#fff5f5",
    warn: "#e67e22", warnBg: "#fef9ef",
    shadow: "0 2px 8px rgba(0,0,0,0.06)",
    navShadow: "0 -1px 10px rgba(0,0,0,0.05)",
    gradient: "linear-gradient(135deg, #2d6a4f, #40916c)",
  },
  dark: {
    bg: "#0a1f1f", bgCard: "rgba(0,30,30,0.7)", bgInput: "rgba(0,0,0,0.3)", bgNav: "rgba(10,20,20,0.95)",
    text: "#e0f0ea", textSoft: "rgba(255,255,255,0.55)", textMuted: "rgba(255,255,255,0.25)",
    accent: "#00e5a0", accentGlow: "rgba(0,229,160,0.15)",
    border: "rgba(0,229,160,0.12)", borderAccent: "rgba(0,229,160,0.4)",
    danger: "#ff4757", dangerBg: "rgba(255,71,87,0.1)",
    warn: "#f0c040", warnBg: "rgba(240,192,64,0.08)",
    shadow: "0 2px 8px rgba(0,0,0,0.2)",
    navShadow: "none",
    gradient: "linear-gradient(135deg, #00e5a0, #00b87a)",
  },
  rainbow: {
    bg: "#1a1a2e", bgCard: "rgba(30,20,50,0.7)", bgInput: "rgba(0,0,0,0.3)", bgNav: "rgba(20,15,40,0.95)",
    text: "#f0e6ff", textSoft: "rgba(255,255,255,0.6)", textMuted: "rgba(255,255,255,0.25)",
    accent: "#e040fb", accentGlow: "rgba(224,64,251,0.15)",
    border: "rgba(224,64,251,0.15)", borderAccent: "rgba(224,64,251,0.4)",
    danger: "#ff4757", dangerBg: "rgba(255,71,87,0.1)",
    warn: "#ffd93d", warnBg: "rgba(255,217,61,0.08)",
    shadow: "0 2px 8px rgba(0,0,0,0.3)",
    navShadow: "none",
    gradient: "linear-gradient(135deg, #e040fb, #536dfe, #00e5ff)",
  },
};

const DEFAULT_CATEGORIES = [
  { id: "arrival", label: "Arrival", icon: "🚶", color: "#2d6a4f", hasSubType: true, subTypes: ["Late", "Early"], hasDuration: true, hasNotice: true },
  { id: "lunch", label: "Lunch", icon: "🍔", color: "#e67e22", hasSubType: true, subTypes: ["Early", "Late"], hasDuration: true, hasNotice: true },
  { id: "early_out", label: "Early Out", icon: "🚪", color: "#ff7b54", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: true, hasNotice: false },
  { id: "no_show", label: "No Show", icon: "👻", color: "#d63031", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: false, hasNotice: false },
  { id: "missing", label: "Missing", icon: "🔍", color: "#8e44ad", hasSubType: false, hasDuration: true, hasNotice: true },
  { id: "unauth_break", label: "Unauth Break", icon: "🚫", color: "#c0392b", hasSubType: false, hasDuration: true, hasNotice: false, alwaysNoNotice: true },
  { id: "coaching", label: "Coaching", icon: "🎯", color: "#2980b9", hasSubType: false, hasDuration: false, hasNotice: false },
  { id: "highlight", label: "Highlight", icon: "⭐", color: "#f39c12", hasSubType: false, hasDuration: false, hasNotice: false },
  { id: "note", label: "Note", icon: "📝", color: "#7f8c8d", hasSubType: false, hasDuration: false, hasNotice: false },
];

const DEFAULT_FOLLOWUPS = [
  { label: "24 hours", hours: 24 },
  { label: "48 hours", hours: 48 },
  { label: "72 hours", hours: 72 },
  { label: "1 week", hours: 168 },
  { label: "2 weeks", hours: 336 },
];

const DEFAULT_TEAMS = [
  { id: "t1", name: "Team 1", active: true },
  { id: "t2", name: "Team 2", active: false },
  { id: "t3", name: "Team 3", active: false },
  { id: "t4", name: "Team 4", active: false },
  { id: "t5", name: "Team 5", active: false },
];

const DEFAULT_DUR = { max: 60, increment: 5 };
const VIEWS = { ENTRY: 0, HISTORY: 1, REPORTS: 2, PEOPLE: 3, SETTINGS: 4 };

const S = {
  async get(k) { try { const r = await window.storage.get(k); return r ? JSON.parse(r.value) : null; } catch { return null; } },
  async set(k, v) { try { await window.storage.set(k, JSON.stringify(v)); } catch {} },
};
const uid = () => Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
const fd = (d) => new Date(d).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
const ft = (d) => new Date(d).toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
const isoDay = (d) => (d instanceof Date ? d : new Date(d)).toISOString().split("T")[0];

export default function App() {
  const [loading, setLoading] = useState(true);
  const [view, setView] = useState(VIEWS.ENTRY);
  const [toast, setToast] = useState(null);
  const [menuOpen, setMenuOpen] = useState(false);
  const [theme, setTheme] = useState("dark");

  const [entries, setEntries] = useState([]);
  const [people, setPeople] = useState([]);
  const [categories, setCategories] = useState(DEFAULT_CATEGORIES);
  const [teams, setTeams] = useState(DEFAULT_TEAMS);
  const [followups, setFollowups] = useState(DEFAULT_FOLLOWUPS);
  const [durSet, setDurSet] = useState(DEFAULT_DUR);

  // Form
  const [fPer, setFPer] = useState("");
  const [fCat, setFCat] = useState("");
  const [fSub, setFSub] = useState("");
  const [fDur, setFDur] = useState(null);
  const [fNot, setFNot] = useState(null);
  const [fFol, setFFol] = useState(null);
  const [fNote, setFNote] = useState("");
  const [editId, setEditId] = useState(null);
  const [addPer, setAddPer] = useState(false);
  const [newName, setNewName] = useState("");
  const [newTeam, setNewTeam] = useState("t1");

  // History
  const [hPer, setHPer] = useState("all");
  const [hCat, setHCat] = useState("all");
  const [hTm, setHTm] = useState("all");
  const [hQ, setHQ] = useState("");
  const [expandedEntry, setExpandedEntry] = useState(null);

  // Reports
  const [rS, setRS] = useState(() => { const d = new Date(); d.setDate(d.getDate() - 30); return isoDay(d); });
  const [rE, setRE] = useState(() => isoDay(new Date()));
  const [rPer, setRPer] = useState("all");
  const [rTm, setRTm] = useState("all");
  const [showPrev, setShowPrev] = useState(false);

  // People
  const [viewPer, setViewPer] = useState(null);
  const [addDate, setAddDate] = useState(false);
  const [ndLabel, setNdLabel] = useState("");
  const [ndDate, setNdDate] = useState("");
  const [ndRemind, setNdRemind] = useState("1 week");
  const [ndRecur, setNdRecur] = useState(true);

  // Settings
  const [sTab, setSTab] = useState("general");
  const [editCat, setEditCat] = useState(null);
  const [editTeam, setEditTeam] = useState(null);

  const T = THEMES[theme];
  const activeTeams = teams.filter(t => t.active);
  const selCat = categories.find(c => c.id === fCat);

  useEffect(() => {
    (async () => {
      const [e, p, c, t, f, d, th] = await Promise.all([
        S.get("ln-e"), S.get("ln-p"), S.get("ln-c"), S.get("ln-t"), S.get("ln-f"), S.get("ln-d"), S.get("ln-theme")
      ]);
      if (e) setEntries(e); if (p) setPeople(p); if (c) setCategories(c);
      if (t) setTeams(t); if (f) setFollowups(f); if (d) setDurSet(d);
      if (th) setTheme(th);
      setLoading(false);
    })();
  }, []);

  const sv = async (k, s, v) => { s(v); await S.set(k, v); };
  const svE = v => sv("ln-e", setEntries, v);
  const svP = v => sv("ln-p", setPeople, v);
  const svC = v => sv("ln-c", setCategories, v);
  const svT = v => sv("ln-t", setTeams, v);
  const svF = v => sv("ln-f", setFollowups, v);
  const svD = v => sv("ln-d", setDurSet, v);
  const svTh = v => { setTheme(v); S.set("ln-theme", v); };

  const flash = (m) => { setToast(m); setTimeout(() => setToast(null), 2200); };

  const resetForm = () => { setFPer(""); setFCat(""); setFSub(""); setFDur(null); setFNot(null); setFFol(null); setFNote(""); setEditId(null); };

  // ─── ACTIONS ───
  const saveEntry = async () => {
    if (!fPer || !fCat) return flash("⚡ Pick person & category!");
    if (selCat?.hasSubType && !fSub) return flash("⚡ Pick a type!");
    const e = {
      id: editId || uid(), personId: fPer, personName: people.find(p => p.id === fPer)?.name || "?",
      category: fCat, subType: fSub || null, duration: fDur, notice: selCat?.alwaysNoNotice ? false : fNot,
      followup: fFol ? { hours: fFol, due: new Date(Date.now() + fFol * 36e5).toISOString() } : null,
      notes: fNote.trim(), timestamp: editId ? entries.find(x => x.id === editId)?.timestamp : new Date().toISOString(),
    };
    if (editId) { await svE(entries.map(x => x.id === editId ? e : x)); flash("✏️ Updated!"); }
    else { await svE([e, ...entries]); flash("⚡ Logged!"); }
    resetForm();
  };

  const delEntry = async (id) => { await svE(entries.filter(x => x.id !== id)); flash("🗑️ Deleted"); };

  const startEdit = (e) => {
    setEditId(e.id); setFPer(e.personId); setFCat(e.category); setFSub(e.subType || "");
    setFDur(e.duration); setFNot(e.notice); setFFol(e.followup?.hours || null); setFNote(e.notes || "");
    setView(VIEWS.ENTRY);
  };

  const addPerson = async () => {
    if (!newName.trim()) return;
    const p = { id: uid(), name: newName.trim(), teamId: newTeam, dates: [] };
    await svP([...people, p]); setNewName(""); setAddPer(false); setFPer(p.id); flash(`👋 ${p.name} added!`);
  };

  const nukePerson = async (id) => {
    const p = people.find(x => x.id === id);
    if (!confirm(`☢️ DELETE ${p?.name} and ALL their entries?\n\nEmail their report first if you need records.`)) return;
    await svP(people.filter(x => x.id !== id));
    await svE(entries.filter(x => x.personId !== id));
    setViewPer(null); flash(`☢️ ${p?.name} nuked`);
  };

  const addImportantDate = async (pid) => {
    if (!ndLabel.trim() || !ndDate) return;
    await svP(people.map(p => p.id !== pid ? p : {
      ...p, dates: [...(p.dates || []), { id: uid(), label: ndLabel.trim(), date: ndDate, remind: ndRemind, recurring: ndRecur }]
    }));
    setNdLabel(""); setNdDate(""); setAddDate(false); flash("📅 Date saved!");
  };

  const delImportantDate = async (pid, did) => {
    await svP(people.map(p => p.id !== pid ? p : { ...p, dates: (p.dates || []).filter(d => d.id !== did) }));
    flash("🗑️ Removed");
  };

  // ─── REMINDERS ───
  const reminders = (() => {
    const now = new Date(); const r = [];
    people.forEach(p => (p.dates || []).forEach(d => {
      const rH = d.remind === "48 hours" ? 48 : d.remind === "1 week" ? 168 : 336;
      let dt = new Date(d.date + "T12:00:00");
      if (d.recurring) { dt.setFullYear(now.getFullYear()); if (dt < now) dt.setFullYear(now.getFullYear() + 1); }
      const dH = (dt - now) / 36e5;
      if (dH > 0 && dH <= rH) r.push({ person: p.name, label: d.label, days: Math.ceil(dH / 24) });
    }));
    entries.forEach(e => {
      if (!e.followup?.due) return;
      const diff = (new Date(e.followup.due) - now) / 36e5;
      if (diff > -24 && diff < 48) {
        const c = categories.find(x => x.id === e.category);
        r.push({ person: e.personName, label: `Follow-up: ${c?.label || ""}`, days: Math.max(0, Math.ceil(diff / 24)), isF: true });
      }
    });
    return r.sort((a, b) => a.days - b.days);
  })();

  // ─── FILTERS ───
  const filtHist = entries.filter(e => {
    if (hPer !== "all" && e.personId !== hPer) return false;
    if (hCat !== "all" && e.category !== hCat) return false;
    if (hTm !== "all") { const p = people.find(x => x.id === e.personId); if (p?.teamId !== hTm) return false; }
    if (hQ) { const s = hQ.toLowerCase(); if (!`${e.personName} ${e.notes} ${e.subType}`.toLowerCase().includes(s)) return false; }
    return true;
  });

  const filtReport = entries.filter(e => {
    const d = new Date(e.timestamp);
    if (d < new Date(rS)) return false; if (d > new Date(rE + "T23:59:59")) return false;
    if (rPer !== "all" && e.personId !== rPer) return false;
    if (rTm !== "all") { const p = people.find(x => x.id === e.personId); if (p?.teamId !== rTm) return false; }
    return true;
  });

  const genReport = (pid) => {
    const re = pid ? filtReport.filter(e => e.personId === pid) : filtReport;
    const l = [`LEADERSHIP NOTES REPORT`, `${fd(rS)} — ${fd(rE)}`, `Total: ${re.length} entries`, ``];
    const g = {};
    re.forEach(e => { if (!g[e.personId]) g[e.personId] = []; g[e.personId].push(e); });
    Object.keys(g).forEach(pid => {
      const p = people.find(x => x.id === pid);
      l.push(`=== ${p?.name || g[pid][0]?.personName || "?"} (${g[pid].length}) ===`);
      g[pid].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp)).forEach(e => {
        const c = categories.find(x => x.id === e.category);
        let line = `  ${fd(e.timestamp)} | ${c?.icon || ""} ${c?.label || e.category}`;
        if (e.subType) line += ` - ${e.subType}`;
        if (e.duration) line += ` - ${e.duration} min`;
        if (e.notice === true) line += " (Notice)";
        if (e.notice === false && c?.hasNotice) line += " (No notice)";
        l.push(line);
        if (e.notes) l.push(`    ${e.notes}`);
      });
      l.push("");
    });
    return l.join("\n");
  };

  const emailReport = (pid) => {
    const body = genReport(pid);
    const nm = pid ? people.find(p => p.id === pid)?.name : "All";
    window.open(`mailto:?subject=${encodeURIComponent(`Leadership Notes - ${nm} - ${fd(rS)} to ${fd(rE)}`)}&body=${encodeURIComponent(body)}`);
  };

  const archive = async (yr) => {
    const ye = entries.filter(e => new Date(e.timestamp).getFullYear() === yr);
    if (!ye.length) return flash("No entries for " + yr);
    if (!confirm(`📦 Archive ${ye.length} entries from ${yr}? Will email report then clear.`)) return;
    const body = [`ARCHIVE ${yr}\n${ye.length} entries\n`];
    ye.forEach(e => {
      const c = categories.find(x => x.id === e.category);
      body.push(`${fd(e.timestamp)} | ${e.personName} | ${c?.label}${e.subType ? ` (${e.subType})` : ""}${e.duration ? ` ${e.duration}min` : ""}${e.notes ? ` - ${e.notes}` : ""}`);
    });
    window.open(`mailto:?subject=${encodeURIComponent(`Leadership Notes Archive ${yr}`)}&body=${encodeURIComponent(body.join("\n"))}`);
    await svE(entries.filter(e => new Date(e.timestamp).getFullYear() !== yr));
    flash(`📦 ${yr} archived!`);
  };

  // ─── STYLES (theme-aware) ───
  const card = { background: T.bgCard, borderRadius: 14, border: `1px solid ${T.border}`, padding: 16, marginBottom: 12, boxShadow: T.shadow };
  const inp = { width: "100%", padding: "11px 14px", borderRadius: 10, border: `1.5px solid ${T.border}`, fontSize: 15, fontFamily: "inherit", outline: "none", boxSizing: "border-box", background: T.bgInput, color: T.text, transition: "border-color 0.2s" };
  const lbl = { fontSize: 11, fontWeight: 800, color: T.accent, letterSpacing: "0.8px", textTransform: "uppercase", marginBottom: 6, display: "block" };
  const btn1 = { width: "100%", padding: "14px", borderRadius: 12, border: "none", background: T.gradient, color: theme === "light" ? "#fff" : "#001a1a", fontSize: 15, fontWeight: 800, cursor: "pointer", fontFamily: "inherit" };
  const btn2 = { ...btn1, background: T.accentGlow, color: T.accent, border: `1px solid ${T.borderAccent}` };
  const btnD = { ...btn1, background: T.dangerBg, color: T.danger, border: `1px solid ${T.danger}33` };

  const rainbowBorder = theme === "rainbow" ? { borderImage: "linear-gradient(135deg, #e040fb, #536dfe, #00e5ff, #69f0ae, #ffd740, #ff6e40) 1", borderImageSlice: 1 } : {};

  if (loading) return (
    <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100vh", background: T.bg, color: T.accent, fontFamily: "'DM Sans', sans-serif", fontSize: 18 }}>
      ⚡ Loading...
    </div>
  );

  // ─── DURATION PICKER ───
  const DurPicker = ({ value, onChange }) => {
    const opts = [];
    for (let i = durSet.increment; i <= durSet.max; i += durSet.increment) opts.push(i);
    return (
      <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
        {opts.map(v => (
          <button key={v} onClick={() => onChange(v)} style={{
            padding: "10px 0", width: 52, borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
            border: value === v ? `2px solid ${T.accent}` : `1px solid ${T.border}`,
            background: value === v ? T.accentGlow : T.bgInput,
            color: value === v ? T.accent : T.textSoft,
            fontSize: 14, fontWeight: value === v ? 800 : 500, textAlign: "center",
          }}>{v}</button>
        ))}
      </div>
    );
  };

  const Toggle2 = ({ value, onChange, a, b }) => (
    <div style={{ display: "flex", gap: 4, background: T.bgInput, borderRadius: 10, padding: 3, border: `1px solid ${T.border}` }}>
      {[{ v: true, l: a || "Yes" }, { v: false, l: b || "No" }].map(o => (
        <button key={String(o.v)} onClick={() => onChange(o.v)} style={{
          flex: 1, padding: "10px 14px", borderRadius: 8, border: "none", cursor: "pointer",
          background: value === o.v ? T.accentGlow : "transparent",
          color: value === o.v ? T.accent : T.textMuted,
          fontWeight: 700, fontSize: 14, fontFamily: "inherit",
        }}>{o.l}</button>
      ))}
    </div>
  );

  const CatBadge = ({ catId, small }) => {
    const c = categories.find(x => x.id === catId);
    if (!c) return null;
    return <span style={{ background: c.color + "22", color: c.color, border: `1px solid ${c.color}44`, borderRadius: 8, padding: small ? "2px 7px" : "3px 10px", fontSize: small ? 11 : 12, fontWeight: 700, whiteSpace: "nowrap" }}>{c.icon} {c.label}</span>;
  };

  // ─── NAV ───
  const navItems = [
    { v: VIEWS.ENTRY, icon: "⚡", l: "Entry" },
    { v: VIEWS.HISTORY, icon: "📋", l: "History" },
    { v: VIEWS.REPORTS, icon: "📊", l: "Reports" },
    { v: VIEWS.PEOPLE, icon: "👥", l: "People" },
  ];

  return (
    <div style={{ fontFamily: "'DM Sans', -apple-system, sans-serif", background: T.bg, minHeight: "100vh", maxWidth: 600, margin: "0 auto", position: "relative", color: T.text }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

      {toast && (
        <div style={{ position: "fixed", top: 16, left: "50%", transform: "translateX(-50%)", background: T.bgCard, color: T.accent, padding: "10px 22px", borderRadius: 12, fontSize: 14, fontWeight: 700, zIndex: 1000, boxShadow: `0 4px 20px rgba(0,0,0,0.2)`, border: `1px solid ${T.borderAccent}`, animation: "slideD .3s ease", ...rainbowBorder }}>
          {toast}
        </div>
      )}

      {/* HEADER */}
      <div style={{ background: T.bgNav, padding: "12px 16px", display: "flex", justifyContent: "space-between", alignItems: "center", position: "sticky", top: 0, zIndex: 100, borderBottom: `1px solid ${T.border}`, ...rainbowBorder }}>
        <div>
          <div style={{ color: T.accent, fontSize: 17, fontWeight: 800, letterSpacing: "-0.3px" }}>📋 Leadership Notes</div>
          <div style={{ color: T.textMuted, fontSize: 9, letterSpacing: "1px", fontWeight: 700 }}>PRIVATE • ON-DEVICE</div>
        </div>
        <button onClick={() => setMenuOpen(!menuOpen)} style={{ background: T.accentGlow, border: `1px solid ${T.borderAccent}`, borderRadius: 10, padding: "7px 14px", color: T.accent, fontSize: 14, cursor: "pointer", fontWeight: 700, fontFamily: "inherit" }}>
          🍔
        </button>
      </div>

      {menuOpen && (
        <>
          <div onClick={() => setMenuOpen(false)} style={{ position: "fixed", inset: 0, zIndex: 90, background: "rgba(0,0,0,0.4)" }} />
          <div style={{ position: "absolute", top: 52, right: 12, background: T.bgCard, borderRadius: 14, boxShadow: `0 8px 30px rgba(0,0,0,0.25)`, zIndex: 95, border: `1px solid ${T.border}`, overflow: "hidden", minWidth: 180, ...rainbowBorder }}>
            {[...navItems, { v: VIEWS.SETTINGS, icon: "⚙️", l: "Settings" }].map(m => (
              <button key={m.v} onClick={() => { setView(m.v); setMenuOpen(false); setViewPer(null); }} style={{
                display: "flex", alignItems: "center", gap: 10, width: "100%", padding: "12px 16px",
                border: "none", background: view === m.v ? T.accentGlow : "transparent", cursor: "pointer",
                fontSize: 14, fontFamily: "inherit", fontWeight: view === m.v ? 800 : 500,
                color: view === m.v ? T.accent : T.textSoft, textAlign: "left",
                borderBottom: `1px solid ${T.border}`,
              }}><span style={{ fontSize: 16 }}>{m.icon}</span> {m.l}</button>
            ))}
          </div>
        </>
      )}

      {/* REMINDERS */}
      {view === VIEWS.ENTRY && reminders.length > 0 && (
        <div style={{ margin: "10px 14px 0", ...card, background: T.warnBg, border: `1px solid ${T.warn}33` }}>
          <div style={{ fontSize: 11, fontWeight: 800, color: T.warn, marginBottom: 4 }}>🔔 {reminders.length} REMINDER{reminders.length > 1 ? "S" : ""}</div>
          {reminders.slice(0, 4).map((r, i) => (
            <div key={i} style={{ fontSize: 12, color: T.textSoft, marginTop: 2 }}>
              {r.isF ? "🎯" : "📅"} <b>{r.person}</b> — {r.label} ({r.days === 0 ? "Today!" : `${r.days}d`})
            </div>
          ))}
        </div>
      )}

      {/* CONTENT */}
      <div style={{ padding: 14, paddingBottom: 80 }}>

        {/* ═══ ENTRY ═══ */}
        {view === VIEWS.ENTRY && (
          <div>
            <h2 style={{ fontSize: 19, fontWeight: 800, margin: "0 0 14px", color: T.accent }}>{editId ? "✏️ Edit Entry" : "⚡ Quick Entry"}</h2>

            <div style={{ marginBottom: 14 }}>
              <label style={lbl}>👤 Person</label>
              {people.length === 0 && !addPer ? (
                <button onClick={() => setAddPer(true)} style={btn1}>+ Add First Person</button>
              ) : (
                <>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
                    {people.map(p => (
                      <button key={p.id} onClick={() => setFPer(p.id)} style={{
                        padding: "9px 14px", borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
                        border: fPer === p.id ? `2px solid ${T.accent}` : `1px solid ${T.border}`,
                        background: fPer === p.id ? T.accentGlow : T.bgInput,
                        color: fPer === p.id ? T.accent : T.textSoft, fontSize: 13, fontWeight: 700,
                      }}>{p.name}</button>
                    ))}
                    <button onClick={() => setAddPer(true)} style={{ padding: "9px 14px", borderRadius: 10, border: `1px dashed ${T.borderAccent}`, background: "transparent", color: T.accent, fontSize: 13, cursor: "pointer", fontFamily: "inherit", fontWeight: 600 }}>+ Add</button>
                  </div>
                  {addPer && (
                    <div style={{ ...card, marginTop: 8, padding: 12 }}>
                      <input value={newName} onChange={e => setNewName(e.target.value)} onKeyDown={e => e.key === "Enter" && addPerson()} placeholder="Name..." autoFocus style={{ ...inp, marginBottom: 8 }} />
                      <select value={newTeam} onChange={e => setNewTeam(e.target.value)} style={{ ...inp, marginBottom: 8 }}>
                        {activeTeams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                      </select>
                      <div style={{ display: "flex", gap: 8 }}>
                        <button onClick={addPerson} style={{ ...btn1, flex: 1 }}>Add</button>
                        <button onClick={() => { setAddPer(false); setNewName(""); }} style={{ ...btn2, flex: 0, width: "auto", padding: "14px 18px" }}>✕</button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </div>

            <div style={{ marginBottom: 14 }}>
              <label style={lbl}>📂 Category</label>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: 7 }}>
                {categories.map(c => (
                  <button key={c.id} onClick={() => { setFCat(c.id); setFSub(""); setFDur(null); setFNot(null); }} style={{
                    padding: "11px 8px", borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
                    border: fCat === c.id ? `2px solid ${c.color}` : `1px solid ${T.border}`,
                    background: fCat === c.id ? c.color + "18" : T.bgInput,
                    color: fCat === c.id ? c.color : T.textSoft,
                    fontSize: 13, fontWeight: 700, display: "flex", alignItems: "center", gap: 6, textAlign: "left",
                  }}><span style={{ fontSize: 15 }}>{c.icon}</span> {c.label}</button>
                ))}
              </div>
            </div>

            {selCat?.hasSubType && (
              <div style={{ marginBottom: 14 }}>
                <label style={lbl}>{selCat.label} — Type</label>
                <div style={{ display: "flex", gap: 8 }}>
                  {selCat.subTypes.map(s => (
                    <button key={s} onClick={() => setFSub(s)} style={{
                      flex: 1, padding: "11px", borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
                      border: fSub === s ? `2px solid ${selCat.color}` : `1px solid ${T.border}`,
                      background: fSub === s ? selCat.color + "18" : T.bgInput,
                      color: fSub === s ? selCat.color : T.textSoft, fontSize: 14, fontWeight: 700,
                    }}>{s}</button>
                  ))}
                </div>
              </div>
            )}

            {selCat?.hasDuration && (
              <div style={{ marginBottom: 14 }}>
                <label style={lbl}>⏱️ Duration (minutes)</label>
                <DurPicker value={fDur} onChange={setFDur} />
              </div>
            )}

            {selCat?.hasNotice && !selCat?.alwaysNoNotice && (
              <div style={{ marginBottom: 14 }}>
                <label style={lbl}>📢 Notice Given?</label>
                <Toggle2 value={fNot} onChange={setFNot} a="Yes 📢" b="No 🚫" />
              </div>
            )}

            <div style={{ marginBottom: 14 }}>
              <label style={lbl}>📅 Follow-up?</label>
              {fFol === null ? (
                <button onClick={() => setFFol(followups[0]?.hours || 24)} style={btn2}>+ Add Follow-up</button>
              ) : (
                <div>
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginBottom: 6 }}>
                    {followups.map(f => (
                      <button key={f.hours} onClick={() => setFFol(f.hours)} style={{
                        padding: "8px 14px", borderRadius: 8, cursor: "pointer", fontFamily: "inherit",
                        border: fFol === f.hours ? `2px solid ${T.warn}` : `1px solid ${T.border}`,
                        background: fFol === f.hours ? T.warnBg : T.bgInput,
                        color: fFol === f.hours ? T.warn : T.textMuted, fontSize: 13, fontWeight: 700,
                      }}>{f.label}</button>
                    ))}
                  </div>
                  <button onClick={() => setFFol(null)} style={{ fontSize: 12, color: T.textMuted, background: "none", border: "none", cursor: "pointer", fontFamily: "inherit" }}>✕ Remove</button>
                </div>
              )}
            </div>

            <div style={{ marginBottom: 18 }}>
              <label style={lbl}>📝 Notes (optional)</label>
              <textarea value={fNote} onChange={e => setFNote(e.target.value)} placeholder="Details..." rows={3} style={{ ...inp, resize: "vertical" }} />
            </div>

            <button onClick={saveEntry} style={btn1}>{editId ? "✏️ Update" : "⚡ Save Entry"}</button>
            {editId && <button onClick={resetForm} style={{ ...btn2, marginTop: 8 }}>Cancel</button>}
          </div>
        )}

        {/* ═══ HISTORY ═══ */}
        {view === VIEWS.HISTORY && (
          <div>
            <h2 style={{ fontSize: 19, fontWeight: 800, margin: "0 0 10px", color: T.accent }}>📋 History</h2>
            <input value={hQ} onChange={e => setHQ(e.target.value)} placeholder="🔍 Search..." style={{ ...inp, marginBottom: 8 }} />
            <div style={{ display: "flex", gap: 6, marginBottom: 10, flexWrap: "wrap" }}>
              <select value={hPer} onChange={e => setHPer(e.target.value)} style={{ ...inp, flex: 1, minWidth: 90 }}>
                <option value="all">All People</option>
                {people.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
              <select value={hCat} onChange={e => setHCat(e.target.value)} style={{ ...inp, flex: 1, minWidth: 90 }}>
                <option value="all">All Categories</option>
                {categories.map(c => <option key={c.id} value={c.id}>{c.icon} {c.label}</option>)}
              </select>
            </div>
            <div style={{ fontSize: 11, color: T.textMuted, marginBottom: 8, fontWeight: 700 }}>{filtHist.length} entries</div>
            {filtHist.length === 0 ? (
              <div style={{ textAlign: "center", padding: 40, color: T.textMuted }}>{entries.length === 0 ? "No entries yet ⚡" : "No matches"}</div>
            ) : filtHist.map(e => {
              const c = categories.find(x => x.id === e.category);
              const isOpen = expandedEntry === e.id;
              return (
                <div key={e.id} onClick={() => setExpandedEntry(isOpen ? null : e.id)} style={{ ...card, borderLeft: `3px solid ${c?.color || "#888"}`, cursor: "pointer", padding: "11px 14px" }}>
                  <div style={{ display: "flex", justifyContent: "space-between" }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, fontSize: 14 }}>{e.personName}</div>
                      <div style={{ display: "flex", gap: 5, flexWrap: "wrap", marginTop: 4, alignItems: "center" }}>
                        <CatBadge catId={e.category} small />
                        {e.subType && <span style={{ fontSize: 11, color: T.textSoft }}>{e.subType}</span>}
                        {e.duration && <span style={{ fontSize: 11, color: T.warn, fontWeight: 700 }}>⏱️{e.duration}m</span>}
                        {e.notice === true && <span style={{ fontSize: 10, color: T.accent }}>📢</span>}
                        {e.notice === false && c?.hasNotice && <span style={{ fontSize: 10, color: T.danger }}>🚫</span>}
                        {e.followup && <span style={{ fontSize: 10, color: T.warn }}>📅</span>}
                      </div>
                    </div>
                    <div style={{ fontSize: 10, color: T.textMuted, textAlign: "right" }}>{fd(e.timestamp)}<br />{ft(e.timestamp)}</div>
                  </div>
                  {isOpen && (
                    <div style={{ marginTop: 10, paddingTop: 10, borderTop: `1px solid ${T.border}` }}>
                      {e.notes && <div style={{ fontSize: 13, color: T.textSoft, marginBottom: 8, lineHeight: 1.5 }}>{e.notes}</div>}
                      {e.followup && <div style={{ fontSize: 12, color: T.warn, marginBottom: 8 }}>📅 Follow-up: {fd(e.followup.due)}</div>}
                      <div style={{ display: "flex", gap: 8 }}>
                        <button onClick={ev => { ev.stopPropagation(); startEdit(e); }} style={{ fontSize: 12, padding: "6px 14px", borderRadius: 8, border: `1px solid ${T.borderAccent}`, background: T.accentGlow, cursor: "pointer", fontWeight: 700, color: T.accent, fontFamily: "inherit" }}>✏️ Edit</button>
                        <button onClick={ev => { ev.stopPropagation(); if (confirm("Delete?")) delEntry(e.id); }} style={{ fontSize: 12, padding: "6px 14px", borderRadius: 8, border: `1px solid ${T.danger}33`, background: T.dangerBg, cursor: "pointer", fontWeight: 700, color: T.danger, fontFamily: "inherit" }}>🗑️</button>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {/* ═══ REPORTS ═══ */}
        {view === VIEWS.REPORTS && (
          <div>
            <h2 style={{ fontSize: 19, fontWeight: 800, margin: "0 0 10px", color: T.accent }}>📊 Reports</h2>
            <div style={card}>
              <div style={{ display: "flex", gap: 8, marginBottom: 8 }}>
                <div style={{ flex: 1 }}><label style={lbl}>Start</label><input type="date" value={rS} onChange={e => setRS(e.target.value)} style={inp} /></div>
                <div style={{ flex: 1 }}><label style={lbl}>End</label><input type="date" value={rE} onChange={e => setRE(e.target.value)} style={inp} /></div>
              </div>
              <select value={rPer} onChange={e => setRPer(e.target.value)} style={{ ...inp, marginBottom: 6 }}>
                <option value="all">All People</option>
                {people.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
              </select>
              {activeTeams.length > 1 && <select value={rTm} onChange={e => setRTm(e.target.value)} style={inp}>
                <option value="all">All Teams</option>
                {activeTeams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
              </select>}
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginBottom: 14 }}>
              <div style={{ ...card, textAlign: "center" }}><div style={{ fontSize: 28, fontWeight: 800, color: T.accent }}>{filtReport.length}</div><div style={{ fontSize: 10, color: T.textMuted, fontWeight: 700 }}>ENTRIES</div></div>
              <div style={{ ...card, textAlign: "center" }}><div style={{ fontSize: 28, fontWeight: 800, color: T.warn }}>{new Set(filtReport.map(e => e.personId)).size}</div><div style={{ fontSize: 10, color: T.textMuted, fontWeight: 700 }}>PEOPLE</div></div>
            </div>

            {/* HEAT MAP */}
            <div style={card}>
              <div style={{ fontSize: 12, fontWeight: 800, color: T.accent, marginBottom: 10 }}>🔥 HEAT MAP</div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 7 }}>
                {categories.map(c => {
                  const cnt = filtReport.filter(e => e.category === c.id).length;
                  const mx = Math.max(...categories.map(cc => filtReport.filter(e => e.category === cc.id).length), 1);
                  const pct = cnt / mx;
                  return (
                    <div key={c.id} style={{
                      background: cnt > 0 ? `${c.color}${Math.round(pct * 50 + 10).toString(16).padStart(2, "0")}` : T.bgInput,
                      border: `1px solid ${cnt > 0 ? c.color + "44" : T.border}`,
                      borderRadius: 10, padding: "10px 6px", textAlign: "center",
                      boxShadow: pct > 0.6 ? `0 0 12px ${c.color}22` : "none",
                    }}>
                      <div style={{ fontSize: 18 }}>{c.icon}</div>
                      <div style={{ fontSize: 10, fontWeight: 700, color: cnt > 0 ? c.color : T.textMuted, marginTop: 3 }}>{c.label}</div>
                      <div style={{ fontSize: 16, fontWeight: 800, color: cnt > 0 ? T.text : T.textMuted, marginTop: 2 }}>{cnt}</div>
                    </div>
                  );
                })}
              </div>
            </div>

            <button onClick={() => emailReport(rPer !== "all" ? rPer : null)} style={{ ...btn1, marginBottom: 8 }}>📧 Email Report</button>
            <button onClick={() => setShowPrev(!showPrev)} style={btn2}>{showPrev ? "Hide" : "👁️ Preview"}</button>
            {showPrev && <pre style={{ ...card, marginTop: 8, fontSize: 11, whiteSpace: "pre-wrap", maxHeight: 300, overflow: "auto", lineHeight: 1.6, color: T.textSoft }}>{genReport(rPer !== "all" ? rPer : null)}</pre>}
          </div>
        )}

        {/* ═══ PEOPLE ═══ */}
        {view === VIEWS.PEOPLE && !viewPer && (
          <div>
            <h2 style={{ fontSize: 19, fontWeight: 800, margin: "0 0 14px", color: T.accent }}>👥 People</h2>
            <div style={{ display: "flex", gap: 6, marginBottom: 14 }}>
              <input value={newName} onChange={e => setNewName(e.target.value)} onKeyDown={e => e.key === "Enter" && addPerson()} placeholder="Name..." style={{ ...inp, flex: 1 }} />
              <select value={newTeam} onChange={e => setNewTeam(e.target.value)} style={{ ...inp, flex: 0, width: "auto", minWidth: 90 }}>
                {activeTeams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
              </select>
              <button onClick={addPerson} style={{ padding: "0 16px", borderRadius: 10, border: "none", background: T.gradient, color: theme === "light" ? "#fff" : "#001a1a", fontWeight: 800, cursor: "pointer", fontFamily: "inherit", fontSize: 18 }}>+</button>
            </div>
            {people.length === 0 ? <div style={{ textAlign: "center", padding: 40, color: T.textMuted }}>No people yet 👋</div> : people.map(p => (
              <div key={p.id} onClick={() => setViewPer(p.id)} style={{ ...card, display: "flex", justifyContent: "space-between", alignItems: "center", cursor: "pointer" }}>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 15 }}>{p.name}</div>
                  <div style={{ fontSize: 11, color: T.textMuted }}>{teams.find(t => t.id === p.teamId)?.name} • {entries.filter(e => e.personId === p.id).length} entries • {(p.dates || []).length} dates</div>
                </div>
                <span style={{ color: T.textMuted, fontSize: 18 }}>›</span>
              </div>
            ))}
          </div>
        )}

        {/* PERSON DETAIL */}
        {view === VIEWS.PEOPLE && viewPer && (() => {
          const p = people.find(x => x.id === viewPer);
          if (!p) return null;
          return (
            <div>
              <button onClick={() => setViewPer(null)} style={{ background: "none", border: "none", color: T.accent, cursor: "pointer", fontFamily: "inherit", fontSize: 14, fontWeight: 700, marginBottom: 10, padding: 0 }}>← Back</button>
              <h2 style={{ fontSize: 20, fontWeight: 800, margin: "0 0 2px" }}>{p.name}</h2>
              <div style={{ fontSize: 11, color: T.textMuted, marginBottom: 14 }}>{teams.find(t => t.id === p.teamId)?.name} • {entries.filter(e => e.personId === p.id).length} entries</div>

              <div style={card}>
                <label style={lbl}>Team</label>
                <select value={p.teamId || ""} onChange={e => svP(people.map(x => x.id === p.id ? { ...x, teamId: e.target.value } : x))} style={inp}>
                  {activeTeams.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                </select>
              </div>

              <div style={card}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
                  <label style={{ ...lbl, marginBottom: 0 }}>📅 Important Dates</label>
                  <button onClick={() => setAddDate(true)} style={{ background: "none", border: "none", color: T.accent, cursor: "pointer", fontWeight: 700, fontFamily: "inherit", fontSize: 13 }}>+ Add</button>
                </div>
                {(p.dates || []).length === 0 && !addDate && <div style={{ fontSize: 13, color: T.textMuted, textAlign: "center", padding: 14 }}>No dates yet</div>}
                {(p.dates || []).map(d => (
                  <div key={d.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "7px 0", borderBottom: `1px solid ${T.border}` }}>
                    <div>
                      <div style={{ fontSize: 14, fontWeight: 600 }}>{d.label}</div>
                      <div style={{ fontSize: 11, color: T.textMuted }}>{fd(d.date)} • {d.remind} • {d.recurring ? "🔄 Yearly" : "One-time"}</div>
                    </div>
                    <button onClick={() => delImportantDate(p.id, d.id)} style={{ background: "none", border: "none", color: T.danger, cursor: "pointer", fontSize: 14 }}>✕</button>
                  </div>
                ))}
                {addDate && (
                  <div style={{ marginTop: 10, padding: 12, background: T.bgInput, borderRadius: 10 }}>
                    <input value={ndLabel} onChange={e => setNdLabel(e.target.value)} placeholder='e.g. "Birthday", "Forklift Cert"' style={{ ...inp, marginBottom: 8 }} />
                    <input type="date" value={ndDate} onChange={e => setNdDate(e.target.value)} style={{ ...inp, marginBottom: 8 }} />
                    <select value={ndRemind} onChange={e => setNdRemind(e.target.value)} style={{ ...inp, marginBottom: 8 }}>
                      {["48 hours", "1 week", "2 weeks"].map(r => <option key={r} value={r}>{r} before</option>)}
                    </select>
                    <div style={{ marginBottom: 8 }}><label style={lbl}>Yearly?</label><Toggle2 value={ndRecur} onChange={setNdRecur} a="Yes 🔄" b="No" /></div>
                    <div style={{ display: "flex", gap: 8 }}>
                      <button onClick={() => addImportantDate(p.id)} style={{ ...btn1, flex: 1 }}>Save</button>
                      <button onClick={() => { setAddDate(false); setNdLabel(""); setNdDate(""); }} style={{ ...btn2, flex: 0, width: "auto", padding: "14px 18px" }}>✕</button>
                    </div>
                  </div>
                )}
              </div>

              <button onClick={() => nukePerson(p.id)} style={{ ...btnD, marginTop: 8 }}>☢️ Delete {p.name} & All Entries</button>
            </div>
          );
        })()}

        {/* ═══ SETTINGS ═══ */}
        {view === VIEWS.SETTINGS && (
          <div>
            <h2 style={{ fontSize: 19, fontWeight: 800, margin: "0 0 10px", color: T.accent }}>⚙️ Settings</h2>
            <div style={{ display: "flex", gap: 4, marginBottom: 14, flexWrap: "wrap" }}>
              {["general", "categories", "teams", "data"].map(t => (
                <button key={t} onClick={() => setSTab(t)} style={{
                  padding: "7px 13px", borderRadius: 8,
                  border: sTab === t ? `1px solid ${T.borderAccent}` : `1px solid ${T.border}`,
                  background: sTab === t ? T.accentGlow : "transparent",
                  color: sTab === t ? T.accent : T.textMuted, fontWeight: 700, fontSize: 13, cursor: "pointer", fontFamily: "inherit",
                  textTransform: "capitalize",
                }}>{t}</button>
              ))}
            </div>

            {sTab === "general" && (
              <div>
                {/* Theme */}
                <div style={card}>
                  <label style={lbl}>🎨 Theme</label>
                  <div style={{ display: "flex", gap: 8 }}>
                    {[{ k: "light", l: "☀️ Light" }, { k: "dark", l: "🌙 Dark" }, { k: "rainbow", l: "💡 Neon" }].map(o => (
                      <button key={o.k} onClick={() => svTh(o.k)} style={{
                        flex: 1, padding: "12px 8px", borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
                        border: theme === o.k ? `2px solid ${THEMES[o.k].accent}` : `1px solid ${T.border}`,
                        background: theme === o.k ? THEMES[o.k].accentGlow : T.bgInput,
                        color: theme === o.k ? THEMES[o.k].accent : T.textSoft, fontSize: 13, fontWeight: 700,
                      }}>{o.l}</button>
                    ))}
                  </div>
                </div>

                <div style={card}>
                  <label style={lbl}>⏱️ Duration Max</label>
                  <input type="number" value={durSet.max} onChange={e => svD({ ...durSet, max: parseInt(e.target.value) || 60 })} style={{ ...inp, marginBottom: 10 }} />
                  <label style={lbl}>⏱️ Increment</label>
                  <input type="number" value={durSet.increment} onChange={e => svD({ ...durSet, increment: parseInt(e.target.value) || 5 })} style={inp} />
                </div>

                <div style={card}>
                  <label style={lbl}>📅 Follow-up Options</label>
                  {followups.map((f, i) => (
                    <div key={i} style={{ display: "flex", gap: 6, alignItems: "center", marginBottom: 6 }}>
                      <input value={f.label} onChange={e => { const u = [...followups]; u[i] = { ...u[i], label: e.target.value }; svF(u); }} style={{ ...inp, flex: 1 }} />
                      <input type="number" value={f.hours} onChange={e => { const u = [...followups]; u[i] = { ...u[i], hours: parseInt(e.target.value) || 24 }; svF(u); }} style={{ ...inp, flex: 0, width: 70 }} />
                      <button onClick={() => svF(followups.filter((_, j) => j !== i))} style={{ background: "none", border: "none", color: T.danger, cursor: "pointer", fontSize: 16 }}>✕</button>
                    </div>
                  ))}
                  <button onClick={() => svF([...followups, { label: "New", hours: 24 }])} style={{ ...btn2, marginTop: 4 }}>+ Add</button>
                </div>
              </div>
            )}

            {sTab === "categories" && (
              <div>
                {categories.map(c => (
                  <div key={c.id} style={card}>
                    {editCat === c.id ? (
                      <div>
                        <input value={c.label} onChange={e => svC(categories.map(x => x.id === c.id ? { ...x, label: e.target.value } : x))} style={{ ...inp, marginBottom: 6 }} placeholder="Name" />
                        <input value={c.icon} onChange={e => svC(categories.map(x => x.id === c.id ? { ...x, icon: e.target.value } : x))} style={{ ...inp, marginBottom: 6 }} placeholder="Emoji" />
                        <input value={c.color} onChange={e => svC(categories.map(x => x.id === c.id ? { ...x, color: e.target.value } : x))} type="color" style={{ ...inp, marginBottom: 6, height: 40, padding: 3 }} />
                        <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 8 }}>
                          {[["hasDuration", "Duration"], ["hasNotice", "Notice"], ["hasSubType", "Sub-types"]].map(([k, l]) => (
                            <label key={k} style={{ fontSize: 12, color: T.textSoft, display: "flex", alignItems: "center", gap: 4, cursor: "pointer" }}>
                              <input type="checkbox" checked={c[k] || false} onChange={e => svC(categories.map(x => x.id === c.id ? { ...x, [k]: e.target.checked, ...(k === "hasSubType" && e.target.checked && !x.subTypes?.length ? { subTypes: ["Option A", "Option B"] } : {}) } : x))} /> {l}
                            </label>
                          ))}
                        </div>
                        {c.hasSubType && (
                          <div style={{ marginBottom: 8 }}>
                            <label style={{ ...lbl, fontSize: 10 }}>Sub-types (comma separated)</label>
                            <input value={(c.subTypes || []).join(", ")} onChange={e => svC(categories.map(x => x.id === c.id ? { ...x, subTypes: e.target.value.split(",").map(s => s.trim()).filter(Boolean) } : x))} style={inp} />
                          </div>
                        )}
                        <button onClick={() => setEditCat(null)} style={btn2}>Done</button>
                      </div>
                    ) : (
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                          <span style={{ fontSize: 20 }}>{c.icon}</span>
                          <div>
                            <div style={{ fontWeight: 700, color: c.color }}>{c.label}</div>
                            <div style={{ fontSize: 10, color: T.textMuted }}>{[c.hasDuration && "Duration", c.hasNotice && "Notice", c.hasSubType && (c.subTypes || []).join("/")].filter(Boolean).join(" • ") || "Basic"}</div>
                          </div>
                        </div>
                        <div style={{ display: "flex", gap: 8 }}>
                          <button onClick={() => setEditCat(c.id)} style={{ background: "none", border: "none", color: T.accent, cursor: "pointer", fontSize: 12, fontWeight: 700, fontFamily: "inherit" }}>Edit</button>
                          <button onClick={() => { if (confirm(`Delete ${c.label}?`)) svC(categories.filter(x => x.id !== c.id)); }} style={{ background: "none", border: "none", color: T.danger, cursor: "pointer", fontSize: 12 }}>✕</button>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
                <button onClick={() => { const n = { id: uid(), label: "New", icon: "📌", color: "#888", hasSubType: false, hasDuration: false, hasNotice: false }; svC([...categories, n]); setEditCat(n.id); }} style={btn1}>+ Add Category</button>
              </div>
            )}

            {sTab === "teams" && (
              <div>
                {teams.map(t => (
                  <div key={t.id} style={card}>
                    {editTeam === t.id ? (
                      <div>
                        <input value={t.name} onChange={e => svT(teams.map(x => x.id === t.id ? { ...x, name: e.target.value } : x))} style={{ ...inp, marginBottom: 8 }} />
                        <button onClick={() => setEditTeam(null)} style={btn2}>Done</button>
                      </div>
                    ) : (
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <div>
                          <div style={{ fontWeight: 700, color: t.active ? T.text : T.textMuted }}>{t.name}</div>
                          <div style={{ fontSize: 11, color: t.active ? T.accent : T.textMuted }}>{t.active ? "Active" : "Inactive"} • {people.filter(p => p.teamId === t.id).length} people</div>
                        </div>
                        <div style={{ display: "flex", gap: 8 }}>
                          <button onClick={() => svT(teams.map(x => x.id === t.id ? { ...x, active: !x.active } : x))} style={{ background: "none", border: "none", cursor: "pointer", fontSize: 12, fontWeight: 700, fontFamily: "inherit", color: t.active ? T.danger : T.accent }}>{t.active ? "Deactivate" : "Activate"}</button>
                          <button onClick={() => setEditTeam(t.id)} style={{ background: "none", border: "none", color: T.accent, cursor: "pointer", fontSize: 12, fontWeight: 700, fontFamily: "inherit" }}>Rename</button>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}

            {sTab === "data" && (
              <div>
                <div style={card}>
                  <div style={{ fontSize: 13, color: T.textSoft, lineHeight: 1.6, marginBottom: 10 }}>🔒 All data stored on your device. Nothing leaves your phone.</div>
                  <div style={{ fontSize: 12, color: T.textMuted, marginBottom: 14 }}>{entries.length} entries • {people.length} people</div>
                  <button onClick={async () => {
                    const d = JSON.stringify({ entries, people, categories, teams, followups, durSet, theme }, null, 2);
                    const b = new Blob([d], { type: "application/json" });
                    const u = URL.createObjectURL(b);
                    const a = document.createElement("a"); a.href = u; a.download = `leadership-notes-${isoDay(new Date())}.json`; a.click();
                    URL.revokeObjectURL(u); flash("💾 Downloaded!");
                  }} style={{ ...btn1, marginBottom: 8 }}>💾 Backup</button>
                  <button onClick={() => {
                    const i = document.createElement("input"); i.type = "file"; i.accept = ".json";
                    i.onchange = async ev => {
                      try {
                        const d = JSON.parse(await ev.target.files[0].text());
                        if (!d.entries || !d.people) return flash("Invalid file");
                        if (!confirm(`Import ${d.entries.length} entries, ${d.people.length} people?`)) return;
                        await svE(d.entries); await svP(d.people);
                        if (d.categories) await svC(d.categories); if (d.teams) await svT(d.teams);
                        if (d.followups) await svF(d.followups); if (d.durSet) await svD(d.durSet);
                        if (d.theme) svTh(d.theme); flash("📂 Imported!");
                      } catch { flash("Error reading file"); }
                    }; i.click();
                  }} style={{ ...btn2, marginBottom: 8 }}>📂 Import</button>

                  <div style={{ marginTop: 8, marginBottom: 8 }}>
                    <label style={lbl}>📦 Archive Year</label>
                    <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                      {[...new Set(entries.map(e => new Date(e.timestamp).getFullYear()))].sort().map(y => (
                        <button key={y} onClick={() => archive(y)} style={{ ...btn2, width: "auto", padding: "10px 14px" }}>📦 {y} ({entries.filter(e => new Date(e.timestamp).getFullYear() === y).length})</button>
                      ))}
                      {entries.length === 0 && <span style={{ fontSize: 12, color: T.textMuted }}>No entries</span>}
                    </div>
                  </div>

                  <button onClick={async () => {
                    if (!confirm("☢️ DELETE EVERYTHING?")) return;
                    if (!confirm("Seriously — gone forever. Sure?")) return;
                    await svE([]); await svP([]); await svC(DEFAULT_CATEGORIES); await svT(DEFAULT_TEAMS);
                    await svF(DEFAULT_FOLLOWUPS); await svD(DEFAULT_DUR); flash("☢️ Reset complete");
                  }} style={{ ...btnD, marginTop: 8 }}>☢️ Nuclear Reset</button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* BOTTOM NAV */}
      <div style={{
        position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)",
        width: "100%", maxWidth: 600, background: T.bgNav, borderTop: `1px solid ${T.border}`,
        display: "flex", justifyContent: "space-around", padding: "5px 0 8px", zIndex: 50,
        boxShadow: T.navShadow, ...(theme === "rainbow" ? { borderImage: "linear-gradient(90deg, #e040fb, #536dfe, #00e5ff, #69f0ae, #ffd740) 1" } : {}),
      }}>
        {navItems.map(n => (
          <button key={n.v} onClick={() => { setView(n.v); setViewPer(null); }} style={{
            border: "none", background: "none", cursor: "pointer", textAlign: "center",
            color: view === n.v ? T.accent : T.textMuted, fontFamily: "inherit", padding: "4px 14px",
          }}>
            <div style={{ fontSize: 18 }}>{n.icon}</div>
            <div style={{ fontSize: 9, fontWeight: 800, marginTop: 1 }}>{n.l}</div>
          </button>
        ))}
      </div>

      <style>{`
        @keyframes slideD { from { opacity:0; transform:translateX(-50%) translateY(-10px); } to { opacity:1; transform:translateX(-50%) translateY(0); } }
        input:focus, textarea:focus, select:focus { border-color: ${T.borderAccent} !important; }
        select option { background: ${theme === "light" ? "#fff" : "#0a1f1f"}; color: ${T.text}; }
        * { -webkit-tap-highlight-color: transparent; box-sizing: border-box; }
      `}</style>
    </div>
  );
}
