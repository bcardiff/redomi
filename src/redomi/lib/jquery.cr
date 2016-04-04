module Redomi::Lib
  class JQuery
    def initialize(@node : Node)
      @app = @node.app
    end

    def text=(text)
      @app.eval("$(%s).text(%s)", @node, text)
    end

    def text
      @app.eval_sync("$(%s).text()", @node) as String
    end

    def html=(html)
      @app.eval("$(%s).html(%s)", @node, html)
    end

    def html
      @app.eval_sync("$(%s).html()", @node) as String
    end

    def parent
      self.class.new(@app.eval_sync("$(%s).parent()[0]", @node) as Node)
    end

    def add_class(css_class)
      @app.eval("$(%s).addClass(%s)", @node, css_class)
    end
  end
end
