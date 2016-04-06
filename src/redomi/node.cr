module Redomi
  class Node
    getter app : App
    getter id : Int32

    # :nodoc:
    def initialize(@id : Int32)
      @app = uninitialized App
    end

    # :nodoc:
    def app=(@app)
      @app.register_node(self)
    end

    def init
    end

    def self.append(parent : Node)
      input = parent.app.create_element("input", self)
      parent.append_child(input)
      input
    end

    def append_child(node : Node)
      @app.eval("%s.appendChild(%s)", self, node)
    end

    def parent
      @app.eval_sync("%s.parentElement", self) as Node
    end

    def text_content=(text : String)
      @app.eval("%s.textContent = %s", self, text)
    end

    def text_content
      @app.eval_sync("%s.textContent", self) as String
    end

    def []=(attribute : String, value : String)
      @app.eval("%s.setAttribute(%s, %s)", self, attribute, value)
    end

    def [](attribute : String)
      @app.eval_sync("%s.getAttribute(%s)", self, attribute) as String
    end

    def class_name=(cssClass : String)
      @app.eval("%s.className = %s", self, cssClass)
    end

    def on_click(&on_click : Node -> Void)
      @app.add_event_listener(self, "click", on_click)
    end
  end
end
