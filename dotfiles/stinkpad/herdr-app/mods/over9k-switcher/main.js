// Cmd+Tab for agents: every agent in the sidebar (all spaces, this computer and
// connected ones), most recently used first (over9k keeps that order: shared
// "over9k.recentAgents"). Opened by over9k (key "over9k.switcher", Ctrl+Tab;
// a Mac-style key remapper can send Cmd+Tab as Ctrl+Tab) on the agent before this one.
// While Ctrl is held, Ctrl+Tab / Ctrl+Shift+Tab move (keys.json's
// "mod:over9k-switcher"); letting go of Ctrl shows the picked agent. Enter and a
// click do too; Esc closes it. agent-name.js is over9k's (copied: mods can't
// import from each other).

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, spaces, panes, run, props, openOverlay, closeOverlay, theme, shared, setShared, nextCommand, home, exec, appHome } from "herdr";
import { agentTask } from "./agent-name.js";

const APP_NAMES = { antigravity: "Antigravity" };
const APP_ICONS = { antigravity: "icons/antigravity.svg" };

// The agents, most recent first; ones never focused after, in the sidebar's order.
// Over9k's sidebar keeps that order (every focus); on its own, this switcher keeps
// its own: the agent you're in when it opens, and each one it switches to.
const OWN = "over9k-switcher.recent";
// Each Claude Code agent's last prompt (last-prompt.py), shown under its name; kept from the last open.
const PROMPTS = "over9k-switcher.prompts";
function remember(address) {
  if (!address || shared("over9k.recentAgents")) return;
  const live = new Set(agents().map((a) => a.address));
  setShared(OWN, [address, ...(shared(OWN) ?? []).filter((x) => x !== address && live.has(x))]);
}
function list() {
  remember(agents().find((a) => a.focused)?.address);
  const recent = shared("over9k.recentAgents") ?? shared(OWN) ?? [];
  const rank = (a) => { const i = recent.indexOf(a.address); return i < 0 ? recent.length : i; };
  return agents().map((a, i) => ({ a, i })).sort((x, y) => rank(x.a) - rank(y.a) || x.i - y.i).map((x) => x.a);
}

function nameOf(a) {
  const p = panes().find((x) => x.terminal === a.address);
  const tab = spaces().flatMap((s) => s.tabs ?? []).find((t) => t.id === (p?.tab ?? a.tab));
  if (tab && tab.name !== a.program?.name && !/^(\d+|t[0-9a-z]+)$/.test(tab.name)) return tab.name;
  return agentTask(a, p?.cwd) || a.program?.name || APP_NAMES[a.app] || a.address;
}

function spaceOf(a) {
  const s = spaces().find((x) => x.id === a.space || (x.tabs ?? []).some((t) => t.id === a.tab));
  if (!s) return "";
  const folder = (s.folder ?? "").replace(/\/+$/, "");
  const name = s.name || (folder === home() ? "~" : folder.split("/").pop());
  return s.machine ? `${name} · ${s.machine}` : name;
}

