require "http/server"

module Redomi
  class Server
    def initialize(@host, @port, @public, &@init : App -> Void)
    end

    def listen
      ws_handler = HTTP::WebSocketHandler.new do |ws|
        Redomi::App.new(ws) do |app|
          @init.call(app)
        end
      end

      server = HTTP::Server.new @host, @port, [
        ws_handler,
        PageHandler.new("/", File.join(Redomi::PATH, "public", "index.html")),
        HTTP::StaticFileHandler.new(@public),
        HTTP::StaticFileHandler.new(File.join(Redomi::PATH, "public")),
      ]
      server.listen
    end

    class PageHandler < HTTP::Handler
      def initialize(@path, @filename : String)
      end

      def call(context)
        case {context.request.method, context.request.resource}
        when {"GET", @path}
          context.response.headers["Content-Type"] = "text/html"
          context.response << File.read(@filename)
        else
          call_next(context)
        end
      end
    end
  end
end
