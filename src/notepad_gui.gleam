import gleam/int
import plushie/app
import plushie/command
import plushie/event.{type Event, Click, EventTarget, Widget}
import plushie/gui
import plushie/node.{type Node}
import plushie/prop/padding
import plushie/ui
import plushie/widget/column
import plushie/widget/row
import plushie/widget/window

type Model {
  Model(count: Int)
}

fn init() {
  #(Model(count: 0), command.none())
}

fn update(model: Model, event: Event) {
  case event {
    Widget(Click(target: EventTarget(id: "inc", ..))) -> #(
      Model(count: model.count + 1),
      command.none(),
    )
    Widget(Click(target: EventTarget(id: "dec", ..))) -> #(
      Model(count: model.count - 1),
      command.none(),
    )
    _ -> #(model, command.none())
  }
}

fn view(model: Model) -> List(Node) {
  [
    ui.window("main", [window.Title("Counter")], [
      ui.column(
        "content",
        [column.Padding(padding.all(16.0)), column.Spacing(8.0)],
        [
          ui.text_("count", "Count: " <> int.to_string(model.count)),
          ui.row("buttons", [row.Spacing(8.0)], [
            ui.button_("inc", "+"),
            ui.button_("dec", "-"),
          ]),
        ],
      ),
    ]),
  ]
}

fn app() {
  app.simple(init, update, view)
}

pub fn main() {
  gui.run(app(), gui.GuiOpts(..gui.default_opts(), dev: True))
}
