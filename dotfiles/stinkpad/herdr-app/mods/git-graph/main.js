import { View, div } from "gpui-kit";
import { props, theme } from "herdr";
import { Graph } from "./graph.js";
import { Menu } from "./menu.js";
import { Dialog } from "./dialog.js";
import { Update } from "./update.js";
import { Settings } from "./settings.js";

// One mod, several roles: the graph (a panel or a pane), and over the window the
// right-click menu, the dialogs its actions ask first, the update window and
// the Manygit settings (props.role).
export default class GitGraph extends View {
  init(_props, cx) {
    const role = props()?.role;
    this.part = role === "menu" ? new Menu() : role === "dialog" ? new Dialog() : role === "update" ? new Update() : role === "settings" ? new Settings() : new Graph();
    this.part.init(cx);
  }

  // As the right-hand panel (no role, not a pane) it draws its own left edge: Herdr's
  // divider only runs between the window's top-level columns.
  render(cx) {
    const el = this.part.render(cx);
    if (props()?.role || props()?.pane) return el;
    return div().size_full().min_h(0).flex().flex_col().border_l(1).border_color(theme().border).child(el);
  }
}
