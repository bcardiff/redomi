module Redomi::Lib
  class D3
    @app : App

    def initialize(@node : Node)
      @app = @node.app
    end

    def transition
      Transition.new(@node)
    end

    class Transition
      @app : App

      def initialize(@node : Node)
        @app = @node.app
      end

      def style(properties : NamedTuple)
        style(properties.to_h)
      end

      def style(properties : Hash)
        js_style = properties.map { |k, v| %(.style(#{k.to_json}, #{v.to_json})) }.join
        @app.eval("d3.select(%s).transition()#{js_style}", @node)
      end
    end
  end
end
