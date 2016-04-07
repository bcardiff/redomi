require "http/server"

module Redomi
  class Server
    def initialize(@host, @port, @public = nil, &@init : App -> Void)
    end

    def listen
      ws_handler = HTTP::WebSocketHandler.new do |ws|
        Redomi::App.new(ws) do |app|
          @init.call(app)
        end
      end

      handlers = [
        ws_handler,
        PageHandler.new("/", File.join(Redomi::PATH, "public", "index.html")),
      ]

      if public = @public
        handlers << HTTP::StaticFileHandler.new(public)
      end

      handlers << HTTP::StaticFileHandler.new(File.join(Redomi::PATH, "public"))

      server = HTTP::Server.new @host, @port, handlers

      puts "Listening on http://#{@host}:#{@port}"
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
