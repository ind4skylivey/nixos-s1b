// Start page: clock, prefix search, keyboard hints. No network calls.
"use strict";

// [key, label, url, nerd-font glyph]
const GROUPS = [
  { name: "dev", accent: "var(--base0D)", links: [
    ["g", "GitHub", "https://github.com/ind4skylivey", "\uf09b"],
    ["r", "nixos-s1b", "https://github.com/ind4skylivey/nixos-s1b", "\uea62"],
    ["n", "search.nixos.org", "https://search.nixos.org/packages", "\uf313"],
    ["h", "home-manager options", "https://home-manager-options.extranix.com/", "\uf015"],
    ["o", "noogle", "https://noogle.dev/", "\u03bb"],
    ["m", "mynixos", "https://mynixos.com/", "\uf313"],
  ]},
  { name: "work", accent: "var(--base0A)", links: [
    ["l", "Linear", "https://linear.app", "\uf0ae"],
    ["s", "Sentry", "https://sentry.io", "\uf188"],
    ["v", "Vibe / Le Chat", "https://chat.mistral.ai", "\uf086"],
    ["k", "Kilo Code", "https://app.kilocode.ai", "\uf121"],
    ["j", "GitLab", "https://gitlab.com", "\uf296"],
    ["u", "GitHub (home)", "https://github.com", "\uf09b"],
    ["z", "Bitflow org", "https://github.com/bfleming-bitflow", "\uf0e8"],
  ]},
  { name: "security", accent: "var(--base08)", links: [
    ["e", "exploit-db", "https://www.exploit-db.com/", "\uf0e7"],
    ["c", "CVE / NVD", "https://nvd.nist.gov/vuln/search", "\uf071"],
    ["b", "HackTheBox", "https://app.hackthebox.com/", "\uf1b2"],
    ["t", "TryHackMe", "https://tryhackme.com/", "\uf11b"],
    ["f", "GTFOBins", "https://gtfobins.github.io/", "\uf120"],
  ]},
  { name: "linux", accent: "var(--base0C)", links: [
    ["a", "Arch Wiki", "https://wiki.archlinux.org/", "\uf303"],
    ["w", "NixOS Wiki", "https://wiki.nixos.org/", "\uf02d"],
    ["x", "mango", "https://github.com/mangowm/mango", "\uf2d2"],
  ]},
  { name: "media / daily", accent: "var(--base09)", links: [
    ["y", "YouTube", "https://www.youtube.com/", "\uf16a"],
    ["d", "Reddit", "https://www.reddit.com/", "\uf1a1"],
    ["q", "ProtonDB", "https://www.protondb.com/", "\uf1b6"],
    ["1", "Proton Mail", "https://mail.proton.me/", "\uf0e0"],
    ["2", "Tuta Mail", "https://app.tuta.com/", "\uf0e0"],
  ]},
  { name: "personal", accent: "var(--base0E)", links: [
    ["p", "about", "https://ind4skylivey.github.io/about/", "\uf007"],
  ]},
];

const enc = encodeURIComponent;
const BANGS = {
  "!gh":   ["github",   q => `https://github.com/search?q=${enc(q)}&type=repositories`],
  "!nix":  ["nixpkgs",  q => `https://search.nixos.org/packages?channel=unstable&query=${enc(q)}`],
  "!nixo": ["nixos options", q => `https://search.nixos.org/options?channel=unstable&query=${enc(q)}`],
  "!hm":   ["home-manager", q => `https://home-manager-options.extranix.com/?query=${enc(q)}`],
  "!yt":   ["youtube",  q => `https://www.youtube.com/results?search_query=${enc(q)}`],
  "!r":    ["reddit",   q => `https://www.reddit.com/search/?q=${enc(q)}`],
};
const ddg = q => `https://duckduckgo.com/?q=${enc(q)}`;

const $ = s => document.querySelector(s);
const q = $("#q"), help = $("#help"), mode = $("#mode"), engine = $("#engine");

