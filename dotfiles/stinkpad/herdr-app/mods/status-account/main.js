import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, exec, shared, openOverlay, settings, focused } from "herdr";

export default class WorkspaceStatus extends View {
  // Claude accounts from claude-swap; tabs-graph's account popup bumps "cswap.tick" after a switch.
  init(_props, cx) {
    this.accounts = null;
    this.load(cx);
    cx.timer.every(60000, (cx) => this.load(cx));
  }

  load(cx) {
    this.tick = shared("cswap.tick");
    cx.spawn(async (cx) => {
      const r = await exec("cswap", ["list", "--json"]);
      if (r.code !== 0) return;
      try { this.accounts = JSON.parse(r.stdout).accounts; } catch { return; }
      cx.notify();
    });
  }

  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  render(cx) {
    const t = theme();
    if (shared("cswap.tick") !== this.tick) this.load(cx);
    // The focused agent's account when it runs on one of its own (`cswap run`), else the default login.
    const own = shared("agents.accountOf")?.[focused()?.agent];
    const def = this.accounts?.find(a => a.active);
    const acct = (own && this.accounts?.find(a => a.number === own)) || def;
    const pct = (u) => (u?.pct == null ? "–" : `${Math.round(u.pct)}%`);
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(h_flex().flex_none().gap(16).items_center()
        .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
        .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`${needs} needs you`))))
      .when(Boolean(acct), el => el.child(h_flex().id("cswap").h(20).px(8).gap(5).items_center().rounded(5)
        .hover(s => s.bg(t.hover).text_color(t.foreground)).tooltip(acct === def ? `Claude account: ${acct.email}` : `Only this agent uses ${acct.email}. Default: ${def?.email}`)
        .on_mouse_down("left", (e) => { this.from = e.bounds; })
        // Centered just above the button, wherever on it the click lands.
        .on_click(() => {
          // Its menu closed by this very press (see tabs-graph): don't open it again.
          const c = shared("tabs-graph.closed");
          if (c?.role === "account" && Date.now() - c.at < 400) return;
          const W = 250, H = 10 + 150 * this.accounts.length, b = this.from, z = Number(settings()?.zoom) || 1;
          openOverlay({ mod: "tabs-graph", kind: "popup", width: W, height: H, at: b ? { x: b.x + b.width / 2 - (W * z) / 2, y: b.y - H * z - 4 * z } : "pointer", props: { role: "account" } });
        })
        // A name in parentheses: this agent's own account, not the default login.
        .child(acct === def ? acct.email.split("@")[0] : `(${acct.email.split("@")[0]})`)
        .child(`· ${pct(acct.usage?.fiveHour)} · ${pct(acct.usage?.sevenDay)}`)
        .child(svg("mods/workspace-chrome/chevron-down.svg").size(11))));
  }
}
