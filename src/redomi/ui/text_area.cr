module Redomi::UI
  class TextArea < Node
    tag_name "textarea"

    def value=(value : String)
      @app.eval("%s.value = %s", self, value)
    end

    def value
      @app.eval_sync("%s.value", self).as(String)
    end

    def on_value_change(&on_click : TextArea, String -> Void)
      on_key = ->(node : Node) {
        node = node.as(TextArea)
        on_click.call(node, node.value)
      }
      @app.add_event_listener(self, "keypress", on_key)
      @app.add_event_listener(self, "keyup", on_key)
    end
  end
end