export default class Switcher extends View {
  init(_props, cx) {
    // mod.json's overlay is a fixed size: reopen as a dialog that fits the rows (46px + 1px gap, 6px padding).
    if (props()?.overlay && !props().fit) {
      this.stub = true;
      // Ctrl+Tab reached the global key while one is open (it lost the keyboard): move it instead.
      if (shared("over9k-switcher.open")) {
        const id = props().overlay;
        cx.spawn(async () => { closeOverlay(id); run("over9k-switcher.next"); run("over9k-switcher.focus"); });
        return;
      }
      openOverlay({ mod: "over9k-switcher", kind: "dialog", width: 460, height: 12 + Math.max(1, list().length) * 47 - 1, props: { fit: true } });
      const id = props().overlay; // closing during init is ignored, so after it
      cx.spawn(async () => { closeOverlay(id); run("over9k-switcher.focus"); });
      return;
    }
    if (props()?.fit) setShared("over9k-switcher.open", true);
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.items = list();
    this.at = this.items.length > 1 ? 1 : 0;
    this.done = false;
    this.tabDown = true;
    this.tabAt = Date.now();
    this.prompts = shared(PROMPTS) ?? {};
    cx.spawn(async (cx) => {
      const r = await exec("python3", ["-I", `${appHome()}/mods/over9k-switcher/last-prompt.py`, `${appHome()}/mods/over9k-prompts/claude-info.py`]).catch(() => null);
      try { this.prompts = JSON.parse(r?.stdout || "{}"); setShared(PROMPTS, this.prompts); cx.notify(); } catch {}
    });
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        if (c === "focus") this.handle.focus();
        else if (c === "next" || c === "prev") {
          // Ctrl+Tab comes as a command, without the key's held flag: a held Tab is down (no
          // key-up yet, and it opened us down) and keeps repeating. Until we've seen a key-up,
          // trust "down" for only 50ms: its key-up may have come before we had the keyboard.
          const now = Date.now(), held = this.tabDown && (this.sawUp || now - this.tabAt < 50);
          this.tabDown = true;
          this.tabAt = now;
          if (!held) { this.move(c === "next" ? 1 : -1); cx.notify(); }
        }
      }
    });
  }

  async close() { if (props()?.fit) setShared("over9k-switcher.open", false); }

  move(by) {
    const n = this.items.length;
    if (n) this.at = (this.at + by + n) % n;
  }

  go() {
    if (this.done) return;
    this.done = true;
    const a = this.items[this.at];
    closeOverlay(props()?.overlay);
    if (!a) return;
    const s = spaces().find((x) => x.id === a.space || (x.tabs ?? []).some((t) => t.id === a.tab));
    if (s && !s.active) run("space.select", { id: s.id });
    run("agent.focus", { terminal: a.address });
    remember(a.address);
  }

  render(cx) {
    if (this.stub) return div();
    const t = theme();
    const color = { working: t.working, blocked: t.blocked, done: t.done, idle: t.idle };
    return v_flex().id("switcher").track_focus(this.handle).w_full().p(6).gap(1).bg(t.popover).text_size(13)
      .on_modifiers_changed((e) => { if (!e.modifiers.control && !e.modifiers.platform) this.go(); })
      .on_key_up((e) => { if (e.key === "tab") { this.tabDown = false; this.sawUp = true; } })
      .on_key_down((e, cx) => {
        // Holding a key doesn't keep moving: each press moves once (this runs before the keymap's Ctrl+Tab).
        if (["tab", "up", "down"].includes(e.key) && e.is_held) return cx.stop_propagation();
        if (e.key === "enter") this.go();
        else if (e.key === "escape") { this.done = true; closeOverlay(props()?.overlay); }
        else if (e.key === "down" || (e.key === "tab" && !e.modifiers?.shift && !e.modifiers?.control)) this.move(1);
        else if (e.key === "up" || (e.key === "tab" && e.modifiers?.shift && !e.modifiers?.control)) this.move(-1);
        else return;
        cx.notify();
      })
      .when(!this.items.length, (el) => el.child(div().p(10).text_color(t.muted).child("No agents running")))
      .children(this.items.map((a, i) => {
        const prog = a.program;
        const icon = prog?.icon ?? APP_ICONS[a.app];
        const prompt = this.prompts[a.address];
        return h_flex().id(`sw-${a.address}`).h(46).px(10).gap(10).items_center().rounded(7)
          .when(i === this.at, (el) => el.bg(t.selected))
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => { this.at = i; this.go(); })
          .child(icon ? (prog?.tint ? svg(icon).size(15).flex_none().text_color(t.foreground) : image(icon).w(15).h(15).flex_none())
            : svg("icons/shell.svg").size(15).flex_none().text_color(t.foreground))
          .child(v_flex().flex_1().min_w(0).gap(1)
            .child(div().truncate().text_color(t.foreground).child(nameOf(a)))
            .child(div().truncate().text_size(11.5).text_color(t.muted).child(prompt ?? "")))
          .child(div().flex_none().max_w(140).truncate().text_size(11.5).text_color(t.dim).child(spaceOf(a)))
          // Working: the sidebar's spinner (over9k's mark); else its status dot.
          .child(a.status === "working"
            ? svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)
            : div().size(7).flex_none().rounded(4).bg(color[a.status] ?? t.unknown));
      }));
  }
}
