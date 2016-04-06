module Redomi::Lib
  class D3
    def initialize(@node : Node)
      @app = @node.app
    end

    def transition
      Transition.new(@node)
    end

    class Transition
      def initialize(@node : Node)
        @app = @node.app
      end

      def style(properties : Hash)
        js_style = properties.map { |k, v| %(.style(#{k.to_json}, #{v.to_json})) }.join
        @app.eval("d3.select(%s).transition()#{js_style}", @node)
      end
    end
  end
end