// ---- clock
const pad = n => String(n).padStart(2, "0");
function tick() {
  const d = new Date();
  $("#clock").innerHTML = `${pad(d.getHours())}:${pad(d.getMinutes())}<span class="sec">${pad(d.getSeconds())}</span>`;
  $("#date").textContent = d.toLocaleDateString("en-GB", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
  const h = d.getHours();
  $("#daypart").textContent = h < 5 ? "// late night" : h < 12 ? "// good morning" : h < 19 ? "// good afternoon" : "// good evening";
}
tick();
setInterval(tick, 1000);

// ---- links
const HINTS = {};
const root = $("#links");
for (const g of GROUPS) {
  const sec = document.createElement("div");
  sec.className = "group";
  sec.style.setProperty("--accent", g.accent);
  const h = document.createElement("h3");
  h.textContent = g.name;
  const ul = document.createElement("ul");
  for (const [key, label, url, icon] of g.links) {
    HINTS[key] = url;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = url;
    a.rel = "noreferrer";
    a.innerHTML = `<span class="hint">${key}</span><span class="ico" aria-hidden="true"></span><span></span>`;
    a.children[1].textContent = icon || "";
    a.lastChild.textContent = label;
    li.append(a);
    ul.append(li);
  }
  sec.append(h, ul);
  root.append(sec);
}

for (const g of GROUPS) {
  const dt = document.createElement("dt"), dd = document.createElement("dd");
  dt.textContent = g.name;
  dd.textContent = g.links.map(([k, l]) => `${k} ${l}`).join("  ·  ");
  $("#hintlist").append(dt, dd);
}
for (const [bang, [name]] of Object.entries(BANGS)) {
  const dt = document.createElement("dt"), dd = document.createElement("dd");
  dt.textContent = bang; dd.textContent = name;
  $("#bangs").append(dt, dd);
}

// hide glyph icons when no Nerd Font is installed (no tofu boxes)
document.fonts.ready.then(() => {
  const ok = ["Maple Mono NF", "JetBrainsMono Nerd Font", "JetBrainsMono NFM", "Symbols Nerd Font"]
    .some(f => document.fonts.check(`12px "${f}"`, "\uf09b"));
  if (!ok) document.body.classList.add("noicons");
});

// ---- search
function resolve(raw) {
  const s = raw.trim();
  if (!s) return null;
  const [first, ...rest] = s.split(/\s+/);
  if (BANGS[first]) {
    const term = rest.join(" ");
    return term ? BANGS[first][1](term) : new URL(BANGS[first][1]("x")).origin;
  }
  if (/^[a-z]+:\/\//i.test(s)) return s;
  if (/^(localhost|[\w-]+(\.[\w-]+)+)(:\d+)?(\/\S*)?$/i.test(s) && !s.includes(" ")) return "https://" + s;
  return ddg(s); // unknown !bangs are handled by DuckDuckGo itself
}
q.addEventListener("input", () => {
  const first = q.value.trim().split(/\s+/)[0];
  engine.textContent = BANGS[first] ? BANGS[first][0] : "ddg";
});
$("#search").addEventListener("submit", e => {
  e.preventDefault();
  const url = resolve(q.value);
  if (url) location.href = url;
});

// ---- modes
function setMode() {
  const insert = document.activeElement === q;
  document.body.classList.toggle("normal", !insert);
  mode.textContent = insert ? "INSERT" : "NORMAL";
}
q.addEventListener("focus", setMode);
q.addEventListener("blur", setMode);
window.addEventListener("focus", () => { if (document.activeElement === document.body) q.focus(); });

document.addEventListener("keydown", e => {
  if (e.ctrlKey || e.metaKey || e.altKey) return;
  const inSearch = document.activeElement === q;

  if (e.key === "Escape") {
    e.preventDefault();
    if (!help.hidden) { help.hidden = true; return; }
    if (inSearch) { if (q.value) { q.value = ""; engine.textContent = "ddg"; } else q.blur(); }
    else if (document.activeElement) document.activeElement.blur();
    setMode();
    return;
  }
  if (inSearch) return;

  if (e.key === "?") { e.preventDefault(); help.hidden = !help.hidden; return; }
  if (!help.hidden) return;
  if (e.key === "/" || e.key === "i") { e.preventDefault(); q.focus(); return; }

  const k = /^Digit\d$/.test(e.code) ? e.code.slice(5) : e.key.toLowerCase();
  const url = HINTS[k];
  if (url && (e.key.length === 1)) {
    e.preventDefault();
    if (e.shiftKey) window.open(url, "_blank", "noopener");
    else location.href = url;
  }
});

q.focus();
setMode();
