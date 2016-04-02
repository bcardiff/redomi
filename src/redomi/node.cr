module Redomi
  class Node
    getter app
    getter id

    # :nodoc:
    # root node initializer
    def initialize
      @id = 0
      @app = uninitialized App
    end

    # :nodoc:
    def app=(@app : App)
    end

    def initialize(parent : Node, tag : String)
      @app = parent.app
      @id = @app.create_node tag, parent
      @app.register_node(self)
    end

    def text=(text : String)
      @app.exec_node(self, "text", [text])
    end

    def text
      @app.exec_node_wait_response(self, "text").as_s
    end

    def add_class(class_names)
      @app.exec_node(self, "addClass", [class_names])
    end

    def on_click(&on_click : Node -> Void)
      @app.on_node_event(self, "click", on_click)
    end
  end
end
