// Atuin threads: the coding-agent sessions Atuin captured, newest first, for the shown
// space's repo (or every space). Click one to resume it in a new tab of that space, in the
// folder it worked in; shift-click forks it instead. Atuin writes the session out from sync
// first when this machine doesn't have it, and resumes it in its own agent.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, spaces, panes, run, theme, appHome, readTextFile, props, closeOverlay } from "herdr";

// `atuin` from the user's PATH, unless `local.json` beside this file names another build
// (`{ "atuin": "/path/to/atuin" }`): the CLI must match the running daemon.
const ATUIN = "atuin";
const LOCAL = "local.json";
const LIMIT = 80;
const REFRESH = 30000;
// Prints the herdr terminal already running a thread, if any: a process started by
// `atuin threads resume <atuin id>`, or the Claude Code process ~/.claude/sessions maps
// to its session id. Each carries HC_TERMINAL_ID in its environment.
const FIND = `pids=$(pgrep -f "threads resume $2")
[ -n "$1" ] && for f in "$HOME"/.claude/sessions/*.json; do grep -qF "$1" "$f" 2>/dev/null && pids="$pids $(basename "$f" .json)"; done
for p in $pids; do t=$(tr '\\0' '\\n' < /proc/$p/environ 2>/dev/null | sed -n 's/^HC_TERMINAL_ID=//p'); [ -n "$t" ] && { echo "$t"; exit; }; done`;

// How each harness is drawn: its icon in the app's table, full color or a tinted glyph.
const ICON = {
  "claude-code": { file: "icons/claude.svg", tint: false },
  codex: { file: "icons/codex.svg", tint: false },
  copilot: { file: "icons/copilot.svg", tint: true },
  opencode: { file: "icons/opencode.svg", tint: true },
  pi: { file: "icons/pi.svg", tint: true },
  omp: { file: "icons/pi.svg", tint: true },
};
const NAME = { "claude-code": "Claude Code", codex: "Codex", copilot: "Copilot", opencode: "opencode", pi: "pi", omp: "omp" };

const base = (path) => path.replace(/\/+$/, "").split("/").pop() || path;
const inside = (dir, root) => dir === root || dir.startsWith(`${root}/`);
// One line of text: titles and previews may hold newlines and control characters.
const line = (s) => (s ?? "").replace(/[\u0000-\u001f\u007f]+/g, " ").trim();

