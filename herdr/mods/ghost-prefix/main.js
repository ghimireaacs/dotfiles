import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { closeOverlay, focused, hc, nextCommand, props, run, theme } from "herdr";

// Port of ~/dotfiles/tmux/tmux.conf: prefix is Ctrl+Space, same keys after it.
// tmux -> herdr:  window = tab,  session = space,  pane = pane.
// Ctrl+letter bindings are written "C-h". Only repeatable actions start a
// timer; the first key after the prefix can take as long as you like.
const PREFIX_LABEL = "Ctrl+Space";
const REPEAT_MS = 500; // tmux repeat-time 500
const BINDINGS = [
  // splits (bind | / bind -)
  ["|", "Split right", "pane.split", { direction: "right" }],
  ["-", "Split down", "pane.split", { direction: "down" }],
  // vim pane navigation (bind h/j/k/l)
  ["h", "Focus left", "pane.go", { direction: "left" }],
  ["j", "Focus down", "pane.go", { direction: "down" }],
  ["k", "Focus up", "pane.go", { direction: "up" }],
  ["l", "Focus right", "pane.go", { direction: "right" }],
  ["left", "Focus left", "pane.go", { direction: "left" }, true],
  ["down", "Focus down", "pane.go", { direction: "down" }, true],
  ["up", "Focus up", "pane.go", { direction: "up" }, true],
  ["right", "Focus right", "pane.go", { direction: "right" }, true],
  // H/J/K/L resized in tmux; Herdr has no resize command (drag the divider),
  // so these swap the pane in that direction instead.
  ["H", "Swap pane left", "pane.swap", { direction: "left" }],
  ["J", "Swap pane down", "pane.swap", { direction: "down" }],
  ["K", "Swap pane up", "pane.swap", { direction: "up" }],
  ["L", "Swap pane right", "pane.swap", { direction: "right" }],
  // windows -> tabs (bind -r C-h / C-l, stock c n p x , and digits)
  ["C-h", "Previous tab", "tab.prev", {}, true],
  ["C-l", "Next tab", "tab.next", {}, true],
  ["c", "New tab", "tab.new"],
  ["n", "Next tab", "tab.next"],
  ["p", "Previous tab", "tab.prev"],
  [",", "Rename tab", "tab.rename"],
  ["&", "Close tab", "tab.close"],
  ["x", "Close pane (ends its terminal)", "pane.close"],
  ["z", "Zoom pane", "pane.zoom"],
  ["[", "Search scrollback", "terminal.search"],
  // sessions -> spaces (bind ( / ), s chooser, $ rename)
  ["(", "Previous space", "space.prev", {}, true],
  [")", "Next space", "space.next", {}, true],
  ["s", "Command palette (pick space/tab)", "app.palette"],
  ["o", "Command palette (pick space/tab)", "app.palette"],
  ["S", "New space", "space.new"],
  ["$", "Rename space", "space.rename"],
  // detach: terminals live in herdr-core, so hiding the window = detach
  ["d", "Detach (minimize window)", "window.minimize"],
  // base-index 1: 1-9 are tabs 1-9, 0 is tab 10
  ...Array.from({ length: 10 }, (_, i) => [String(i), `Tab ${i === 0 ? 10 : i}`, "tab.select", { index: i === 0 ? 10 : i }]),
];

function forwardKey(e, key) {
  if (["enter", "tab", "backspace", "left", "right", "up", "down", "space"].includes(e.key)) return e.key;
  if (key === " ") return "space";
  if (/^[A-Z]$/.test(key)) return `shift+${key.toLowerCase()}`;
  if (key.length === 1 && "abcdefghijklmnopqrstuvwxyz0123456789`\\[],=-.';/".includes(key)) return key === "\\" ? "backslash" : key;
  return null;
}

export default class GhostPrefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.repeat = false;
    this.generation = 0;
    this.all = false;
    // The mod-specific key binding beats the global opener while we're open.
    cx.spawn(async (cx) => {
      for (;;) {
        await nextCommand();
        this.sendPrefix(cx);
      }
    });
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  send(key, cx) {
    this.generation++;
    const terminal = focused()?.terminal;
    if (!terminal) return this.dismiss();
    // hc starts its subprocess at the call, before closing cancels this view's tasks.
    const pending = hc(["keys", terminal, key]);
    cx.spawn(async () => {
      const result = await pending;
      if (result.code !== 0) console.log(`ghost-prefix: ${result.stderr}`);
    });
    this.dismiss();
  }

  sendPrefix(cx) {
    this.send("ctrl+space", cx);
  }

  key(e, cx) {
    cx.stop_propagation();
    const m = e.modifiers;
    if (e.key === "escape") return this.dismiss();
    // prefix twice sends a literal Ctrl+Space (tmux: bind C-Space send-prefix)
    if (m.control && e.key === "space") return this.sendPrefix(cx);
    // Ctrl+letter after the prefix (C-h / C-l): look up as "C-x"
    if (m.control && !m.alt && !m.platform && !m.shift && /^[a-z]$/.test(e.key)) {
      const ctrl = BINDINGS.find((b) => b[0] === `C-${e.key}`);
      if (!ctrl) return this.dismiss();
      const [, , command, args = {}, repeatable = false] = ctrl;
      return this.fire(command, args, repeatable, cx);
    }
    const plain = !m.control && !m.alt && !m.platform;
    const key = plain ? (e.key_char ?? (m.shift && e.key.length === 1 ? e.key.toUpperCase() : e.key)) : e.key;
    if (plain && key === "?") {
      this.all = !this.all;
      this.repeat = false;
      this.generation++;
      cx.notify();
      return;
    }
    const binding = plain && BINDINGS.find((b) => b[0] === key);
    if (!binding) {
      const forwarded = this.repeat && plain && forwardKey(e, key);
      if (forwarded) return this.send(forwarded, cx);
      return this.dismiss();
    }
    const [, , command, args = {}, repeatable = false] = binding;
    this.fire(command, args, repeatable, cx);
  }

  fire(command, args, repeatable, cx) {
    if (!repeatable) this.dismiss();
    run(command, args);
    if (repeatable) {
      this.repeat = true;
      const generation = ++this.generation;
      cx.timer.after(REPEAT_MS, () => {
        if (this.generation === generation) this.dismiss();
      });
      cx.notify();
    }
  }

  render() {
    const t = theme();
    const rows = this.all ? BINDINGS : BINDINGS.filter(([key]) => !["left", "right", "up", "down"].includes(key) && !/^\d$/.test(key));
    return v_flex().id("ghost-prefix").track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
      .child(h_flex().justify_between().child(div().font_semibold().child(this.repeat ? `Repeat · ${REPEAT_MS} ms` : `${PREFIX_LABEL} · waiting for a key`))
        .child(div().text_color(t.muted).child(`Esc cancel · ${PREFIX_LABEL} again sends it`)))
      .child(v_flex().h(280).min_h(0).overflow_y_scrollbar().children(rows.map(([key, label, , , repeatable]) =>
        h_flex().h(20).flex_none().items_center().gap(12).child(div().w(40).text_color(t.accent).child(key))
          .child(div().flex_1().child(label)).child(div().text_color(t.dim).child(repeatable ? "repeat" : "")))))
      .child(div().text_color(t.muted).child("0–9 tabs (0 = 10) · arrows focus · ? all bindings"));
  }
}
