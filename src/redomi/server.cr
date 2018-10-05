require "http/server"

module Redomi
  module Server
    def self.setup_handlers(public : String? = nil, &init : App -> Void)
      ws_handler = HTTP::WebSocketHandler.new do |ws|
        Redomi::App.new(ws) do |app|
          init.call(app)
        end
      end

      handlers = [
        ws_handler,
        PageHandler.new("/", File.join(Redomi::PATH, "public", "index.html")),
      ] of HTTP::Handler

      if public
        handlers << HTTP::StaticFileHandler.new(public)
      end

      handlers << HTTP::StaticFileHandler.new(File.join(Redomi::PATH, "public"))

      handlers
    end

    def self.setup(public : String? = nil, &init : App -> Void)
      HTTP::Server.new setup_handlers(public, &init)
    end

    class PageHandler
      include HTTP::Handler

      def initialize(@path : String, @filename : String)
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
