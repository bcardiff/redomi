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

    def append(node : Node)
      @app.exec_node(self, "append", [node])
    end

    def parent
      (@app.exec_node_wait_response(self, "parent") as Array)[0] as Node
    end

    def text=(text : String)
      @app.exec_node(self, "text", [text])
    end

    def text
      @app.exec_node_wait_response(self, "text") as String
    end

    def add_class(class_names)
      @app.exec_node(self, "addClass", [class_names])
    end

    def on_click(&on_click : Node -> Void)
      @app.on_node_event(self, "click", on_click)
    end
  end
end
