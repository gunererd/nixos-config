// Alt+Z: hide the sidebar, the tab bar and the status bar together, and the panes'
// borders, corners and gaps, or bring them back (as the sidebar is). keys.json runs one
// command per key, so the key opens this, which sets the layout and closes itself.
// The look it takes away is kept in shared "zen.look" to put back.

import { View, div } from "gpui-kit";
import { run, layout, props, closeOverlay, shared, setShared } from "herdr";

const PARTS = ["sidebar", "tabs", "status"];
const BARE = { border: { width: 0 }, focus: { width: 0 }, radius: 0, gap: 0, padding: 0 };

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class Zen extends View {
  init(_props, cx) {
    const id = props()?.overlay;
    if (!id) return;
    const l = JSON.parse(JSON.stringify(layout()));
    const show = Boolean(find(l, "sidebar")?.hidden);
    for (const part of PARTS) {
      const n = find(l, part);
      if (n) n.hidden = !show;
    }
    // The panes' look lives on the main block; the space around them on its row.
    const pane = find(l, "main")?.content?.pane, row = find(l, "work-body");
    if (pane && row) {
      if (show) {
        const look = shared("zen.look");
        if (look) {
          Object.assign(pane, look.pane);
          Object.assign(row, look.row);
        }
      } else {
        setShared("zen.look", { pane: { border: pane.border, focus: pane.focus, radius: pane.radius, gap: pane.gap }, row: { padding: row.padding } });
        Object.assign(pane, { border: { ...pane.border, ...BARE.border }, focus: { ...pane.focus, ...BARE.focus }, radius: BARE.radius, gap: BARE.gap });
        row.padding = BARE.padding;
      }
    }
    run("layout.set", { layout: l });
    // A part shown or hidden by its own key keeps that over the file: say it too.
    for (const part of PARTS) run(show ? "layout.show" : "layout.hide", { id: part });
    cx.spawn(async () => closeOverlay(id)); // closing during init is ignored
  }

  render() {
    return div();
  }
}
