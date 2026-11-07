import { View, div, svg, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { spaces, panes, focused, run, openOverlay, closeOverlay, props, theme, window, shared, setShared, layout, settings, exec } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// A press on a menu's own button closes the menu before the click lands, so the click
// would open it again: a menu that closed just now (by that press) stays closed.
const CLOSED = "tabs-graph.closed";
export const justClosed = (role) => { const c = shared(CLOSED); return c?.role === role && Date.now() - c.at < 400; };

export default class Tabs extends View {
  async close() { if (props()?.role) setShared(CLOSED, { role: props().role, at: Date.now() }); }

  init(_props, cx) {
    // Claude accounts from claude-swap; the popup that switches bumps "cswap.tick" so the bar reloads.
    this.accounts = null;
    this.loadAccounts(cx);
    cx.timer.every(60000, (cx) => this.loadAccounts(cx));
    if (props()?.role) return;
    this.pressed = null;
    this.panels = JSON.parse(localStorage.getItem("panels") ?? "{}");
  }

  // The side panel is remembered per tab: switching shows that tab's choice
  // (closed if it never had one), and opening or closing it records it.
  // A lone pane keeps its header but shows no focus border: the layout can't say "only when
  // split" for the border alone, so the focus color follows the shown tab's pane count.
  syncFocus(root, tab) {
    const pane = find(root, "main")?.content?.pane;
    if (!pane?.focus || !tab) return;
    const own = panes().filter(p => p.tab === tab.id);
    const want = own.length <= 1 || tab.zoomed ? "canvas" : "accent";
    if (pane.focus.color === want || this.focusSent === want) return;
    this.focusSent = want;
    const next = JSON.parse(JSON.stringify(root));
    find(next, "main").content.pane.focus.color = want;
    run("layout.set", { layout: next });
  }

  syncPanel(key, panel, body, enabled) {
    if (!key || !panel) return;
    const now = panel.hidden ? null : body?.active ?? null;
    if (key !== this.space) {
      const first = this.space === undefined;
      this.space = key; this.pending = null;
      if (!(first && !(key in this.panels))) {
        const stored = this.panels[key] ?? null, want = enabled.includes(stored) ? stored : null;
        if (want !== now) {
          this.pending = { want, until: Date.now() + 1000 };
          if (want) { run("layout.select", { stack: "panel-body", child: want }); run("layout.show", { id: "panel" }); }
          else run("layout.hide", { id: "panel" });
          return;
        }
      }
    }
    // Until the restore lands (or something else won), the old state isn't a choice.
    if (this.pending) {
      if (this.pending.want !== now && Date.now() < this.pending.until) return;
      this.pending = null;
    }
    if (this.panels[key] === now) return;
    this.panels[key] = now;
    localStorage.setItem("panels", JSON.stringify(this.panels));
  }

  // The Git button's dropdown, opened as a popup of this mod with props { role: "git" }.
  loadAccounts(cx) {
    this.tick = shared("cswap.tick");
    cx.spawn(async (cx) => {
      const r = await exec("cswap", ["list", "--json"]);
      if (r.code !== 0) return;
      try { this.accounts = JSON.parse(r.stdout).accounts; } catch { return; }
      cx.notify();
    });
  }

  // Each account with bars like Omarchy's usage panel: use, and when it resets. Click one to switch to it.
  renderAccountMenu(t) {
    const TRACK = 224;
    const limit = (label, u) => v_flex().gap(4).pt(6)
      .child(h_flex().justify_between().text_color(t.foreground).child(label).child(u?.pct == null ? "–" : `${Math.round(u.pct)}%`))
      .child(div().w(TRACK).h(5).rounded(3).bg(t.border).child(div().h_full().rounded(3).bg(t.working).w(TRACK * Math.min(100, u?.pct ?? 0) / 100)))
      .when(Boolean(u?.countdown), el => el.child(div().text_size(11).text_color(t.dim).child(`Resets in ${u.countdown}`)));
    return v_flex().size_full().p(5).gap(4).bg(t.popover).text_size(12.8)
      .children((this.accounts ?? []).map(a => v_flex().id(`acct-${a.number}`).px(8).py(7).rounded(7)
        .hover(s => s.bg(t.hover)).when(a.active, el => el.bg(t.selected))
        .on_click(() => {
          const overlay = props().overlay;
          (a.active ? Promise.resolve() : exec("cswap", ["switch", String(a.number)])).then(() => {
            setShared("cswap.tick", Date.now());
            closeOverlay(overlay);
          });
        })
        .child(h_flex().gap(8).items_center().text_color(t.foreground)
          .child(div().text_color(t.muted).child(String(a.number)))
          .child(div().flex_1().truncate().font_medium().child(a.email.split("@")[0]))
          .child(a.active ? svg("mods/workspace-chrome/check.svg").size(14) : div().text_size(11).text_color(t.dim).child("Switch")))
        .child(limit("Session", a.usage?.fiveHour))
        .child(limit("Weekly", a.usage?.sevenDay))));
  }

  renderGitMenu(t) {
    // Each opens zoomed, as a pane of the focused tab, on the focused pane's folder;
    // picking one the tab already has closes it.
    const space = spaces().find(p => p.active), tab = space?.tabs.find(c => c.active);
    const here = panes().filter(p => p.tab === tab?.id), f = focused();
    const cwd = here.find(p => p.pane === f?.pane && !p.mod)?.cwd ?? here.find(p => !p.mod)?.cwd ?? space?.folder;
    const mine = (id) => here.find(p => p.mod === id);
    const open = (id) => {
      closeOverlay(props().overlay);
      if (mine(id)) run("pane.close", { pane: mine(id).pane });
      else { run("pane.split", { direction: "right", mod: id, props: { folder: cwd } }); run("pane.zoom"); }
    };
    const row = (id, label, icon) => h_flex().id(`git-${id}`).h(28).px(8).gap(7).items_center().rounded(6).text_color(t.foreground).when(Boolean(mine(id)), el => el.bg(t.selected))
      .hover(s => s.bg(t.hover)).on_click(() => open(id)).child(svg(icon).size(14).text_color(t.muted)).child(label);
    return v_flex().size_full().p(5).bg(t.popover).text_size(12.8)
      .child(row("changes-pane", "Changes", "mods/changes/changes.svg"))
      .child(row("git-graph", "Graph", "mods/git-graph/icons/graph.svg"));
  }

  // The More dropdown: Automations in the side panel, Over9k's Timeline and To-do docked on the right.
  renderMoreMenu(t) {
    const root = layout(), panel = find(root, "panel"), body = find(root, "panel-body");
    const items = [
      { id: "automations", label: "Automations", icon: "mods/automations/automations.svg",
        on: panel && !panel.hidden && body?.active === "automations",
        toggle: (on) => { if (on) run("layout.hide", { id: "panel" }); else { run("layout.select", { stack: "panel-body", child: "automations" }); run("layout.show", { id: "panel" }); } } },
      { id: "timeline", label: "Timeline", icon: "mods/over9k-prompts/timeline.svg", keys: "Ctrl+Shift+H" },
      { id: "todo", label: "To-do", icon: "mods/workspace-chrome/circle-check.svg", keys: "Ctrl+Shift+Y" },
    ].map(i => i.toggle ? i : { ...i, on: !find(root, i.id)?.hidden, toggle: () => run("layout.toggle", { id: i.id }) });
    return v_flex().size_full().p(5).bg(t.popover).text_size(12.8)
      .children(items.map(i => h_flex().id(`more-${i.id}`).h(28).px(8).gap(7).items_center().rounded(6).text_color(t.foreground).when(i.on, el => el.bg(t.selected))
        .hover(s => s.bg(t.hover)).on_click(() => { closeOverlay(props().overlay); i.toggle(i.on); })
        .child(svg(i.icon).size(14).text_color(t.muted)).child(div().flex_1().child(i.label))
        .when(Boolean(i.keys), el => el.child(div().text_size(11).text_color(t.dim).child(i.keys)))));
  }

  render(cx) {
    const t = theme();
    if (props()?.role === "git") return this.renderGitMenu(t);
    if (props()?.role === "more") return this.renderMoreMenu(t);
    if (props()?.role === "account") return this.renderAccountMenu(t);
    if (shared("cswap.tick") !== this.tick) this.loadAccounts(cx);
    const space = spaces().find(p => p.active);
    const shown = space?.tabs ?? [];
    // Tabs holding only agents are reached from the agents list, so they get no pill.
    const agentOnly = (id) => { const own = panes().filter(p => p.tab === id); return own.length > 0 && own.every(p => p.mod || p.program?.agent) && own.some(p => p.program?.agent); };
    const visible = shown.filter(c => !agentOnly(c.id));
    const stop = (_e, cx) => cx.stop_propagation();
    const button = (id, label, action) => div().id(id).size(22).flex_none().flex().items_center().justify_center().rounded(6).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", stop).on_click(action).child(label);
    const item = (c, i) => {
      const program = panes().find(p => p.tab === c.id && p.program?.agent)?.program ?? panes().find(p => p.tab === c.id)?.program;
      const name = /^tb\d+$/.test(c.name) ? program?.name ?? "Terminal" : c.name;
      return h_flex().id(`tab-${c.id}`).h(22).px(10).gap(7).rounded(7).items_center().flex_none().text_size(12.8)
        .border(1).border_color(c.active ? t.border : t.chrome).bg(c.active ? t.raised : t.chrome).text_color(c.active ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover))
        .on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.pressed = i; if (e.click_count === 2) run("tab.rename", { id: c.id }); })
        .on_mouse_up("left", () => {
          const from = this.pressed; this.pressed = null;
          if (from !== null && from !== i) run("tab.move", { id: visible[from].id, index: space.tabs.findIndex(x => x.id === c.id) + 1 });
          else run("tab.select", { id: c.id });
        })
        .on_mouse_down("right", (_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }); })
        .when(Boolean(program?.icon), el => el.child(program.tint ? svg(program.icon).size(14).text_color(t.muted) : image(program.icon).size(14)))
        .child(div().max_w(170).truncate().child(c.zoomed ? `${name} Z` : name))
        .when(c.status === "working", el => el.child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)))
        .when(c.status === "blocked" || c.status === "done", el => el.child(div().size(6).rounded(3).bg(t[c.status])))
        .when(c.active, el => el.child(div().id(`close-${c.id}`).text_color(t.dim).on_mouse_down("left", stop).on_click((_e, cx) => { cx.stop_propagation(); run("tab.close", { id: c.id }); }).child(svg("mods/pane/close.svg").size(12))));
    };
    const root = layout(), sidebar = find(root, "sidebar"), w = window();
    // Old saved rails and a dragged-narrow sidebar can be smaller than the window buttons.
    const lightsPadding = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen && root?.traffic_lights
      ? Math.max(10, (root.traffic_lights[0] + 64) / settings().zoom - (sidebar?.hidden ? 0 : sidebar?.size?.px ?? 0))
      : 10;
    const panel = find(root, "panel"), body = find(root, "panel-body");
    const enabled = [...(shared("workspace.panels") ?? ["files", "changes"]), "graph", "automations"];
    this.syncPanel(shown.find(c => c.active)?.id, panel, body, enabled);
    this.syncFocus(root, shown.find(c => c.active));
    // One right-hand panel at a time: whichever opened last (button, menu or key) closes the others.
    const side = ["panel", "timeline", "todo"].filter(id => { const n = find(root, id); return n && !n.hidden; });
    if (side.length > 1) {
      const fresh = side.find(id => !this.side?.includes(id)) ?? side[side.length - 1];
      for (const id of side) if (id !== fresh) run("layout.hide", { id });
    }
    this.side = side;
    const panelButton = (id, label, icon) => {
      const on = panel && !panel.hidden && body?.active === id;
      return h_flex().id(`panel-${id}`).h(22).px(8).gap(5).flex_none().items_center().rounded(6)
        .text_size(12).bg(on ? t.selected : t.chrome).text_color(on ? t.foreground : t.muted)
        .hover(s => s.bg(t.hover)).on_mouse_down("left", stop)
        .on_click(() => {
          if (on) run("layout.hide", { id: "panel" });
          else { run("layout.select", { stack: "panel-body", child: id }); run("layout.show", { id: "panel" }); }
        }).child(svg(icon).size(14)).child(label);
    };
    // Changes and Graph live in one Git dropdown; the button lights while the tab has either.
    const gitOn = panes().some(p => p.tab === shown.find(c => c.active)?.id && (p.mod === "changes-pane" || p.mod === "git-graph"));
    const gitButton = h_flex().id("panel-git").h(22).px(8).gap(5).flex_none().items_center().rounded(6)
      .text_size(12).bg(gitOn ? t.selected : t.chrome).text_color(gitOn ? t.foreground : t.muted)
      .hover(s => s.bg(t.hover)).on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.gitFrom = e.bounds; })
      // Hung above the button (the bar is at the bottom), right edges together, wherever on it the click lands.
      .on_click(() => {
        if (justClosed("git")) return;
        const b = this.gitFrom, z = Number(settings()?.zoom) || 1;
        openOverlay({ mod: "tabs-graph", kind: "popup", width: 160, height: 66, at: b ? { x: b.x + b.width - 160 * z, y: b.y - 66 * z - 4 * z } : "pointer", props: { role: "git" } });
      })
      .child(svg("mods/git-graph/icons/graph.svg").size(14)).child("Git").child(svg("mods/workspace-chrome/chevron-down.svg").size(12));
    // Automations, Timeline and To-do live in one More dropdown; it lights while one is open.
    const moreOn = (panel && !panel.hidden && body?.active === "automations") || ["timeline", "todo"].some(id => find(root, id) && !find(root, id).hidden);
    const moreButton = h_flex().id("panel-more").h(22).px(8).gap(5).flex_none().items_center().rounded(6)
      .text_size(12).bg(moreOn ? t.selected : t.chrome).text_color(moreOn ? t.foreground : t.muted)
      .hover(s => s.bg(t.hover)).on_mouse_down("left", (e, cx) => { cx.stop_propagation(); this.moreFrom = e.bounds; })
      .on_click(() => {
        if (justClosed("more")) return;
        const b = this.moreFrom, z = Number(settings()?.zoom) || 1;
        openOverlay({ mod: "tabs-graph", kind: "popup", width: 210, height: 96, at: b ? { x: b.x + b.width - 210 * z, y: b.y - 96 * z - 4 * z } : "pointer", props: { role: "more" } });
      })
      .child(svg("mods/workspace-chrome/layers.svg").size(14)).child("More").child(svg("mods/workspace-chrome/chevron-down.svg").size(12));
    return h_flex().size_full().min_w(0).px(10).pl(lightsPadding).gap(3).items_center().bg(t.chrome).border_t(1).border_color(t.border)
      .on_mouse_up("left", () => { this.pressed = null; })
      .on_scroll_wheel(e => { if (Math.abs(e.delta.y) >= 1) run(e.delta.y > 0 ? "tab.prev" : "tab.next"); })
      .child(h_flex().id("tab-scroll").flex_1().min_w(0).h_full().items_center().gap(3).overflow_x_scrollbar().children(visible.map(item)))
      .when(enabled.includes("files"), el => el.child(panelButton("files", "Files", "mods/files/file.svg")))
      .child(gitButton)
      .child(moreButton)
      .when(w?.buttons, el => el.child(button("minimize", w.platform === "windows" ? svg("mods/tabs-graph/win-min.svg").size(16) : "−", () => run("window.minimize")))
        .child(button("maximize", w.platform === "windows" ? svg(`mods/tabs-graph/${w.maximized ? "win-restore" : "win-max"}.svg`).size(16) : "□", () => run("window.maximize")))
        .child(button("close-window", w.platform === "windows" ? svg("mods/tabs-graph/win-close.svg").size(16) : svg("mods/pane/close.svg").size(13), () => run("window.close"))));
  }
}
