// Start page: clock, prefix search, keyboard hints. No network calls.
"use strict";

const GROUPS = [
  { name: "dev", accent: "var(--base0D)", links: [
    ["g", "GitHub", "https://github.com/ind4skylivey"],
    ["r", "nixos-s1b", "https://github.com/ind4skylivey/nixos-s1b"],
    ["n", "search.nixos.org", "https://search.nixos.org/packages"],
    ["h", "home-manager options", "https://home-manager-options.extranix.com/"],
    ["o", "noogle", "https://noogle.dev/"],
    ["m", "mynixos", "https://mynixos.com/"],
  ]},
  { name: "security", accent: "var(--base08)", links: [
    ["e", "exploit-db", "https://www.exploit-db.com/"],
    ["c", "CVE / NVD", "https://nvd.nist.gov/vuln/search"],
    ["b", "HackTheBox", "https://app.hackthebox.com/"],
    ["t", "TryHackMe", "https://tryhackme.com/"],
    ["f", "GTFOBins", "https://gtfobins.github.io/"],
  ]},
  { name: "linux", accent: "var(--base0C)", links: [
    ["a", "Arch Wiki", "https://wiki.archlinux.org/"],
    ["w", "NixOS Wiki", "https://wiki.nixos.org/"],
    ["x", "mango", "https://github.com/mangowm/mango"],
  ]},
  { name: "personal", accent: "var(--base0E)", links: [
    ["p", "about", "https://ind4skylivey.github.io/about/"],
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
  for (const [key, label, url] of g.links) {
    HINTS[key] = url;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = url;
    a.rel = "noreferrer";
    a.innerHTML = `<span class="hint">${key}</span><span></span>`;
    a.lastChild.textContent = label;
    li.append(a);
    ul.append(li);
  }
  sec.append(h, ul);
  root.append(sec);
}

for (const [bang, [name]] of Object.entries(BANGS)) {
  const dt = document.createElement("dt"), dd = document.createElement("dd");
  dt.textContent = bang; dd.textContent = name;
  $("#bangs").append(dt, dd);
}

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

  const url = HINTS[e.key.toLowerCase()];
  if (url && e.key.length === 1) {
    e.preventDefault();
    if (e.shiftKey) window.open(url, "_blank", "noopener");
    else location.href = url;
  }
});

q.focus();
setMode();
