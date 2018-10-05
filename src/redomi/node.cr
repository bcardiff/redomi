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

    def self.namespace
      nil
    end

    def self.append_to(tag, parent : Node)
      input = parent.app.create_element(tag, self)
      parent.append_child(input)
      input
    end

    def self.append_to(tag, parent : Node)
      input = parent.app.create_element(tag, self)
      yield input
      parent.append_child(input)
      input
    end

    macro tag_name(tag)
      def self.append_to(parent : Node)
        self.append_to({{tag}}, parent)
      end

      def self.append_to(parent : Node, &block : {{@type}} ->)
        self.append_to({{tag}}, parent, &block)
      end
    end

    macro float_attribute(*names)
    {% for name in names %}
      def {{name.id}}=(value)
        self[{{name.stringify}}] = value.to_f64.to_s
      end

      def {{name.id}}
        self[{{name.stringify}}].to_f64
      end
    {% end %}
    end

    macro int_property(*names)
    {% for name in names %}
      def {{name.id}}=(value)
        @app.eval({{"%s.#{name.id} = %s"}}, self, value.to_i64)
      end

      def {{name.id}}
        (@app.eval_sync({{"%s.#{name.id}"}}, self).as(String)).to_i64
      end
    {% end %}
    end

    def append_child(node : Node)
      @app.eval("%s.appendChild(%s)", self, node)
    end

    def parent
      @app.eval_sync("%s.parentElement", self).as(Node)
    end

    def text_content=(text : String)
      @app.eval("%s.textContent = %s", self, text)
    end

    def text_content
      @app.eval_sync("%s.textContent", self).as(String)
    end

    def []=(attribute : String, value : String)
      @app.eval("%s.setAttribute(%s, %s)", self, attribute, value)
    end

    def [](attribute : String)
      @app.eval_sync("%s.getAttribute(%s)", self, attribute).as(String)
    end

    def class_name=(cssClass : String)
      @app.eval("%s.className = %s", self, cssClass)
    end

    def on_click(&on_click : Node -> Void)
      @app.add_event_listener(self, "click", on_click)
    end
  end
end
