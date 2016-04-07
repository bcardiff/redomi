module Redomi::UI
  class SliderInput < Node
    tag_name "input"

    def init
      self["type"] = "range"
    end

    int_property value

    def on_value_change(&on_click : SliderInput, Int64 -> Void)
      on_key = ->(node : Node) {
        node = node as SliderInput
        on_click.call(node, node.value)
      }
      @app.add_event_listener(self, "input", on_key)
      @app.add_event_listener(self, "change", on_key)
    end
  end
end
