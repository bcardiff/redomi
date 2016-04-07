module Redomi::UI
  class SliderInput < Node
    tag_name "input"

    def init
      self["type"] = "range"
    end

    def value=(value)
      @app.eval("%s.value = %s", self, value.to_i64)
    end

    def value
      (@app.eval_sync("%s.value", self) as String).to_i64
    end

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