function ago(iso) {
  const ms = Date.now() - Date.parse(iso);
  const m = Math.floor(ms / 60000);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

// Where a space is now: its first terminal's live folder, else where it was made (as the
// spaces sidebar sees it).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}

function icon(harness, t) {
  const spec = ICON[harness];
  if (!spec) return div().w(14).h(14).flex_none();
  return spec.tint ? svg(spec.file).size(14).flex_none().text_color(t.muted) : image(spec.file).w(14).h(14).flex_none();
}

export default class Threads extends View {
  init(_props, cx) {
    this.atuin = ATUIN;
    this.threads = [];
    this.error = null;
    this.loaded = false;
    this.loading = false;
    this.scope = "space"; // or "all"
    this.roots = {}; // folder -> its repo root (the folder itself outside a repo)
    // ponytail: keyboard selection doesn't scroll the list; fine while threads fit, add a scroll handle if not
    this.at = 0; // type to filter, ↑/↓ move, Enter resumes (shift forks), Tab (or ←/→ while empty) switches scope, Esc closes
    this.shown = [];
    this.filter = "";
    this.input = InputState.new({ placeholder: "Search threads…" });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; cx.notify(); });
    this.input.on("submit", (e, cx) => { if (this.shown[this.at]) this.resume(this.shown[this.at], e.shift, cx); });
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      const local = await readTextFile(`${appHome()}/mods/atuin-threads/${LOCAL}`);
      if (local) {
        try {
          this.atuin = JSON.parse(local).atuin || ATUIN;
        } catch (e) {
          this.error = `${LOCAL}: ${e.message}`;
        }
      }
      this.refresh(cx);
    });
    cx.timer.every(REFRESH, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const r = await exec(this.atuin, ["threads", "search", "", "--limit", String(LIMIT), "--style", "json"]);
        if (r.code !== 0) throw new Error(line(r.stderr).split("Location:")[0] || `atuin exited ${r.code}`);
        // A subagent's thread resumes as its parent's, so only roots are listed.
        this.threads = JSON.parse(r.stdout).map((m) => m.session).filter((s) => !s.parent_atuin_id);
        this.error = null;
      } catch (e) {
        this.error = String(e.message ?? e);
      }
      this.loaded = true;
      this.loading = false;
      cx.notify();
    });
  }

  // The repo root of `dir`, looked up once; `dir` itself until known, and outside a repo.
  root(dir, cx) {
    if (dir in this.roots) return this.roots[dir];
    this.roots[dir] = dir;
    cx.spawn(async (cx) => {
      const r = await exec("git", ["-C", dir, "rev-parse", "--show-toplevel"]);
      if (r.code === 0 && r.stdout.trim()) {
        this.roots[dir] = r.stdout.trim();
        cx.notify();
      }
    });
    return dir;
  }

  // A new tab in the shown space, in the thread's folder when this machine has it (else
  // atuin picks one), running atuin's resume: it writes the session out if need be and
  // hands the terminal to the agent.
  resume(th, fork, cx) {
    const space = spaces().find((s) => s.active);
    const args = ["threads", "resume", th.atuin_id];
    if (fork) args.push("--fork");
    const name = line(th.title).slice(0, 28) || undefined;
    cx.spawn(async () => {
      if (!fork) {
        const open = (await exec("sh", ["-c", FIND, "sh", th.session_id ?? "", th.atuin_id])).stdout.trim();
        if (open) {
          closeOverlay(props().overlay);
          return run("pane.focus", { terminal: open });
        }
      }
      const has = th.cwd ? (await exec("test", ["-d", th.cwd])).code === 0 : false;
      run("tab.new", { space: space?.id, name, folder: has ? th.cwd : undefined, argv: [this.atuin, ...args] });
    });
  }

  tab(t, id, label, on) {
    return div()
      .id(id)
      .px(8)
      .h(22)
      .rounded(6)
      .flex()
      .items_center()
      .text_size(11.5)
      .text_color(on ? t.foreground : t.muted)
      .when(on, (el) => el.bg(t.raised))
      .hover((el) => el.bg(t.hover))
      .on_click((_e, cx) => {
        this.scope = id;
        this.at = 0;
        cx.notify();
      })
      .child(label);
  }

  header(t, here, mine, cx) {
    return v_flex()
      .flex_none()
      .px(10)
      .pt(10)
      .pb(6)
      .gap(6)
      .child(h_flex().items_center().justify_between()
        .child(div().text_size(12).font_semibold().text_color(t.foreground).child("Threads"))
        .child(div()
          .id("refresh")
          .size(20)
          .rounded(5)
          .flex()
          .items_center()
          .justify_center()
          .text_color(t.muted)
          .hover((el) => el.bg(t.hover))
          .on_click((_e, cx) => this.refresh(cx))
          .when(this.loading, (el) => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).text_color(t.working).spin(900)))
          .when(!this.loading, (el) => el.child("↻"))))
      .child(h_flex().gap(4)
        .child(this.tab(t, "space", here ? `${base(here)} (${mine})` : "This space", this.scope === "space"))
        .child(this.tab(t, "all", `All (${this.threads.length})`, this.scope === "all")))
      .child(h_flex().h(30).px(8).items_center().rounded(7).border_1().border_color(t.border).bg(t.background)
        .child(Input.new(this.input).flex_1().h_full().text_size(12).text_color(t.foreground)));
  }

  row(t, th, on) {
    const title = line(th.title) || line(th.preview) || "(untitled)";
    const model = th.model ? ` · ${th.model}` : "";
    return v_flex()
      .id(`th-${th.atuin_id}`)
      .flex_none()
      .px(8)
      .py(5)
      .gap(2)
      .rounded(7)
      .when(on, (el) => el.bg(t.hover))
      .hover((el) => el.bg(t.hover))
      .on_click((e, cx) => this.resume(th, e.modifiers.shift, cx))
      .child(h_flex().gap(7).items_center()
        .child(icon(th.harness, t))
        .child(div().flex_1().truncate().text_color(t.foreground).child(title)))
      .child(h_flex().pl(21).gap(5).items_center().text_size(11).text_color(t.dim)
        .child(div().flex_none().child(ago(th.updated_at)))
        .child(div().flex_none().child("·"))
        .child(div().truncate().child(`${NAME[th.harness] ?? th.harness}${model} · ${th.message_count}`))
        .when(this.scope === "all" && Boolean(th.cwd), (el) => el
          .child(div().flex_none().child("·"))
          .child(div().flex_none().truncate().text_color(t.muted).child(base(th.cwd)))));
  }

  empty(t, text) {
    return div().px(12).py(10).text_size(12).text_color(t.dim).child(text);
  }

  render(cx) {
    const t = theme();
    const ps = panes();
    const space = spaces().find((s) => s.active);
    const here = space ? this.root(place(space, ps), cx) : null;
    const mine = here ? this.threads.filter((th) => th.cwd && inside(th.cwd, here)) : [];
    const q = this.filter.trim().toLowerCase();
    const shown = (this.scope === "space" ? mine : this.threads)
      .filter((th) => !q || [th.title, th.preview, th.cwd, th.model, NAME[th.harness]].some((v) => v && v.toLowerCase().includes(q)));
    this.shown = shown;

    let body;
    if (this.error) body = this.empty(t, `atuin: ${this.error}`).text_color(t.blocked);
    else if (!this.loaded) body = this.empty(t, "Loading…");
    else if (shown.length === 0) body = this.empty(t, q ? "No matching threads." : this.scope === "space" ? `No threads in ${here ? base(here) : "this space"} yet.` : "No threads captured yet.");
    else body = v_flex().id("list").flex_1().overflow_y_scrollbar().px(4).pb(6).children(shown.map((th, i) => this.row(t, th, i === this.at)));
    this.at = Math.min(this.at, Math.max(0, shown.length - 1));

    return v_flex()
      .id("root")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return closeOverlay(props().overlay);
        if (k === "down" || k === "up") {
          if (!shown.length) return;
          this.at = (this.at + (k === "down" ? 1 : shown.length - 1)) % shown.length;
        } else if (k === "tab" || ((k === "left" || k === "right") && !this.filter)) {
          this.scope = this.scope === "space" ? "all" : "space";
          this.at = 0;
        } else return;
        cx.stop_propagation();
        cx.notify();
      })
      .size_full()
      .bg(t.chrome)
      .text_size(12.5)
      .child(this.header(t, here, mine.length, cx))
      .child(div().flex_1().min_h(0).flex().flex_col().child(body));
  }
}
